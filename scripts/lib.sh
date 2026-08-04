#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="gitops-delivery"
EXPECTED_CONTEXT="kind-${CLUSTER_NAME}"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${PROJECT_ROOT}/.local/kubeconfig}"

export KUBECONFIG="${KUBECONFIG_PATH}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required command '$1' is not installed." >&2
    exit 1
  fi
}

assert_safe_context() {
  if [[ ! -f "${KUBECONFIG_PATH}" ]]; then
    echo "Project kubeconfig not found at ${KUBECONFIG_PATH}." >&2
    echo "Run 'make cluster-create' first." >&2
    exit 1
  fi

  local current_context
  current_context="$(kubectl --kubeconfig "${KUBECONFIG_PATH}" config current-context)"
  if [[ "${current_context}" != "${EXPECTED_CONTEXT}" ]]; then
    echo "Safety check failed: expected '${EXPECTED_CONTEXT}', got '${current_context}'." >&2
    exit 1
  fi
}

safe_kubectl() {
  assert_safe_context
  kubectl --kubeconfig "${KUBECONFIG_PATH}" --context "${EXPECTED_CONTEXT}" "$@"
}

safe_helm() {
  assert_safe_context
  helm --kubeconfig "${KUBECONFIG_PATH}" --kube-context "${EXPECTED_CONTEXT}" "$@"
}
