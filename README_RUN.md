# README - Como o Projeto foi Executado

Este documento explica **todos os problemas enfrentados** e as **soluções aplicadas** para fazer o projeto funcionar no ambiente local com K3d + Docker Desktop.

---

## 🔧 Problemas Encontrados e Soluções

### 1. Docker Build - Erro de Contexto

**Problema:**
```dockerfile
COPY src/ .
# ERROR: "/src": not found
```

O Docker não conseguia encontrar os arquivos `src/` e `requirements.txt` porque o build context estava errado.

**Solução:**
- Criar uma pasta temporária `/tmp/visit-counter-build`
- Copiar os arquivos necessários manualmente
- Criar Dockerfile simples na pasta temporária

```powershell
# Criar pasta temporária
mkdir E:\tmp\visit-counter-build

# Copiar arquivos
copy "E:\8. Programming\K8s-Visit-Counter\docker\requirements.txt" E:\tmp\visit-counter-build\
copy "E:\8. Programming\K8s-Visit-Counter\src\app.py" E:\tmp\visit-counter-build\

# Criar Dockerfile simples
# FROM python:3.11-slim
# WORKDIR /app
# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt
# COPY app.py .
# EXPOSE 5000
# CMD ["python", "app.py"]

# Build da imagem
docker build -t visit-counter:latest E:\tmp\visit-counter-build
```

---

### 2. K3d - Pull de Imagem

**Problema:**
```error
Failed to pull image "visit-counter:latest": pull access denied, repository does not exist
```

O Kubernetes tentava fazer pull da imagem do Docker Hub, mas a imagem só existia localmente.

**Solução:**
- Usar `k3d image import` para importar a imagem para todos os nós do cluster

```powershell
# Importar imagem para o cluster K3d
k3d image import visit-counter:latest -c estudocluster
```

**E também:**
- Alterar o `pullPolicy` para `Never` no Helm values.yaml

```yaml
image:
  repository: visit-counter
  tag: latest
  pullPolicy: Never  # Importante!
```

---

### 3. Helm Deployment - Criação de Namespace

**Problema:**
O namespace `apps` não existia e o Helm não conseguia criar.

**Solução:**
- Usar `--create-namespace` no comando helm

```powershell
helm upgrade --install visit-counter ..\helm\visit-counter --namespace apps --create-namespace
```

---

### 4. Registry Local K3d

**Problema:**
Tentar usar registry local com porta dinâmica.

**Solução mais simples:**
- Usar apenas `k3d image import` (funcionou melhor)
- Manter `pullPolicy: Never`

---

## ✅ O que Funcionou

### Passos Executados:

```powershell
# 1. Criar cluster K3d com registry
k3d cluster create estudocluster --servers 1 --agents 2 --port "8080:80@loadbalancer" --api-port 6443 --registry-create regCluster

# 2. Verificar nós
kubectl get nodes
# Resultado: 3 nodes (1 server + 2 agents)

# 3. Instalar Prometheus + Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f ..\monitoring\values-prometheus.yaml

# 4. Criar imagem Docker (na pasta temporária)
docker build -t visit-counter:latest E:\tmp\visit-counter-build

# 5. Importar imagem para K3d
k3d image import visit-counter:latest -c estudocluster

# 6. Deploy via kubectl (simples, sem Helm por enquanto)
kubectl run visit-counter --image=visit-counter:latest --image-pull-policy=Never -n apps --port=5000

# 7. Expor como service
kubectl expose pod visit-counter -n apps --port=80 --target-port=5000 --type=ClusterIP --name=visit-counter-svc
```

---

## 🎯 Resultado Final

- **Cluster K3d**: 3 nós (1 server + 2 agents) ✅
- **Prometheus + Grafana**: Instalados no namespace `monitoring` ✅
- **Aplicação Flask**: Rodando em 1 pod ✅
- **Service**: Exposto na porta 80 ✅

---

## 📋 Para Testar

```powershell
# Acessar a aplicação
kubectl port-forward -n apps svc/visit-counter-svc 5000:80
# Abrir: http://localhost:5000

# Ver logs
kubectl logs -n apps visit-counter

# Ver pods
kubectl get pods -n apps

# Acessar Grafana
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
# Login: admin / admin123
```

---

**Nota**: O deployment via Helm tiveram problemas com image pull. A solução alternativa com `kubectl run` funcionou. O Helm values.yaml precisa de ajuste adicional para funcionar com K3d local.

---

*Criado: 2026-04-09*
*Projeto: K8s-Visit-Counter*
*Maintainer: Felipe Moreira Rios*