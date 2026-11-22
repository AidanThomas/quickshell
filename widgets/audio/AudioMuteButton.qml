import qs.config
import qs.components

import QtQuick

IslandAction {
    id: root

    required property bool muted

    property string activeIconName: "audio.volumeHigh"
    property string mutedIconName: "audio.muted"

    signal muteRequested

    text: muted ? "Unmute" : "Mute"
    tooltipText: text
    iconName: muted ? mutedIconName : activeIconName
    iconColor: muted ? Theme.accentAmber : Theme.textPrimary
    onClicked: root.muteRequested()
}
