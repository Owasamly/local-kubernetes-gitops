#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="gitops-dev"
ARGO_CD_CHART_VERSION="${ARGO_CD_CHART_VERSION:-10.2.1}"
DEMO_IMAGE="${DEMO_IMAGE:-demo-app:local}"

required_commands=(docker k3d kubectl helm)

for command_name in "${required_commands[@]}"; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Missing required command: ${command_name}" >&2
    exit 1
  fi
done

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Start Docker Desktop or the Docker daemon first." >&2
  exit 1
fi

if k3d cluster list 2>/dev/null | awk 'NR > 1 { print $1 }' | grep -qx "${CLUSTER_NAME}"; then
  echo "Starting existing k3d cluster: ${CLUSTER_NAME}"
  k3d cluster start "${CLUSTER_NAME}"
else
  echo "Creating k3d cluster: ${CLUSTER_NAME}"
  k3d cluster create --config "${ROOT_DIR}/cluster/k3d-config.yaml"
fi

kubectl config use-context "k3d-${CLUSTER_NAME}"
kubectl wait --for=condition=Ready nodes --all --timeout=180s

echo "Building and importing the local demo image"
docker build --tag "${DEMO_IMAGE}" "${ROOT_DIR}/app"
k3d image import "${DEMO_IMAGE}" --cluster "${CLUSTER_NAME}"

echo "Installing Argo CD chart ${ARGO_CD_CHART_VERSION}"
helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo update argo
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version "${ARGO_CD_CHART_VERSION}" \
  --values "${ROOT_DIR}/argocd/values.yaml" \
  --wait \
  --timeout 10m

kubectl wait \
  --namespace argocd \
  --for=condition=Available \
  deployment/argocd-server \
  --timeout=300s

echo "Applying the declarative Argo CD project and application"
kubectl apply -f "${ROOT_DIR}/argocd/demo-project.yaml"
kubectl apply -f "${ROOT_DIR}/argocd/demo-app-application.yaml"

echo "Waiting for Argo CD to reconcile demo-app"
for attempt in $(seq 1 60); do
  sync_status="$(kubectl get application demo-app -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health_status="$(kubectl get application demo-app -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || true)"

  if [[ "${sync_status}" == "Synced" && "${health_status}" == "Healthy" ]]; then
    echo "demo-app is Synced and Healthy"
    break
  fi

  if [[ "${attempt}" -eq 60 ]]; then
    echo "Timed out waiting for demo-app. Run cluster/verify.sh for diagnostics." >&2
    exit 1
  fi

  sleep 5
done

echo
echo "Bootstrap complete."
echo "Demo application: http://gitops-demo.localhost:8080"
echo "Argo CD UI: run 'make argocd-ui', then open http://localhost:8443"
echo "Initial Argo CD password command: make argocd-password"
