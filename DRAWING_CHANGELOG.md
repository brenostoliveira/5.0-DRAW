# Drawing editor change record

This document records the drawing feature increments and their reasons. Revision identifiers identify implementation increments. Source locations refer to the current source snapshot and are updated with each branch update.

## 5.0-DRAW-R1 — Initial drawing mode and score integration

### Added functionality

Adds a drawing-mode entry in the notation interface and the View menu. The palette provides selection, freehand pencil, line, rectangle and ellipse tools, with color and stroke-width controls. A temporary path follows the pointer while drawing. Releasing the pointer inserts the completed SVG image through an undoable score edit.

### Files added

| File | Added lines | Reason |
| --- | --- | --- |
| `src/notationscene/qml/MuseScore/NotationScene/DrawingToolIcon.qml` | 1–68 | Defines vector icons for the drawing palette, including the geometric additions in R2. |

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
| `src/notationscene/qml/MuseScore/NotationScene/NotationView.qml` | previous 153–280; removed in R7 | Originally added the overlay palette. R7 relocates its controls into the docked panel. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.h` | 26–28, 75–78, 173–181, 206–208, 303–308, 362–369 | Declares drawing properties, signals, pointer handlers and temporary path state. |
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
| `src/notationscene/qml/MuseScore/NotationScene/DrawingToolsPanel.qml` | 87–99 | Exposes the additional tools with extractable English labels; relocated from the overlay in R7. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.h` | 306 | Declares the shared path-update helper. |
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
| `DRAWING_CHANGELOG.md` | 1–312 | Records feature revisions, changed-file locations, reasons and validation status. |

### Files modified

