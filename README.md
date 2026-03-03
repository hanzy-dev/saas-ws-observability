# saas-ws-observability

Production-grade local observability stack for the Workspace microservices ecosystem.

Includes:
- Prometheus (metrics + alert rules)
- Alertmanager (alert routing)
- Grafana (dashboards + explore)
- OpenTelemetry Collector (OTLP receiver)
- Tempo (distributed tracing backend)
- Loki + Promtail (logs)

## Quickstart (infra only)

```bash
make up
```

URLs:

- Grafana: http://localhost:3000
 (admin/admin)
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093
- Tempo: http://localhost:3200
- Loki: http://localhost:3100

## Demo mode (includes saas-ws-hello)

saas-ws-hello is gated behind a compose profile to keep CI infra-only.

Start full demo:

```
docker compose --profile demo up -d
```

Generate demo traffic:

```
make demo-traffic
```

## One-command demo (repeatable)

Run the full stack (with demo service) and generate traffic:

```bash
docker compose --profile demo up -d
make demo-traffic
```

## What you should see

### 1) Prometheus targets

Open: `http://localhost:9090/targets`

Expected (UP):

- prometheus
- otel-collector
- tempo
- loki

saas-ws-hello (when demo profile is enabled)

### 2) Grafana dashboards

Open Grafana → Dashboards → folder Workspace:

- `Workspace Observability - Infra`
- `saas-ws-hello - HTTP RED`

### 3) Traces (Tempo)

Grafana → Explore → datasource Tempo:

- Service Name: `saas-ws-hello`
- Span Name: `GET /ping` or `POST /echo`

### 4) Logs (Loki)

Grafana → Explore → datasource Loki:

`logql
{compose_service="hello-api"} |= "http_request"
`

## Docs (Proof Pack)

- Evidence checklist + screenshots: `docs/evidence.md`
- Incident response runbook: `docs/runbook.md`
- Security + hardening notes: `docs/security.md`
- Performance baseline + capacity notes: `docs/perf.md`
- Kubernetes quickstart: `docs/k8s.md`

## CI

GitHub Actions validates:

- YAML lint
- docker compose config
- Infra smoke checks (health/ready)

## Notes

- OTLP receivers are not exposed to host by default (avoids port conflicts). Services should export traces within the Docker network to `otel-collector:4318`.
- For production deployments, use TLS/auth, persistent storage, and define retention/backup policies.