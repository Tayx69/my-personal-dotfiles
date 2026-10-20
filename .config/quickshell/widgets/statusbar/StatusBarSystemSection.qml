import QtQuick
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    implicitWidth: content.width
    implicitHeight: 26
    visible: SettingsService.statusBarShowTray

    Row {
        id: content
        height: parent.height
        spacing: 10

        Rectangle {
            visible: SettingsService.statusBarShowTray
            width: visible ? trayIcons.width + 14 : 0
            height: 26
            radius: height / 2
            color: Theme.statusAccentColor

            Row {
                id: trayIcons
                height: parent.height
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: [
                        { icon: Icons.notifications, page: "notifications" },
                        { icon: Icons.wifi, page: "wifi" },
                        { icon: Icons.bluetooth, page: "bluetooth" }
                    ]
                    Item {
                        id: trayButton
                        required property var modelData
                        width: 26
                        height: 26

                        Text {
                            anchors.centerIn: parent
                            text: trayButton.modelData.icon
                            color: Theme.statusAccentTextColor
                            opacity: OverlayState.utilityCenterVisible
                                && OverlayState.utilityPage !== trayButton.modelData.page ? 0.55 : 1
                            font.family: Typography.nerdIconFontFamily
                            font.pixelSize: 16

                            Behavior on opacity { NumberAnimation { duration: 120 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: OverlayState.toggleUtilityPage(trayButton.modelData.page)
                        }
                    }
                }
            }
        }
    }
}
