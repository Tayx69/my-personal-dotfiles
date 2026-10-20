pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

        property real volume: 0
    property real microphoneVolume: 0
    property bool muted: false
    property bool microphoneMuted: false
    // Saat mute, tampilan dianggap 0 supaya jelas; volume asli tetap tersimpan di sistem.
    readonly property real displayVolume: muted ? 0 : volume
    readonly property real displayMicrophoneVolume: microphoneMuted ? 0 : microphoneVolume
    property real pendingVolume: 0
    property real pendingMicrophoneVolume: 0

    function setVolume(value: real): void {
        const clamped = Math.max(0, Math.min(1, value));
        if (root.muted && clamped > 0)
            setMuted(false);
        pendingVolume = clamped;
        root.volume = clamped;
        sinkWriteTimer.restart();
    }

    function setMicrophoneVolume(value: real): void {
        const clamped = Math.max(0, Math.min(1, value));
        if (root.microphoneMuted && clamped > 0)
            setMicrophoneMuted(false);
        pendingMicrophoneVolume = clamped;
        root.microphoneVolume = clamped;
        sourceWriteTimer.restart();
    }

    function setMuted(mute: bool): void {
        root.muted = mute;
        sinkMuteSetter.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@",
            mute ? "1" : "0"];
        sinkMuteSetter.running = true;
    }

    function setMicrophoneMuted(mute: bool): void {
        root.microphoneMuted = mute;
        sourceMuteSetter.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@",
            mute ? "1" : "0"];
        sourceMuteSetter.running = true;
    }

    function toggleMute(): void {
        setMuted(!root.muted);
    }

    function toggleMicrophoneMute(): void {
        setMicrophoneMuted(!root.microphoneMuted);
    }

    function readOutput(data: string, microphone: bool): void {
        const match = data.match(/Volume:\s+([0-9.]+)/);
        if (!match)
            return;

        if (microphone) {
            root.microphoneVolume = Number(match[1]);
            root.microphoneMuted = data.includes("MUTED");
        } else {
            root.volume = Number(match[1]);
            root.muted = data.includes("MUTED");
        }
    }

    Process {
        id: sinkReader
        running: true
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => root.readOutput(data, false)
        }
    }

    Process {
        id: sinkMuteSetter
        onExited: sinkReader.running = true
    }

    Process {
        id: sourceMuteSetter
        onExited: sourceReader.running = true
    }

    Process {
        id: sourceReader
        running: true
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: SplitParser {
            onRead: data => root.readOutput(data, true)
        }
    }

    Process {
        id: sinkSetter
        onExited: sinkReader.running = true
    }

    Process {
        id: sourceSetter
        onExited: sourceReader.running = true
    }

    Timer {
        id: sinkWriteTimer
        interval: 40
        onTriggered: {
            if (sinkSetter.running) {
                restart();
                return;
            }
            sinkSetter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@",
                root.pendingVolume.toFixed(2)];
            sinkSetter.running = true;
        }
    }

    Timer {
        id: sourceWriteTimer
        interval: 40
        onTriggered: {
            if (sourceSetter.running) {
                restart();
                return;
            }
            sourceSetter.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@",
                root.pendingMicrophoneVolume.toFixed(2)];
            sourceSetter.running = true;
        }
    }

    Timer {
        id: refreshTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!sinkReader.running)
                sinkReader.running = true;
            if (!sourceReader.running)
                sourceReader.running = true;
        }
    }
}
