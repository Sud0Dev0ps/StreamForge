# StreamForge Disaster Recovery Runbook

**Version:** 1.2  
**Last Updated:** June 2026  
**Status:** Active

---

## Purpose

This document describes the recovery procedures required to restore the StreamForge platform following infrastructure failure.

The objective is to restore service quickly and consistently while minimizing data loss.

This runbook focuses on **how to recover**.

For service priority, RTO, RPO, and recovery classification, see: [`docs/service-tiers.md`]

---

## Recovery Principle

**A backup does not exist until a restore has been proven.**

StreamForge backups have been partially validated through a successful Homepage restore.

---

## Architecture Overview

### Production Server

- **Hostname:** dockerserver
- **Repository:** ~/StreamForge

### Source of Truth

The GitHub repository is the source of truth for infrastructure definitions.

**Production repository location:** `~/StreamForge`

**The repository contains:**
- Docker Compose files
- Documentation
- Scripts
- Environment templates
- Homepage example configuration

---

## Docker Compose Projects

**Current production state:**

| Project | Expected Containers |
|---------|-------------------|
| media | 10 |
| finance | 2 |
| infrastructure | 1 |

**Expected output:**
```
finance          running(2)
infrastructure  running(1)
media           running(10)
```

**Validate with:**
```bash
docker compose ls
```

---

## Runtime Configuration

Application runtime configuration is stored outside the Git repository.

**Live location:** `/opt/appdata`

**Approximate size:** ~4 GB

**Examples:**
- Plex
- Jellyfin
- Sonarr
- Radarr
- Prowlarr
- NZBGet
- Homepage
- Firefly III
- MariaDB
- Dockhand

---

## Production Environment Files

Production `.env` files contain secrets and environment-specific values.

**Live locations:**
```
~/StreamForge/environments/production/media/.env
~/StreamForge/environments/production/finance/.env
~/StreamForge/environments/production/infrastructure/.env
```

**Important:** These files are excluded from Git and must never be committed. They are backed up daily to the NAS.

---

## NAS Storage

**NAS mount:** `/mnt/data`

**NAS export:** `192.168.10.2:/volume1/data`

**The NAS provides:**
- Media storage
- Download storage
- StreamForge backups

**Important paths:**
```
/mnt/data/media
/mnt/data/downloads
/mnt/data/backups/streamforge
```

---

## Backup Strategy

### Backup Location

StreamForge backups are stored on the NAS: `/mnt/data/backups/streamforge`

**Backup folder structure:**
```
/mnt/data/backups/streamforge/appdata
/mnt/data/backups/streamforge/env
/mnt/data/backups/streamforge/docs
/mnt/data/backups/streamforge/logs
```

### Backup Script

**Backup script location:** `~/StreamForge/scripts/backup-streamforge.sh`

**The backup script performs:**
- rsync mirror of `/opt/appdata`
- Backup of production `.env` files
- Backup of disaster recovery documentation
- Timestamped logging
- Strict shell safety using `set -euo pipefail`

### Backup Schedule

Backups run daily via cron:

```
0 12 * * * /home/serveradmin/StreamForge/scripts/backup-streamforge.sh
```

This runs once per day at midday.

### Backup Logs

Backup logs are stored in: `/mnt/data/backups/streamforge/logs`

**Example log file:** `backup-YYYY-MM-DD.log`

**Check backup logs:**
```bash
ls -lah /mnt/data/backups/streamforge/logs
tail -20 /mnt/data/backups/streamforge/logs/backup-YYYY-MM-DD.log
```

---

## Critical Assets

### Critical

These are required for recovery:
- GitHub repository
- `/opt/appdata`
- Production `.env` files
- Password manager

### Important

These are important but not fully protected by the current backup strategy:
- NAS media library

### Disposable

These can be recreated:
- Downloads
- Temporary working data

### Legacy

These exist but are not part of the current active recovery strategy:
- `/opt/docker-legacy`
- `/mnt/data/backups/docker`
- Docker named volumes under `/var/lib/docker/volumes`

**Do not delete legacy assets without validation.**

---

## Known Constraints

