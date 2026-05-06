# Sonarr Post-Deployment Configuration

After running `docker-compose up -d`, complete these steps through the Sonarr UI.

## Initial Setup

### 1. Authentication (Optional but Recommended)
- Settings → General → Security
- Authentication: Forms (Login Page)
- Username: [your choice]
- Password: [your choice]

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
- [ ] Can access UI at http://staging-ip:8989
- [ ] Root folder `/data/media/tv` is configured
- [ ] Authentication is set up (if enabled)