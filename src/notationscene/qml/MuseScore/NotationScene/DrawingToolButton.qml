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
import Muse.UiComponents

Item {
    id: root
    property bool actionEnabled: true
    property bool accentButton: false
    property string toolTipTitle: ""
    property string toolTipDescription: ""
    property string toolTipShortcut: ""
    property Component contentItem: null
    property alias navigation: button.navigation
    property alias accessible: button.accessible
    signal clicked()
    signal hintChanged(string description)

    implicitWidth: 38
    implicitHeight: 34

    FlatButton {
        id: button
        anchors.fill: parent
        minWidth: 0
        margins: 0
        enabled: root.actionEnabled
        accentButton: root.accentButton
        toolTipTitle: root.toolTipTitle
        toolTipDescription: root.toolTipDescription
        toolTipShortcut: root.toolTipShortcut
        toolTipShowLocked: true
        contentItem: root.contentItem
        onClicked: root.clicked()
    }

    DrawingControlHint {
        control: root
        title: root.toolTipTitle
        description: root.toolTipDescription
        shortcut: root.toolTipShortcut
        interacting: button.mouseArea.pressed
        onHintChanged: function(description) { root.hintChanged(description) }
    }
}
