import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: app
    title: qsTr("YubiKey Manager")
    visible: true

    minimumHeight: calcHeight()
    height: minimumHeight
    minimumWidth: calcWidth()
    width: minimumWidth

    property int margins: 12

    function calcWidth() {
        return mainStack.currentItem ? Math.max(
                                           350,
                                           mainStack.currentItem.implicitWidth + (margins * 2)) : 0
    }

    function calcHeight() {
        return mainStack.currentItem ? Math.max(
                                           360,
                                           header.height + mainStack.currentItem.implicitHeight
                                           + (margins * 2)) : 0
    }

    menuBar: MainMenuBar {
    }

    AboutPage {
        id: aboutPage
    }

    Shortcut {
        sequence: StandardKey.Close
        onActivated: close()
    }

    // @disable-check M301
    YubiKey {
        id: yk
        onError: console.log(traceback)
        onHasDeviceChanged: mainStack.handleDeviceChange()
    }

    Timer {
        id: timer
        triggeredOnStart: true
        interval: 500
        repeat: true
        running: true
        onTriggered: yk.refresh()
    }
    ColumnLayout {
        spacing: 0
        anchors.fill: parent
        Layout.fillWidth: true
        Header {
            id: header
        }
        StackView {
            id: mainStack
            property bool frozen: fidoDialog.visible || slotDialog.visible
                                  || pivManager.visible
                                  || connectionsDialog.visible
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialItem: message
            onCurrentItemChanged: {
                if (currentItem) {
                    currentItem.forceActiveFocus()
                }
            }
            function handleDeviceChange() {
                if (!frozen) {
                    clear()
                    push(yk.hasDevice ? deviceInfo : message)
                }
            }
        }
    }

    Component {
        id: message
        ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.bottomMargin: 10
            GroupBox {
                Layout.margins: 12
                title: qsTr("Device")
                Layout.fillWidth: true
                Layout.fillHeight: true
                Label {
                    anchors.fill: parent
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: if (yk.nDevices == 0) {
                              qsTr("No YubiKey detected.\nInsert a YubiKey to configure.")
                          } else if (yk.nDevices == 1) {
                              qsTr("Connecting to YubiKey...")
                          } else {
                              qsTr("Multiple YubiKeys detected!\nYubiKeys must be configured one at a time.")
                          }
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            GroupBox {
                Layout.rightMargin: 12
                Layout.leftMargin: 12
                Layout.bottomMargin: 12
                title: qsTr("Things you can do with the YubiKey Manager")
                Layout.fillWidth: true
                Layout.fillHeight: true
                    Label {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: qsTr("•  Add or change a PIN on your FIDO 2 enabled YubiKey\n•  Enable or disable connections on your YubiKey\n•  Program custom functionality into the short or long button touches (OTP slots)\n•  Swap the functionalities between the short and long button touches (OTP slots)")
                        leftPadding:12
                        topPadding:6
                    }
            }
        }
    }

    Component {
        id: deviceInfo
        DeviceInfo {
            device: yk
        }
    }

    SlotDialog {
        id: slotDialog
        device: yk
    }

    PivManager {
        id: pivManager
        device: yk
    }

    OpenPgpResetDialog {
        id: openPgpResetDialog
        device: yk
    }

    OpenPgpPinRetries {
        id: openPgpPinRetries
        device: yk
    }

    OpenPgpTouchPolicy {
        id: openPgpTouchPolicy
        device: yk
    }

    OpenPgpShowStatus {
        id: openPgpStatus
        device: yk
    }

    FidoDialog {
        id: fidoDialog
        device: yk
    }

    TouchYubiKey {
        id: touchYubiKeyPrompt
    }

    MessageDialog {
        id: openPgpResetConfirm
        icon: StandardIcon.Information
        title: qsTr("OpenPGP functionality has been reset.")
        text: qsTr("All data has been cleared and default PINs are set.")
        standardButtons: StandardButton.Ok
    }

    MessageDialog {
        id: openPgpTouchConfirm
        icon: StandardIcon.Information
        title: qsTr("Touch Policy for OpenPGP")
        text: qsTr("A new touch policy for OpenPGP has been set.")
        standardButtons: StandardButton.Ok
    }
    MessageDialog {
        id: openPgpPinRetriesConfirm
        icon: StandardIcon.Information
        title: qsTr("Pin retries for OpenPGP")
        text: qsTr("New pin retries for OpenPGP has been set.")
        standardButtons: StandardButton.Ok
    }

    ClipBoard {
        id: clipboard
    }

    function copyToClipboard(value) {
        clipboard.setClipboard(value)
    }

    function supportsOpenPgpTouch() {
        // Touch policy for OpenPGP is available from version 4.2.0.
        return parseInt(yk.version.split('.').join('')) >= 420
    }

    function supportsOpenPgpPinRetries() {
        // Note: this only works for YK4. NEOs below 1.0.7 doesn't support this,
        // but since we need to select the applet to get the OpenPGP version,
        // we allow all NEOs to try.
        var version = yk.version.split('.').join('')
        return version < 400 || version > 431
    }

    function clearsPinWhenSettingPinRetries() {
        var version = yk.version.split('.').join('')
        return version < 400
    }

    function enableLogging(logLevel) {
        yk.enableLogging(logLevel, null)
    }
    function enableLoggingToFile(logLevel, logFile) {
        yk.enableLogging(logLevel, logFile)
    }
    function disableLogging() {
        yk.disableLogging()
    }
}
