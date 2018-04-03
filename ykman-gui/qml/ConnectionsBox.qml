import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import "utils.js" as Utils


ColumnLayout {
    property var device
    property bool saving: false
    property bool unlocked: false
    property var unsavedConnections: []

    readonly property bool hasDevice: device.hasDevice

    anchors.left: parent.left
    anchors.right: parent.right

    signal commit(var connections)
    signal reset()
    signal startConfiguringConnections()

    onCommit: {
        console.log('set_mode', connections)
        saving = true
        device.set_mode(connections, function (error) {
            if (error) {
                if (error === 'Failed to switch mode.') {
                    modeSwitchError.open()
                }
            } else {
                ejectNow.open()
            }
        })
    }

    onHasDeviceChanged: {
        if (!hasDevice) {
            reset()
        }
    }

    onReset: {
        unlocked = false
        saving = false
        unsavedConnections = null

        for (var i = 0; i < switchesRepeater.count; ++i) {
            switchesRepeater.itemAt(i).fixState()
        }
    }

    onStartConfiguringConnections: {
        unsavedConnections = Utils.intersection(device.connections, device.enabled)
        unlocked = true
    }

    function isAcceptableConfiguration() {
        return unsavedConnections && (unsavedConnections.length > 0)
    }

    function isEnabled(connectionId) {
        return Utils.includes(device.enabled, connectionId)
    }

    function isUnsavedEnabled(connectionId) {
        return Utils.includes(unsavedConnections, connectionId)
    }


    function setConnection(connectionId, enabled) {
        if (enabled) {
            unsavedConnections = Utils.union(unsavedConnections, [connectionId]);
        } else {
            unsavedConnections = Utils.without(unsavedConnections, connectionId);
        }
    }

    RowLayout {

        Button {
            id: unlockConnectionsButton
            Layout.bottomMargin: -18

            enabled: device.connections.length > 1
            text: qsTr('Configure')
            visible: !unlocked

            onClicked: startConfiguringConnections()
        }

        Button {
            id: cancelConnectionsButton
            Layout.alignment: Qt.AlignRight
            Layout.bottomMargin: -18

            enabled: device.connections.length > 1 && !saving
            text: qsTr('Cancel')
            visible: unlocked

            onClicked: reset()
        }

        Button {
            id: commitConnectionsButton
            Layout.alignment: Qt.AlignRight
            Layout.bottomMargin: -18

            enabled: device.connections.length > 1 && isAcceptableConfiguration() && !saving
            text: qsTr('Save')
            visible: unlocked

            onClicked: commit(unsavedConnections)
        }

    }

    GridLayout {
        flow: GridLayout.TopToBottom
        rows: device.connections.length
        columns: 2

        anchors.right: parent.right

        Repeater {
            model: device.connections

            Label {
                Layout.column: 0
                Layout.row: index
                Layout.topMargin: 22

                enabled: unlocked ? isUnsavedEnabled(modelData) : isEnabled(modelData)
                text: modelData
            }
        }

        Repeater {
            id: switchesRepeater
            model: device.connections

            Switch {
                Layout.column: 1
                Layout.row: index
                Layout.topMargin: 22

                checked: isUnsavedEnabled(modelData)
                enabled: !saving
                visible: unlocked

                signal fixState()

                onCheckedChanged: {
                    if (unlocked) {
                        console.log('Click', checked)
                        setConnection(modelData, checked)
                        console.log('Connections', device.connections, unsavedConnections)
                    } else {
                        fixState()
                    }
                }

                onFixState: {
                    checked = isEnabled(modelData)
                }
            }
        }
    }

    MessageDialog {
        id: modeSwitchError
        title: qsTr('Error configuring connections')
        icon: StandardIcon.Critical
        text: qsTr('Failed to configure connections. Make sure the YubiKey does not have restricted access.')
        standardButtons: StandardButton.Ok
    }

    MessageDialog {
        id: ejectNow
        title: qsTr('Connections configured')
        icon: StandardIcon.Information
        text: qsTr('Connections are now configured. Remove and re-insert your YubiKey.')
        standardButtons: StandardButton.NoButton

        readonly property bool hasDevice: device.hasDevice
        onHasDeviceChanged: {
            if (!hasDevice) {
                ejectNow.close()
            }
        }
    }

}
