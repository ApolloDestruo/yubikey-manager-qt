import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.3

Pane {
    id: pane
    height: 200
    padding: 14
    function isEnabled(feature) {
        return device.enabled.indexOf(feature) !== -1
    }
    function isCapable(feature) {
        return device.capabilities.indexOf(feature) !== -1
    }

    ColumnLayout {
        anchors.fill: parent
        Label {
            text: qsTr("") + device.name
            Layout.fillWidth: false
        }
        Label {
            text: qsTr("Firmware Version: ") + device.version
        }
        Label {
            text: qsTr("Serial: ") + (device.serial ? device.serial : 'Unknown')
        }

        GroupBox {
            Layout.fillHeight: false
            Layout.fillWidth: false
            GridLayout {
                flow: GridLayout.TopToBottom
                rows: features.length
                property var features: [{
                        id: 'OTP',
                        label: qsTr('YubiKey Slots')
                    }, {
                        id: 'PIV',
                        label: qsTr('PIV')
                    }, {
                        id: 'OATH',
                        label: qsTr('OATH')
                    }, {
                        id: 'OPGP',
                        label: qsTr('OpenPGP')
                    }, {
                        id: 'U2F',
                        label: qsTr('U2F')
                    }]
                anchors.fill: parent
                Repeater {
                    model: parent.features
                    Label {
                        text: modelData.label + ':'
                    }
                }
                Repeater {
                    model: parent.features
                    Label {
                        text: (isCapable(
                                   modelData.id) ? isEnabled(
                                                       modelData.id) ? qsTr("Enabled") : qsTr(
                                                                           "Disabled") : qsTr(
                                                                           "Not available"))
                    }
                }
            }
        }
    }
}
