## Add prometheus and grafana repo
``` 
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
## Install prometheus
```
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.enabled=false
```

## INSTALL LOKI
```helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false
```
## Provision Grafana with Preconfigured Datasources
```
helm install my-grafana grafana/grafana \
  --namespace monitoring \
  --set 'datasources.datasources\.yaml.apiVersion=1' \
  --set 'datasources.datasources\.yaml.datasources[0].name=Prometheus' \
  --set 'datasources.datasources\.yaml.datasources[0].type=prometheus' \
  --set 'datasources.datasources\.yaml.datasources[0].access=proxy' \
  --set 'datasources.datasources\.yaml.datasources[0].url=http://prometheus-operated:9090' \
  --set 'datasources.datasources\.yaml.datasources[0].isDefault=true' \
  --set 'datasources.datasources\.yaml.datasources[1].name=Loki' \
  --set 'datasources.datasources\.yaml.datasources[1].type=loki' \
  --set 'datasources.datasources\.yaml.datasources[1].access=proxy' \
  --set 'datasources.datasources\.yaml.datasources[1].url=http://loki:3100'

```
