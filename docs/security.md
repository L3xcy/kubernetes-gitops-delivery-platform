# Security model

## Workload controls

- Dedicated ServiceAccount with token automount disabled
- Non-root UID and GID
- Read-only root filesystem
- Privilege escalation disabled
- All Linux capabilities dropped
- Runtime-default seccomp profile
- CPU and memory requests and limits
- Liveness and readiness probes
- Namespace-scoped NetworkPolicy
- No application secrets required

## Delivery controls

- Git is the source of truth for environment image tags
- Development auto-sync and production manual approval are separate
- Argo CD AppProject limits allowed source repositories and destinations
- The AppProject blocks Kubernetes Secrets from this demonstration repository
- GitHub Actions receives read-only repository permissions except for the tag-triggered package publisher
- API credentials and kubeconfigs are excluded from Git

## Local cluster isolation

Every script uses the repository-owned `.local/kubeconfig`, verifies `kind-gitops-delivery`, and passes both kubeconfig and context explicitly. Do not replace these calls with unqualified `kubectl` commands on a workstation that also accesses other clusters.

The repository contains no employer configuration, credentials, cluster endpoints, or production data.
