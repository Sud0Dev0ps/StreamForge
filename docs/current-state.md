# Current State — Production Server

## System Info
- OS: Ubuntu 20.04.6 LTS
- CPU: AMD Ryzen 5 PRO 2400G with Radeon Vega Graphics
    CPU MHz: 1.47
    CPU max MHz: 3.6
    CPU min MHz: 1.6
- RAM: 24GB
    Swap 8GB
- Disk: /dev/nvme0n1p2              234G   25G  198G  12% /

## Running Containers

### Management
- Dockhand → 3000
- Homepage → 3001

### Media Stack
- Plex (no external port exposed via docker)
- Sonarr
    Port: 8989
    Config path: /opt/docker/sonarr → /config
    Media path: /mnt/data → /data
    Storage type: bind mounts

- Radarr → 7878
- Prowlarr → 9696
- NZBGet → 6789
- Overseerr → 5055
- Navidrome → 4533

### Personal
- Firefly
    Port: 8090
    Upload storage: anonymous Docker volume
    Risk: data location not clearly managed

- MariaDB (Firefly DB)
    Port: internal (3306)
    Data: firefly_mariadb (named volume)
    Storage type: named volume

## On-Demand Containers
The following services are intentionally stopped and only started when needed:
- metube
- pyload-ng
- jellyfin

These are preserved to retain configuration but are not part of the always-on stack.

## Docker Volumes

### Named Volumes
- dockhand_dockhand_data
- firefly_firefly_iii_upload
- firefly_mariadb_data
- freshrss_freshrss_data
- freshrss_freshrss_extensions

### Anonymous Volumes
- 6f703fbd3c1c597d...
- 7c5c2dc20b6bbe2f...
- a7df561a19228794...

Note:
Anonymous volumes exist and are not clearly mapped to services.
These will need to be identified and migrated to named volumes during docker-compose refactor.

---

## Networking
Multiple services exposed directly via host ports.
No reverse proxy or ingress layer.

## Storage
Storage Synology NTFS share: 192.168.10.2:/volume1/data  8.8T  4.9T  3.9T  56% /mnt/data

## Observations / Issues

- No orchestration
- No infrastructure as code
- Mixed container sources (linuxserver, ghcr, etc.)
- Multiple unused containers
- Large number of exposed ports
- No central logging or monitoring

---

## Risks

- Difficult to rebuild from scratch
- Configurations not tracked in Git
- Potential security exposure via open ports

---

## Unknowns
- Exact volume mappings for each container
- How containers were originally started
- No backup strategy

## Rebuild Assessment

Current system is NOT reproducible without manual effort.

To rebuild, I would need:
- Container run commands or configs (missing)
- Volume mappings (partially unknown)
- Environment variables (unknown)
- Startup configuration (unclear)

Estimated rebuild difficulty: HIGH

Goal:
Migrate to fully reproducible system using docker-compose and Git.