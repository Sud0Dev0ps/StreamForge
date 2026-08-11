# StreamForge

**A production grade DevOps homelab built to demonstrate practical infrastructure engineering skills.**

StreamForge is a self-hosted platform designed and operated as a hands on environment for developing DevOps and Platform Engineering skills from a traditional systems administration background.

Rather than treating the environment as a collection of standalone containers, StreamForge applies production style engineering practices to infrastructure design, deployment, operations, recovery, networking and documentation.

The platform is managed through a Git-based workflow where infrastructure changes are planned, reviewed, committed, deployed, and validated through small, reversible changes.

---

## What StreamForge Demonstrates

StreamForge demonstrates hands on experience with:

- Linux server administration
- Docker and Docker Compose
- Git-based infrastructure management
- Reverse proxy architecture
- Internal DNS design
- Docker networking and service isolation
- Infrastructure troubleshooting
- Backup and disaster recovery
- Database backup strategy
- Infrastructure documentation
- Production change management and rollback planning
- Security conscious architecture and least privilege design

The project deliberately emphasizes understanding *why* infrastructure is designed a particular way rather than simply deploying tools.

---

## Architecture

| Component | Current Implementation |
|---|---|
| Production Server | Lenovo ThinkCentre M725s — AMD Ryzen 5 PRO 2400G, 24GB RAM |
| Operating System | Ubuntu Server 22.04 LTS |
| Container Runtime | Docker Engine + Docker Compose |
| Control Plane | MacBook — Git operations, infrastructure editing and documentation |
| Source Control | Git + GitHub |
| Storage | Synology NAS using NFS |
| Networking | UniFi |
| Internal DNS | UniFi DNS with NextDNS upstream |
| Reverse Proxy | Caddy |
| Internal Namespace | `.streamforge.internal` |
| Backups | Automated NAS-based configuration and database backups |

### Internal Service Access

Suitable browser facing services use a centralized internal access path:

```
LAN Client
    ↓
UniFi DNS
    ↓
Caddy — 192.168.10.10:80
    ↓
streamforge_proxy_prod
    ↓
Application Container
```

UniFi provides private DNS resolution for StreamForge services while forwarding public DNS requests upstream to NextDNS.

Caddy provides LAN only HTTP reverse proxying to selected application containers through a dedicated Docker proxy network.

Direct IP and port access is deliberately retained as a troubleshooting and rollback path.

Plex remains an intentional exception because its host networking, discovery, and client behaviour do not currently justify introducing a reverse proxy dependency.

---

## Repository Structure

```
StreamForge/
├── environments/
│   ├── staging/
│   └── production/
│       ├── media/
│       ├── infrastructure/
│       ├── finance/
│       └── proxy/
├── docs/
├── scripts/
└── README.md
```

Infrastructure definitions, reusable configuration examples, operational procedures and documentation are stored in Git.

Application runtime state and secrets remain outside the repository.

---

## Technology Stack

### Active

- Ubuntu Server
- Docker Engine
- Docker Compose
- Git / GitHub
- Caddy
- UniFi networking and internal DNS
- NextDNS
- Synology NAS / NFS
- Bash automation

### Planned

- Tailscale remote access
- VLAN segmentation and firewall policy
- Backup retention and pruning
- Offsite backup
- Internal HTTPS/TLS assessment
- CI/CD workflow improvements
- Central monitoring and logging
- Infrastructure automation

---

## Production Services

### Media

| Service | Purpose |
|---|---|
| Plex | Primary media server |
| Jellyfin | Secondary media server |
| Sonarr | TV library management |
| Radarr | Movie library management |
| Prowlarr | Indexer management |
| NZBGet | Usenet downloader |
| Seerr | Media request management |
| Navidrome | Music streaming |
| MeTube | Media download utility |
| Homepage | Internal service dashboard |

### Infrastructure

| Service | Purpose |
|---|---|
| Dockhand | Docker management |
| Caddy | Internal reverse proxy |

### Finance

| Service | Purpose |
|---|---|
| Firefly III | Personal finance application |
| MariaDB | Firefly III database |

---

## Internal Service Namespace

The following services currently use the `.streamforge.internal` namespace:

- `homepage.streamforge.internal`
- `seerr.streamforge.internal`
- `navidrome.streamforge.internal`
- `sonarr.streamforge.internal`
- `radarr.streamforge.internal`
- `prowlarr.streamforge.internal`
- `nzbget.streamforge.internal`
- `jellyfin.streamforge.internal`
- `metube.streamforge.internal`
- `firefly.streamforge.internal`
- `dockhand.streamforge.internal`

