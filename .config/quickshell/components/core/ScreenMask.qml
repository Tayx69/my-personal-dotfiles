import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import "../theme"
import "../../services"

PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData

    property real cornerRadius: ShellMetrics.radiusLarge
    property real topInset: SettingsService.statusBarPosition === "top"
        && !SettingsService.statusBarAutoHide ? ShellMetrics.statusBarHeight : 0
    property real bottomInset: SettingsService.statusBarPosition === "bottom"
        && !SettingsService.statusBarAutoHide ? ShellMetrics.statusBarHeight : 0

    screen: targetScreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "screen-mask"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {
        item: container
        intersection: Intersection.Xor
    }

    Item {
        id: container
        anchors.fill: parent

        // Hanya lekukan tepat di bawah bar atas (sudut bawah layar dibiarkan lurus).
        Item {
            id: cornerClip
            anchors {
                left: parent.left
                right: parent.right
                top: root.topInset > 0 ? parent.top : undefined
                bottom: root.topInset > 0 ? undefined : parent.bottom
            }
            height: (root.topInset > 0 ? root.topInset : root.bottomInset) + root.cornerRadius
            clip: true

            Rectangle {
                x: 0
                y: root.topInset > 0
                    ? root.topInset
                    : cornerClip.height - root.bottomInset - (root.height - root.topInset - root.bottomInset)
                width: root.width
                height: root.height - root.topInset - root.bottomInset
                color: Theme.barColor

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskSource: roundedMask
                    maskEnabled: true
                    maskInverted: true
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1
                }
            }
        }

        Item {
            id: roundedMask
            anchors {
                top: parent.top
                topMargin: root.topInset
                right: parent.right
                bottom: parent.bottom
                bottomMargin: root.bottomInset
                left: parent.left
            }
            layer.enabled: true
            visible: false

            Rectangle {
                anchors.fill: parent
                radius: root.cornerRadius
            }
        }
    }
}
