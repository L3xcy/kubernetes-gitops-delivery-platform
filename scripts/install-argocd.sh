#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib.sh"
require_command curl
require_command kubectl

assert_safe_context
ARGO_CD_VERSION="v3.4.2"
MANIFEST="${PROJECT_ROOT}/.local/argocd-install-${ARGO_CD_VERSION}.yaml"
mkdir -p "${PROJECT_ROOT}/.local"

curl --fail --location --proto '=https' --tlsv1.2 \
  "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGO_CD_VERSION}/manifests/install.yaml" \
  --output "${MANIFEST}"

safe_kubectl create namespace argocd --dry-run=client --output=yaml \
  | safe_kubectl apply --filename -
safe_kubectl --namespace argocd apply --server-side --force-conflicts --filename "${MANIFEST}"
safe_kubectl --namespace argocd wait \
  --for=condition=Available deployment/argocd-server --timeout=300s

echo "Argo CD ${ARGO_CD_VERSION} is ready in the isolated local cluster."
