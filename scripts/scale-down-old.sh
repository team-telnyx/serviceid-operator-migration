#!/bin/bash
# scale-down-old.sh - Scale down the old Ansible-based operator
set -e

NAMESPACE="op-service-id-system"
OLD_DEPLOYMENT="op-service-id-controller-manager"

echo "=========================================="
echo "Scale Down Old Operator"
echo "=========================================="
echo ""

# Verify context
echo "[1/3] Verifying cluster connection..."
kubectl cluster-info | head -1
echo ""

# Scale down
echo "[2/3] Scaling down old operator..."
kubectl scale deployment "$OLD_DEPLOYMENT" --replicas=0 -n "$NAMESPACE"
echo ""

# Verify
echo "[3/3] Verifying old operator is stopped..."
sleep 5
kubectl get pods -n "$NAMESPACE" | grep "$OLD_DEPLOYMENT" || echo "✓ Old operator scaled down"
echo ""

echo "=========================================="
echo "Old operator scaled down successfully!"
echo "=========================================="
echo ""
echo "Next step: Deploy new operator with:"
echo "  kubectl apply -f manifests/new-operator-deployment.yaml"
