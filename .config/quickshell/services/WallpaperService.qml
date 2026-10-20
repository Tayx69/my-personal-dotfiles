pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Satu wallpaper statis (tanpa picker, shuffle, atau transisi).
// Dipakai oleh lapisan wallpaper dan lockscreen.
//
// Atur sekali dengan menulis path gambar ke:
//   ~/.config/quickshell/wallpaper-selection
//   contoh: echo ~/Pictures/wall.jpg > ~/.config/quickshell/wallpaper-selection
// Kalau file kosong/tidak ada, yang tampil hanya warna latar polos.
Singleton {
    id: root

    readonly property string homeDirectory: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
        || homeDirectory + "/.config"

    readonly property url source: {
        const saved = selectionFile.text().trim();
        if (saved === "")
            return "";
        if (saved.startsWith("file://"))
            return saved;
        return localFileUrl(expandedPath(saved));
    }

    function expandedPath(pathValue): string {
        let path = (pathValue || "").trim();
        if ((path.startsWith("\"") && path.endsWith("\""))
                || (path.startsWith("'") && path.endsWith("'")))
            path = path.slice(1, -1);
        if (path === "~")
            path = homeDirectory;
        else if (path.startsWith("~/"))
            path = homeDirectory + path.slice(1);
        return path.split("${HOME}").join(homeDirectory)
            .split("$HOME").join(homeDirectory);
    }

    function localFileUrl(pathValue): string {
        return "file://" + pathValue.split("/")
            .map(part => encodeURIComponent(part)).join("/");
    }

    FileView {
        id: selectionFile
        path: root.configHome + "/quickshell/wallpaper-selection"
        printErrors: false
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }
}
