# StreamForge

## Overview

StreamForge is a production-grade DevOps homelab project designed to simulate real-world infrastructure and workflows.

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

StreamForge/
├── environments/
│   ├── staging/          # Staging environment
│   └── production/
│       ├── media/        # Media stack (Sonarr, Radarr, etc.)
│       ├── infrastructure/  # Infrastructure tooling (Dockhand)
│       └── home/         # Personal services (Firefly, MariaDB — planned)
├── docs/
└── README.md


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
| MariaDB | Database | 🔄 Pending |
| Firefly | Finance tracking | 🔄 Pending |
| Plex | Media server | 🔄 Pending |

### Infrastructure Stack (Production)
| Service | Purpose | Status |
|---------|---------|--------|
| Dockhand | Docker management | ✅ Migrated |

## Current Status

**Phase**: Production Migration — Phase 2 Complete

- [x] System audit completed
- [x] Git repository initialised
- [x] Staging environment fully GitOps
- [x] Production network created (`media_network_prod`)
- [x] Phase 1 complete — core media stack migrated (5 services)
- [x] Phase 2 complete — Homepage, Navidrome, Dockhand migrated
- [x] Repository restructured into media / infrastructure / home stacks
- [ ] Phase 3 — MariaDB, Firefly (high risk)
- [ ] Phase 4 — Plex (high risk)

## GitOps Workflow
MacBook (edit) → GitHub (source of truth) → Production Server (git pull)
All infrastructure changes flow through Git. No manual edits on the server.