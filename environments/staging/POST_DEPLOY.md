# StreamForge Post-Deployment Configuration

After running `docker-compose up -d`, complete these steps 

## Radarr 

### 1. Authentication (Optional but Recommended)
- Settings → General → Security
- Authentication: Forms (Login Page)
- Username: [your choice]
- Password: [your choice]
- **Important:** Keep "Disable authentication for local addresses" UNCHECKED
  - Provides extra depth of security even on trusted networks

### 2. Media Management
- Settings → Media Management
- Root Folders → Add Root Folder
- Path: `/data/media/movies`
- Click "Add"

### 3. Download Clients
*To be configured when NZBGet is deployed*

### 4. Indexers
*To be configured when Prowlarr is deployed*

## Sonarr 

### 1. Authentication (Optional but Recommended)
- Settings → General → Security
- Authentication: Forms (Login Page)
- Username: [your choice]
- Password: [your choice]
- **Important:** Keep "Disable authentication for local addresses" UNCHECKED
  - Provides extra depth of security even on trusted networks

### 2. Media Management
- Settings → Media Management
- Root Folders → Add Root Folder
- Path: `/data/media/tv`
- Click "Add"

### 3. Download Clients
*To be configured when NZBGet is deployed*

### 4. Indexers
*To be configured when Prowlarr is deployed*

## Verification
- [ ] Can access Radarr UI at http://staging-ip:7878
- [ ] Can access Sonarr UI at http://staging-ip:8989
- [ ] Authentication enabled and credentials stored securely
- [ ] Root folder added for Radarr `/data/media/movies` is configured and writable
- [ ] Root folder added for Sonarr `/data/media/tv` is configured and writable
- [ ] Ready for download client integration (pending NZBGet deployment)