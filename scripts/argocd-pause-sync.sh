#!/bin/bash
# argocd-pause-sync.sh - Pause ArgoCD auto-sync for service-id-operator
set -e

APP_NAME="service-id-operator-tlnx-backend-lv1-dev"

echo "=========================================="
echo "ArgoCD: Pause Auto-Sync"
echo "=========================================="
echo ""

# Check if argocd CLI is installed
if ! command -v argocd &> /dev/null; then
    echo "ERROR: argocd CLI not found!"
    echo "Install with:"
    echo "  curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
    echo "  sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd"
    exit 1
fi

# Login instructions
echo "[Step 1] Login to ArgoCD with Okta SSO"
echo ""
echo "If not already logged in, run:"
echo "  argocd login argocd.telnyx.io --sso"
echo ""
echo "This will open a browser for Okta authentication."
echo ""

# Check current login status
echo "[Step 2] Checking ArgoCD login status..."
argocd account get-user-info 2>/dev/null || echo "Not logged in. Please run: argocd login argocd.telnyx.io --sso"
echo ""

# Pause auto-sync
echo "[Step 3] Pausing auto-sync for $APP_NAME..."
echo "Command: argocd app set $APP_NAME --sync-policy none"
echo ""
echo "Or disable auto-sync in the UI:"
echo "  1. Open https://argocd.telnyx.io"
echo "  2. Find application: $APP_NAME"
echo "  3. Click 'App Details' -> 'Sync Policy'"
echo "  4. Set 'Automated Sync' to 'Disable'"
echo ""

# Alternative: Set ignore annotation
echo "[Alternative] Add ignore annotation to deployment:"
echo "  kubectl annotate deployment op-service-id-controller-manager -n op-service-id-system argocd.argoproj.io/ignore=true --overwrite"
echo ""

echo "=========================================="
echo "After pausing sync, you can safely run:"
echo "  ./scripts/deploy-new-operator.sh"
echo "=========================================="
