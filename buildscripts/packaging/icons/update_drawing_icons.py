"""Regenerate application icons from the independent edition's approved image.

Requires Pillow. Existing build scripts consume the generated files directly;
Pillow is only needed when updating this icon set, not when building MuseScore.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

from PIL import Image

PNG_SIZES = (16, 24, 32, 48, 64, 96, 128, 256, 512, 1024, 2048)
ICO_SIZES = (16, 24, 32, 48, 64, 96, 128, 192, 256)


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, default=Path(__file__).resolve().parents[3])
    args = parser.parse_args()
    root = args.source_root.resolve(strict=True)
    directory = root / "share/icons/AppIcon"
    master = directory / "MS4_Drawing_AppIcon.png"
    original_hash = sha256(master)
    with Image.open(master) as source:
        image = source.convert("RGBA")
    if image.size != (2000, 2000):
        raise ValueError("The approved Drawing master must be the supplied 2000x2000 image")

    assets = []
    for size in PNG_SIZES:
        path = directory / f"MS4_AppIcon_{size}x{size}.png"
        expected = image.resize((size, size), Image.Resampling.LANCZOS)
        matches = False
        if path.exists():
            with Image.open(path) as previous:
                matches = previous.size == expected.size and previous.convert("RGBA").tobytes() == expected.tobytes()
        if not matches:
            expected.save(path, "PNG")
        with Image.open(path) as decoded:
            assert decoded.convert("RGBA").tobytes() == expected.tobytes(), str(path)
        assets.append(path)

    ico = directory / "MS4_AppIcon.ico"
    frames = {(size, size): image.resize((size, size), Image.Resampling.LANCZOS) for size in ICO_SIZES}
    matches = False
    if ico.exists():
        with Image.open(ico) as previous:
            matches = (previous.ico.sizes() == set(frames)
                       and all(previous.ico.getimage(size).convert("RGBA").tobytes() == frame.tobytes()
                               for size, frame in frames.items()))
    if not matches:
        frames[(256, 256)].save(ico, "ICO", sizes=list(frames), append_images=list(frames.values()))
    with Image.open(ico) as decoded:
        assert decoded.ico.sizes() == set(frames)
        for size, frame in frames.items():
            assert decoded.ico.getimage(size).convert("RGBA").tobytes() == frame.tobytes(), str(size)
    assets.append(ico)

    icns = directory / "MS4_AppIcon.icns"
    mac_frames = [image.resize((size, size), Image.Resampling.LANCZOS) for size in (32, 64, 128, 256, 512, 1024)]
    mac_frames[-1].save(icns, "ICNS", append_images=mac_frames)
    with Image.open(icns) as decoded:
        for dimensions in decoded.info["sizes"]:
            frame = decoded.icns.getimage(dimensions).convert("RGBA")
            size = dimensions[0] * dimensions[2]
            expected = image.resize((size, size), Image.Resampling.LANCZOS)
            assert frame.tobytes() == expected.tobytes(), "ICNS " + str(dimensions)
    assets.append(icns)

    composer = directory / "AppIcon.icon"
    settings_path = composer / "icon.json"
    settings = json.loads(settings_path.read_text(encoding="utf8"))
    settings["groups"][0]["layers"] = [{"hidden": False, "image-name": "Drawing.png", "name": "MuseScore Drawing"}]
    settings["groups"][0]["translucency"] = {"enabled": False, "value": 0}
    settings["groups"][0]["shadow"] = {"kind": "neutral", "opacity": 0}
    settings_path.write_text(json.dumps(settings, indent=2) + "\n", encoding="utf8")
    artwork = composer / "Assets/Drawing.png"
    shutil.copyfile(directory / "MS4_AppIcon_1024x1024.png", artwork)
    assert sha256(artwork) == sha256(directory / "MS4_AppIcon_1024x1024.png")
    superseded = composer / "Assets/1x1 Colour.svg"
    if superseded.exists():
        superseded.unlink()
    assets.extend((settings_path, artwork))

    favicon = root / "buildscripts/packaging/Windows/PortableApps/Other/Help/images/favicon.ico"
    if favicon.parent.exists():
        shutil.copyfile(ico, favicon)
        assert sha256(favicon) == sha256(ico)
        assets.append(favicon)
    assert sha256(master) == original_hash, "The approved master must remain byte-for-byte unchanged"
    receipt = {"master": master.relative_to(root).as_posix(), "masterSha256": original_hash,
               "masterSize": [2000, 2000], "icoFrames": list(ICO_SIZES),
               "assets": {path.relative_to(root).as_posix(): sha256(path) for path in assets}}
    (directory / "drawing-icon.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf8")
    print(json.dumps({"root": str(root), "masterSha256": original_hash, "assets": len(assets)}))


if __name__ == "__main__":
    main()
