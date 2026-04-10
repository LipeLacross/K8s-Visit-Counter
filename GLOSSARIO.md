# Glossary - Dicionário de Termos Técnicos

Este documento explica todos os termos técnicos usados no projeto de forma simples e didática.

---

## 📦 Container e Docker

### Container

**O que é:** Um pacote leve que inclui tudo para rodar um software (código + dependências + sistema operacional mínimo).

**Analogia:** É como uma caixa de pizza com tudo dentro (massa, queijo, molho) - você não precisa de nenhuma cozinha externa.

**Exemplo:**
```dockerfile
python app.py  # Uma única unidade que roda a aplicação
```

### Docker

**O que é:** Plataforma para criar e rodar containers.

**Para que serve:** Empacotar a aplicação para rodar em qualquer lugar, sem precisar instalar Python, dependências, etc.

### Docker Hub

**O que é:** Repositório público de imagens Docker (como um "GitHub para containers").

**Exemplo:** `docker pull nginx` baixa a imagem do Nginx do Docker Hub.

### Dockerfile

**O que é:** Arquivo que define como criar uma imagem Docker.

**Exemplo:**
```dockerfile
FROM python:3.11-slim  # Imagem base
COPY src/ ./           # Copiar arquivos
CMD ["python", "app.py"]  # Comando para rodar
```

### Imagem (Docker)

**O que é:** Modelo/template somente-leitura usado para criar containers.

**Diferença:** Imagem = planta baixa, Container = casa construída.

### Build Context

**O que é:** O diretório que o Docker usa para ler arquivos durante o build.

**Problema comum:** Se o .dockerignore estiver errado, arquivos não são encontrados.

---

## ☸️ Kubernetes (K8s)

### Kubernetes

**O que é:** Plataforma para gerenciar containers em escala. Gerencia deploy, scaling e operações de containers.

** nickname:** K8s (K - 8 letras - s)

### Cluster

**O que é:** Um grupo de máquinas (nodes) que trabalha junto para rodar containers.

**Analogia:** É como um time de construction workers, onde várias pessoas trabalham juntas.

**Exemplo:** 1 server node + 2 agent nodes = 1 cluster

### Node

**O que é:** Uma máquina física ou virtual no cluster K8s.

**Tipos:**
- **Server/Master Node:** Controla o cluster (_API server, etcd, scheduler_)
- **Agent/Worker Node:** Onde os containers realmente rodam

### Pod

**O que é:** A menor unidade do K8s. Pode ter 1 ou mais containers.

**Analogia:** É como um "cachorro" - o menor animal que você pode ter (cada container é um "gato" dentro do "cachorro").

**Exemplo:**
```yaml
pod:
  containers:
  - name: app
    image: visit-counter:latest
```

### Deployment

**O que é:** Um "controlador" que gerencia os Pods - garante que a quantidade correta esteja rodando.

**Analogia:** É como um "pedido de pizzas" - você pede 3 pizzas e quer que cheguem 3.

**Exemplo:**
```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 3  # Sempre ter 3 cópias
```

### ReplicaSet

**O que é:** O mecanismo interno do K8s que garante a quantidade de réplicas.

**Diferença:** Você usa Deployment, não ReplicaSet diretamente.

### Service

**O que é:** Um "ponto de entrada" fixo para um grupo de Pods. Fornece um IP/name fixo para acessar os Pods.

**Analogia:** É como o "RG" ou "CPF" - um número fixo que identifica você, mesmo que você mude de roupa.

**Problema que resolve:** Pods morrem e nascem com IPs novos - o Service mantém um IP fixo.

### Selector

**O que é:** Uma "etiqueta" usada para conectar Service ao Deployment.

**Exemplo:**
```yaml
# Deployment tem label "app: visit-counter"
labels:
  app: visit-counter

# Service busca por essa label
selector:
  app: visit-counter
```

### Labels

**O que é:** "Etiquetas" de identificação nos recursos K8s.

**Formato:** `key: value` (ex: `app: visit-counter`)

### Namespace

**O que é:** Uma "sala"virtual que separa recursos. Organiza recursos em grupos isolados.

**Analogia:** É como pastas em um computador - você pode ter "pasta/trabalho" e "pasta/pessoal".

