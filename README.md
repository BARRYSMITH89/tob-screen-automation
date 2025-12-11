# Taste of Belgium – Digital Signage Automation (Reconstructed)

This repository contains a clean, reconstructed version of the scripts I use to
automate an in-store digital signage screen for **Taste of Belgium**, a retail
chocolate shop.

In production, a Raspberry Pi is connected to a portrait-mounted TV in the shop
and plays a looping promotional video at boot with no keyboard or mouse. Video
files are synced from cloud storage so I can update the content remotely.

This repo shows the core ideas and code structure, without exposing any secrets
(rclone config, API keys, Wi-Fi details, etc.).

## Features

- Autoplays a muted, vertically rotated MP4 video at boot.
- Loops the current promotional video continuously.
- Designed to run unattended on a Raspberry Pi.
- Includes a bisync setup script used to sync content from cloud storage.

## Files

- `screen_player.py` – Python script that finds a video file and plays it using
  `mpv` in fullscreen, muted, rotated 270° (for a portrait TV), looping forever.
- `tob_bisync_setup.sh` – shell script used to configure and run `rclone bisync`
  for the Taste of Belgium video folder (no secrets included).
- `.gitignore` – ignore Python cache, logs and large video files.
- `README.md` – this documentation.

## How it works (high level)

1. Cloud storage (Google Drive / Dropbox) holds the promotional videos for the
   screen.
2. `rclone bisync` keeps a local folder on the Raspberry Pi in sync with that
   cloud folder.
3. At boot, the Raspberry Pi runs `screen_player.py` (via a systemd service).
4. The script finds the first MP4 video in the configured folder and hands it to
   `mpv` with the correct fullscreen / loop / rotation options.
5. The video plays on a continuous loop throughout opening hours.

> Note: The live production scripts on the Raspberry Pi cannot be accessed
> remotely at the moment, so this repository contains a reconstructed version
> that matches the same structure and behaviour for demonstration and
> portfolio purposes.
