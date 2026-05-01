# Current State

---

# Production Server

## System Info

* **OS:** Ubuntu 20.04.6 LTS
* **CPU:** AMD Ryzen 5 PRO 2400G @ 3.6 GHz
* **RAM:** 24GB (Swap: 8GB)
* **Disk:** `/dev/nvme0n1p2` — 234G total, 25G used (12%)

---

## Running Containers

### Management
* Dockhand → 3000
* Homepage → 3001

### Media Stack
* Plex (no external port exposed via Docker)

* **Sonarr**
  * Port: 8989
  * Config: `/opt/docker/sonarr → /config`
  * Media: `/mnt/data → /data`
  * Storage: bind mounts

* Radarr → 7878

* Prowlarr → 9696

* NZBGet → 6789

* Overseerr → 5055

* Navidrome → 4533

### Personal
* **Firefly**
  * Port: 8090
  * Upload storage: anonymous Docker volume
  * ⚠️ Risk: data location not clearly managed

* **MariaDB (Firefly DB)**
  * Port: internal (3306)
  * Data: `firefly_mariadb` (named volume)
  * Storage: named volume

---

## On-Demand Containers
The following services are intentionally stopped and started only when needed:
* metube
* pyload-ng
* jellyfin

These are preserved for configuration but are not part of the always-on stack.

---

## Docker Volumes

### Named Volumes
* dockhand_dockhand_data
* firefly_firefly_iii_upload
* firefly_mariadb_data
* freshrss_freshrss_data
* freshrss_freshrss_extensions

### Anonymous Volumes
* 6f703fbd3c1c597d...
* 7c5c2dc20b6bbe2f...
* a7df561a19228794...

**Note:**
Anonymous volumes are not clearly mapped to services and should be migrated to named volumes.

---

# Networking
* Multiple services exposed via host ports
* No reverse proxy or ingress layer

---

# Storage
* Synology share:
  `192.168.10.2:/volume1/data`
  8.8T total / 4.9T used / 3.9T free (56%)
  Mounted at `/mnt/data`

---

# Staging Server

## Overview
* Ubuntu laptop
* Clean Docker installation
* Used for testing before production deployment
* No persistent services (baseline state)

## System Info
* **OS:** Ubuntu 24.04.4 LTS
* **CPU:** Intel i5-9300H @ 3.6 GHz
* **RAM:** 8GB (Swap: 4GB)
* **Disk:** `/dev/nvme0n1p2` — 468G

---

# Observations / Issues

* No orchestration
* No Infrastructure as Code
* Mixed container sources (linuxserver, ghcr, etc.)
* Multiple unused containers
* Large number of exposed ports
* No central logging or monitoring

---

# Risks
* Difficult to rebuild from scratch
* Configurations not tracked in Git
* Potential security exposure via open ports

---

# Unknowns
* Exact volume mappings per container
* Original container run commands
* Environment variables
* Startup configuration
* No defined backup strategy

---

# Rebuild Assessment
Current system is **NOT reproducible** without manual effort.

### Requirements to Rebuild
* Container configurations (missing)
* Volume mappings (partially unknown)
* Environment variables (unknown)
* Startup configuration (unclear)

**Estimated difficulty:** HIGH

---
# Goal
Migrate to a fully reproducible system using:
* Docker Compose
* Git-managed configuration
