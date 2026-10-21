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
import Muse.Ui
import MuseScore.NotationScene

Item {
    id: root
    required property var paintView
    required property NavigationSection navigationSection
    property var panels: []
    property int nextNavigationOrder: 100
    property int nextStackOrder: 1
    readonly property real margin: Math.min(8, Math.max(0, width / 2), Math.max(0, height / 2))
    readonly property int gap: 8
    visible: Boolean(paintView) && paintView.drawingMode
    enabled: visible && !paintView.readOnly && !paintView.publishMode

    function closePanel(panel) {
        root.panels = root.panels.filter(function(item) { return item !== panel })
        panel.destroy()
    }

    function placePanel(panel, occupied) {
        const maxX = Math.max(root.margin, root.width - root.margin - panel.width)
        const maxY = Math.max(root.margin, root.height - root.margin - panel.height)
        const xs = [root.margin, maxX, panel.x]
        const ys = [root.margin, maxY, panel.y]
        for (const other of occupied) {
            xs.push(other.x - panel.width - root.gap, other.x + other.width + root.gap)
            ys.push(other.y - panel.height - root.gap, other.y + other.height + root.gap)
        }
        let bestOverlap = Infinity
        let bestDistance = Infinity
        let bestX = root.margin
        let bestY = root.margin
        for (const candidateX of xs) {
            const x = Math.max(root.margin, Math.min(maxX, candidateX))
            for (const candidateY of ys) {
                const y = Math.max(root.margin, Math.min(maxY, candidateY))
                let overlap = 0
                for (const other of occupied) {
                    const w = Math.max(0, Math.min(x + panel.width + root.gap, other.x + other.width)
                                       - Math.max(x - root.gap, other.x))
                    const h = Math.max(0, Math.min(y + panel.height + root.gap, other.y + other.height)
                                       - Math.max(y - root.gap, other.y))
                    overlap += w * h
                }
                const distance = (x - panel.x) * (x - panel.x) + (y - panel.y) * (y - panel.y)
                if (overlap < bestOverlap || (overlap === bestOverlap && distance < bestDistance)) {
                    bestOverlap = overlap
                    bestDistance = distance
                    bestX = x
                    bestY = y
                }
            }
        }
        panel.x = bestX
        panel.y = bestY
    }

    function relayout() {
        const occupied = []
        for (const panel of root.panels) {
            root.placePanel(panel, occupied)
            occupied.push(panel)
        }
    }

    function openPanel(tool, title) {
        if (!root.enabled) {
            return
        }
        const existing = root.panels.find(function(panel) { return panel.tool === tool })
        const previous = root.panels.slice()
        for (const panel of previous) {
            if (panel !== existing && !panel.pinned && !panel.hasPendingConfirmation) {
                root.closePanel(panel)
            }
        }
        if (existing) {
            existing.z = root.nextStackOrder++
            return
        }
        const panel = panelComponent.createObject(root, {
            tool: tool,
            title: title,
            navigationOrder: root.nextNavigationOrder++,
            x: root.margin,
            y: root.margin,
            z: root.nextStackOrder++
        })
        if (!panel) {
            return
        }
        root.placePanel(panel, root.panels)
        root.panels = root.panels.concat([panel])
        Qt.callLater(root.relayout)
    }

    onWidthChanged: Qt.callLater(root.relayout)
    onHeightChanged: Qt.callLater(root.relayout)
    onVisibleChanged: { if (visible) Qt.callLater(root.relayout) }

    Component {
        id: panelComponent
        DrawingToolSubpanel {
            id: subpanel
            paintView: root.paintView
            navigationSection: root.navigationSection
            width: Math.max(0, Math.min(implicitWidth, root.width - 2 * root.margin))
            height: Math.max(0, Math.min(implicitHeight, root.height - 2 * root.margin))
            onPinRequested: function(pin) { subpanel.pinned = pin }
            onCloseRequested: root.closePanel(subpanel)
            onActivated: subpanel.z = root.nextStackOrder++
            onImplicitHeightChanged: Qt.callLater(root.relayout)
        }
    }
}
