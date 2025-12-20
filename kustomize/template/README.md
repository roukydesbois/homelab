# Application Template

This template provides a starting point for adding new applications to your homelab GitOps setup.

## Quick Start

1. **Copy the template folder**:
   ```bash
   cp -r kustomize/template kustomize/YOUR_APP_NAME
   ```

2. **Search and replace placeholders**:
   - `APP_NAME` → Your application name (lowercase, hyphenated)
   - `HELM_REPO_URL` → Helm chart repository URL (e.g., https://charts.bitnami.com/bitnami)
   - `CHART_NAME` → Helm chart name (e.g., postgresql)
   - `CHART_VERSION` → Chart version or version range (e.g., 1.2.3 or 1.2.x)
   - `GITHUB_REPO` → Your GitHub repository URL

3. **Customize the configuration**:
   - Edit `base/APP_NAME-argocd-app.yaml` with your Helm chart details
   - Edit `overlays/thomelab/APP_NAME-helm-chart-patch.yaml` with cluster-specific values
   - Add additional resources as needed (StorageClass, PVC, ConfigMaps, etc.)

4. **Create the app-of-apps file**:
   ```bash
   cp kustomize/YOUR_APP_NAME/cluster-app-of-apps.yaml.template \
      kustomize/clusters/overlays/thomelab/YOUR_APP_NAME-app-of-apps.yaml
   ```

5. **Register the application**:
   Add your app to `kustomize/clusters/overlays/thomelab/kustomization.yaml`:
   ```yaml
   resources:
     - YOUR_APP_NAME-app-of-apps.yaml
   ```

6. **Commit and push**:
   ```bash
   git add kustomize/YOUR_APP_NAME
   git add kustomize/clusters/overlays/thomelab/YOUR_APP_NAME-app-of-apps.yaml
   git add kustomize/clusters/overlays/thomelab/kustomization.yaml
   git commit -m "Add YOUR_APP_NAME application"
   git push
   ```

ArgoCD will automatically detect and sync your new application!

## Template Structure

```
template/
├── README.md                              # This file
├── cluster-app-of-apps.yaml.template     # Copy to clusters/overlays/[cluster]/
├── base/
│   ├── kustomization.yaml                # Base kustomization
│   └── APP_NAME-argocd-app.yaml          # ArgoCD Application definition
└── overlays/
    └── thomelab/
        ├── kustomization.yaml            # Overlay kustomization
        ├── APP_NAME-helm-chart-patch.yaml    # Helm values patches
        ├── APP_NAME-ingress.yaml         # Tailscale ingress (optional)
        └── examples/                     # Example resources
            ├── storage-class.yaml        # Example StorageClass
            ├── pvc.yaml                  # Example PersistentVolumeClaim
            ├── cnpg-cluster.yaml         # Example PostgreSQL cluster
            └── sealed-secret.yaml        # Example SealedSecret
```

## Common Customizations

### Adding Storage

If your app needs persistent storage:
1. Uncomment the StorageClass in `overlays/thomelab/examples/storage-class.yaml`
2. Uncomment the PVC in `overlays/thomelab/examples/pvc.yaml`
3. Add them to `overlays/thomelab/kustomization.yaml` resources
4. Reference the PVC in your Helm values patch

### Adding a Database

If your app needs a PostgreSQL database:
1. Uncomment the CNPG cluster in `overlays/thomelab/examples/cnpg-cluster.yaml`
2. Add it to `overlays/thomelab/kustomization.yaml` resources
3. Reference the database secrets in your Helm values patch (see example)

### Adding Secrets

For sensitive configuration:
1. Create a Secret manifest
2. Seal it using kubeseal:
   ```bash
   kubeseal --format yaml < secret.yaml > sealed-secret.yaml
   ```
3. Add the sealed secret to `overlays/thomelab/kustomization.yaml` resources

### Adding Ingress

To expose your app via Tailscale:
1. Uncomment the ingress in `overlays/thomelab/APP_NAME-ingress.yaml`
2. Customize the hostname
3. Add it to `overlays/thomelab/kustomization.yaml` resources

### Multiple Components

If your app has multiple related services (e.g., app + database + worker):
1. Create separate ArgoCD Application files in `base/` for each component
2. Add all to `base/kustomization.yaml` resources
3. Create corresponding patches in `overlays/thomelab/` if needed

## AppProject Configuration

The `cluster-app-of-apps.yaml.template` includes an AppProject with:
- **sourceRepos**: Your GitHub repo + external Helm repos
- **destinations**: Target namespace
- **clusterResourceWhitelist**: Common cluster-scoped resources (StorageClass, PV, PVC)
- **namespaceResourceWhitelist**: All namespace-scoped resources

Add additional source repos or adjust permissions as needed.

## Sync Policies

The template uses automated sync by default:
- **prune**: true - Remove resources deleted from Git
- **selfHeal**: true - Reconcile manual changes
- **ApplyOutOfSyncOnly**: true - Only update changed resources
- **CreateNamespace**: true - Auto-create namespace if needed

Adjust these in the base ArgoCD Application or via patches.

## Tips

- Start simple: Begin with just the Helm chart, add complexity incrementally
- Test locally: Use minikube overlay for local testing before deploying to thomelab
- Check existing apps: Look at similar apps in kustomize/ for patterns
- Use patches: Prefer Kustomize patches over forking base definitions
- Version control: Pin chart versions initially, use version ranges once stable
- Namespace everything: Each app gets its own namespace for isolation

## Troubleshooting

- **App not appearing in ArgoCD**: Check that app-of-apps is added to cluster kustomization.yaml
- **Sync failing**: Check ArgoCD logs and Application status for details
- **Permission errors**: Verify AppProject sourceRepos and destination match your config
- **Helm values not applied**: Ensure patches use correct JSON path and YAML structure
- **Ingress not working**: Verify Tailscale ingress class and hostname configuration
