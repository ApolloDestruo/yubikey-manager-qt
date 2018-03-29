import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

ColumnLayout {
    id: deviceInfo
    property var device
    Layout.minimumWidth: app.minimumWidth
    Keys.onTabPressed: btnRepeater.itemAt(0).forceActiveFocus()
    Keys.onEscapePressed: deviceInfo.forceActiveFocus()
    ColumnLayout {
        Layout.margins: 12
        GroupBox {
            id: deviceBox
            title: qsTr("Device")
            Layout.fillWidth: true
            Layout.fillHeight: false
            GridLayout {
                columns: 1
                Label {
                    text: (device.name === 'YubiKey 4') ? device.name + ' Series' : device.name
                    leftPadding: 10
                    topPadding: 5
                }
                Label {
                    text: qsTr("Firmware: ") + device.version
                    leftPadding: 10
                }
                Label {
                    text: qsTr("Serial: ") + (device.serial ? device.serial : 'Unknown')
                    leftPadding: 10
                    bottomPadding: 10
                }
            }
        }

       GridLayout{
           columns: 3
           Layout.bottomMargin: 10
            GroupBox {
                id: connectionsBox
                checkable: false
                flat: false
                title: qsTr("USB Interfaces")
                Layout.fillWidth: false
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.right: parent.right
                    anchors.left: parent.left
                    Button {
                        id: connectionsBtn
                        text: qsTr("Enable / Disable")
                        Layout.alignment: Qt.AlignRight
                        enabled: device.connections.length > 1
                        onClicked: connectionsDialog.show()
                        Layout.bottomMargin: -18
                    }

                    Repeater {
                        id: connectionsRepeater
                        model: device.connections
                        Label {
                            text: (device.enabled.indexOf(modelData) < 0) ? "disabled - " + modelData : modelData
                            color: (device.enabled.indexOf(modelData) < 0) ? "gray" : "black"
                            anchors.right: parent.right
                            Layout.topMargin: 22
                        }
                    }
                }
            }

            Rectangle {
                id: deviceRect
                width:180
                height: 160
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                AnimatedImage {
                    id: deviceImage
                    width: 210
                    height: 175
                    fillMode: Image.PreserveAspectCrop
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 12
                    source: getKeyImage(device.name);
                    horizontalAlignment: Text.AlignHCenter
                    onPlayingChanged: deviceImage.playing = true
                }
            }

            GroupBox {
                id: featureBox
                antialiasing: false
                transformOrigin: Item.Center
                Layout.columnSpan: 1
                Layout.rowSpan: 1
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                title: qsTr("Applications")
                Layout.fillWidth: false
                Layout.fillHeight: true
                GridLayout {
                    flow: GridLayout.TopToBottom
                    rows: features.length
                    anchors.right: parent.right
                    anchors.left: parent.left
                    property var features: [{
                            id: 'OTP',
                            label: qsTr('YubiKey Slots'),
                            onConfigure: slotDialog.load
                        }, {
                            id: 'U2F',
                            label: qsTr('FIDO 2'),
                            onConfigure: fidoDialog.load
                        }, {
                            id: 'U2F',
                            label: qsTr('U2F')
                        }, {
                            id: 'PIV',
                            label: qsTr('PIV'),
                            onConfigure: featureFlag_pivManager ? pivManager.start : undefined
                        }, {
                            id: 'OATH',
                            label: qsTr('OATH')
                        }, {
                            id: 'OPGP',
                            label: qsTr('OpenPGP')
                        }]

                    Repeater {
                        model: parent.features
                        Label {
                            Layout.column: 0
                            Layout.row: index
                            text: modelData.label + ':'
                            color: (isCapable(
                                        modelData.id) ? isEnabled(
                                                            modelData.id) ? "black" :
                                                                                "grey" :
                                                                                "grey")
                        }

                    }


                    Repeater {
                        model: parent.features
                        Label {
                            Layout.column: 1
                            Layout.row: index
                            text: (isCapable(
                                       modelData.id) ? isEnabled(
                                                           modelData.id) ? qsTr("Enabled") : qsTr(
                                                                               "Disabled") : qsTr(
                                                                               "Not available"))
                            color: (isCapable(
                                        modelData.id) ? isEnabled(
                                                            modelData.id) ? "black" :
                                                                                "grey" :
                                                                                "grey")
                        }
                    }

                    Repeater {
                        id: btnRepeater
                        model: parent.features
                        Button {
                            Layout.column: 2
                            Layout.row: index
                            Layout.alignment: Qt.AlignRight
                            text: qsTr("Configure")
                            enabled: isEnabled(modelData.id)
                            visible: parent.features[index].onConfigure !== undefined
                            focus: true
                            Keys.onTabPressed: {
                                var nextButton = btnRepeater.itemAt(index + 1)
                                if (nextButton.enabled && nextButton.visible) {
                                    nextButton.forceActiveFocus()
                                } else {
                                    connectionsBtn.forceActiveFocus()
                                }
                            }
                            onClicked: parent.features[index].onConfigure()
                        }
                    }
                }
            }
     }

    }
    function isEnabled(feature) {
        return device.enabled.indexOf(feature) !== -1
    }

    function isCapable(feature) {
        return device.capabilities.indexOf(feature) !== -1
    }

    function readable_list(args) {
        if (args.length === 0) {
            return ''
        } else if (args.length === 1) {
            return args[0]
        } else {
            args = args.slice() //Don't modify the original array.
            var last = args.pop()
            return args.join(', ') + qsTr(' and ') + last
        }
    }

    function getKeyImage(name){

        var deviceCaps = device.enabled;
        var fileEnding = [];

        // create an Array in the style [1,0,1] depending on
        // if capabilities are available and turned on

        if(deviceCaps.indexOf('OTP') !== -1){
            fileEnding.push(1);
        } else fileEnding.push(0);

        if(deviceCaps.indexOf('U2F') !== -1){
            fileEnding.push(1);
        } else fileEnding.push(0);

        if(deviceCaps.indexOf('CCID') !== -1){
            fileEnding.push(1);
        } else fileEnding.push(0);

        var fileEndingString = fileEnding.join('');

        if(name === "YubiKey 4"){
            return "../images/anim/yk4-"+fileEndingString+".gif";
        } else if (name === "YubiKey NEO"){
            return "../images/anim/neo-"+fileEndingString+".gif";
        } else if (name === "FIDO U2F Security Key"){
            return "../images/anim/sky-100.gif";
        } //TODO add FIDO 2
    }

}
