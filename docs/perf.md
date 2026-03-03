# Performance & Capacity Notes

This document records a repeatable baseline for the local observability stack and provides guidance for capacity planning.

## Scope
Components:
- Prometheus
- Grafana
- Tempo
- Loki + Promtail
- OTel Collector
- Alertmanager
- saas-ws-hello (demo target)

## Baseline environment
Record your machine/environment here (update as needed):
- OS:
- CPU:
- RAM:
- Docker Desktop version:
- Date:

## Retention & storage settings
- Prometheus retention: `7d` (`--storage.tsdb.retention.time=7d`)
- Prometheus storage: `prometheus-data:/prometheus`
- Loki retention: `168h` (7d) in `loki.yaml`
- Tempo storage: local (demo)

## Quick health checks
- Prometheus healthy: http://localhost:9090/-/healthy
- Grafana health: http://localhost:3000/api/health
- Tempo ready: http://localhost:3200/ready
- Loki ready: http://localhost:3100/ready
- Alertmanager ready: http://localhost:9093/-/ready

## Load generation (demo)
Generate traffic for metrics/traces/logs:
```bash
make demo-traffic
```

For a burst:

```
for i in $(seq 1 200); do make demo-traffic; done
```

## What to observe

### Prometheus

Targets are UP: http://localhost:9090/targets

Query ingestion basics:

- up
- sum(rate(ws_hello_http_requests_total[5m]))

### Grafana dashboards

- Workspace Observability - Infra
- saas-ws-hello - HTTP RED

### Tempo (traces)

Grafana → Explore → Tempo:

- Service: `saas-ws-hello`

### Loki (logs)

Grafana → Explore → Loki:

- `{compose_service="hello-api"} |= "http_request"`

### Resource usage snapshot

Capture a quick snapshot with:

```
docker stats --no-stream
```

Record notes here:

Prometheus CPU/RAM:
Grafana CPU/RAM:
Tempo CPU/RAM:
Loki CPU/RAM:
OTel Collector CPU/RAM:
Promtail CPU/RAM:

## Capacity guidance (production direction)

This repo is a local baseline. For production:

- Prometheus:

  - size storage for retention window + scrape interval
  - consider remote_write for long-term storage

- Tempo:

  - use object storage backend (S3/GCS/Azure)
  - plan compaction and retention policies

- Loki:

  - define retention per stream/tenant
  - use object storage + index/chunk tuning

- Reliability:

  - define SLOs (error rate, p95 latency)
  - run in Kubernetes with resource requests/limits
  - consider HA for Prometheus/Grafana/Loki/Tempo where needed