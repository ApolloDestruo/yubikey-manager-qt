import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.0
import "slotutils.js" as SlotUtils

ColumnLayout {
    id: confColumn
    Keys.onTabPressed: secretKeyInput.forceActiveFocus()
    Keys.onEscapePressed: close()

    Label {
        text: qsTr("Configure challenge-response for ") + SlotUtils.slotNameCapitalized(
                  selectedSlot)
        font.bold: true
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        Layout.maximumWidth: confColumn.width
    }

    Label {
        text: qsTr("When queried, the YubiKey will respond to a challenge.")
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        Layout.maximumWidth: confColumn.width
    }

    GroupBox {
        title: "Secret Key"
        Layout.fillWidth: true
        Layout.maximumWidth: confColumn.width
        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: secretKeyInput
                    KeyNavigation.tab: generateBtn
                    Layout.fillWidth: true
                    implicitWidth: 320
                    font.family: "Courier"
                    validator: RegExpValidator {
                        regExp: /([0-9a-fA-F]{2}){1,20}$/
                    }
                }
                Button {
                    id: generateBtn
                    KeyNavigation.tab: requireTouch
                    text: qsTr("Generate")
                    onClicked: generateKey()
                }
            }

            Label {
                text: qsTr("The Secret key contains an even number of up to 40 hexadecimal characters.")
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.maximumWidth: confColumn.width
            }

            CheckBox {
                id: requireTouch
                KeyNavigation.tab: backBtn
                text: qsTr("Require touch")
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Button {
            id: backBtn
            KeyNavigation.tab: finishBtn
            text: qsTr("Back")
            onClicked: stack.pop({
                                     immediate: true
                                 })
        }
        Button {
            id: finishBtn
            KeyNavigation.tab: secretKeyInput
            text: qsTr("Finish")
            enabled: secretKeyInput.acceptableInput
            onClicked: finish()
        }
    }

    SlotOverwriteWarning {
        id: warning
        onYes: programChallengeResponse()
    }

    function generateKey() {
        device.random_key(20, function (res) {
            secretKeyInput.text = res
        })
    }

    function finish() {
        if (slotsConfigured[selectedSlot - 1]) {
            warning.open()
        } else {
            programChallengeResponse()
        }
    }

    function programChallengeResponse() {
        device.program_challenge_response(selectedSlot, secretKeyInput.text,
                                          requireTouch.checked,
                                          function (error) {
                                              if (!error) {
                                                  confirmConfigured.open()
                                              } else {
                                                  if (error === 3) {
                                                      writeError.open()
                                                  }
                                              }
                                          })
    }
}
