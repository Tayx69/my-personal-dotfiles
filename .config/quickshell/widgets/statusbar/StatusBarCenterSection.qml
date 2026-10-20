import QtQuick
import "../../components/common"
import "../../components/state"
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property date currentTime
    readonly property string timePattern: SettingsService.clock24Hour
        ? (SettingsService.clockShowSeconds ? "HH:mm:ss" : "HH:mm")
        : (SettingsService.clockShowSeconds ? "hh:mm:ss AP" : "hh:mm AP")

    implicitWidth: content.width
    implicitHeight: 26
    visible: SettingsService.statusBarShowAudio
        || (SettingsService.statusBarShowMedia && MediaService.available)
        || SettingsService.statusBarShowClock

    component BarText: Text {
        height: 26
        color: Theme.barTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 14
        font.weight: Font.Light
        verticalAlignment: Text.AlignVCenter
    }

    Row {
        id: content
        height: parent.height
        spacing: 2

        Rectangle {
            visible: SettingsService.statusBarShowAudio
            width: visible ? controls.width + 22 : 0
            height: 26
            radius: height / 2
            color: Theme.barPillColor

            HoverHandler { cursorShape: Qt.PointingHandCursor }
            MouseArea {
                anchors.fill: parent
                z: -1
                cursorShape: Qt.PointingHandCursor
                onClicked: OverlayState.toggleControlCenter()
            }

            Row {
                id: controls
                height: parent.height
                anchors.centerIn: parent
                spacing: 10

                Row {
                    id: volumeRow
                    property bool showValue: false
                    height: parent.height
                    spacing: showValue ? 5 : 0

                    WheelHandler {
                        onWheel: event => AudioService.setVolume(AudioService.displayVolume
                            + (event.angleDelta.y > 0 ? 0.01 : -0.01))
                    }

                    Timer { id: volumeHide; interval: 1400; onTriggered: volumeRow.showValue = false }
                    Connections {
                        target: AudioService
                        function onVolumeChanged() { volumeRow.showValue = true; volumeHide.restart(); }
                    }

                    StatusRing {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        value: AudioService.displayVolume
                        ringWidth: 2.5
                        backgroundColor: Theme.barTrackColor
                        icon: AudioService.muted ? Icons.volumeMuted : Icons.volume
                        iconSize: 13
                        iconColor: AudioService.muted ? Theme.barMutedTextColor : Theme.barTextColor
                        ringColor: AudioService.muted ? Theme.barMutedTextColor : Theme.barAccentColor
                        onClicked: OverlayState.toggleControlCenter()
                        onScrolled: delta => AudioService.setVolume(AudioService.displayVolume + delta)
                    }

                    BarText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Math.round(AudioService.volume * 100) + "%"
                        color: Theme.barTextColor
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        clip: true
                        width: volumeRow.showValue && !AudioService.muted ? implicitWidth : 0
                        opacity: volumeRow.showValue && !AudioService.muted ? 1 : 0
                        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 140 } }
                    }
                }

                Row {
                    id: micRow
                    property bool showValue: false
                    height: parent.height
                    spacing: showValue ? 5 : 0

                    WheelHandler {
                        onWheel: event => AudioService.setMicrophoneVolume(AudioService.displayMicrophoneVolume
                            + (event.angleDelta.y > 0 ? 0.01 : -0.01))
                    }

                    Timer { id: micHide; interval: 1400; onTriggered: micRow.showValue = false }
                    Connections {
                        target: AudioService
                        function onMicrophoneVolumeChanged() { micRow.showValue = true; micHide.restart(); }
                    }

                    StatusRing {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        value: AudioService.displayMicrophoneVolume
                        ringWidth: 2.5
                        backgroundColor: Theme.barTrackColor
                        icon: AudioService.microphoneMuted ? Icons.microphoneMuted : Icons.microphone
                        iconSize: 13
                        iconColor: AudioService.microphoneMuted ? Theme.barMutedTextColor : Theme.barTextColor
                        ringColor: AudioService.microphoneMuted ? Theme.barMutedTextColor : Theme.barAccentColor
                        onClicked: OverlayState.toggleControlCenter()
                        onScrolled: delta => AudioService.setMicrophoneVolume(
                            AudioService.displayMicrophoneVolume + delta)
                    }

                    BarText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Math.round(AudioService.microphoneVolume * 100) + "%"
                        color: Theme.barTextColor
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        clip: true
                        width: micRow.showValue && !AudioService.microphoneMuted ? implicitWidth : 0
                        opacity: micRow.showValue && !AudioService.microphoneMuted ? 1 : 0
                        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 140 } }
                    }
                }
            }
        }

        Rectangle {
            visible: SettingsService.statusBarShowMedia && MediaService.available
            width: visible ? mediaRow.width + 20 : 0
            height: 26
            radius: height / 2
            color: Theme.barPillColor

            HoverHandler { cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: OverlayState.toggleControlCenter() }

            Row {
                id: mediaRow
                height: parent.height
                anchors.centerIn: parent
                spacing: 7

                Text {
                    height: parent.height
                    text: Icons.media
                    color: Theme.barAccentColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                }

                BarText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(180, implicitWidth)
                    text: MediaService.artist !== ""
                        ? MediaService.artist + " - " + MediaService.title
                        : MediaService.title
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }
            }
        }

        BarText {
            visible: SettingsService.statusBarShowClock
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 8
            text: Qt.formatTime(root.currentTime, root.timePattern) + "  •  "
                + Typography.japaneseWeekday(root.currentTime) + ", "
                + Qt.formatDate(root.currentTime, "dd MMM yyyy")
            font.pixelSize: 15
        }
    }
}
