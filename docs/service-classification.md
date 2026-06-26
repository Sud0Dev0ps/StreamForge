# StreamForge Service Classification and Recovery Priorities

**Version:** 1.0  
**Last Updated:** June 2026  
**Status:** Active

---

## Purpose

This document defines StreamForge service criticality, recovery priorities, Recovery Time Objectives and Recovery Point Objectives.

The goal is to avoid treating every service equally during an outage.

**Recovery effort should reflect business impact. Restore what matters first.**

This document focuses on **what matters first**.

For exact recovery steps, see: [`docs/disaster-recovery.md`]

---

## Scope

This document covers the current StreamForge production environment running on **dockerserver**.

It supports Disaster Recovery planning by defining:
- Which services are most important
- Which services should be restored first
- How quickly services should return
- How much data loss is acceptable
- Which components are disposable

---

## Current Production Stack Summary

StreamForge currently consists of three Docker Compose projects.

| Project | Containers |
|---------|-----------|
| media | 10 |
| finance | 2 |
| infrastructure | 1 |

**Expected state:**
```
finance          running(2)
infrastructure  running(1)
media           running(10)
```

---

## Source of Truth

The GitHub repository is the source of truth for infrastructure definitions.

**Production repository location:** `~/StreamForge`

**Key production compose files:**
```
environments/production/media/docker-compose.yml
environments/production/finance/docker-compose.yml
environments/production/infrastructure/docker-compose.yml
```

**Secrets are not stored in Git.**

Production environment files are stored locally on the production server:
```
environments/production/media/.env
environments/production/finance/.env
environments/production/infrastructure/.env
```

These files are backed up daily.

---

## Definitions

### Recovery Time Objective

**Recovery Time Objective, or RTO,** is the maximum acceptable time before a service should be restored.

**Example:** If Plex has an RTO of 1 hour, the target is to restore Plex within 1 hour of an outage.

---

### Recovery Point Objective

**Recovery Point Objective, or RPO,** is the maximum acceptable amount of data loss.

**Current backup schedule:** Daily at 12:00

Therefore most backed-up application configuration currently has an RPO of approximately **24 hours**.

---

## Tier 1 — Critical Services

These services should be restored first.

Users or core platform operation are immediately impacted if these services are unavailable.

| Service | Purpose | Target RTO | Current RPO | Reason |
|---------|---------|-----------|-----------|--------|
| **Homepage** | Operational dashboard | 15 min | 24 hrs | Main visibility and service entry point |
| **Plex** | Primary media platform | 1 hr | 24 hrs | Main household media service |
| **Prowlarr** | Indexer management | 1 hr | 24 hrs | Required for automation pipeline |
| **Sonarr** | TV automation | 1 hr | 24 hrs | Core media automation |
| **Radarr** | Movie automation | 1 hr | 24 hrs | Core media automation |
| **NZBGet** | Download pipeline | 1 hr | 24 hrs | Required for automated downloads |

---

## Tier 2 — Important Services

These services matter, but interruption is acceptable for a longer period.

| Service | Purpose | Target RTO | Current RPO | Reason |
|---------|---------|-----------|-----------|--------|
| **Jellyfin** | Secondary media platform | Same day | 24 hrs | Useful fallback, but not primary |
| **Navidrome** | Music streaming | Same day | 24 hrs | Useful but not urgent |
| **Seerr** | Media requests | Same day | 24 hrs | Requests can wait during outage |
| **Firefly III** | Personal finance | Same day | 24 hrs | Important data, but not time-critical |
| **MariaDB** | Firefly database | Same day | 24 hrs | Required by Firefly III |

---

## Tier 3 — Convenience or Disposable Services

These services have low operational impact and can be restored after higher-priority services.

| Service | Purpose | Target RTO | Current RPO | Reason |
|---------|---------|-----------|-----------|--------|
| **MeTube** | Manual media downloads | Best effort | None | Convenience service |
| **Dockhand** | Container visibility | Best effort | None | Helpful but not required |
| **Downloads** | Temporary download data | N/A | None | Disposable working data |

---

## Critical Assets

### Git Repository

**Purpose:**
- Docker Compose files
- Documentation
- Scripts
- Templates

**Target RTO:** 1 hour

**Target RPO:** Near zero

---

### Application Configuration

**Location:** `/opt/appdata`

**Backup location:** `/mnt/data/backups/streamforge/appdata`

**Target RTO:** 1–2 hours

**Target RPO:** 24 hours

---

### Production Environment Files

