"""Build and inspect the independent Windows installer from an installed runtime."""
import argparse
import ctypes
from ctypes import wintypes
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import uuid
import xml.etree.ElementTree as ET
import zipfile


WIX_NS = "http://schemas.microsoft.com/wix/2006/wi"
COMPONENT_NAMESPACE = uuid.UUID("a04d8381-e2c4-4e6d-a8df-a05cdeac7e17")
UPGRADE_CODE = "F41E049E-37F2-4B74-88CA-16B96A979CE8"
ET.register_namespace("", WIX_NS)


def digest(path):
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def element(parent, tag, **attributes):
    return ET.SubElement(parent, "{" + WIX_NS + "}" + tag, attributes)


def identifier(prefix, path):
    return prefix + hashlib.sha256(path.encode("utf8")).hexdigest()[:24]


def msi_rows(path, sql):
    """Query an MSI read-only, without running installation actions."""
    library = ctypes.WinDLL("msi")
    handle = wintypes.UINT
    library.MsiOpenDatabaseW.argtypes = [wintypes.LPCWSTR, wintypes.LPCWSTR, ctypes.POINTER(handle)]
    library.MsiDatabaseOpenViewW.argtypes = [handle, wintypes.LPCWSTR, ctypes.POINTER(handle)]
    library.MsiViewExecute.argtypes = [handle, handle]
    library.MsiViewFetch.argtypes = [handle, ctypes.POINTER(handle)]
    library.MsiRecordGetFieldCount.argtypes = [handle]
    library.MsiRecordGetStringW.argtypes = [handle, wintypes.UINT, wintypes.LPWSTR, ctypes.POINTER(wintypes.DWORD)]
    library.MsiCloseHandle.argtypes = [handle]
    database, view = handle(), handle()
    if library.MsiOpenDatabaseW(str(path), None, ctypes.byref(database)):
        raise RuntimeError("Cannot inspect MSI database")
    try:
        if library.MsiDatabaseOpenViewW(database, sql, ctypes.byref(view)):
            raise RuntimeError("Cannot open MSI view")
        if library.MsiViewExecute(view, 0):
            raise RuntimeError("Cannot execute MSI query")
        rows = []
        while True:
            record = handle()
            result = library.MsiViewFetch(view, ctypes.byref(record))
            if result == 259:
                break
            if result:
                raise RuntimeError("Cannot fetch MSI record")
            try:
                values = []
                for index in range(1, library.MsiRecordGetFieldCount(record) + 1):
                    buffer = ctypes.create_unicode_buffer(32768)
                    length = wintypes.DWORD(len(buffer))
                    if library.MsiRecordGetStringW(record, index, buffer, ctypes.byref(length)):
                        raise RuntimeError("Cannot read MSI record")
                    values.append(buffer.value)
                rows.append(values)
            finally:
                library.MsiCloseHandle(record)
        return rows
    finally:
        if view.value:
            library.MsiCloseHandle(view)
        library.MsiCloseHandle(database)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--spec", type=Path, required=True)
    parser.add_argument("--artifact-dir", type=Path, required=True)
    args = parser.parse_args()
    spec = json.loads(args.spec.read_text(encoding="utf-8-sig"))
    artifact = args.artifact_dir.resolve()
    install = Path(spec["install"])
    source = Path(spec["snapshot"])
    wix = Path(spec["wix"])
    runtime_manifest = json.loads((artifact / "build-result.json").read_text(encoding="utf8"))
    runtime_zip = artifact / "MuseScore-4.7.6-drawing-runtime.zip"
    if digest(runtime_zip) != runtime_manifest["archiveSha256"]:
        raise RuntimeError("Runtime ZIP checksum mismatch")
    files = sorted(path for path in install.rglob("*") if path.is_file())
    if len(files) < 1000 or sum(path.stat().st_size for path in files) < 100_000_000:
        raise RuntimeError("Incomplete installer payload")

    package_id = spec["releaseId"]
    installer = artifact / (package_id + "-windows-x64-installer.msi")
    portable = artifact / (package_id + "-windows-x64-portable.zip")
    shutil.copyfile(runtime_zip, portable)
    if digest(portable) != runtime_manifest["archiveSha256"]:
        raise RuntimeError("Portable copy checksum mismatch")

    root = ET.Element("{" + WIX_NS + "}Wix")
    product_code = str(uuid.uuid5(COMPONENT_NAMESPACE, package_id)).upper()
    product = element(root, "Product", Id=product_code, Name="MuseScore Drawing " + spec["version"] + " - " + spec["timestamp"],
                      Language="1033", Version=spec["version"], Manufacturer="Breno Oliveira", UpgradeCode=UPGRADE_CODE)
    element(product, "Package", InstallerVersion="500", Compressed="yes", InstallScope="perMachine", Platform="x64")
    element(product, "MediaTemplate", EmbedCab="yes", CompressionLevel="high")
    element(product, "MajorUpgrade", AllowSameVersionUpgrades="yes", Schedule="afterInstallInitialize",
            DowngradeErrorMessage="A newer MuseScore Drawing edition is installed.")
    element(product, "Property", Id="ARPNOMODIFY", Value="1")
    element(product, "Property", Id="ARPURLINFOABOUT", Value=spec["repositoryUrl"])
    element(product, "Icon", Id="DrawingIcon", SourceFile=str(source / "share/icons/AppIcon/MS4_AppIcon.ico"))
    element(product, "Property", Id="ARPPRODUCTICON", Value="DrawingIcon")
    element(product, "WixVariable", Id="WixUILicenseRtf", Value=str(source / "buildscripts/packaging/Windows/Installer/LICENSE.rtf"))
    element(product, "UIRef", Id="WixUI_Minimal")
    element(product, "UIRef", Id="WixUI_ErrorProgressText")
    condition = element(product, "Condition", Message="This installer requires 64-bit Windows.")
    condition.text = "VersionNT64"

    target = element(product, "Directory", Id="TARGETDIR", Name="SourceDir")
    program_files = element(target, "Directory", Id="ProgramFiles64Folder")
    install_root = element(program_files, "Directory", Id="DRAWING_INSTALL_ROOT", Name="MuseScore Drawing 4.7")
    directories = {".": install_root}
    feature = element(product, "Feature", Id="DrawingApplication", Title="MuseScore Drawing", Level="1", Absent="disallow")
    for path in files:
        relative = path.relative_to(install)
        current = Path(".")
        for part in relative.parent.parts:
            child = current / part
            key = child.as_posix()
            if key not in directories:
                directories[key] = element(directories[current.as_posix()], "Directory", Id=identifier("D", key), Name=part)
            current = child
        key = relative.as_posix()
        component_id = identifier("C", key)
        component = element(directories[current.as_posix()], "Component", Id=component_id,
                            Guid=str(uuid.uuid5(COMPONENT_NAMESPACE, key.lower())).upper(), Win64="yes")
        element(component, "File", Id=identifier("F", key), Source=str(path), KeyPath="yes")
        element(feature, "ComponentRef", Id=component_id)

    menu = element(target, "Directory", Id="ProgramMenuFolder")
    drawing_menu = element(menu, "Directory", Id="DrawingProgramMenu", Name="MuseScore Drawing 4.7")
    shortcut_component = element(drawing_menu, "Component", Id="DrawingShortcut",
                                 Guid=str(uuid.uuid5(COMPONENT_NAMESPACE, "start-menu")).upper(), Win64="yes")
    element(shortcut_component, "Shortcut", Id="DrawingStartMenu", Name="MuseScore Drawing 4.7",
            Target="[DRAWING_INSTALL_ROOT]bin\\MuseScore4.exe", WorkingDirectory=identifier("D", "bin"), Icon="DrawingIcon")
    element(shortcut_component, "RemoveFolder", Id="RemoveDrawingMenu", On="uninstall")
    element(shortcut_component, "RegistryValue", Root="HKLM", Key="Software\\BrenoOliveira\\MuseScoreDrawing4.7",
            Name="Installed", Type="integer", Value="1", KeyPath="yes")
    element(feature, "ComponentRef", Id="DrawingShortcut")

    work = artifact.parent / "installer-work"
    work.mkdir(exist_ok=True)
    document = work / "drawing.wxs"
    ET.indent(root)
    ET.ElementTree(root).write(document, encoding="utf-8", xml_declaration=True)
    object_file = work / "drawing.wixobj"
    subprocess.run([str(wix / "candle.exe"), "-nologo", "-arch", "x64", "-out", str(object_file), str(document)], check=True)
    subprocess.run([str(wix / "light.exe"), "-nologo", "-ext", "WixUIExtension", "-out", str(installer), str(object_file)],
                   cwd=work, check=True)

    properties = dict(msi_rows(installer, "SELECT `Property`, `Value` FROM `Property`"))
    if properties.get("UpgradeCode", "").strip("{}") != UPGRADE_CODE or properties.get("ProductCode") != "{" + product_code + "}":
        raise RuntimeError("Installer product identity mismatch")
    file_rows = msi_rows(installer, "SELECT `File`, `FileName`, `FileSize` FROM `File`")
    if len(file_rows) != len(files) or sum(int(row[2]) for row in file_rows) != sum(path.stat().st_size for path in files):
        raise RuntimeError("MSI payload does not match the complete installed runtime")
    directory_rows = msi_rows(installer, "SELECT `Directory`, `Directory_Parent`, `DefaultDir` FROM `Directory`")
    if not any(row[0] == "DRAWING_INSTALL_ROOT" and row[1] == "ProgramFiles64Folder"
               and row[2].split("|")[-1] == "MuseScore Drawing 4.7" for row in directory_rows):
        raise RuntimeError("Installer destination mismatch")
    registry_rows = msi_rows(installer, "SELECT `Key` FROM `Registry`")
    if any(row[0] != "Software\\BrenoOliveira\\MuseScoreDrawing4.7" for row in registry_rows):
        raise RuntimeError("Installer writes an unexpected registry key")
    upgrades = msi_rows(installer, "SELECT `UpgradeCode` FROM `Upgrade`")
    if not upgrades or any(row[0] != "{" + UPGRADE_CODE + "}" for row in upgrades):
        raise RuntimeError("Installer targets a different product for upgrades")
    with zipfile.ZipFile(runtime_zip) as archive:
        if archive.testzip():
            raise RuntimeError("Portable ZIP integrity failed")

    public_spec = {key: spec[key] for key in ("releaseId", "version", "timestamp", "repositoryUrl", "revision", "tag")}
    manifest = dict(public_spec, createdAt=datetime.now(timezone.utc).isoformat(), installerProductCode=product_code,
                    installerUpgradeCode=UPGRADE_CODE, installDirectory="[ProgramFiles64Folder]MuseScore Drawing 4.7",
                    payloadFiles=len(file_rows), payloadBytes=sum(int(row[2]) for row in file_rows),
                    installerTablesValidated=True, installedOnSystem=False, guiValidated=False,
                    assets=[dict(name=path.name, bytes=path.stat().st_size, sha256=digest(path)) for path in (installer, portable)])
    (artifact / "distribution-manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf8")
    (artifact / "SHA256SUMS.txt").write_text("".join(asset["sha256"] + "  " + asset["name"] + "\n" for asset in manifest["assets"]), encoding="utf8")
    print(json.dumps({"installer": str(installer), "portable": str(portable), "files": len(file_rows)}), flush=True)


if __name__ == "__main__":
    main()
