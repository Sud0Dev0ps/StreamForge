# StreamForge — Future Ideas

This document captures potential future improvements and experiments for StreamForge.

Items listed here are ideas rather than committed implementation plans. Architecture, security impact, operational complexity and rollback requirements should be evaluated before implementation.

---

## Remote Access

### Tailscale

Provide secure remote access to StreamForge without exposing services directly to the public internet.

Areas to evaluate:

- Subnet routing versus per-device Tailscale
- Which StreamForge networks should be remotely reachable
- Access to `.streamforge.internal` hostnames
- Split DNS requirements
- UniFi DNS integration
- Tailnet ACLs and least-privilege access
- NAS and management-network access boundaries

Architecture planning should be completed before implementation.

---

## Network Segmentation

### UniFi VLAN Segmentation

Reduce unnecessary trust between device groups while preserving required StreamForge service flows.

Potential areas:

- Trusted client network
- Server network
- IoT devices
- Management interfaces
- NAS connectivity
- Media streaming
- DNS access
- Inter-VLAN firewall policy

Firewall requirements and rollback procedures should be documented before rules are applied.

---

## Internal HTTPS/TLS

Evaluate whether internal HTTPS provides sufficient operational or security benefit to justify certificate-management complexity.

Potential approaches:

- Caddy internal CA
- Locally managed trusted CA
- Public-domain certificate architecture

Key considerations:

- Certificate trust distribution
- Browser and mobile-device behaviour
- Streaming-device compatibility
- Operational recovery
- Avoiding permanent certificate warnings

HTTP remains the accepted LAN-only configuration until a complete trust model is designed.

---

## Media Platform Evaluation

### Plex and Jellyfin

Plex currently remains the primary media server and intentionally uses Docker host networking.

Jellyfin is also deployed and available through the StreamForge reverse proxy.

Future evaluation could compare:

- TV and streaming-device client availability
- Mobile clients
- Offline media support
- Remote streaming
- User management
- Hardware transcoding
- Library compatibility
- Migration effort
- Operational simplicity

No Plex networking or proxy changes should be made solely for architectural consistency.

---

## Backup and Recovery

### Backup Retention and Pruning

Define a deliberate retention policy for StreamForge backups.

Potential goals:

- Protect recent recovery points
- Retain longer-term monthly recovery points
- Prevent uncontrolled NAS storage growth
- Introduce safe dry-run validation before automated deletion

### MariaDB Restore Validation

Perform an isolated restore of a Firefly III MariaDB logical dump.

The existing backup creation and compressed-file integrity checks do not prove that the database can be successfully restored.

### Offsite Backup

Evaluate encrypted offsite protection for critical StreamForge data.

Potential approaches:

- Cloud object storage
- Encrypted external storage
- Secondary NAS or remote location

Recovery-key storage and restore procedures should be considered part of the design.

### Dockhand Backup Strategy

Investigate a safe method for protecting Dockhand configuration without weakening the permissions around its encryption key.

---

## Observability

Evaluate centralized monitoring, logging and alerting for StreamForge.

Potential capabilities:

- Host health monitoring
- Container health monitoring
- Disk and NAS capacity alerts
- Backup success/failure alerts
- Service availability monitoring
- Centralized logs
- Resource trend visibility

Tool selection should follow the monitoring requirements rather than drive them.

---

## Automation

### n8n

Evaluate n8n as an optional workflow-automation platform.

Potential use cases:

- Health-check notifications
- Media download notifications
- Backup completion or failure alerts
- Operational workflows
- CI/CD webhook triggers

### Infrastructure Automation

Potential future areas:

- Ansible host configuration
- Automated rebuild procedures
- Configuration validation
- Deployment checks
- Repeatable environment provisioning

Automation should target proven repetitive processes rather than adding complexity for its own sake.

---

## CI/CD

Explore lightweight CI/CD improvements for the StreamForge Git workflow.

Potential checks:

- Docker Compose validation
- Caddy configuration validation
- Shell script linting
- Markdown checks
- Secret detection
- Automated configuration tests

Production deployment should remain controlled until automated validation and rollback behaviour are well understood.

---

## Platform Evolution

Continue reviewing opportunities to improve StreamForge as both a reliable homelab and a practical DevOps/Platform Engineering learning environment.

Future technology choices should support the underlying engineering goals:

- Reproducibility
- Recoverability
- Security
- Observability
- Automation
- Maintainability
- Clear documentation
