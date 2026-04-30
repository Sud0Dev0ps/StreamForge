# Day 1 — Production System Audit

## Goal
Establish a clear baseline of the current production environment before making any changes.

## Actions Performed
Executed system inspection commands:
lscpu
docker ps -a
docker images
df -h
free -h
ss -tulnp

## Environment Summary

### System
- OS: Ubuntu 20.04.6 LTS
- CPU: AMD Ryzen 5 2400G
- RAM: 24GB (8GB swap)
- Disk: 234GB SSD (12% used)

### Storage
- NAS mounted at: /mnt/data
- Capacity: 8.8TB (approx. 56% used)

## Running Containers

### Media Stack
- Plex
- Sonarr (8989)
- Radarr (7878)
- Prowlarr (9696)
- NZBGet (6789)
- Overseerr (5055)

### Applications
- Homepage (3001)
- Navidrome (4533)
- Firefly (8090)

### Supporting Services
- MariaDB (internal)
- Dockhand (3000)

## Inactive / Unused Containers
- metube (exited)
- pyload-ng (never started)
- jellyfin (unused)

## Networking
- Multiple services exposed via host ports
- No reverse proxy or central ingress
- Plex running in host network mode

## Storage Configuration
- Mix of bind mounts (/opt/docker, /mnt/data)
- Named Docker volumes used for some services
- Volume mappings not fully documented

## Key Observations
- No centralized orchestration
- No infrastructure as code
- Services deployed manually via docker-compose
- Mixed image sources (linuxserver, ghcr, etc.)
- Large number of exposed ports
- No monitoring or logging stack

## Risks Identified
- System is not easily reproducible
- Configuration not tracked in version control
- Unknown dependencies between services
- Potential security exposure from open ports

## Unknowns
- Exact environment variables per container
- Full volume mapping details
- Startup/boot process
- Backup coverage

## Outcome
A baseline snapshot of the system was captured
This will be used to:
- guide cleanup decisions
- support migration to Infrastructure as Code
- validate future rebuild capability