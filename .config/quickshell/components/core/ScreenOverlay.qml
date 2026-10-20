import "../../services"
import "../../widgets/controlcenter"
import "../../widgets/launcher"
import "../../widgets/notifications"
import "../../widgets/powermenu"
import "../../widgets/utilitycenter"
import "../state"
import "../theme"

EdgeOverlayWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData
    screen: targetScreen

    readonly property bool barOnTop: SettingsService.statusBarPosition === "top"
        && !SettingsService.statusBarAutoHide
    readonly property real barBottom: ShellMetrics.statusBarHeight

    EdgePanel {
        id: powerPanel
        host: root
        edge: EdgePanel.Left
        edgeAlignment: EdgePanel.Start
        alongEdgeOffset: -10
        edgeOffset: ShellMetrics.panelScreenEdgeOverlap
        shown: OverlayState.powerMenuVisible
        closedWidthScale: 1
        targetWidth: 250
        targetHeight: 330
        radius: ShellMetrics.panelRadius
        motionStiffness: ShellMetrics.fastPanelSpringStiffness
        motionDamping: ShellMetrics.fastPanelSpringDamping
        closeMotionDamping: ShellMetrics.fastPanelCloseSpringDamping

        PowerMenu {
            anchors.fill: parent
        }
    }

    EdgePanel {
        id: utilityPanel
        host: root
        edge: EdgePanel.Right
        edgeAlignment: EdgePanel.Start
        alongEdgeOffset: -10
        edgeOffset: ShellMetrics.panelScreenEdgeOverlap
        shown: OverlayState.utilityCenterVisible
        wantsKeyboardFocus: true
        closedWidthScale: 1
        targetWidth: 360
        targetHeight: Math.max(1, Math.min(800, root.height - 96))
        radius: ShellMetrics.panelRadius
        motionStiffness: ShellMetrics.fastPanelSpringStiffness
        motionDamping: ShellMetrics.fastPanelSpringDamping
        closeMotionDamping: ShellMetrics.fastPanelCloseSpringDamping

        UtilityCenter {
            anchors.fill: parent
        }
    }

    EdgePanel {
        id: controlPanel
        host: root
        edge: EdgePanel.Top
        edgeAlignment: EdgePanel.Center
        edgeOffset: ShellMetrics.panelScreenEdgeOverlap
        shown: OverlayState.controlCenterVisible
        targetWidth: Math.max(1, Math.min(780, root.width - 64))
        targetHeight: 360
        radius: ShellMetrics.panelRadius
        motionStiffness: ShellMetrics.fastPanelSpringStiffness
        motionDamping: ShellMetrics.fastPanelSpringDamping
        closeMotionDamping: ShellMetrics.fastPanelCloseSpringDamping

        ControlCenter {
            anchors.fill: parent
        }
    }

    // Lekukan penyambung antara bar (atas) dan menu di bawahnya.
    BarFillet {
        visible: root.barOnTop
        side: "right"
        x: powerPanel.x + powerPanel.width - 0.5
        y: root.barBottom - 0.5
        opacity: powerPanel.motionProgress * powerPanel.motionProgress
    }

    BarFillet {
        visible: root.barOnTop
        side: "left"
        x: utilityPanel.x - width + 0.5
        y: root.barBottom - 0.5
        opacity: utilityPanel.motionProgress * utilityPanel.motionProgress
    }

    BarFillet {
        visible: root.barOnTop
        side: "left"
        x: controlPanel.x - width + 0.5
        y: root.barBottom - 0.5
        opacity: controlPanel.motionProgress * controlPanel.motionProgress
    }

    BarFillet {
        visible: root.barOnTop
        side: "right"
        x: controlPanel.x + controlPanel.width - 0.5
        y: root.barBottom - 0.5
        opacity: controlPanel.motionProgress * controlPanel.motionProgress
    }

    EdgePanel {
        id: launcherWidget

        host: root
        edge: EdgePanel.Bottom
        edgeAlignment: EdgePanel.Center
        edgeOffset: ShellMetrics.panelScreenEdgeOverlap
        shown: OverlayState.launcherVisible
        wantsKeyboardFocus: true
        focusTarget: launcher.focusTarget

        targetWidth: Math.max(1, Math.min(
            SettingsService.launcherWidth * SettingsService.uiScale,
            root.width - 80))
        targetHeight: launcher.desiredHeight
        radius: ShellMetrics.panelRadius
        motionStiffness: ShellMetrics.fastPanelSpringStiffness
        motionDamping: ShellMetrics.fastPanelSpringDamping
        closeMotionDamping: ShellMetrics.fastPanelCloseSpringDamping

        ApplicationLauncher {
            id: launcher
            anchors.fill: parent
            shown: launcherWidget.shown
            initialQuery: OverlayState.launcherInitialQuery
            requestSerial: OverlayState.launcherRequestSerial
            maximumHeight: Math.max(1, Math.min(620, root.height - 60))
            bottomPadding: ShellMetrics.panelContentInsetFromEdge

            onCloseRequested: OverlayState.hideLauncher()
        }
    }

    EdgePanel {
        host: root
        edge: EdgePanel.Right
        edgeAlignment: EdgePanel.End
        alongEdgeOffset: -24
        edgeOffset: ShellMetrics.panelScreenEdgeOverlap
        shown: NotificationService.popupNotificationCount > 0
            && !OverlayState.utilityCenterVisible
        closedWidthScale: 1
        targetWidth: 380
        targetHeight: notificationStack.desiredHeight
        radius: ShellMetrics.panelRadius

        NotificationStack {
            id: notificationStack
            anchors.fill: parent
            maximumHeight: Math.max(1, root.height - 112)
        }
    }

}
