# StreamForge

## Overview
StreamForge is a production like DevOps homelab project designed to simulate realworld infrastructure and workflows.

The goal is to transition from a traditional system administration background into a DevOps role by building, automating and operating a fully reproducible platform.


## Architecture
- **Production**: Ubuntu Server (media stack + services)
- **Staging/Dev**: Ubuntu Laptop
- **Client**: MacBook (development + Git)
- **Storage**: Synology NAS
- **Networking**: UniFi (planned VLAN segmentation)


## Tech Stack
- Docker / Docker Compose
- Ansible (planned)
- Terraform (planned)
- Kubernetes (K3s - planned)
- GitHub Actions (planned)
- Prometheus / Grafana / Loki (planned)


## Project Goals
- Build a fully reproducible homelab environment
- Implement Infrastructure as Code (IaC)
- Create CI/CD pipelines
- Migrate workloads to Kubernetes
- Implement observability and monitoring
- Demonstrate production-ready practices


## Current Status

**Phase**: Week 1 — Foundations

- [x] System audit completed
- [x] Git repository initialized
- [x] Documentation baseline created
- [x] Docker environment cleanup
- [x] First service migrated to docker-compose
