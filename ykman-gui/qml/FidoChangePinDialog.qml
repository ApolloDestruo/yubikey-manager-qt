import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2

ChangeCode {
    hasCode: hasPin
    minLength: 4
    maxLength: 128
    showRequirements: false
    acceptBtnName: qsTr('Set PIN')
    headerText: hasPin ? qsTr("Change FIDO2 PIN") : qsTr("Set a FIDO2 PIN")
    Keys.onEscapePressed: close()
    onCodeChanged: {
        var _currentPin = currentCode || null
        var _newPin = newCode
        if (hasPin) {
            device.fido_change_pin(_currentPin, _newPin, handleChangePin)
        } else {
            device.fido_set_pin(_newPin, handleChangePin)
        }
    }

    function handleChangePin(resp) {
        if (resp.success) {
            fidoPinConfirmation.open()
        } else {
            fidoSetPinError.text = resp.error
            fidoSetPinError.open()
        }
    }

    MessageDialog {
        id: fidoSetPinError
        icon: StandardIcon.Critical
        title: qsTr("Failed to set PIN.")
        standardButtons: StandardButton.Ok
        onAccepted: fidoDialog.load()
    }

    MessageDialog {
        id: fidoPinConfirmation
        icon: StandardIcon.Information
        title: qsTr("A new PIN has been set!")
        text: qsTr("Setting a PIN for the FIDO2 Application was successful.")
        standardButtons: StandardButton.Ok
        onAccepted: fidoDialog.load()
    }
}
