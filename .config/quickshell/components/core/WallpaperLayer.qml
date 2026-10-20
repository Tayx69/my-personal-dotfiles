import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import "../../services"
import "../common"
import "../state"
import "../theme"

// Lapisan wallpaper statis dengan bingkai membulat dan bayangan dalam.
// Tidak ada transisi atau pergantian wallpaper; sumbernya satu gambar dari
// WallpaperService. Lapisan ini juga memulai urutan animasi masuk (StartupState)
// yang ditunggu oleh status bar, jadi jangan dihapus tanpa mengganti itu.
PanelWindow {
    id: root

    required property var modelData
    readonly property var targetScreen: modelData
    readonly property bool barOnTop: SettingsService.statusBarPosition === "top"
    readonly property real reservedBarHeight: SettingsService.statusBarAutoHide
        ? 0 : ShellMetrics.statusBarHeight

    // Tanpa file wallpaper-selection, lapisan ini transparan sehingga wallpaper
    // dari program lain (mis. awww) tetap terlihat di belakangnya.
    readonly property bool externalWallpaper: WallpaperService.source.toString() === ""

    property real margin: 0
    property real cornerRadius: ShellMetrics.desktopFrameRadius
    property bool startupIntroStarted: false

    function startStartupIntro(): void {
        if (startupIntroStarted)
            return;

        startupIntroStarted = true;
        StartupState.startSequence(targetScreen.name);
        startupIntro.start();
    }

    // Tidak menunggu gambar siap: tanpa wallpaper pun bar harus tetap muncul.
    Component.onCompleted: {
        DisplayedWallpaperState.setSource(targetScreen.name, WallpaperService.source);
        startStartupIntro();
    }

    Connections {
        target: WallpaperService

        function onSourceChanged() {
            DisplayedWallpaperState.setSource(root.targetScreen.name, WallpaperService.source);
        }
    }

    screen: targetScreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    mask: Region {}

    Rectangle {
        id: solidBlock

        visible: !root.externalWallpaper
        anchors.fill: parent
        color: Theme.shellBackgroundColor
        opacity: 0
    }

    ClippingRectangle {
        id: wallpaperFrame

        visible: !root.externalWallpaper
        x: root.margin
        y: root.height
        width: root.width - root.margin * 2
        height: root.height - root.margin * 2
        radius: root.cornerRadius
        color: Theme.wallpaperFallbackColor
        contentUnderBorder: true

        Image {
            anchors.fill: parent
            source: WallpaperService.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            mipmap: true
        }
    }

    ShaderEffect {
        anchors {
            top: parent.top
            topMargin: root.barOnTop ? root.reservedBarHeight : 0
            right: parent.right
            bottom: parent.bottom
            bottomMargin: root.barOnTop ? 0 : root.reservedBarHeight
            left: parent.left
        }

        property vector2d surfaceSize: Qt.vector2d(width, height)
        property real cornerRadius: ShellMetrics.radiusLarge
        property real shadowSize: ShellMetrics.shadowSize
        property color shadowColor: Theme.shellShadowColor

        fragmentShader: Qt.resolvedUrl("../../shaders/inner-shadow.frag.qsb")
    }

    SequentialAnimation {
        id: startupIntro

        MotionAnimation {
            group: "wallpaper"
            type: MotionAnimation.DefaultEffects
            target: solidBlock
            property: "opacity"
            from: 0
            to: 1
        }

        MotionAnimation {
            group: "wallpaper"
            target: wallpaperFrame
            property: "y"
            from: root.height
            to: root.margin
        }

        onFinished: {
            StartupState.finishMaskReveal(root.targetScreen.name);
            DisplayedWallpaperState.setSource(root.targetScreen.name,
                WallpaperService.source);
        }
    }
}
