# Kubernetes (Minimal Manifests)

These manifests deploy a minimal observability stack into Kubernetes:
- Prometheus
- Grafana
- Tempo
- Loki

Namespace: `ws-observability`

## Apply
```bash
kubectl config use-context docker-desktop
kubectl apply -f k8s/
kubectl -n ws-observability get pods
```

## Port-forward

```
kubectl -n ws-observability port-forward svc/grafana 3000:3000
kubectl -n ws-observability port-forward svc/prometheus 9090:9090
kubectl -n ws-observability port-forward svc/tempo 3200:3200
kubectl -n ws-observability port-forward svc/loki 3100:3100
```

## Grafana login

Default (demo):

- user: admin
- password: admin

Change by updating k8s/01-grafana-secret.yaml (base64 values).

## Cleanup

```
kubectl delete namespace ws-observability
```