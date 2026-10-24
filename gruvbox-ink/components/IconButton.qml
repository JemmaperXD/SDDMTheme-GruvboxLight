import QtQuick 2.15
import "Tokens.js" as T

Item {
    id: btn
    property real s: 1
    property string glyph: "\uf011"
    signal clicked()

    width: Math.round(24 * s)
    height: Math.round(24 * s)

    FontLoader {
        id: faSolid
        source: "../fonts/FontAwesome6FreeSolid.otf"
    }

    Text {
        anchors.centerIn: parent
        text: btn.glyph
        color: btnMouse.containsMouse ? T.red : T.fg2
        opacity: btnMouse.containsMouse ? 1.0 : 0.92
        font.family: faSolid.name
        font.weight: Font.Black
        font.pixelSize: Math.round(14 * s)
        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
        id: btnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