Private DNS records resolve to the production server, where Caddy routes requests to the appropriate container using Docker's internal networking.

Only applications requiring reverse proxy connectivity are attached to the shared proxy network.

MariaDB remains isolated from the proxy network and Plex remains on host networking.

---

## Engineering Approach

StreamForge changes follow a simple operating principle:

> One small controlled change, validate it, document it, then expand.

Infrastructure work is deliberately performed in stages:

1. Understand the current architecture.
2. Define the problem being solved.
3. Design the change and rollback path.
4. Validate configuration before deployment.
5. Deploy the smallest practical change.
6. Verify service health and user facing behaviour.
7. Document the resulting architecture.
8. Commit the validated state to Git.

This approach reduces unnecessary production risk while making architectural decisions explicit and reproducible.

---

## Git Workflow

Production infrastructure follows:

**MacBook → GitHub → Production Server**

1. Configuration or documentation is edited on the MacBook.
2. Changes are reviewed locally using Git.
3. A focused commit records the architectural change.
4. The commit is pushed to GitHub.
5. Production pulls the validated configuration.
6. Only affected services are recreated where necessary.
7. Service and infrastructure health are validated after deployment.

Infrastructure changes are intentionally kept small and reversible.

---

## Backup and Recovery

StreamForge uses automated backups to a dedicated Synology NAS backup location.

The current backup strategy protects:

- Application configuration under `/opt/appdata`
- Production environment files
- Docker Compose definitions
- StreamForge documentation
- Firefly III data through logical MariaDB dumps
- Backup logs and manifests

Recovery procedures are documented separately and tested incrementally.

A Homepage configuration restore has been successfully completed.

MariaDB logical backup creation and compressed file integrity have been validated; a full isolated database restore test remains planned.

---

## Current Platform State

Major completed milestones include:

- Production workloads migrated to Git-managed Docker Compose
- Production server upgraded from Ubuntu 20.04 to Ubuntu 22.04 LTS
- Application stacks separated by responsibility
- Dedicated NAS backup storage implemented
- Automated application and database backups implemented
- Disaster recovery procedures documented
- Homepage restore successfully tested
- Caddy reverse proxy deployed
- Dedicated Docker proxy network deployed
- Central private DNS implemented through UniFi
- `.streamforge.internal` service namespace deployed
- Direct service access preserved for rollback
- Plex reviewed and retained as an intentional host-networked exception
- Database services kept isolated from the reverse-proxy network

---

## Current Engineering Focus

The next major phases of StreamForge focus on:

1. **Secure remote access** — design and implement Tailscale without exposing services publicly.
2. **Network segmentation** — introduce deliberate trust boundaries and firewall policy using UniFi VLANs.
3. **Recovery maturity** — validate MariaDB restoration, improve backup retention, and design offsite protection.
4. **Platform automation** — expand validation, deployment, and infrastructure automation.
5. **Observability** — introduce centralized monitoring, logging, and alerting.

HTTPS/TLS remains deliberately deferred until the internal certificate and trust model is properly designed.

---

## Documentation

Detailed operational and architectural documentation is maintained within the repository:

- `docs/current-state.md` — deployed architecture and current platform state
- `docs/disaster-recovery.md` — recovery procedures and restore validation
- `docs/service-classification.md` — service priority and recovery classification
- `docs/issues.md` — known issues and tracked operational concerns
- `docs/future-ideas.md` — future platform ideas
- `environments/production/*/POST_DEPLOY.md` — environment-specific deployment validation

---

## Secrets and Private Configuration

Secrets and environment-specific configuration are intentionally excluded from the public repository.

- `.env` files remain on the appropriate host.
- `env.example` files document required configuration without containing secrets.
- Application runtime state is stored outside Git.
- Private infrastructure values are included only where appropriate to understanding the architecture.

---

## Project Direction

StreamForge is intentionally developed incrementally rather than through large infrastructure changes.

The long term goal is to continue evolving the environment into a reliable, documented and increasingly automated platform while demonstrating transferable DevOps and Platform Engineering practices.

The technologies may change over time; the engineering principles remain the same:

**design deliberately, automate where valuable, reduce unnecessary risk, validate recovery, and document decisions.**
