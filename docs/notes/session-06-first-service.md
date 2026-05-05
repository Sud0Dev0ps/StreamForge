# Session 6 — First Service Deployment (Sonarr)

## Objective
Deploy the first application (Sonarr) in the staging environment using a clean, reproducible and production style Docker setup.

---
## Environment
* Host: Ubuntu Laptop (Staging)
* Role: Dev/Test environment
* Docker: Clean baseline (no containers, images, or volumes)

---
## Implementation

### Directory Structure
Created a service-specific structure:
~/homelab/docker/sonarr/
├── config/
└── data/

This ensures:
* separation of concerns
* persistent configuration
* portability across environments

---
### Docker Compose Configuration
Defined Sonarr as a service using docker-compose:
* Image: linuxserver/sonarr
* Port: 8989
* Volumes:
  * ./config → /config
  * ./data → /data
* Environment:
  * PUID/PGID for permissions
  * TZ for consistency
* Restart policy: unless-stopped

Key design decision:
👉 Use **relative bind mounts** for portability and version control compatibility

---
## Deployment
Executed:
docker compose up -d
Validation steps:
* Container running (`docker ps`)
* Logs healthy (`docker logs`)
* UI accessible via browser

---
## Validation & Testing
Performed multiple checks:
* Local connectivity:
  curl http://localhost:8989 → response received (401 expected)

* Remote connectivity:
  Accessed from MacBook via:
  http://192.168.3.145:8989

* Container lifecycle:
  * restart tested
  * destroy/recreate tested (`docker compose down && up`)

Result:
✅ Configuration persisted correctly
✅ Service stable and reproducible

---
## Issue Encountered

### Problem
Web UI initially not accessible via browser

### Investigation
* Verified container running
* Verified port mapping (0.0.0.0:8989)
* Verified firewall (inactive)
* Tested with curl → received HTTP 401 (service responding)

### Root Cause
Browser-specific issue (not infrastructure or service related)

### Resolution
Switched browser / session → UI loaded successfully

---
## Key Learnings
* HTTP 401 does NOT mean failure → indicates service is reachable but requires proper request context
* Always validate using multiple layers:
  * container
  * network
  * service response
  * client (browser)
* Docker port binding (`0.0.0.0`) is critical for external access
* Reproducibility requires:
  * clean volumes
  * defined structure
  * controlled deployment

---
## Outcome
Successfully deployed a:
* containerized
* reproducible
* externally accessible

service in staging
This marks the transition from:
“running apps manually”
to
“deploying managed services”

---
## Next Steps
* Repeat process for Radarr
* Introduce shared media/download paths
* Refactor configuration using `.env` files
* Begin multi-service docker-compose design