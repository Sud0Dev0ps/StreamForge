#!/bin/bash

set -euo pipefail

BACKUP_DIR="/mnt/data/backups/streamforge"
LOG_DIR="$BACKUP_DIR/logs"
LOG_FILE="$LOG_DIR/backup-$(date +%F).log"

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

log() {
  echo "$(timestamp) $1" | tee -a "$LOG_FILE"
}

fail() {
  log "ERROR: $1"
  exit 1
}

mkdir -p "$LOG_DIR" "$BACKUP_DIR/env" "$BACKUP_DIR/manifests" "$BACKUP_DIR/docs"

log "=== StreamForge Backup Started ==="

[ -d "/opt/appdata" ] || fail "/opt/appdata does not exist"
[ -d "$BACKUP_DIR" ] || fail "$BACKUP_DIR does not exist"

log "Backing up /opt/appdata..."
rsync -avh --no-owner --no-group --delete \
  --exclude 'mariadb/' \
  --exclude 'dockhand/' \
  /opt/appdata/ "$BACKUP_DIR/appdata/" >> "$LOG_FILE" 2>&1

log "Backing up .env files..."
cp ~/StreamForge/environments/production/media/.env "$BACKUP_DIR/env/media.env"
cp ~/StreamForge/environments/production/finance/.env "$BACKUP_DIR/env/finance.env"
cp ~/StreamForge/environments/production/infrastructure/.env "$BACKUP_DIR/env/infrastructure.env"
chmod 600 "$BACKUP_DIR"/env/*.env

log "Backing up compose files..."
cp ~/StreamForge/environments/production/media/docker-compose.yml "$BACKUP_DIR/manifests/media-docker-compose.yml"
cp ~/StreamForge/environments/production/finance/docker-compose.yml "$BACKUP_DIR/manifests/finance-docker-compose.yml"
cp ~/StreamForge/environments/production/infrastructure/docker-compose.yml "$BACKUP_DIR/manifests/infrastructure-docker-compose.yml"

log "Backing up documentation..."
cp ~/StreamForge/docs/disaster-recovery.md "$BACKUP_DIR/docs/disaster-recovery.md"

log "=== StreamForge Backup Complete ==="