# StreamForge Infrastructure Stack — Post Deployment Configuration

After running `docker compose up -d` from `environments/production/infrastructure/`, follow the steps below to verify the stack is running correctly.

---

## Prerequisites

- `infra_network_prod` network created via `setup-network.sh`
- `.env` file in place at `environments/production/infrastructure/.env`
- Config folder present at `/opt/appdata/dockhand/`

---

## Configuration Steps

### Dockhand (Docker Management)
**Access:** `http://production-ip:3000`

#### First Run
- Navigate to the UI — no initial configuration required
- Dockhand will automatically discover running containers via the Docker socket
- Review container list to confirm all expected services are visible

---

## Verification Checklist

### Dockhand
- [ ] UI accessible at `http://production-ip:3000`
- [ ] Running containers visible in the dashboard
- [ ] Docker socket mounted correctly (container management functional)

---

## Network Architecture

Infrastructure services run on a dedicated `infra_network_prod` network (172.32.0.0/16), isolated from the media stack.

| Service | Network |
|---------|---------|
| dockhand | infra_network_prod |

---

## Rollback

```bash
docker compose down
cd /opt/docker/dockhand
docker compose up -d
```