| File | Locations | Reason |
| --- | --- | --- |
| `src/notationscene/qml/MuseScore/NotationScene/notationtoolbarmodel.cpp` | 45–46 | Adds Draw to the standard toolbar action list at the existing drawing-button position. |
| `src/notationscene/internal/notationcommandsregister.cpp` | 2957 | Uses the English Draw label for the shared toolbar and menu action. |
| `src/notationscene/inotationsceneconfiguration.h` | 25–26, 49–51 | Declares the session tool and its notification. |
| `src/notationscene/internal/notationsceneconfiguration.h` | 45–47, 80–81 | Stores the last tool, initially selection, without persistent settings. |
| `src/notationscene/internal/notationsceneconfiguration.cpp` | 134–152 | Implements session tool access and change notification. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.h` | 364 | Tracks whether a drawing-image selection gesture owns the pointer sequence. |
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

## 5.0-DRAW-R6 — Synchronize with official main

### Modified functionality

Integrates the 38 upstream commits through `f019f4079d0ba74c481fa93396b3486a77f22635` without discarding the two drawing commits. The only textual merge conflict was in drawing-view initialization: the drawing session subscriptions are retained alongside the official playback-state API. Playback state now comes from the injected playback interface, matching the updated upstream ownership. No additional drawing tools are introduced.

### Drawing integration files modified

| File | Locations | Reason |
| --- | --- | --- |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.cpp` | 154–182, 1947, 1958, 2160 | Retains drawing initialization and adopts the official playback-state access and playing-state notification. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.h` | 31–41, 87 | Retains upstream include organization and playback-state dependency injection alongside drawing declarations. |
| `DRAWING_CHANGELOG.md` | entire document; R6 and refreshed source locations | Documents upstream integration, the conflict resolution and the current validation boundary. |

### Files integrated from upstream

The following changes belong to official main. Locations are from the upstream integration diff; removed ranges refer to the previous upstream source. They are retained to preserve official behavior and dependencies. Drawing-specific changes are documented separately above.

| File | Change | Locations | Reason |
| --- | --- | --- | --- |
| `muse` | Modified | submodule reference | Integrates upstream: Update framework. |
| `muse_deps` | Modified | submodule reference | Integrates upstream: Update framework. |
| `src/appshell/CMakeLists.txt` | Modified | 48–51 | Integrates upstream: remove context module. step 1. |
| `src/appshell/appshellmodule.cpp` | Modified | 41–42, 54–55, 118, 124–125, 151–152, 154–156 | Integrates upstream: remove context module. step 1. |
| `src/appshell/appshellmodule.h` | Modified | 52, 69 | Integrates upstream: remove context module. step 1. |
| `src/appshell/internal/appshellcommandscontroller.cpp` | Modified | 42, 48, 401–405, removed: previous 409–410, removed: previous 412–413 | Integrates upstream: remove context module. step 1. |
| `src/appshell/internal/appshellcommandscontroller.h` | Modified | 48, 76 | Integrates upstream: remove context module. step 1. |
| `src/appshell/internal/extensioncontextresolver.cpp` | Added | 1–48 | Integrates upstream: remove context module. step 1. |
| `src/appshell/internal/extensioncontextresolver.h` | Added | 1–49 | Integrates upstream: remove context module. step 1. |
| `src/appshell/internal/shortcutresolver.cpp` | Added | 1–133 | Integrates upstream: remove context module. step 1. |
| `src/appshell/internal/shortcutresolver.h` | Added | 1–55 | Integrates upstream: remove context module. step 1. |
| `src/appshell/qml/MuseScore/AppShell/NotationReviewPage/ReviewNotationView.qml` | Modified | 41 | Integrates upstream: Add missing isMainView flag. |
| `src/context/CMakeLists.txt` | Modified | removed: previous 27, removed: previous 30–35 | Integrates upstream: remove context module. step 1. |
| `src/context/contextmodule.cpp` | Modified | removed: previous 26–27, removed: previous 31, removed: previous 48, removed: previous 51–52, removed: previous 60–61 | Integrates upstream: remove context module. step 1. |
| `src/context/iglobalcontext.h` | Modified | removed: previous 26, removed: previous 31–32, removed: previous 51–53 | Integrates upstream: remove context module. step 1. |
| `src/context/internal/extensioncontextresolver.cpp` | Removed | removed: previous 1–48 | Integrates upstream: remove context module. step 1. |
| `src/context/internal/extensioncontextresolver.h` | Removed | removed: previous 1–49 | Integrates upstream: remove context module. step 1. |
| `src/context/internal/globalcontext.cpp` | Modified | removed: previous 38, removed: previous 132–141 | Integrates upstream: remove context module. step 1. |
| `src/context/internal/globalcontext.h` | Modified | removed: previous 32–33, removed: previous 53–55, removed: previous 64–65 | Integrates upstream: remove context module. step 1. |
| `src/context/internal/playbackstate.cpp` | Removed | removed: previous 1–77 | Integrates upstream: remove context module. step 1. |
| `src/context/internal/playbackstate.h` | Removed | removed: previous 1–50 | Integrates upstream: remove context module. step 1. |
| `src/context/internal/shortcutresolver.cpp` | Removed | removed: previous 1–133 | Integrates upstream: remove context module. step 1. |
| `src/context/internal/shortcutresolver.h` | Removed | removed: previous 1–55 | Integrates upstream: remove context module. step 1. |
| `src/context/iplaybackstate.h` | Removed | removed: previous 1–48 | Integrates upstream: remove context module. step 1. |
| `src/context/tests/mocks/globalcontextmock.h` | Modified | removed: previous 43–45 | Integrates upstream: remove context module. step 1. |
| `src/context/tests/mocks/playbackstatemock.h` | Removed | removed: previous 1–40 | Integrates upstream: remove context module. step 1. |
| `src/engraving/editing/edit.cpp` | Modified | 2661 | Integrates upstream: Merge pull request #34860 from 0xMashiro/fix/linked-range-empty-segments. |
| `src/engraving/tests/parts_data/delete-linked-rests.mscx` | Added | 1–45 | Integrates upstream: Fix empty segments left in linked scores after range deletion. |
| `src/engraving/tests/parts_tests.cpp` | Modified | 41, 1471–1516 | Integrates upstream: Merge current main into linked-segment deletion fix. |
| `src/notationscene/internal/notationactioncontroller.cpp` | Modified | 705, 810, 849, 1639, 2633 | Integrates upstream: remove context module. step 1. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.cpp` | Modified | 151, 156, 1567, 1578, 1773 | Integrates upstream: remove context module. step 1. |
| `src/notationscene/qml/MuseScore/NotationScene/abstractnotationpaintview.h` | Modified | 28–30, 32, removed: previous 32–33, 38, 80 | Integrates upstream: remove context module. step 1. |
| `src/playback/internal/playbackcontroller.cpp` | Modified | 234–246, 865–867, removed: previous 856, 1116, 1118–1128, removed: previous 1122–1123, removed: previous 1132–1134, 1238–1246, 1248, 1251, 1255–1261, 1264–1265, 1327–1334, 1336, 1339, 1343–1348, removed: previous 1506, 1750–1751 | Integrates upstream: remove context module. step 1. |
| `src/playback/internal/playbackcontroller.h` | Modified | 67–75, removed: previous 73–75, 255 | Integrates upstream: remove context module. step 1. |
| `src/playback/iplaybackcontroller.h` | Modified | 46–63, removed: previous 59–61 | Integrates upstream: remove context module. step 1. |
| `src/playback/playbackmodule.cpp` | Modified | 91 | Integrates upstream: remove context module. step 1. |
| `src/playback/qml/MuseScore/Playback/notationregionsbeingprocessedmodel.cpp` | Modified | 157, 201 | Integrates upstream: remove context module. step 1. |
| `src/playback/qml/MuseScore/Playback/playbacktoolbarmodel.cpp` | Modified | 81, 85, 91, 226, 236 | Integrates upstream: remove context module. step 1. |
| `src/playback/qml/MuseScore/Playback/playbacktoolbarmodel.h` | Modified | removed: previous 31, removed: previous 57 | Integrates upstream: remove context module. step 1. |
| `src/playback/tests/CMakeLists.txt` | Modified | 26 | Integrates upstream: remove context module. step 1. |
| `src/playback/tests/mocks/playbackcontrollermock.h` | Modified | 34–39, removed: previous 40–42 | Integrates upstream: remove context module. step 1. |
| `src/playback/tests/mocks/playbackstatemock.h` | Added | 1–39 | Integrates upstream: remove context module. step 1. |
| `src/project/CMakeLists.txt` | Modified | 44, 79–80 | Integrates upstream: Add ability to delete any online score. |
| `src/project/iconvertfiletoscorescenario.h` | Modified | removed: previous 36–40, 64–66, 73–75, 79–80 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/iconvertfiletoscoreservice.h` | Modified | 29, 56–59, 61, 64–66, 73–74, 82–86 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/ideletecloudscorescenario.h` | Added | 1–44 | Integrates upstream: Add ability to delete any online score. |
| `src/project/internal/closeprojectscenario.cpp` | Modified | 28–29, removed: previous 30, 33–34, 52–53 | Integrates upstream: remove context module. step 1. |
| `src/project/internal/closeprojectscenario.h` | Modified | 35, 48 | Integrates upstream: remove context module. step 1. |
| `src/project/internal/convertfiletoscorescenario.cpp` | Modified | 28, 38, 53, 59–61, 65–69, 72, 156–160, 172–178, 180–186, 201, 203, 208, 210, 269–270, 285, 290–316, 351, 353–356, 363–383, 436–448, 477, 542–550, 552, 570, 572, 577, 591–607 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/internal/convertfiletoscorescenario.h` | Modified | 29, 37–40, 48, 67, 72, 75, 80–84, 89, 92, 94, 97, 101, 113–114 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/internal/convertfiletoscoreservice.cpp` | Modified | 26, 86, 134, 236–237, removed: previous 262–265, 262–266, 269, 274, 282, 288, 292, 300, 309, 311–324, 327–335, 339, 345, 348, 356–364, 383, 385–391, 397, 462–474, 535–540, 544, 587–599, removed: previous 557–558, 622, 625–626, 632, 635, 660, 670, 675–686, 688–690, 694, 697, removed: previous 633–634, 705, 721–730, 738–739, 743–747, removed: previous 686–687, 753–766, 769–771, 782, 800–807, 809–810, 812–813, 845, removed: previous 763, 855, removed: previous 774–778 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/internal/convertfiletoscoreservice.h` | Modified | 24, 26, 65, 68, 72, 78–86, 90, 95, 97, 100, removed: previous 95–96, 108, 111, 113–114, 116, 119, 121 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/internal/deletecloudscorescenario.cpp` | Added | 1–88 | Integrates upstream: Add ability to delete any online score. |
| `src/project/internal/deletecloudscorescenario.h` | Added | 1–56 | Integrates upstream: Add ability to delete any online score. |
| `src/project/projecterrors.h` | Modified | 56, removed: previous 58–60 | Integrates upstream: Show a toast when uploading a file for conversion fails. |
| `src/project/projectmodule.cpp` | Modified | 42, 99, 166 | Integrates upstream: Add ability to delete any online score. |
| `src/project/qml/MuseScore/Project/CMakeLists.txt` | Modified | 70, 184–187 | Integrates upstream: FileListModel: add tests. |
| `src/project/qml/MuseScore/Project/ConvertFileToScoreDialog.qml` | Modified | 53–71, 132, 187, 207, removed: previous 193, 214–215, 218, 220–221 | Integrates upstream: Make FileListModel the single source of truth for selected file paths. |
| `src/project/qml/MuseScore/Project/DeleteCloudScoreDialog.qml` | Added | 1–141 | Integrates upstream: Add ability to delete any online score. |
| `src/project/qml/MuseScore/Project/ScoresPage.qml` | Modified | 288–291, 327–330 | Integrates upstream: Add ability to delete any online score. |
| `src/project/qml/MuseScore/Project/internal/ConvertFileToScore/MultipleFilesPanel.qml` | Modified | 36, 267–268, 330, 336 | Integrates upstream: Make FileListModel the single source of truth for selected file paths. |
| `src/project/qml/MuseScore/Project/internal/ConvertFileToScore/SelectedFilesPage.qml` | Modified | 36, removed: previous 38, 45–47, removed: previous 54–60, 94, 100, 110, 113, 116, 127, 132 | Integrates upstream: Make FileListModel the single source of truth for selected file paths. |
| `src/project/qml/MuseScore/Project/internal/ConvertFileToScore/convertfiletoscoremodel.cpp` | Modified | 28–29, 80, 84–96, 120, 122–125, 154, 156, 175, 181–182, 186, 196, 221–223, 272, 274–275, removed: previous 308–312, 280–284, removed: previous 321, 291–294, 371, 381, removed: previous 426–447, 395, 419, 421, 426, 429, 431–432, 435–442, removed: previous 494, 451, 460, 523 | Integrates upstream: Accept links without a scheme. |
| `src/project/qml/MuseScore/Project/internal/ConvertFileToScore/convertfiletoscoremodel.h` | Modified | 40–41, 51, 53, removed: previous 54, 66, 80, removed: previous 88, 98–99, 110, removed: previous 120, 124 | Integrates upstream: FileListModel: add tests. |
| `src/project/qml/MuseScore/Project/internal/ConvertFileToScore/filelistmodel.cpp` | Modified | removed: previous 25–26, 41, 61, 63, 94–101, 111, 115, 120–134, 161–164, 200–203, 206, 225–230, 235, 239–268, 273, 277–278, 291 | Integrates upstream: FileListModel: add tests. |
| `src/project/qml/MuseScore/Project/internal/ConvertFileToScore/filelistmodel.h` | Modified | 28–30, 32, removed: previous 35, 40, 43, 50–61, 68–72, 74–75, removed: previous 60, removed: previous 62–64, 100, 103, 109–111 | Integrates upstream: FileListModel: add tests. |
| `src/project/qml/MuseScore/Project/internal/ConvertFileToScore/reviewscorequalitymodel.h` | Modified | 43, removed: previous 47 | Integrates upstream: ReviewScoreQualityModel: add tests. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/CloudScoresView.qml` | Modified | 94–97, 100–104, 141–144, 147–151 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/RecentScoresView.qml` | Modified | 78–81, 126–129 | Integrates upstream: Add ability to delete any online score. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/ScoreGridItem.qml` | Modified | 44, 55, 57–58, 222–230, 245, 368–374 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/ScoreItemMenuButton.qml` | Modified | 44, 89, 91–93, 97–100, 131–133 | Integrates upstream: Add ability to delete any online score. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/ScoreListItem.qml` | Modified | 46, 48–49, 53–60, 140, 192, 296–302, 312 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/ScoresGridView.qml` | Modified | 50, 52–53, 172, 198–201, 204–209 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/ScoresListView.qml` | Modified | 51, 53–54, 250–253, 256–261 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/ScoresView.qml` | Modified | 45 | Integrates upstream: Add ability to delete any online score. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/abstractscoresmodel.cpp` | Modified | 39 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/abstractscoresmodel.h` | Modified | 72 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/cloudscoresmodel.cpp` | Modified | 64–67, 72–77, 79–85, 91–95, 118–122, 128–151, 189–190, 213, 217–224, removed: previous 208–209, 273–280, 315, 318–330 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/cloudscoresmodel.h` | Modified | 35–37, 52, 56, 73, 92–97, 102, 108 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/scorespagemodel.cpp` | Modified | 90–94 | Integrates upstream: Add ability to delete any online score. |
| `src/project/qml/MuseScore/Project/internal/ScoresPage/scorespagemodel.h` | Modified | 34, 52, 75 | Integrates upstream: Add ability to delete any online score. |
| `src/project/qml/MuseScore/Project/resources/ScoreProcessing.png` | Modified | binary asset; no source lines | Integrates upstream: Update the score processing dialog image. |
| `src/project/qml/MuseScore/Project/tests/CMakeLists.txt` | Added | 1–41 | Integrates upstream: ReviewScoreQualityModel: add tests. |
| `src/project/qml/MuseScore/Project/tests/cloudscoresmodel_tests.cpp` | Added | 1–1060 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/qml/MuseScore/Project/tests/convertfiletoscoremodel_tests.cpp` | Added | 1–911 | Integrates upstream: Simplify tests. |
| `src/project/qml/MuseScore/Project/tests/filelistmodel_tests.cpp` | Added | 1–606 | Integrates upstream: FileListModel: add tests. |
| `src/project/qml/MuseScore/Project/tests/reviewscorequalitymodel_tests.cpp` | Added | 1–305 | Integrates upstream: Simplify tests. |
| `src/project/tests/CMakeLists.txt` | Modified | 38, 42 | Integrates upstream: Simplify tests. |
| `src/project/tests/closeprojectscenariotests.cpp` | Modified | 28, 57, 63, removed: previous 64, removed: previous 68, 135 | Integrates upstream: remove context module. step 1. |
| `src/project/tests/convertfiletoscorescenario_tests.cpp` | Modified | removed: previous 24–25, removed: previous 28, 29, 35, 44, removed: previous 61–79, 70–75, 88–97, 103–113, 116, removed: previous 127, 121, 124, 150, 158, 165–168, removed: previous 188–198, 180, removed: previous 221, 208–213, 222, 225–226, 236, removed: previous 271, 267, 279, 306, 310–340, 343, 347–349, removed: previous 349, 371, 380, removed: previous 383–387, 391–392, 396, 399, 403–405, 412, 423, 426, 432, 435, 437, 446–451, 454, 456, removed: previous 478, 472, 475, 477, 490, 495, 497, 510, 559, 668, removed: previous 714, 703, removed: previous 735, 713, 715, removed: previous 741, removed: previous 768, removed: previous 795, 784, 789, removed: previous 827, 813, removed: previous 848, 830, removed: previous 874, removed: previous 881, 861, 866, removed: previous 908, 882, 890, 897–900, 903, 911, 916–919, 927, removed: previous 955, 939, 944–945, removed: previous 989, 972, 977–978, 1003, 1008–1009, 1037, 1042–1043, 1060–1150, 1153–1154, removed: previous 1107, 1180–1271, 1308, 1311, 1319, 1357, 1360, 1368, 1391, 1402–1403, 1430–1476, 1481, 1498–1499, 1508, 1516–1517 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/tests/convertfiletoscoreservice_tests.cpp` | Modified | 26, 37, 44, removed: previous 58–76, 68, 76, 78–83, 86, 88, 108–121, 127, 165–166, 170, 179, 187, 189–190, 194–196, 199, 204, 206–207, 211, 467–483, 526–529, 532, 538–541, 544, 586–601, 603, 606–622, 626, 629–632, 635–652, removed: previous 596, 655–662, 665, 674, removed: previous 619, 699–701, 703–715, 717–725, 729, 736, 757–758, 765, 768, 770–788, 792, 794, removed: previous 698–702, 804–815, 817, 820–821, 823–827, 830–871, 875, 892, 896–897, 994–1025, 1033, 1059, 1076, 1126, 1129–1131, 1137, 1140, 1143–1144, 1148, removed: previous 997, 1161–1326, 1333–1334, 1352, 1356, 1391, 1395, 1404–1406, 1415, 1417–1419, 1421–1422, 1428, 1434–1435, 1438, 1448, 1455, 1483–1489, 1493, 1506–1507, 1526, 1532, 1538, 1540–1544, 1547, 1555–1561, 1565–1567, 1569, 1571, 1575, 1591–1595, 1597, 1601, 1603, 1606–1607, 1613–1617, 1620, 1627–1632, 1635–1641, removed: previous 1331, 1668–1700, 1702–1704, 1726–1731, 1734, 1736–1738, 1741, 1752, 1781, 1811, 1834, 1837, 1840, 1845–1849, 1856–1857, 1862–1865, 1868, 1871, 1882–1883 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/tests/deletecloudscorescenario_tests.cpp` | Added | 1–273 | Integrates upstream: Simplify tests. |
| `src/project/tests/mocks/convertfiletoscorescenariomock.h` | Modified | 26–27, 43, removed: previous 42, 47, 50 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/tests/mocks/convertfiletoscoreservicemock.h` | Modified | 38, 41, 45, 51–52 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/project/tests/mocks/deletecloudscorescenariomock.h` | Added | 1–37 | Integrates upstream: CloudScoresModel: add tests. |
| `src/project/tests/utils/testutils.h` | Added | 1–71 | Integrates upstream: Simplify tests. |
| `src/project/types/converttypes.h` | Modified | 92–93, 96, 101–113 | Integrates upstream: Show uploading scores as Processing and allow canceling them. |
| `src/stubs/playback/playbackcontrollerstub.cpp` | Modified | 56–65 | Integrates upstream: remove context module. step 1. |
| `src/stubs/playback/playbackcontrollerstub.h` | Modified | 40–42 | Integrates upstream: remove context module. step 1. |

