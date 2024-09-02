.DEFAULT_GOAL := help

.PHONY:

export SHELL=/bin/bash
export TZ=:UTC

directories:
	mkdir -p ./config

installs:
	brew install kompose
	brew install kustomize
#	brew install krew (krew is not support on macosx darwin/arm64)
	brew install txn2/tap/kubefwd

get-deployment.zip:
	wget https://github.com/NASA-AMMOS/aerie/releases/download/v2.18.0/Deployment.zip && \
	unzip ./Deployment.zip && \
	tar xvf ./deployment.tar

get-docker-compose:
	curl https://raw.githubusercontent.com/NASA-AMMOS/aerie-mission-model-template/main/docker-compose.yml --output docker-compose.yml

aerie-up: | get-docker-compose aerie-down ## aerie up
	@echo source: https://nasa-ammos.github.io/aerie-docs/introduction/#fast-track
	docker compose down
	source .env && docker compose up 

aerie-down: ## aerie down
	docker compose down

#------------------------------------------------------------------------------
# Examples
#------------------------------------------------------------------------------
aerie-dev: ## (kubefwd) kubectl apply -f./workspace/examples/aerie-dev
	@echo && echo "[INFO] Attempting to create namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$@]" && \
	make kubectl-use-context K8S_CONTEXT=${K8S_CONTEXT} && \
	make kubectl-delete-namespace-$@ || true && \
	make kubectl-create-namespace-$@ && \
	kubectl apply -f./workspace/examples/$@/postgres-data-persistentvolumeclaim.yaml && \
	kubectl apply -f./workspace/examples/$@/postgres-deployment.yaml && \
	kubectl apply -f./workspace/examples/$@/postgres-service.yaml && \
	echo && echo use: psql -h postgres -U postgres && echo && \
	sudo kubefwd svc -n $@ -m 5432:5432

grafana-example-1: ## (kubefwd) kubectl apply -k ./workspace/examples/grafana-example-1/ -n grafana-example-1
	@echo source https://grafana.com/docs/grafana/latest/setup-grafana/installation/kubernetes/
	@make kubectl-use-context K8S_CONTEXT=${K8S_CONTEXT} && \
	echo && echo "[INFO] Attempting to create namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$@]" && \
	make kubectl-delete-namespace-$@ || true && \
	make kubectl-create-namespace-$@ && \
	kubectl apply -f ./workspace/examples/$@/ -n $@
	echo && echo "use: http://grafana:3000/ (because kubefwd was)" && echo && \
	sudo kubefwd svc -n $@ -m 80:80

grafana-example-2: ## (port-forward) kubectl apply -k ./workspace/examples/grafana-example-1/ -n grafana-example-2
	@echo source https://grafana.com/docs/grafana/latest/setup-grafana/installation/kubernetes/
	@make kubectl-use-context K8S_CONTEXT=${K8S_CONTEXT} && \
	echo && echo "[INFO] Attempting to create namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$@]" && \
	make kubectl-delete-namespace-$@ || true && \
	make kubectl-create-namespace-$@ && \
	kubectl apply -f ./workspace/examples/grafana-example-1/ -n $@
	echo && echo "use: http://localhost:3000/ (because port-forward was used)" && echo && \
	sleep 5
	kubectl port-forward service/grafana 3000:3000 --namespace=$@

mysql-wordpress-example-1: ## (kubefwd) kubectl apply -k ./workspace/examples/mysql-wordpress-example-1/ -n mysql-wordpress-example-1
	@echo && echo source: https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/
	@make kubectl-use-context K8S_CONTEXT=${K8S_CONTEXT} && \
	echo && echo "[INFO] Attempting to create namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$@]" && \
	kubectl delete -k ./workspace/examples/$@/ -n $@ || true && \
	make kubectl-delete-namespace-$@ || true && \
	make kubectl-create-namespace-$@ && \
	kubectl apply -k ./workspace/examples/$@/ -n $@ && \
	echo && echo "use: http://wordpress:80/ (because kubefwd was used)" && echo
	sudo kubefwd svc -n $@ -m 80:80

nginx-example-1: ## nginx-example-1
	@make kubectl-use-context K8S_CONTEXT=${K8S_CONTEXT} && \
	echo && echo "[INFO] Attempting to create namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$@]" && \
	make kubectl-delete-namespace-$@ || true && \
	make kubectl-create-namespace-$@ && \
	kubectl apply -f ./workspace/examples/$@/$@.yaml -n $@ && \
	echo && echo "use: http://nginx:80/ (because port-forward was used)" && echo && \
	sudo kubefwd svc -n $@ -m 80:80

