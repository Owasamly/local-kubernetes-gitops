#!/usr/bin/env bash

set -Eeuo pipefail

CLUSTER_NAME="gitops-dev"

kubectl config use-context "k3d-${CLUSTER_NAME}" >/dev/null

echo "Kubernetes nodes"
kubectl get nodes -o wide

echo
echo "Argo CD application"
kubectl get application demo-app -n argocd \
  -o custom-columns='NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status,REVISION:.status.sync.revision'

echo
echo "Demo workload"
kubectl get deployment,pods,service,ingress -n demo -o wide

echo
echo "HTTP endpoint"
curl --fail --silent --show-error --head http://gitops-demo.localhost:8080
