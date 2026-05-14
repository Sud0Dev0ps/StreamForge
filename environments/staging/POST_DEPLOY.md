# StreamForge Post-Deployment Configuration
After running `docker compose up -d` 
follow the configuration steps below, then use the verification checklist to confirm everything is working.

---

## Configuration Steps

### Sonarr (TV Shows)
**Access:** `http://staging-ip:8989`

#### Authentication (Recommended)
- Navigate to: Settings → General → Security
- Set Authentication to: **Forms (Login Page)**
- Create username and password
- **Important:** Keep "Disable authentication for local addresses" **UNCHECKED**

#### Media Management
- Navigate to: Settings → Media Management → Root Folders
- Add Root Folder: `/data/media/tv`

#### Download Clients

##### NZBGet
- Navigate to: Settings → Download Clients → Add → NZBGet
- Host: `nzbget` (Docker service name)
- Port: `6789`
- Username: `nzbget` (default)
- Password: `password`
- Category: `tv

##### qBittorrent
- Settings → Download Clients → Add (+) → qBittorrent
    Name: qBittorrent
    Host: gluetun
    Port: 8080
    Username: `admin` (default)
    Password: `password`
    Category: tv

#### Remote Path Mapping NZBget (Required)
- In the NZBGet download client settings, add Remote Path Mapping:
  - Host: `nzbget`
  - Remote Path: `/downloads/completed/` (NZBGet container view)
  - Local Path: `/data/downloads/usenet/completed/` (Sonarr container view)
- This translates paths between containers with different volume mounts

#### Remote Path Mapping qBittorrent (Required)
- In the qBittorrent download client settings, add Remote Path Mapping:
  - Host: `gluetun`
  - Remote Path: `/downloads/completed/` (qBittorrent container view)
  - Local Path: `/data/downloads/torrents/completed/` (Sonarr container view)

---

### Radarr (Movies)
**Access:** `http://staging-ip:7878`

#### Authentication (Recommended)
- Navigate to: Settings → General → Security
- Set Authentication to: **Forms (Login Page)**
- Create username and password
- **Important:** Keep "Disable authentication for local addresses" **UNCHECKED**

#### Media Management
- Navigate to: Settings → Media Management → Root Folders
- Add Root Folder: `/data/media/movies`

#### Download Clients
##### NZBGet
- Navigate to: Settings → Download Clients → Add → NZBGet
- Host: `nzbget`
- Port: `6789`
- Username: `nzbget` (default)
- Password: `password`
- Category: `movies`

##### qBittorrent
- Settings → Download Clients → Add (+) → qBittorrent
    Name: qBittorrent
    Host: gluetun
    Port: 8080
    Username: `admin` (default)
    Password: `password`
    Category: movies

#### Remote Path Mapping NZBget (Required)
- In the NZBGet download client settings, add Remote Path Mapping:
  - Host: `nzbget`
  - Remote Path: `/downloads/completed/` (NZBGet container view)
  - Local Path: `/data/downloads/usenet/completed/` (Radarr container view)
- This translates paths between containers with different volume mounts

#### Remote Path Mapping qBittorrent (Required)
- In the qBittorrent download client settings, add Remote Path Mapping:
  - Host: `gluetun`
  - Remote Path: `/downloads/completed/` (qBittorrent container view)
  - Local Path: `/data/downloads/torrents/completed/` (Radarr container view)

---

### NZBGet (Download Client)
**Access:** `http://staging-ip:6789`

**Architecture Note:**  
NZBGet uses least privilege volume mounting — it only has access to `/data/downloads/usenet/` (not the full `/data/` directory). 
This follows security best practices while Sonarr/Radarr retain full `/data/` access for file movement operations.

#### Security
- Navigate to: Settings → SECURITY
- Change default password from `tegbzn6789`

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

### Gluetun (VPN)

#### Check logs
- Check Wireguard is up and connected
`docker logs gluetun`
- Confirm VPN IP and not network public IP
`docker exec gluetun wget -qO- https://api.ipify.org`

