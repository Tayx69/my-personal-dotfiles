import QtQuick
import "../../components/theme"
import "../../services"

QtObject {
    readonly property var allItems: [
        {
            key: "command:settings",
            type: "command",
            name: "Settings",
            detail: "Open shell settings",
            command: "settings",
            icon: Icons.settings,
            enabled: SettingsService.launcherCommandSettings
        },
        {
            key: "command:tmux",
            type: "command",
            name: "Tmux sessions",
            detail: "Attach to a tmux session",
            command: "tmux",
            icon: Icons.terminal,
            enabled: SettingsService.launcherCommandTmux
        }
    ]

    readonly property var items: allItems.filter(item => item.enabled)
}
