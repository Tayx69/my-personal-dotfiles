import QtQuick
import ".."

Column {
    id: root
    width: parent ? parent.width : 0
    spacing: 12

    readonly property var animationSettings: [
        { key: "panel", title: "Panels", detail: "Control, utility, power, and edge panels" },
        { key: "launcher", title: "Launcher", detail: "Results, selection, and scrolling" },
        { key: "content", title: "Content", detail: "Calendar, connectivity, media, and switches" },
        { key: "notification", title: "Notifications", detail: "Popup and history movement" },
        { key: "wallpaper", title: "Startup", detail: "Desktop frame and startup reveal" },
        { key: "statusBar", title: "Status bar", detail: "Startup and workspace movement" }
    ]

    SettingsGroup {
        Repeater {
            model: root.animationSettings
            delegate: SettingsAnimationRow {
                required property var modelData
                required property int index
                width: root.width
                groupKey: modelData.key
                title: modelData.title
                detail: modelData.detail
                showSeparator: index < root.animationSettings.length - 1
            }
        }
    }
}
