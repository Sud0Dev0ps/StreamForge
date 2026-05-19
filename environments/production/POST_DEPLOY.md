# StreamForge Post Deployment Configuration
After running `docker compose up -d` 
Follow the configuration steps below, then use the verification checklist to confirm everything is working.

---

## Configuration Steps

### Prowlarr (Indexer Manager)
**Access:** `http://production-ip:9696`

#### Authentication (Recommended)
- Navigate to: Settings → General → Security
- Set Authentication to: **Forms (Login Page)**
- Create username and password

#### Connect Applications
- Navigate to: Settings → Apps → Add

**For Sonarr:**
- Prowlarr Server: `http://localhost:9696` (default)
- Sonarr Server: `http://production-ip:8989`
- API Key: Copy from Sonarr → Settings → General → Security → API Key
- Test connection and save

**For Radarr:**
- Prowlarr Server: `http://localhost:9696` (default)
- Radarr Server: `http://production-ip:7878`
- API Key: Copy from Radarr → Settings → General → Security → API Key
- Test connection and save

#### Add Indexers
- Navigate to: Indexers → Add Indexer
- Add your Usenet indexers
- Configure with your indexer API keys/credentials
- Prowlarr will automatically sync these to Sonarr and Radarr

---

## Verification Checklist

### Prowlarr
- [ ] UI accessible at `http://production-ip:9696`
- [ ] Authentication enabled (credentials stored securely)
- [ ] Sonarr connected (API key verified)
- [ ] Radarr connected (API key verified)
- [ ] Indexers added and configured
- [ ] Indexers successfully synced to both Sonarr and Radarr

---

## Network Architecture
All services run on the `media_network_prod` Docker bridge network (`172.31.0.0/16`) and communicate using production server IP until all services are migrated:
- `prowlarr` → `172.31.0.5`