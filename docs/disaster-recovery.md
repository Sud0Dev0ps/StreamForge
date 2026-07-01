# StreamForge Disaster Recovery Runbook

**Version:** 1.4
**Last Updated:** July 2026
**Status:** Active

---

## Purpose

This document describes the recovery procedures required to restore the StreamForge platform following infrastructure failure.

The objective is to restore service quickly and consistently while minimizing data loss.

This runbook focuses on **how to recover**. For service priority, RTO, RPO, and recovery classification, see [`docs/service-classifications.md`]

---

## Recovery Principle

> A backup does not exist until a restore has been proven.

| Backup type | Restore proven? |
|---|---|
| Homepage (appdata) | Yes — successful restore test June 2026 |
| MariaDB logical dump (Firefly III) |  **No** — dump integrity validated (gzip), but a real restore has **not** been performed. Treat Step 10 as untested until a dry run is completed. |

Until the MariaDB restore path is exercised end-to-end in a non-production test, it should be considered a **documented procedure**, not a **proven recovery capability**.

---

## Architecture Overview

**Production Server**
- Hostname: `dockerserver`
- Repository: `~/StreamForge`

**Source of Truth**

The GitHub repository is the source of truth for infrastructure definitions, stored at `~/StreamForge` in production. It contains:

- Docker Compose files
- Documentation
- Scripts
- Environment templates
- Homepage example configuration

---

## Docker Compose Projects

Current production state:

| Project | Expected Containers |
|---|---|
| media | 10 |
| finance | 2 |
| infrastructure | 1 |

Expected output:

```
finance          running(2)
infrastructure   running(1)
media            running(10)
```

Validate with:

```bash
docker compose ls
```

---

## Runtime Configuration

Application runtime configuration is stored outside the Git repository.

- **Live location:** `/opt/appdata`
- **Approximate size:** ~4 GB

Examples: Plex, Jellyfin, Sonarr, Radarr, Prowlarr, NZBGet, Homepage, Firefly III, MariaDB, Dockhand.

### Important Runtime Backup Notes

Most application configuration under `/opt/appdata` is backed up using `rsync`. Two directories are **intentionally excluded** from the general file backup:

```
/opt/appdata/mariadb/
/opt/appdata/dockhand/
```

#### MariaDB Exclusion

`/opt/appdata/mariadb/` is excluded from the general appdata rsync backup because:

- MariaDB data files are live database files — copying them while the engine is running is not a reliable backup method.
- The directory has restrictive ownership and permissions (UID `999:999`).
- Firefly III database data is instead backed up using a compressed **logical** MariaDB dump.

> **Rebuild implication:** because this directory is excluded from the appdata backup, a from-scratch rebuild will **not** restore `/opt/appdata/mariadb/`. It must be re-initialized fresh by the MariaDB container, with correct ownership set **before** first start (see Step 9).

#### Dockhand Exclusion

`/opt/appdata/dockhand/` is excluded from the general appdata rsync backup because:

- Dockhand contains a root-owned encryption key.
- Current permissions are restrictive.
- Ownership should not be changed casually while the service is healthy.

Dockhand backup remains an accepted short-term risk. **There is currently no recovery path for Dockhand** — if it does not come back up cleanly in Step 7, it must be reconfigured manually from scratch.

---

## Production Environment Files

Production `.env` files contain secrets and environment-specific values.

Live locations:

```
~/StreamForge/environments/production/media/.env
~/StreamForge/environments/production/finance/.env
~/StreamForge/environments/production/infrastructure/.env
```

> **Important:** these files are excluded from Git and must never be committed.

They are backed up daily to the NAS with restricted permissions.

- **Backup location:** `/mnt/streamforge-backups/env`
- **Expected backup permissions:** `-rw-------`

> **Verify on next backup review:** the restore commands in Step 4 assume the backup script writes per-stack files named `media.env`, `finance.env`, and `infrastructure.env`. Confirm this against the actual output of `backup-streamforge.sh` — if the script instead preserves `.env` as the filename inside per-stack subfolders, the restore commands need to match that structure exactly.

---

## NAS Storage

- **NAS mount:** `/mnt/data`
- **NAS export:** `192.168.10.2:/volume1/data`

The NAS provides media storage, download storage, and StreamForge backups.

Important paths:

```
/mnt/data/media
/mnt/data/downloads
/mnt/data/backups/streamforge
```

