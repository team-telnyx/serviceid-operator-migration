# ArgoCD CLI Authentication with Okta

## Prerequisites

Install ArgoCD CLI:
```bash
# Linux
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# macOS
brew install argocd

# Verify
argocd version --client
```

## Login with Okta SSO

### Step 1: Initiate SSO Login
```bash
argocd login argocd.telnyx.io --sso
```

This will:
1. Open your default browser
2. Redirect to Okta login page
3. Authenticate with your Telnyx credentials
4. Redirect back to ArgoCD
5. CLI will capture the authentication token

### Step 2: Verify Login
```bash
argocd account get-user-info
```

Expected output:
```
Username: your-email@telnyx.com
Issuer: https://telnyx.okta.com
Groups: your-groups...
```

### Step 3: List Applications
```bash
# List all apps
argocd app list

# Find service-id-operator
argocd app list | grep service-id-operator
```

## Managing Service-Id-Operator Application

### Get Application Details
```bash
argocd app get service-id-operator-tlnx-backend-lv1-dev
```

### Pause Auto-Sync (Before Migration)
```bash
# Disable automated sync
argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy none

# Verify
argocd app get service-id-operator-tlnx-backend-lv1-dev | grep "Sync Policy"
```

### Resume Auto-Sync (After Migration)
```bash
# Re-enable automated sync
argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy automated

# Or with auto-prune (be careful!)
argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy automated --auto-prune
```

### Manual Sync (if needed)
```bash
# Trigger manual sync
argocd app sync service-id-operator-tlnx-backend-lv1-dev
```

## Alternative: Web UI

If CLI doesn't work with Okta:

1. Open https://argocd.telnyx.io
2. Click "Login via Okta"
3. Complete Okta authentication
4. Find `service-id-operator-tlnx-backend-lv1-dev` application
5. Click on it
6. Click "App Details" tab
7. Under "Sync Policy", set "Automated Sync" to "Disable"

## Troubleshooting

### "token expired" Error
```bash
# Re-login
argocd login argocd.telnyx.io --sso
```

### "permission denied" Error
Your Okta groups may not have access to the application. Contact:
- ArgoCD admins
- infra-core-squad

### CLI Opens Browser but Hangs
Try manual token flow:
```bash
argocd login argocd.telnyx.io --sso --grpc-web
```

Or use the web UI instead of CLI.

## Quick Reference

| Task | Command |
|------|---------|
| Login | `argocd login argocd.telnyx.io --sso` |
| List apps | `argocd app list` |
| Get app | `argocd app get service-id-operator-tlnx-backend-lv1-dev` |
| Pause sync | `argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy none` |
| Resume sync | `argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy automated` |
| Manual sync | `argocd app sync service-id-operator-tlnx-backend-lv1-dev` |
| Logout | `argocd logout argocd.telnyx.io` |
