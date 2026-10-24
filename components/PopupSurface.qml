import qs.config

import QtQuick

Item {
    id: root

    default property alias content: contentContainer.data

    property int padding: 16
    property bool connected: true
    property color accentColor: Theme.accentCyan

    TechnicalSurface {
        anchors.fill: parent
        cutSize: Theme.surfaceCutSize
        fillColor: Theme.popupSurface
        outlineWidth: Theme.islandBorderWidth
        outlineColor: Theme.borderHover
        radius: Theme.popupRadius
    }

    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.margins: root.padding
    }

    Rectangle {
        visible: root.connected
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.top
        }
        width: 28
        height: 4
        color: root.accentColor
        radius: 2
    }
}
