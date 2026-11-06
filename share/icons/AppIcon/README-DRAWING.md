# MuseScore Drawing application icon

The default application icon for this independent edition is the exact
2000x2000 image approved and supplied by Breno Oliveira, stored as
`MS4_Drawing_AppIcon.png`. Keep this master unchanged. It replaces the official
application icon in new Drawing builds, including Windows executable/installer
icons, the Qt application icon, Linux application sizes, PortableApps branding,
and macOS application icon assets. Score document icons remain separate.

To regenerate the derived files with Pillow:

```sh
python buildscripts/packaging/icons/update_drawing_icons.py
```

The script checks decoded PNG/ICO/ICNS frames against the approved artwork and
records checksums in `drawing-icon.json`. Normal compilation uses the generated
assets already in the repository; no new build-time Python dependency is needed.
The application and packaging resource paths retain their existing names.

Asset checks do not establish platform build or visual acceptance. The macOS
Icon Composer bundle still requires validation using Xcode on macOS. Do not
redesign this icon or restore the upstream application icon during a base update.
