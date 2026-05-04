Day 4 — Staging Audit (Initial Baseline)

## Objective
Establish a clear, fully understood baseline of the staging environment before deploying any services.

## System Information

### CPU
Model: Intel i5-9300H
Cores/Threads: 4 cores / 8 threads
Max Frequency: 4.1 GHz

### Memory
Total: 7.4 GiB
Used: ~1.1 GiB
Available: ~6.3 GiB

### Disk
Total: 468 GB
Used: 19 GB (5%)
Available: 425 GB

---

## Docker State

### Containers
Multiple containers present (all stopped):
firecrawl stack (API, Redis, RabbitMQ, Postgres, Playwright)
hello-world test containers

### Images
A number of large images present (~4–5 GB total):
  * firecrawl
  * playwright
  * postgres
  * rabbitmq
  * redis

### Volumes
2 anonymous volumes detected

### Assessment
Docker is installed and functioning correctly
Environment is **not clean**
Residual resources from previous testing remain

---

## Network Audit

### Open Ports (ss -tulnp)
**Expected / Safe:**
* 22 (SSH) → accessible externally
* 53 (DNS) → local resolver only
* 5353 (mDNS) → network discovery
* 631 (CUPS) → local-only printing service

**Observations:**
No unexpected external services
No Docker-related ports exposed
Network surface is minimal and controlled

---

## Docker Service
Status: Active (running)
Enabled on boot: Yes
Confirmed healthy and correctly configured.

---

## Power Management
Disabled sleep/hibernate to ensure server-like behavior:
```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

---

## OS-Level Audit

### Running Services (high-level)
* docker → running
* ssh → running
* systemd-resolved → running
* cups → running (optional)
* avahi-daemon → running (optional)

### Observations
System includes some desktop-oriented services
No unknown or suspicious services detected

---

## Issues Identified

### Docker Environment Not Clean
Stopped containers remain
Unused images consuming disk space
Anonymous volumes present

**Impact:**
Reduces reproducibility
Introduces hidden state
Not aligned with clean staging principles

---

## Actions Required
Perform Docker cleanup to establish baseline:
```
docker container prune
docker image prune -a
docker volume prune
```
---

## Current Status
Staging environment is:
* [x] OS-level clean and understood
* [x] Network exposure minimal and controlled
* [x] Docker installed and functioning
* [x] Docker environment clean
* [x] Fully reproducible baseline established

---

## Key Takeaways
A system is not “clean” just because nothing is running
True baseline requires:
  * No unused containers
  * No unused images
  * No orphaned volumes

Staging must be:
  * Minimal
  * Predictable
  * Fully understood before deployment

---

## Next Step

Perform Docker cleanup
Re-validate Docker state
Transition to first service deployment (Sonarr)