> **Dependency note:** `dockerserver` depends on this NFS mount being available *before* most containers (media library paths, backup targets) can start correctly. Validate the NAS mount immediately after confirming the host is reachable — don't wait until after Docker is validated (see Step 1/2 ordering below).

---

## Backup Strategy

### Backup Location

```
/mnt/streamforge-backups
├── appdata
├── db
├── env
├── docs
├── logs
└── manifests
```

### Backup Script

Location: `~/StreamForge/scripts/backup-streamforge.sh`

The backup script performs:

- `rsync` mirror of most of `/opt/appdata`
- Exclusion of raw MariaDB database files
- Exclusion of Dockhand appdata
- Compressed logical MariaDB dump for Firefly III
- Backup of production `.env` files
- Backup of Docker Compose manifest files
- Backup of disaster recovery documentation
- Timestamped logging
- Strict shell safety using `set -euo pipefail`

### Appdata Backup

Most application runtime data is mirrored from `/opt/appdata/` to `/mnt/data/backups/streamforge/appdata/` using `rsync` with Synology-compatible options:

```bash
rsync -a --no-owner --no-group /opt/appdata/ /mnt/data/backups/streamforge/appdata/
```

This avoids ownership and group preservation issues caused by the current Synology NFS user mapping. (Carried forward from the Homepage restore test — see Observations below — this can change ownership on restore and should be checked against LinuxServer containers, which are more permission-sensitive.)

### MariaDB Backup

Firefly III database data is backed up using a compressed logical MariaDB dump.

- **Backup location:** `/mnt/data/backups/streamforge/db`
- **Dump filename format:** `firefly-mariadb-YYYY-MM-DD.sql.gz`
- **Example:** `firefly-mariadb-2026-xx-xx.sql.gz`

The dump is created from inside the MariaDB container using the database variables from the finance `.env` file, compressed with `gzip`, and permissioned as `-rw-------`.

> Reminder (per StreamForge convention): use `mariadb-dump`, not `mysqldump`, and the inline password syntax `-p'PASSWORD'` to avoid interactive-prompt issues with output redirection.

#### MariaDB Backup Validation

Validate that the dump exists:

```bash
ls -lh /mnt/data/backups/streamforge/db/
```

Validate gzip integrity:

```bash
gzip -t /mnt/data/backups/streamforge/db/firefly-mariadb-$(date +%F).sql.gz
echo $?
```

Expected result: `0` — meaning the compressed database backup file is readable and not obviously corrupt. **This confirms the file is intact, not that a restore will succeed.**

### Backup Schedule

Backups run daily via cron:

```
0 12 * * * /home/serveradmin/StreamForge/scripts/backup-streamforge.sh
```

This runs once per day at midday.

> **Consideration for a future session:** a midday backup window captures the database mid-traffic rather than during a quiet period. This is a workable accepted tradeoff for a homelab, but worth revisiting once a maintenance window is defined

### Backup Logs

Backup logs are stored in `/mnt/streamforge-backups/logs`, e.g. `backup-YYYY-MM-DD.log`.

```bash
ls -lah /mnt/streamforge-backups/logs
tail -20 /mnt/streamforge-backups/logs/backup-YYYY-MM-DD.log
```

A successful backup log should include:

```
=== StreamForge Backup Started ===
Backing up /opt/appdata...
Backing up MariaDB database...
MariaDB backup created: /mnt/data/backups/streamforge/db/firefly-mariadb-YYYY-MM-DD.sql.gz
Backing up .env files...
Backing up compose files...
Backing up documentation...
=== StreamForge Backup Complete ===
```

---

## Critical Assets

**Critical** (required for recovery):
- GitHub repository
- `/opt/appdata` backup
- Production `.env` files
- MariaDB logical dump backup *(integrity validated; restore not yet proven — see Recovery Principle)*
- Password manager

**Important** (not fully protected by current strategy):
- NAS media library
- Dockhand configuration *(no recovery path currently exists — see Dockhand Exclusion above)*

**Disposable** (can be recreated):
- Downloads
- Temporary working data

**Legacy** (not part of current active recovery strategy — do not delete without validation):
- `/opt/docker-legacy`
- `/mnt/data/backups/docker`
- Docker named volumes under `/var/lib/docker/volumes`

---

## Known Constraints