**Exemplo:** `apps`, `monitoring`, `default`

### ConfigMap

**O que é:** Configurações em formato de texto que podem ser injetadas nos containers.

**Exemplo:** Variáveis de ambiente, configurações de arquivo.

### Secret

**O que é:** Como ConfigMap, mas para dados sensíveis (senhas, tokens, chaves).

**Diferença:** Os dados são codificados em base64 e podem ser criptografados.

### Ingress

**O que é:** Define regras de roteamento HTTP/HTTPS para dentro do cluster.

**Para que serve:** URL diferente para serviços diferentes.

**Exemplo:** `/app1` vai para Service A, `/app2` vai para Service B.

### Health Probes

**O que são:** Verificações que o K8s faz para saber se o container está saudável.

**Tipos:**

- **Liveness Probe:** "O container está vivo?" Se falhar, reinicia.
- **Readiness Probe:** "O container está pronto para receber tráfego?" Se falhar, remove do Service.

**Exemplo:**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 5000
  initialDelaySeconds: 10
  periodSeconds: 5
```

### NodePort

**O que é:** Um tipo de Service que expõe a porta em cada nó.

**Problema:** Usa portas altas (30000-32767) e não é para produção.

### LoadBalancer

**O que é:** Um tipo de Service que cria um IP externo (precisa de cloud provider).

**Limitação:** Não funciona em K3d local (só em AWS, GCP, Azure).

### ClusterIP

**O que é:** Um tipo de Service que só funciona dentro do cluster K8s.

**Usado para:** Comunicação interna entre serviços.

### port-forward

**O que é:** Um comando que "tunela" uma porta do container para o seu computador.

**Usado para:** Acessar aplicações em desenvolvimento local.

**Exemplo:**
```bash
kubectl port-forward svc/my-service 8080:80
# Agora http://localhost:8080 funciona
```

---

## 🦞 K3d (Kubernetes)

### K3d

**O que é:** Uma ferramenta para criar clusters Kubernetes dentro de containers Docker.

**Para que serve:** Desenvolvimento local sem precisar de VMs ou cloud.

**Por que existe:** Kubernetes pesado, K3d leve (baseado em K3s).

### K3s

**O que é:** Uma versão leve do Kubernetes (menos 40% do tamanho).

**Diferença:** K3d cria clusters K3s dentro de Docker.

### k3d cluster create

**O que é:** Comando para criar um cluster K3d.

**Exemplo:**
```bash
k3d cluster create meucluster --servers 1 --agents 2
# 1 server + 2 agents = 3 nodes
```

### k3d image import

**O que é:** Importa uma imagem Docker local para o cluster K3d.

**Para que serve:** Evitar que o K8s tente fazer pull do Docker Hub.

---

## 📦📦 Helm (Gerenciador de Pacotes)

### Helm

**O que é:** Um "gerenciador de pacotes" para Kubernetes. É como o "apt" ou "npm" do K8s.

**Para que serve:** Instalar aplicações complexas (Prometheus, Grafana, etc.) com um comando.

### Chart

**O que é:** Um pacote Helm (como um "pacote npm").

**Estrutura:**
```
my-chart/
  Chart.yaml        # Metadados
  values.yaml       # Valores padrão
  templates/       # Templates K8s
```

### values.yaml

**O que é:** Arquivo com configurações do Chart.

**Exemplo:**
```yaml
replicaCount: 3
image:
  repository: my-app
  tag: latest
```

### template

**O que é:** Um arquivo YAML com placeholders que o Helm preenche com valores.

**Exemplo:**
```yaml
 replicas: {{ .Values.replicaCount }}
```

### helm install

**O que é:** Instala um Chart no cluster.

**Exemplo:**
```bash
helm install my-release ./my-chart
```

### helm upgrade

**O que é:** Atualiza uma instalação existente.

**Exemplo:**
```bash
helm upgrade my-release ./my-chart --set replicaCount=5
```

### --install --upgrade (ou --install)

**O que é:** Instala se não existir, ou atualiza se existir.

---

## 🏗️ Terraform (Infraestrutura como Código)

### Terraform

**O que é:** Ferramenta para criar infraestrutura declarativamente (como código).

**Para que serve:** Criar VMs, networks, storage na AWS/Azure/GCP.

**Analogia:** É como escrever "quero uma casa com 3 quartos" e alguém construir.

### Provider

**O que é:** Um plugin que permite ao Terraform interagir com um serviço (AWS, Azure, etc).

**Exemplo:**
```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Resource