| Constraint | Status |
|-----------|--------|
| Backups run daily | Accepted |
| Appdata RPO is approximately 24 hours | Accepted |
| Media library is not backed up | Accepted for now |
| Restore process is manual | Accepted for now |
| No offsite backup | Future improvement |
| NAS permissions depend on current Synology mapping | Deferred to security session |

---

## Full Recovery Procedure

Use this process during a major outage or rebuild.

---

### Step 1 — Restore or Prepare Docker Host

**Goal:** Bring the production server back online.

**Validate:**
```bash
hostname
whoami
docker --version
docker ps
```

**Success criteria:**
- Server is accessible
- Docker is installed
- Docker daemon is running

---

### Step 2 — Confirm NAS Mount

**Validate NAS mount:**
```bash
ls -lah /mnt/data
```

**Confirm expected directories exist:**
```bash
ls -lah /mnt/data/media
ls -lah /mnt/data/downloads
ls -lah /mnt/data/backups/streamforge
```

**Success criteria:**
- `/mnt/data` is mounted
- Backup folder is accessible
- Media and downloads folders are visible

---

### Step 3 — Restore StreamForge Repository

**If the repository already exists:**
```bash
cd ~/StreamForge
git status
git pull origin main
```

**If rebuilding from scratch:**
```bash
cd ~
git clone https://github.com/Sud0Dev0ps/StreamForge.git
cd StreamForge
```

**Success criteria:**
- Repository exists at `~/StreamForge`
- Main branch is available
- Compose files are present

**Validate:**
```bash
ls -lah environments/production/media/docker-compose.yml
ls -lah environments/production/finance/docker-compose.yml
ls -lah environments/production/infrastructure/docker-compose.yml
```

---

### Step 4 — Restore Production Environment Files

Restore `.env` files from backup.

**Backup location:** `/mnt/data/backups/streamforge/env`

**Live locations:**
```
~/StreamForge/environments/production/media/.env
~/StreamForge/environments/production/finance/.env
~/StreamForge/environments/production/infrastructure/.env
```

**Example restore commands:**
```bash
cp /mnt/data/backups/streamforge/env/media.env \
~/StreamForge/environments/production/media/.env

cp /mnt/data/backups/streamforge/env/finance.env \
~/StreamForge/environments/production/finance/.env

cp /mnt/data/backups/streamforge/env/infrastructure.env \
~/StreamForge/environments/production/infrastructure/.env
```

**Validate:**
```bash
ls -lah ~/StreamForge/environments/production/media/.env
ls -lah ~/StreamForge/environments/production/finance/.env
ls -lah ~/StreamForge/environments/production/infrastructure/.env
```

**Success criteria:**
- All three `.env` files exist
- Files are readable
- Files are not committed to Git

**Validate Git safety:**
```bash
git status
git check-ignore -v environments/production/media/.env
git check-ignore -v environments/production/finance/.env
git check-ignore -v environments/production/infrastructure/.env
```

---

### Step 5 — Restore Application Configuration

Restore `/opt/appdata` from backup.

**Backup location:** `/mnt/data/backups/streamforge/appdata`

**Live location:** `/opt/appdata`

**Restore command:**
```bash
sudo rsync -avh /mnt/data/backups/streamforge/appdata/ /opt/appdata/
```

**Validate:**
```bash
du -sh /opt/appdata
ls -lah /opt/appdata
```

**Success criteria:**
- Service directories exist under `/opt/appdata`
- No obvious missing application folders
- No restore errors reported by rsync

---

### Step 6 — Confirm Docker Networks

**Current production networks:**
- media_network_prod
- finance_network_prod
- infra_network_prod

**Validate:**
```bash
docker network ls
```

**If a required external network is missing, recreate it:**
```bash
docker network create media_network_prod
docker network create finance_network_prod
docker network create infra_network_prod
```

**Success criteria:**
- Required Docker networks exist
- Compose stacks can attach to their expected external networks

---

### Step 7 — Start Infrastructure Stack

From the repository:
```bash
cd ~/StreamForge
```

Start infrastructure:
```bash
docker compose \
-f environments/production/infrastructure/docker-compose.yml \
up -d
```

**Validate:**
```bash
docker compose \
-f environments/production/infrastructure/docker-compose.yml \
ps
```

**Check logs:**
```bash
docker logs dockhand --tail 20
```

