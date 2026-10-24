import QtQuick 2.15
import "Tokens.js" as T

Rectangle {
    id: seal
    property real s: 1
    property string letter: "j"

    width: Math.round(34 * s)
    height: width
    radius: Math.round(2 * s)
    color: T.red

    transformOrigin: Item.Center

    Component.onCompleted: stamp.start()

    SequentialAnimation {
        id: stamp
        NumberAnimation {
            target: seal
            property: "scale"
            from: 1.22; to: 1.0
            duration: 460
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: Math.round(2.5 * s)
        radius: Math.round(1 * s)
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(0.984, 0.945, 0.780, 0.38)
    }

    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: Math.round(1 * s)
        text: seal.letter.toUpperCase()
        color: T.bg0
        font.family: T.serif
        font.pixelSize: Math.round(19 * s)
    }
}
