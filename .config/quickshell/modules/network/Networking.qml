pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    ListModel {
        id: networksModel
    }

    property alias networks: networksModel

    property bool wifiStatus: false

    function setFromJson(jsonText) {
        let arr = [];
        try {
            arr = (typeof jsonText === "string")
            ? JSON.parse(jsonText)
            : jsonText;
        } catch (e) {
            console.log("networksModel: bad JSON", e);
            networksModel.clear();
            return;
        }

        networksModel.clear();

        for (let i = 0; i < arr.length; i++) {
            const o = arr[i] || {};
            if (o["in-use"] === "*") {
                networksModel.append({
                    inUse: o["in-use"] || "",
                    ssid:  "* " + o["ssid"] || ""
                });
            }
        }

        for (let i = 0; i < arr.length; i++) {
            const o = arr[i] || {};
            if (o["in-use"] === "*") {
                continue;
            }
            networksModel.append({
                inUse: o["in-use"] || "",
                ssid:  o["ssid"] || ""
            });
        }
    }

    function clear() {
        networksModel.clear();
    }

    function rescan() {
        rescanProcess.running = true;
    }

    function checkWifiStatus() {
        checkWifiStatusProcess.running = true;
    }

    function toggleWifi() {
        toggleWifiProcess.running = true;

    }

    Process {
        id: rescanProcess
        command: ["seed-networks-cli", "rescan"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                listProcess.running = true;
            }
        }
    }

    Process {
        id: listProcess
        command: ["seed-networks-cli", "list"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.setFromJson(this.text)
        }
    }

    Process {
        id: checkWifiStatusProcess
        command: ["seed-networks-cli", "wifi-status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiStatus = this.text === 'enabled\n'
            }
        }
    }

    Process {
        id: toggleWifiProcess
        command: ["seed-networks-cli", "toggle-wifi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                checkWifiStatusProcess.running = true;
            }
        }
    }
}
