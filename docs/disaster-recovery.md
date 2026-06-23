# StreamForge Disaster Recovery Runbook

**Version:** 1.1  
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
- Templates
- Scripts

---

## Runtime Configuration

**Location:**
```
/opt/appdata
```

**Approximate size:** 4 GB

Contains persistent application state and configuration.

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

## Backup Strategy

### Backup Location

```
/mnt/data/backups/streamforge
```

**Contains:**
- `appdata/`
- `env/`
- `docs/`
- `logs/`

### Backup Scope

| Asset | Method | Frequency |
|-------|--------|-----------|
| `/opt/appdata` | rsync mirror | Daily |
| Production `.env` files | File copy | Daily |
| DR documentation | File copy | Daily |
| Git repository | GitHub | Continuous |
| Media | Synology responsibility | Independent |
| Downloads | No backup | N/A |

### Automation

**Daily backup job:**
```
0 12 * * * /home/serveradmin/StreamForge/scripts/backup-streamforge.sh
```

### Logging

Logs are stored in:
```
/mnt/data/backups/streamforge/logs
```

**Example:**
```
backup-2026-06-19.log
```

## Active Compose Projects

| Project | Containers |
|---------|-----------|
| media | 10 |
| finance | 2 |
| infrastructure | 1 |

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
- StreamForge backups

### Recovery Procedure

#### Step 1: Install Ubuntu

Install:
- Docker
- Docker Compose
- Git
- rsync

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

#### Step 4: Restore Backup

**Restore appdata:**
```bash
# From backup location to target location
/mnt/data/backups/streamforge/appdata → /opt/appdata
```

**Restore secrets:**
```bash
# From backup location to target location
/mnt/data/backups/streamforge/env → ~/StreamForge/environments/production/
```

#### Step 5: Start Stacks

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

#### Step 6: Validate Services

**Verify:**
```bash
docker compose ls
docker ps
```

**Expected:**
```
finance         running (2)
infrastructure  running (1)
media           running (10)
```

#### Step 7: Validate Application State

Confirm:
- Plex libraries present
- Sonarr configuration intact
- Radarr configuration intact
- Homepage widgets available
- Firefly accessible
- Dockhand operational

---

## Scenario 2 – NAS Loss

### Lost
- `/mnt/data/media`
- `/mnt/data/downloads`
- `/mnt/data/backups`

### Survives
- Running server
- `/opt/appdata`
- Production `.env`
- GitHub repository

### Impact

Services remain operational.

Media content and backups must be restored or reacquired.

---

## Scenario 3 – GitHub Loss

### Survives
- Running server
- AppData
- NAS
- Backup copies

### Impact

Infrastructure definitions lost remotely.

Recovery possible from local repository.

---

## Scenario 4 – Secret Loss

### Lost
Production `.env` files.

### Impact

Services cannot start correctly.

### Mitigation

Restore from:
```
/mnt/data/backups/streamforge/env
```

or password manager.

---

## Recovery Objectives (RTO)

| Service Group | Target Recovery Time |
|---------------|----------------------|
| Infrastructure | 15 minutes |
| Media Stack | 1 hour |
| Finance Stack | 2 hours |

---

## Future Improvements

- Restore testing
- Recovery Point Objectives (RPO)
- Hyper Backup
- Snapshot Replication
- Offsite backups
- Monitoring
- Alerting
- CI/CD
- Ansible automation
- Security hardening

---

## Legacy Assets

Historical artifacts currently exist:

- `/opt/docker-legacy`
- `/mnt/data/backups/docker`
- `/var/lib/docker/volumes`

These are not part of the active architecture.

Do not remove without validation.

---

## Philosophy

**Version 1** answered:
> Can StreamForge be rebuilt?

**Version 1.1** answers:
> Can StreamForge be rebuilt from known backups?

**Future versions** will answer:
- How quickly?
- How much data would we lose?
- How do we prove our backups work?
- Can recovery be automated?

The goal is operational maturity, not perfection.

## Restore Validation

Date:
23 June 2026

Service:
Homepage

Objective:
Validate backup and recovery procedures.

Steps:

1. Stop Homepage container.
2. Rename /opt/appdata/homepage to homepage.broken.
3. Restore from backup.
4. Start container.
5. Verify web UI and cards.

Result:
SUCCESS

Duration:
~5 minutes

Data Loss:
None

Observations:

- Backup ownership displayed as 1024:users.
- Homepage container handled permissions automatically.
- Functional validation confirmed dashboard and cards operated correctly.