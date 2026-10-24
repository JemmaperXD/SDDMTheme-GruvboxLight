import QtQuick 2.15
import "Tokens.js" as T

Item {
    id: field
    property real s: 1
    property alias text: input.text
    property bool hasError: false
    property real caretX: 0
    property string hint: "\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022"
    signal accepted()
    signal edited()

    implicitHeight: Math.round(37 * s)

    function forceFocus() { input.forceActiveFocus(); }
    function clear() { input.text = ""; }
    function syncCaret() {
        var r = input.positionToRectangle(input.cursorPosition);
        field.caretX = Math.max(0, Math.min(r.x, Math.max(0, input.width - Math.round(10 * field.s))));
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.bottomMargin: Math.round(2 * s)
        verticalAlignment: TextInput.AlignVCenter
        echoMode: TextInput.Password
        passwordCharacter: "\u2022"
        passwordMaskDelay: 0
        color: T.fg1
        selectionColor: T.bg2
        selectedTextColor: T.fg1
        font.family: T.mono
        font.pixelSize: Math.round(14 * s)
        font.letterSpacing: Math.round(3.6 * s)
        cursorVisible: activeFocus
        onAccepted: field.accepted()
        onTextEdited: {
            field.syncCaret();
            field.edited();
            caretPulse.start();
        }
        onCursorPositionChanged: field.syncCaret()
        onActiveFocusChanged: if (activeFocus) field.syncCaret()
    }

    Text {
        anchors.verticalCenter: input.verticalCenter
        anchors.verticalCenterOffset: Math.round(-0.5 * s)
        visible: opacity > 0
        text: field.hint
        color: T.gray
        opacity: input.text.length === 0 ? (input.activeFocus ? 0.28 : 0.55) : 0
        font.family: T.mono
        font.pixelSize: Math.round(14 * s)
        font.letterSpacing: Math.round(3.6 * s)
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: field.hasError ? Qt.rgba(0.616, 0.0, 0.024, 0.55)
                              : Qt.rgba(0.235, 0.220, 0.212, 0.26)
    }

    Rectangle {
        id: caretMark
        x: field.caretX
        anchors.bottom: parent.bottom
        width: Math.round(9 * s)
        height: Math.round(3 * s)
        color: T.red
        opacity: input.activeFocus && input.text.length > 0 ? 1 : 0
        visible: opacity > 0
        transformOrigin: Item.Bottom
        Behavior on x { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 160 } }
        SequentialAnimation {
            id: caretPulse
            NumberAnimation { target: caretMark; property: "scale"; to: 1.9; duration: 70; easing.type: Easing.OutQuad }
            NumberAnimation { target: caretMark; property: "scale"; to: 1.0; duration: 160; easing.type: Easing.OutCubic }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: Math.round(2 * s)
        width: (input.activeFocus || field.hasError) ? parent.width : 0
        color: field.hasError ? T.red : Qt.rgba(0.235, 0.220, 0.212, 0.55)
        Behavior on width { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 200 } }
    }
}
