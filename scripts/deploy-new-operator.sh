#!/bin/bash
# deploy-new-operator.sh - Deploy the new Go-based operator
set -e

NAMESPACE="op-service-id-system"
NEW_DEPLOYMENT="infra-oci-serviceid-operator"
MANIFEST="manifests/new-operator-deployment.yaml"

echo "=========================================="
echo "Deploy New Operator"
echo "=========================================="
echo ""

# Verify old operator is scaled down
echo "[1/4] Checking old operator status..."
OLD_REPLICAS=$(kubectl get deployment op-service-id-controller-manager -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
if [ "$OLD_REPLICAS" != "0" ]; then
    echo "WARNING: Old operator still has $OLD_REPLICAS replicas!"
    echo "Run ./scale-down-old.sh first"
    exit 1
fi
echo "✓ Old operator is scaled down"
echo ""

# Apply new operator
echo "[2/4] Applying new operator manifest..."
kubectl apply -f "$MANIFEST"
echo ""

# Wait for pod
echo "[3/4] Waiting for new operator pod..."
sleep 10
kubectl get pods -n "$NAMESPACE" | grep "$NEW_DEPLOYMENT"
echo ""

# Check status
echo "[4/4] Checking deployment status..."
kubectl rollout status deployment/"$NEW_DEPLOYMENT" -n "$NAMESPACE" --timeout=60s || true
echo ""

echo "=========================================="
echo "New operator deployed!"
echo "=========================================="
echo ""
echo "Check logs with:"
echo "  kubectl logs -n $NAMESPACE -l app=$NEW_DEPLOYMENT -c manager"
