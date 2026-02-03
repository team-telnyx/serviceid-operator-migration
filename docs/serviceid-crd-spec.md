# ServiceId CRD Specification

## Overview

The ServiceId CRD (Custom Resource Definition) defines a workload identity that creates:
- A Kubernetes ServiceAccount
- RBAC rules for the ServiceAccount
- A Vault policy for secret access
- A Vault Kubernetes auth role

## API Version

- **Group**: `infra-core.telnyx.com`
- **Version**: `v1alpha1`
- **Kind**: `ServiceId`

## Spec Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `k8s_sa_name` | string | Yes | Name of the ServiceAccount to create |
| `k8s_sa_namespace` | string | Yes | Namespace for the ServiceAccount |
| `k8s_sa_rules` | array | Yes | RBAC rules for the ServiceAccount |
| `vault_k8s_auth_path` | string | Yes | Vault Kubernetes auth backend path (e.g., `tlnx-backend-lv1-dev`) |
| `vault_k8s_auth_role_name` | string | Yes | Name of the Vault Kubernetes auth role |
| `vault_policy_name` | string | Yes | Name of the Vault policy to create |
| `vault_policies` | array | Yes | List of Vault policy paths and capabilities |

## Example

```yaml
apiVersion: infra-core.telnyx.com/v1alpha1
kind: ServiceId
metadata:
  name: chat-to-integrations
  namespace: ai-pipeline-squad
spec:
  k8s_sa_name: chat-to-integrations
  k8s_sa_namespace: ai-pipeline-squad
  k8s_sa_rules:
    - apiGroups: [""]
      resources: ["pods", "endpoints"]
      verbs: ["get", "list", "watch"]
  
  vault_k8s_auth_path: tlnx-backend-lv1-dev
  vault_k8s_auth_role_name: chat-to-integrations
  vault_policy_name: chat-to-integrations
  vault_policies:
    - capabilities: ["read", "list"]
      path: ai-pipeline-squad/data/chat-to-integrations
    - capabilities: ["read", "list"]
      path: ai-pipeline-squad/data/chat-to-integrations/*
```

## Status Fields

The operator updates the ServiceId status with:

- `conditions`: Array of condition objects
  - `type`: Condition type (`Failure`, `Running`, etc.)
  - `status`: "True", "False", or "Unknown"
  - `message`: Human-readable message
  - `reason`: Machine-readable reason

## Vault Policy Format

The operator creates Vault policies in HCL format:

```hcl
path "ai-pipeline-squad/data/chat-to-integrations" {
  capabilities = ["read", "list"]
}

path "ai-pipeline-squad/data/chat-to-integrations/*" {
  capabilities = ["read", "list"]
}
```

## Vault Kubernetes Auth Role

The operator creates a Vault Kubernetes auth role with:

```bash
vault write auth/tlnx-backend-lv1-dev/role/<role_name> \
  bound_service_account_names="<sa_name>" \
  bound_service_account_namespaces="<sa_namespace>" \
  token_policies="<vault_policy_name>" \
  ttl=24h
```

## RBAC Resources Created

1. **ServiceAccount** in specified namespace
2. **Role** with rules from `k8s_sa_rules`
3. **RoleBinding** linking Role to ServiceAccount
