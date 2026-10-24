import QtQuick 2.15
import "Tokens.js" as T

Item {
    id: btn
    property real s: 1
    property string label: "UNLOCK"
    property string trailing: "\u2192"
    property bool active: true
    signal clicked()

    implicitHeight: Math.round(44 * s)
    scale: ma.pressed ? 0.994 : 1.0
    Behavior on scale { NumberAnimation { duration: 90 } }

    Rectangle {
        id: plate
        anchors.fill: parent
        radius: Math.round(2 * s)
        color: ma.pressed ? T.fg0 : (ma.containsMouse ? T.fg2 : T.fg1)
        opacity: btn.active ? 1 : 0.45
        Behavior on color { ColorAnimation { duration: 160 } }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#ffffff"
            opacity: 0.07
        }

        Text {
            id: caption
            anchors.left: parent.left
            anchors.leftMargin: Math.round(17 * s)
            anchors.verticalCenter: parent.verticalCenter
            text: btn.label
            color: T.bg0
            font.family: T.mono
            font.pixelSize: Math.round(10.5 * s)
            font.letterSpacing: Math.round(2.4 * s)
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: Math.round(17 * s)
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: Math.round(-0.5 * s)
            text: btn.trailing
            color: T.bg0
            opacity: 0.75
            font.family: T.sans
            font.pixelSize: Math.round(15 * s)
            x: ma.containsMouse && btn.active ? Math.round(-3 * s) : 0
            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: btn.active ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (btn.active) btn.clicked()
    }
}
