import QtQuick
import "../theme"

Item {
    id: root

    required property bool active
    required property bool panelHovered
    required property bool externalHovered

    property bool hasBeenHoveredSinceOpened: false
    property bool dismissIfNeverHovered: false
    property int exitGracePeriodMs: ShellMetrics.exitGracePeriodMs
    property int initialHoverGracePeriodMs: ShellMetrics.initialHoverGracePeriodMs

    signal dismissRequested()

    visible: false

    function scheduleDismissIfOutside(): void {
        // Jangan menutup panel sebelum kursor pernah masuk ke panel. Saat panel
        // dibuka lewat klik, overlay menutupi bar sehingga hover bar langsung
        // hilang dan panel ikut tertutup sebelum kursor sempat berpindah.
        if (active && hasBeenHoveredSinceOpened && !panelHovered && !externalHovered)
            exitGraceTimer.restart();
    }

    onPanelHoveredChanged: {
        if (panelHovered) {
            hasBeenHoveredSinceOpened = true;
            exitGraceTimer.stop();
        } else if (hasBeenHoveredSinceOpened) {
            scheduleDismissIfOutside();
        }
    }

    onExternalHoveredChanged: {
        if (externalHovered)
            exitGraceTimer.stop();
        else
            scheduleDismissIfOutside();
    }

    onActiveChanged: {
        if (active) {
            hasBeenHoveredSinceOpened = panelHovered;
            initialHoverTimer.restart();
        } else {
            initialHoverTimer.stop();
            exitGraceTimer.stop();
        }
    }

    Timer {
        id: exitGraceTimer
        interval: root.exitGracePeriodMs
        onTriggered: {
            if (root.active && !root.panelHovered && !root.externalHovered)
                root.dismissRequested();
        }
    }

    // Timer awal hanya aktif bila dismissIfNeverHovered = true (perilaku lama).
    Timer {
        id: initialHoverTimer
        interval: root.initialHoverGracePeriodMs
        onTriggered: {
            if (root.dismissIfNeverHovered && root.active
                    && !root.panelHovered && !root.externalHovered)
                root.dismissRequested();
        }
    }
}
