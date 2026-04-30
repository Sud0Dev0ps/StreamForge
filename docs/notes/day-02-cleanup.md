# Day 2 — Cleanup and Initial Structure
## Goal
Reduce clutter, remove unused resources and begin organising the environment for maintainability.

## Actions Performed

### Docker Cleanup
Removed unused containers:
docker container prune
Removed unused images:
docker image prune -a

## Volume Inspection
Listed volumes:
docker volume ls

Observed:
- mixture of named and anonymous volumes
- some volumes tied to inactive containers

Decision:
- do not delete volumes yet (to avoid data loss)

## Directory Structure
Created initial project structure:
~/homelab/
├── docker/
├── scripts/
└── docs/

## Existing Configuration
Discovered existing service layout:
/opt/docker/
- each service stored in its own folder
- each service contains its own docker-compose.yml

Assessment:
- functional but not version controlled
- inconsistent structure
- not aligned with Infrastructure as Code practices

## Key Decisions
- Keep existing services running (no disruption)
- Begin migrating configurations into Git managed structure
- Avoid deleting anything critical until fully understood

## Backup Strategy (Initial)
Identified critical data to protect:
- /opt/docker (configs)
- /mnt/data (media + data)
- Docker volumes (databases, uploads)

Decision:
- ensure backup coverage before major changes

## Observations
- Environment contains legacy and unused services
- Configurations are scattered
- No single source of truth

## Outcome
- Environment cleaned of unused containers/images
- Initial structure created for project
- Clear direction set for migration to reproducible setup