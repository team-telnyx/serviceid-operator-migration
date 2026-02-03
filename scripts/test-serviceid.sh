#!/bin/bash
# test-serviceid.sh - Create test ServiceId and verify Vault policy creation
set -e

NAMESPACE="op-service-id-system"
TEST_SVCID="test-serviceid-vault-policy"
MANIFEST="manifests/test-serviceid.yaml"

echo "=========================================="
echo "Test ServiceId Creation"
echo "=========================================="
echo ""

# Verify new operator is running
echo "[1/5] Checking new operator status..."
NEW_POD=$(kubectl get pods -n "$NAMESPACE" -l app=infra-oci-serviceid-operator -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -z "$NEW_POD" ]; then
    echo "ERROR: New operator pod not found!"
    exit 1
fi
echo "✓ New operator pod: $NEW_POD"
echo ""

# Apply test ServiceId
echo "[2/5] Creating test ServiceId..."
kubectl apply -f "$MANIFEST"
echo ""

# Wait for processing
echo "[3/5] Waiting for ServiceId processing (15s)..."
sleep 15

# Check ServiceId status
echo "[4/5] Checking ServiceId status..."
kubectl get serviceid "$TEST_SVCID" -n "$NAMESPACE" -o yaml | head -50
echo ""

# Check new operator logs
echo "[5/5] Checking new operator logs..."
kubectl logs -n "$NAMESPACE" "$NEW_POD" -c manager --tail=30
echo ""

echo "=========================================="
echo "Test complete!"
echo "=========================================="
echo ""
echo "Verify Vault policy was created:"
echo "  vault policy list | grep $TEST_SVCID"
echo ""
echo "Verify ServiceAccount was created:"
echo "  kubectl get sa $TEST_SVCID-sa -n $NAMESPACE"
