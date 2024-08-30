.DEFAULT_GOAL := help

.PHONY:

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
#	export POSTGRES_USER=postgres && export POSTGRES_PASSWORD=postgres
	kubectl delete namespace aerie-dev || true
	kubectl create namespace aerie-dev && \
	kubectl apply -f./workspace/postgres/postgres-data-persistentvolumeclaim.yaml
	kubectl apply -f./workspace/postgres/postgres-deployment.yaml
	kubectl apply -f./workspace/postgres/postgres-service.yaml
	kubectl expose pod postgres --namespace aerie-dev
	kubectl run dnsutils --namespace aerie-dev --image=registry.k8s.io/coredns/coredns:v1.11.1

aerie-dev-kubefwd: installs
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