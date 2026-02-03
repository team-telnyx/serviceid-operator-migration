# ServiceId Operator Migration

Migration from old Ansible-based operator to new Go-based `infra-oci-serviceid-operator`.

## Overview

| Aspect | Old Operator | New Operator |
|--------|-------------|--------------|
| Namespace | `op-service-id-system` | `op-service-id-system` (same) |
| ServiceAccount | `op-service-id-controller-manager` | Reuse same SA |
| Image | `infra/op-service-id:0.14.0.b3.bd57061` | `infra-oci-serviceid-operator:2026.01.09.19.18.7f37159` |
| Vault Auth | `auth/tlnx-backend-lv1-dev` | Same |
| Vault Role | `op-service-id` | Same |

## Repository Structure

```
.
├── README.md
├── manifests/
│   ├── new-operator-deployment.yaml
│   └── test-serviceid.yaml
├── scripts/
│   ├── migrate.sh
│   ├── scale-down-old.sh
│   ├── verify-new-operator.sh
│   └── rollback.sh
└── docs/
    └── serviceid-crd-spec.md
```

## Quick Start

1. Review manifests in `manifests/`
2. Run scripts in order from `scripts/`
3. Test with `test-serviceid.yaml`

## Migration Steps

### Phase 1: Planning (Current)
- [x] Analyze old operator configuration
- [x] Document ServiceId CRD spec
- [x] Prepare migration scripts

### Phase 2: Deployment
- [ ] Scale down old operator
- [ ] Deploy new operator
- [ ] Verify new operator is running

### Phase 3: Testing
- [ ] Create test ServiceId
- [ ] Verify Vault policy creation
- [ ] Verify ServiceAccount/RBAC creation

### Phase 4: Cleanup (if tests pass)
- [ ] Delete old operator deployment
- [ ] Monitor new operator

## Rollback

If issues occur, run `scripts/rollback.sh` to restore old operator.
