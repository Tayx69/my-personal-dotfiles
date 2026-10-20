import QtQuick
import "../theme"

// Lekukan cekung kecil (seperti sambungan bar -> menu). Warna sama dengan bar.
// side: "left"  -> diletakkan di sisi KIRI panel (panel ada di kanan fillet)
//       "right" -> diletakkan di sisi KANAN panel
Canvas {
    id: root

    property string side: "left"
    property real size: 22 * ShellMetrics.uiScale
    property color color: Theme.barColor

    width: size
    height: size
    antialiasing: true

    onColorChanged: requestPaint()
    onSideChanged: requestPaint()
    onSizeChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        const r = width;
        ctx.clearRect(0, 0, width, height);
        ctx.fillStyle = root.color;
        ctx.beginPath();
        if (root.side === "left") {
            ctx.moveTo(0, 0);
            ctx.lineTo(r, 0);
            ctx.lineTo(r, r);
            ctx.arc(0, r, r, 0, -Math.PI / 2, true);
        } else {
            ctx.moveTo(r, 0);
            ctx.lineTo(0, 0);
            ctx.lineTo(0, r);
            ctx.arc(r, r, r, Math.PI, Math.PI * 1.5, false);
        }
        ctx.closePath();
        ctx.fill();
    }
}
