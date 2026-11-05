import qs.config

import QtQuick

Item {
    id: root

    default property alias content: contentContainer.data

    property var geometry: null
    property real revealProgress: 1
    property int originEdge: geometry?.originEdge ?? DisclosureGeometry.Bottom
    property int padding: 16
    property bool connected: true
    property color accentColor: Theme.accentCyan

    readonly property real progress: Math.max(0, Math.min(1, revealProgress))
    readonly property rect revealRect: root.revealRectForProgress(progress, originEdge)
    readonly property rect connectorRect: root.connectorRectForGeometry()

    function revealRectForProgress(value: real, edge: int): rect {
        if (edge === DisclosureGeometry.Top) {
            const revealedHeight = root.height * value;
            return Qt.rect(0, root.height - revealedHeight, root.width, revealedHeight);
        }
        if (edge === DisclosureGeometry.Right)
            return Qt.rect(0, 0, root.width * value, root.height);
        if (edge === DisclosureGeometry.Left) {
            const revealedWidth = root.width * value;
            return Qt.rect(root.width - revealedWidth, 0, revealedWidth, root.height);
        }

        return Qt.rect(0, 0, root.width, root.height * value);
    }

    function connectorRectForGeometry(): rect {
        if (!root.geometry?.valid)
            return Qt.rect(0, 0, 0, 0);

        const source = root.geometry.connectorRect;
        if (root.originEdge === DisclosureGeometry.Top)
            return Qt.rect(source.x, Math.max(0, root.height - source.height), source.width, source.height);
        if (root.originEdge === DisclosureGeometry.Right)
            return Qt.rect(0, source.y, source.width, source.height);
        if (root.originEdge === DisclosureGeometry.Left)
            return Qt.rect(Math.max(0, root.width - source.width), source.y, source.width, source.height);

        return Qt.rect(source.x, 0, source.width, source.height);
    }

    Item {
        id: revealViewport

        x: root.revealRect.x
        y: root.revealRect.y
        width: root.revealRect.width
        height: root.revealRect.height
        clip: true

        Item {
            id: surfaceLayer

            x: -revealViewport.x
            y: -revealViewport.y
            width: root.width
            height: root.height
            opacity: root.progress

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
        }
    }

    // Keep the connector inside this compositor surface. It shares the edge
    // with the glass layer instead of adding a second overlapping glass window.
    Rectangle {
        x: root.connectorRect.x
        y: root.connectorRect.y
        width: root.connectorRect.width
        height: root.connectorRect.height
        visible: root.connected && root.geometry?.valid && root.progress > 0
        color: root.accentColor
        radius: Math.min(width, height) / 2
        opacity: root.progress
    }
}