| Constraint | Status |
|---|---|
| Backups run daily | Accepted |
| Appdata RPO is approximately 24 hours | Accepted |
| MariaDB database dump RPO is approximately 24 hours | Accepted |
| Raw MariaDB appdata is excluded from rsync | Accepted; database dump used instead |
| Dockhand appdata is excluded from rsync | Accepted short-term risk; no recovery path exists |
| Media library is not backed up | Accepted for now |
| Restore process is manual | Accepted for now |
| MariaDB restore procedure is documented but untested | **Open — should be exercised in a dry run** |
| `external: true` typo flagged in infrastructure compose (Session 30) | **Open — confirm fixed before relying on Step 6** |
| No offsite backup | Future improvement |
| Backup retention policy is basic | Future improvement |
| NAS permissions depend on current Synology mapping | Deferred to future NAS backup share session |

---

## Full Recovery Procedure

Use this process during a major outage or rebuild.

### Step 1 — Confirm Host and NAS Connectivity

**Goal:** Bring the production server back online and confirm its storage dependency is reachable, before validating Docker state.

```bash
hostname
whoami
ls -lah /mnt/data
docker --version
docker ps
```

**Success criteria:**
- Server is accessible
- `/mnt/data` is mounted and browsable (NFS dependency satisfied)
- Docker is installed and the daemon is running

> This combines the original "Restore Docker Host" and "Confirm NAS Mount" checks, since most containers (media library paths, backup targets) depend on the NAS mount being present before they can start meaningfully.

### Step 2 — Confirm NAS Backup Paths

```bash
ls -lah /mnt/data/media
ls -lah /mnt/data/downloads
ls -lah /mnt/data/backups/streamforge
```

**Success criteria:** media, downloads, and backup folders are all visible.

### Step 3 — Restore StreamForge Repository

If the repository already exists:

```bash
cd ~/StreamForge
git status
git pull origin main
```

If rebuilding from scratch:

```bash
cd ~
git clone https://github.com/Sud0Dev0ps/StreamForge.git
cd StreamForge
```

**Success criteria:** repository exists at `~/StreamForge`, main branch is available, compose files are present.

```bash
ls -lah environments/production/media/docker-compose.yml
ls -lah environments/production/finance/docker-compose.yml
ls -lah environments/production/infrastructure/docker-compose.yml
```

### Step 4 — Restore Production Environment Files

Restore `.env` files from backup (`/mnt/data/backups/streamforge/env`) to their live locations:

```bash
cp /mnt/data/backups/streamforge/env/media.env \
  ~/StreamForge/environments/production/media/.env
cp /mnt/data/backups/streamforge/env/finance.env \
  ~/StreamForge/environments/production/finance/.env
cp /mnt/data/backups/streamforge/env/infrastructure.env \
  ~/StreamForge/environments/production/infrastructure/.env
```

> Confirm these source filenames match the actual backup script output (see note in the Production Environment Files section above) before relying on this command during a real outage.

Restrict permissions:

```bash
chmod 600 ~/StreamForge/environments/production/media/.env
chmod 600 ~/StreamForge/environments/production/finance/.env
chmod 600 ~/StreamForge/environments/production/infrastructure/.env
```

Validate:

```bash
ls -lah ~/StreamForge/environments/production/media/.env
ls -lah ~/StreamForge/environments/production/finance/.env
ls -lah ~/StreamForge/environments/production/infrastructure/.env

git status
git check-ignore -v environments/production/media/.env
git check-ignore -v environments/production/finance/.env
git check-ignore -v environments/production/infrastructure/.env
```

**Success criteria:** all three `.env` files exist, are readable by the correct user, and are confirmed git-ignored (not committed).

### Step 5 — Restore Application Configuration

```bash
sudo rsync -avh /mnt/data/backups/streamforge/appdata/ /opt/appdata/
```

Validate:

```bash
du -sh /opt/appdata
ls -lah /opt/appdata
```

**Success criteria:** service directories exist under `/opt/appdata`, no obvious missing application folders, no restore errors reported by rsync.

> **Important:** this step does **not** restore `/opt/appdata/mariadb/` or `/opt/appdata/dockhand/` — both are intentionally excluded. MariaDB will need to initialize fresh (Step 9) and Dockhand will need manual reconfiguration (Step 7).

### Step 6 — Confirm Docker Networks

Current production networks:

