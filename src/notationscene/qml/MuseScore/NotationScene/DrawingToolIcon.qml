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
