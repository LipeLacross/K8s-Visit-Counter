# Ansible - Configuração e Automação

Este documento explica como o Ansible foi configurado no projeto para automatizar a instalação e configuração dos nodes do cluster Kubernetes.

---

## 📁 Arquivos do Ansible

```
ansible/
├── inventory.ini    # Lista de hosts do cluster
└── playbook.yml     # Playbook de instalação
```

---

## 📄 inventory.ini

Define os servidores do cluster K3d.

```ini
[k8s]
server ansible_host={{ server_ip }} ansible_user=ubuntu
agent[1:2] ansible_host={{ agent_ips }} ansible_user=ubuntu

[k8s:vars]
ansible_python_interpreter=/usr/bin/python3
project_name=k8s-visit-counter
```

**Explicação:**
- `k8s`: grupo principal
- `server`: nó master/control plane
- `agent[1:2]`: nós workers (agent-1, agent-2)
- `ansible_user=ubuntu`: usuário para SSH

---

## 📄 playbook.yml

Playbook completo com 4 plays:

### Play 1: Setup Kubernetes Nodes
Instala Docker, kubectl, helm e k3d em todos os nodes.

```yaml
- name: Setup Kubernetes Nodes
  hosts: k8s
  become: yes
  vars:
    k3d_version: "v5.8.3"
    kubectl_version: "1.31.0"
    helm_version: "3.16.3"

  tasks:
    # Atualiza apt
    - name: Update apt cache
      apt:
        update_cache: yes

    # Instala pacotes necessários
    - name: Install required packages
      apt:
        name:
          - curl
          - wget
          - gnupg
          - apt-transport-https
          - ca-certificates
          - lsb-release
        state: present

    # Instala Docker
    - name: Install Docker
      apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          - docker-buildx-plugin
          - docker-compose-plugin
        state: present

    # Baixa e instala kubectl
    - name: Download kubectl
      get_url:
        url: "https://dl.k8s.io/release/v{{ kubectl_version }}/bin/linux/amd64/kubectl"
        dest: /usr/local/bin/kubectl
        mode: '0755'

    # Baixa e instala Helm
    - name: Install Helm
      shell: |
        curl -fsSL https://get.helm.sh/helm-v{{ helm_version }}-linux-amd64.tar.gz -o /tmp/helm.tar.gz
        tar -xzf /tmp/helm.tar.gz -C /tmp/helm
        mv /tmp/helm/linux-amd64/helm /usr/local/bin/helm

    # Instala k3d
    - name: Install k3d
      shell: |
        curl -sL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG={{ k3d_version }} bash

    # Verifica instalações
    - name: Verify kubectl installation
      command: kubectl version --client
```

### Play 2: Setup Kubernetes Server Node
Cria o cluster K3d no nó server.

```yaml
- name: Setup Kubernetes Server Node
  hosts: k8s:server
  become: yes
  vars:
    cluster_name: "estudocluster"

  tasks:
    - name: Create K3d cluster
      shell: |
        k3d cluster create {{ cluster_name }} --servers 1 --agents 2 --port "8080:80@loadbalancer" --api-port 6443
```

### Play 3: Install Monitoring Stack
Instala Prometheus e Grafana via Helm.

```yaml
- name: Install Monitoring Stack
  hosts: k8s:server
  become: no

  tasks:
    - name: Add Prometheus Helm repository
      kubernetes.core.helm_repository:
        name: prometheus-community
        url: https://prometheus-community.github.io/helm-charts

    - name: Install kube-prometheus-stack
      kubernetes.core.helm:
        name: monitoring
        chart_ref: prometheus-community/kube-prometheus-stack
        release_namespace: monitoring
        create_namespace: true
        values_files:
          - ../monitoring/values-prometheus.yaml
```

---

## 🚀 Como Usar

### Pré-requisitos
```powershell
# Instalar Ansible
scoop install ansible

# Configurar SSH para os servers
```

### Executar o Playbook

```powershell
cd ansible

# Testar conectividade
ansible -i inventory.ini all -m ping

# Executar playbook completo
ansible-playbook -i inventory.ini playbook.yml

# Executar apenas tasks específicas
ansible-playbook -i inventory.ini playbook.yml --tags "docker,kubectl"
```

---

## 📋 Variáveis do Playbook

| Variável | Default | Descrição |
|----------|---------|-----------|
| `k3d_version` | v5.8.3 | Versão do k3d |
| `kubectl_version` | 1.31.0 | Versão do kubectl |
| `helm_version` | 3.16.3 | Versão do Helm |
| `cluster_name` | estudocluster | Nome do cluster K3d |

---

## 🔧 Estrutura do Playbook

```
playbook.yml
├── Play 1: Setup Kubernetes Nodes
│   ├── Instala Docker
│   ├── Instala kubectl
│   ├── Instala Helm
│   └── Instala k3d
│
├── Play 2: Setup Server Node
│   └── Cria cluster K3d
│
└── Play 3: Install Monitoring
    ├── Adiciona Helm repo
    └── Instala Prometheus + Grafana
```

---

## ⚠️ Notas

1. **SSH**: O Ansible precisa de acesso SSH aos nodes
2. **Privileges**: Alguns tasks precisam de `become: yes` (sudo)
3. **Python**: Necessário Python 3 nos nodes
4. **kubeconfig**: O Ansible cria o cluster, mas o kubectl local precisa do kubeconfig

---

## 📦 Tags Disponíveis

```powershell
# Executar apenas Docker
ansible-playbook -i inventory.ini playbook.yml --tags "docker"

# Executar apenas kubectl
ansible-playbook -i inventory.ini playbook.yml --tags "kubectl"

# Executar apenas Helm
ansible-playbook -i inventory.ini playbook.yml --tags "helm"

# Pular Docker
ansible-playbook -i inventory.ini playbook.yml --skip-tags "docker"
```

---

## 🔍 Troubleshooting

```powershell
# Verificar conectividade
ansible -i inventory.ini all -m ping

# Verificar variáveis
ansible-inventory -i inventory.ini --list

# Modo verbose
ansible-playbook -i inventory.ini playbook.yml -vvv
```

---

**Maintainer**: Felipe Moreira Rios
**Created**: 2026-04-09