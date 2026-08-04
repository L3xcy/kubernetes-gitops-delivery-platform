#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/lib.sh"
require_command kind

KIND_EXPERIMENTAL_PROVIDER=podman kind delete cluster --name "${CLUSTER_NAME}"
echo "Deleted only the dedicated Kind cluster '${CLUSTER_NAME}'."
