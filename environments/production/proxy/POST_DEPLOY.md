# Proxy Production Post-Deploy Checks

## Confirm the proxy stack

```bash
docker compose ps
docker logs caddy --tail 50
```

## Confirm Caddy is listening

```bash
sudo ss -tulpn | grep ':80'
```

## Test Homepage through the proxy

From a client with the temporary hosts entry configured:

```bash
curl -I http://homepage.streamforge.internal
```

## Confirm direct Homepage access remains available

```bash
curl -I http://192.168.10.10:3001
```

## Rollback

```bash
docker compose down
```

The original direct Homepage path should remain available.

