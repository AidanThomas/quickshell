import qs.config
import qs.components

import QtQuick
import QtQuick.Controls as Controls

DisclosurePopup {
    id: root

    required property date currentDate

    property var locale: Qt.locale()
    readonly property date today: new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate(), 12)
    property date selectedDate: new Date(today.getFullYear(), today.getMonth(), today.getDate(), 12)
    property int displayYear: selectedDate.getFullYear()
    property int displayMonth: selectedDate.getMonth()
    readonly property int firstDayOfWeek: locale.firstDayOfWeek % 7
    readonly property var calendarDays: buildCalendarDays(displayYear, displayMonth, firstDayOfWeek)

    implicitWidth: 416
    implicitHeight: 467
    originEdge: DisclosureGeometry.Bottom
    // Leave enough travel for the shared canopy to form a visible neck
    // between the compact clock island and the larger calendar body.
    // Align the visible canopy top with Hyprland's tiled-window top edge: the
    // reserved bar plus its outer gap. Hyprland draws the window border
    // outward from its reported geometry, so the outer border begins here.
    // The logical popup also accounts for the centred island and backing.
    surfaceGap: (Theme.topBarHeight - Theme.islandHeight) / 2
        + Theme.screenEdgeGap
        + Theme.canopyBackingMargin
    initialFocusTarget: previousMonthButton

    function sameDay(left, right): bool {
        return left.getFullYear() === right.getFullYear()
            && left.getMonth() === right.getMonth()
            && left.getDate() === right.getDate();
    }

    function buildCalendarDays(year, month, weekStart): var {
        const first = new Date(year, month, 1, 12);
        const offset = (first.getDay() - weekStart + 7) % 7;
        const days = [];

        for (let index = 0; index < 42; index++)
            days.push(new Date(year, month, index - offset + 1, 12));

        return days;
    }

    function weekdayLabel(index): string {
        const sunday = new Date(2023, 0, 1 + ((firstDayOfWeek + index) % 7), 12);
        return locale.toString(sunday, "ddd");
    }

    function showMonth(offset) {
        const next = new Date(displayYear, displayMonth + offset, 1, 12);
        displayYear = next.getFullYear();
        displayMonth = next.getMonth();
    }

    function showToday() {
        selectedDate = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 12);
        displayYear = selectedDate.getFullYear();
        displayMonth = selectedDate.getMonth();
    }

    function selectDate(value) {
        selectedDate = value;
        displayYear = value.getFullYear();
        displayMonth = value.getMonth();
    }

    DisclosureSurface {
        anchors.fill: parent
        geometry: root.geometry
        revealProgress: root.revealProgress
        originEdge: root.originEdge
        connected: false
        materialVisible: !root.canopyPresentationActive
        padding: 16

        TechnicalSurface {
            anchors.fill: parent
            // Fill the logical popup bounds. The frame-owned canopy extends
            // by Theme.islandGap, matching the spacing between bar pills.
            anchors.margins: -16
            fillColor: Theme.islandSurface
            outlineWidth: Theme.islandBorderWidth
            outlineColor: Theme.borderDefault
            // Nested corners reduce by the frame inset rather than becoming
            // rounder than their 14px outer container.
            radius: Math.max(0, Theme.popupRadius - Theme.canopyBackingMargin)
        }

        Column {
            anchors.fill: parent
            spacing: 8

            Item {
                width: parent.width
                height: 40

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                    width: parent.width - monthControls.width - x
                    spacing: -3

                    Text {
                        text: root.locale.toString(
                            new Date(root.displayYear, root.displayMonth, 1, 12),
                            "MMMM"
                        ).toUpperCase()
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.7
                    }

                    Text {
                        text: root.displayYear
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.letterSpacing: 0.8
                    }
                }

                Row {
                    id: monthControls
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 2

                    Controls.Button {
                        id: todayButton
                        width: 30
                        height: 28
                        focusPolicy: Qt.StrongFocus
                        hoverEnabled: true
                        Accessible.name: "Today"
                        Accessible.description: "Return to the current date"
                        onClicked: root.showToday()

                        background: Rectangle {
                            radius: 9
                            color: todayButton.down || todayButton.visualFocus
                                ? Theme.islandSurfaceActive
                                : (todayButton.hovered ? Theme.islandSurfaceHover : Theme.islandSurface)
                            border.width: 1
                            border.color: todayButton.visualFocus || todayButton.hovered
                                ? Theme.borderHover
                                : Theme.borderDefault
                        }

                        contentItem: Text {
                            text: ""
                            color: Theme.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 12
                        }

                        Controls.ToolTip.visible: todayButton.hovered
                        Controls.ToolTip.text: "Today"
                        Controls.ToolTip.delay: 650

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    IslandAction {
                        id: previousMonthButton
                        text: "Previous month"
                        iconText: "‹"
                        tooltipText: "Previous month"
                        onClicked: root.showMonth(-1)
                    }

                    IslandAction {
                        text: "Next month"
                        iconText: "›"
                        tooltipText: "Next month"
                        onClicked: root.showMonth(1)
                    }
                }
            }

            Grid {
                id: weekdayGrid
                width: parent.width
                columns: 7
                columnSpacing: 4

                readonly property real cellWidth: (width - columnSpacing * 6) / 7

                Repeater {
                    model: 7

                    Text {
                        required property int index

                        width: weekdayGrid.cellWidth
                        height: 18
                        text: root.weekdayLabel(index).toUpperCase()
                        color: Theme.textMuted
                        opacity: 0.76
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: 8
                        font.weight: Font.Medium
                        font.letterSpacing: 0.6
                    }
                }
            }

            Item {
                id: ledger
                width: parent.width
                height: 216

                Repeater {
                    model: 6

                    delegate: Item {
                        required property int index

                        x: 0
                        y: index * 36
                        width: ledger.width
                        height: 36

                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }
                            height: 1
                            color: Theme.borderSubtle
                            opacity: index === 5 ? 0 : 0.72
                        }
                    }
                }

                Grid {
                    id: dateGrid
                    anchors.fill: parent
                    columns: 7
                    columnSpacing: 4

                    readonly property real cellWidth: (width - columnSpacing * 6) / 7

                    Repeater {
                        id: dayRepeater
                        model: root.calendarDays

                        Controls.AbstractButton {
                            id: dayButton

                            required property var modelData
                            required property int index

                            readonly property bool inDisplayedMonth: modelData.getMonth() === root.displayMonth
                            readonly property bool isToday: root.sameDay(modelData, root.today)
                            readonly property bool isSelected: root.sameDay(modelData, root.selectedDate)
                            readonly property bool isPast: modelData < root.today

                            width: dateGrid.cellWidth
                            height: 36
                            focusPolicy: Qt.StrongFocus
                            hoverEnabled: true
                            Accessible.name: root.locale.toString(modelData, "dddd, d MMMM yyyy")
                            Accessible.selected: isSelected

                            onClicked: root.selectDate(modelData)

                            background: Item {
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 34
                                    height: 28
                                    radius: 4
                                    color: dayButton.isSelected
                                        ? Theme.popupSurfaceRaised
                                        : (dayButton.hovered ? Theme.islandSurfaceHover : "transparent")
                                    border.width: dayButton.visualFocus
                                        || dayButton.isSelected
                                        || dayButton.hovered ? 1 : 0
                                    border.color: dayButton.visualFocus
                                        ? Theme.borderHover
                                        : (dayButton.isSelected ? Theme.borderDefault : Theme.borderSubtle)

                                    Rectangle {
                                        anchors {
                                            top: parent.top
                                            topMargin: 1
                                            horizontalCenter: parent.horizontalCenter
                                        }
                                        width: 20
                                        height: 1
                                        color: Theme.glassEdgeHighlight
                                        opacity: 0.45
                                        visible: dayButton.isSelected
                                    }
                                }
                            }

                            contentItem: Item {
                                Text {
                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        topMargin: 3
                                        leftMargin: 4
                                    }
                                    text: "✓"
                                    visible: dayButton.isPast
                                    color: Theme.textMuted
                                    opacity: 0.38
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 7
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: dayButton.modelData.getDate()
                                    color: dayButton.isSelected
                                        ? Theme.textPrimary
                                        : (dayButton.inDisplayedMonth ? Theme.textPrimary : Theme.textMuted)
                                    opacity: dayButton.inDisplayedMonth ? 1 : 0.42
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    font.weight: dayButton.isSelected ? Font.DemiBold : Font.Normal
                                }

                                Rectangle {
                                    anchors {
                                        horizontalCenter: parent.horizontalCenter
                                        bottom: parent.bottom
                                        bottomMargin: 3
                                    }
                                    width: 10
                                    height: 2
                                    radius: 1
                                    color: Theme.accentCyan
                                    visible: dayButton.isToday
                                }
                            }

                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }

                            Keys.onPressed: event => {
                                let target = dayButton.index;
                                if (event.key === Qt.Key_Left)
                                    target -= 1;
                                else if (event.key === Qt.Key_Right)
                                    target += 1;
                                else if (event.key === Qt.Key_Up)
                                    target -= 7;
                                else if (event.key === Qt.Key_Down)
                                    target += 7;
                                else if (event.key === Qt.Key_Home)
                                    target -= target % 7;
                                else if (event.key === Qt.Key_End)
                                    target += 6 - (target % 7);
                                else
                                    return;

                                const destination = dayRepeater.itemAt(Math.max(0, Math.min(41, target)));
                                if (destination)
                                    destination.forceActiveFocus(Qt.TabFocusReason);
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.borderSubtle
                opacity: 0.72
            }

            LocalForecast {
                width: parent.width
                animationsEnabled: root.revealProgress > 0
            }
        }
    }
}
