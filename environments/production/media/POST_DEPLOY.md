# StreamForge Post Deployment Configuration
After running `docker compose up -d` 
Follow the configuration steps below, then use the verification checklist to confirm everything is working.

---

## Configuration Steps

### Radarr (Movies)
**Access:** `http://production-ip:7878`

#### Authentication (Recommended)
- Navigate to: Settings → General → Security
- Set Authentication to: **Forms (Login Page)**
- Create username and password
- **Important:** Keep "Disable authentication for local addresses" **UNCHECKED**

#### Media Management
- Navigate to: Settings → Media Management → Root Folders
- Add Root Folder: `/data/media/movies`

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

### NZBGet
- [ ] UI accessible at `http://staging-ip:6789`
- [ ] Default password changed
- [ ] News server(s) configured and tested
- [ ] Categories `tv` and `movies` exist
- [ ] Downloads completing to `path/to/downloads/usenet/completed/`

### Prowlarr
- [ ] UI accessible at `http://production-ip:9696`
- [ ] Authentication enabled (credentials stored securely)
- [ ] Sonarr connected (API key verified)
- [ ] Radarr connected (API key verified)
- [ ] Indexers added and configured
- [ ] Indexers successfully synced to both Sonarr and Radarr

### Radarr
- [ ] UI accessible at `http://production-ip:7878`
- [ ] Authentication enabled (credentials stored securely)
- [ ] Root folder `/data/media/movies` configured
- [ ] NZBGet download client added and tested
- [ ] qBittorrent download client added and tested
- [ ] Remote path for NZBget mapping configured correctly
- [ ] Remote path mapping qBittorrent configured correctly
- [ ] Indexers synced from Prowlarr (visible in Settings → Indexers)
- [ ] **End-to-end test:** Search for a movie → Download → Verify import to `/data/media/movies/`

### Sonarr
- [ ] UI accessible at `http://production-ip:8989`
- [ ] Authentication enabled (credentials stored securely)
- [ ] Root folder `/data/media/tv` configured
- [ ] NZBGet download client added and tested
- [ ] qBittorrent download client added and tested
- [ ] Remote path for NZBget mapping configured correctly
- [ ] Remote path mapping qBittorrent configured correctly
- [ ] Indexers synced from Prowlarr (visible in Settings → Indexers)
- [ ] **End-to-end test:** Search for a TV episode → Download → Verify import to `/data/media/tv/`

---

## Network Architecture
All services run on the `media_network_prod` Docker bridge network (`172.31.0.0/16`) and communicate using production server IP until all services are migrated:
- `navidrome` → `172.31.0.x`
- `nzbget` → `172.31.0.x`
- `seerr` → `172.31.0.x`
- `radarr` → `172.31.0.x`
- `homepage` → `172.31.0.x`
- `prowlarr` → `172.31.0.x`
- `sonarr` → `172.31.0.x`