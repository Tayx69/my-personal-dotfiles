/**
 * Pixie SDDM - PowerBar Component (versi dengan efek hover)
 * Author asli: xCaptaiN09
 */
import QtQuick

Row {
    id: powerBarRoot
    spacing: 6
    height: 36

    property color textColor: "white"
    // Pakai font ikon dari tema; kalau filenya tidak ada, pakai Nerd Font sistem
    property string iconFamily: iconFont.status === FontLoader.Ready ? iconFont.name : "JetBrainsMono Nerd Font"

    FontLoader { id: iconFont; source: "../assets/fonts/MaterialDesignIcons.ttf" }

    // Battery (otomatis tersembunyi di PC desktop)
    Row {
        id: batteryRow
        spacing: 5
        visible: typeof battery !== "undefined" && typeof battery.percent !== "undefined"
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: batteryText
            text: (typeof battery !== "undefined" ? battery.percent : "0") + "%"
            color: powerBarRoot.textColor
            font.pixelSize: 14
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: batteryIcon
            text: (typeof battery !== "undefined" && battery.charging) ? "󱐋" : "󰁹"
            color: powerBarRoot.textColor
            font.pixelSize: 18
            font.family: powerBarRoot.iconFamily
            anchors.verticalCenter: parent.verticalCenter
        }

        // SDDM kadang tidak mengirim sinyal baterai, jadi dicek paksa tiap 5 detik
        Timer {
            interval: 5000
            running: typeof battery !== "undefined" && battery.present
            repeat: true
            onTriggered: {
                batteryText.text = battery.percent + "%"
                batteryIcon.text = battery.charging ? "󱐋" : "󰁹"
            }
        }
    }

    // Keyboard layout
    Rectangle {
        visible: typeof keyboard !== "undefined" && keyboard.layouts.length > 1
        width: kbText.implicitWidth + 20
        height: 36
        radius: 18
        anchors.verticalCenter: parent.verticalCenter
        color: kbArea.pressed ? Qt.rgba(1, 1, 1, 0.28) : (kbArea.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : "transparent")
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            id: kbText
            anchors.centerIn: parent
            text: (typeof keyboard !== "undefined" && keyboard.layouts[keyboard.currentLayout]) ? keyboard.layouts[keyboard.currentLayout].shortName : "US"
            color: powerBarRoot.textColor
            font.pixelSize: 14
            font.capitalization: Font.AllUppercase
        }

        MouseArea {
            id: kbArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
        }
    }

    // Tombol daya: suspend, restart, shutdown
    Repeater {
        model: [
            { icon: "󰤄", action: "suspend" },
            { icon: "󰑐", action: "reboot" },
            { icon: "󰐥", action: "poweroff" }
        ]

        delegate: Rectangle {
            width: 36
            height: 36
            radius: 18
            anchors.verticalCenter: parent.verticalCenter
            color: area.pressed ? Qt.rgba(1, 1, 1, 0.28) : (area.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : "transparent")
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: modelData.icon
                color: powerBarRoot.textColor
                font.pixelSize: 20
                font.family: powerBarRoot.iconFamily
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData.action === "suspend") sddm.suspend()
                    else if (modelData.action === "reboot") sddm.reboot()
                    else sddm.powerOff()
                }
            }
        }
    }
}
