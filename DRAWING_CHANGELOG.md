# Drawing editor change record

This document records the drawing feature increments and their reasons. Revision identifiers identify implementation increments. Source locations refer to the current source snapshot and are updated with each branch update.

## 5.0-DRAW-R1 — Initial drawing mode and score integration

### Added functionality

Adds a drawing-mode entry in the notation interface and the View menu. The palette provides selection, freehand pencil, line, rectangle and ellipse tools, with color and stroke-width controls. A temporary path follows the pointer while drawing. Releasing the pointer inserts the completed SVG image through an undoable score edit.

### Files added

| File | Added lines | Reason |
| --- | --- | --- |
| `src/notationscene/qml/MuseScore/NotationScene/DrawingToolIcon.qml` | 1–55 | Defines vector icons for the drawing palette, including the geometric additions in R2. |

### Files modified

| File | Locations | Reason |
| --- | --- | --- |
| `src/appshell/qml/MuseScore/AppShell/appmenumodel.cpp` | 294–295 | Makes the drawing-mode toggle available in the View menu. |
| `src/notation/inotationinteraction.h` | 27–28, 257 | Exposes SVG drawing insertion through the notation interaction interface. |
| `src/notation/internal/notationinteraction.h` | 274 | Declares the concrete drawing insertion operation. |
| `src/notation/internal/notationinteraction.cpp` | 81, 6301–6327 | Creates the embedded SVG image, anchors it to a measure base, and inserts it through the undoable edit flow. |
| `src/notationscene/inotationsceneconfiguration.h` | 45–47 | Exposes the drawing-mode session state and notification. |
| `src/notationscene/internal/notationsceneconfiguration.h` | 41–43, 78–79 | Stores the drawing-mode state in memory. |
| `src/notationscene/internal/notationsceneconfiguration.cpp` | 114–132 | Reads, updates and notifies changes to drawing-mode state. |
| `src/notationscene/notationcommands.h` | 491 | Defines the drawing-mode toggle identifier. |
| `src/notationscene/internal/notationcommandsregister.cpp` | 2955–2961 | Registers the translated, checkable drawing-mode action. |
| `src/notationscene/internal/notationactioncontroller.h` | 263 | Declares the mode-toggle handler. |
| `src/notationscene/internal/notationactioncontroller.cpp` | 571, 2798–2802 | Routes the toggle to the shared session state. |
| `src/notationscene/internal/notationcommandsstate.h` | 33, 44 | Provides access to scene configuration for the action's checked state. |
| `src/notationscene/internal/notationcommandsstate.cpp` | 370–373, 518–521 | Synchronizes the checked state shown by interface entry points. |
| `src/notationscene/qml/MuseScore/NotationScene/CMakeLists.txt` | 170 | Registers the drawing icon component in the QML module. |
| `src/notationscene/qml/MuseScore/NotationScene/NotationView.qml` | 153–280 | Adds the palette, tool selection, color and stroke-width controls. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.h` | 26–28, 74–77, 171–179, 204–206, 301–306, 360–367 | Declares drawing properties, signals, pointer handlers and temporary path state. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.cpp` | 28–35, 154–174, 800–807, 1565–1887, 2118–2120, 2141–2147 | Implements mode synchronization, previews, pointer gestures, SVG serialization and score insertion. |

## 5.0-DRAW-R2 — Additional geometric tools

### Added functionality

Adds triangle, right triangle, diamond, rounded rectangle, star, cross, arrow, double arrow and filled arrow tools. Their geometry follows the pointer during drawing. The filled arrow uses the selected color in both the preview and the resulting SVG. Triangle geometry uses the full base of the dragged bounds.

### Files added

No additional source files.

### Files modified

| File | Locations | Reason |
| --- | --- | --- |
| `src/notationscene/qml/MuseScore/NotationScene/DrawingToolIcon.qml` | 31–39 | Adds the geometric tool icons. |
| `src/notationscene/qml/MuseScore/NotationScene/NotationView.qml` | 199–207 | Exposes the additional tools with extractable English labels. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.h` | 304 | Declares the shared path-update helper. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.cpp` | 803, 1593–1611, 1755–1870 | Constructs the supported shapes and preserves filled-arrow appearance during preview and SVG serialization. |

