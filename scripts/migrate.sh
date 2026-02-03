#!/bin/bash
# migrate.sh - Full migration script (interactive)
set -e

NAMESPACE="op-service-id-system"
OLD_DEPLOYMENT="op-service-id-controller-manager"
NEW_DEPLOYMENT="infra-oci-serviceid-operator"

echo "=========================================="
echo "ServiceId Operator Migration"
echo "=========================================="
echo ""
echo "This script will:"
echo "  1. Scale down old operator"
echo "  2. Deploy new operator"
echo "  3. Test with sample ServiceId"
echo ""
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

# Step 1: Scale down old
echo ""
echo "[Step 1/4] Scaling down old operator..."
./scripts/scale-down-old.sh

# Step 2: Deploy new
echo ""
echo "[Step 2/4] Deploying new operator..."
./scripts/deploy-new-operator.sh

# Step 3: Test
echo ""
echo "[Step 3/4] Creating test ServiceId..."
./scripts/test-serviceid.sh

# Step 4: Verify
echo ""
echo "[Step 4/4] Verifying Vault policy..."
./scripts/verify-vault-policy.sh

echo ""
echo "=========================================="
echo "Migration complete!"
echo "=========================================="
echo ""
echo "If everything looks good, you can delete the old operator:"
echo "  kubectl delete deployment $OLD_DEPLOYMENT -n $NAMESPACE"
echo ""
echo "If there are issues, run rollback:"
echo "  ./scripts/rollback.sh"
