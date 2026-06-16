# StreamForge Media Stack — Post Deployment Configuration

After running `docker compose up -d` from `environments/production/media/` 
Follow the configuration steps below, then use the verification checklist to confirm everything is working.

---

## Prerequisites

- `media_network_prod` network created via `setup-network.sh`
- `.env` file in place at `environments/production/media/.env`
- All configuration directories present under `/opt/appdata`
- NAS mounted and accessible at `/mnt/data`
- Homepage example configuration files available in the repository

---

## Configuration Steps

### Radarr (Movies)

**Access:** `http://production-ip:7878`

#### Authentication

- Navigate to: Settings → General → Security
- Set Authentication to: **Forms (Login Page)**
- Create username and password
- Leave **Disable authentication for local addresses** unchecked

#### Media Management

- Navigate to: Settings → Media Management → Root Folders
- Add root folder: `/data/media/movies`

#### Download Client

- Add NZBGet as the download client
- NZBGet host: `production-ip`
- NZBGet port: `6789`
- Test connection and save

---

### Sonarr (TV)

**Access:** `http://production-ip:8989`

#### Authentication

- Navigate to: Settings → General → Security
- Set Authentication to: **Forms (Login Page)**
- Create username and password

#### Media Management

- Add root folder: `/data/media/tv`

#### Download Client

- Add NZBGet as the download client
- Test connection and save

---

### Prowlarr (Indexer Manager)

**Access:** `http://production-ip:9696`

#### Authentication

- Navigate to: Settings → General → Security
- Set Authentication to: **Forms (Login Page)**
- Create username and password

#### Connect Applications

**For Sonarr:**
- Sonarr URL: `http://production-ip:8989`
- API Key: Sonarr → Settings → General → Security → API Key
- Test connection and save

**For Radarr:**
- Radarr URL: `http://production-ip:7878`
- API Key: Radarr → Settings → General → Security → API Key
- Test connection and save

#### Add Indexers

- Navigate to: Indexers → Add Indexer
- Add your Usenet indexers
- Configure API keys and credentials
- Confirm indexers sync to Sonarr and Radarr

---

### NZBGet

**Access:** `http://production-ip:6789`

#### Initial Configuration

- Change the default password
- Configure news servers
- Configure categories for `tv` and `movies`

#### Active Download Structure

NZBGet uses:

```
/data/downloads
├── completed
├── intermediate
├── nzb
├── queue
└── tmp
```

**Host path:** `/mnt/data/downloads`

**Container path:** `/data/downloads`

---

## Runtime Services

### Homepage

**Access:** `http://production-ip:3001`

#### Configuration Files

Runtime configuration location: `/opt/appdata/homepage/config`

Example files are stored in Git:

```
environments/production/media/homepage/
├── bookmarks.yaml.example
├── docker.yaml.example
├── services.yaml.example
├── settings.yaml.example
└── widgets.yaml.example
```

**Required live files:**

- bookmarks.yaml
- docker.yaml
- services.yaml
- settings.yaml
- widgets.yaml

**For a new deployment:**

```bash
mkdir -p /opt/appdata/homepage/config
```

Copy the example files, remove the `.example` extension, and customise values for the environment.

#### HOMEPAGE_ALLOWED_HOSTS

Ensure `.env` contains:

```
HOMEPAGE_ALLOWED_HOSTS=<server-ip>:3001
```

**Example:**

```
HOMEPAGE_ALLOWED_HOSTS=192.168.x.x:3001
```

Homepage will reject requests if the host header does not match.

---

### Navidrome

**Access:** `http://production-ip:4533`

#### First Run

- Create the admin account
- Confirm music library path is available
- Allow the initial scan to complete

**Current music path:** `/data/media/mixes`

---

### Plex

**Access:** `http://production-ip:32400/web`

#### Network Mode

Plex uses host networking:

```yaml
network_mode: host
```

This is required for local network discovery.

#### Claim Token

Before first deployment:

```
PLEX_CLAIM=<token>
```

Get a fresh token from: https://plex.tv/claim

The token expires after approximately 4 minutes.

#### Library Paths

