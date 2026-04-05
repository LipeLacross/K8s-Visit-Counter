Write-Host "🚀 CRIANDO CLUSTER K3D..." -ForegroundColor Green
k3d cluster create estudocluster `
  --servers 1 `
  --agents 2 `
  --port "8080:80@loadbalancer" `
  --api-port 6443

Write-Host ""
Write-Host "✅ CLUSTER CRIADO" -ForegroundColor Green
kubectl get nodes

Write-Host ""
Write-Host "📦 INSTALANDO PROMETHEUS + GRAFANA..." -ForegroundColor Green
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack `
  --namespace monitoring `
  --create-namespace `
  -f ../monitoring/values-prometheus.yaml

Write-Host ""
Write-Host "✅ SETUP CONCLUIDO!" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "   1. Execute: .\scripts\deploy-app.ps1"
Write-Host "   2. Para acessar o Grafana: kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80"
Write-Host "   3. Login: admin / admin123"