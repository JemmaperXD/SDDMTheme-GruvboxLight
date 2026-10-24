import QtQuick 2.15
import "components"
import "components/Tokens.js" as T

Rectangle {
    id: root

    width: Screen.width
    height: Screen.height
    color: T.bg0

    property real u: Math.max(0.62, Math.min(width / 1366.0, height / 768.0))
    property var now: new Date()

    property int sessionIndex: Math.max(0, sessionModel.lastIndex)
    property bool sessionMenuOpen: false
    property bool loggingIn: false
    property string notice: ""
    property bool noticeIsError: false
    property real shake: 0

    property string hostLabel: String(sddm.hostName || "").toLowerCase()

    property string userName: {
        if (userModel.count <= 0)
            return "guest";
        var i = userModel.lastIndex;
        if (i < 0)
            i = 0;
        return String(userModel.data(userModel.index(i, 0), 257));
    }

    function sessionName(i) {
        if (i < 0 || i >= sessionModel.count)
            return "session";
        return String(sessionModel.data(sessionModel.index(i, 0), 260));
    }

    function submit() {
        if (root.loggingIn)
            return;
        if (pw.text.length === 0) {
            root.notice = "PASSPHRASE REQUIRED";
            root.noticeIsError = true;
            shakeAnim.start();
            pw.forceFocus();
            return;
        }
        root.notice = "";
        root.noticeIsError = false;
        root.loggingIn = true;
        sddm.login(root.userName, pw.text, root.sessionIndex);
    }

    function fail(text) {
        root.loggingIn = false;
        root.notice = text;
        root.noticeIsError = true;
        pw.clear();
        shakeAnim.start();
        pw.forceFocus();
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Timer {
        interval: 20000
        running: root.loggingIn
        repeat: false
        onTriggered: root.fail("AUTHENTICATION TIMED OUT")
    }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            root.loggingIn = false;
        }

        function onLoginFailed() {
            root.fail("INCORRECT PASSPHRASE");
        }

        function onInformationMessage(message) {
            root.fail(String(message).toUpperCase());
        }
    }

    // ---------------------------------------------------------------- backdrop

    Image {
        id: wallpaper
        anchors.fill: parent
        source: (config.background && config.background.length > 0) ? config.background : "background.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        smooth: true
        mipmap: true
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 900; easing.type: Easing.OutCubic } }

        Component.onCompleted: wallpaper.opacity = 1
    }

    // Mist rolling in from the left, so the login block sits on "paper" while
    // the ink drawing stays untouched on the right.
    Rectangle {
        width: parent.width * 0.58
        height: parent.height
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.00; color: "#f7f0e1b8" }
            GradientStop { position: 0.48; color: "#dcf0e1b8" }
            GradientStop { position: 0.80; color: "#47f0e1b8" }
            GradientStop { position: 1.00; color: "#00f0e1b8" }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.sessionMenuOpen = false;
            pw.forceFocus();
        }
    }

    // ------------------------------------------------------------------- clock

    Item {
        id: clockBlock
        x: Math.round(76 * root.u)
        y: Math.round(root.height * 0.075)
        opacity: 0

        Column {
            spacing: 0

            Text {
                text: Qt.formatTime(root.now, "HH:mm")
                color: T.fg1
                font.family: T.serif
                font.pixelSize: Math.round(78 * root.u)
                font.letterSpacing: Math.round(-1.5 * root.u)
                opacity: 0.92
            }

            Item {
                height: Math.round(24 * root.u)
                width: metaRow.implicitWidth

                Row {
                    id: metaRow
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: Math.round(-3 * root.u)
                    spacing: Math.round(9 * root.u)

                    Rectangle {
                        width: Math.round(5 * root.u)
                        height: width
                        radius: width / 2
                        color: T.red
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatDate(root.now, "dddd \u00b7 d MMMM").toUpperCase()
                        color: T.fg3
                        font.family: T.mono
                        font.pixelSize: Math.round(8.5 * root.u)
                        font.letterSpacing: Math.round(2.6 * root.u)
                    }

                    Text {
                        visible: root.hostLabel.length > 0
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\u00b7"
                        color: T.gray
                        font.family: T.mono
                        font.pixelSize: Math.round(8.5 * root.u)
                        opacity: 0.7
                    }

                    Text {
                        visible: root.hostLabel.length > 0
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.hostLabel
                        color: T.gray
                        font.family: T.mono
                        font.pixelSize: Math.round(8.5 * root.u)
                        font.letterSpacing: Math.round(2.2 * root.u)
                        opacity: 0.75
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------------- login

    Item {
        id: login
        x: Math.round(76 * root.u)
        y: Math.round(root.height * 0.455)
        width: Math.round(342 * root.u)
        height: content.implicitHeight
        opacity: 0

        transform: Translate { id: loginShift; x: root.shake; y: Math.round(14 * root.u) }

        Column {
            id: content
            width: parent.width
            spacing: 0

            Item {
                width: parent.width
                height: Math.round(50 * root.u)

                Seal {
                    s: root.u
                    letter: root.userName.charAt(0)
                    anchors.verticalCenter: parent.verticalCenter
                    x: 0
                }

                Column {
                    x: Math.round(49 * root.u)
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - x
                    spacing: Math.round(1 * root.u)

                    Text {
                        text: "WELCOME"
                        color: T.fg3
                        font.family: T.mono
                        font.pixelSize: Math.round(7.2 * root.u)
                        font.letterSpacing: Math.round(3.0 * root.u)
                    }

                    Text {
                        width: parent.width
                        text: root.userName
                        color: T.fg0
                        elide: Text.ElideRight
                        font.family: T.serif
                        font.pixelSize: Math.round(27 * root.u)
                    }
                }
            }

            Item { width: 1; height: Math.round(31 * root.u) }

            Text {
                text: "PASSPHRASE"
                color: T.fg3
                font.family: T.mono
                font.pixelSize: Math.round(7.6 * root.u)
                font.letterSpacing: Math.round(2.8 * root.u)
            }

            Item { width: 1; height: Math.round(9 * root.u) }

            PasswordField {
                id: pw
                width: parent.width
                s: root.u
                hasError: root.noticeIsError

                onAccepted: root.submit()
                onEdited: {
                    if (root.noticeIsError) {
                        root.notice = "";
                        root.noticeIsError = false;
                    }
                }
            }

            Text {
                width: parent.width
                height: Math.round(24 * root.u)
                verticalAlignment: Text.AlignVCenter
                text: root.notice.length > 0 ? root.notice : "PRESS ENTER TO UNLOCK"
                color: root.noticeIsError ? T.red : T.fg3
                opacity: root.noticeIsError ? 1.0 : 0.8
                elide: Text.ElideRight
                font.family: T.mono
                font.pixelSize: Math.round(7.6 * root.u)
                font.letterSpacing: Math.round(2.2 * root.u)
                Behavior on opacity { NumberAnimation { duration: 180 } }
            }

            InkButton {
                width: parent.width
                s: root.u
                label: root.loggingIn ? "CHECKING" : "UNLOCK"
                active: !root.loggingIn
                onClicked: root.submit()
            }

            Item { width: 1; height: Math.round(17 * root.u) }

            Item {
                id: footer
                width: parent.width
                height: Math.round(24 * root.u)

                Item {
                    id: sessionTrigger
                    width: triggerRow.implicitWidth
                    height: parent.height
                    anchors.left: parent.left

                    Row {
                        id: triggerRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Math.round(7 * root.u)

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "SESSION"
                            color: T.fg3
                            font.family: T.mono
                            font.pixelSize: Math.round(7.2 * root.u)
                            font.letterSpacing: Math.round(2.2 * root.u)
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.sessionName(root.sessionIndex)
                            color: T.fg1
                            font.family: T.mono
                            font.pixelSize: Math.round(8.2 * root.u)
                            font.letterSpacing: Math.round(0.8 * root.u)
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "\u25be"
                            color: T.fg3
                            font.family: T.sans
                            font.pixelSize: Math.round(9 * root.u)
                            rotation: root.sessionMenuOpen ? 180 : 0
                            Behavior on rotation { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: T.fg1
                        opacity: triggerMouse.containsMouse || root.sessionMenuOpen ? 0.35 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    MouseArea {
                        id: triggerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.sessionMenuOpen = !root.sessionMenuOpen
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Math.round(12 * root.u)

                    IconButton {
                        s: root.u
                        glyph: "\uf011"
                        visible: sddm.canPowerOff
                        onClicked: sddm.powerOff()
                    }

                    IconButton {
                        s: root.u
                        glyph: "\uf021"
                        visible: sddm.canReboot
                        onClicked: sddm.reboot()
                    }

                    IconButton {
                        s: root.u
                        glyph: "\uf186"
                        visible: sddm.canSuspend
                        onClicked: sddm.suspend()
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------------- tile menu

    MouseArea {
        anchors.fill: parent
        visible: root.sessionMenuOpen
        z: 10
        onClicked: {
            root.sessionMenuOpen = false;
            pw.forceFocus();
        }
    }

    Rectangle {
        id: sessionMenu
        x: login.x
        y: {
            var desired = login.y + footer.y + footer.height + Math.round(9 * root.u);
            var limit = root.height - height - Math.round(18 * root.u);
            return Math.min(desired, limit);
        }
        width: Math.round(216 * root.u)
        height: Math.min(Math.round(sessionModel.count * 31 * root.u) + Math.round(8 * root.u), Math.round(260 * root.u))
        visible: root.sessionMenuOpen
        opacity: root.sessionMenuOpen ? 1 : 0
        z: 20
        color: T.bg0
        radius: Math.round(2 * root.u)
        border.width: 1
        border.color: Qt.rgba(0.235, 0.220, 0.212, 0.24)

        Behavior on opacity {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }

        ListView {
            anchors.fill: parent
            anchors.margins: Math.round(4 * root.u)
            model: sessionModel
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: menuRow
                width: ListView.view.width
                height: Math.round(31 * root.u)
                radius: Math.round(1 * root.u)
                color: index === root.sessionIndex ? Qt.rgba(0.922, 0.859, 0.698, 0.75)
                                                   : (rowMouse.containsMouse ? T.bg1 : "transparent")

                Rectangle {
                    visible: index === root.sessionIndex
                    width: Math.round(4 * root.u)
                    height: width
                    radius: width / 2
                    color: T.red
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(7 * root.u)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(19 * root.u)
                    anchors.right: parent.right
                    anchors.rightMargin: Math.round(8 * root.u)
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.sessionName(index)
                    color: T.fg1
                    elide: Text.ElideRight
                    font.family: T.mono
                    font.pixelSize: Math.round(8.4 * root.u)
                    font.letterSpacing: Math.round(0.6 * root.u)
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.sessionIndex = index;
                        root.sessionMenuOpen = false;
                        pw.forceFocus();
                    }
                }
            }
        }
    }

    // --------------------------------------------------------------- signature

    Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: Math.round(22 * root.u)
        anchors.bottomMargin: Math.round(15 * root.u)
        text: root.hostLabel.toUpperCase()
        color: T.fg3
        font.family: T.mono
        font.pixelSize: Math.round(7.2 * root.u)
        font.letterSpacing: Math.round(2.8 * root.u)
        opacity: 0.5
    }

    // -------------------------------------------------------------- animations

    ParallelAnimation {
        id: intro
        NumberAnimation {
            target: clockBlock
            property: "opacity"
            from: 0; to: 1
            duration: 900
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: login
            property: "opacity"
            from: 0; to: 1
            duration: 700
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: loginShift
            property: "y"
            from: Math.round(14 * root.u); to: 0
            duration: 750
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: root; property: "shake"; to: Math.round(-5 * root.u); duration: 45 }
        NumberAnimation { target: root; property: "shake"; to: Math.round(5 * root.u); duration: 55 }
        NumberAnimation { target: root; property: "shake"; to: Math.round(-3 * root.u); duration: 55 }
        NumberAnimation { target: root; property: "shake"; to: Math.round(3 * root.u); duration: 55 }
        NumberAnimation { target: root; property: "shake"; to: 0; duration: 60 }
    }

    Component.onCompleted: {
        intro.start();
        pw.forceFocus();
    }

}