## 5.0-DRAW-R7 — Docked main drawing tools panel

### Added functionality

Replaces the score-overlay palette with a narrow native dock panel. The panel can be moved to either side of the score or floated through the existing docking system. Group headings, vector icons, separators, native themed buttons and the highlighted current tool organize the drawing interface. Vertical scrolling keeps the controls reachable in short windows.

Groups follow the requested order: colors; selection; pencil; Bézier; shapes; painting/gradients; repeat along path; nodes/anchors; eraser; text; grouping/fusion; objects/layers; characters; import/export; undo/redo; delete; anchor grid.

The Keep visible option retains the panel when drawing mode is disabled while the notation page remains active. Drawing controls remain disabled outside drawing mode, preserving musical interaction. Unpinning outside drawing mode hides the panel. The option is held by the notation page rather than the panel content, so opening and closing the dock does not reset it.

The existing selection, pencil, geometric tools, drawing colors and stroke width are connected to the score view. Color and width changes retain their immediate preview behavior. The undo/redo group reuses the official score-history toolbar. Keyboard navigation uses the application's navigation controls, and tool tips use the native tooltip service without adding an input overlay or letter shortcuts.

Bézier, painting/gradients, path repetition, nodes/anchors, eraser, text, grouping/fusion, objects/layers, characters, drawing import/export, drawing deletion and anchor-grid groups have disabled entries in this revision. Their editing operations are not implemented by this panel-structure increment. Disabled controls do not invoke musical actions or claim a tool is active.

