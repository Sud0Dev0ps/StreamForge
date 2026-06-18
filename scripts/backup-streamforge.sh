#!/bin/bash

set -e

echo "=== StreamForge Backup Started ==="

BACKUP_DIR="/mnt/data/backups/streamforge"

echo "Backing up /opt/appdata..."
rsync -avh --delete /opt/appdata/ "$BACKUP_DIR/appdata/"

echo "Backing up .env files..."
cp ~/StreamForge/environments/production/media/.env \
   "$BACKUP_DIR/env/media.env"

cp ~/StreamForge/environments/production/finance/.env \
   "$BACKUP_DIR/env/finance.env"

cp ~/StreamForge/environments/production/infrastructure/.env \
   "$BACKUP_DIR/env/infrastructure.env"

echo "Backing up compose files..."
cp ~/StreamForge/environments/production/media/docker-compose.yml \
   "$BACKUP_DIR/manifests/"

cp ~/StreamForge/environments/production/finance/docker-compose.yml \
   "$BACKUP_DIR/manifests/"

cp ~/StreamForge/environments/production/infrastructure/docker-compose.yml \
   "$BACKUP_DIR/manifests/"

echo "Backing up documentation..."
cp ~/StreamForge/docs/disaster-recovery.md \
   "$BACKUP_DIR/docs/"

echo "=== Backup Complete ==="