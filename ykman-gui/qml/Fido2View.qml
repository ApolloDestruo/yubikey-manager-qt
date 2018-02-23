import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.3

Pane {
    height: 200
    padding: 14
    ColumnLayout {
        anchors.fill: parent
        Label {
            text: qsTr("FIDO 2")
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            font.bold: true
        }
        Label {
            text: qsTr("PIN is set, 8 retries left")
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        }
        RowLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            Button {
                id: setPinBtn
                text: qsTr("Set PIN")
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                onClicked: stack.push(setPinView)
            }
            Button {
                id: resetBtn
                text: qsTr("Reset")
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            }
        }
    }
    Component {
        id: setPinView

        GridLayout {
            columns: 2
            Label {
                text: qsTr("Current PIN: ")
            }
            TextField {
                id: currentPin
                echoMode: TextInput.Password
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("New PIN: ")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
            TextField {
                id: newPin
                echoMode: TextInput.Password
            }
            Label {
                text: qsTr("Confirm PIN: ")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            }
            TextField {
                id: confirmPin
                echoMode: TextInput.Password
            }
        }
    }
}
