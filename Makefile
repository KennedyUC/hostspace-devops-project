SHELL := /bin/bash

ENV ?= ""
TAG ?= ""
VERSION ?= ""
CERT_FILE ?= ""
KEY_FILE ?= ""

include .env/$(ENV)/core.env
include .env/$(ENV)/web.env
export $(shell sed 's/=.*//' .env/$(ENV)/core.env)
export $(shell sed 's/=.*//' .env/$(ENV)/web.env)

.PHONY: install-utils
install-utils:	
	@echo '🏗️ Installing yq'
	@sudo apt-get update && \
     sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
     sudo chmod a+x /usr/local/bin/yq

	@echo '🏗️ Installing skaffold'
	@curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
	 sudo install skaffold /usr/local/bin/

.PHONY: configure-awscli
configure-awscli:
	@aws configure set aws_access_key_id $(AWS_ACCESS_KEY)
	@aws configure set aws_secret_access_key $(AWS_SECRET_KEY)
	@aws configure set default.region $(AWS_REGION)
	@aws configure set default.output json

.PHONY: set-kubectl-context
set-kubectl-context:
	@until [ "$$(aws eks describe-cluster --region $(AWS_REGION) --name $(EKS_CLUSTER_NAME) --query "cluster.status" --output text)" = "ACTIVE" ]; do \
        echo "Waiting for the cluster to be in the ACTIVE state..."; \
        sleep 10; \
	done
	@echo "Cluster is now in the ACTIVE state. Waiting for a few minutes before connecting to the cluster..."
	@sleep 60
	@aws eks --region $(AWS_REGION) update-kubeconfig --name $(EKS_CLUSTER_NAME)
	@kubectl get nodes


.PHONY: docker-login
docker-login:
	@echo $(DOCKER_PASSWORD) | docker login --username $(DOCKER_REPO) --password-stdin

.PHONY: update-skaffold-manifest
update-skaffold-manifest:
	@echo '🏗️ Updating skaffold manifest file'
	@yq e -i '.build.artifacts[0].image = "student-api-$(ENV)"' skaffold.yaml
	@yq e -i '.build.artifacts[1].image = "teacher-api-$(ENV)"' skaffold.yaml
	@yq e -i '.build.artifacts[2].image = "admin-api-$(ENV)"' skaffold.yaml
	@yq e -i '.build.artifacts[3].image = "web-$(ENV)"' skaffold.yaml

.PHONY: skaffold-build
skaffold-build:
	@echo "🏗️ Build the docker containers for $(ENV) environment"
	@skaffold build --platform linux/amd64 \
					--default-repo=$(DOCKER_REPO) \
					--push --cache-artifacts=false \
					--tag $(VERSION)-$(TAG)

.PHONY: setup-envs
setup-envs:
	@echo "🏗️ Setting Up the .env file"
	@echo ENV=$(ENV) > backend/src/.env;
	@echo SECRET_KEY=$(SECRET_KEY) >> backend/src/.env;
	@echo JWT_ALGORITHM=$(JWT_ALGORITHM) >> backend/src/.env;
	@echo POSTGRES_USER=$(POSTGRES_USER) >> backend/src/.env;
	@echo POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) >> backend/src/.env;
	@echo POSTGRES_SERVER=$(POSTGRES_SERVER) >> backend/src/.env;
	@echo POSTGRES_PORT=$(POSTGRES_PORT) >> backend/src/.env;
	@echo ADMIN_DB=$(ADMIN_DB) >> backend/src/.env;
	@echo STUDENT_DB=$(STUDENT_DB) >> backend/src/.env;
	@echo TEACHER_DB=$(TEACHER_DB) >> backend/src/.env
	@echo REACT_APP_ADMIN_URL=$(REACT_APP_ADMIN_URL) >> frontend/.env
	@echo REACT_APP_STUDENT_URL=$(REACT_APP_STUDENT_URL) >> frontend/.env
	@echo REACT_APP_TEACHER_URL=$(REACT_APP_TEACHER_URL) >> frontend/.env

.PHONY: update-chart-values
update-chart-values:
	@echo '🏗️ Updating chart values manifest file'
	@yq e -i '.api.admin.container.image = "$(DOCKER_REPO)/admin-api-$(ENV)"' app-chart/$(ENV)-values.yaml
	@yq e -i '.api.admin.container.tag = "$(VERSION)-$(TAG)"' app-chart/$(ENV)-values.yaml
	@yq e -i '.api.student.container.image = "$(DOCKER_REPO)/student-api-$(ENV)"' app-chart/$(ENV)-values.yaml
	@yq e -i '.api.student.container.tag = "$(VERSION)-$(TAG)"' app-chart/$(ENV)-values.yaml
	@yq e -i '.api.teacher.container.image = "$(DOCKER_REPO)/teacher-api-$(ENV)"' app-chart/$(ENV)-values.yaml
	@yq e -i '.api.teacher.container.tag = "$(VERSION)-$(TAG)"' app-chart/$(ENV)-values.yaml
	@yq e -i '.web.container.image = "$(DOCKER_REPO)/web-$(ENV)"' app-chart/$(ENV)-values.yaml
	@yq e -i '.web.container.tag = "$(VERSION)-$(TAG)"' app-chart/$(ENV)-values.yaml

.PHONY: deploy-app
deploy-app:
	@until kubectl get crd -n argocd >/dev/null 2>&1; do \
        echo "Waiting for ArgoCD CRDs to be available..."; \
        sleep 10; \
    done
	@echo "ArgoCD CRDs are available."
	@echo '🏗️ Deploying Application'
	@kubectl apply -f app-deployment/$(ENV)-deploy.yaml

.PHONY: configure-app-tls 
configure-app-tls:
	@echo '🏗️ Installing Nginx Ingress TLS secret'
	@kubectl create secret tls app-server-tls --cert=$(CERT_FILE) --key=$(KEY_FILE) --namespace=school-app -o yaml | kubectl apply -f -