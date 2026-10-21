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

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Muse.Ui
import Muse.UiComponents

ColumnLayout {
    id: root
    required property var paintView
    required property NavigationPanel navigationPanel
    signal hintChanged(string description)
    spacing: 8

    StyledTextLabel {
        Layout.fillWidth: true
        text: qsTrc("notation", "Drawing color")
        horizontalAlignment: Text.AlignLeft
    }

    RowLayout {
        Layout.fillWidth: true
        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            color: root.paintView ? root.paintView.drawingColor : "transparent"
            border.width: 1
            border.color: ui.theme.strokeColor
            radius: 2
        }
        StyledDropdown {
            id: colorControl
            Layout.fillWidth: true
            model: [
                { text: qsTrc("notation", "Black"), value: "#1f1f1f" },
                { text: qsTrc("notation", "Red"), value: "#c62828" },
                { text: qsTrc("notation", "Blue"), value: "#1565c0" },
                { text: qsTrc("notation", "Green"), value: "#2e7d32" }
            ]
            currentIndex: root.paintView ? indexOfValue(root.paintView.drawingColor.toString()) : -1
            navigation.panel: root.navigationPanel
            navigation.order: 3
            navigation.accessible.name: qsTrc("notation", "Drawing color")
            onActivated: function(index, value) { root.paintView.drawingColor = value }
            DrawingControlHint {
                control: colorControl
                title: qsTrc("notation", "Drawing color")
                description: qsTrc("notation", "Choose the color used for drawing strokes and previews.")
                interacting: colorControl.isOpened
                onHintChanged: function(description) { root.hintChanged(description) }
            }
        }
    }

    StyledTextLabel {
        Layout.fillWidth: true
        text: qsTrc("notation", "Stroke width")
        horizontalAlignment: Text.AlignLeft
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        StyledSlider {
            id: widthSlider
            Layout.fillWidth: true
            Layout.minimumWidth: 40
            from: 0.5
            to: 12
            stepSize: 0.5
            value: root.paintView ? root.paintView.drawingWidth : 1.5
            navigation.panel: root.navigationPanel
            navigation.order: 4
            navigation.accessible.name: qsTrc("notation", "Stroke width")
            onMoved: root.paintView.drawingWidth = value
            DrawingControlHint {
                control: widthSlider
                title: qsTrc("notation", "Stroke width")
                description: qsTrc("notation", "Drag to adjust stroke width with an immediate preview.")
                interacting: widthSlider.pressed
                onHintChanged: function(description) { root.hintChanged(description) }
            }
        }
        IncrementalPropertyControl {
            id: widthNumber
            Layout.preferredWidth: 76
            Layout.minimumWidth: 76
            Layout.maximumWidth: 76
            currentValue: root.paintView ? root.paintView.drawingWidth : 1.5
            minValue: 0.5
            maxValue: 12
            step: 0.5
            decimals: 2
            navigation.panel: root.navigationPanel
            navigation.order: 5
            navigation.accessible.name: qsTrc("notation", "Stroke width value")
            onValueEdited: function(value) {
                if (Number.isFinite(value) && value >= minValue && value <= maxValue) {
                    root.paintView.drawingWidth = value
                }
            }
            DrawingControlHint {
                control: widthNumber
                title: qsTrc("notation", "Stroke width value")
                description: qsTrc("notation", "Enter a width from 0.5 to 12, or use the increment buttons.")
                interacting: widthNumber.activeFocus
                onHintChanged: function(description) { root.hintChanged(description) }
            }
        }
    }
}