- `media_network_prod`
- `finance_network_prod`
- `infra_network_prod`

```bash
docker network ls
```

If a required external network is missing, recreate it:

```bash
docker network create media_network_prod
docker network create finance_network_prod
docker network create infra_network_prod
```

**Success criteria:** required Docker networks exist and compose stacks can attach to them.

### Step 7 — Start Infrastructure Stack

```bash
cd ~/StreamForge
docker compose -f environments/production/infrastructure/docker-compose.yml up -d
docker compose -f environments/production/infrastructure/docker-compose.yml ps
docker logs dockhand --tail 20
```

**Success criteria:** Dockhand is running, no crash loop, no critical errors in logs.

> Dockhand appdata is excluded from backup. If it does not recover cleanly, it must be reconfigured manually — there is currently no documented recovery path for this service's stored configuration.

### Step 8 — Start Media Stack

```bash
cd ~/StreamForge
docker compose -f environments/production/media/docker-compose.yml up -d
docker compose -f environments/production/media/docker-compose.yml ps

docker logs homepage --tail 20
docker logs plex --tail 20
docker logs sonarr --tail 20
docker logs radarr --tail 20
docker logs prowlarr --tail 20
docker logs nzbget --tail 20
```

**Success criteria:** media containers are running, no crash loops, Homepage/Plex/automation services are accessible.

### Step 9 — Start Finance Stack

Because `/opt/appdata/mariadb/` is excluded from the appdata backup, on a from-scratch rebuild this directory will not exist yet. Create it with the correct ownership **before** the container starts:

```bash
sudo mkdir -p /opt/appdata/mariadb
sudo chown -R 999:999 /opt/appdata/mariadb
```

Then start the stack:

```bash
cd ~/StreamForge
docker compose -f environments/production/finance/docker-compose.yml up -d
docker compose -f environments/production/finance/docker-compose.yml ps

docker logs firefly --tail 20
docker logs mariadb --tail 20
```

**Success criteria:** Firefly III is running, MariaDB is running, no database startup errors. At this point MariaDB will be a fresh, empty database — proceed to Step 10 to restore data.

### Step 10 — Restore Firefly III MariaDB Database

>**This procedure has not yet been proven with a real restore.** The dump's integrity has been validated with `gzip -t`, but the restore itself should be tested in a non-destructive way (e.g. against a disposable MariaDB container) before being relied upon during a real outage.

Confirm the dump exists and is intact:

```bash
ls -lh /mnt/data/backups/streamforge/db/

gzip -t /mnt/data/backups/streamforge/db/firefly-mariadb-YYYY-MM-DD.sql.gz
echo $?
```

Expected result: `0`

Load finance environment variables:

```bash
set -a
source ~/StreamForge/environments/production/finance/.env
set +a
```

Restore the dump into the MariaDB container:

```bash
zcat /mnt/data/backups/streamforge/db/firefly-mariadb-YYYY-MM-DD.sql.gz | \
  docker exec -i mariadb mariadb \
  -u"$MYSQL_USER" \
  -p"$MYSQL_PASSWORD" \
  "$MYSQL_DATABASE"
```

Validate:

```bash
docker logs mariadb --tail 50
docker logs firefly --tail 50
```

**Success criteria:** dump import completes without error, MariaDB container remains running, Firefly III loads successfully and its data is visible in the application.

---

## Service URLs

| Service | URL |
|---|---|
| Dockhand | `http://<server>:3000` |
| Homepage | `http://<server>:3001` |
| Jellyfin | `http://<server>:8096` |
| Plex | `http://<server>:32400/web` |
| Navidrome | `http://<server>:4533` |
| NZBGet | `http://<server>:6789` |
| Prowlarr | `http://<server>:9696` |
| Radarr | `http://<server>:7878` |
| Sonarr | `http://<server>:8989` |
| Seerr | `http://<server>:5055` |
| Firefly III | `http://<server>:8090` |

---

## Validation Checklist

Recovery is not complete until the user-facing service works.