### Files added

| File | Added lines | Reason |
| --- | --- | --- |
| `src/notationscene/qml/MuseScore/NotationScene/DrawingToolsPanel.qml` | 1–216 | Defines the scrolling 17-group panel, themed controls, tool state, navigation, color preview, stroke-width control and visibility option. |

### Files modified

| File | Locations | Reason |
| --- | --- | --- |
| `src/appshell/qml/MuseScore/AppShell/NotationPage/NotationPage.qml` | 91, 116–131, 273–299 | Registers the narrow native dock, its side-drop destinations and visibility policy, and supplies the active score view. |
| `src/notationscene/qml/MuseScore/NotationScene/NotationView.qml` | removed previous 153–280; current 165 | Removes the fixed overlay so drawing controls belong to the docked panel and no longer cover the score. |
| `src/notationscene/qml/MuseScore/NotationScene/DrawingToolIcon.qml` | 40–51 | Adds theme-colored vector icons for the additional panel groups. |
| `src/notationscene/qml/MuseScore/NotationScene/CMakeLists.txt` | 171 | Registers the new panel with the notation-scene QML module. |
| `DRAWING_CHANGELOG.md` | R1/R2 source references, R7 and validation status | Records this panel increment, file locations, reasons and the limits of the available group operations. |

## 5.0-DRAW-R8 — Contextual tool subpanels and independent pinning

