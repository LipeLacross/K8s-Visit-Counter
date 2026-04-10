# Terraform - Infraestrutura como Código

Este documento explica como o Terraform foi configurado no projeto para criar a infraestrutura na AWS (VPC, subnets, EC2, etc).

---

## 📁 Arquivos do Terraform

```
terraform/
├── main.tf        # Recursos AWS (VPC, subnets, EC2)
├── variables.tf   # Variáveis configuráveis
└── outputs.tf     # Saídas (IPs, IDs)
```

---

## 📄 main.tf

Define todos os recursos AWS a serem criados.

### Bloco Terraform
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### Provider
```hcl
provider "aws" {
  region = var.aws_region
}
```

### VPC
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support  = true
  
  tags = {
    Name = "${var.project_name}-vpc"
  }
}
```

### Subnets Públicas
```hcl
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}
```

### Subnets Privadas
```hcl
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}
```

### Internet Gateway
```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.project_name}-igw"
  }
}
```

### Route Table
```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}
```

### Security Group
```hcl
resource "aws_security_group" "k8s_nodes" {
  name        = "${var.project_name}-k8s-nodes-sg"
  description = "Security group for Kubernetes nodes"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### EC2 - Server Node
```hcl
resource "aws_instance" "k8s_server" {
  ami           = var.ami_id
  instance_type = var.server_instance_type
  subnet_id     = aws_subnet.public[0].id
  key_name      = aws_key_pair.k8s.key_name
  security_groups = [aws_security_group.k8s_nodes.id]
  
  tags = {
    Name = "${var.project_name}-server"
  }
}
```

### EC2 - Agent Nodes
```hcl
resource "aws_instance" "k8s_agent" {
  count        = var.agent_count
  ami          = var.ami_id
  instance_type = var.agent_instance_type
  subnet_id    = aws_subnet.public[count.index].id
  key_name     = aws_key_pair.k8s.key_name
  security_groups = [aws_security_group.k8s_nodes.id]
  
  tags = {
    Name = "${var.project_name}-agent-${count.index + 1}"
  }
}
```

---

## 📄 variables.tf

Variáveis configuráveis com valores padrão.

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "k8s-visit-counter"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Ubuntu 22.04)"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "server_instance_type" {
  description = "Instance type for K8s server node"
  type        = string
  default     = "t3.medium"
}

variable "agent_instance_type" {
  description = "Instance type for K8s agent nodes"
  type        = string
  default     = "t3.small"
}

variable "agent_count" {
  description = "Number of agent nodes"
  type        = number
  default     = 2
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
  default     = ""
}
```

---

## 📄 outputs.tf

Saídas do Terraform após a criação dos recursos.

```hcl
output "server_ip" {
  description = "Public IP of the K8s server node"
  value       = aws_instance.k8s_server.public_ip
}

output "agent_ips" {
  description = "Public IPs of the K8s agent nodes"
  value       = aws_instance.k8s_agent[*].public_ip
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "security_group_id" {
  description = "ID of the K8s nodes security group"
  value       = aws_security_group.k8s_nodes.id
}
```

---

## 🚀 Como Usar

### Pré-requisitos
```powershell
# Instalar Terraform
scoop install terraform

# Configurar AWS CLI
aws configure

# Definir variáveis de ambiente
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
```

### Inicializar Terraform
```powershell
cd terraform
terraform init
```

### Ver Plano
```powershell
terraform plan -var="ssh_public_key=YOUR_SSH_KEY" -var="aws_region=us-east-1"
```

### Criar Recursos
```powershell
terraform apply -var="ssh_public_key=YOUR_SSH_KEY" -var="aws_region=us-east-1"
```

### Obter IPs
```powershell
terraform output

# Ou
terraform output -raw
```

---

## 📋 Variáveis

| Variável | Default | Descrição |
|----------|---------|-----------|
| `aws_region` | us-east-1 | Região AWS |
| `project_name` | k8s-visit-counter | Nome do projeto |
| `vpc_cidr` | 10.0.0.0/16 | CIDR da VPC |
| `ami_id` | ami-0c55b159cbfafe1f0 | AMI Ubuntu 22.04 |
| `server_instance_type` | t3.medium | Tipo da instância server |
| `agent_instance_type` | t3.small | Tipo das instâncias agents |
| `agent_count` | 2 | Número de agents |
| `ssh_public_key` | (vazio) | Chave SSH pública |

---

## 🔧 Arquitetura Criada

```
AWS Cloud
│
├── VPC (10.0.0.0/16)
│   │
│   ├── Internet Gateway
│   │
│   ├── Public Subnet 1 (10.0.0.0/24)
│   │   └── EC2 Server (k8s-visit-counter-server)
│   │
│   ├── Public Subnet 2 (10.0.1.0/24)
│   │   └── EC2 Agent 1 (k8s-visit-counter-agent-1)
│   │
│   ├── Public Subnet 3 (10.0.2.0/24)
│   │   └── EC2 Agent 2 (k8s-visit-counter-agent-2)
│   │
│   ├── Private Subnet 1 (10.0.10.0/24)
│   ├── Private Subnet 2 (10.0.11.0/24)
│   └── Private Subnet 3 (10.0.12.0/24)
│
└── Security Group (k8s-nodes-sg)
```

---

## 🔍 Troubleshooting

```powershell
# Ver estado
terraform show

# Ver recursos
terraform state list

# Destruir tudo
terraform destroy

# Ver outputs
terraform output
```

---

## ⚠️ Custos

Lembre-se que criar recursos na AWS gera custos. Para desenvolvimento, considere:
- Usar t3.small (mais barato)
- Destruir recursos após uso
- Usar AWS Free Tier

---

## ⏭️ Próximos Passos

Após criar a infraestrutura com Terraform:
1. Configurar os nodes com Ansible
2. Criar o cluster K3d
3. Deploy da aplicação com Helm

---

**Maintainer**: Felipe Moreira Rios
**Created**: 2026-04-09