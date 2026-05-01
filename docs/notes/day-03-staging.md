# Day 3 — Staging Environment Setup
## Goal
Create a clean staging environment to safely test changes before applying them to production

## Environment
Device: Ubuntu Laptop
Role: Staging / Development

## Docker Installation
Attempted installation:
sudo apt install docker.io docker-compose -y

## Issue Encountered
Installation failed with:
containerd.io : Conflicts: containerd  
E: pkgProblemResolver::Resolve generated breaks  

## Root Cause
Conflicting package sources:
- Ubuntu repository:
  - docker.io
  - containerd
- Docker repository (docker.list):
  - containerd.io
This caused dependency conflicts.

## Resolution
Removed Docker repository and reinstalled using Ubuntu packages:
- Commands used:
    sudo rm /etc/apt/sources.list.d/docker.list  
    sudo apt update  
    sudo apt purge docker docker.io containerd containerd.io -y  
    sudo apt autoremove -y  
    sudo apt install docker.io docker-compose -y  

## Validation
docker run hello-world
Result:
- Docker installed successfully
- Container execution verified

## Key Learnings
Avoid mixing package sources (APT vs vendor repos)
Use a consistent installation method
Troubleshooting package conflicts is a common real-world task

## Outcome
Clean staging environment established
Ready for testing docker-compose configurations
Independent from production system

## Next Step
Begin:
Git repository structure
First service migration to clean docker-compose