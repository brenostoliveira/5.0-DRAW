/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-Studio-CLA-applies
 *
 * MuseScore Studio
 * Music Composition & Notation
 *
 * Copyright (C) 2026 MuseScore Limited and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 */

import QtQuick
import QtQuick.Shapes

import Muse.UiComponents

Shape {
    id: root

    property string tool: "select"
    property string pathData: {
        switch (tool) {
        case "select": return "M5 2 L19 15 L13 16 L16 22 L12.5 23 L9.5 17 L5 21 Z"
        case "pencil": return "M4 18 L7 20 L20 7 L17 4 Z M15.5 5.5 L18.5 8.5 M4 18 L3 22 L7 20"
        case "line": return "M4 20 L20 4 M4 20 L7 20 M20 4 L20 7"
        case "rectangle": return "M4 4 L20 4 L20 20 L4 20 Z"
        case "ellipse": return "M12 3 C17 3 21 7 21 12 C21 17 17 21 12 21 C7 21 3 17 3 12 C3 7 7 3 12 3 Z"
        case "triangle": return "M12 3 L22 21 L2 21 Z"
        case "rightTriangle": return "M4 3 L4 21 L22 21 Z"
        case "diamond": return "M12 2 L22 12 L12 22 L2 12 Z"
        case "roundedRectangle": return "M8 3 L16 3 C19 3 21 5 21 8 L21 16 C21 19 19 21 16 21 L8 21 C5 21 3 19 3 16 L3 8 C3 5 5 3 8 3 Z"
        case "star": return "M12 2 L14.8 9 L22 9.5 L16.5 14.5 L18.5 22 L12 18 L5.5 22 L7.5 14.5 L2 9.5 L9.2 9 Z"
        case "cross": return "M12 3 L12 21 M3 12 L21 12"
        case "arrow": return "M3 12 L21 12 M14 5 L21 12 L14 19"
        case "doubleArrow": return "M8 5 L1 12 L8 19 M16 5 L23 12 L16 19"
        case "filledArrow": return "M2 10 L15 10 L15 4 L23 12 L15 20 L15 14 L2 14 Z"
        case "bezier": return "M3 20 C3 4 21 20 21 4 M1 18 L5 18 L5 22 L1 22 Z M19 2 L23 2 L23 6 L19 6 Z"
        case "paint": return "M4 12 L12 4 L20 12 L12 20 Z M4 12 L20 12 M21 15 C17 20 17 23 21 23 C25 23 25 20 21 15"
        case "repeat": return "M2 18 C7 3 17 21 22 6 M3 16 L6 16 L6 19 L3 19 Z M10 10 L13 10 L13 13 L10 13 Z M19 5 L22 5 L22 8 L19 8 Z"
        case "nodes": return "M3 20 C3 4 21 20 21 4 M1 18 L5 18 L5 22 L1 22 Z M19 2 L23 2 L23 6 L19 6 Z M7 3 L17 3 M12 3 L12 12"
        case "eraser": return "M3 15 L14 3 L22 10 L11 22 L8 22 Z M6 12 L14 19 M8 22 L23 22"
        case "text": return "M4 4 L20 4 M12 4 L12 21 M7 21 L17 21"
        case "group": return "M2 2 L22 2 L22 22 L2 22 Z M6 6 L13 6 L13 13 L6 13 Z M11 11 L18 11 L18 18 L11 18 Z"
        case "layers": return "M2 7 L12 2 L22 7 L12 12 Z M2 12 L12 17 L22 12 M2 17 L12 22 L22 17"
        case "characters": return "M3 21 L8 21 C-2 8 5 2 12 2 C19 2 26 8 16 21 L21 21"
        case "transfer": return "M3 8 L20 8 M15 3 L20 8 L15 13 M21 17 L4 17 M9 12 L4 17 L9 22"
        case "delete": return "M4 6 L20 6 M8 6 L8 3 L16 3 L16 6 M6 6 L7 22 L17 22 L18 6 M10 10 L10 18 M14 10 L14 18"
        case "grid": return "M3 3 L21 3 L21 21 L3 21 Z M9 3 L9 21 M15 3 L15 21 M3 9 L21 9 M3 15 L21 15"
        case "pin": return "M8 3 L19 3 M9 3 L9 10 L5 15 L21 15 L17 10 L17 3 M13 15 L13 23"
        default: return ""
        }
    }

    ShapePath {
        strokeColor: ui.theme.fontPrimaryColor
        strokeWidth: 1.8
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
        fillColor: "transparent"

        PathSvg {
            path: root.pathData
        }
    }
}