### Added functionality

Opens a contextual subpanel when an available drawing tool or the colors control is chosen from the main panel. Each subpanel has an English title, a pin button in the upper-right header, a close button and scrolling content. The pin starts off. Pinned subpanels remain open when another tool panel is opened; an existing panel is reused instead of duplicated. Closing a subpanel does not change the active tool or main-panel visibility option.

New panels are placed within the score-view area, which stays inside the application window and excludes docked side panels. Placement considers space on both sides and above/below existing panels, minimizes overlap among the candidate positions, and recomputes positions when the available area changes. When there is insufficient space for a non-overlapping arrangement, overlap is reduced rather than allowing panels outside the available bounds. The content scrolls when the panel height is constrained.

Subpanel pin state is independent of the main Keep visible setting. Leaving drawing mode hides contextual panels without destroying their state; returning reveals them. Clicking outside does not dismiss them. A confirmation-pending state prevents automatic replacement on a tool change; this increment does not introduce a new Confirm/Cancel editing session.

Pencil and geometric-tool subpanels expose existing shared color and stroke-width settings and a tool activation control. These settings apply to the current drawing style, rather than introducing separate saved styles for each tool. Selection uses its existing tool action and selection hint. Unimplemented tool groups remain unavailable. No new editing operations or global letter shortcuts are added.

