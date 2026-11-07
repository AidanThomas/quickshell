import qs.components
import qs.config

import QtQuick
import Quickshell

ShellRoot {
    id: test

    function fail(message: string): void {
        console.error("DISCLOSURE_RESILIENCE_FAIL: " + message);
        Qt.exit(1);
    }

    function openPrimary(): void {
        if (!primary.requestOpen(DisclosureLifecycle.ProgrammaticInput))
            fail("primary disclosure rejected a valid open request at stage " + state.stage);
    }

    QtObject {
        id: state

        property int stage: 0
        property rect initialOriginRect: Qt.rect(0, 0, 0, 0)
        property rect initialConnectorRect: Qt.rect(0, 0, 0, 0)
    }

    PanelWindow {
        id: host

        anchors {
            top: true
            left: true
        }

        implicitWidth: 420
        implicitHeight: 180
        color: "transparent"
        focusable: true

        Item {
            id: primaryOrigin

            x: 40
            y: 20
            width: 100
            height: 32
        }

        Item {
            id: secondaryOrigin

            x: 260
            y: 20
            width: 100
            height: 32
        }

        DisclosurePopup {
            id: primary

            origin: primaryOrigin
            implicitWidth: 260
            implicitHeight: 140
            clickAwayEnabled: true
            lifecycle.transitionDuration: 160

            Rectangle {
                anchors.fill: parent
                color: "#333333"
            }

            lifecycle.onOpened: {
                if (state.stage === 1) {
                    if (!primary.visible || !primary.interactionEnabled)
                        test.fail("rapid reversal did not settle open and interactive");

                    state.stage = 2;
                    primary.requestClose(DisclosureLifecycle.Programmatic);
                    replacementTimer.start();
                } else if (state.stage === 3) {
                    if (secondary.lifecycle.requestedOpen)
                        test.fail("primary did not replace the secondary panel");

                    state.stage = 4;
                    primaryOrigin.visible = false;
                } else if (state.stage === 5) {
                    state.stage = 6;
                    primary.originAvailable = false;
                } else if (state.stage === 7) {
                    if (!primary.geometry.valid)
                        test.fail("geometry was invalid before the layout change");

                    state.initialOriginRect = primary.geometry.originGlobalRect;
                    state.initialConnectorRect = primary.geometry.connectorRect;
                    primary.geometry.availableGeometry = Qt.rect(0, 0, 640, 360);
                    primaryOrigin.x = 310;
                    primaryOrigin.y = 110;
                    primaryOrigin.width = 80;
                    geometryTimer.start();
                }
            }

            lifecycle.onClosed: reason => {
                if (state.stage === 4) {
                    if (reason !== DisclosureLifecycle.OriginUnavailable)
                        test.fail("hidden origin used the wrong dismissal reason");

                    primaryOrigin.visible = true;
                    state.stage = 5;
                    Qt.callLater(test.openPrimary);
                } else if (state.stage === 6) {
                    if (reason !== DisclosureLifecycle.OriginUnavailable)
                        test.fail("service loss used the wrong dismissal reason");

                    primary.originAvailable = true;
                    state.stage = 7;
                    Qt.callLater(test.openPrimary);
                } else if (state.stage === 8) {
                    if (reason !== DisclosureLifecycle.Programmatic || primary.revealProgress !== 0 || primary.visible || primary.effectiveOpen || primary.mask.item !== null || secondary.visible || secondary.mask.item !== null)
                        test.fail("mid-transition reduced-motion close did not reach a clean endpoint");

                    console.log("DISCLOSURE_RESILIENCE_PASS");
                    Qt.quit();
                }
            }
        }

        DisclosurePanel {
            id: secondary

            origin: secondaryOrigin
            implicitWidth: 220
            implicitHeight: 150
            clickAwayEnabled: true
            lifecycle.transitionDuration: 160

            anchors {
                top: true
                right: true
            }

            Rectangle {
                anchors.fill: parent
                color: "#444444"
            }

            lifecycle.onOpened: {
                if (state.stage !== 2)
                    return;
                if (primary.lifecycle.requestedOpen)
                    test.fail("secondary panel did not replace the closing popup");

                state.stage = 3;
                test.openPrimary();
            }
        }

        Timer {
            interval: 50
            running: true
            onTriggered: {
                state.stage = 1;
                test.openPrimary();
                rapidCloseOne.start();
            }
        }

        Timer {
            id: rapidCloseOne

            interval: 20
            onTriggered: {
                primary.requestClose(DisclosureLifecycle.OriginToggle, DisclosureLifecycle.Pointer);
                rapidOpenOne.start();
            }
        }

        Timer {
            id: rapidOpenOne

            interval: 20
            onTriggered: {
                test.openPrimary();
                rapidCloseTwo.start();
            }
        }

        Timer {
            id: rapidCloseTwo

            interval: 20
            onTriggered: {
                primary.requestClose(DisclosureLifecycle.OriginToggle, DisclosureLifecycle.Pointer);
                rapidOpenTwo.start();
            }
        }

        Timer {
            id: rapidOpenTwo

            interval: 20
            onTriggered: test.openPrimary()
        }

        Timer {
            id: replacementTimer

            interval: 25
            onTriggered: {
                if (!secondary.requestOpen(DisclosureLifecycle.Keyboard))
                    test.fail("secondary panel rejected its replacement open");
            }
        }

        Timer {
            id: geometryTimer

            interval: 80
            onTriggered: {
                const surface = primary.geometry.surfaceRect;
                const originRect = primary.geometry.originGlobalRect;
                const connectorRect = primary.geometry.connectorRect;
                const originChanged = originRect.x !== state.initialOriginRect.x || originRect.y !== state.initialOriginRect.y || originRect.width !== state.initialOriginRect.width || originRect.height !== state.initialOriginRect.height;
                const connectorChanged = connectorRect.x !== state.initialConnectorRect.x || connectorRect.y !== state.initialConnectorRect.y;
                if (!primary.geometry.valid || !originChanged || !connectorChanged)
                    test.fail("geometry did not respond to origin layout changes");
                if (surface.x < 8 || surface.y < 8 || surface.x + surface.width > 632 || surface.y + surface.height > 352)
                    test.fail("surface escaped the simulated monitor bounds");

                state.stage = 8;
                primary.requestClose(DisclosureLifecycle.Programmatic);
                reducedMotionTimer.start();
            }
        }

        Timer {
            id: reducedMotionTimer

            interval: 40
            onTriggered: {
                if (primary.lifecycle.lifecycleState !== DisclosureLifecycle.Closing || primary.revealProgress <= 0 || primary.revealProgress >= 1)
                    test.fail("close was not in flight before enabling reduced motion");

                MotionPreferences.reducedMotion = true;
            }
        }

        Timer {
            interval: 5000
            running: true
            onTriggered: test.fail("test timed out at stage " + state.stage)
        }
    }
}
