# StreamForge Post-Deployment Configuration
After running `docker compose up -d` 
follow the configuration steps below, then use the verification checklist to confirm everything is working.

---

## Configuration Steps

### 1. Sonarr (TV Shows)
**Access:** `http://staging-ip:8989`

#### Authentication (Recommended)
- Navigate to: Settings → General → Security
- Set Authentication to: **Forms (Login Page)**
- Create username and password
- **Important:** Keep "Disable authentication for local addresses" **UNCHECKED** for defense-in-depth

#### Media Management
- Navigate to: Settings → Media Management → Root Folders
- Add Root Folder: `/data/media/tv`

#### Download Client
- Navigate to: Settings → Download Clients → Add → NZBGet
- Host: `nzbget` (Docker service name)
- Port: `6789`
- Username: `nzbget` (default)
- Password: `tegbzn6789` (change in NZBGet first)
- Category: `tv`

#### Remote Path Mapping (Required)
- In the NZBGet download client settings, add Remote Path Mapping:
  - Host: `nzbget`
  - Remote Path: `/downloads/completed/` (NZBGet's container view)
  - Local Path: `/data/downloads/usenet/completed/` (Sonarr's container view)
- This translates paths between containers with different volume mounts

---

### 2. Radarr (Movies)
**Access:** `http://staging-ip:7878`

#### Authentication (Recommended)
- Navigate to: Settings → General → Security
- Set Authentication to: **Forms (Login Page)**
- Create username and password
- **Important:** Keep "Disable authentication for local addresses" **UNCHECKED** for defense-in-depth

#### Media Management
- Navigate to: Settings → Media Management → Root Folders
- Add Root Folder: `/data/media/movies`

#### Download Client
- Navigate to: Settings → Download Clients → Add → NZBGet
- Host: `nzbget`
- Port: `6789`
- Username: `nzbget`
- Password: `tegbzn6789` (change in NZBGet first)
- Category: `movies`

#### Remote Path Mapping (Required)
- In the NZBGet download client settings, add Remote Path Mapping:
  - Host: `nzbget`
  - Remote Path: `/downloads/completed/`
  - Local Path: `/data/downloads/usenet/completed/`

---

### 3. NZBGet (Download Client)
**Access:** `http://staging-ip:6789`

**Architecture Note:**  
NZBGet uses least-privilege volume mounting — it only has access to `/data/downloads/usenet/` (not the full `/data/` directory). 
This follows security best practices while Sonarr/Radarr retain full `/data/` access for file movement operations.

#### Security
- Navigate to: Settings → SECURITY
- Change default password from `tegbzn6789` to something secure

#### News Servers
- Navigate to: Settings → NEWS-SERVERS
- Add your Usenet provider details:
  - Host (e.g., `news.provider.com`)
  - Port (typically `563` for SSL)
  - Username and password from your provider
  - Connections (typically 10-30, check provider limits)
  - Enable SSL: Yes

#### Categories
- Navigate to: Settings → CATEGORIES
- Verify these categories exist (create if missing):
  - `tv` (for Sonarr)
  - `movies` (for Radarr)
- DestDir can be left blank to use default `/downloads/completed/`

---

### 4. Prowlarr (Indexer Manager)
**Access:** `http://staging-ip:9696`

#### Authentication (Recommended)
- Navigate to: Settings → General → Security
- Set Authentication to: **Forms (Login Page)**
- Create username and password

#### Connect Applications
- Navigate to: Settings → Apps → Add

**For Sonarr:**
- Prowlarr Server: `http://localhost:9696` (default)
- Sonarr Server: `http://sonarr:8989`
- API Key: Copy from Sonarr → Settings → General → Security → API Key
- Test connection and save

**For Radarr:**
- Prowlarr Server: `http://localhost:9696` (default)
- Radarr Server: `http://radarr:7878`
- API Key: Copy from Radarr → Settings → General → Security → API Key
- Test connection and save

#### Add Indexers
- Navigate to: Indexers → Add Indexer
- Add your Usenet indexers
- Configure with your indexer API keys/credentials
- Prowlarr will automatically sync these to Sonarr and Radarr

---

## Verification Checklist

### Sonarr
- [ ] UI accessible at `http://staging-ip:8989`
- [ ] Authentication enabled (credentials stored securely)
- [ ] Root folder `/data/media/tv` configured
- [ ] NZBGet download client added and tested
- [ ] Remote path mapping configured correctly
- [ ] Indexers synced from Prowlarr (visible in Settings → Indexers)
- [ ] **End-to-end test:** Search for a TV episode → Download → Verify import to `/data/media/tv/`

### Radarr
- [ ] UI accessible at `http://staging-ip:7878`
- [ ] Authentication enabled (credentials stored securely)
- [ ] Root folder `/data/media/movies` configured
- [ ] NZBGet download client added and tested
- [ ] Remote path mapping configured correctly
- [ ] Indexers synced from Prowlarr (visible in Settings → Indexers)
- [ ] **End-to-end test:** Search for a movie → Download → Verify import to `/data/media/movies/`

### NZBGet
- [ ] UI accessible at `http://staging-ip:6789`
- [ ] Default password changed
- [ ] News server(s) configured and tested
- [ ] Categories `tv` and `movies` exist
- [ ] Downloads completing to `/home/grizmo/staging-data/downloads/usenet/completed/`

### Prowlarr
- [ ] UI accessible at `http://staging-ip:9696`
- [ ] Authentication enabled (credentials stored securely)
- [ ] Sonarr connected (API key verified)
- [ ] Radarr connected (API key verified)
- [ ] Indexers added and configured
- [ ] Indexers successfully synced to both Sonarr and Radarr

---

## Network Architecture
All services run on the `media_network` Docker bridge network (`172.21.0.0/16`) and communicate using Docker service names:

- `sonarr` → `172.21.0.3`
- `radarr` → `172.21.0.2`
- `nzbget` → `172.21.0.4`
- `prowlarr` → `172.21.0.5`

Services can reach each other using hostnames (e.g., `http://nzbget:6789`) rather than IP addresses, which provides stability if container IPs change.