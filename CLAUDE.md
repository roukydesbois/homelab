# Homelab Kubernetes GitOps Architecture

## Overview

This repository implements a GitOps-based Kubernetes homelab using **ArgoCD** and **Kustomize**. It follows a hierarchical multi-cluster setup supporting different environments (thomelab, minikube, vps) with separation between core infrastructure components and user-facing applications.

## Directory Structure

```
kustomize/
├── base/                          # Shared application bases (nextcloud, odoo)
├── clusters/                      # Cluster-specific configurations
│   ├── base/                      # Base cluster bootstrap
│   └── overlays/
│       ├── thomelab/              # Primary homelab cluster
│       ├── minikube/              # Local development
│       └── vps/                   # External VPS cluster
├── core-argocd-apps/              # Infrastructure components
│   ├── base/                      # Core app definitions
│   └── overlays/
│       └── thomelab/              # Cluster-specific tweaks
└── [app-name]/                    # Individual application configs
    ├── base/                      # Application base manifests
    └── overlays/
        ├── thomelab/              # Thomelab-specific overrides
        └── minikube/              # Minikube overrides
```

## Key Architecture Components

### 1. GitOps Flow (Two-Level Bootstrap)

**Level 1: Cluster Bootstrap**
- Entry point: `clusters/overlays/[cluster]/` (e.g., thomelab)
- Creates the root `core-argocd-app` ArgoCD Application
- This app deploys to `kustomize/core-argocd-apps/overlays/[cluster]/`
- Cluster-specific configuration: storage, networking, infrastructure

**Level 2: Application Deployment**
- Applications are deployed via individual app-of-apps files
- Each application is an ArgoCD Application with namespace and AppProject
- Applications can be toggled on/off by editing the cluster overlay kustomization

### 2. Three-Layer Kustomize Pattern

Each application follows the same structure:

```
app-name/
├── base/
│   └── kustomization.yaml         # Base ArgoCD Application definitions
└── overlays/
    ├── thomelab/
    │   └── kustomization.yaml     # Patch-based customization
    └── minikube/
        └── kustomization.yaml     # Different patches for different envs
```

**Base Layer**: Contains ArgoCD Application specs pointing to Helm charts or raw manifests
**Overlay Layer**: Uses Kustomize patches to customize values for the target cluster

### 3. Core Infrastructure vs. Regular Applications

**Core Infrastructure** (`core-argocd-apps/`):
- ArgoCD itself
- Helm package managers (ArgoCD Image Updater)
- Storage systems (Longhorn)
- Clustering tools (Tailscale)
- Monitoring and backup (Velero)
- Certificate management (Cert-Manager)
- Database operators (CloudNative PG)

These are managed as cluster-wide configurations with patches applied via the thomelab overlay.

**User Applications** (individual app directories):
- Immich, Nextcloud, Keycloak, Firefly
- Each has its own namespace, AppProject, and namespace-scoped resources
- Isolated from core infrastructure

### 4. Application Definition Pattern

Each application follows this structure:

```yaml
# app-of-apps.yaml in cluster overlay
apiVersion: v1
kind: Namespace
metadata:
  name: [app-name]
---
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: [app-name]
  namespace: argocd
spec:
  sourceRepos:
    - https://github.com/roukydesbois/homelab
    - https://[helm-repo].com  # External Helm repos
  destinations:
    - namespace: [app-name]
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: [app-name]
spec:
  project: [app-name]
  source:
    repoURL: https://github.com/roukydesbois/homelab
    targetRevision: main
    path: kustomize/[app-name]/overlays/[cluster]
  destination:
    namespace: [app-name]
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 5. Helm Chart Integration

Most applications use Helm charts as their source. The pattern is:

1. **Base Application Definition**: Points to a Helm chart repository
   ```yaml
   source:
     repoURL: https://[helm-repo]
     chart: [chart-name]
     targetRevision: [version]
   ```

2. **Overlay Patches**: Inject custom Helm values via Kustomize patches
   ```yaml
   - op: add
     path: /spec/source/helm/valuesObject
     value:
       image:
         tag: v1.2.3
       persistence:
         storageClassName: custom-sc
   ```

This approach allows full Helm customization without forking charts.

## Deployment Patterns

### Multi-Component Applications (Example: Firefly)

Applications with multiple related services use separate Applications in base:
```
firefly/base/
├── firefly-db-app.yaml       # Database Application
├── firefly-iii-app.yaml      # Main app
└── importer-app.yaml         # Companion service
```

All three are included in the kustomization and patched together in the overlay.

### Database Integration (Example: Immich)

For stateful applications with databases:

1. **Storage Configuration** (overlay):
   - StorageClass definition
   - PersistentVolumeClaim resources

2. **Database Cluster** (overlay):
   - CloudNative PG cluster definition (immich-pg)
   - Creates secrets with connection details

3. **Application Configuration** (patch):
   - Helm values receive database secrets via patch
   - Example: `valueFrom.secretKeyRef` for DB_HOSTNAME, DB_PASSWORD

Pattern in overlays/thomelab:
```yaml
resources:
  - immich-db-sc.yaml           # Storage class
  - cnpg-cluster.yaml           # Database
  - library-pvc.yaml            # Application storage
  - ../../base
