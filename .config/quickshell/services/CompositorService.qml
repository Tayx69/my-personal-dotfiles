pragma Singleton

import Quickshell
import Quickshell.Hyprland
import QtQuick

// Pengganti CompositorService untuk Hyprland. Bentuk datanya sengaja dibuat sama
// (id, idx, name, output, is_active, is_focused, is_urgent) supaya widget
// lain tidak perlu diubah.
Singleton {
    id: root

    readonly property bool available: !!Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
    readonly property bool windowsReady: available

    // Hanya workspace biasa (id > 0); special workspace (id negatif) diabaikan.
    readonly property var workspaces: Hyprland.workspaces.values
        .filter(w => w.id > 0)
        .map(w => ({
            id: w.id,
            idx: w.id,
            name: w.name,
            output: w.monitor?.name ?? "",
            is_active: (w.monitor?.activeWorkspace?.id ?? -1) === w.id,
            is_focused: Hyprland.focusedWorkspace?.id === w.id,
            is_urgent: w.urgent ?? false
        }))
        .sort((a, b) => a.id - b.id)

    // Sintaks dispatch Lua (Hyprland 0.55+)
    function focusWorkspace(id: int): void {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = '${id}' })`)
    }
}
