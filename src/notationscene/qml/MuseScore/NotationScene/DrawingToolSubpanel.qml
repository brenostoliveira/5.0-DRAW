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
import MuseScore.NotationScene

Rectangle {
    id: root
    required property var paintView
    required property string tool
    required property string title
    required property NavigationSection navigationSection
    required property int navigationOrder
    property string hintDescription: ""
    DrawingToolInfo { id: toolInfo }
    property bool pinned: false
    property bool hasPendingConfirmation: false
    signal closeRequested()
    signal pinRequested(bool pin)
    signal activated()

    implicitWidth: 268
    implicitHeight: headerRow.implicitHeight + body.implicitHeight + 33
    color: ui.theme.backgroundPrimaryColor
    border.color: ui.theme.strokeColor
    border.width: 1
    radius: 4
    clip: true

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: root.activated()
        onWheel: function(wheel) { wheel.accepted = true }
    }

    NavigationPanel {
        id: panelNavigation
        name: "DrawingSubpanel_" + root.tool
        section: root.navigationSection
        order: root.navigationOrder
        enabled: root.visible && root.enabled
        direction: NavigationPanel.Both
        accessible.name: root.title
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        RowLayout {
            id: headerRow
            Layout.fillWidth: true
            Layout.minimumHeight: 36
            Layout.preferredHeight: 36
            Layout.maximumHeight: 36
            spacing: 4
            StyledTextLabel {
                Layout.fillWidth: true
                font: ui.theme.bodyBoldFont
                maximumLineCount: 2
                text: root.title
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WordWrap
            }
            FlatButton {
                id: pinControl
                Layout.preferredWidth: 30
                width: 30
                height: 30
                minWidth: 0
                margins: 0
                accentButton: root.pinned
                toolTipTitle: root.pinned ? qsTrc("notation", "Unpin subpanel") : qsTrc("notation", "Pin subpanel")
                toolTipDescription: qsTrc("notation", "Keep this subpanel open when another tool panel is opened.")
                toolTipShowLocked: true
                DrawingControlHint {
                    control: pinControl
                    title: pinControl.toolTipTitle
                    description: pinControl.toolTipDescription
                    interacting: pinControl.mouseArea.pressed
                    onHintChanged: function(description) { root.hintDescription = description }
                }
                accessible.checked: root.pinned
                navigation.panel: panelNavigation
                navigation.order: 0
                contentItem: Item {
                    implicitWidth: 24
                    implicitHeight: 24
                    DrawingToolIcon {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        tool: "pin"
                    }
                }
                onClicked: root.pinRequested(!root.pinned)
            }
            FlatButton {
                id: closeControl
                Layout.preferredWidth: 30
                width: 30
                height: 30
                minWidth: 0
                margins: 0
                icon: IconCode.CLOSE_X_ROUNDED
                toolTipTitle: qsTrc("notation", "Close subpanel")
                toolTipDescription: qsTrc("notation", "Close this subpanel without changing the active tool.")
                toolTipShowLocked: true
                DrawingControlHint {
                    control: closeControl
                    title: closeControl.toolTipTitle
                    description: closeControl.toolTipDescription
                    interacting: closeControl.mouseArea.pressed
                    onHintChanged: function(description) { root.hintDescription = description }
                }
                navigation.panel: panelNavigation
                navigation.order: 1
                onClicked: root.closeRequested()
            }
        }

        SeparatorLine { Layout.fillWidth: true }

        StyledFlickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: body.implicitHeight
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout {
                id: body
                width: parent.width - 10
                spacing: 10

                StyledTextLabel {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 76
                    Layout.preferredHeight: 76
                    Layout.maximumHeight: 76
                    text: root.hintDescription || toolInfo.description(root.tool)
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignTop
                    wrapMode: Text.WordWrap
                    maximumLineCount: 4
                }

                FlatButton {
                    id: activateControl
                    visible: root.tool !== "colors"
                    Layout.fillWidth: true
                    text: qsTrc("notation", "Use tool")
                    toolTipTitle: root.title
                    toolTipDescription: toolInfo.description(root.tool)
                    toolTipShowLocked: true
                    DrawingControlHint {
                        control: activateControl
                        title: activateControl.toolTipTitle
                        description: activateControl.toolTipDescription
                        interacting: activateControl.mouseArea.pressed
                        onHintChanged: function(description) { root.hintDescription = description }
                    }
                    accentButton: Boolean(root.paintView) && root.paintView.drawingTool === root.tool
                    navigation.panel: panelNavigation
                    navigation.order: 2
                    onClicked: root.paintView.drawingTool = root.tool
                }

                StyledTextLabel {
                    visible: root.tool === "select"
                    Layout.fillWidth: true
                    text: qsTrc("notation", "Click a drawing to select it.")
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                }

                DrawingStyleControls {
                    visible: root.tool !== "select"
                    Layout.fillWidth: true
                    paintView: root.paintView
                    navigationPanel: panelNavigation
                    onHintChanged: function(description) { root.hintDescription = description }
                }
            }
        }
    }
}