#### Verify Kill Switch (Optional but Recommended)
Test that qBittorrent loses network access if VPN disconnects:
```bash
# Stop VPN
docker stop gluetun

# Verify qBittorrent has no network
docker exec qbittorrent wget -qO- --timeout=5 https://api.ipify.org
# Should fail with "bad address" or timeout

# Restart VPN
docker start gluetun
docker restart qbittorrent  # Required to reattach to VPN namespace
```

---

### qBittorrent
**Access:** `http://staging-ip:8080`

#### Check public IP
- Confirm VPN IP and not public IP
`docker exec qbittorrent wget -qO- --timeout=5 https://api.ipify.org`


#### Change default password
- Find default password and change
`docker logs qbittorrent 2>&1 | grep -i password`

#### Download paths
- Settings (Tools → Options → Downloads):
  - Default Save Path: /downloads/completed/ (where finished torrents go)
  - Keep incomplete torrents in: /downloads/incomplete/ (actively downloading)

#### Categories
- Right-click in the categories panel 
  - Add these categories:
    - Add category: tv with save path /downloads/completed/tv/
    - Add category: movies with save path /downloads/completed/movies/

#### Folders
- Create the following folders:
  - mkdir -p path/to/data/torrents/completed/{tv,movies}
  - mkdir -p path/to/data/downloads/torrents/incomplete

---

### Prowlarr (Indexer Manager)
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
- [ ] qBittorrent download client added and tested
- [ ] Remote path for NZBget mapping configured correctly
- [ ] Remote path mapping qBittorrent configured correctly
- [ ] Indexers synced from Prowlarr (visible in Settings → Indexers)
- [ ] **End-to-end test:** Search for a TV episode → Download → Verify import to `/data/media/tv/`



### Radarr
- [ ] UI accessible at `http://staging-ip:7878`
- [ ] Authentication enabled (credentials stored securely)
- [ ] Root folder `/data/media/movies` configured
- [ ] NZBGet download client added and tested
- [ ] qBittorrent download client added and tested
- [ ] Remote path for NZBget mapping configured correctly
- [ ] Remote path mapping qBittorrent configured correctly
- [ ] Indexers synced from Prowlarr (visible in Settings → Indexers)
- [ ] **End-to-end test:** Search for a movie → Download → Verify import to `/data/media/movies/`

### NZBGet
- [ ] UI accessible at `http://staging-ip:6789`
- [ ] Default password changed
- [ ] News server(s) configured and tested
- [ ] Categories `tv` and `movies` exist
- [ ] Downloads completing to `path/to/downloads/usenet/completed/`

### Prowlarr
- [ ] UI accessible at `http://staging-ip:9696`
- [ ] Authentication enabled (credentials stored securely)
- [ ] Sonarr connected (API key verified)
- [ ] Radarr connected (API key verified)
- [ ] Indexers added and configured
- [ ] Indexers successfully synced to both Sonarr and Radarr

### Gluetun
- [ ] Check Wireguard is up and connected
- [ ] Confirm VPN IP and not network public IP

### qBittorrent
- [ ] UI accessible at `http://staging-ip:8080`
- [ ] Confirm VPN IP and not public IP
- [ ] Change default passwod (credentials stored securely)
- [ ] Categories `tv` and `movies` created
- [ ] Folders created: 
  - [ ] path/to/data/torrents/completed/{tv,movies}
  - [ ] path/to/data/downloads/torrents/incomplete
- [ ] Downloads completing to `path/to/downloads/torrents/completed/`
- [ ] Incomplete downloads to `path/to/downloads/torrents/incomplete/`

---

## Network Architecture
All services run on the `media_network` Docker bridge network (`172.21.0.0/16`) and communicate using Docker service names:
- `sonarr` → `172.21.0.3`
- `radarr` → `172.21.0.2`
- `nzbget` → `172.21.0.4`
- `prowlarr` → `172.21.0.5`
- `gluetun` → `172.21.0.6`

**Note:** qBittorrent shares gluetun's network namespace via `network_mode: service:gluetun` and does not have its own IP on media_network. 
To reach qBittorrent services connect to `http://gluetun:8080`.

Services can reach each other using hostnames (e.g., `http://nzbget:6789`) rather than IP addresses, which provides stability if container IPs change.