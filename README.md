# K8s-Visit-Counter

## O que este projeto faz?
Uma API de contador de visitas que roda em 3 pods simultâneos, com monitoramento via Prometheus e dashboards no Grafana.

## Ferramentas instaladas (obrigatórias)
- Docker Desktop
- kubectl (scoop install kubectl)
- helm (scoop install helm)
- k3d (scoop install k3d)

## Como rodar

### 1. Setup do cluster
```powershell
cd scripts
.\setup-cluster.ps1
```

### 2. Deploy da aplicacao
```powershell
.\deploy-app.ps1
```

### 3. Testar a aplicacao
```powershell
kubectl port-forward -n apps svc/visit-counter 5000:80
# Acesse http://localhost:5000
```

### 4. Acessar Grafana
```powershell
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
# Acesse http://localhost:3000 (admin/admin123)
```

## Comandos uteis
```powershell
# Ver pods
kubectl get pods -n apps

# Ver logs
kubectl logs -n apps -l app=visit-counter

# Ver metricas direto do Prometheus
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090

# Destruir tudo
k3d cluster delete estudocluster
```

## Estrutura do projeto
- `src/` - Codigo fonte da aplicacao
- `docker/` - Dockerfile da aplicacao
- `helm/visit-counter/` - Helm chart da aplicacao
- `monitoring/` - Configuracoes do Prometheus/Grafana
- `scripts/` - Scripts de setup e deploy