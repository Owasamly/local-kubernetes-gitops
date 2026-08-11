FROM nginxinc/nginx-unprivileged:1.30-alpine

LABEL org.opencontainers.image.title="Local Kubernetes GitOps Demo"
LABEL org.opencontainers.image.description="Minimal unprivileged web workload managed by Argo CD"
LABEL org.opencontainers.image.source="https://github.com/Owasamly/local-kubernetes-gitops"

COPY --chown=101:101 index.html /usr/share/nginx/html/index.html

USER 101

EXPOSE 8080
