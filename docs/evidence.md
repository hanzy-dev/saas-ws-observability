# Evidence Pack

This repo provides repeatable proof that **metrics + tracing + alerts + logs** work end-to-end for the Workspace ecosystem.

## URLs
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093
- Tempo (backend): http://localhost:3200
- Loki (backend): http://localhost:3100

## Evidence files (screenshots)
Place screenshots under: `docs/evidence/`

Required:
- `docs/evidence/targets.png`
- `docs/evidence/dashboard-infra.png`
- `docs/evidence/dashboard-hello-http-red.png`
- `docs/evidence/trace-hello.png`
- `docs/evidence/alerts.png`

Optional (recommended):
- `docs/evidence/logs-loki.png`

---

## 1) Prometheus scrape targets (all UP)
Open: http://localhost:9090/targets

Expected (UP):
- `prometheus`
- `otel-collector`
- `tempo`
- `saas-ws-hello` (endpoint: `http://hello-api:8080/metrics`)

Screenshot:
- `docs/evidence/targets.png`

---

## 2) Grafana dashboard: Infra health
Open Grafana → Dashboards → Folder `Workspace` → **Workspace Observability - Infra**

Expected:
- `Targets Up` shows expected value (e.g. `4`)
- `Collector Up` shows `1`
- `Tempo Up` shows `1`

Screenshot:
- `docs/evidence/dashboard-infra.png`

---

## 3) Grafana dashboard: saas-ws-hello HTTP RED
Open Grafana → Dashboards → Folder `Workspace` → **saas-ws-hello - HTTP RED**

Expected:
- Request rate (RPS) shows activity after generating traffic
- Latency p50/p95/p99 is visible
- Top routes include `GET /ping` and `POST /echo`
- Error panels may show “No data” if there are no 5xx (healthy state)

Screenshot:
- `docs/evidence/dashboard-hello-http-red.png`

Traffic generator:
```bash
make demo-traffic
```

4) Tempo tracing proof (trace detail)

Open Grafana → Explore → datasource Tempo

Search:

- Service Name: `saas-ws-hello`
- Span Name: `GET /ping` or `POST /echo`

Expected:

- Traces are listed
- Opening a trace shows span timeline / duration
- Span names are stable (e.g. `GET /ping`, `POST /echo`)

Screenshot:

- `docs/evidence/trace-hello.png`

5) Prometheus alerts loaded

Open: `http://localhost:9090/alerts`

Expected:

- Alert rules are loaded
- State is typically `Inactive` when the system is healthy

Screenshot:

- `docs/evidence/alerts.png`

6) Loki logs proof (optional)

Open Grafana → Explore → datasource Loki

Recommended query (focused):

- `{compose_service="hello-api"} |= "http_request"`

Alternative query (broad):

- `{compose_project="saas-ws-observability"}`

Expected:

- Log lines appear for the selected service/project
- JSON logs may include fields such as trace_id and request_id

Screenshot:

- `docs/evidence/logs-loki.png`