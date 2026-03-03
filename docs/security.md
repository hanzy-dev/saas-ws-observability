# Security

This repo provides a local observability stack for development/demo purposes. The configuration is designed to be repeatable and easy to run, while documenting the steps required to harden it for production.

## Exposed ports
The stack exposes these ports to the host:
- Grafana: `3000` (UI)
- Prometheus: `9090` (UI/API)
- Alertmanager: `9093` (UI/API)
- Tempo: `3200` (query/ready)
- Loki: `3100` (query/ready)
- OTel Collector: `8888` (internal metrics)

OTLP receivers are **not** exposed to the host by default to avoid port conflicts and reduce attack surface. Services should export traces within the Docker network to:
- `otel-collector:4318` (OTLP/HTTP)

## Credentials
Grafana uses default credentials in `docker-compose.yml`:
- user: `admin`
- password: `admin`

For any environment beyond local demo:
- change credentials via environment variables
- prefer secrets management (e.g., Docker secrets / Kubernetes Secrets)
- do not commit secrets into git

## Data retention and persistence
Prometheus stores TSDB data on a named Docker volume:
- `prometheus-data:/prometheus`
Retention is configured via:
- `--storage.tsdb.retention.time=7d`

Tempo and Loki use local storage for demo purposes. For production:
- use object storage for Tempo (S3/GCS/Azure)
- define retention and backup policies for logs/traces/metrics

## Transport security (TLS)
This stack runs over plain HTTP for local usage.

For production:
- place a reverse proxy (Nginx/Traefik) in front of Grafana/Prometheus/Alertmanager/Loki/Tempo
- enable TLS (HTTPS)
- restrict access by network policy/firewall/VPN

## Authentication & authorization
For production:
- enable Grafana auth (OAuth/SAML) and enforce RBAC
- restrict Prometheus/Alertmanager endpoints (IP allowlist or auth proxy)
- avoid exposing internal-only endpoints publicly

## Hardening checklist (production)
- [ ] Change default Grafana admin password
- [ ] Restrict host-exposed ports to trusted networks only
- [ ] Add TLS termination (reverse proxy / ingress)
- [ ] Enable authentication/SSO + RBAC in Grafana
- [ ] Configure Alertmanager receivers (Slack/email/pager) using secrets
- [ ] Use persistent storage + backup policy (metrics/logs/traces)
- [ ] Set resource limits/requests (Kubernetes) and plan HA
- [ ] Document upgrade procedure and test it in staging