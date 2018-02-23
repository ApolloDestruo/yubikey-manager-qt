import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: applicationWindow
    visible: true
    title: qsTr("YubiKey Manager")
    width: 640
    height: 400
    property var device: yk
    Material.primary: "#9aca3c"
    Material.accent: "#284c61"

    //Material.theme: Material.Dark
    function enableLogging(logLevel) {
        yk.enableLogging(logLevel, null)
    }
    function enableLoggingToFile(logLevel, logFile) {
        yk.enableLogging(logLevel, logFile)
    }
    function disableLogging() {
        yk.disableLogging()
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("‹")
                onClicked: stack.pop()
            }
            Label {
                text: "YubiKey Manager"
                Material.foreground: "white"
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                text: qsTr("⋮")
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        /*
        Item {
            id: item1
            Layout.minimumHeight: 50
            Layout.maximumHeight: 50
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: 50
            Image {
                id: logo
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.left: parent.left
                anchors.leftMargin: 12
                sourceSize.height: 50
                source: "images/logo.png"
            }
        }*/
        RowLayout {
            spacing: 5
            Layout.preferredHeight: 350
            Layout.fillHeight: false
            ColumnLayout {
                x: 0
                Layout.minimumWidth: 130
                Layout.columnSpan: 1
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Button {
                    x: 0
                    text: qsTr("HOME")
                    highlighted: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: false
                    flat: true
                    onClicked: {
                        stack.clear()
                        stack.push(deviceInfoView)
                    }
                }
                Button {
                    text: qsTr("YUBIKEY SLOTS")
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    flat: true
                    onClicked: {
                        stack.clear()
                        stack.push(slotView)
                    }
                }
                Button {
                    x: 0
                    text: qsTr("FIDO 2")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    flat: true
                    onClicked: {
                        stack.clear()
                        stack.push(fido2View)
                    }
                }
                Button {
                    x: 0
                    text: "CONNECTIONS"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    flat: true
                    onClicked: {
                        stack.clear()
                        stack.replace(connectionsView)
                    }
                }
            }

            ColumnLayout {
                id: hello
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                StackView {
                    id: stack
                    initialItem: deviceInfoView
                    Component {
                        id: deviceInfoView
                        DeviceInfoView {
                        }
                    }
                    Component {
                        id: slotView
                        SlotView {
                        }
                    }
                    Component {
                        id: fido2View
                        Fido2View {
                        }
                    }
                    Component {
                        id: connectionsView
                        ConnectionsView {
                        }
                    }
                }
            }
        }
    }

    // @disable-check M301
    YubiKey {
        id: yk
        onError: console.log(traceback)
    }
    Timer {
        id: timer
        triggeredOnStart: true
        interval: 500
        repeat: true
        running: true
        onTriggered: yk.refresh()
    }
}
