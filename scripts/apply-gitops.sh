#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib.sh"

assert_safe_context
safe_kubectl apply --filename "${PROJECT_ROOT}/gitops/project.yaml"
safe_kubectl apply --filename "${PROJECT_ROOT}/gitops/dev-application.yaml"
safe_kubectl apply --filename "${PROJECT_ROOT}/gitops/prod-application.yaml"

echo "GitOps applications submitted. Dev auto-syncs; production requires manual approval."