**O que é:** Um objeto de infraestrutura que o Terraform gerencia.

**Exemplo:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxx"
  instance_type = "t3.medium"
}
```

### Variable

**O que é:** Um valor configurável no Terraform.

**Exemplo:**
```hcl
variable "aws_region" {
  default = "us-east-1"
}
```

### Output

**O que é:** Um valor que o Terraform exibe após criar recursos.

**Exemplo:**
```hcl
output "server_ip" {
  value = aws_instance.web.public_ip
}
```

### terraform init

**O que é:** Inicializa o diretório com providers e módulos.

### terraform plan

**O que é:** Mostra o que será criado/modificado.

### terraform apply

**O que é:** Aplica as mudanças.

### terraform destroy

**O que é:** Destrói todos os recursos criados.

### state

**O que é:** Um arquivo que guarda o estado atual da infraestrutura.

**Importante:** Mantenha em outro lugar (S3, etc) em produção.

### VPC (Virtual Private Cloud)

**O que é:** Uma rede virtual isolada na cloud.

**Analogia:** É como um condomínio fechado - só quem tem acesso pode entrar.

### Subnet

**O que é:** Uma subdivisão da VPC.

**Tipos:**
- **Pública:** Tem acesso à internet (tem IP público)
- **Privada:** Só acesso interno

### CIDR Block

**O que é:** Notação para ranges de IPs.

**Exemplo:** `10.0.0.0/16` = IPs de 10.0.0.0 até 10.0.255.255

### Security Group

**O que é:** Regras de firewall para instâncias.

**Exemplo:** Permite HTTP (porta 80) de qualquer lugar.

### EC2 (Elastic Compute Cloud)

**O que é:** Virtual machines na AWS.

---

## 🤖 Ansible (Automação)

### Ansible

**O que é:** Ferramenta de automação para configurar servers.

**Diferença de Terraform:** Terraform cria infraestrutura, Ansible configura servidores.

### Playbook

**O que é:** Um arquivo que define tarefas a serem executadas.

**Formato:** YAML

### Task

**O que é:** Uma única ação (como "instalar Docker").

### Inventory

**O que é:** Lista de hosts que o Ansible gerencia.

**Exemplo:**
```ini
[webservers]
web1.example.com
web2.example.com
```

### Module

**O que é:** Uma "ferramenta" que o Ansible usa para fazer algo.

**Exemplo:** `apt` (instalar pacotes), `docker` (gerenciar containers).

### Become

**O que é:** Flag para executar como sudo/root.

### Tags

**O que é:** Labels para executar só partes específicas do playbook.

---

## 📊 Monitoramento

### Prometheus

**O que é:** Sistema de monitoramento que coleta métricas.

**Modelo:** Pull - Prometheus busca métricas ativamente.

### Metrics (Métricas)

**O que é:** Dados quantitativos sobre o sistema.

**Tipos:**
- **Counter:** só aumenta (ex: número de requests)
- **Gauge:** sobe e desce (ex: memória usada)
- **Histogram:** distribuição de valores
- **Summary:** similar ao histograma

### /metrics

**O que é:** Endpoint padrão do Prometheus.

**No nosso projeto:** `http://app:5000/metrics`

### ServiceMonitor

**O que é:** Recurso do Prometheus Operator que define como coletar métricas.

**Exemplo:**
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
spec:
  endpoints:
  - path: /metrics
    port: web