### Files added

| File | Added lines | Reason |
| --- | --- | --- |
| `src/notationscene/qml/MuseScore/NotationScene/DrawingToolSubpanel.qml` | 1–152 | Provides the contextual frame, title, independent pin, close action, scrollable content, tool activation and live controls. |
| `src/notationscene/qml/MuseScore/NotationScene/DrawingSubpanels.qml` | 1–133 | Owns open subpanels, preserves pinned and confirmation-pending panels, and chooses bounded positions with minimal overlap among candidates. |
| `src/notationscene/qml/MuseScore/NotationScene/DrawingStyleControls.qml` | 1–76 | Shares the existing drawing color and stroke-width controls with immediate preview updates. |

### Files modified

| File | Locations | Reason |
| --- | --- | --- |
| `src/notationscene/qml/MuseScore/NotationScene/DrawingToolsPanel.qml` | 32, 139–158, 181–184 | Emits contextual-panel requests from available tools and relocates color/width controls into the colors subpanel. |
| `src/notationscene/qml/MuseScore/NotationScene/NotationView.qml` | 55–65 | Hosts contextual panels separately from the main dock and exposes the panel-opening entry point. |
| `src/appshell/qml/MuseScore/AppShell/NotationPage/NotationPage.qml` | 298 | Connects main-panel requests to the active notation view's subpanel host. |
| `src/notationscene/qml/MuseScore/NotationScene/DrawingToolIcon.qml` | 52 | Adds the themed vector pin icon. |
| `src/notationscene/qml/MuseScore/NotationScene/CMakeLists.txt` | 172–174 | Registers the contextual panel, host and shared style controls in the QML module. |
| `DRAWING_CHANGELOG.md` | refreshed R1/R2/R7 references, R8 and validation status | Documents contextual behavior, changed locations, reasons and validation limits. |

