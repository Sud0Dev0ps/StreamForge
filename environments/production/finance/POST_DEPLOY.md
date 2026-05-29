# Finance Stack — Post Deploy Notes

## Setup Steps

1. Create the network:
```bash
   bash setup-network.sh
```

2. Create config directories:
```bash
   sudo mkdir -p /opt/appdata/mariadb
   sudo mkdir -p /opt/appdata/firefly/upload
   sudo chown -R serveradmin:serveradmin /opt/appdata/mariadb
   sudo chown -R www-data:www-data /opt/appdata/firefly/upload
```

3. Copy `.env` and populate with real values:
```bash
   cp env.example .env
```

4. Validate compose:
```bash
   docker compose config
```

5. Bring up MariaDB first and verify healthy before starting Firefly:
```bash
   docker compose up -d mariadb
   docker compose logs mariadb
   docker compose up -d firefly
```

6. Verify Firefly at http://dockerserver:8090

## Rollback Plan

```bash
docker compose down
cd /opt/docker/firefly
docker compose up -d
```

## Network
- Network: finance_network_prod
- Subnet: 172.33.0.0/16

## Data Paths
- MariaDB: /opt/appdata/mariadb
- Firefly uploads: /opt/appdata/firefly/upload

## Notes
- MariaDB data migrated from named volume `firefly_mariadb_data` to bind mount
- Backup taken pre-migration: mariadb_backup_20260529.sql (stored on NAS + MacBook)
- APP_KEY must match original — do not regenerate or all encrypted data is lost