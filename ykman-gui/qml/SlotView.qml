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
            text: qsTr("Configure YubiKey Slots")
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            font.bold: true
        }

        RadioButton {
            id: r1
            text: qsTr("Short Press (Slot 1): Configured")
        }
        RadioButton {
            id: r2
            text: qsTr("Long Press (Slot 2): Empty")
        }
        RowLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            Button {
                highlighted: true
                //Material.accent: Material.accent
                id: setPinBtn
                text: qsTr("Swap slots")
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Swap the configurations between the two slots.")
            }
            Button {
                id: conf
                text: qsTr("Configure")
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            }
        }
    }
}
