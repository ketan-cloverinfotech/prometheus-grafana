# Step 1: Create kubenetes state metrics

[kube-state-metrics.yaml](kube-state-metrics.yaml)
### Create prometheus.yaml file as follow
```
# my global config
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: []            # add Alertmanager here later

rule_files: []                   # add rules here later

scrape_configs:
  # ───────────────────────────────
  # 0) scrape Prometheus itself
  # ───────────────────────────────
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
        labels:
          app: prometheus

  # ───────────────────────────────
  # 1) GKE ‑ kube‑state‑metrics
  # ───────────────────────────────
  - job_name: gke-kube-state
    metrics_path: /metrics
    static_configs:
      - targets: ['34.68.14.174:8080']
        labels:
          cluster: gke-prod

  # ───────────────────────────────
  # 2) GKE ‑ node‑exporter
  # ───────────────────────────────
  - job_name: gke-node-exporter
    metrics_path: /metrics
    static_configs:
      - targets: ['34.136.169.24:9100']
        labels:
          cluster: gke-prod

  # ───────────────────────────────
  # 3) GKE ‑ C-Advisor
  # ───────────────────────────────
  - job_name: 'gke-cadvisor'
    scheme: https
    tls_config:
      ca_file: /home/ketan_jfrog/prometheus/ca.crt
      insecure_skip_verify: false
    bearer_token_file: /home/ketan_jfrog/prometheus/token
    metrics_path: /metrics/cadvisor
    static_configs:
      - targets: ['34.56.12.110:10250']
        labels:
          cluster: gke-prod
```
