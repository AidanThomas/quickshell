pragma Singleton

import QtQuick

QtObject {
    id: root

    property bool hostAvailable: false
    property var presenter: null

    function claim(candidate): void {
        if (candidate && candidate.canopyPresentationActive)
            root.presenter = candidate;
    }

    function release(candidate): void {
        if (root.presenter === candidate)
            root.presenter = null;
    }
}
