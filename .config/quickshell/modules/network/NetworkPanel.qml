import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    id: networkScope

    property bool panelVisible: false

    IpcHandler {
        target: "network"
        function toggle(): void { networkScope.panelVisible = !networkScope.panelVisible; }
        function show(): void { networkScope.panelVisible = true; }
        function hide(): void { networkScope.panelVisible = false; }
    }

    Variants {
        model: Quickshell.screens

        FloatingWindow {
            required property var modelData
            screen: modelData
            visible: networkScope.panelVisible

            implicitHeight: 30

            ColumnLayout {
                anchors.fill: parent

                Button {
                    height: 50
                    text: "asd"
                    onClicked: {
                        Networking.rescan();
                    }
                }

                Switch {
                    id: mySwitch
                    text: "Enable Wifi"
                    checked: Networking.wifiStatus
                    onToggled: {
                        Networking.toggleWifi();
                    }
                }

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: Networking.networks
                    delegate: Component {
                        Rectangle {
                            id: delegateRectangle
                            width: listView.width
                            height: 30
                            color: mouseArea.pressed ? "lightgray" : "white"
                            border.width: 1
                            border.color: "gray"

                            Text {
                                text: ssid
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                onDoubleClicked: {
                                    console.log("DoubleClicked item at index: " + index + ", Name: " + ssid + ", inUse: " + inUse);
                                    // You can perform actions here, e.g.,
                                    // listView.currentIndex = index
                                    // navigate to a new page, etc.
                                }
                            }
                        }
                    }
                }
            }

            onClosed: {
                networkScope.panelVisible = false;
            }
        }

    }
}
