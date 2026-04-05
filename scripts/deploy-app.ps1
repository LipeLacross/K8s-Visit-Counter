Write-Host "🏗️  BUILD DA IMAGEM DOCKER..." -ForegroundColor Green
docker build -t visit-counter:latest ../docker

Write-Host ""
Write-Host "📤 IMPORTANDO IMAGEM PARA O K3D..." -ForegroundColor Green
k3d image import visit-counter:latest -c estudocluster

Write-Host ""
Write-Host "🚀 DEPLOY VIA HELM..." -ForegroundColor Green
helm upgrade --install visit-counter ../helm/visit-counter `
  --namespace apps `
  --create-namespace `
  --set image.tag=latest

Write-Host ""
Write-Host "✅ DEPLOY CONCLUIDO!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 VERIFICANDO PODS..." -ForegroundColor Yellow
kubectl get pods -n apps

Write-Host ""
Write-Host "🔗 PARA TESTAR A APLICACAO:" -ForegroundColor Yellow
Write-Host "   kubectl port-forward -n apps svc/visit-counter 5000:80"
Write-Host "   Acesse: http://localhost:5000"