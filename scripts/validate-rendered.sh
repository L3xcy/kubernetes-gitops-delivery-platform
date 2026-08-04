#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT

helm template delivery-demo "${PROJECT_ROOT}/charts/delivery-demo" \
  --namespace delivery-dev \
  --values "${PROJECT_ROOT}/charts/delivery-demo/values-dev.yaml" \
  > "${TEMP_DIR}/dev.yaml"
helm template delivery-demo "${PROJECT_ROOT}/charts/delivery-demo" \
  --namespace delivery-prod \
  --values "${PROJECT_ROOT}/charts/delivery-demo/values-prod.yaml" \
  > "${TEMP_DIR}/prod.yaml"

required_patterns=(
  "automountServiceAccountToken: false"
  "runAsNonRoot: true"
  "allowPrivilegeEscalation: false"
  "readOnlyRootFilesystem: true"
  "type: RuntimeDefault"
  "kind: NetworkPolicy"
)

for pattern in "${required_patterns[@]}"; do
  if ! grep -q "${pattern}" "${TEMP_DIR}/dev.yaml"; then
    echo "Rendered dev manifest is missing security control: ${pattern}" >&2
    exit 1
  fi
done

grep -q "replicas: 2" "${TEMP_DIR}/prod.yaml"
grep -q "kind: PodDisruptionBudget" "${TEMP_DIR}/prod.yaml"
grep -q "kubernetes-gitops-delivery-platform:v0.1.0" "${TEMP_DIR}/prod.yaml"

echo "Rendered Helm manifests satisfy the expected delivery and security controls."
