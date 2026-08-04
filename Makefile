PYTHON ?= python3
VENV ?= .venv
PORT ?= 8080
IMAGE ?= localhost/gitops-delivery-demo:dev
CHART ?= charts/delivery-demo

.PHONY: init lint test run image chart-lint chart-validate render check cluster-create cluster-delete \
	local-deploy install-argocd apply-gitops verify

init:
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/python -m pip install -e '.[dev]'

lint:
	$(VENV)/bin/ruff check .

test:
	$(VENV)/bin/pytest -q

run:
	$(VENV)/bin/uvicorn app.main:app --reload --host 127.0.0.1 --port $(PORT)

image:
	podman build --tag $(IMAGE) .

chart-lint:
	helm lint $(CHART)
	helm lint $(CHART) --values $(CHART)/values-dev.yaml
	helm lint $(CHART) --values $(CHART)/values-prod.yaml

render:
	mkdir -p .local/rendered
	helm template delivery-demo $(CHART) --namespace delivery-dev \
		--values $(CHART)/values-dev.yaml > .local/rendered/dev.yaml
	helm template delivery-demo $(CHART) --namespace delivery-prod \
		--values $(CHART)/values-prod.yaml > .local/rendered/prod.yaml

chart-validate:
	scripts/validate-rendered.sh

check: lint test chart-lint render chart-validate
	bash -n scripts/*.sh

cluster-create:
	scripts/create-cluster.sh

cluster-delete:
	scripts/delete-cluster.sh

local-deploy:
	scripts/deploy-local.sh

install-argocd:
	scripts/install-argocd.sh

apply-gitops:
	scripts/apply-gitops.sh

verify:
	scripts/verify.sh
