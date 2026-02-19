#!/bin/bash

# Configuration
LOCAL_PATH="/run/media/josef/"
SMB_SHARE="//10.6.1.49/HLA1_PVE_local/josef-Xd1-gpu0"
SMB_USER="josef_smb-apfs"
MOUNT_POINT="/mnt/josef-Xd1-gpu0"
OP_ITEM_UUID="gvjim7hpb4tyq5xotg3myfwbem"

# Exclusion list - add paths relative to LOCAL_PATH
EXCLUDE_PATHS=(
  "lost+found"
  ".Trash*"
  "Games/SteamLibrary/*"                 # Exclude entire Steam library (redownloadable)
  "Games/Heroic/*"                       # Exclude Heroic/Epic games (redownloadable)
  "Games/GameData/BeamNG/current/temp/*" # BeamNG temp files (auto-regenerated cache)
  "SteamRecordings/video/*"
  "SteamRecordings/timelines/*"
  "SteamRecordings/gamerecording.pb"
)

# Function to get SMB password from 1Password
get_smb_password() {
  if ! command -v op &>/dev/null; then
    echo "Error: 1Password CLI (op) not found." >&2
    echo "Install with: brew install 1password-cli" >&2
    exit 1
  fi

  # Get password from 1Password - need --reveal to get actual password
  PASSWORD=$(op item get "$OP_ITEM_UUID" --fields password --reveal 2>&1)
  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Could not retrieve password from 1Password" >&2
    echo "Output: $PASSWORD" >&2
    echo "" >&2
    echo "Make sure you're signed in: op signin" >&2
    exit 1
  fi

  if [ -z "$PASSWORD" ]; then
    echo "Error: Password retrieved but is empty" >&2
    exit 1
  fi

  echo "$PASSWORD"
}

# Function to mount SMB share
mount_smb() {
  # Check if already mounted
  if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    echo "SMB share already mounted at $MOUNT_POINT"
    return 0
  fi

  # Create mount point with sudo (required for /mnt)
  if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
  fi

  echo "Mounting SMB share to $MOUNT_POINT..."

  # Get password from 1Password
  SMB_PASSWORD=$(get_smb_password)

  # Strip any trailing whitespace/newlines
  SMB_PASSWORD=$(echo -n "$SMB_PASSWORD" | tr -d '\n\r')

  # Create temporary credentials file
  CRED_FILE=$(mktemp)
  printf "username=%s\npassword=%s\n" "$SMB_USER" "$SMB_PASSWORD" >"$CRED_FILE"
  chmod 600 "$CRED_FILE"

  # Mount using credentials file
  sudo mount -t cifs "$SMB_SHARE" "$MOUNT_POINT" \
    -o credentials="$CRED_FILE",uid="$(id -u)",gid="$(id -g)" 2>&1

  MOUNT_RESULT=$?

  # Clean up credentials file
  rm -f "$CRED_FILE"

  if [ $MOUNT_RESULT -ne 0 ]; then
    echo "Failed to mount SMB share"
    echo "Check: 1Password password, network connection, or server availability"
    exit 1
  fi

  echo "Mounted successfully"
}

# Function to build exclude arguments for rsync
build_exclude_args() {
  EXCLUDE_ARGS=()
  EXCLUDE_ARGS+=(--exclude="System Volume Information")
  EXCLUDE_ARGS+=(--exclude="\$RECYCLE.BIN")
  EXCLUDE_ARGS+=(--exclude="pagefile.sys")
  EXCLUDE_ARGS+=(--exclude="hiberfil.sys")
  for path in "${EXCLUDE_PATHS[@]}"; do
    EXCLUDE_ARGS+=(--exclude="$path")
  done
}