- [ ] Server boots successfully
- [ ] Docker daemon is running
- [ ] NAS mount is accessible at `/mnt/data`
- [ ] StreamForge repository exists at `~/StreamForge`
- [ ] Git working tree is clean or understood
- [ ] Production `.env` files restored
- [ ] `/opt/appdata` restored
- [ ] MariaDB directory re-created with `999:999` ownership (fresh rebuild only)
- [ ] MariaDB dump exists
- [ ] MariaDB dump passes gzip validation
- [ ] Docker networks exist
- [ ] Infrastructure stack running
- [ ] Media stack running
- [ ] Finance stack running
- [ ] Firefly III database restored if required
- [ ] Homepage loads and cards work
- [ ] Plex loads, libraries visible, playback works
- [ ] Sonarr loads
- [ ] Radarr loads
- [ ] Prowlarr loads
- [ ] NZBGet loads
- [ ] Firefly III loads and data is visible
- [ ] No critical errors in logs

---

## Restore Test Log

### Homepage Restore Test — June 2026

**Service:** Homepage
**Objective:** Validate backup and recovery process using a low-risk service.

**Procedure:**
1. Confirmed backup existed: `/mnt/data/backups/streamforge/appdata/homepage`
2. Confirmed live configuration existed: `/opt/appdata/homepage`
3. Stopped Homepage container
4. Renamed live configuration: `/opt/appdata/homepage` → `/opt/appdata/homepage.broken`
5. Restored Homepage from backup to `/opt/appdata/homepage`
6. Started Homepage container
7. Validated logs
8. Confirmed Homepage loaded and cards worked

**Result:** ✅ SUCCESS — Data loss: none

**Observations:** Backup ownership appeared as `1024 users`; original live ownership appeared as `serveradmin serveradmin`. Homepage still started successfully and functioned correctly despite the ownership mismatch. This needs further testing with LinuxServer containers, which tend to be more sensitive to PUID/PGID permissions.

### MariaDB Backup Validation — June 2026

**Service:** Firefly III / MariaDB
**Objective:** Validate that the Firefly III database backup is created as a compressed logical MariaDB dump. **This test validates the backup, not a restore.**

**Procedure:**
1. Confirmed MariaDB container name: `mariadb`
2. Confirmed finance `.env` contains required database variables: `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`
3. Added MariaDB dump backup to the StreamForge backup script
4. Ran the backup script manually
5. Confirmed dump file was created under `/mnt/data/backups/streamforge/db`
6. Validated gzip integrity using `gzip -t`
7. Confirmed full backup script completed successfully

**Result:** ✅ SUCCESS (backup creation and integrity only)

```bash
gzip -t /mnt/data/backups/streamforge/db/firefly-mariadb-2026-xx-xx.sql.gz
echo $?
# 0
```

**Observations:** MariaDB is now backed up using a logical database dump instead of relying on raw database files. Raw MariaDB appdata remains intentionally excluded from the general rsync backup. This improves the reliability of Firefly III recovery — **once the restore path itself has been tested**, which has not yet happened.

---

## Common Validation Commands

```bash
# Compose projects
docker compose ls

# Running containers
docker ps

# Container logs
docker logs <container-name> --tail 20

# Backup logs
ls -lah /mnt/data/backups/streamforge/logs
tail -20 /mnt/data/backups/streamforge/logs/backup-YYYY-MM-DD.log

# Appdata size
du -sh /opt/appdata

# Backup size
du -sh /mnt/data/backups/streamforge/appdata

# Database backup files
ls -lh /mnt/data/backups/streamforge/db/

# Validate current day's database dump
gzip -t /mnt/data/backups/streamforge/db/firefly-mariadb-$(date +%F).sql.gz
echo $?
```

---

## Future Improvements

- **Test restore of the Firefly III MariaDB dump in a safe, disposable environment** *(highest priority gap)*
- Test restore of a LinuxServer container (ownership/PUID-PGID sensitivity)
- Add a Dockhand backup strategy
- Add offsite backups
- Configure Synology Hyper Backup
- Investigate Snapshot Replication
- Create a dedicated StreamForge backup NAS share
- Add monitoring and alerting
- Add service health checks
- Create an Ansible rebuild playbook
- Review NFS permissions
- Review Docker socket exposure
- Review backup retention policy
- Add database backup retention and pruning

---

## Document History

| Version | Date | Change |
|---|---|---|
| 1.0 | June 2026 | Initial Disaster Recovery runbook |
| 1.1 | June 2026 | Added backup strategy, backup schedule, and recovery validation |
| 1.2 | June 2026 | Added Homepage restore test and linked service classification document |
| 1.3 | June 2026 | Added MariaDB logical dump backup model, validation steps, exclusions and Firefly database restore procedure |