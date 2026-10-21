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
            spacing: 4
            StyledTextLabel {
                Layout.fillWidth: true
                text: root.title
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WordWrap
            }
            FlatButton {
                width: 30
                height: 30
                minWidth: 0
                margins: 0
                accentButton: root.pinned
                toolTipTitle: root.pinned ? qsTrc("notation", "Unpin subpanel") : qsTrc("notation", "Pin subpanel")
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
                width: 30
                height: 30
                minWidth: 0
                margins: 0
                icon: IconCode.CLOSE_X_ROUNDED
                toolTipTitle: qsTrc("notation", "Close subpanel")
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

                FlatButton {
                    visible: root.tool !== "colors"
                    Layout.fillWidth: true
                    text: qsTrc("notation", "Use tool")
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
                }
            }
        }
    }
}