# Function to perform the sync operation
run_sync() {
  local DIRECTION="$1"
  local DELETE_FLAG="$2"

  build_exclude_args

  # Build rsync command arguments
  RSYNC_ARGS=(
    -rh                # recursive, human-readable (removed -a for speed)
    --itemize-changes  # show what's happening per file
    --progress         # show per-file progress (needed for current file visibility)
    --partial          # resume interrupted transfers
    --sparse           # handle sparse files efficiently
    --modify-window=60 # tolerate up to 60-second timestamp differences (for SMB quirks)
  )

  # Add delete flag if syncing TO remote
  if [ "$DELETE_FLAG" = "with_delete" ]; then
    RSYNC_ARGS+=(--delete-after) # delete AFTER transfer (safer for case-insensitive SMB)
  fi

  # Add exclude arguments
  RSYNC_ARGS+=("${EXCLUDE_ARGS[@]}")

  # Set source and destination based on direction
  if [ "$DIRECTION" = "to_remote" ]; then
    echo "Syncing TO remote (local -> remote, WITH DELETE)..."
    RSYNC_ARGS+=("$LOCAL_PATH" "$MOUNT_POINT/")
  else
    echo "Syncing FROM remote (remote -> local, no delete)..."
    RSYNC_ARGS+=("$MOUNT_POINT/" "$LOCAL_PATH")
  fi

  echo ""

  # Execute rsync
  rsync "${RSYNC_ARGS[@]}"
  RSYNC_EXIT=$?

  echo ""

  if [ $RSYNC_EXIT -eq 0 ]; then
    echo "Sync completed successfully!"
  else
    echo "Warning: rsync exited with code $RSYNC_EXIT"
    echo "Some files may not have been transferred."
    return $RSYNC_EXIT
  fi
}

# Function to cleanup (unmount share)
cleanup() {
  if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    echo "Unmounting $MOUNT_POINT..."
    sudo umount "$MOUNT_POINT"
    sudo rmdir "$MOUNT_POINT" 2>/dev/null
    echo "Done!"
  fi
}

# Show usage if no arguments
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 {to|from|dry-run-to|dry-run-from}"
  echo ""
  echo "Sync between local and remote SMB storage:"
  echo "  Local:  $LOCAL_PATH"
  echo "  Remote: $SMB_SHARE"
  echo ""
  echo "Commands:"
  echo "  to            - Sync local -> remote (DELETES extra files on remote to mirror local)"
  echo "  from          - Sync remote -> local (does NOT delete local files)"
  echo "  dry-run-to    - Preview what would be synced TO remote (no changes made)"
  echo "  dry-run-from  - Preview what would be synced FROM remote (no changes made)"
  echo ""
  echo "Share is automatically mounted and unmounted for each operation."
  echo ""
  echo "Performance optimizations:"
  echo "  - Removed archive mode (-a) for faster SMB transfers"
  echo "  - Removed verbose mode (-v) to reduce I/O overhead"
  echo "  - Added --partial for resuming interrupted large file transfers"
  echo "  - Using --itemize-changes for structured progress output"
  echo "  - Using --delete-after for safer deletions on case-insensitive SMB"
  exit 0
fi

# Handle commands
case "$1" in
to)
  mount_smb
  echo ""
  run_sync "to_remote" "with_delete"
  cleanup
  ;;
from)
  mount_smb
  echo ""
  run_sync "from_remote" "no_delete"
  cleanup
  ;;
dry-run-to)
  mount_smb
  echo ""
  echo "DRY RUN: Previewing sync TO remote (local -> remote)..."
  echo "No files will be modified."
  echo ""
  build_exclude_args
  rsync -rh \
    --dry-run \
    --itemize-changes \
    --delete \
    --sparse \
    --modify-window=2 \
    "${EXCLUDE_ARGS[@]}" \
    "$LOCAL_PATH" "$MOUNT_POINT/"
  echo ""
  echo "Dry run complete. No changes were made."
  cleanup
  ;;
dry-run-from)
  mount_smb
  echo ""
  echo "DRY RUN: Previewing sync FROM remote (remote -> local)..."
  echo "No files will be modified."
  echo ""
  build_exclude_args
  rsync -rh \
    --dry-run \
    --itemize-changes \
    --sparse \
    --modify-window=2 \
    "${EXCLUDE_ARGS[@]}" \
    "$MOUNT_POINT/" "$LOCAL_PATH"
  echo ""
  echo "Dry run complete. No changes were made."
  cleanup
  ;;
umount | unmount)
  if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    echo "Unmounting $MOUNT_POINT..."
    sudo umount "$MOUNT_POINT"
    sudo rmdir "$MOUNT_POINT" 2>/dev/null
    echo "Unmounted and cleaned up"
  else
    echo "Not mounted"
    # Clean up folder if it exists but isn't mounted
    if [ -d "$MOUNT_POINT" ]; then
      sudo rmdir "$MOUNT_POINT" 2>/dev/null && echo "Cleaned up empty mount point"
    fi
  fi
  ;;
*)
  echo "Error: Unknown command '$1'"
  echo "Usage: $0 {to|from|dry-run-to|dry-run-from}"
  echo ""
  echo "Advanced: 'umount' command available for manual cleanup if needed"
  exit 1
  ;;
esac
