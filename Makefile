.DEFAULT_GOAL := help

.PHONY: mysql-wordpress-example-1

export SHELL=/bin/bash
export TZ=:UTC

directories:
	mkdir -p ./config

# https://nasa-ammos.github.io/aerie-docs/introduction/#fast-track

installs:
	brew install kompose
	brew install kustomize
	brew install txn2/tap/kubefwd

get-deployment.zip:
	wget https://github.com/NASA-AMMOS/aerie/releases/download/v2.18.0/Deployment.zip && \
	unzip ./Deployment.zip && \
	tar xvf ./deployment.tar

get-docker-compose:
	curl https://raw.githubusercontent.com/NASA-AMMOS/aerie-mission-model-template/main/docker-compose.yml --output docker-compose.yml

aerie-up: | get-docker-compose aerie-down ## aerie up
	docker compose down
	source .env && docker compose up 

aerie-down: ## aerie down
	docker compose down

# curl https://raw.githubusercontent.com/NASA-AMMOS/aerie-mission-model-template/main/docker-compose.yml --output docker-compose.yml

# kubectl delete namespace aerie-dev
# kubectl config use-context docker-desktop
# kubectl create namespace aerie-dev
# kubectl apply -f .
# kubectl get pods -n aerie-dev
# kubectl delete namespace aerie-dev
# kubectl delete --all pods --namespace=default # this actually restarts!
# kubectl delete -n default deployment nginx-deployment 

# kubectl get nodes
# kubectl create namespace nginx-deployment
# kubectl apply -f ./nginx-deployment.yaml
# kubectl get pods -n nginx-deployment
# kubectl delete namespace nginx-deployment


postgres-secret:
	kubectl delete namespace postgresql
	kubectl create namespace postgresql
	kubectl create secret generic postgresql-secret --namespace postgresql --from-literal=POSTGRES_DB=postgres --from-literal=POSTGRES_USER=postgres --from-literal=POSTGRES_PASSWORD=pass --dry-run=client -o yaml > ./workspace/postgres/postgresql-secret.yml
	kubectl get secrets -n postgresql

aerie-postgres-recreate:
	@export namespace=aerie-dev && \
	make kubectl-delete-namespace-$${namespace} || true && \
	make kubectl-create-namespace-$${namespace} && \
	kubectl apply -f./workspace/examples/aerie/postgres-data-persistentvolumeclaim.yaml && \
	kubectl apply -f./workspace/examples/aerie/postgres-deployment.yaml && \
	kubectl apply -f./workspace/examples/aerie/postgres-service.yaml && \
	echo && echo psql -h postgres -U postgres && echo && \
	sudo kubefwd svc -n $${namespace} -m 5432:5432

nginx-example-1: ## nginx-example-1
	@echo && echo running target $@
	@make kubectl-delete-namespace-$@ || true && \
	make kubectl-create-namespace-$@ && \
	kubectl apply -f ./workspace/examples/$@/$@.yaml -n $@ && \
	kubectl get pods -n $@ && \
	echo && echo open http://nginx && echo && \
	sudo kubefwd svc -n $@ -m 80:80

postgres-example-1: ## postgres-example-1
	@echo && echo running target $@
	@export namespace=$@ && \
	make kubectl-delete-namespace-$@ || true && \
	make kubectl-create-namespace-$@ && \
	kubectl apply -f ./workspace/examples/$@/$@.yaml -n $@ && \
	kubectl get pods -n $@ && \
	sudo kubefwd svc -n $@ -m 5432:5432

# nginx-example-2: ## nginx-example-2 (does not work)
# 	@echo source: https://medium.com/@muppedaanvesh/deploying-nginx-on-kubernetes-a-quick-guide-04d533414967
# 	@export namespace=$@ && \
# 	make kubectl-delete-namespace-$${namespace} || true && \
# 	make kubectl-create-namespace-$${namespace} && \
# 	kubectl run nginx-pod --image=nginx:1.14.2 --restart=Never --port=80 -n $${namespace}
# 	sudo kubefwd svc -n $${namespace} -m 80:80

# curl --silent -L https://k8s.io/examples/application/wordpress/mysql-deployment.yaml --output ./workspace/examples/$@/mysql-deployment.yaml && \
# curl --silent -L https://k8s.io/examples/application/wordpress/wordpress-deployment.yaml --output ./workspace/examples/$@/wordpress-deployment.yaml && \

