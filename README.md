# StreamForge

**A production grade DevOps homelab, built to prove real infrastructure skills.**

StreamForge simulates real world infrastructure and workflows as a hands-on from a traditional system administration background into a DevOps / Platform Engineering role. Every phase — build, automate, document, operate — is treated the way it would be on a live production system, not a weekend project.

The platform is operated through a Git-based workflow: infrastructure configuration is reviewed, committed and deployed through controlled, reproducible changes.

---

## Table of Contents

- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [Tech Stack](#tech-stack)
- [Production Services](#production-services)
- [Current Status](#current-status)
- [Git Workflow](#git-workflow)
- [Secrets and Private Configuration](#secrets-and-private-configuration)
- [Project Direction](#project-direction)

---

## Architecture

| Component | Details |
|---|---|
| **Production** | Lenovo ThinkCentre M725s — AMD Ryzen 5 PRO 2400G, 24GB RAM |
| **Operating System** | Ubuntu Server 22.04 LTS |
| **Control Plane** | MacBook — Git operations, documentation and code editing |
| **Storage** | Synology NAS, mounted for media and backups |
| **Networking** | UniFi network, with segmentation planned |
| **Runtime** | Docker Engine + Docker Compose |

---

## Repository Structure

```text
StreamForge/
├── environments/
│   ├── staging/
│   └── production/
│       ├── media/
│       ├── infrastructure/
│       └── finance/
├── docs/
├── scripts/
└── README.md
```

---

## Tech Stack

**Active**
- Docker / Docker Compose
- Git / GitHub
- Bash automation
- Synology NAS storage
- UniFi networking

**Planned**
- Reverse proxy
- Tailscale
- VLAN segmentation
- Backup retention and pruning
- Offsite backup
- CI/CD workflow improvements
- Monitoring and logging

---

## Production Services

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
| MariaDB | Firefly database | Running |

---

## Current Status

StreamForge has completed its initial production migration phase.

- Production server upgraded to Ubuntu 22.04 LTS
- Docker Compose stacks separated by function (media, infrastructure, finance)
- Media, infrastructure, and finance services managed through Git
- Dedicated NAS backup share in use
- Daily backup script in place
- MariaDB database backup included
- Disaster recovery documentation started
- Public repository excludes secrets and environment-specific `.env` files

---

## Git Workflow

**MacBook → GitHub → Production Server**

1. Edit configuration or documentation on the MacBook.
2. Review changes locally.
3. Commit with a clear, descriptive message.
4. Push to GitHub.
5. Pull changes on the production server.
6. Apply changes with Docker Compose where required.
7. Validate service health.

---

## Secrets and Private Configuration

Secrets and environment-specific values are never stored in this repository.

- `.env.example` files document required variables without exposing private values.
- Actual `.env` files live only on the relevant host.

---

## Project Direction

StreamForge is intentionally built in small, controlled phases rather than one large push.

**Near-term focus areas:**
- Reverse proxy planning and implementation
- Tailscale planning and implementation
- Network segmentation planning
- Backup retention and offsite backup strategy