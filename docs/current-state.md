# StreamForge — Current State

**Last Updated:** August 2026
**Status:** Active

**Related documents:** **Related documents:** [Disaster Recovery Runbook](disaster-recovery.md) · [Service Classification](service-classification.md)

---

## Purpose

This document describes the current operating state of the StreamForge platform. It provides a clear snapshot of what is running, where key configuration lives, how internal services are accessed and which areas are still planned for future improvement.

Detailed recovery procedures are documented separately in [`docs/disaster-recovery-runbook.md`](docs/disaster-recovery-runbook.md).

---

## Table of Contents

- [Production Server](#production-server)
- [Production Compose Projects](#production-compose-projects)
- [Running Services](#running-services)
- [Repository Layout](#repository-layout)
- [Runtime Configuration](#runtime-configuration)
- [Internal DNS and Reverse Proxy](#internal-dns-and-reverse-proxy)
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

StreamForge production services are organized into four Docker Compose projects.

| Project | Purpose | Expected Containers |
|---|---|---|
| media | Media services and automation | 10 |
| infrastructure | Platform management services | 1 |
| finance | Personal finance services | 2 |
| proxy | Internal reverse proxy | 1 |

Expected validation command:

```bash
docker compose ls
```

Expected state:

```
finance             running(2)
infrastructure      running(1)
media               running(10)
proxy               running(1)
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

### Proxy Stack

| Service | Purpose | Status |
|---|---|---|
| Caddy | Internal reverse proxy | Running |

---

## Repository Layout

Production Compose files:

```
environments/production/media/docker-compose.yml
environments/production/infrastructure/docker-compose.yml
environments/production/finance/docker-compose.yml
environments/production/proxy/docker-compose.yml
```

Proxy routing configuration:

```
environments/production/proxy/Caddyfile
```

Environment templates:

```
environments/production/media/env.example
environments/production/infrastructure/env.example
environments/production/finance/env.example
environments/production/proxy/env.example
```

Actual `.env` files are excluded from Git and stored only on the relevant host.

---

## Runtime Configuration

Application runtime configuration is stored outside Git under:

```
/opt/appdata
```

This includes application configuration and persistent service data for the production containers.

The Git repository stores infrastructure definitions, reusable configuration examples, scripts and documentation. It does not store live application state or secrets.

---

## Internal DNS and Reverse Proxy

StreamForge uses UniFi DNS and Caddy to provide readable internal hostnames for suitable browser-facing services.

The standard request path is:

```
LAN client
  ↓
UniFi DHCP
  ↓
UniFi DNS
  ├─ StreamForge internal record → 192.168.10.10
  └─ Public DNS request → NextDNS
  ↓
Caddy — 192.168.10.10:80
  ↓
streamforge_proxy_prod
  ↓
Application container
```

StreamForge internal services use the `.streamforge.internal` namespace.

### Current Internal Hostnames

| Service | Internal Hostname | Caddy Backend |
|---|---|---|
| Homepage | `homepage.streamforge.internal` | `homepage:3000` |
| Seerr | `seerr.streamforge.internal` | `seerr:5055` |
| Navidrome | `navidrome.streamforge.internal` | `navidrome:4533` |
| Sonarr | `sonarr.streamforge.internal` | `sonarr:8989` |
| Radarr | `radarr.streamforge.internal` | `radarr:7878` |
| Prowlarr | `prowlarr.streamforge.internal` | `prowlarr:9696` |
| NZBGet | `nzbget.streamforge.internal` | `nzbget:6789` |
| Jellyfin | `jellyfin.streamforge.internal` | `jellyfin:8096` |
| MeTube | `metube.streamforge.internal` | `metube:8081` |
| Firefly III | `firefly.streamforge.internal` | `firefly:8080` |
| Dockhand | `dockhand.streamforge.internal` | `dockhand:3000` |

UniFi owns the private DNS records for these hostnames. Public DNS requests continue upstream to NextDNS.

Caddy is currently LAN-only and listens on HTTP port 80.
Public DNS, internet exposure, port forwarding, and internal HTTPS/TLS are not part of the current deployment.

The proxied applications and Caddy share the Docker network:

```
streamforge_proxy_prod
```

Only applications that require reverse-proxy connectivity are deliberately attached to this network.

Existing direct IP-and-port access remains available as a rollback and troubleshooting path.

### Intentional Exceptions

**Plex**

Plex remains on Docker host networking and is intentionally accessed directly rather than through Caddy.


- Plex uses `network_mode: host`.
- Plex is healthy through its existing direct access path.
- Plex has existing LAN and secure-connection behaviour that should not be changed solely to provide a friendlier browser URL.
- Adding a reverse-proxy route would introduce an exception requiring Caddy to reach the host-networked service rather than a container on `streamforge_proxy_prod`.
- The current operational benefit does not justify the additional complexity.

Plex therefore remains an intentional architectural exception rather than incomplete reverse-proxy work.

**MariaDB**

MariaDB is not an HTTP application and does not require reverse-proxy connectivity.

It remains attached only to the finance application network and is deliberately excluded from `streamforge_proxy_prod`.

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

```
scripts/backup-streamforge.sh
```

Current backup destination: `/mnt/streamforge-backups`

The backup script currently includes:

- Most `/opt/appdata` service configuration
- Production `.env` files
- Docker Compose files
- StreamForge documentation
- Firefly III MariaDB logical dump
- Backup logs

Known backup limitations:

- Dockhand appdata is currently excluded
- Raw MariaDB data files are excluded by design
- MariaDB is backed up using a logical dump instead
- Backup retention and pruning still need improvement
- Offsite backup has not yet been implemented

---

## Git Workflow

**MacBook → GitHub → Production Server**

1. Edit configuration or documentation on the MacBook.
2. Review changes locally.
3. Commit to Git.
4. Push to GitHub.
5. Pull changes on the production server.
6. Apply Compose or service-specific changes where required.
7. Validate infrastructure and service health.

Production should avoid untracked manual configuration changes wherever practical.

---

## Current Operational State

StreamForge has completed its initial production migration and internal reverse-proxy rollout.

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
- Caddy reverse proxy deployed
- Dedicated proxy Compose project deployed
- Shared `streamforge_proxy_prod` network deployed
- Central internal DNS configured through UniFi
- `.streamforge.internal` namespace deployed for suitable web services
- Direct application access preserved as a rollback path
- Homepage links migrated to validated internal hostnames
- Plex reviewed and deliberately retained as a host-networked exception
- MariaDB deliberately excluded from the proxy network

**Current focus:**

- Reverse proxy and internal DNS documentation
- Tailscale architecture planning
- Network segmentation planning
- Backup retention and offsite backup planning

---

## Accepted Current Gaps

| Area | Status |
|---|---|
| Tailscale | Planned |
| VLAN segmentation | Planned |
| Internal HTTPS/TLS | Deferred |
| Plex reverse proxy | Intentionally not implemented |
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
docker network inspect streamforge_proxy_prod
findmnt /mnt/data
findmnt /mnt/streamforge-backups
```

A healthy baseline should show:

- Ubuntu 22.04 LTS
- No failed systemd services
- `finance`, `infrastructure`, `media`, and `proxy` Compose projects running
- Expected containers running
- `streamforge_proxy_prod` available
- Caddy and the expected proxied applications attached to the proxy network
- Plex and MariaDB absent from the proxy network
- NAS mounts available