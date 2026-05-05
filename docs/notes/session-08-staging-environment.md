# Session — Staging Environment & Git Foundations

## Work completed
- Reviewed repo structure (ansible, docker, kubernetes, terraform, environments, scripts)
- Designed the environments/ folder structure
- Cleaned up a real Portainer-generated Sonarr compose file
- Created our first environment-aware compose file
- Created .env.example template
- Written a production-grade .gitignore

## Key concepts learned

### Environment separation
- Staging and production must be isolated
- Same docker-compose.yml should work across both
- Only the .env changes between environments

### Configuration principles
- Only define what is explicitly changing from defaults
- Anything that differs between environments belongs in .env
- Hardcoded values in compose files = future problems

### Secrets management
- Never commit real credentials to Git
- .env stays on the server only
- .env.example documents what's needed without exposing values

### .gitignore strategy
- *.env catches all variants
- !.env.example explicitly protects the template
- Future-proofed for Terraform, Ansible, Python

### Git habits
- git add files explicitly rather than git add .
- git status before every commit
- Never rely on memory — verify the state
