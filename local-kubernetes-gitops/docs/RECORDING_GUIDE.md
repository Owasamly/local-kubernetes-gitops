# Portfolio recording guide

This guide produces concise evidence of CI validation, GitOps synchronization and drift recovery.

## Prepare the environment

```bash
make bootstrap
make verify
```

Start the Argo CD UI before recording:

```bash
make argocd-ui
```

Open `http://localhost:8443`, sign in and navigate to `demo-app`. Do not record the password retrieval command or password.

## Screenshots

### 1. CI workflow summary

Open the latest `GitOps Validation and Security` run and capture all three green jobs:

- Helm Lint and Schema Validation;
- Kubernetes Configuration Security;
- Container Build and Vulnerability Scan.

Suggested filename: `gitops-ci-validation.png`.

### 2. Cluster topology

```bash
kubectl get nodes \
  -o custom-columns='NAME:.metadata.name,STATUS:.status.conditions[-1].type,ROLE:.metadata.labels.node-role\.kubernetes\.io/control-plane,WORKLOAD:.metadata.labels.workload,VERSION:.status.nodeInfo.kubeletVersion'
```

Suggested filename: `gitops-cluster-nodes.png`.

### 3. Argo CD resource tree

In the Argo CD UI, open `demo-app` and capture:

- `Synced`;
- `Healthy`;
- the Deployment, ReplicaSet, Pods, Service, Ingress and PodDisruptionBudget.

Suggested filename: `argocd-application-healthy.png`.

### 4. Workload status

```bash
kubectl get deployment,pods,service,ingress -n demo -o wide
```

Suggested filename: `gitops-workload-status.png`.

### 5. Running application

Open `http://gitops-demo.localhost:8080` and capture the complete application card.

Suggested filename: `gitops-demo-application.png`.

### 6. Argo CD synchronization history

Open `demo-app`, select `History and Rollback`, and capture multiple successful Git revisions.

Suggested filename: `argocd-sync-history.png`.

## Main video: Git-driven scaling

Target duration: 45–70 seconds.

1. Begin on `charts/demo-app/values.yaml` with `replicaCount: 2`.
2. Show two running Pods in a terminal:

   ```bash
   kubectl get pods -n demo
   ```

3. Change the value to `3`.
4. Commit and push:

   ```bash
   git add charts/demo-app/values.yaml
   git commit -m "demo: scale application through GitOps"
   git push
   ```

5. Open the GitHub Actions run briefly and show validation.
6. Return to Argo CD and click `Refresh` if polling has not detected the revision yet.
7. Show the application transition through `OutOfSync` and `Progressing`.
8. Finish when Argo CD shows `Synced / Healthy` and three Pods.

Restore the project to two replicas afterward with a second Git commit.

## Secondary video: self-healing

Target duration: 20–30 seconds.

Keep the Argo CD resource tree visible and run:

```bash
kubectl scale deployment demo-app -n demo --replicas=1
kubectl get deployment demo-app -n demo --watch
```

Capture Argo CD detecting drift and restoring the replica count declared in Git.

## Editing checklist

- crop browser tabs, bookmarks, taskbar and unrelated windows;
- hide usernames, tokens and passwords that are not relevant evidence;
- use 16:9 framing and readable terminal font sizes;
- remove dependency-download and image-pull waiting time;
- keep Git commit, Argo transition and final state in chronological order;
- add short captions: `Git change`, `CI validation`, `Automatic sync`, `Healthy`;
- do not imply CI directly pushes to the local cluster.
