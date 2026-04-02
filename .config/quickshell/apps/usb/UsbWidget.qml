import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Scope {
    id: root

    // ── Configuration ──────────────────────────────────────────────────
    readonly property string scriptPath: "seed-usb-manager"

    property bool automountEnabled: false
    property var usbDrives: []          // list of drive objects from the script
    property bool loading: false

    // ── Colors / Theme ─────────────────────────────────────────────────
    readonly property color bgColor:        "#1e1e2e"
    readonly property color surfaceColor:   "#313244"
    readonly property color overlayColor:   "#45475a"
    readonly property color textColor:      "#cdd6f4"
    readonly property color subtextColor:   "#a6adc8"
    readonly property color accentColor:    "#89b4fa"
    readonly property color greenColor:     "#a6e3a1"
    readonly property color redColor:       "#f38ba8"
    readonly property color yellowColor:    "#f9e2af"

    // ── Process runners ────────────────────────────────────────────────

    Process {
        id: listProcess
        command: [root.scriptPath, "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.usbDrives = JSON.parse(this.text);
                } catch (e) {
                    root.usbDrives = [];
                    console.warn("USB list parse error:", e);
                }
            }
          }
        onExited: (exitCode, exitStatus) => {
            root.loading = false;
            if (exitCode !== 0) {
                root.usbDrives = []
                console.warn("USB list error: (exitCode:", exitCode, ') -', exitStatus);
            }
        }
    }

    Process {
        id: automountStatusProcess
        command: [root.scriptPath, "automount-status"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                try {
                    const obj = JSON.parse(stdout);
                    root.automountEnabled = obj.enabled;
                } catch (e) {}
            }
        }
    }

    Process {
        id: automountToggleProcess
        property bool targetState: false
        command: [root.scriptPath, targetState ? "automount-on" : "automount-off"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.automountEnabled = targetState;
            }
            refreshDrives();
        }
    }

    Process {
        id: mountProcess
        property string device: ""
        command: [root.scriptPath, "mount", device]
        onExited: (exitCode, exitStatus) => {
            refreshDrives();
        }
    }

    Process {
        id: unmountProcess
        property string device: ""
        command: [root.scriptPath, "unmount", device]
        onExited: (exitCode, exitStatus) => {
            refreshDrives();
        }
    }

    // ── Refresh timer ──────────────────────────────────────────────────

    Timer {
        id: pollTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: refreshDrives()
    }

    function refreshDrives() {
        root.loading = true;
        listProcess.running = true;
    }

    function initialize() {
        automountStatusProcess.running = true;
        refreshDrives();
    }

    Component.onCompleted: root.initialize()

    // ── Main window ────────────────────────────────────────────────────

    FloatingWindow {
        id: window
        width: 360
        height: windowContent.implicitHeight + 48

        onClosed: Qt.quit()

        Rectangle {
            anchors.fill: parent
            color: root.bgColor

            ColumnLayout {
                id: windowContent
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 16
                }
                spacing: 10

                // ── Header ─────────────────────────────────

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "USB Drive Manager"
                        color: root.textColor
                        font.pixelSize: 15
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    // Refresh button
                    Rectangle {
                        width: 28; height: 28
                        radius: 6
                        color: refreshMa.containsMouse ? root.overlayColor : root.surfaceColor

                        Text {
                            anchors.centerIn: parent
                            text: "⟳"
                            color: root.accentColor
                            font.pixelSize: 16
                            rotation: root.loading ? 360 : 0

                            Behavior on rotation {
                                RotationAnimation {
                                    duration: 600
                                    direction: RotationAnimation.Clockwise
                                }
                            }
                        }

                        MouseArea {
                            id: refreshMa
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.refreshDrives()
                        }
                    }
                }

                // ── Separator ──────────────────────────────

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.overlayColor
                }

                // ── Auto-mount toggle ──────────────────────

                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 8
                    color: root.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        ColumnLayout {
                            spacing: 0
                            Layout.fillWidth: true

                            Text {
                                text: "Auto-mount"
                                color: root.textColor
                                font.pixelSize: 13
                            }
                            Text {
                                text: "Mount new drives to /mnt/usbX"
                                color: root.subtextColor
                                font.pixelSize: 10
                            }
                        }

                        // Toggle switch
                        Rectangle {
                            id: toggleTrack
                            width: 42; height: 22
                            radius: 11
                            color: root.automountEnabled ? root.greenColor : root.overlayColor

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            Rectangle {
                                id: toggleKnob
                                width: 18; height: 18
                                radius: 9
                                color: root.textColor
                                y: 2
                                x: root.automountEnabled ? parent.width - width - 2 : 2

                                Behavior on x {
                                    NumberAnimation { duration: 150 }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    automountToggleProcess.targetState = !root.automountEnabled;
                                    automountToggleProcess.running = true;
                                }
                            }
                        }
                    }
                }

                // ── Drive list header ──────────────────────

                Text {
                    text: root.automountEnabled
                          ? "Connected Drives (auto-managed)"
                          : "Connected Drives (manual)"
                    color: root.subtextColor
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    Layout.topMargin: 2
                }

                // ── Drive list ─────────────────────────────

                // Empty state
                Rectangle {
                    visible: root.usbDrives.length === 0
                    Layout.fillWidth: true
                    height: 60
                    radius: 8
                    color: root.surfaceColor

                    Text {
                        anchors.centerIn: parent
                        text: root.loading ? "Scanning…" : "No USB drives detected"
                        color: root.subtextColor
                        font.pixelSize: 12
                    }
                }

                // Drive entries
                Repeater {
                    model: root.usbDrives

                    Rectangle {
                        id: driveCard
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        height: 56
                        radius: 8
                        color: driveMa.containsMouse ? root.overlayColor : root.surfaceColor

                        MouseArea {
                            id: driveMa
                            anchors.fill: parent
                            hoverEnabled: true
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            // Drive icon
                            Rectangle {
                                width: 36; height: 36
                                radius: 8
                                color: driveCard.modelData.mounted
                                       ? Qt.rgba(root.greenColor.r, root.greenColor.g, root.greenColor.b, 0.15)
                                       : Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)

                                Text {
                                    anchors.centerIn: parent
                                    text: driveCard.modelData.mounted ? "⛁" : "⛀"
                                    font.pixelSize: 18
                                    color: driveCard.modelData.mounted ? root.greenColor : root.accentColor
                                }
                            }

                            // Drive info
                            ColumnLayout {
                                spacing: 1
                                Layout.fillWidth: true

                                Text {
                                    text: driveCard.modelData.label || driveCard.modelData.device
                                    color: root.textColor
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: {
                                        let info = driveCard.modelData.device + "  ·  " + driveCard.modelData.size + "  ·  " + driveCard.modelData.fstype;
                                        if (driveCard.modelData.mounted && driveCard.modelData.mountpoint) {
                                            info += "  →  " + driveCard.modelData.mountpoint;
                                        }
                                        return info;
                                    }
                                    color: root.subtextColor
                                    font.pixelSize: 10
                                    font.family: "monospace"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            // Mount/Unmount button
                            Rectangle {
                                width: btnText.width + 20
                                height: 28
                                radius: 6
                                color: driveCard.modelData.mounted
                                       ? Qt.rgba(root.redColor.r, root.redColor.g, root.redColor.b, 0.15)
                                       : Qt.rgba(root.greenColor.r, root.greenColor.g, root.greenColor.b, 0.15)
                                border.color: driveCard.modelData.mounted ? root.redColor : root.greenColor
                                border.width: 1

                                Text {
                                    id: btnText
                                    anchors.centerIn: parent
                                    text: driveCard.modelData.mounted ? "Unmount" : "Mount"
                                    color: driveCard.modelData.mounted ? root.redColor : root.greenColor
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (driveCard.modelData.mounted) {
                                            unmountProcess.device = driveCard.modelData.device;
                                            unmountProcess.running = true;
                                        } else {
                                            mountProcess.device = driveCard.modelData.device;
                                            mountProcess.running = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Footer hint ────────────────────────────

                Text {
                    visible: !root.automountEnabled && root.usbDrives.length > 0
                    text: "ℹ  Auto-mount is off — plug in a drive and mount it here"
                    color: root.yellowColor
                    font.pixelSize: 10
                    opacity: 0.7
                    Layout.topMargin: 2
                    Layout.bottomMargin: 4
                }
            }
        }
    }
}
