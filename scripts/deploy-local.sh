#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib.sh"
require_command podman
require_command kind
require_command helm

assert_safe_context
podman build --tag localhost/gitops-delivery-demo:dev "${PROJECT_ROOT}"
KIND_EXPERIMENTAL_PROVIDER=podman kind load docker-image \
  localhost/gitops-delivery-demo:dev --name "${CLUSTER_NAME}"

safe_helm upgrade --install delivery-demo "${PROJECT_ROOT}/charts/delivery-demo" \
  --namespace delivery-local \
  --create-namespace \
  --values "${PROJECT_ROOT}/charts/delivery-demo/values-local.yaml" \
  --wait \
  --timeout 120s

safe_kubectl --namespace delivery-local rollout status deployment/delivery-demo --timeout=120s