## Validation status

- The Windows development build completed with Qt 6.11.2, MSVC 2022 and the RelWithDebInfo configuration before R4.
- Portable compilation and Qt dependency deployment completed successfully through R3. The package includes the PortableApps launcher, Qt runtime libraries and Windows platform plugin. Portable-mode headers were checked.
- R4 and R5 received source review, C++ formatting and whitespace inspection and are included in the successful portable build through R8. They have not been checked in the running application.
- R6 received conflict and source-diff inspection. Both submodules match the official main references. The merged source is included in the successful portable build through R8; runtime verification remains outstanding.
- The subsequent R4/R5 portable update attempt stopped during configuration because the local build helper treated a native warning as a terminating PowerShell error; it did not replace the previously successful R3 package.
- R7 compiled successfully as part of the portable build through R8; it has not been launched or exercised in the application. Docking, scrolling, keyboard navigation and theme rendering require runtime verification.
- R8 compiled successfully and was installed and deployed with the Qt dependencies and official PortableApps launcher. It has not been launched or exercised in the application. Pinning, replacement, placement under window resizing, scrolling, focus and live style synchronization require runtime verification.
- The local build helper now records native warning output without stopping the pipeline and checks each native process exit status. This orchestration correction is outside the repository; official build scripts are unchanged. The R8 build, installation and Qt deployment completed successfully. A final artifact-hash error was repaired using the .NET SHA256 implementation; the installed executable hash matches the compiled executable. The helper correction remains outside the repository.
- Portable artifact identity through R8: the installed application executable has SHA256 `D8D2E1A8F12B63ED522DAD9ED1C7C24CC1D594E1B385F9D3D3B8FFCAA32CA8FA`. Required launcher, Qt runtime and platform-plugin files were confirmed present.
- Automated tests were not executed. Musical editing, drawing interaction, persistence and portable runtime behavior still require application verification.
- Source labels are in English and use translation extraction. Translation catalogs are unchanged.
