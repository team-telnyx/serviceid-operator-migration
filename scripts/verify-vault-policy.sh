#!/bin/bash
# verify-vault-policy.sh - Verify Vault policy was created by operator
set -e

TEST_SVCID="test-serviceid-vault-policy"
VAULT_POLICY="test-serviceid-policy"

echo "=========================================="
echo "Verify Vault Policy Creation"
echo "=========================================="
echo ""

# List matching policies
echo "[1/2] Checking Vault policies..."
echo "Looking for policies matching: $TEST_SVCID"
vault policy list | grep -i "$TEST_SVCID" || echo "No matching policies found"
echo ""

# Read the specific policy
echo "[2/2] Reading policy: $VAULT_POLICY"
vault policy read "$VAULT_POLICY" 2>/dev/null || echo "Policy $VAULT_POLICY not found"
echo ""

echo "=========================================="
echo "Verification complete!"
echo "=========================================="
