# Architecture of the Project

## 📁 Project Structure

```
K8s-Visit-Counter/
├── docker/                      # Docker image configuration
│   ├── Dockerfile               # Container image definition
│   └── requirements.txt         # Python dependencies
│
├── src/                         # Application source code
│   └── app.py                   # Flask application with Prometheus metrics
│
├── helm/visit-counter/          # Helm chart for Kubernetes deployment
│   ├── Chart.yaml              # Chart metadata
│   ├── values.yaml             # Default configuration values
│   └── templates/              # Kubernetes manifests
│       ├── deployment.yaml      # Pod deployment (3 replicas)
│       ├── service.yaml        # Load balancer service
│       ├── ingress.yaml        # Ingress routing
│       └── servicemonitor.yaml # Prometheus metrics scraping
│
├── monitoring/                 # Monitoring configuration
│   └── values-prometheus.yaml  # Prometheus & Grafana settings
│
├── scripts/                     # Automation scripts
│   ├── setup-cluster.ps1       # K3d cluster + Prometheus setup
│   └── deploy-app.ps1          # Docker build + Helm deploy
│
├── README.md                   # Portuguese documentation
├── README_EN.md                # English documentation
└── ARCHITECTURE.md             # This file
```

## 🎯 Architecture Principles

### Organization and Separation of Responsibilities
- **Application Layer** (`src/app.py`): Flask API handling HTTP requests and Prometheus metrics
- **Container Layer** (`docker/`): Docker image packaging
- **Orchestration Layer** (`helm/`): Kubernetes manifests defining deployment, service, and monitoring
- **Infrastructure Layer** (`scripts/`): Automation for cluster creation and application deployment
- **Observability Layer** (`monitoring/`): Prometheus and Grafana configuration

### Scalability
- **Horizontal Scaling**: Deployment configured with 3 replicas, easily scalable via Helm (`--set replicaCount=N`)
- **Stateless Design**: Application has no local state; each pod maintains independent visit counter (demonstrates distributed counting)
- **Load Balancing**: Kubernetes Service distributes traffic across all pod replicas
- **Resource Management**: CPU/memory limits defined in Helm values to prevent resource exhaustion

### Reusability
- **Helm Charts**: Encapsulated templates allow deployment across different environments (dev, staging, prod)
- **ServiceMonitor**: Reusable pattern for exposing application metrics to Prometheus
- **Scripts**: Modular PowerShell scripts can be adapted for other projects

### Maintainability
- **Declarative Configuration**: Kubernetes manifests define desired state; cluster reconciles automatically
- **Separation of Concerns**: Configuration separated from templates (values.yaml)
- **Health Probes**: Liveness and readiness probes enable automatic recovery
- **GitOps Ready**: All configuration is code, enabling version control and code review

## 📝 Conventions

### File and Folder Naming
- **Lowercase with hyphens**: `deployment.yaml`, `setup-cluster.ps1`
- **Descriptive names**: `values-prometheus.yaml` (clarifies purpose)
- **Consistent extensions**: `.yaml` for Kubernetes, `.ps1` for PowerShell, `.py` for Python

### Coding Conventions
- **YAML**: 2-space indentation, lowercase keys, hyphenated naming
- **Python**: snake_case for variables/functions, descriptive naming
- **PowerShell**: PascalCase for cmdlets, consistent parameter naming

### Module and Component Structure
- **Helm**: `Chart.yaml` → `values.yaml` → `templates/` pattern
- **Kubernetes**: Each resource type in separate file (Deployment, Service, Ingress, ServiceMonitor)
- **Scripts**: Sequential steps with clear output messages

### Best Practices
- **Single Responsibility**: Each Kubernetes resource has one purpose
- **DRY (Don't Repeat Yourself)**: Helm templates use Go templating to reduce duplication
- **Idempotency**: Scripts use `helm upgrade --install` for both install and update
- **Error Handling**: PowerShell scripts check command success implicitly

## 🛠️ Maintenance and Expansion

### Maintenance

**Updating Dependencies**:
```powershell
# Update Helm charts
helm repo update

# Rebuild Docker image with new dependencies
docker build -t visit-counter:latest ../docker

# Update application in cluster
helm upgrade visit-counter ../helm/visit-counter -n apps
```

**Bug Fixes and Quality Improvements**:
1. Fix source code in `src/app.py`
2. Update Helm chart version in `Chart.yaml`
3. Rebuild Docker image: `docker build -t visit-counter:latest ../docker`
4. Import to K3d: `k3d image import visit-counter:latest -c estudocluster`
5. Redeploy: `helm upgrade visit-counter ../helm/visit-counter -n apps`

**Code Quality**:
- Keep application simple and focused on core functionality
- Document any configuration changes in comments
- Use meaningful labels in Kubernetes resources

### Adding New Features

**1. Create new module or component**:
- For new Python functionality: Add to `src/app.py` or create new module in `src/`
- For new Kubernetes resource: Create template in `helm/visit-counter/templates/`

**2. Add required files**:
- New Python dependencies → Update `docker/requirements.txt`
- New environment variables → Add to `helm/visit-counter/values.yaml`
- New configuration → Update respective values file

**3. Update project configuration**:
- Update Helm values if needed
- Update monitoring configuration if exposing new metrics

**4. Create tests**:
- Test Flask application locally
- Test Kubernetes manifests with `helm template`
- Verify deployment in cluster

---

**Last update**: 2026-04-05  
**Project version**: 0.1.0  
**Maintainer**: Felipe Moreira Rios  