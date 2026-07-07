# StreamForge — Current State

**Last Updated:** July 2026
**Status:** Active

---

## Purpose

This document describes the current operating state of the StreamForge platform. It provides a clear snapshot of what is running, where key configuration lives and which areas are still planned for future improvement.

Detailed recovery procedures are documented separately in [`docs/disaster-recovery.md`](disaster-recovery.md).

---

## Table of Contents

- [Production Server](#production-server)
- [Production Compose Projects](#production-compose-projects)
- [Running Services](#running-services)
- [Repository Layout](#repository-layout)
- [Runtime Configuration](#runtime-configuration)
- [Storage](#storage)
- [Backups](#backups)
- [Git Workflow](#git-workflow)
- [Current Operational State](#current-operational-state)
- [Accepted Current Gaps](#accepted-current-gaps)
- [Validation Commands](#validation-commands)

---

## Production Server

| Item | Current State |
|---|---|
| Hostname | `dockerserver` |
| Hardware | Lenovo ThinkCentre M725s |
| CPU | AMD Ryzen 5 PRO 2400G |
| RAM | 24GB |
| Operating System | Ubuntu 22.04.5 LTS |
| Codename | jammy |
| Kernel | 5.15.x |
| Primary IP | Managed on the local LAN |
| Runtime | Docker Engine + Docker Compose |

---

## Production Compose Projects

StreamForge production services are organized into three Docker Compose projects.

| Project | Purpose | Expected Containers |
|---|---|---|
| `media` | Media services and automation | 10 |
| `infrastructure` | Platform management services | 1 |
| `finance` | Personal finance services | 2 |

**Expected validation command:**

```bash
docker compose ls
```

**Expected output:**

```text
finance             running(2)
infrastructure      running(1)
media               running(10)
```

---

## Running Services

### Media Stack

| Service | Purpose | Status |
|---|---|---|
| Plex | Primary media server | Running |
| Jellyfin | Secondary media server | Running |
| Sonarr | TV management | Running |
| Radarr | Movie management | Running |
| Prowlarr | Indexer management | Running |
| NZBGet | Usenet downloader | Running |
| Seerr | Request management | Running |
| Homepage | Dashboard | Running |
| Navidrome | Music streaming | Running |
| MeTube | Media download utility | Running |

### Infrastructure Stack

| Service | Purpose | Status |
|---|---|---|
| Dockhand | Docker management | Running |

### Finance Stack

| Service | Purpose | Status |
|---|---|---|
| Firefly III | Personal finance tracking | Running |
| MariaDB | Firefly III database | Running |

---

## Repository Layout

Production Compose files:

```text
environments/production/media/docker-compose.yml
environments/production/infrastructure/docker-compose.yml
environments/production/finance/docker-compose.yml
```

Environment templates:

```text
environments/production/media/env.example
environments/production/infrastructure/env.example
environments/production/finance/env.example
```

Actual `.env` files are excluded from Git and stored only on the relevant host.

---

## Runtime Configuration

Application runtime configuration is stored outside Git under:

```text
/opt/appdata
```

This includes application configuration and persistent service data for the production containers.

The Git repository stores Compose definitions and documentation only — it does not store live application state or secrets.

---

## Storage

StreamForge uses Synology NAS storage for media, downloads, and backups.

| Mount | Purpose |
|---|---|
| `/mnt/data` | Media and download storage |
| `/mnt/streamforge-backups` | Dedicated StreamForge backup destination |

The media library is intentionally not fully backed up at this stage.

---

## Backups

Backups are performed by:

```text
scripts/backup-streamforge.sh
```

**Current backup destination:** `/mnt/streamforge-backups`

The backup script currently includes:

- Most `/opt/appdata` service configuration
- Production `.env` files
- Docker Compose files
- StreamForge documentation
- Firefly III MariaDB logical dump
- Backup logs

**Known backup limitations:**

- Dockhand appdata is currently excluded
- Raw MariaDB data files are excluded by design
- MariaDB is backed up using a logical dump instead
- Backup retention and pruning still need improvement
- Offsite backup has not yet been implemented

---

## Git Workflow

**MacBook → GitHub → Production Server**

1. Edit on the MacBook.
2. Review changes locally.
3. Commit to Git.
4. Push to GitHub.
5. Pull on the production server.
6. Apply Compose changes where required.
7. Validate containers and service health.

Production should avoid untracked manual configuration changes wherever practical.

---

## Current Operational State

StreamForge has completed its initial production migration.

**Completed:**

- Production Compose stacks created
- Media stack migrated
- Infrastructure stack migrated
- Finance stack migrated
- Homepage restore test completed
- MariaDB backup creation added
- Dedicated NAS backup share created
- Production server upgraded from Ubuntu 20.04 to Ubuntu 22.04
- Docker repository corrected to Ubuntu jammy packages
- Public README refreshed

**Current focus:**

- Reverse proxy planning
- Tailscale planning
- Network segmentation planning
- Backup retention and offsite backup planning

---

## Accepted Current Gaps

| Area | Status |
|---|---|
| Reverse proxy | Planned |
| Tailscale | Planned |
| VLAN segmentation | Planned |
| Backup retention/pruning | Open |
| Offsite backup | Open |
| Dockhand backup strategy | Open |
| MariaDB restore test | Open |
| Central monitoring/logging | Future |
| NAS permissions hardening | Future |
| Ubuntu 24.04 upgrade | Deferred |

---

## Validation Commands

Useful current-state validation commands:

```bash
lsb_release -a
hostnamectl
uptime
systemctl --failed
docker compose ls
docker ps --format "table {{.Names}}\t{{.Status}}"
findmnt /mnt/data
findmnt /mnt/streamforge-backups
```

A healthy baseline should show:

- Ubuntu 22.04 LTS
- No failed systemd services
- `finance`, `infrastructure`, and `media` Compose projects running
- Expected containers running
- NAS mounts available