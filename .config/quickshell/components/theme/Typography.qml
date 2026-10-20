pragma Singleton

import Quickshell
import "../../services"

Singleton {
    readonly property string bodyFontFamily: "JetBrainsMono Nerd Font"
    readonly property string nerdIconFontFamily: "JetBrainsMono Nerd Font"
    readonly property string materialIconFontFamily: "Material Design Icons"
    readonly property string symbolIconFontFamily: "Symbols Nerd Font"

    readonly property var japaneseWeekdays: ["日", "月", "火", "水", "木", "金", "土"]

    // Hanya nama hari yang Jepang, contoh: 日曜日
    function japaneseWeekday(when: date): string {
        return japaneseWeekdays[when.getDay()] + "曜日";
    }

    readonly property real labelSmall: 11 * SettingsService.uiScale
    readonly property real labelMedium: 12 * SettingsService.uiScale
    readonly property real labelLarge: 13 * SettingsService.uiScale
    readonly property real bodySmall: 12 * SettingsService.uiScale
    readonly property real bodyMedium: 14 * SettingsService.uiScale
    readonly property real bodyLarge: 16 * SettingsService.uiScale
    readonly property real titleSmall: 14 * SettingsService.uiScale
    readonly property real titleMedium: 16 * SettingsService.uiScale
    readonly property real titleLarge: 20 * SettingsService.uiScale
    readonly property real headlineSmall: 24 * SettingsService.uiScale
}