Verify Plex libraries point to:

- `/data/media/tv`
- `/data/media/movies`
- `/data/media/music`

---

### Jellyfin

**Access:** `http://production-ip:8096`

#### First Run

- Complete setup wizard
- Create admin account
- Configure libraries:
  - TV Shows → `/data/media/tv`
  - Movies → `/data/media/movies`
  - Music → `/data/media/music`
- Allow library scan to complete

#### Seerr Integration

When Jellyfin becomes the primary media server:

- Navigate to: Seerr → Settings → Media Server
- Jellyfin URL: `http://production-ip:8096`
- Use a Jellyfin API key

---

### Seerr

**Access:** `http://production-ip:5055`

Configure and test:

- Jellyfin or Plex
- Sonarr
- Radarr

---

### MeTube

**Access:** `http://production-ip:8081`

**Download path:** `/downloads`

**Host path:** `/mnt/data/downloads/metube`

---

## Verification Checklist

### Homepage

- [ ] UI accessible at `http://production-ip:3001`
- [ ] Service links working
- [ ] Docker integration showing container status

### NZBGet

- [ ] UI accessible at `http://production-ip:6789`
- [ ] Default password changed
- [ ] News servers configured
- [ ] Categories `tv` and `movies` configured
- [ ] Downloads completing successfully

### Prowlarr

- [ ] UI accessible at `http://production-ip:9696`
- [ ] Authentication enabled
- [ ] Sonarr connected
- [ ] Radarr connected
- [ ] Indexers configured
- [ ] Indexers syncing correctly

### Sonarr

- [ ] UI accessible at `http://production-ip:8989`
- [ ] Authentication enabled
- [ ] Root folder configured: `/data/media/tv`
- [ ] Download path `/data/downloads` accessible
- [ ] Indexers synced from Prowlarr
- [ ] Test download imported successfully

### Radarr

- [ ] UI accessible at `http://production-ip:7878`
- [ ] Authentication enabled
- [ ] Root folder configured: `/data/media/movies`
- [ ] Download path `/data/downloads` accessible
- [ ] Indexers synced from Prowlarr
- [ ] Test download imported successfully

### Seerr

- [ ] UI accessible at `http://production-ip:5055`
- [ ] Media server connected
- [ ] Sonarr connected
- [ ] Radarr connected

### Navidrome

- [ ] UI accessible at `http://production-ip:4533`
- [ ] Music library scanned
- [ ] Artists and albums visible

### Plex

- [ ] UI accessible at `http://production-ip:32400/web`
- [ ] Library paths verified
- [ ] Metadata intact
- [ ] Playback verified

### Jellyfin

- [ ] UI accessible at `http://production-ip:8096`
- [ ] Admin account created
- [ ] Libraries configured
- [ ] Scan completed
- [ ] Playback verified

### MeTube

- [ ] UI accessible at `http://production-ip:8081`
- [ ] Download path working
- [ ] Test download completed successfully

---

## Network Architecture

All media services use `media_network_prod`.

**Subnet:** `172.31.0.0/16`

**Exception:** Plex → host networking

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
| metube | media_network_prod |
| plex | host |

---

## Recovery Notes

### Configuration Location

All active service configuration resides under: `/opt/appdata`

**Examples:**

```
/opt/appdata/homepage
/opt/appdata/jellyfin
/opt/appdata/navidrome
/opt/appdata/nzbget
/opt/appdata/prowlarr
/opt/appdata/radarr
/opt/appdata/sonarr
/opt/appdata/seerr
/opt/appdata/plex
```

### Source of Truth

Git is the source of truth for:

- Docker Compose files
- Environment templates
- Deployment documentation
- Homepage example configuration

**Production secrets remain in:** `environments/production/media/.env`

These are not committed to Git.

### Legacy Deployment Archive

Legacy `/opt/docker` service directories have been archived and are no longer used by running containers.

Current runtime configuration should be validated with:

```bash
docker inspect <container-name>
```

### Post-Restore Validation

After any rebuild or restore:

```bash
docker compose config
docker compose up -d
docker compose ps
```

Then complete the verification checklist above.