## 5.0-DRAW-R3 — Windows deployment from paths containing spaces

### Modified functionality

Keeps the source directory together when the generated Qt deployment script supplies the QML scan directory to the Windows dependency deployment tool. Previously, a checkout path containing spaces was split and portable deployment failed after compilation.

### Files added

No additional source files.

### Files modified

| File | Location | Reason |
| --- | --- | --- |
| `src/app/CMakeLists.txt` | 363 | Quotes the source directory in the generated deployment arguments. |

## 5.0-DRAW-R4 — Native Draw button and session behavior

### Modified functionality

Uses the standard notation-toolbar action component to display the pencil icon followed by **Draw**, with the same typography, emphasis, sizing and compact-mode behavior as the other toolbar entries. The same checkable action is available in the View menu.

Selection is the initial tool. The latest tool is retained in memory for the application session and restored when the main score view is recreated or drawing mode is re-enabled.

Activating drawing mode ends musical note entry and element editing and clears the previous selection. Drawing pointer gestures are consumed by the drawing tools; selection gestures on drawing images use the notation interaction interface directly, as refined in R5. Musical double-click, hover and context-menu behavior is suppressed while drawing mode is active. Turning drawing mode off restores the ordinary pointer and context-menu routes. Mode switching leaves inserted drawings in the score.

### Files added

| File | Added lines | Reason |
| --- | --- | --- |
| `DRAWING_CHANGELOG.md` | 1–125 | Records feature revisions, changed-file locations, reasons and validation status. |

### Files modified

| File | Locations | Reason |
| --- | --- | --- |
| `src/notationscene/qml/MuseScore/NotationScene/notationtoolbarmodel.cpp` | 45–46 | Adds Draw to the standard toolbar action list at the existing drawing-button position. |
| `src/notationscene/internal/notationcommandsregister.cpp` | 2957 | Uses the English Draw label for the shared toolbar and menu action. |
| `src/notationscene/inotationsceneconfiguration.h` | 25–26, 49–51 | Declares the session tool and its notification. |
| `src/notationscene/internal/notationsceneconfiguration.h` | 45–47, 80–81 | Stores the last tool, initially selection, without persistent settings. |
| `src/notationscene/internal/notationsceneconfiguration.cpp` | 134–152 | Implements session tool access and change notification. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.h` | 362 | Tracks whether a drawing-image selection gesture owns the pointer sequence. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.cpp` | 166–174, 1351–1401, 1455–1459, 1565–1753, 2141–2147 | Restores the session tool, separates drawing and musical pointer routes, and preserves normal context-menu handling when drawing mode is off. |

## 5.0-DRAW-R5 — Isolate drawing-image selection and movement

### Modified functionality

Selects the image identified by the drawing tool directly through the notation interaction interface. Movement begins after the pointer crosses the drag threshold and is restricted to image elements. This prevents the musical input controller from performing another hit test and selecting a different score element. Releasing the pointer or leaving drawing mode completes the active undoable drag.

### Files added

No additional source files.

### Files modified

| File | Locations | Reason |
| --- | --- | --- |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.cpp` | 1355–1357, 1367–1369, 1393–1395, 1571–1573, 1650–1659, 1682–1698, 1723–1731 | Keeps drawing selection and image movement inside the drawing gesture handlers, completes active drag transactions, and preserves ordinary musical input routing when drawing mode is off. |
| `DRAWING_CHANGELOG.md` | 37, 55, 81, 87, 100, 102–125 | Updates source locations, records R5 and keeps the documented validation boundary current. |

## Validation status

- The Windows development build completed with Qt 6.11.2, MSVC 2022 and the RelWithDebInfo configuration before R4.
- Portable compilation and Qt dependency deployment completed successfully through R3. The package includes the PortableApps launcher, Qt runtime libraries and Windows platform plugin. Portable-mode headers were checked.
- R4 and R5 received source review, C++ formatting and whitespace inspection. They have not been compiled or checked in the running application.
- Automated tests were not executed. Musical editing, drawing interaction, persistence and portable runtime behavior still require application verification.
- Source labels are in English and use translation extraction. Translation catalogs are unchanged.
