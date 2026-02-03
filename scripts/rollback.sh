#!/bin/bash
# rollback.sh - Rollback to old operator if issues occur
set -e

NAMESPACE="op-service-id-system"
OLD_DEPLOYMENT="op-service-id-controller-manager"
NEW_DEPLOYMENT="infra-oci-serviceid-operator"

echo "=========================================="
echo "ROLLBACK - Restore Old Operator"
echo "=========================================="
echo ""

# Delete new operator
echo "[1/3] Deleting new operator..."
kubectl delete deployment "$NEW_DEPLOYMENT" -n "$NAMESPACE" --ignore-not-found=true
echo ""

# Wait for deletion
echo "[2/3] Waiting for new operator to terminate..."
sleep 10
kubectl get pods -n "$NAMESPACE" | grep "$NEW_DEPLOYMENT" || echo "✓ New operator deleted"
echo ""

# Scale up old operator
echo "[3/3] Scaling up old operator..."
kubectl scale deployment "$OLD_DEPLOYMENT" --replicas=1 -n "$NAMESPACE"
sleep 5
kubectl rollout status deployment/"$OLD_DEPLOYMENT" -n "$NAMESPACE" --timeout=60s || true
echo ""

echo "=========================================="
echo "Rollback complete!"
echo "=========================================="
echo ""
echo "Verify old operator is running:"
echo "  kubectl get pods -n $NAMESPACE"
