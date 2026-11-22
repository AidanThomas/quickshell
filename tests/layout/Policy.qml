import qs.config

import QtQuick
import Quickshell

ShellRoot {
    id: test

    function require(condition: bool, message: string): void {
        if (condition)
            return;

        console.error("LAYOUT_POLICY_FAIL: " + message);
        Qt.exit(1);
    }

    QtObject {
        id: originScreen
        property string name: "origin"
        property int x: 0
        property int y: 0
    }

    QtObject {
        id: rotatedScreen
        property string name: "rotated"
        property int x: 2560
        property int y: -820
    }

    Component.onCompleted: {
        require(LayoutPolicy.modeForWidth(799) === LayoutPolicy.Minimum, "sub-baseline width did not use the minimum fallback");
        require(LayoutPolicy.modeForWidth(800) === LayoutPolicy.Minimum, "800px baseline did not use the minimum layout");
        require(LayoutPolicy.modeForWidth(960) === LayoutPolicy.Compact, "compact breakpoint was not inclusive");
        require(LayoutPolicy.modeForWidth(1279) === LayoutPolicy.Compact, "compact profile ended early");
        require(LayoutPolicy.modeForWidth(1280) === LayoutPolicy.Full, "full breakpoint was not inclusive");
        require(LayoutPolicy.modeForWidth(3840) === LayoutPolicy.Full, "maximum supported width did not retain the full layout");

        const screens = [rotatedScreen, originScreen];
        require(LayoutPolicy.primaryScreens(screens)[0] === originScreen, "compositor origin did not select the primary screen");
        require(LayoutPolicy.secondaryScreens(screens).length === 1, "secondary screen count was incorrect");
        require(LayoutPolicy.secondaryScreens(screens)[0] === rotatedScreen, "rotated output was not retained as a secondary");
        require(LayoutPolicy.primaryScreens([]).length === 0, "empty screen model produced a primary");

        console.info("LAYOUT_POLICY_PASS");
        Qt.exit(0);
    }
}
