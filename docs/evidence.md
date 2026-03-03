# Evidence Pack

This repo provides repeatable proof that **metrics + tracing + alerts** work end-to-end for the Workspace ecosystem.

## URLs
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Tempo (backend): http://localhost:3200

## Evidence files (screenshots)
Place screenshots under: `docs/evidence/`

Required:
- `docs/evidence/targets.png`
- `docs/evidence/dashboard-infra.png`
- `docs/evidence/dashboard-hello-http-red.png`
- `docs/evidence/trace-hello.png`

Optional (recommended):
- `docs/evidence/alerts.png`

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
- `Targets Up` shows `4`
- `Collector Up` shows `1`
- `Tempo Up` shows `1`
- Scrape duration / samples charts are populated

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

Traffic generator (run from host, Docker network):
```bash
docker run --rm --network saas-ws-observability_default curlimages/curl:8.7.1 \
  -sS http://hello-api:8080/ping >/dev/null

docker run --rm --network saas-ws-observability_default curlimages/curl:8.7.1 \
  -sS -X POST http://hello-api:8080/echo \
  -H 'Content-Type: application/json' \
  -d '{"message":"hi"}' >/dev/null
```

## 4) Tempo tracing proof (trace detail)

Open Grafana → Explore → datasource Tempo

Search:

- Service Name: saas-ws-hello
- Span Name: GET /ping or POST /echo

Expected:

- Traces are listed
- Opening a trace shows span timeline / duration
- Span names are stable (e.g. GET /ping, POST /echo)

Screenshot:

- `docs/evidence/trace-hello.png`

5) Prometheus alerts loaded (inactive is OK)

Open: `http://localhost:9090/alerts`

Expected:

- Alert rules from prometheus/alerts.yml are loaded
- State is typically Inactive when the system is healthy

Screenshot:

- `docs/evidence/alerts.png`