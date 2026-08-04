#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib.sh"

assert_safe_context
safe_kubectl --namespace delivery-local get deployment,service,pods
safe_kubectl --namespace delivery-local get networkpolicy,poddisruptionbudget 2>/dev/null || true
safe_kubectl --namespace delivery-local rollout status deployment/delivery-demo --timeout=120s

echo "Workload checks passed. To inspect it locally, run:"
echo "kubectl --kubeconfig '${KUBECONFIG_PATH}' --context '${EXPECTED_CONTEXT}' -n delivery-local port-forward service/delivery-demo 8080:80"
