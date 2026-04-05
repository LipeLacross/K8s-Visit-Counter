# K8s-Visit-Counter - Projeto de Estudo Kubernetes

## 🌐🇧🇷 [Versão em Português](README.md)
## 🌐🇺🇸 [English Version](README_EN.md)

---

## O que este projeto faz?

Uma API de contador de visitas em Flask que roda em 3 pods simultâneos no Kubernetes, com monitoramento via Prometheus e dashboards no Grafana.

```
┌─────────────────────────────────────────────────────────────┐
│                    ARQUITETURA DO PROJETO                   │
└─────────────────────────────────────────────────────────────┘

                        ┌──────────────┐
                        │   Usuário    │
                        └──────┬───────┘
                               │ http://localhost:5000
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  KUBERNETES (K3d)                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Service (Load Balancer) - visit-counter:80         │   │
│  │         │              │              │              │   │
│  │    ┌────┴────┐    ┌────┴────┐    ┌────┴────┐        │   │
│  │    │  Pod 1  │    │  Pod 2  │    │  Pod 3  │        │   │
│  │    │ Flask   │    │ Flask   │    │ Flask   │        │   │
│  │    │ :5000   │    │ :5000   │    │ :5000   │        │   │
│  │    └─────────┘    └─────────┘    └─────────┘        │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│              ┌───────────────┼───────────────┐             │
│              ▼               ▼               ▼             │
│        ┌─────────┐    ┌──────────┐    ┌──────────┐        │
│        │Prometheus│◄───│ServiceMon│    │Grafana   │        │
│        │ :9090   │    │ itor     │    │ :3000    │        │
│        └─────────┘    └──────────┘    └──────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## 🔨 Funcionalidades do Projeto

- **API Contador de Visitas**: Aplicação Flask que conta visitas por pod
- **3 Réplicas**: Deployment Kubernetes com 3 pods simultâneos
- **Balanceamento de Carga**: Service distribui requisições entre pods
- **Health Checks**: probes de liveness e readiness
- **Métricas Prometheus**: Expostas via endpoint `/metrics`
- **ServiceMonitor**: Descoberta automática de métricas pelo Prometheus
- **Dashboards Grafana**: Visualização do cluster e aplicação
- **Deploy com Helm**: Configuração declarativa Kubernetes
- **Desenvolvimento Local**: Cluster K3d para testes locais

### 📸 Exemplo Visual

```
# Acessar a aplicação
curl http://localhost:5000
# Retorna: "Olá do Pod visit-counter-abc123 | Ambiente: dev | Visita número: 42"

# Ver métricas
curl http://localhost:5000/metrics
# Retorna: # HELP visitas_total Total de visitas na aplicação
# TYPE visitas_total counter
# visitas_total 42
```

## ✔️ Técnicas e Tecnologias Utilizadas

| Tecnologia | Finalidade |
|------------|------------|
| **Python/Flask** | Aplicação web |
| **prometheus-client** | Exportação de métricas |
| **Docker** | Conteinerização |
| **Terraform** | Infraestrutura como Código (AWS) |
| **Ansible** | Automação de configuração |
| **Kubernetes (K3d)** | Orquestração de contêineres |
| **Helm** | Gerenciamento de pacotes |
| **Prometheus** | Coleta de métricas |
| **Grafana** | Visualização |
| **PowerShell** | Automação de scripts |

## 📊 Diagrama Mermaid

```mermaid
graph TD
    A[Usuário] -->|HTTP| B[Service]
    B --> C[Pod 1]
    B --> D[Pod 2]
    B --> E[Pod 3]
    
    F[Prometheus] -->|Coleta Métricas| C
    F -->|Coleta Métricas| D
    F -->|Coleta Métricas| E
    
    F --> G[Grafana]
    G -->|Mostra Dashboards| A
```

## 📁 Estrutura do Projeto

```
K8s-Visit-Counter/
├── docker/                     # Imagem Docker
│   ├── Dockerfile              # Definição da imagem
│   └── requirements.txt         # Dependências Python
│
├── src/                        # Código da aplicação
│   └── app.py                  # App Flask com métricas
│
├── helm/visit-counter/         # Chart Helm
│   ├── Chart.yaml              # Metadados do chart
│   ├── values.yaml             # Configuração
│   └── templates/              # Manifestos K8s
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       └── servicemonitor.yaml
│
├── monitoring/                 # Configuração de monitoramento
│   └── values-prometheus.yaml
│
├── scripts/                    # Automação (PowerShell)
│   ├── setup-cluster.ps1
│   └── deploy-app.ps1
│
├── terraform/                 # Infraestrutura como Código
│   ├── main.tf                 # Recursos AWS (VPC, EC2)
│   ├── variables.tf            # Variáveis configuráveis
│   └── outputs.tf              # Saídas (IPs, IDs)
│
├── ansible/                   # Automação de Configuração
│   ├── inventory.ini           # Hosts do cluster
│   └── playbook.yml            # Playbook de instalação
│
└── README.md                  # Documentação
```

- **docker/**
  - `Dockerfile`: Container Python 3.11-slim
  - `requirements.txt`: Flask 3.0.0, prometheus-client 0.19.0

- **src/**
  - `app.py`: Aplicação Flask com rotas `/`, `/metrics`, `/health`

- **helm/visit-counter/**
  - `Chart.yaml`: Metadados do chart (versão 0.1.0)
  - `values.yaml`: replicaCount: 3, imagem, service, ingress
  - `templates/deployment.yaml`: 3 réplicas com health probes
  - `templates/service.yaml`: Service ClusterIP
  - `templates/ingress.yaml`: Ingress Traefik
  - `templates/servicemonitor.yaml`: Config de scraping Prometheus

- **monitoring/**
  - `values-prometheus.yaml`: Senha admin Grafana, config Prometheus

- **scripts/**
  - `setup-cluster.ps1`: Cria cluster K3d + instala Prometheus/Grafana
  - `deploy-app.ps1`: Build Docker + deploy Helm

- **terraform/**
  - `main.tf`: Cria VPC, subnets, security groups, instâncias EC2
  - `variables.tf`: Parâmetros region, instance types, etc
  - `outputs.tf`: Retorna IPs públicos das VMs

- **ansible/**
  - `inventory.ini`: Define servidores server e agents
  - `playbook.yml`: Instala Docker, kubectl, helm, k3d, Prometheus

## 🛠️ Abrir e Rodar o Projeto

### Método 1: Local (K3d - Recomendado para estudo)

```powershell
# Instalar ferramentas
scoop install kubectl helm k3d docker

