# StreamForge Media Stack — Post Deployment Configuration

After running `docker compose up -d` from `environments/production/media/`, follow the configuration steps below, then use the verification checklist to confirm everything is working.

---

## Prerequisites

- `media_network_prod` network created via `setup-network.sh`
- `.env` file in place at `environments/production/media/.env`
- All config folders present under `/opt/appdata/`
- Homepage config files in place at `/opt/appdata/homepage/config/` (not Git-tracked — copy from backup or configure manually)

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

### Homepage
**Access:** `http://production-ip:3001`

#### Config Files
Homepage config files are **not Git-tracked** — they must be in place at `/opt/appdata/homepage/config/` before the container starts. Files required:
- `services.yaml` — service links and integrations
- `widgets.yaml` — dashboard widgets
- `settings.yaml` — general settings
- `bookmarks.yaml` — bookmarks
- `docker.yaml` — Docker integration

Copy from backup or configure manually on first run.

#### HOMEPAGE_ALLOWED_HOSTS
Ensure `HOMEPAGE_ALLOWED_HOSTS` in `.env` matches your production server IP and port exactly:
HOMEPAGE_ALLOWED_HOSTS=192.168.x.x:3001

### Navidrome (Music)
**Access:** `http://production-ip:4533`

#### First Run
- Navigate to the UI and create your admin account on first access
- Music library will begin scanning automatically from the configured music path
- Scanning may take several minutes depending on library size

### Plex (Media Server)
**Access:** `http://production-ip:32400/web`

#### ⚠️ Network Mode: Host
Plex runs with `network_mode: host` — it binds directly to the host network. This is required for local network device discovery (mDNS). There is no Docker port publishing for this service.

#### Claim Token
- On first deployment, `PLEX_CLAIM` must be set in `.env`
- Get a fresh token from: https://plex.tv/claim
- **Token expires after 4 minutes** — have your `.env` ready before fetching it
- After claiming, the token is no longer needed but can remain in `.env`

#### ⚠️ Volume Mount Change Pending
Current compose uses `${DATA_PATH}:/data` — library paths inside Plex must be updated to match:
- TV: `/data/media/tv`
- Movies: `/data/media/movies`
- Music: `/data/media/music`

**Do not redeploy Plex without updating library paths first** — this is a live, family-facing service.

### Jellyfin (Media Server)
**Access:** `http://production-ip:8096`

#### First Run
- Navigate to the UI on first access to complete the setup wizard
- Create your admin account
- Add media libraries pointing to:
  - TV Shows: `/data/media/tv`
  - Movies: `/data/media/movies`
  - Music: `/data/media/music`
- Library scan will begin automatically — may take several minutes depending on library size

#### Seerr Integration
Seerr connects to Jellyfin (not Plex) once the family cutover is complete. Update Seerr settings at that time:
- Navigate to: Settings → Media Server
- Switch from Plex to Jellyfin
- Jellyfin URL: `http://production-ip:8096`
- API Key: Copy from Jellyfin → Dashboard → API Keys

---

## Verification Checklist

### Homepage
- [ ] UI accessible at `http://production-ip:3001`
- [ ] All service links loading correctly
- [ ] Docker integration showing container statuses

### Navidrome
- [ ] UI accessible at `http://production-ip:4533`
- [ ] Music library scan completed
- [ ] Albums and artists visible

### NZBGet
- [ ] UI accessible at `http://production-ip:6789`
- [ ] Default password changed
- [ ] News server(s) configured and tested
- [ ] Categories `tv` and `movies` exist
- [ ] Downloads completing to `/data/downloads/usenet/completed/`

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
- [ ] Remote path mapping configured correctly
- [ ] Indexers synced from Prowlarr
- [ ] **End-to-end test:** Search for a movie → Download → Verify import to `/data/media/movies/`

### Sonarr
- [ ] UI accessible at `http://production-ip:8989`
- [ ] Authentication enabled (credentials stored securely)
- [ ] Root folder `/data/media/tv` configured
- [ ] NZBGet download client added and tested
- [ ] Remote path mapping configured correctly
- [ ] Indexers synced from Prowlarr
- [ ] **End-to-end test:** Search for a TV episode → Download → Verify import to `/data/media/tv/`

### Seerr
- [ ] UI accessible at `http://production-ip:5055`
- [ ] Plex or Jellyfin connected and tested (see Jellyfin section for cutover notes)
- [ ] Sonarr connected and tested
- [ ] Radarr connected and tested

### Plex
- [ ] UI accessible at `http://production-ip:32400/web`
- [ ] Claim token set in `.env` before first deployment
- [ ] ⚠️ Library paths updated to `/data/media/tv`, `/data/media/movies`, `/data/media/music` before redeploying
- [ ] Existing library metadata verified after redeploy

### Jellyfin
- [ ] UI accessible at `http://production-ip:8096`
- [ ] Admin account created
- [ ] Media libraries configured with correct paths
- [ ] Library scan completed — TV, movies, music visible
- [ ] Playback verified on at least one device

---

## Network Architecture

All media services run on `media_network_prod` (172.31.0.0/16), with the exception of Plex which uses host networking.

| Service | Network |
|---------|---------|
| homepage | media_network_prod |
| navidrome | media_network_prod |
| prowlarr | media_network_prod |
| radarr | media_network_prod |
| sonarr | media_network_prod |
| nzbget | media_network_prod |
| seerr | media_network_prod |
| jellyfin | media_network_prod |
| plex | host (network_mode: host) |

---

## Rollback

If a service fails to start, the old config is still available at `/opt/docker/<service>` until confirmed stable and removed.

```bash
docker compose down
cd /opt/docker/<service>
docker compose up -d
```