# saas-ws-observability

Local observability stack for the Workspace microservices ecosystem.

Includes:
- Prometheus (metrics + alert rules)
- Grafana (dashboards + explore)
- OpenTelemetry Collector (OTLP receiver)
- Tempo (distributed tracing backend)

## Quickstart

```bash
make up
```

URLs:

- Grafana: http://localhost:3000
 (admin/admin)
- Prometheus: http://localhost:9090
- Tempo: http://localhost:3200

## What you should see

### 1) Prometheus targets

Open: http://localhost:9090/targets

Expected targets (UP):

- prometheus
- otel-collector
- tempo
- saas-ws-hello

### 2) Grafana dashboards

Open Grafana → Dashboards → folder Workspace:

- Workspace Observability - Infra
- saas-ws-hello - HTTP RED

### 3) Traces in Tempo (via Grafana Explore)

Open Grafana → Explore → datasource Tempo, then search:

- Service Name: saas-ws-hello
- Span Name: GET /ping or POST /echo

## Demo traffic

Generate traffic to populate metrics + traces:

```
make demo-traffic
```

## Evidence & Runbook

- Evidence checklist and expected screenshots: docs/evidence.md
- Incident response runbook: docs/runbook.md

## Notes

- saas-ws-hello is included in this compose stack for a repeatable demo.
- OTLP receivers are not exposed to host by default (avoids port conflicts). Services should run in the same Docker network and export to otel-collector:4318.