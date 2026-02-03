# Vault Token Issue - INFRA-14150 Follow-up

## Problem

The operator starts successfully but cannot initialize the Vault client because the Vault token is not being loaded properly.

## Root Cause

The Vault Agent Injector mounts the token at `/vault/secrets/token` but does not set it as an environment variable. The operator's `cmd/main.go` expects `VAULT_TOKEN` env var to be set.

```go
// From cmd/main.go
if vaultAddr != "" && vaultToken != "" {
    vaultClient, err = vault.NewClient(vaultAddr, vaultToken, k8sAuthPath)
} else {
    setupLog.Info("Vault client not configured - Vault operations will be skipped")
}
```

## Attempted Solutions

### ❌ Option A: Shell command in deployment
Failed because the operator image is scratch/distroless - no `/bin/sh` available.

### ❌ Option B: VAULT_TOKEN env var pointing to file
Failed because the operator expects the actual token value, not a file path.

## ✅ Solution (Pending Gilfoyle's Implementation)

Modify `cmd/main.go` to read the token from file when `VAULT_TOKEN` env var is not set:

```go
// After checking env vars, if vaultToken is still empty, try reading from file
if vaultToken == "" {
    // Try to read token from Vault Agent Injector path
    tokenBytes, err := os.ReadFile("/vault/secrets/token")
    if err == nil {
        vaultToken = string(tokenBytes)
        setupLog.Info("Vault token loaded from /vault/secrets/token")
    }
}
```

This should be added around line 75, before the existing Vault client initialization check.

## Current Status

- Operator pod: `infra-oci-serviceid-operator-7dd7646cb9-c87w2` - Running (2/2)
- Image: `infra-14150-nil-pointer-dereference-in-vault-client-05027d3`
- Issue: "Vault client not configured - Vault operations will be skipped"
- ServiceId reconciliation fails with: `error: "vault client is nil"`

## Next Steps

1. Gilfoyle updates `cmd/main.go` with file reading logic
2. Build and push new image
3. Test Vault policy creation
4. Verify end-to-end ServiceId reconciliation

## References

- Jira: INFRA-14150
- Branch: INFRA-14150-lv-1-infra-oci-serviceid-operator-panic-nil-pointer-dereference-in-vault-client
