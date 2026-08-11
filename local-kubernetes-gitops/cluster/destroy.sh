#!/usr/bin/env bash

set -Eeuo pipefail

CLUSTER_NAME="gitops-dev"

if k3d cluster list 2>/dev/null | awk 'NR > 1 { print $1 }' | grep -qx "${CLUSTER_NAME}"; then
  k3d cluster delete "${CLUSTER_NAME}"
else
  echo "Cluster ${CLUSTER_NAME} does not exist. Nothing to delete."
fi
