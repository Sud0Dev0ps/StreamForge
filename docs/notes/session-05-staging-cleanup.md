# Session 5 — Staging Cleanup & Baseline Validation

## Objective
Establish a fully clean, minimal, and reproducible staging environment before deploying any services.

---

## Docker Cleanup
### Actions Taken
* Removed all stopped containers
* Removed all unused images
* Removed all Docker volumes

### Commands Used
```
docker container prune
docker image prune -a
docker volume prune
```
---

## Docker State (Post-Cleanup)

### Containers
* None present
### Images
* None present
### Volumes
* None present

### Assessment
Docker environment is fully clean with no residual state from previous testing.

---

## Network Audit

### Command
```
ss -tulnp
```

### Results
**Active Ports:**
* 22 (SSH) → accessible externally
* 53 (DNS) → local resolver only (127.0.0.x)

**Internal/Ephemeral:**
* 127.0.0.1:44027 (temporary internal port)

### Removed During Cleanup
* CUPS (631) → removed
* mDNS / Avahi (5353) → removed

### Assessment
* No unnecessary external exposure
* No Docker-related ports open
* Network surface is minimal and controlled

---

## OS-Level Cleanup

### Disabled Services
* CUPS (printing service)
* Avahi (mDNS / network discovery)

### Commands Used
```
sudo systemctl disable --now cups
sudo systemctl disable --now avahi-daemon
```

### Additional Systemd Cleanup
Disabled socket-based activation to fully prevent services from starting:

```
sudo systemctl disable --now cups.socket cups.path
sudo systemctl disable --now avahi-daemon.socket
```

### Outcome
* Services fully disabled
* No automatic reactivation via systemd sockets

---

## Running Services Review
### Command
```
systemctl list-units --type=service --state=running
```

### Observations
* Core system services active (systemd, NetworkManager, etc.)
* Docker service running and enabled
* SSH service running
* Desktop-related services still present (GNOME, Bluetooth, etc.)

### Assessment
* No unknown or suspicious services
* System remains stable and understandable
* Some desktop components retained (acceptable for staging laptop)

---

## Key Decisions
* Removed non-essential services (CUPS, Avahi) to reduce network exposure
* Accepted remaining desktop services as part of laptop-based staging
* Prioritized **understanding and control** over aggressive minimalism

---

## Final Validation
### Docker
* [x] No containers
* [x] No images
* [x] No volumes

### Network
* [x] Only SSH externally exposed
* [x] No unnecessary ports

### OS
* [x] Services understood
* [x] No unexpected processes
* [x] Stable system state

---

## Final Status
Staging environment is:

* [x] Clean
* [x] Minimal
* [x] Predictable
* [x] Fully understood
* [x] Reproducible baseline established
* [x] Ready for service deployment

---

## Key Takeaways
* A system is not “clean” just because nothing is running
* Docker artifacts persist unless explicitly removed
* systemd services can be triggered by sockets even when disabled
* True baseline requires:
  * No leftover containers
  * No unused images
  * No orphaned volumes
* Network exposure must be intentionally controlled

---

## Next Step
**Day 6 — First Service Deployment (Sonarr)**

Focus:
* Build clean `docker-compose.yml`
* Design proper volume structure
* Validate in staging before production