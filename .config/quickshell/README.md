# JAQC-shell (versi Hyprland, disederhanakan)

Fork ringkas dari [JAQC-shell](https://github.com/MystiaFin/shell) yang aslinya untuk Niri.
Dipindahkan ke **Hyprland (config Lua, 0.55+)** dan dibuang bagian yang tidak perlu.

> Belum diuji langsung di mesin nyata (disiapkan lewat pembacaan kode dan pemeriksaan
> rujukan statis). Kalau ada error, jalankan `qs -c <nama>` dari terminal dan baca pesannya.

## Yang berubah dari aslinya

**Diganti untuk Hyprland**
- `services/NiriService.qml` → `services/CompositorService.qml` (memakai `Quickshell.Hyprland`,
  bentuk datanya sama sehingga widget lain tidak berubah).
- Pindah workspace memakai dispatch Lua: `hl.dsp.focus({ workspace = '<id>' })`.
- Logout memakai `hyprctl dispatch "hl.dsp.exit()"`. Pengguna **uwsm** sebaiknya ganti ke `uwsm stop`
  (`widgets/powermenu/PowerMenu.qml`).
- Logo di bar diganti dari NixOS ke Arch. Font teks diganti dari Poppins ke Rubik
  (`components/theme/Typography.qml`).

**Dibuang**
- Ganti wallpaper: picker, shuffle, transisi, perintah launcher dan IPC `wallpaper`.
- Perubahan warna: palet dinamis dari wallpaper, Gruvbox, ganti tema, tombol terang/gelap.
  Sekarang satu palet tetap (Catppuccin, `components/theme/palettes/Catppuccin.qml`).
- Semua theme integration (GTK, kitty/foot, tmux, Vesktop, Spotify, btop, cava) dan aset ikonnya.
- Desktop overview, widget melayang, cuaca, dan CPU (semuanya bergantung pada sistem wallpaper).
- Halaman pengaturan Colors, Wallpaper, Floating widgets, dan Integrations.

**Dipertahankan**
- Status bar, Control Center (volume, mic, media + cava), Utility Center (notifikasi, WiFi, Bluetooth,
  kalender, brightness), power menu, launcher (+ mode `>` dan tmux), notifikasi, lockscreen (PAM),
  auto-lock lewat swayidle, dan jendela pengaturan.

## Wallpaper statis

Wallpaper tidak bisa diganti lewat UI. Tulis path gambar sekali ke:

```sh
echo ~/Pictures/wall.jpg > ~/.config/quickshell/wallpaper-selection
```

Gambar ini dipakai sebagai wallpaper desktop dan latar lockscreen. Kalau file kosong, yang tampil
hanya warna latar polos. Kalau kamu memakai hyprpaper/swww, kosongkan saja file itu.

## Pasang

```sh
mkdir -p ~/.config/quickshell
cp -r JAQC-shell-hyprland ~/.config/quickshell/jaqc
qs -c jaqc
```

## Keybind (Hyprland Lua)

```lua
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("qs -c jaqc ipc call launcher toggle"))
hl.bind("SUPER + L",     hl.dsp.exec_cmd("qs -c jaqc ipc call lockscreen lock"))
```
Cek `qs ipc --help` kalau urutan opsi `-c` pada versimu berbeda.

## Dependensi

- **Quickshell 0.3** dengan modul Wayland, PAM, Networking, Bluetooth, Notifications, Mpris
- **Hyprland** (config Lua) dengan `HYPRLAND_INSTANCE_SIGNATURE` tersedia
- Font: JetBrainsMono Nerd Font, Symbols Nerd Font, Material Design Icons
- `cava`, `wpctl` (WirePlumber), `brightnessctl`, `swayidle` (untuk auto-lock), `networkmanager`, `bluez`

## Struktur

```text
components/   primitif shell, state, efek, tema (satu palet)
services/     pengaturan, audio, jaringan, media, notifikasi, CompositorService (Hyprland)
widgets/      status bar, launcher, panel, notifikasi, pengaturan, power menu
shaders/      efek visual (inner shadow, sdf liquid)
shell.qml     root
```