#	mkdir -p ./workspace/examples/mysql-wordpress-persistent-volume/ && \

#	@echo && echo source: https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/ && echo

mysql-wordpress-example-1: ## kubectl apply -k ./workspace/examples/mysql-wordpress-example-1/ -n mysql-wordpress-example-1
	@echo && echo "[INFO] Attempting to create namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$@]" && \
	make kubectl-use-context K8S_CONTEXT=${K8S_CONTEXT} && \
	make kubectl-delete-namespace-$@ || true && \
	make kubectl-create-namespace-$@ && \
	kubectl apply -k ./workspace/examples/$@/ -n $@
	sudo kubefwd svc -n $@ -m 80:80

mysql-wordpress-example-2:
	@echo && echo "[INFO] Attempting to create namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$@]" && \
	make kubectl-use-context K8S_CONTEXT=${K8S_CONTEXT} && \
	kubectl apply -k ./workspace/examples/mysql-wordpress-example-1/ -n default

# make kubectl-delete-deployment-default K8S_DEPLOYMENT=wordpress
# make kubectl-delete-deployment-default K8S_DEPLOYMENT=wordpress-mysql

# make kubectl-get-secrets-default && \
# make kubectl-get-pvc-default && \
# kubectl get pods

# kubectl apply -k ./workspace/examples/mysql-wordpress-persistent-volume/ && \
# && \
#	kubectl expose pod nginx-pod --type=NodePort --port=80 --name=$${namespace}

# kubectl get svc

# kubectl targets
K8S_CONTEXT=docker-desktop
K8S_CONTEXT_TODELETE=null

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

kubectl-create-namespace-%: ## kubectl create namespace %
	@echo && echo "[INFO] Attempting to create namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$*]"
	kubectl create namespace $*

kubectl-delete-namespace-%: ## kubectl delete namespace %
	@echo && echo "[INFO] Attempting to delete namespace k8s:context:[${K8S_CONTEXT}]:namespace:[$*]"
	@kubectl delete namespace $*

K8S_DEPLOYMENT=null

kubectl-get-deployments: ## kubectl get deployment
	@make kubectl-use-context K8S_CONTEXT=${K8S_CONTEXT} && \
	kubectl get deployment

kubectl-delete-deployment-%: ## kubectl delete -n $* deployment ${K8S_DEPLOYMENT}
	kubectl delete -n $* deployment ${K8S_DEPLOYMENT}

kubectl-get-secrets-%: ## kubectl get secrets -n %
	@echo && kubectl get secrets -n $*

kubectl-get-pvc-%: ## kubectl get pvc --namespace %
	@echo && kubectl get pvc --namespace $*

kubectl-get-pods-%:
	kubectl get pods -n $*

K8S_K=./workspace/examples/mysql-wordpress-persistent-volume/
kubectl-apply-k:
	kubectl apply -k ${KPATH}

K8S_POD=nginx=pod
K8S_POD_PORT=80
kubectl-expose-pod-%: ## kubectl expose pod ${K8S_POD} --type=NodePort --port=${K8S_POD_PORT} --name=$${namespace}
	@export namespace=$@ && \
	kubectl expose pod ${K8S_POD} --type=NodePort --port=${K8S_POD_PORT} --name=$${namespace}

aerie-kubefwd: installs
	sudo kubefwd svc -n aerie-dev -m 5432:5432

# kubectl run dnsutils --image=registry.k8s.io/coredns/coredns:v1.11.1 --rm -ti
# kubectl logs --namespace=kube-system -l k8s-app=kube-dns
# kubectl get pods --namespace=kube-system -l k8s-app=kube-dns
# kubectl get svc --namespace=kube-system
# kubectl get endpoints kube-dns --namespace=kube-system
# kubectl -n kube-system edit configmap coredns

# --rm -ti

#--image=postgres:latest --rm -ti
#	kubectl get pods -n aerie-dev

# kubectl create -f configs/postgresql-secret.yml
# kubectl create -f configs/postgresql-pv.yml
# kubectl create -f configs/postgresql-pvc.yml
# kubectl create -f deployment/postgresql-deployment.yml
# kubectl create -f service/postgresql-svc.yml

kompose-convert: installs clean get-docker-compose ## convert docker-compose to kompose
	mkdir -p kompose-output/ && \
	cd ./kompose-output && \
	kompose convert -f ../docker-compose.yml

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