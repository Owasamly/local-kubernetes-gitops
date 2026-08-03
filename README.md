# Local Kubernetes GitOps Platform

A local Kubernetes and continuous-delivery project demonstrating GitOps deployment with k3d, Helm, Argo CD, and GitHub Actions.

## Project objective

This project uses Git as the source of truth for deploying a containerized application to a local Kubernetes cluster. Argo CD continuously compares the desired state stored in this repository with the actual cluster state and automatically reconciles differences.

## Planned architecture

- Docker provides the container runtime.
- k3d runs a lightweight k3s Kubernetes cluster.
- Helm packages the application and Kubernetes resources.
- Argo CD synchronizes the Helm chart from GitHub.
- GitHub Actions validates and scans changes before deployment.

## GitOps capabilities

- Automated synchronization
- Drift detection and self-healing
- Resource pruning
- Declarative Argo CD configuration
- Helm-based deployments
- Kubernetes manifest validation
- Container and configuration security scanning

## Repository structure

| Directory | Purpose |
|---|---|
| `app/` | Demo application and container definition |
| `charts/demo-app/` | Application Helm chart |
| `argocd/` | Argo CD Application and AppProject definitions |
| `cluster/` | Local cluster configuration |
| `security/` | Security policies and validation configuration |
| `.github/workflows/` | CI validation and security workflows |
| `docs/screenshots/` | Portfolio evidence and screenshots |

## Project status

Work in progress.