**Success criteria:**
- Dockhand is running
- No crash loop
- Logs do not show critical errors

---

### Step 8 — Start Media Stack

Start media services:
```bash
docker compose \
-f environments/production/media/docker-compose.yml \
up -d
```

**Validate:**
```bash
docker compose \
-f environments/production/media/docker-compose.yml \
ps
```

**Check logs:**
```bash
docker logs homepage --tail 20
docker logs plex --tail 20
docker logs sonarr --tail 20
docker logs radarr --tail 20
docker logs prowlarr --tail 20
docker logs nzbget --tail 20
```

**Success criteria:**
- Media containers are running
- No crash loops
- Homepage is accessible
- Plex is accessible
- Automation services are accessible

---

### Step 9 — Start Finance Stack

Start finance services:
```bash
docker compose \
-f environments/production/finance/docker-compose.yml \
up -d
```

**Validate:**
```bash
docker compose \
-f environments/production/finance/docker-compose.yml \
ps
```

**Check logs:**
```bash
docker logs firefly --tail 20
docker logs mariadb --tail 20
```

**Success criteria:**
- Firefly III is running
- MariaDB is running
- No database startup errors

---

## Service URLs

| Service | URL |
|---------|-----|
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

**Recovery is not complete until the user-facing service works.**

```
[ ] Server boots successfully
[ ] Docker daemon is running
[ ] NAS mount is accessible at /mnt/data
[ ] StreamForge repository exists at ~/StreamForge
[ ] Git working tree is clean or understood
[ ] Production .env files restored
[ ] /opt/appdata restored
[ ] Docker networks exist
[ ] Infrastructure stack running
[ ] Media stack running
[ ] Finance stack running
[ ] Homepage loads
[ ] Homepage cards work
[ ] Plex loads
[ ] Plex libraries are visible
[ ] Plex media playback works
[ ] Sonarr loads
[ ] Radarr loads
[ ] Prowlarr loads
[ ] NZBGet loads
[ ] Firefly III loads
[ ] No critical errors in logs
```

---

## Homepage Restore Test

**Date:** 23 June 2026

**Service:** Homepage

**Objective:** Validate backup and recovery process using a low-risk service.

### Procedure

1. Confirmed backup existed: `/mnt/data/backups/streamforge/appdata/homepage`
2. Confirmed live configuration existed: `/opt/appdata/homepage`
3. Stopped Homepage container
4. Renamed live configuration: `/opt/appdata/homepage` → `/opt/appdata/homepage.broken`
5. Restored Homepage from backup: `/mnt/data/backups/streamforge/appdata/homepage` → `/opt/appdata/homepage`
6. Started Homepage container
7. Validated logs
8. Confirmed Homepage loaded and cards worked

### Result

**SUCCESS**

**Data Loss:** None

### Observations

Backup ownership appeared as: `1024 users`

Original live ownership appeared as: `serveradmin serveradmin`

Homepage still started successfully and functioned correctly. This may need further testing with LinuxServer containers, which may be more sensitive to permissions.

---

## Common Validation Commands

**Check compose projects:**
```bash
docker compose ls
```

**Check running containers:**
```bash
docker ps
```

**Check logs:**
```bash
docker logs <container-name> --tail 20
```

**Check backup logs:**
```bash
ls -lah /mnt/data/backups/streamforge/logs
tail -20 /mnt/data/backups/streamforge/logs/backup-YYYY-MM-DD.log
```

**Check appdata size:**
```bash
du -sh /opt/appdata
```

**Check backup size:**
```bash
du -sh /mnt/data/backups/streamforge/appdata
```

---

## Future Improvements

Potential improvements:
- Test restore of a LinuxServer container
- Add offsite backups
- Configure Synology Hyper Backup
- Investigate Snapshot Replication
- Add monitoring and alerting
- Add service health checks
- Create Ansible rebuild playbook
- Review NFS permissions
- Review Docker socket exposure
- Review backup retention policy

---

## Document History

| Version | Date | Change |
|---------|------|--------|
| 1.0 | June 2026 | Initial Disaster Recovery runbook |
| 1.1 | June 2026 | Added backup strategy, backup schedule, and recovery validation |
| 1.2 | June 2026 | Added Homepage restore test and linked service classification document |