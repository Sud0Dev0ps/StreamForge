## [RISK] Production and staging on the same VLAN

**Date identified:** 2025-05-05
**Priority:** Medium
**Status:** Accepted risk — to be resolved in networking phase

### Problem
Production and staging environments currently share the same VLAN.
This means:
- A misconfigured staging service could potentially reach production
- No network-level isolation between environments
- Does not reflect real world infrastructure best practices

### Risk
Low likelihood but high impact. 
A mistake in staging could affect production services or data.

### Mitigation until resolved
- Be deliberate about which machine you are working on
- Double check environment before making changes
- Never test destructive operations on staging without verifying you are not connected to production resources

### Resolution plan
Implement VLAN separation via UniFi during the networking module.
- Production VLAN: dedicated, restricted access
- Staging VLAN: isolated from production

----

## [30/4/2026] - Docker installation failed (containerd conflict)

### Context
Install Docker onto development machine

### Problem
Installation failed with:
containerd.io : Conflicts: containerd
E: pkgProblemResolver::Resolve generated breaks

### Root Cause
Ubuntu repo → docker.io + containerd  
Docker repo (docker.list) → containerd.io  
These repos caused a package conflict

### Resolution
Removed Docker repo to enforce a single package source:

Commands executed:
sudo rm /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt purge docker docker.io containerd containerd.io -y
sudo apt autoremove -y
sudo apt install docker.io docker-compose -y

### Validation
docker run hello-world
Result: successful container execution

### Lessons Learned
Avoid mixing package sources (APT vs vendor repos)
Prefer consistency over latest version
Validate installation sources before installing tools