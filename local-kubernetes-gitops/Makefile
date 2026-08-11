SHELL := /usr/bin/env bash

.PHONY: bootstrap verify render lint security argocd-ui argocd-password status destroy

bootstrap:
	./cluster/bootstrap.sh

verify:
	./cluster/verify.sh

render:
	@mkdir -p .rendered
	helm template demo-app charts/demo-app --namespace demo > .rendered/demo-app.yaml
	@echo "Rendered manifest: .rendered/demo-app.yaml"

lint:
	helm lint charts/demo-app --strict

security: render
	trivy --config security/trivy.yaml config .rendered

argocd-ui:
	kubectl port-forward service/argocd-server -n argocd 8443:80

argocd-password:
	@kubectl get secret argocd-initial-admin-secret -n argocd \
		-o jsonpath='{.data.password}' | base64 --decode
	@echo

status:
	kubectl get application demo-app -n argocd
	kubectl get deployment,pods,service,ingress -n demo -o wide

destroy:
	./cluster/destroy.sh
