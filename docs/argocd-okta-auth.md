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

> **⚠️ Verify ArgoCD URL:** Common URLs are:
> - `argocd.telnyx.io` (production)
> - `argocd.dev.telnyx.io` (dev)
> - `argocd.query.dev.telnyx.io`
> 
> Check your existing kubeconfig or ask infra-core-squad for the correct URL.

### Step 1: Initiate SSO Login
```bash
# Replace <ARGOCD_URL> with the actual ArgoCD server URL
argocd login <ARGOCD_URL> --sso

# Examples:
# argocd login argocd.telnyx.io --sso
# argocd login argocd.dev.telnyx.io --sso
```

This will:
1. Open your default browser
2. Redirect to Okta login page
3. Authenticate with your Telnyx credentials
4. Redirect back to ArgoCD
5. CLI will capture the authentication token

### Step 2: Verify Login (from configured server)
```bash
# If you logged in successfully in Step 1, verify with:
argocd account get-user-info

# Or specify the server explicitly
argocd account get-user-info --server <ARGOCD_URL>
```

Expected output:
```
Username: your-email@telnyx.com
Issuer: https://telnyx.okta.com
Groups: your-groups...
```

### Step 3: List Applications
```bash
# List all apps (uses the server from your current context)
argocd app list

# Or specify server explicitly
argocd app list --server <ARGOCD_URL> --auth-token <TOKEN>

# Find service-id-operator
argocd app list | grep service-id-operator
```

## Managing Service-Id-Operator Application

Replace `<ARGOCD_URL>` with your actual ArgoCD server (e.g., `argocd.telnyx.io` or `argocd.dev.telnyx.io`).

### Get Application Details
```bash
argocd app get service-id-operator-tlnx-backend-lv1-dev

# Or with explicit server
argocd app get service-id-operator-tlnx-backend-lv1-dev --server <ARGOCD_URL>
```

### Pause Auto-Sync (Before Migration)
```bash
# Disable automated sync
argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy none

# With explicit server
argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy none --server <ARGOCD_URL>

# Verify
argocd app get service-id-operator-tlnx-backend-lv1-dev | grep "Sync Policy"
```

### Resume Auto-Sync (After Migration)
```bash
# Re-enable automated sync
argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy automated

# With explicit server
argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy automated --server <ARGOCD_URL>

# Or with auto-prune (be careful!)
argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy automated --auto-prune
```

### Manual Sync (if needed)
```bash
# Trigger manual sync
argocd app sync service-id-operator-tlnx-backend-lv1-dev

# With explicit server
argocd app sync service-id-operator-tlnx-backend-lv1-dev --server <ARGOCD_URL>
```

## Alternative: Web UI

If CLI doesn't work with Okta:

1. Open `https://<ARGOCD_URL>` (replace with actual ArgoCD server)
2. Click "Login via Okta"
3. Complete Okta authentication
4. Find `service-id-operator-tlnx-backend-lv1-dev` application
5. Click on it
6. Click "App Details" tab
7. Under "Sync Policy", set "Automated Sync" to "Disable"

> **Note:** Common ArgoCD URLs:
> - `https://argocd.telnyx.io` (production)
> - `https://argocd.dev.telnyx.io` (dev)
> - `https://argocd.query.dev.telnyx.io`

## Troubleshooting

### "token expired" Error
```bash
# Re-login (replace <ARGOCD_URL> with actual server)
argocd login <ARGOCD_URL> --sso
```

### "permission denied" Error
Your Okta groups may not have access to the application. Contact:
- ArgoCD admins
- infra-core-squad

### CLI Opens Browser but Hangs
Try manual token flow:
```bash
argocd login <ARGOCD_URL> --sso --grpc-web
```

Or use the web UI instead of CLI.

## Quick Reference

Replace `<ARGOCD_URL>` with your actual ArgoCD server URL.

| Task | Command |
|------|---------|
| Login | `argocd login <ARGOCD_URL> --sso` |
| List apps | `argocd app list` |
| Get app | `argocd app get service-id-operator-tlnx-backend-lv1-dev` |
| Pause sync | `argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy none` |
| Resume sync | `argocd app set service-id-operator-tlnx-backend-lv1-dev --sync-policy automated` |
| Manual sync | `argocd app sync service-id-operator-tlnx-backend-lv1-dev` |
| Logout | `argocd logout <ARGOCD_URL>` |

> **Common ArgoCD URLs at Telnyx:**
> - `argocd.telnyx.io` (production)
> - `argocd.dev.telnyx.io` (dev)
> - `argocd.query.dev.telnyx.io`
