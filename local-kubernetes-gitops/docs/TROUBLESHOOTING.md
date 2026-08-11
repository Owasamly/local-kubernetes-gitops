# Troubleshooting

## Docker daemon is unavailable

```text
Cannot connect to the Docker daemon
```

Start Docker Desktop or the Linux Docker service, then verify:

```bash
docker info
```

## Cluster exists but the Kubernetes API is unavailable

```bash
k3d cluster start gitops-dev
kubectl config use-context k3d-gitops-dev
kubectl get --raw='/readyz?verbose'
```

Wait for `readyz check passed` before continuing.

## Demo image cannot be pulled

The chart uses a locally imported image with `imagePullPolicy: IfNotPresent`. Rebuild and import it:

```bash
docker build -t demo-app:local app
k3d image import demo-app:local -c gitops-dev
kubectl rollout restart deployment/demo-app -n demo
```

## Argo CD remains OutOfSync

Inspect the Application conditions:

```bash
kubectl describe application demo-app -n argocd
kubectl get application demo-app -n argocd -o yaml
```

Request a hard refresh:

```bash
kubectl annotate application demo-app -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite
```

## Application is Synced but not Healthy

```bash
kubectl get pods -n demo -o wide
kubectl describe deployment demo-app -n demo
kubectl describe pods -n demo
kubectl logs -n demo -l app.kubernetes.io/name=demo-app --tail=100
```

Common causes are a missing local image, readiness-probe failures or insufficient Docker resources.

## Local hostname does not resolve

Most browsers resolve `*.localhost` automatically. Test it:

```bash
curl -I http://gitops-demo.localhost:8080
```

If required, add this local hosts entry:

```text
127.0.0.1 gitops-demo.localhost
```

## Port already in use

The project uses:

- `8080` for the demo ingress;
- `8443` for the Argo CD port-forward.

Find the conflicting process or change the host-side port in `cluster/k3d-config.yaml` and the `argocd-ui` Make target.

## Reset the environment

```bash
make destroy
make bootstrap
```

This deletes only the explicitly named `gitops-dev` k3d cluster.
