// SPDX-License-Identifier: GPL-3.0-only
import QtQuick
import QtTest
import "../../qml/MuseScore/NotationScene/drawing/core/Parametric.js" as P
import "../../qml/MuseScore/NotationScene/drawing/core/Editing.js" as E
import "../../qml/MuseScore/NotationScene/drawing/core/Vector.js" as V
import "../../qml/MuseScore/NotationScene/drawing/core/Context.js" as A

TestCase {
    name: "ParametricNoise"
    function noise(length, options, width) {
        return E.basicShape("noise", {x: 0, y: 0}, {x: length, y: 0},
                            V.style("#123456", "none", width || 2, 1),
                            Object.assign({seed: 42, density: 35, amplitude: 20, verticalSpacing: 8}, options || {}));
    }
    function dots(shape) { return P.renderNoise(shape).commands.slice(0, -2); }

    function test_deterministic_persistence() {
        var a = noise(300), b = noise(300);
        compare(JSON.stringify(a.commands), JSON.stringify(b.commands));
        var restored = V.readDocument(V.document([a]))[0];
        compare(restored.kind, "noise");
        compare(restored.wave.seed, 42);
        compare(restored.wave.guideVersion, 1);
        compare(JSON.stringify(dots(restored)), JSON.stringify(dots(a)));
    }
    function test_layout_adds_dots_without_stretching() {
        var a = noise(150), b = noise(300);
        verify(dots(b).length > dots(a).length);
        var first = dots(a).filter(function(c) { return c[1] < 145; });
        var extended = dots(b).filter(function(c) { return c[1] < 145; });
        compare(JSON.stringify(first), JSON.stringify(extended));
        compare(a.style.width, b.style.width);
        var shortened = P.clone(b);
        shortened.commands[1][1] = 150;
        compare(JSON.stringify(dots(shortened)), JSON.stringify(dots(a)));
    }
    function test_density_and_spacing() {
        verify(dots(noise(300, {density: 90})).length > dots(noise(300, {density: 5})).length);
        verify(dots(noise(300, {verticalSpacing: 2})).length > dots(noise(300, {verticalSpacing: 20})).length);
    }
    function test_zero_spread_keeps_a_dotted_line() {
        var a = noise(300, {amplitude: 0, density: 50});
        verify(dots(a).length > 10);
        verify(dots(a).every(function(c) { return c[2] === 0; }));
    }
    function test_full_density_is_filled_envelope() {
        var a = noise(100000, {density: 100});
        verify(dots(a).length < 16);
        verify(dots(a).some(function(c) { return c[0] === "Z"; }));
        var svg = V.svg([a]);
        verify(svg.indexOf('fill="#123456"') >= 0);
        compare(a.style.fill, "none");
        verify(V.svg([noise(300)]).indexOf('fill="none"') >= 0);
    }
    function test_edit_handles_do_not_mutate_seed_or_original() {
        var a = noise(300), original = JSON.stringify(a), handles = P.handles(a, 1);
        compare(handles.length, 6);
        compare(handles[0].role, "noise-spread");
        compare(handles[1].role, "noise-spacing");
        var changed = P.adjust(a, handles[0], 0, 10, 1);
        compare(changed.wave.stops[0].amplitude, 30);
        compare(changed.wave.seed, a.wave.seed);
        changed = P.adjust(a, handles[1], 0, -5, 1);
        compare(changed.wave.stops[0].period, 13);
        compare(JSON.stringify(a), original);
    }
    function test_size_colour_and_gradient() {
        var a = noise(300, {}, 5), old = JSON.stringify(a.style);
        verify(V.svg([a]).indexOf('stroke-width="5"') >= 0);
        var gradient = {stops: []}, st = Object.assign({}, a.style, {strokeGradient: gradient});
        compare(P.noiseStyle({waveform: "noise", density: 100}, st).fillGradient, gradient);
        compare(JSON.stringify(a.style), old);
    }
    function test_rotation_and_geometry_budget() {
        var a = noise(300), moved = V.translate(a, 10, 12);
        compare(moved.wave.a.x, 10);
        compare(moved.wave.a.y, 12);
        var rotated = V.transform(a, [0, 1, -1, 0, 0, 0]);
        verify(rotated.commands.every(function(c) { return c.length < 3 || (isFinite(c[1]) && isFinite(c[2])); }));
        var huge = noise(1000000, {density: 99, amplitude: 1000, verticalSpacing: 0.1}, 0.1);
        verify(dots(huge).length <= 16388);
        var zero = noise(0);
        verify(zero.commands.every(function(c) { return isFinite(c[1]) && isFinite(c[2]); }));
    }
    function test_only_guide_nodes_are_editable_and_anchored() {
        var a = noise(300, {density: 90}), markers = [];
        for (var i = 0; i <= 4; ++i) markers.push({x: i * 75, y: 0, row: "r", key: "0:0/1", numerator: i, denominator: 8, scale: 1});
        compare(V.handles(a).length, 2);
        var linked = V.autoAnchors(a, markers, 0);
        compare(linked.shape.commands.length, 5);
        compare(linked.bindings.length, 5);
        verify(dots(linked.shape).length > 100);
        verify(linked.bindings.every(function(b) { return b.command < 5; }));
        verify(V.isNoiseGuide(linked.shape));
        var sparse = V.autoAnchors(noise(300, {density: 1, amplitude: 100}), markers, 0);
        compare(JSON.stringify(sparse.shape.commands), JSON.stringify(linked.shape.commands));
        compare(JSON.stringify(sparse.bindings), JSON.stringify(linked.bindings));
    }
    function test_guide_deformation_and_curves_drive_the_pattern() {
        var a = noise(300, {amplitude: 0});
        a.commands = [["M",0,0],["C",80,100,220,100,300,0]];
        verify(dots(a).some(function(c) { return c[2] > 60; }));
        var original = JSON.stringify(a), curved = V.insertPoint(a, 1, 0.5);
        verify(V.isNoiseGuide(curved));
        var handles = V.handles(curved).filter(function(h) { return !h.control; });
        var middle = handles.filter(function(h) { return h.command === 1; })[0];
        var changed = V.deform(curved, middle, handles, 0, 20, 0.5);
        verify(V.isNoiseGuide(changed));
        compare(changed.wave.seed, a.wave.seed);
        compare(changed.style.width, a.style.width);
        verify(dots(changed).some(function(c) { return c[2] > 80; }));
        compare(JSON.stringify(a), original);
    }
    function test_legacy_dots_upgrade_to_one_guide() {
        var a = noise(300, {density: 90});
        a.commands = P.noiseCommands(a.wave, a.style.width);
        delete a.wave.guideVersion;
        verify(V.handles(a).length > 100);
        var restored = V.readDocument(V.document([a]))[0];
        compare(V.handles(restored).length, 2);
        verify(V.isNoiseGuide(restored));
        compare(restored.wave.seed, a.wave.seed);
        compare(JSON.stringify(dots(restored)), JSON.stringify(a.commands.slice(0, -2)));
    }
    function test_smooth_and_angular_nodes_keep_the_parametric_tool() {
        var a = V.insertPoint(noise(300), 1, 0.5);
        var editor = {shapes: [a], remember: function(){}, autoLink: function(){}, changed: function(){}};
        A.curvature(editor, {shape: 0, handle: {command: 1}}, true);
        verify(V.isNoiseGuide(editor.shapes[0]));
        compare(editor.shapes[0].commands[1][0], "C");
        A.curvature(editor, {shape: 0, handle: {command: 1}}, false);
        verify(V.isNoiseGuide(editor.shapes[0]));
        compare(editor.shapes[0].wave.seed, 42);
    }
}
