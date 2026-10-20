pragma Singleton

import Quickshell
import QtQuick
import "../../services"
import "palettes"

Singleton {
    // Satu palet tetap (Catppuccin). Warna diubah langsung di palettes/Catppuccin.qml.
    readonly property QtObject catppuccin: Catppuccin {}
    readonly property QtObject activeTheme: catppuccin

    function withOpacity(colorValue: color, opacityValue: real): color {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b,
            Math.max(0, Math.min(1, opacityValue)));
    }

    function mix(first: color, second: color, amount: real): color {
        return Qt.rgba(
            first.r + (second.r - first.r) * amount,
            first.g + (second.g - first.g) * amount,
            first.b + (second.b - first.b) * amount,
            first.a + (second.a - first.a) * amount
        );
    }

    function linearChannel(channel: real): real {
        return channel <= 0.04045 ? channel / 12.92
            : Math.pow((channel + 0.055) / 1.055, 2.4);
    }

    function luminance(colorValue: color): real {
        return linearChannel(colorValue.r) * 0.2126
            + linearChannel(colorValue.g) * 0.7152
            + linearChannel(colorValue.b) * 0.0722;
    }

    function contrastText(background: color): color {
        const dark = "#171218";
        const light = "#fff8fb";
        const backgroundLuminance = luminance(background);
        const darkRatio = (backgroundLuminance + 0.05) / (luminance(dark) + 0.05);
        const lightRatio = (luminance(light) + 0.05) / (backgroundLuminance + 0.05);
        return darkRatio >= lightRatio ? dark : light;
    }

    readonly property real surfaceOpacity: SettingsService.reduceTransparency
        ? 1 : SettingsService.surfaceOpacity

    readonly property color liquidColor: activeTheme.foregroundColor
    readonly property color windowColor: activeTheme.windowColor
    readonly property color maskColor: activeTheme.maskColor
    readonly property color wallpaperFallbackColor: activeTheme.wallpaperFallbackColor

    readonly property color shellBackgroundColor: activeTheme.foregroundColor
    readonly property color shellShadowColor: "#50000000"
    readonly property color panelSurfaceColor: withOpacity(
        activeTheme.searchBackgroundColor, surfaceOpacity)
    readonly property color hoverSurfaceColor: activeTheme.itemHoverColor
    readonly property color surfaceBorderColor: activeTheme.searchBorderColor
    readonly property color selectedSurfaceColor: activeTheme.highlightColor
    readonly property color primaryTextColor: activeTheme.textColor
    readonly property color secondaryTextColor: activeTheme.secondaryTextColor
    readonly property color mutedTextColor: activeTheme.placeholderTextColor
    readonly property color accentColor: activeTheme.accentColor
    readonly property color accentHoverColor: activeTheme.accentHoverColor
    readonly property color accentTextColor: activeTheme.accentTextColor
    // Warna khusus status bar (Catppuccin Mocha, format hex Qt = #AARRGGBB).
    readonly property color barColor: "#d91e1e2e"          // base ~85% opak
    readonly property color barPillColor: "#14ffffff"      // putih ~8%
    readonly property color barTrackColor: "#26ffffff"     // putih ~15%
    readonly property color barTextColor: "#cdd6f4"
    readonly property color barMutedTextColor: "#6c7086"
    readonly property color barAccentColor: "#89b4fa"
    readonly property color statusAccentColor: barAccentColor
    readonly property color statusAccentTextColor: contrastText(statusAccentColor)
    readonly property color successColor: activeTheme.successColor
    readonly property color dangerColor: activeTheme.dangerColor
    readonly property color dangerTextColor: contrastText(dangerColor)

    // Material-inspired tonal surface hierarchy. Existing aliases above remain
    // available while components migrate to explicit semantic roles.
    readonly property color surfaceColor: panelSurfaceColor
    readonly property color surfaceContainerLowColor: mix(
        activeTheme.foregroundColor, activeTheme.searchBackgroundColor, 0.55)
    readonly property color surfaceContainerColor: activeTheme.searchBackgroundColor
    readonly property color surfaceContainerHighColor: mix(
        activeTheme.searchBackgroundColor, activeTheme.textColor, 0.06)
    readonly property color surfaceTextColor: primaryTextColor
    readonly property color surfaceVariantTextColor: secondaryTextColor
    readonly property color outlineColor: surfaceBorderColor
    readonly property color outlineVariantColor: withOpacity(surfaceBorderColor, 0.62)
    readonly property color primaryContainerColor: selectedSurfaceColor
    readonly property color primaryContainerTextColor: accentColor
    readonly property color scrimColor: "#99000000"
}
