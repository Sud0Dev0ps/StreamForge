# StreamForge Disaster Recovery Runbook

**Version:** 1.0  
**Last Updated:** June 2026

---

## Purpose

This document describes the critical assets and recovery procedures required to rebuild the StreamForge platform following infrastructure failure.

The objective is to restore service quickly and consistently while minimizing data loss.

---

## Architecture Overview

### Source of Truth

**GitHub repository:**
```
~/StreamForge
```

**Contains:**
- Docker Compose files
- Documentation
- Environment templates
- Homepage example configuration

---

## Runtime Configuration

**Location:**
```
/opt/appdata
```

**Approximate size:** 4 GB

Contains persistent application state and configuration.

**Examples:**
- Plex
- Jellyfin
- Sonarr
- Radarr
- Prowlarr
- Seerr
- Navidrome
- Homepage
- Firefly
- MariaDB
- Dockhand

---

## Secrets

**Location:**
```
environments/production/*/.env
```

**Current files:**
- `environments/production/media/.env`
- `environments/production/finance/.env`
- `environments/production/infrastructure/.env`

Secrets are intentionally excluded from Git.

---

## NAS Storage

**Mounted from:**
```
192.168.10.2:/volume1/data
```

**Mounted as:**
```
/mnt/data
```

**Contains:**
- `/media`
- `/downloads`
- `/backups`

---

## Critical Assets

| Asset | Importance |
|-------|-----------|
| GitHub Repository | Critical |
| `/opt/appdata` | Critical |
| Production `.env` files | Critical |
| Password Manager | Critical |
| NAS Media | Important |
| Downloads | Low |
| Historical Docker Backups | Legacy |
| Docker Volumes | Legacy |

---

## Active Compose Projects

### Media Stack

**Location:**
```
environments/production/media/docker-compose.yml
```

**Services:**
- homepage
- jellyfin
- plex
- navidrome
- nzbget
- prowlarr
- radarr
- sonarr
- seerr
- metube

### Finance Stack

**Location:**
```
environments/production/finance/docker-compose.yml
```

**Services:**
- firefly
- mariadb

### Infrastructure Stack

**Location:**
```
environments/production/infrastructure/docker-compose.yml
```

**Services:**
- dockhand

---

## Scenario 1 – Complete Server Loss

### Lost
- Ubuntu installation
- Docker installation
- Containers
- `/opt/appdata`
- Local `.env` files

### Survives
- GitHub repository
- Synology NAS

### Recovery Procedure

#### Step 1: Install Ubuntu

Update packages.

Install Docker and Docker Compose.

#### Step 2: Mount NAS

**Verify:**
```bash
df -h /mnt/data
```

**Expected:**
```
192.168.10.2:/volume1/data
```

#### Step 3: Clone StreamForge

```bash
git clone https://github.com/Sud0Dev0ps/StreamForge.git
```

#### Step 4: Restore Production .env Files

Restore:
- `environments/production/media/.env`
- `environments/production/finance/.env`
- `environments/production/infrastructure/.env`

#### Step 5: Restore /opt/appdata

Restore application configuration.

#### Step 6: Start Stacks

**Media:**
```bash
cd environments/production/media
docker compose up -d
```

**Finance:**
```bash
cd ../finance
docker compose up -d
```

**Infrastructure:**
```bash
cd ../infrastructure
docker compose up -d
```

#### Step 7: Validate Services

**Verify:**
```bash
docker compose ls
docker ps
```

**Expected:**
```
finance running (2)
infrastructure running (1)
media running (10)
```

---

## Scenario 2 – NAS Loss

### Lost
- `/mnt/data/media`
- `/mnt/data/downloads`
- `/mnt/data/backups`

### Survives
- GitHub repository
- `/opt/appdata`
- Production `.env` files

### Impact

Services remain recoverable.

Media content must be restored or reacquired.

---

## Scenario 3 – GitHub Loss

### Survives
- Running server
- AppData
- NAS

### Impact

Infrastructure definitions are lost.

Recovery possible from local repository.

---

## Scenario 4 – Secret Loss

### Lost
Production `.env` files.

### Impact

Services cannot start correctly.

Compose files remain intact.

### Mitigation

Restore secrets from password manager or secret backup.

---

## Recovery Objectives (RTO)

| Service | Target Recovery Time |
|---------|----------------------|
| Homepage | 15 minutes |
| Dockhand | 15 minutes |
| Sonarr | 30 minutes |
| Radarr | 30 minutes |
| Prowlarr | 30 minutes |
| Seerr | 30 minutes |
| Navidrome | 30 minutes |
| Jellyfin | 1 hour |
| Plex | 1 hour |
| Firefly | 2 hours |

---

## Deferred Work

Future improvements:

- Backup strategy
- Backup verification
- Restore testing
- Monitoring
- Alerting
- CI/CD
- Ansible automation
- Offsite backups
- Recovery Point Objectives (RPO)

---

## Notes

Historical artifacts currently exist:

- `/opt/docker-legacy`
- `/mnt/data/backups/docker`
- `/var/lib/docker/volumes`

These are considered legacy assets and are not part of the active StreamForge architecture.

**Do not delete without validation.**

---

## Philosophy

This Version 1 runbook prioritizes clarity and recoverability over operational perfection.

It answers the most important question: **"If I got hit by a bus tomorrow, could someone else rebuild StreamForge?"**

Version 1 says **yes**.

Future versions will answer:
- "How quickly?"
- "How much data would we lose?"
- "How do we prove our backups work?"