**Live location:**
```
~/StreamForge/environments/production/media/.env
~/StreamForge/environments/production/finance/.env
~/StreamForge/environments/production/infrastructure/.env
```

**Backup location:** `/mnt/data/backups/streamforge/env`

**Target RTO:** 1 hour

**Target RPO:** 24 hours

---

### NAS Media Library

**Location:** `/mnt/data/media`

**Current backup status:** Not backed up

**Risk decision:** Accepted for now

The media library is important, but it is too large to include in the current backup strategy. Future improvement may include NAS snapshots, Hyper Backup or offsite backup for selected critical media.

---

### Downloads

**Location:** `/mnt/data/downloads`

**Current backup status:** Disposable

Downloads are working data and are not considered critical.

---

## Recovery Priority Order

During a major outage, restore in this order:

1. Restore or rebuild the Docker host
2. Confirm network access
3. Confirm NAS mount is available at `/mnt/data`
4. Restore or clone the StreamForge Git repository
5. Restore production `.env` files
6. Restore `/opt/appdata`
7. Confirm Docker is running
8. Confirm Docker Compose projects are available
9. Start infrastructure stack
10. Start media stack
11. Validate Homepage
12. Validate Plex
13. Validate Sonarr, Radarr, Prowlarr, and NZBGet
14. Start finance stack
15. Validate Firefly III
16. Validate convenience services
17. Confirm user facing functionality

---

## Standard Validation Commands

**Check compose projects:**
```bash
docker compose ls
```

**Check running containers:**
```bash
docker ps
```

**Check service logs:**
```bash
docker logs <container-name> --tail 20
```

**Check backup logs:**
```bash
ls -lah /mnt/data/backups/streamforge/logs
tail -20 /mnt/data/backups/streamforge/logs/backup-YYYY-MM-DD.log
```

---

## User-Facing Validation

**Recovery is not complete just because containers are running.**

A service is only considered restored when it works from the user perspective.

**Examples:**

| Service | Validation |
|---------|-----------|
| Homepage | Dashboard loads and cards work |
| Plex | Libraries load and media plays |
| Sonarr | UI loads and system health is clean |
| Radarr | UI loads and system health is clean |
| Prowlarr | Indexers are visible |
| NZBGet | UI loads and paths are correct |
| Firefly III | Login works and data is present |

---

## Known Risks

| Risk | Status |
|------|--------|
| No offsite backup | Accepted for now |
| NAS permissions rely on current Synology mapping | Deferred to security session |
| Media library is not backed up | Accepted for now |
| Restore process is manual | Accepted for now |
| Single operator knowledge | Accepted for now |
| Docker socket exposure through Homepage/Dockhand | Deferred to security session |

---

## Restore Testing History

| Date | Service | Result | Notes |
|------|---------|--------|-------|
| 23 June 2026 | Homepage | Successful | Restored from NAS backup and validated dashboard/cards |

---

## Homepage Restore Test Notes

Homepage was used as the first controlled restore test.

### Test Procedure

1. Confirmed backup existed
2. Confirmed live and backup directory structures matched
3. Stopped Homepage container
4. Renamed live config from `/opt/appdata/homepage` to `/opt/appdata/homepage.broken`
5. Restored Homepage from `/mnt/data/backups/streamforge/appdata/homepage`
6. Started Homepage
7. Validated logs
8. Confirmed dashboard loaded and cards worked

### Observation

Backup ownership appeared as: `1024 users`

Live ownership originally appeared as: `serveradmin serveradmin`

Homepage still started successfully and functioned correctly. This may need further testing with LinuxServer containers, which may be more sensitive to permissions.

---

## Testing Schedule

| Frequency | Activity |
|-----------|----------|
| Daily | Automated backup runs |
| Weekly | Confirm backup logs exist |
| Monthly | Restore-test one low-risk service |
| Quarterly | Review DR runbook and service priorities |
| After major change | Update this document and DR runbook |

---

## Future Improvements

Potential improvements:
- Add offsite backups
- Configure Synology Hyper Backup
- Investigate Snapshot Replication
- Add monitoring and alerting
- Add health checks
- Create Ansible rebuild playbook
- Test restore of a LinuxServer container
- Review NFS permissions
- Review Docker socket exposure
- Define notification expectations during outages

---

## Guiding Principle

**Not every service deserves equal recovery effort.**

During an outage, restore the services that matter most first.

The purpose of this document is to make recovery decisions easier under pressure.

---

## Document History

| Version | Date | Change |
|---------|------|--------|
| 1.0 | June 2026 | Initial service classification and recovery priorities document |