# Setup do cluster
cd scripts
.\setup-cluster.ps1

# Deploy da app
.\deploy-app.ps1
```

### Método 2: Cloud (Terraform + Ansible)

#### Passo 1: Criar infraestrutura com Terraform
```powershell
cd terraform

# Inicializar Terraform
terraform init

# Ver plano
terraform plan -var="ssh_public_key=YOUR_KEY" -var="aws_region=us-east-1"

# Criar recursos
terraform apply -var="ssh_public_key=YOUR_KEY" -var="aws_region=us-east-1"

# Obter IPs dos nodes
terraform output
```

#### Passo 2: Configurar nodes com Ansible
```powershell
cd ansible

# Atualizar inventory com IPs do Terraform
# Edite inventory.ini com os IPs das instâncias

# Executar playbook
ansible-playbook -i inventory.ini playbook.yml
```

#### Passo 3: Deploy da aplicação
```powershell
# SSH para o server node
ssh ubuntu@<server_ip>

# Executar scripts de deploy
cd scripts
./deploy-app.sh
```

### Pré-requisitos (Método 2)

```powershell
# Terraform
scoop install terraform

# Ansible
scoop install ansible

# AWS CLI (para Terraform)
scoop install awscli
aws configure
```

## Comandos Úteis

### Kubernetes (kubectl)
```powershell
# Ver pods
kubectl get pods -n apps

# Ver deployment
kubectl get deployment -n apps

# Ver service
kubectl get svc -n apps

# Ver logs
kubectl logs -n apps -l app=visit-counter

# Acessar Prometheus
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090

# Escalar para 5 réplicas
helm upgrade visit-counter ../helm/visit-counter -n apps --set replicaCount=5

# Deletar cluster
k3d cluster delete estudocluster
```

### Terraform
```powershell
cd terraform

# Inicializar
terraform init

# Ver plano
terraform plan

# Aplicar
terraform apply

# Destruir tudo
terraform destroy

# Ver outputs
terraform output
```

### Ansible
```powershell
cd ansible

# Testar conectividade
ansible -i inventory.ini all -m ping

# Executar playbook completo
ansible-playbook -i inventory.ini playbook.yml

# Executar apenas tasks específicas
ansible-playbook -i inventory.ini playbook.yml --tags "docker,kubectl"
```

## 🌐 Stack Completa - Onde cada ferramenta se encaixa

Este projeto demonstra a stack completa de DevOps:

```
┌─────────────────────────────────────────────────────────────┐
│  TERRAFORM (Infraestrutura)                                  │
│  Cria: VPC, subnets, security groups, EC2                   │
│  Arquivos: terraform/main.tf, variables.tf, outputs.tf     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  ANSIBLE (Configuração)                                      │
│  Instala: Docker, kubectl, helm, k3d, Prometheus            │
│  Arquivos: ansible/inventory.ini, playbook.yml              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  KUBERNETES (Orquestração)                                   │
│  Gerencia: Pods, Services, Deployments                     │
│  Arquivos: helm/visit-counter/templates/*.yaml             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  HELM (Pacotes)                                              │
│  Instala: Aplicações dentro do K8s                          │
│  Arquivos: helm/visit-counter/Chart.yaml, values.yaml       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  DOCKER (Containerização)                                    │
│  Empacota: Aplicação Python                                  │
│  Arquivos: docker/Dockerfile, requirements.txt             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  APLICAÇÃO (Código)                                          │
│  Executa: API Flask com métricas Prometheus                 │
│  Arquivos: src/app.py                                        │
└─────────────────────────────────────────────────────────────┘
```

### Fluxo Completo de Deploy

1. **Terraform** → Cria as VMs na AWS
2. **Ansible** → Instala Docker e ferramentas nas VMs
3. **K3d** → Cria o cluster Kubernetes nas VMs
4. **Helm** → Faz deploy da aplicação no K8s
5. **Docker** → Containeriza a aplicação
6. **Aplicação** → Roda o código Python

### Quando usar cada abordagem?

| Abordagem | Quando usar |
|-----------|-------------|
| **scripts/PowerShell** | Desenvolvimento local (K3d) - mais simples |
| **Terraform + Ansible** | Produção em cloud (AWS) - mais robusto |
| **Apenas Helm** | Já tem infraestrutura, só precisa deployar |

## 🌐 Deploy

Este projeto é desenhado para **desenvolvimento local e aprendizado** usando K3d.

Para deploy em produção:
1. Envie a imagem Docker para um registry (Docker Hub, GHCR, etc.)
2. Atualize os valores Helm com o registry de produção
3. Faça deploy em um cluster Kubernetes real (EKS, GKE, AKS, etc.)
4. Configure ingress com certificados TLS

---

**Última atualização**: 2026-04-05  
**Versão do projeto**: 0.1.0  
**Mantenedor**: Felipe Moreira Rios  