postgres-example-1: ## postgres-example-1
	@make kubectl-use-context K8S_CONTEXT=${K8S_CONTEXT} && \
	echo && echo "[INFO] Attempting to create namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$@]" && \
	make kubectl-delete-namespace-$@ || true && \
	make kubectl-create-namespace-$@ && \
	kubectl apply -f ./workspace/examples/$@/$@.yaml -n $@ && \
	echo && echo "use: psql -h postgres -U postgres (because kubefwd was used)" && echo
	sudo kubefwd svc -n $@ -m 5432:5432

postgres-secret:
	kubectl delete namespace postgresql
	kubectl create namespace postgresql
	kubectl create secret generic postgresql-secret --namespace postgresql --from-literal=POSTGRES_DB=postgres --from-literal=POSTGRES_USER=postgres --from-literal=POSTGRES_PASSWORD=pass --dry-run=client -o yaml > ./workspace/postgres/postgresql-secret.yml
	kubectl get secrets -n postgresql

#------------------------------------------------------------------------------
# kubectl targets
#------------------------------------------------------------------------------
K8S_CONTEXT=docker-desktop
K8S_CONTEXT_TODELETE=null
K8S_DEPLOYMENT=null

kubectl-get-contexts: ## kubectl get contexts
	@echo && kubectl config get-contexts

kubectl-use-context: ## kubectl use-context K8S_CONTEXT=<default=docker-desktop>
	@echo && echo "[INFO] Attempting to use-context k8s:context:[${K8S_CONTEXT}]"
	@kubectl config use-context ${K8S_CONTEXT}

kubectl-delete-context: ## kubectl config delete-context K8S_CONTEXT_TODELETE=<default=null>
	@echo && echo "[INFO] Attempting to delete context k8s:context:[${K8S_CONTEXT_TODELETE}]"
	@kubectl config delete-context ${K8S_CONTEXT_TODELETE} || true

kubectl-cluster-info: ## kubectl cluster-info
	@echo && kubectl cluster-info

kubectl-get-nodes: kubectl-use-context ## kubectl get nodes
	@echo && kubectl get nodes

kubectl-get-namespaces: kubectl-use-context ## kubectl get namespaces
	@echo && kubectl get namespaces

kubectl-get-secrets-%: ## kubectl get secrets -n %
	@echo && kubectl get secrets -n $*

kubectl-get-pvc-%: ## kubectl get pvc --namespace %
	@echo && kubectl get pvc --namespace $*

kubectl-get-pods-%: ## kubectl get pods --namespace %
	kubectl get pods -n $*

kubectl-create-namespace-%: ## kubectl create namespace %
	@echo && echo "[INFO] Attempting to create namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$*]"
	kubectl create namespace $*

kubectl-delete-namespace-%: ## kubectl delete namespace %
	@echo && echo "[INFO] Attempting to delete namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$*]"
	@kubectl delete namespace $*

kubectl-get-deployments: ## kubectl get deployment
	@make kubectl-use-context K8S_CONTEXT=${K8S_CONTEXT} && \
	kubectl get deployment

kubectl-delete-deployment-%: ## kubectl delete -n $* deployment ${K8S_DEPLOYMENT}
	kubectl delete -n $* deployment ${K8S_DEPLOYMENT}

kompose-convert: installs clean get-docker-compose ## convert docker-compose to kompose
	mkdir -p kompose-output/ && \
	cd ./kompose-output && \
	kompose convert -f ../docker-compose.yml

test-kubernetes:

clean-kubernetes: ## delete k8s namespaces (of course NOT default)
	make kubectl-delete-namespace-aerie-dev || true
	make kubectl-delete-namespace-grafana-example-1 || true
	make kubectl-delete-namespace-grafana-example-2 || true
	make kubectl-delete-namespace-mysql-wordpress-example-1 || true
	make kubectl-delete-namespace-nginx-example-1 || true
	make kubectl-delete-namespace-postgres-example-1 || true

clean-docker:

clean:
	rm -f ./docker-compose.yml ./kompose-output/*.y*l

references:
	@echo https://github.com/txn2/kubefwd/blob/master/README.md
	@echo https://www.linkedin.com/pulse/running-postgresql-docker-container-kubernetes-persistent-pudi-n2xue/
	@echo https://nasa-ammos.github.io/aerie-docs/introduction/#fast-track
	@echo https://nasa-ammos.github.io/aerie-docs/planning/upload-mission-model/ 
	@echo https://fluxcd.io/flux/components/kustomize/kustomizations/
	@echo https://nasa-ammos.github.io/aerie-docs/introduction/#fast-track 
	@echo https://github.com/NASA-AMMOS/aerie/tree/develop/deployment
	@echo https://github.com/NASA-AMMOS/aerie/releases

print-%:
	@echo $*=$($*)

export MAKEFILE_LIST=Makefile

help:
	@printf "\033[37m%-30s\033[0m %s\n" "#----------------------------------------------------------------------------------"
	@printf "\033[37m%-30s\033[0m %s\n" "# Makefile targets                                                                 |"
	@printf "\033[37m%-30s\033[0m %s\n" "#----------------------------------------------------------------------------------"
	@printf "\033[37m%-30s\033[0m %s\n" "#-target-----------------------description-----------------------------------------"
	@grep -E '^[a-zA-Z_-].+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# WARN The "MERLIN_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "SCHEDULER_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "POSTGRES_USER" variable is not set. Defaulting to a blank string. 
# WARN The "AERIE_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "SCHEDULER_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "AERIE_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "GATEWAY_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "SEQUENCING_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "SEQUENCING_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "GATEWAY_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "MERLIN_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "POSTGRES_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "REPOSITORY_DOCKER_URL" variable is not set. Defaulting to a blank string. 
# WARN The "DOCKER_TAG" variable is not set. Defaulting to a blank string. 
# WARN The "MERLIN_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "MERLIN_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "REPOSITORY_DOCKER_URL" variable is not set. Defaulting to a blank string. 
# WARN The "DOCKER_TAG" variable is not set. Defaulting to a blank string. 
# WARN The "REPOSITORY_DOCKER_URL" variable is not set. Defaulting to a blank string. 
# WARN The "DOCKER_TAG" variable is not set. Defaulting to a blank string. 
# WARN The "SCHEDULER_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "SCHEDULER_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "HASURA_GRAPHQL_ADMIN_SECRET" variable is not set. Defaulting to a blank string. 
# WARN The "SEQUENCING_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "HASURA_GRAPHQL_ADMIN_SECRET" variable is not set. Defaulting to a blank string. 
# WARN The "SEQUENCING_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "REPOSITORY_DOCKER_URL" variable is not set. Defaulting to a blank string. 
# WARN The "DOCKER_TAG" variable is not set. Defaulting to a blank string. 
# WARN The "AERIE_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "AERIE_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "HASURA_GRAPHQL_ADMIN_SECRET" variable is not set. Defaulting to a blank string. 
# WARN The "HASURA_GRAPHQL_JWT_SECRET" variable is not set. Defaulting to a blank string. 
# WARN The "AERIE_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "AERIE_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "REPOSITORY_DOCKER_URL" variable is not set. Defaulting to a blank string. 
# WARN The "DOCKER_TAG" variable is not set. Defaulting to a blank string. 
# WARN The "GATEWAY_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "GATEWAY_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "HASURA_GRAPHQL_JWT_SECRET" variable is not set. Defaulting to a blank string. 
# WARN The "REPOSITORY_DOCKER_URL" variable is not set. Defaulting to a blank string. 
# WARN The "DOCKER_TAG" variable is not set. Defaulting to a blank string. 
# WARN The "HASURA_GRAPHQL_ADMIN_SECRET" variable is not set. Defaulting to a blank string. 
# WARN The "MERLIN_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "MERLIN_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "REPOSITORY_DOCKER_URL" variable is not set. Defaulting to a blank string. 
# WARN The "DOCKER_TAG" variable is not set. Defaulting to a blank string. 
# WARN The "SCHEDULER_USERNAME" variable is not set. Defaulting to a blank string. 
# WARN The "SCHEDULER_PASSWORD" variable is not set. Defaulting to a blank string. 
# WARN The "HASURA_GRAPHQL_ADMIN_SECRET" variable is not set. Defaulting to a blank string. 
# WARN The "REPOSITORY_DOCKER_URL" variable is not set. Defaulting to a blank string. 
# WARN The "DOCKER_TAG" variable is not set. Defaulting to a blank string. 
# WARN The "REPOSITORY_DOCKER_URL" variable is not set. Defaulting to a blank string. 
# WARN The "DOCKER_TAG" variable is not set. Defaulting to a blank string. 