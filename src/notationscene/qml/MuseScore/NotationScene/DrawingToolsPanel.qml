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

Item {
    id: root

    required property var paintView
    property NavigationSection navigationSection: null
    property int navigationOrderStart: 1
    property bool keepVisible: false
    signal keepVisibleRequested(bool keep)
    signal subpanelRequested(string tool, string title)

    readonly property bool canDraw: Boolean(paintView) && paintView.drawingMode
                                   && !paintView.readOnly && !paintView.publishMode

    property string hintDescription: ""
    readonly property real descriptionHeight: Math.max(0, Math.min(96, height - 120))
    DrawingToolInfo { id: toolInfo }

    implicitWidth: 168

    NavigationPanel {
        id: toolsNavigation
        name: "DrawingTools"
        section: root.navigationSection
        order: root.navigationOrderStart
        enabled: root.visible
        direction: NavigationPanel.Both
        accessible.name: qsTrc("notation", "Drawing tools")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        CheckBox {
            id: keepVisibleControl
            Layout.fillWidth: true
            text: qsTrc("notation", "Keep visible")
            checked: root.keepVisible
            navigation.panel: toolsNavigation
            navigation.order: 0
            onClicked: root.keepVisibleRequested(!checked)
            DrawingControlHint {
                control: keepVisibleControl
                title: qsTrc("notation", "Keep visible")
                description: qsTrc("notation", "Keep the main panel open when drawing mode is turned off.")
                interacting: keepVisibleControl.pressed
                onHintChanged: function(description) { root.hintDescription = description }
            }
        }

        SeparatorLine { Layout.fillWidth: true }

        StyledFlickable {
            id: scrollArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: groupsColumn.implicitHeight
            flickableDirection: Flickable.VerticalFlick

            Column {
                id: groupsColumn
                width: scrollArea.width - 10
                spacing: 8

                Repeater {
                    model: [
                        { key: "colors", title: qsTrc("notation", "Colors"), tools: [] },
                        { key: "selection", title: qsTrc("notation", "Selection"), tools: [
                            { tool: "select", title: qsTrc("notation", "Select"), available: true } ] },
                        { key: "pencil", title: qsTrc("notation", "Pencil"), tools: [
                            { tool: "pencil", title: qsTrc("notation", "Pencil"), available: true } ] },
                        { key: "bezier", title: qsTrc("notation", "Bézier"), tools: [
                            { tool: "bezier", title: qsTrc("notation", "Bézier pen"), available: false } ] },
                        { key: "shapes", title: qsTrc("notation", "Shapes"), tools: [
                            { tool: "line", title: qsTrc("notation", "Line"), available: true },
                            { tool: "rectangle", title: qsTrc("notation", "Rectangle"), available: true },
                            { tool: "ellipse", title: qsTrc("notation", "Ellipse"), available: true },
                            { tool: "triangle", title: qsTrc("notation", "Triangle"), available: true },
                            { tool: "rightTriangle", title: qsTrc("notation", "Right triangle"), available: true },
                            { tool: "diamond", title: qsTrc("notation", "Diamond"), available: true },
                            { tool: "roundedRectangle", title: qsTrc("notation", "Rounded rectangle"), available: true },
                            { tool: "star", title: qsTrc("notation", "Star"), available: true },
                            { tool: "cross", title: qsTrc("notation", "Cross"), available: true },
                            { tool: "arrow", title: qsTrc("notation", "Arrow"), available: true },
                            { tool: "doubleArrow", title: qsTrc("notation", "Double arrow"), available: true },
                            { tool: "filledArrow", title: qsTrc("notation", "Filled arrow"), available: true } ] },
                        { key: "paint", title: qsTrc("notation", "Painting / gradients"), tools: [
                            { tool: "paint", title: qsTrc("notation", "Painting / gradients"), available: false } ] },
                        { key: "repeat", title: qsTrc("notation", "Repeat along path"), tools: [
                            { tool: "repeat", title: qsTrc("notation", "Repeat along path"), available: false } ] },
                        { key: "nodes", title: qsTrc("notation", "Nodes / anchors"), tools: [
                            { tool: "nodes", title: qsTrc("notation", "Nodes / anchors"), available: false } ] },
                        { key: "eraser", title: qsTrc("notation", "Eraser"), tools: [
                            { tool: "eraser", title: qsTrc("notation", "Eraser"), available: false } ] },
                        { key: "text", title: qsTrc("notation", "Text"), tools: [
                            { tool: "text", title: qsTrc("notation", "Text"), available: false } ] },
                        { key: "group", title: qsTrc("notation", "Grouping / fusion"), tools: [
                            { tool: "group", title: qsTrc("notation", "Grouping / fusion"), available: false } ] },
                        { key: "layers", title: qsTrc("notation", "Objects / layers"), tools: [
                            { tool: "layers", title: qsTrc("notation", "Objects / layers"), available: false } ] },
                        { key: "characters", title: qsTrc("notation", "Characters"), tools: [
                            { tool: "characters", title: qsTrc("notation", "Characters"), available: false } ] },
                        { key: "transfer", title: qsTrc("notation", "Import / export"), tools: [
                            { tool: "transfer", title: qsTrc("notation", "Import / export"), available: false } ] },
                        { key: "history", title: qsTrc("notation", "Undo / redo"), tools: [] },
                        { key: "delete", title: qsTrc("notation", "Delete"), tools: [
                            { tool: "delete", title: qsTrc("notation", "Delete drawing"), available: false } ] },
                        { key: "grid", title: qsTrc("notation", "Anchor grid"), tools: [
                            { tool: "grid", title: qsTrc("notation", "Anchor grid"), available: false } ] }
                    ]

                    delegate: Column {
                        id: groupDelegate
                        required property var modelData
                        required property int index
                        width: groupsColumn.width
                        spacing: 6

                        StyledTextLabel {
                            width: parent.width
                            text: groupDelegate.modelData.title
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.WordWrap
                        }

                        DrawingToolButton {
                            visible: groupDelegate.modelData.key === "colors"
                            width: 38
                            height: 34
                            actionEnabled: root.canDraw
                            toolTipTitle: qsTrc("notation", "Drawing colors and stroke")
                            toolTipDescription: toolInfo.description("colors")
                            onHintChanged: function(description) { root.hintDescription = description }
                            navigation.panel: toolsNavigation
                            navigation.order: 1
                            contentItem: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                color: root.paintView ? root.paintView.drawingColor : "transparent"
                                border.width: 1
                                border.color: ui.theme.strokeColor
                                radius: 2
                            }
                            onClicked: root.subpanelRequested("colors", qsTrc("notation", "Colors and stroke"))
                        }

                        Grid {
                            columns: 3
                            spacing: 6
                            Repeater {
                                model: groupDelegate.modelData.tools
                                delegate: DrawingToolButton {
                                    id: toolButton
                                    required property var modelData
                                    required property int index
                                    width: 38
                                    height: 34
                                    actionEnabled: root.canDraw && modelData.available
                                    accentButton: modelData.available && Boolean(root.paintView)
                                                  && root.paintView.drawingTool === modelData.tool
                                    toolTipTitle: modelData.title
                                    toolTipDescription: modelData.available ? toolInfo.description(modelData.tool) : qsTrc("notation", "This tool is not available yet.")
                                    onHintChanged: function(description) { root.hintDescription = description }
                                    accessible.selected: accentButton
                                    navigation.panel: toolsNavigation
                                    navigation.order: (groupDelegate.index + 1) * 100 + index
                                    onClicked: {
                                        root.paintView.drawingTool = modelData.tool
                                        root.subpanelRequested(modelData.tool, modelData.title)
                                    }
                                    contentItem: Item {
                                        implicitWidth: 24
                                        implicitHeight: 24
                                        DrawingToolIcon {
                                            anchors.centerIn: parent
                                            width: 24
                                            height: 24
                                            tool: toolButton.modelData.tool
                                        }
                                    }
                                }
                            }
                        }

                        Loader {
                            active: groupDelegate.modelData.key === "history"
                            visible: active
                            sourceComponent: UndoRedoToolBar {
                                id: historyToolbar
                                enabled: root.canDraw
                                navigationPanel.name: "DrawingUndoRedo"
                                navigationPanel.section: root.navigationSection
                                navigationPanel.order: root.navigationOrderStart + 1
                                sourceComponentCallback: function(type) {
                                    return type === ToolBarItemType.ACTION ? historyControl : null
                                }
                                Component {
                                    id: historyControl
                                    StyledToolBarItem {
                                        id: historyButton
                                        width: 30
                                        height: 30
                                        navigation.panel: historyToolbar.navigationPanel
                                        navigation.order: historyButton.parent ? historyButton.parent.itemIndex : 0
                                        toolTipShowLocked: true
                                        DrawingControlHint {
                                            control: historyButton
                                            title: historyButton.toolTipTitle
                                            description: historyButton.toolTipDescription || qsTrc("notation", "Undo or redo the most recent score edit.")
                                            shortcut: historyButton.toolTipShortcut
                                            interacting: historyButton.mouseArea.pressed
                                            onHintChanged: function(description) { root.hintDescription = description }
                                        }
                                    }
                                }
                            }
                        }

                        SeparatorLine { width: parent.width }
                    }
                }
            }
        }
        SeparatorLine { Layout.fillWidth: true }
        StyledTextLabel {
            Layout.fillWidth: true
            Layout.minimumHeight: root.descriptionHeight
            Layout.preferredHeight: root.descriptionHeight
            Layout.maximumHeight: root.descriptionHeight
            text: root.hintDescription || toolInfo.description(root.paintView ? root.paintView.drawingTool : "select")
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
            maximumLineCount: 5
        }
    }
}
