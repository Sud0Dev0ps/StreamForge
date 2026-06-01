# StreamForge

## Overview

StreamForge is a production grade DevOps homelab project designed to simulate real world infrastructure and workflows.

The goal is to transition from a traditional system administration background into a DevOps role by building, automating and operating a fully reproducible platform using GitOps principles.

## Architecture

| Component | Details |
|-----------|---------|
| Production | Lenovo Desktop, AMD Ryzen 5, 24GB RAM — Ubuntu Server |
| Staging | Ubuntu Laptop |
| Control Plane | MacBook (Git operations, code editing) |
| Storage | Synology NAS (8.8TB, mounted at `/mnt/data`) |
| Networking | UniFi (VLAN segmentation planned) |

## Repository Structure

```
StreamForge/
├── environments/
│   ├── staging/
│   └── production/
│       ├── media/
│       ├── infrastructure/
│       ├── home/
│       └── finance/
├── docs/
└── README.md
```

## Tech Stack

**Active**
- Docker / Docker Compose
- Git / GitHub (GitOps workflow)

**Planned**
- Ansible
- Terraform
- Kubernetes (K3s)
- GitHub Actions
- Prometheus / Grafana / Loki

## Services

### Media Stack (Production)
| Service | Purpose | Status |
|---------|---------|--------|
| Sonarr | TV management | ✅ Migrated |
| Radarr | Movie management | ✅ Migrated |
| Prowlarr | Indexer management | ✅ Migrated |
| NZBGet | Usenet downloader | ✅ Migrated |
| Seerr | Request management | ✅ Migrated |
| Homepage | Dashboard | ✅ Migrated |
| Navidrome | Music streaming | ✅ Migrated |
| Plex | Media server | ⚠️ In Git — redeploy pending |
| Jellyfin | Media server | ✅ Deployed |

### Infrastructure Stack (Production)
| Service | Purpose | Status |
|---------|---------|--------|
| Dockhand | Docker management | ✅ Migrated |

### Finance Stack (Production)
| Service | Purpose | Status |
|---------|---------|--------|
| MariaDB | Database | ✅ Migrated |
| Firefly | Finance tracking | ✅ Migrated |

## Current Status

**Phase**: Production Migration — Phase 4 In Progress

- [x] System audit completed
- [x] Git repository initialised
- [x] Staging environment fully GitOps
- [x] Production network created (`media_network_prod`)
- [x] Phase 1 complete — core media stack migrated (5 services)
- [x] Phase 2 complete — Homepage, Navidrome, Dockhand migrated
- [x] Repository restructured into media / infrastructure / finance stacks
- [x] Phase 3 complete — MariaDB, Firefly migrated to finance stack
- [x] Phase 4 in progress — Jellyfin deployed, Plex in Git (redeploy pending)

## GitOps Workflow

```
MacBook (edit) → GitHub (source of truth) → Production Server (git pull)
```

All infrastructure changes flow through Git. No manual edits on the server.