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
    required property Item control
    property string title: ""
    property string description: ""
    property string shortcut: ""
    property bool interacting: false
    signal hintChanged(string description)

    anchors.fill: parent

    function dismiss() {
        delay.stop()
        if (tipLoader.item) {
            tipLoader.item.close()
        }
        tipLoader.active = false
    }

    HoverHandler {
        id: hover
        blocking: false
        onHoveredChanged: {
            root.hintChanged(hovered ? root.description : "")
            if (hovered && !root.interacting) {
                delay.restart()
            } else {
                root.dismiss()
            }
        }
    }

    Timer {
        id: delay
        interval: 600
        onTriggered: {
            if (hover.hovered && !root.interacting && root.visible) {
                tipLoader.active = true
                if (tipLoader.item) {
                    tipLoader.item.open()
                }
            }
        }
    }

    Loader {
        id: tipLoader
        active: false
        sourceComponent: StyledToolTip {
            parent: root.control
            closePolicies: PopupView.NoAutoClose
            closeOnEscape: false
            title: root.title
            description: root.description
            shortcut: root.shortcut
            onWindowChanged: {
                if (window) {
                    window.flags = window.flags | Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus
                }
            }
        }
    }

    onInteractingChanged: { if (interacting) root.dismiss() }
    onVisibleChanged: { if (!visible) root.dismiss() }
    Component.onDestruction: root.dismiss()
}
