import qs.config
import qs.widgets.power

import QtQuick

Item {
    id: root

    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    Text {
        id: icon
        text: ""
        color: Theme.text
        font.pixelSize: 18
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: powerMenu.toggle()
    }

    PowerMenu {
        id: powerMenu
    }
}
