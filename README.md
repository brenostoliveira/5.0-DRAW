<p align="center">
  <img src="share/icons/AppIcon/MS4_Drawing_AppIcon.png" width="160" alt="MuseScore Drawing icon">
</p>

# MuseScore Drawing

**Vector drawing tools integrated into your musical scores.**

MuseScore Drawing is an unofficial, independently maintained edition of MuseScore Studio, developed by [Breno Oliveira](https://github.com/brenostoliveira). It brings freehand drawing, editable curves, graphical notation and musical attachments directly into the score editor. It is built on MuseScore Studio and retains the work and copyright notices of its original contributors.

The current Windows edition is based on **MuseScore Studio 4.7.6**. The project is maintained independently of the official MuseScore team. A separate 5.0 development branch is also present in this repository.

[Download for Windows](https://github.com/brenostoliveira/5.0-DRAW/releases/latest) · [All releases](https://github.com/brenostoliveira/5.0-DRAW/releases) · [Support development on Patreon](https://www.patreon.com/cw/MuseScoreDrawing_IndependentDevelopment)

## Download and installation

Each Windows release includes the base version and an update timestamp in its title and filenames. The timestamp uses `YYYYMMDDHHmm` in São Paulo time. The startup screen displays the same update identifier beside the base version.

- **Installer (`.msi`)** installs MuseScore Drawing into its own `MuseScore Drawing 4.7` folder in Program Files and creates a Drawing Start menu entry. Its Windows Installer identity is dedicated to this edition, allowing the official installation to coexist.
- **Portable runtime (`.zip`)** can be extracted to a folder of your choice. Open `bin/MuseScore4.exe` inside the extracted folder. Extract the complete archive so the executable can find Qt, fonts, translations and other runtime resources. This distribution uses the development-edition user settings location.
- **SHA256SUMS.txt** contains the checksums of the installer and portable archive.

Download the latest available files from [Releases](https://github.com/brenostoliveira/5.0-DRAW/releases/latest). Save a copy of an existing score before trying a new development update.

## Drawing tools

### Pencil and Bézier pen

Draw freehand with adjustable smoothing, width and opacity, or construct Bézier paths and reshape their curves. Round and square nibs support flattening and rotation, with slant available for square nibs. Nib orientation can follow the direction of the stroke. Pressure-sensitive drawing is supported when the input device provides pressure data.

### Shapes, arrows and waves

Create lines, rectangles, rounded rectangles, ellipses, triangles, polygons, stars, diamonds, crosses and arrows. Parametric shapes have editable controls, live previews and confirmation/cancellation sessions.

Waves have amplitude, wavelength and envelope controls. They can stretch with the musical layout or keep their pattern by adding or removing oscillations as available space changes.

Stipple/noise bands provide adjustable density, vertical spread, spacing and dot size. A separate editable guide controls their musical attachments and deformation. The stipple distribution follows that guide and generates additional dots as space grows. This newer tool is undergoing broader score and layout testing.

### Selection and transformations

Select one or several drawings, move, resize, stretch, rotate, skew and mirror them. Use grouping and ungrouping to manage related artwork. The drawing mode handles graphical selection, while the normal score editor continues to handle musical selection when drawing mode is off.

### Nodes, anchors and musical layout

Add, move, remove, join and unlink nodes, and change node curvature. Drawings can be attached to notes, rests and rhythmic subdivisions, or linked to nodes of other drawings.

A single effective attachment moves an SVG with its attachment point while preserving its shape. Multiple attachments allow deformation according to the movement of their nodes. Drawings can follow spacing changes and continue across system breaks, with controls for continuation endpoints.

### Colour, gradients and line styles

Set independent stroke and fill colours, stroke width and opacity. Edit gradients directly on the drawing, including stop colours and stop opacity.

Line-style editing works from a selected node onward, or within a node interval selected with Shift. It supports copying, pasting and removing node properties, with inherited styles continuing until the next explicit style change. Editing stays active while using the style tools, with live preview and confirmation or cancellation.

### Repetition along a path

Select a path and a source SVG to distribute copies at equal spacing. Adjust the copy count, rotation, path opacity and whether the copies follow the path direction. Copies can be moved individually. Changing the count redistributes them evenly.

The confirmed result acts as a linked group. Each copy uses a central attachment to preserve its geometry while the path changes. Removing a copy from the group detaches it, with undo available to restore the previous relationship.

### Objects, layers and panels

The Objects panel shows artwork associated with the focused page, including expandable groups. Rename items independently of their persistent synchronization IDs. Drag items to change stacking order, create groups or move objects into and out of groups.

Context menus expose drawing, node, anchoring and transformation actions. Settings subpanels can be pinned, allowing several controls to stay available together.

### Text, musical characters and SVG files

Add editable text and musical characters through MuseScore's character picker. Import SVG artwork and export drawings as SVG. Stroke/fill tools, transformation and musical attachments can be combined with the drawing workflow.

### Erasing and history

Erase whole drawings, touched path sections or selected regions. Undo and redo cover graphical edits. Delete and Backspace remove selected drawings.

## Saving, parts and export

Drawing geometry and attachment data are embedded in the `.mscz` or `.mscx` score file. Associated drawings are carried into separate instrument parts and participate in score layout and visual export.

The feature set continues to evolve. Save/reopen, complex part layouts and unusual combinations of tools benefit from testing on real scores. A drawing represents visual notation and does not itself create playback instructions.

## Demonstrations

These recordings show the core workflow from an earlier development stage. The interface and tools have evolved since they were recorded.

- [Freehand drawing](https://github.com/user-attachments/assets/9bbe07ea-247e-467a-be37-a81c7367ecbe)
- [Musical layout adaptation](https://github.com/user-attachments/assets/7643a4d9-30dd-4d01-a307-fb64415ffb1c)
- [Node editing](https://github.com/user-attachments/assets/4380dd72-7bfa-4420-ab12-bcc19929c2b7)
- [Normal score editing with drawings](https://github.com/user-attachments/assets/8aa2c476-14d9-4534-ab6d-276b54404169)
- [Shapes and arrows](https://github.com/user-attachments/assets/6700f6ee-1e2d-41a0-9221-9cf517d8f4a7)
- [Text and musical characters](https://github.com/user-attachments/assets/c9cde5e4-a76a-4ad9-9f73-100a38a96b5b)

## Support independent development

Voluntary support helps fund maintenance, bug fixes, new tools and documentation. The drawing tools remain part of this open-source project.

[Support MuseScore Drawing on Patreon](https://www.patreon.com/cw/MuseScoreDrawing_IndependentDevelopment)

## Report a problem

Use this repository's [issue tracker](https://github.com/brenostoliveira/5.0-DRAW/issues). Include the base version and update number shown on startup, your operating system, the steps to reproduce the problem, and a sample score when possible.

Windows compilation and package checks are recorded per release. Manual validation is reported separately. Linux and macOS builds are currently unvalidated for this edition.

## Source and building

The `drawing-4.7.6` branch contains the current 4.x edition. Download the matching source archive from the release tag or clone the repository and select that branch.

```sh
git clone --branch drawing-4.7.6 --recurse-submodules https://github.com/brenostoliveira/5.0-DRAW.git
cd 5.0-DRAW
cmake -P build.cmake install -DCMAKE_BUILD_TYPE=RelWithDebInfo
```

Configure the compiler, Qt and dependencies for your platform using the [MuseScore developer build documentation](https://github.com/musescore/MuseScore/wiki/Set-up-developer-environment). Local build paths depend on your Qt and compiler installation. The independent Windows MSI is assembled from the installed runtime with `buildscripts/packaging/Windows/drawing/package_distribution.py` and WiX 3.14.1.

## License and acknowledgements

MuseScore Drawing builds on MuseScore Studio and its contributors. The source is distributed under the GNU GPL version 3, with existing third-party licenses and notices retained. See [LICENSE.txt](LICENSE.txt) and the notices accompanying the sources and runtime dependencies.
