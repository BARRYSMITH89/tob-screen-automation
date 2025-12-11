#!/usr/bin/env python3
"""
Taste of Belgium – digital signage screen player.

This script is a clean, reconstructed version of the player I use on a
Raspberry Pi in the shop. It assumes that:

- Promotional videos are stored in a local folder (VIDEO_DIR).
- `mpv` is installed on the system.
- The screen is mounted in portrait mode, so we rotate the video 270°.

On the Pi I run this script at boot (via systemd) so the video starts
automatically without keyboard or mouse.
"""

import subprocess
from pathlib import Path
import time

# Folder containing the video files (adjust as needed on the Pi)
VIDEO_DIR = Path("/home/pi/tob-screen-videos")

# File extension(s) to consider as videos
VIDEO_EXTENSIONS = {".mp4", ".mkv", ".mov"}


def find_video_file() -> Path:
    """Return the first video file found in VIDEO_DIR, or raise if none."""
    if not VIDEO_DIR.is_dir():
        raise FileNotFoundError(f"Video folder not found: {VIDEO_DIR}")

    for path in sorted(VIDEO_DIR.iterdir()):
        if path.suffix.lower() in VIDEO_EXTENSIONS:
            return path

    raise FileNotFoundError(f"No video files found in {VIDEO_DIR}")


def play_video_loop(video_path: Path) -> None:
    """
    Call mpv to play the given video in a fullscreen, muted, infinite loop,
    rotated 270° for a portrait display.
    """
    cmd = [
        "mpv",
        str(video_path),
        "--fs",                # fullscreen
        "--loop=inf",          # infinite loop
        "--mute=yes",          # no audio
        "--no-border",         # remove window border
        "--video-rotate=270",  # rotate video for portrait screen
    ]

    print("Running command:", " ".join(cmd))
    subprocess.run(cmd, check=False)


def main() -> None:
    # Small delay – on the Pi this gives the network/display time to settle.
    time.sleep(5)

    video = find_video_file()
    print(f"Playing video: {video}")
    play_video_loop(video)


if __name__ == "__main__":
    main()
