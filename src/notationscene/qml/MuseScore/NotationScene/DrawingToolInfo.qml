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

QtObject {
    function description(tool) {
        switch (tool) {
        case "select": return qsTrc("notation", "Select a drawing and drag it to move it.")
        case "pencil": return qsTrc("notation", "Drag on the score to draw a freehand line.")
        case "colors": return qsTrc("notation", "Set the color and width used for drawing strokes.")
        default: return qsTrc("notation", "Drag on the score to draw this shape.")
        }
    }
}
