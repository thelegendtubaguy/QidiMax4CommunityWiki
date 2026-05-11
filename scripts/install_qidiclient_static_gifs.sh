#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root, for example:" >&2
  echo "curl -fsSL https://raw.githubusercontent.com/thelegendtubaguy/QidiMax4CommunityWiki/main/scripts/install_qidiclient_static_gifs.sh | sudo bash" >&2
  exit 1
fi

REPO_REF="${REPO_REF:-main}"
ARCHIVE_URL="https://raw.githubusercontent.com/thelegendtubaguy/QidiMax4CommunityWiki/${REPO_REF}/files/qidiclient-static-gifs.tar.gz"
TARGET_DIR="/home/qidi/QIDI_Client/access"
BACKUP_DIR="$TARGET_DIR/.gif-backup-$(date +%Y%m%d-%H%M%S)"
TMP_DIR="$(mktemp -d)"
ARCHIVE="$TMP_DIR/qidiclient-static-gifs.tar.gz"
SOURCE_DIR="$TMP_DIR/static-gifs"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if [ ! -d "$TARGET_DIR" ]; then
  echo "Missing target directory: $TARGET_DIR" >&2
  exit 1
fi

curl -fsSL "$ARCHIVE_URL" -o "$ARCHIVE"

mkdir -p "$SOURCE_DIR"
tar -xzf "$ARCHIVE" -C "$SOURCE_DIR"
if [ ! -f "$SOURCE_DIR/block_popup/loading.gif" ]; then
  echo "Downloaded archive did not contain expected static GIFs." >&2
  exit 1
fi

mkdir -p "$BACKUP_DIR"
cd "$TARGET_DIR"
while IFS= read -r -d '' file; do
  mkdir -p "$BACKUP_DIR/$(dirname "$file")"
  cp -a "$file" "$BACKUP_DIR/$file"
done < <(find . -type f -name '*.gif' ! -path './.gif-backup-*/*' -print0)

cd "$SOURCE_DIR"
while IFS= read -r -d '' file; do
  install -D -o qidi -g netdev -m 755 "$file" "$TARGET_DIR/$file"
done < <(find . -type f -name '*.gif' -print0)

find "$TARGET_DIR" -type f -name '._*.gif' -delete
systemctl restart qidi-client.service
systemctl --no-pager --full status qidi-client.service | sed -n '1,12p'
echo "Installed static qidiclient GIFs."
echo "Backup: $BACKUP_DIR"
