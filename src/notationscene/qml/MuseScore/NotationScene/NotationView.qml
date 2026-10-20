/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-Studio-CLA-applies
 *
 * MuseScore Studio
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore Limited and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Muse.Ui
import Muse.UiComponents
import MuseScore.NotationScene
import MuseScore.Braille
import MuseScore.Playback

import "internal"

FocusScope {
    id: root

    property alias name: notationView.objectName
    property alias publishMode: notationView.publishMode
    property alias readOnly: notationView.readOnly

    property alias paintView: notationView

    property alias isNavigatorVisible: notationNavigator.visible
    property alias isBraillePanelVisible: brailleViewLoader.active
    property alias isMainView: notationView.isMainView

    property alias defaultNavigationControl: fakeNavCtrl

    readonly property alias navigationSection: navSec
    readonly property alias navigationOrderEnd: searchPopup.navigationOrderEnd

    NavigationSection {
        id: navSec
        name: "NotationView"
        order: 5
        enabled: root.visible
    }

    QtObject {
        id: prv
        readonly property int scrollbarMargin: 4
    }

    NotationContextMenuModel {
        id: contextMenuModel
    }

    Component.onCompleted: {
        notationView.load()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        NotationSwitchPanel {
            id: tabPanel
            Layout.fillWidth: true

            navigationPanel.section: navSec
            navigationPanel.order: 1
        }

        SeparatorLine { visible: tabPanel.visible }

        SplitView {
            id: splitView

            Layout.fillWidth: true
            Layout.fillHeight: true

            orientation: notationNavigator.orientation === Qt.Horizontal ? Qt.Vertical : Qt.Horizontal

            StyledViewScrollAndZoomArea {
                SplitView.fillWidth: true
                SplitView.fillHeight: true

                horizontalScrollbarSize: notationView.horizontalScrollbarSize
                startHorizontalScrollPosition: notationView.startHorizontalScrollPosition

                verticalScrollbarSize: notationView.verticalScrollbarSize
                startVerticalScrollPosition: notationView.startVerticalScrollPosition

                NotationPaintView {
                    id: notationView
                    anchors.fill: parent

                    property NavigationPanel navigationPanel: NavigationPanel {
                        name: "ScoreView"
                        section: navSec
                        enabled: notationView.enabled && notationView.visible
                        direction: NavigationPanel.Both
                        order: tabPanel.navigationPanel.order + 1
                    }

                    NavigationControl {
                        id: fakeNavCtrl
                        name: "Score"
                        enabled: notationView.enabled && notationView.visible

                        panel: notationView.navigationPanel
                        order: 1

                        onActiveChanged: {
                            if (fakeNavCtrl.active) {
                                notationView.forceFocusIn()

                                if (notationView.navigationPanel.highlight) {
                                    notationView.selectOnNavigationActive()
                                }
                            } else {
                                notationView.focus = false
                            }
                        }
                    }

                    NavigationFocusBorder {
                        navigationCtrl: fakeNavCtrl
                        drawOutsideParent: false
                    }

                    Rectangle {
                        id: playbackCursor

                        Component.onCompleted: {
                            notationView.setPlaybackCursorItem(playbackCursor)
                        }
                    }

                    Rectangle {
                        id: drawingToolsPanel
                        z: 20
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 12
                        width: 196
                        height: toolsColumn.implicitHeight + 20
                        radius: 4
                        color: ui.theme.backgroundPrimaryColor
                        border.color: ui.theme.strokeColor
                        border.width: 1

                        Column {
                            id: toolsColumn
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            RowLayout {
                                width: parent.width
                                Text {
                                    Layout.fillWidth: true
                                    text: qsTrc("notation", "Drawing mode")
                                    color: ui.theme.fontPrimaryColor
                                    font: ui.theme.bodyFont
                                }
                                Switch {
                                    checked: notationView.drawingMode
                                    enabled: !notationView.readOnly && !notationView.publishMode
                                    onToggled: notationView.drawingMode = checked
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: 4
                                visible: notationView.drawingMode

                                Repeater {
                                    model: [
                                        { name: qsTrc("notation", "Select"), tool: "select" },
                                        { name: qsTrc("notation", "Pencil"), tool: "pencil" },
                                        { name: qsTrc("notation", "Line"), tool: "line" },
                                        { name: qsTrc("notation", "Rectangle"), tool: "rectangle" },
                                        { name: qsTrc("notation", "Ellipse"), tool: "ellipse" },
                                        { name: qsTrc("notation", "Triangle"), tool: "triangle" },
                                        { name: qsTrc("notation", "Right triangle"), tool: "rightTriangle" },
                                        { name: qsTrc("notation", "Diamond"), tool: "diamond" },
                                        { name: qsTrc("notation", "Rounded rectangle"), tool: "roundedRectangle" },
                                        { name: qsTrc("notation", "Star"), tool: "star" },
                                        { name: qsTrc("notation", "Cross"), tool: "cross" },
                                        { name: qsTrc("notation", "Arrow"), tool: "arrow" },
                                        { name: qsTrc("notation", "Double arrow"), tool: "doubleArrow" },
                                        { name: qsTrc("notation", "Filled arrow"), tool: "filledArrow" }
                                    ]

                                    delegate: Button {
                                        required property var modelData
                                        width: parent.width
                                        height: 28
                                        checkable: true
                                        checked: notationView.drawingTool === modelData.tool
                                        onClicked: notationView.drawingTool = modelData.tool

                                        contentItem: RowLayout {
                                            spacing: 8
                                            DrawingToolIcon {
                                                Layout.preferredWidth: 20
                                                Layout.preferredHeight: 20
                                                tool: modelData.tool
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.name
                                                color: ui.theme.fontPrimaryColor
                                                font: ui.theme.bodyFont
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                        background: Rectangle {
                                            radius: 3
                                            color: parent.checked ? ui.theme.accentColor : (parent.hovered ? ui.theme.buttonColor : "transparent")
                                            border.color: parent.checked ? ui.theme.accentColor : "transparent"
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                width: parent.width
                                visible: notationView.drawingMode

                                Text {
                                    text: qsTrc("notation", "Color")
                                    color: ui.theme.fontPrimaryColor
                                    font: ui.theme.bodyFont
                                }
                                ComboBox {
                                    Layout.fillWidth: true
                                    model: [qsTrc("notation", "Black"), qsTrc("notation", "Red"), qsTrc("notation", "Blue"), qsTrc("notation", "Green")]
                                    onActivated: {
                                        const colors = ["#1f1f1f", "#c62828", "#1565c0", "#2e7d32"]
                                        notationView.drawingColor = colors[currentIndex]
                                    }
                                }
                            }

                            RowLayout {
                                width: parent.width
                                visible: notationView.drawingMode

                                Text {
                                    text: qsTrc("notation", "Width")
                                    color: ui.theme.fontPrimaryColor
                                    font: ui.theme.bodyFont
                                }
                                Slider {
                                    Layout.fillWidth: true
                                    from: 0.5
                                    to: 12
                                    value: notationView.drawingWidth
                                    onMoved: notationView.drawingWidth = value
                                }
                            }
                        }
                    }

                    onActiveFocusRequested: {
                        fakeNavCtrl.requestActive()
                    }

                    onShowContextMenuRequested: function (elementType, viewPos) {
                        contextMenuModel.loadItems(elementType)
                        contextMenuLoader.show(viewPos, contextMenuModel.items)
                    }

                    onHideContextMenuRequested: {
                        contextMenuLoader.close()
                    }

                    onShowSearchRequested: {
                        searchPopup.show()        
                    }

                    onShowElementPopupRequested: function (popupType) {
                        popUpLoader.updateShow(popupType);
                    }

                    onHideElementPopupRequested: {
                        popUpLoader.updateShow(AbstractElementPopupModel.TYPE_UNDEFINED);
                    }

                    onViewportChanged: {
                        notationNavigator.setCursorRect(viewport)
                    }

                    ContextMenuLoader {
                        id: contextMenuLoader

                        onHandleMenuItem: function(itemId) {
                            contextMenuModel.handleMenuItem(itemId)
                        }

                        onOpened: notationView.onContextMenuIsOpenChanged(true)
                        onClosed: notationView.onContextMenuIsOpenChanged(false)
                    }

                    ElementPopupLoader {
                        id: popUpLoader

                        notationViewNavigationSection: navSec
                        navigationOrderStart: notationView.navigationPanel.order + 1

                        property int popupType: AbstractElementPopupModel.TYPE_UNDEFINED
                        property bool updateShowScheduled: false

                        function updateShow(popupType) {
                            this.popupType = popupType;
                            if (!updateShowScheduled) {
                                Qt.callLater(doUpdateShow)
                                updateShowScheduled = true;
                            }
                        }

                        function doUpdateShow() {
                            updateShowScheduled = false;

                            if (popupType !== AbstractElementPopupModel.TYPE_UNDEFINED) {
                                show(popupType);
                            } else {
                                close();
                            }
                        }

                        onOpened: function(popupType) {
                            notationView.onElementPopupIsOpenChanged(popupType)
                        }

                        onClosed: {
                            notationView.onElementPopupIsOpenChanged(AbstractElementPopupModel.TYPE_UNDEFINED)
                        }
                    }

                    NotationRegionsBeingProcessedView {
                        notationViewRect: Qt.rect(notationView.x, notationView.y, notationView.width, notationView.height)
                        notationViewMatrix: notationView.matrix
                    }
                }

                onPinchToZoom: function(scale, pos) {
                    notationView.pinchToZoom(scale, pos)
                }

                onScrollHorizontal: function(newPos) {
                    notationView.scrollHorizontal(newPos)
                }

                onScrollVertical: function(newPos) {
                    notationView.scrollVertical(newPos)
                }
            }

            Loader {
                id: notationNavigator

                readonly property NotationNavigator navigatorItem: item as NotationNavigator

                property var orientation: navigatorItem?.orientation ?? Qt.Horizontal

                visible: false

                SplitView.preferredHeight: 100
                SplitView.preferredWidth: 100
                SplitView.minimumWidth: 30
                SplitView.minimumHeight: 30

                sourceComponent: visible ? navigatorComp : null

                function setCursorRect(viewport) {
                    if (navigatorItem) {
                        navigatorItem.setCursorRect(viewport)
                    }
                }
            }

            Loader {
                id: brailleViewLoader

                readonly property int navigationOrder: popUpLoader.navigationOrderEnd + 1

                active: false
                visible: active

                SplitView.fillWidth: true
                SplitView.preferredHeight: 50
                SplitView.minimumHeight: 30

                sourceComponent: BrailleView {
                    navigationPanel.section: navSec
                    navigationPanel.order: brailleViewLoader.navigationOrder

                    navigationPanel.onActiveChanged: function (active) {
                        if (active) {
                            notationView.navigationPanel.setActive(false);
                            fakeNavCtrl.setActive(false);
                        }
                    }
                }
            }

            Component {
                id: navigatorComp

                NotationNavigator {

                    property bool isVertical: orientation === Qt.Vertical

                    objectName: root.name + "Navigator"

                    Component.onCompleted: {
                        load()
                    }

                    onMoveNotationRequested: function(dx, dy) {
                        notationView.moveCanvas(dx, dy)
                    }
                }
            }

            handle: Rectangle {
                id: resizingHandle

                implicitWidth: 4
                implicitHeight: 4

                color: ui.theme.strokeColor

                states: [
                    State {
                        name: "PRESSED"
                        when: resizingHandle.SplitHandle.pressed
                        PropertyChanges {
                            target: resizingHandle
                            opacity: ui.theme.accentOpacityHit
                        }
                    },
                    State {
                        name: "HOVERED"
                        when: resizingHandle.SplitHandle.hovered
                        PropertyChanges {
                            target: resizingHandle
                            opacity: ui.theme.accentOpacityHover
                        }
                    }
                ]
            }
        }

        SearchPopup {
            id: searchPopup

            Layout.fillWidth: true

            navigationPanel.section: navSec
            navigationOrderStart: brailleViewLoader.navigationOrder + 1

            onClosed: {
                fakeNavCtrl.requestActive()
            }
        }
    }
}
