#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <dev|prod> <immutable-image-tag>" >&2
  exit 1
fi

ENVIRONMENT="$1"
IMAGE_TAG="$2"
if [[ "${ENVIRONMENT}" != "dev" && "${ENVIRONMENT}" != "prod" ]]; then
  echo "Environment must be 'dev' or 'prod'." >&2
  exit 1
fi
if [[ ! "${IMAGE_TAG}" =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$ ]]; then
  echo "Image tag contains unsupported characters." >&2
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VALUES_FILE="${PROJECT_ROOT}/charts/delivery-demo/values-${ENVIRONMENT}.yaml"

sed -i.bak -E "s/^  tag: .*/  tag: ${IMAGE_TAG}/" "${VALUES_FILE}"
rm "${VALUES_FILE}.bak"

echo "Updated ${VALUES_FILE} to image tag '${IMAGE_TAG}'."
echo "Review the diff, commit it, and let Argo CD reconcile the declared state."
