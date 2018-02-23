import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.3

Pane {
    height: 200
    ColumnLayout {
        Label {
            text: "Configure enabled connection protocols"
            font.bold: true
        }
        Label {
            id: infoText
            text: qsTr("Select the connections you want to enable for your YubiKey.
After saving you need to remove and re-insert your
YubiKey for the settings to take effect.")
        }
        RowLayout {
            Repeater {
                id: connections
                model: device.connections
                CheckBox {
                    text: modelData
                }
            }
        }
        Button {
            id: saveConnectionsBtn
            text: qsTr("Save connections")
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
        }
    }
}
