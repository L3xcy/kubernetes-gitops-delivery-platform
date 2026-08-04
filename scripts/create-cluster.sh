#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib.sh"
require_command kind
require_command podman
require_command kubectl

mkdir -p "$(dirname "${KUBECONFIG_PATH}")"

if KIND_EXPERIMENTAL_PROVIDER=podman kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "Kind cluster '${CLUSTER_NAME}' already exists."
else
  KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster \
    --name "${CLUSTER_NAME}" \
    --config "${PROJECT_ROOT}/cluster/kind.yaml" \
    --kubeconfig "${KUBECONFIG_PATH}"
fi

kubectl --kubeconfig "${KUBECONFIG_PATH}" config use-context "${EXPECTED_CONTEXT}" >/dev/null
assert_safe_context
safe_kubectl wait --for=condition=Ready node --all --timeout=120s
echo "Safe local cluster is ready with context '${EXPECTED_CONTEXT}'."
