#!/usr/bin/env bash
set -euo pipefail

# --- settings ---
REMOTE_NAME="tob_drive"                 # rclone remote name you created
LOCAL_DIR="$HOME/TOB_GDrive"            # local mirror folder
LOG_DIR="$HOME/.local/share/rclone"
SYSTEMD_DIR="$HOME/.config/systemd/user"
SERVICE_NAME="tob-bisync.service"
TIMER_NAME="tob-bisync.timer"

# --- prep ---
mkdir -p "$LOCAL_DIR" "$LOG_DIR" "$SYSTEMD_DIR"

# stop & clean old units quietly (if any)
systemctl --user disable --now "$TIMER_NAME" 2>/dev/null || true
rm -f "$SYSTEMD_DIR/$SERVICE_NAME" "$SYSTEMD_DIR/$TIMER_NAME"

# --- one-time baseline (two-way) ---
# NOTE: fixed cap for deletions because your rclone does not support percentages.
rclone bisync "$REMOTE_NAME:" "$LOCAL_DIR" --resync \
  --drive-export-formats docx,xlsx,pptx,pdf \
  --max-delete=100 \
  --progress

# --- create service ---
cat > "$SYSTEMD_DIR/$SERVICE_NAME" <<EOF
[Unit]
Description=Rclone TOB Drive <-> Local bisync

[Service]
Type=oneshot
ExecStart=/usr/bin/rclone bisync $REMOTE_NAME: $LOCAL_DIR \
  --drive-export-formats docx,xlsx,pptx,pdf \
  --log-file $LOG_DIR/tob_bisync.log \
  --log-level NOTICE \
  --max-delete=100
EOF

# --- create timer (every 2 minutes) ---
cat > "$SYSTEMD_DIR/$TIMER_NAME" <<'EOF'
[Unit]
Description=Run TOB bisync every 2 minutes

[Timer]
OnBootSec=2min
OnUnitActiveSec=2min
AccuracySec=30s
Persistent=true

[Install]
WantedBy=default.target
EOF

# --- enable timer ---
systemctl --user daemon-reload
systemctl --user enable --now "$TIMER_NAME"

echo
echo "Local folder : $LOCAL_DIR"
echo "Log file     : $LOG_DIR/tob_bisync.log"
echo
systemctl --user status "$TIMER_NAME" --no-pager || true

