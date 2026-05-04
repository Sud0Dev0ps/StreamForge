# Day 7 — Shared Storage Architecture & Multi-Service Foundation

## Objective
Standardise storage across services and extend the staging environment to support multiple applications (Sonarr + Radarr) using a consistent, production aligned design.

---

## Key Design Decision — Unified Data Path
Defined a **single container path** for all media-related services:
```text
/data
```

### Internal Structure
/data/
├── media/
│   ├── tv/
│   └── movies/
└── downloads/
├── complete/
└── incomplete/

---

## Architecture Principle
Containers should never depend on host-specific paths.
| Environment | Host Path | Container Path |
| ----------- | --------- | -------------- |
| Production  | /mnt/data | /data          |
| Staging     | ../data   | /data          |

This ensures:
* portability
* consistency across environments
* compatibility between services

---

## Implementation

### Shared Data Directory
Created a central data directory:
~/homelab/docker/data/
Populated with required structure:
* media/tv
* media/movies
* downloads/service/complete
* downloads/service/incomplete

---

### Sonarr Refactor
Updated volume mapping:

```yaml
volumes:
  - ./config:/config
  - ../data:/data
```

Removed incorrect self-referencing symlink:
```text
data -> data/   ❌ invalid
```

---

### Radarr Deployment
Created new service using same structure and conventions:
* consistent compose format
* identical `/data` mapping
* separate config directory
* shared storage layer

```yaml
volumes:
  - ./config:/config
  - ../data:/data
```

---

## Issue Encountered

### Problem
Docker failed to start container due to invalid mount path:

```text
mkdir .../sonarr/data: file exists
```

### Root Cause
Misconfigured symbolic link:

```text
data -> data/
```

This created a recursive reference, preventing Docker from resolving the mount target.

### Resolution
* Removed symlink
* Replaced with explicit relative path (`../data`)
* Standardised volume mappings across services

---

## Validation

### Cross-Container Visibility Test
Created test file:

```bash
touch ~/homelab/docker/data/shared-test.txt
```

Verified visibility from both containers:

```bash
docker exec -it sonarr-staging ls /data
docker exec -it radarr ls /data
```

Result:
Both containers accessed the same filesystem

---

### Functional Validation
* Sonarr and Radarr both running
* UI accessible from external machine
* Containers stable across restart/recreate
* Data persisted correctly

---

## Key Learnings
* Shared storage is critical for multi-service systems
* Container paths must be consistent across all services
* Avoid symlinks for infrastructure — use explicit paths
* Docker volume mounts require valid, resolvable directories
* `docker exec` is essential for validating container perspective

---

## Outcome
Established a:
* multi-service Docker environment
* shared storage layer
* production-aligned path strategy
* reproducible deployment model

This enables future integration between:
* Sonarr
* Radarr
* download clients (NZBGet / qBittorrent)

---

## Next Steps
* Add Prowlarr (indexer management)
* Introduce download client
* Connect services into full media pipeline
* Begin consolidating into multi-service docker-compose
