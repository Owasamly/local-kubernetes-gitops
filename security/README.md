# Security controls

This project treats GitOps configuration as deployable code. Security checks therefore run before Argo CD is allowed to reconcile a new revision.

## CI controls

The `GitOps Validation and Security` workflow performs:

1. strict Helm linting;
2. deterministic manifest rendering;
3. Kubernetes schema validation with Kubeconform;
4. Trivy misconfiguration scanning against rendered manifests;
5. a local container image build;
6. Trivy container vulnerability scanning;
7. SARIF upload to GitHub Code Scanning;
8. blocking gates for high/critical Kubernetes misconfigurations and fixed critical image vulnerabilities.

Reporting and enforcement use separate Trivy passes. SARIF is uploaded even if an enforcement pass later fails.

## Workload hardening

The Helm chart configures:

- an unprivileged NGINX image;
- non-root execution;
- a read-only root filesystem;
- dropped Linux capabilities;
- `RuntimeDefault` seccomp;
- disabled service-account token mounting;
- CPU and memory requests and limits;
- liveness and readiness probes;
- a PodDisruptionBudget;
- controlled rolling updates.

## Secret handling

No runtime credentials are required by the demo application. Local kubeconfig files, Argo CD passwords, tokens and unencrypted secret manifests are excluded from Git.

Never record or commit the output of `make argocd-password`.