```

### Grafana

**O que é:** Ferramenta de visualization de métricas (dashboards).

### Dashboard

**O que é:** Uma página com gráficos e métricas.

### Alert

**O que é:** Um alerta quando algo passa de um limiar.

**Exemplo:** Se CPU > 80% por 5 minutos, enviar alerta.

### Prometheus Operator

**O que é:** Um operator que gerencia Prometheus no K8s.

---

## 🔧 Comandos

### kubectl

**O que é:** CLI oficial do Kubernetes.

### kubeconfig

**O que é:** Arquivo que diz ao kubectl como conectar ao cluster.

### Context

**O que é:** Uma configuração no kubeconfig (cluster + usuário + namespace).

### API Server

**O que é:** O "cérebro" do K8s - API que recebe comandos.

### etcd

**O que é:** Banco de dados chave-valor do K8s (onde configs são salvas).

### Scheduler

**O que é:** Componente que decide em qual node cada Pod vai rodar.

### Controller Manager

**O que é:** Componente que garante o estado desejado (ex: 3 réplicas).

### kubelet

**O que é:** Agente que roda em cada node e gerencia containers.

### kube-proxy

**O que é:** Rede do K8s - permite comunicação entre Pods.

---

## 🌐 Redes

### DNS

**O que é:** Sistema que traduz nomes em IPs.

### Port

**O que é:** Número que identifica um serviço em uma máquina.

**Exemplos:**
- 80 = HTTP
- 443 = HTTPS
- 5000 = Nossa app Flask
- 6443 = API do Kubernetes

### localhost

**O que é:** O próprio computador (127.0.0.1).

### 127.0.0.1

**O que é:** IP do localhost.

### 0.0.0.0

**O que é:** "Todas as interfaces" - qualquer IP da máquina.

### Port Mapping

**O que é:** Mapear uma porta do container para uma porta do host.

**Exemplo:** `5000:80` = porta 80 do container mapeada para 5000 do host.

### Proxy

**O que é:** Um servidor intermediário.

### Reverse Proxy

**O que é:** Um proxy que direciona requisições para servidores internos.

---

## 💻 Desenvolvimento

### CLI (Command Line Interface)

**O que é:** Linha de comando (terminal).

### GUI (Graphical User Interface)

**O que é:** Interface gráfica (.mouse).

### Script

**O que é:** Um arquivo com comandos para executar automaticamente.

### Shell

**O que é:** O interpretador de comandos (PowerShell, bash).

### Environment (Ambiente)

**O que é:** Um contexto de execução (dev, test, prod).

### Variável de Ambiente

**O que é:** Uma variável que guarda configurações.

---

## 📋 Glossário de Comandos

### Docker

| Comando | O que faz |
|---------|-----------|
| `docker build` | Cria imagem |
| `docker run` | Roda container |
| `docker ps` | Lista containers |
| `docker images` | Lista imagens |
| `docker rm` | Remove container |
| `docker rmi` | Remove imagem |

### kubectl

| Comando | O que faz |
|---------|-----------|
| `kubectl get pods` | Lista pods |
| `kubectl get svc` | Lista services |
| `kubectl get nodes` | Lista nodes |
| `kubectl get deploy` | Lista deployments |
| `kubectl run` | Cria pod |
| `kubectl expose` | Cria service |
| `kubectl apply -f arquivo.yaml` | Aplica config |
| `kubectl delete -f arquivo.yaml` | Remove config |
| `kubectl logs` | Ver logs |
| `kubectl exec` | Executar comando no pod |
| `kubectl port-forward` | Redirecionar porta |

### Helm

| Comando | O que faz |
|---------|-----------|
| `helm install` | Instala chart |
| `helm upgrade` | Atualiza chart |
| `helm uninstall` | Remove chart |
| `helm list` | Lista releases |
| `helm values` | Ver valores |
| `helm template` | Renderiza template |

### Terraform

| Comando | O que faz |
|---------|-----------|
| `terraform init` | Inicializa |
| `terraform plan` | Verifica mudanças |
| `terraform apply` | Aplica mudanças |
| `terraform destroy` | Remove recursos |
| `terraform output` | Ver outputs |

### Ansible

| Comando | O que faz |
|---------|-----------|
| `ansible-playbook` | Executa playbook |
| `ansible-inventory` | Lista inventory |
| `ansible all -m ping` | Testa conexão |

---

## 📚 Referências

- [Kubernetes Docs](https://kubernetes.io/pt-br/docs/)
- [Helm Docs](https://helm.sh/docs/)
- [Terraform Docs](https://www.terraform.io/docs)
- [Ansible Docs](https://docs.ansible.com/)
- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)

---

**Ultima atualização:** 2026-04-10
**Projeto:** K8s-Visit-Counter
**Mantenedor:** Felipe Moreira Rios