patches:
  - op: add                       # Patch application to use these resources
    path: /spec/source/helm/valuesObject/server/containers/env
    value:
      DB_HOSTNAME:
        valueFrom:
          secretKeyRef:
            name: immich-pg-app
```

### Sealed Secrets for Sensitive Data

Sensitive configuration stored as SealedSecrets:
- `keycloak-config-sealed-secret.yaml`
- `firefly-config-sealed.yaml`
- Sealed with cluster-specific key, preventing accidental exposure

## Multi-Cluster Support

### Thomelab Cluster
- Primary homelab deployment
- All applications enabled
- Storage: Longhorn with S3 backup to Garage
- Networking: Tailscale for external access
- Backup: Velero with scheduled backups
- ArgoCD accessible via Tailscale

### VPS Cluster
- Minimal setup under `clusters/overlays/vps/`
- Only core ArgoCD configuration
- Separate namespace, project, and application management
- Example: Odoo running in isolated namespace

### Minikube
- Development environment overlays for some apps
- Simplified configurations for local testing

## Key Patterns & Conventions

### 1. Namespace Isolation
- Each application gets its own namespace
- AppProjects restrict access to specific namespaces
- Cluster resources (PV, StorageClass) whitelisted in AppProject

### 2. Automated Sync Policies
```yaml
syncPolicy:
  automated:
    prune: true              # Remove resources no longer in git
    selfHeal: true           # Reconcile if cluster diverges
  syncOptions:
    - ApplyOutOfSyncOnly=true    # Only update changed resources
    - ServerSideApply=true       # Use server-side apply
    - CreateNamespace=true       # Auto-create namespaces
```

### 3. Ingress Configuration
- Tailscale ingress controller for all apps
- Ingress class: `tailscale`
- Tailscale Funnel enabled for public access
- Hostname pattern: `[app-name]` or `[custom-name]`

### 4. ArgoCD Configuration (Core App Patches)
The core-argocd-apps overlay includes extensive customization:
- OIDC integration with Keycloak for SSO
- RBAC policies tied to Keycloak groups
- Webhook notifications to ntfy
- Custom triggers for synced/failed/degraded states
- Backup configuration for critical namespaces

### 5. Resource Patching Strategy
Use Kustomize patches to:
- Add cluster-specific ingress annotations
- Inject storage class references
- Configure persistence volumes
- Merge Helm values from multiple sources
- Apply cluster-specific image tags

## Common File Types

- `*-app.yaml` or `*-argocd-app.yaml`: ArgoCD Application definitions
- `*-app-of-apps.yaml`: Contains Namespace, AppProject, and Application together
- `*-sc.yaml`: StorageClass definitions
- `*-pvc.yaml`: PersistentVolumeClaim definitions
- `*-cluster.yaml`: CloudNative PG cluster definitions
- `*-ingress.yaml`: Ingress configurations
- `*-sealed*.yaml`: SealedSecrets for sensitive data
- `*-job.yaml`: Kubernetes Job resources (e.g., CronJob for auto-import)

## Deployment Workflow

1. **Code Change**: Commit to main branch in kustomize/
2. **ArgoCD Detection**: Monitors repository and detects changes
3. **Automatic Sync**: Kustomize builds and applies manifests
4. **Self-Healing**: Continuous reconciliation prevents drift
5. **Notifications**: Webhook notifications to ntfy on status changes
6. **Backup**: Velero captures critical namespaces on schedule

## Key Files to Know

- `/kustomize/clusters/base/core-apps-app.yaml` - Root ArgoCD Application
- `/kustomize/clusters/overlays/[cluster]/kustomization.yaml` - Cluster entry point
- `/kustomize/core-argocd-apps/overlays/[cluster]/kustomization.yaml` - Infrastructure config
- Application-specific overlays contain the environment-specific customizations

## Adding a New Application

1. Create `kustomize/[app-name]/base/` with ArgoCD Application definitions
2. Create `kustomize/[app-name]/overlays/thomelab/` with cluster patches
3. Create app-of-apps file in `kustomize/clusters/overlays/thomelab/[app-name]-app-of-apps.yaml`
4. Add it to `kustomize/clusters/overlays/thomelab/kustomization.yaml` resources
5. Commit and push - ArgoCD will automatically sync

