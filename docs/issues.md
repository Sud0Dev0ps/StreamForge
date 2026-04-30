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