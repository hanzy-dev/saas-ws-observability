# Runbook

This runbook covers common incidents for the local Workspace observability stack.

## Scope
Services:
- Prometheus
- Grafana
- Tempo
- OpenTelemetry Collector
- saas-ws-hello (demo service)

## Quick links
- Prometheus Targets: http://localhost:9090/targets
- Prometheus Alerts: http://localhost:9090/alerts
- Grafana: http://localhost:3000 (admin/admin)
- Tempo (backend): http://localhost:3200

## Standard checks

### Check containers

```bash
docker compose ps
docker compose logs --tail=100 prometheus
docker compose logs --tail=100 otel-collector
docker compose logs --tail=100 tempo
Check scrape health
```

Prometheus query:

- up
- up{job="saas-ws-hello"}
- up{job="otel-collector"}
- up{job="tempo"}

## Incident 1: Target down (job shows DOWN in /targets)

### Symptoms

- PrometheusTargetDown alert fires
- /targets shows DOWN for one of:
  - saas-ws-hello
  - otel-collector
  - tempo

### Triage

1. Confirm which target is down:

   - `http://localhost:9090/targets`

2. Check container status:

```
docker compose ps
```

3. Check logs for the failing component:

```
docker compose logs --tail=200 <service>
```

### Likely causes

- Container crashed / restarting
- Misconfigured scrape target (wrong host/port/path)
- Network or DNS resolution issue inside docker network

### Mitigation

- Restart the affected service:

```
docker compose restart <service>
```

- If still failing, recreate it:

```
docker compose up -d --force-recreate <service>
```

### Validation

- /targets shows UP again
- PromQL: up{job="<job_name>"} returns 1

## Incident 2: Latency spike (p95/p99 increased)

### Symptoms

- Grafana dashboard saas-ws-hello - HTTP RED shows p95/p99 rising
- Users report “slow responses” (simulated)

### Triage

1. Identify whether all routes are affected or only one route:

   - Dashboard filter route

2. Confirm p95 in Prometheus:

```
histogram_quantile(
  0.95,
  sum by (le) (rate(ws_hello_http_request_duration_seconds_bucket[5m]))
)
```

3. Check request volume (is this load-related?):

```
sum(rate(ws_hello_http_requests_total[5m]))
```

### Likely causes

- CPU/memory pressure in container
- Downstream dependency slow (e.g., DB ping/queries) — for future services
- Lock contention or retry storms — for future workers/services

### Mitigation

- Restart hello service (quick recovery):

```
docker compose restart hello-api
```

- If related to load test, reduce load and validate recovery.

### Validation

- p95/p99 returns to normal baseline
- RPS stabilizes
- Traces in Tempo show shorter spans for GET /ping / POST /echo

## Incident 3: Traces missing in Tempo (metrics OK, traces empty)

### Symptoms

- Prometheus + dashboards OK
- Tempo search shows no traces for saas-ws-hello

### Triage

1. Confirm hello is configured to export OTLP to collector:

   - In docker-compose.yml, hello-api env:
      - OTEL_EXPORTER_OTLP_ENDPOINT=otel-collector:4318

2. Check collector logs:

```
docker compose logs --tail=200 otel-collector
```

Check tempo health:

```
curl -sS http://localhost:3200/ready
```

### Mitigation

- Restart collector then tempo:

```
docker compose restart otel-collector
docker compose restart tempo
```

- Restart hello-api:

```
docker compose restart hello-api
```

### Validation

- Generate traffic (see docs/evidence.md) and confirm traces appear in Grafana Explore (Tempo).