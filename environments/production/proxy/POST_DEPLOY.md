# StreamForge Proxy — Production Post-Deploy Checks

## Purpose

This document describes the validation and operational checks to perform after deploying or changing the StreamForge production reverse proxy.

The production proxy uses Caddy to provide LAN only HTTP access to suitable StreamForge services through the `.streamforge.internal` namespace.

This document focuses on operational validation. The deployed architecture is documented in `docs/current-state.md`.

---

## Architecture

The standard request path is:

```
LAN client
  ↓
UniFi DHCP
  ↓
UniFi DNS
  ├─ StreamForge internal record → 192.168.10.10
  └─ Public DNS request → NextDNS
  ↓
Caddy — 192.168.10.10:80
  ↓
streamforge_proxy_prod
  ↓
Application container
```

Caddy is currently:

- LAN only
- HTTP only
- Bound to the production server on port 80
- Not publicly exposed
- Not configured for HTTPS/TLS
- Connected to selected applications through `streamforge_proxy_prod`

Existing direct IP and port access is deliberately retained as a rollback and troubleshooting path.

---

## Current Proxy Routes

| Service | Internal Hostname | Caddy Backend |
|---|---|---|
| Homepage | `homepage.streamforge.internal` | `homepage:3000` |
| Seerr | `seerr.streamforge.internal` | `seerr:5055` |
| Navidrome | `navidrome.streamforge.internal` | `navidrome:4533` |
| Sonarr | `sonarr.streamforge.internal` | `sonarr:8989` |
| Radarr | `radarr.streamforge.internal` | `radarr:7878` |
| Prowlarr | `prowlarr.streamforge.internal` | `prowlarr:9696` |
| NZBGet | `nzbget.streamforge.internal` | `nzbget:6789` |
| Jellyfin | `jellyfin.streamforge.internal` | `jellyfin:8096` |
| MeTube | `metube.streamforge.internal` | `metube:8081` |
| Firefly III | `firefly.streamforge.internal` | `firefly:8080` |
| Dockhand | `dockhand.streamforge.internal` | `dockhand:3000` |

### Intentional Exclusions

Plex remains on Docker host networking and is intentionally accessed directly. It is not connected to `streamforge_proxy_prod`.

MariaDB is not an HTTP application and remains isolated from the proxy network.

---

## 1. Validate the Caddy Configuration

Before deploying a changed Caddyfile, validate it without modifying the running proxy:

```bash
docker run --rm \
  -v "$PWD/Caddyfile:/etc/caddy/Caddyfile:ro" \
  caddy:2 \
  caddy validate --config /etc/caddy/Caddyfile
```

Expected result:

```
Valid configuration
```

Warnings about Caddyfile formatting or automatic HTTPS being disabled may appear with the current HTTP-only configuration and are non-blocking.

**Do not deploy a Caddyfile that fails validation.**

---

## 2. Deploy Caddy Configuration Changes

The production Caddyfile is bind mounted into the Caddy container:

```
./Caddyfile:/etc/caddy/Caddyfile:ro
```

A Git pull may replace the host side Caddyfile with a new filesystem object while the running container remains attached to the previous bind mounted file.

For this reason, after pulling a Caddyfile change, recreate only Caddy:

```bash
docker compose up -d \
  --no-deps \
  --force-recreate \
  caddy
```

This deliberately avoids restarting unrelated application containers.

---

## 3. Confirm the Active Caddy Configuration

After Caddy has been recreated, confirm the container sees the expected configuration:

```bash
docker exec caddy cat /etc/caddy/Caddyfile
```

Compare the output with the Git managed production Caddyfile.

A successful reload or running container alone does not prove that Caddy is using the latest host side bind mounted file.

---

## 4. Confirm Proxy Health

From the production proxy directory:

```bash
docker compose ps
docker logs caddy --tail 50
```

Caddy should be running without a crash loop or critical configuration errors.

Confirm that the host is listening on port 80:

```bash
sudo ss -tulpn | grep ':80'
```

The expected listener should correspond to the production server's port 80 binding.

---

## 5. Confirm Proxy Network Membership

Inspect the shared proxy network:

```bash
docker network inspect streamforge_proxy_prod \
  --format '{{range .Containers}}{{.Name}}{{"\n"}}{{end}}' |
sort
```

Expected members:

```
caddy
dockhand
firefly
homepage
jellyfin
metube
navidrome
nzbget
prowlarr
radarr
seerr
sonarr
```

The following services should **not** appear:

```
mariadb
plex
```

Unexpected containers on this network should be investigated rather than accepted automatically.

---

## 6. Validate Internal DNS

StreamForge private DNS records are owned by UniFi.

A client using UniFi provided DNS should resolve internal service names to:

```
192.168.10.10
```

Example:

```bash
nslookup homepage.streamforge.internal
```

Repeat with another internal hostname if required.

If an internal hostname returns `NXDOMAIN`, confirm which DNS server the client is actually using before troubleshooting Caddy.

---

## 7. Device Level DNS Overrides

Device level DNS profiles, VPN clients, Private DNS settings or DNS filtering applications can override the DNS server supplied through UniFi DHCP.

This was observed with a NextDNS device profile.

The failing path was:

```
Client
  ↓
Device-level NextDNS profile
  ↓
Public NextDNS resolver
  ↓
NXDOMAIN
```

Public NextDNS resolvers do not contain StreamForge private DNS records.

The intended path is:

```
Client
  ↓
UniFi DNS
  ├─ Internal StreamForge record → 192.168.10.10
  └─ Public DNS request → NextDNS
```

When one device cannot resolve `.streamforge.internal` while other LAN devices can, inspect that device's DNS configuration before changing StreamForge infrastructure.

---

## 8. Validate Service Access

Test representative services through Caddy:

```bash
curl -I http://homepage.streamforge.internal
curl -I http://jellyfin.streamforge.internal
curl -I http://firefly.streamforge.internal
```

Redirect responses may be normal depending on the application.

For significant proxy changes, browser testing should also be performed.

For media applications such as Jellyfin, successful page loading alone is not sufficient. Confirm actual playback where the change could affect media traffic.

---

## 9. Confirm Direct Access

Direct service access remains intentionally available.

Representative checks:

```bash
curl -I http://192.168.10.10:3001
curl -I http://192.168.10.10:8096
curl -I http://192.168.10.10:8090
```

A proxy deployment should not unintentionally remove existing direct access.

---

## 10. Rollback

If an internal proxy route fails:

1. Use the application's direct IP and port path.
2. Confirm the application itself is healthy.
3. Remove or disable the corresponding UniFi DNS record if required.
4. Revert the relevant Compose or Caddy change through Git.
5. Push the revert to GitHub.
6. Pull the reverted configuration on production.
7. Recreate only the affected application container if its network configuration changed.
8. Recreate Caddy if the Caddyfile changed.
9. Validate direct and proxied access again.

**Do not stop or recreate an entire application stack when only one service requires rollback.**

---

## Security Boundaries

The reverse proxy does not make StreamForge publicly accessible.

The current design intentionally has:

- No public StreamForge DNS records
- No internet facing Caddy exposure
- No router port forwarding for Caddy
- No published HTTPS port
- No automatic TLS deployment
- No requirement for application databases to join the proxy network

`streamforge_proxy_prod` provides an additional Docker network path between Caddy and selected application containers. Membership should therefore remain deliberate and limited to services that require proxy connectivity.

---

## Deferred Work

The following are intentionally outside the current proxy deployment:

- Plex reverse proxying
- Internal HTTPS/TLS
- Remote access through Tailscale
- Public service exposure
