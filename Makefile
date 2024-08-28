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

get-deployment.zip:
	wget https://github.com/NASA-AMMOS/aerie/releases/download/v2.18.0/Deployment.zip && \
	unzip ./Deployment.zip && \
	tar xvf ./deployment.tar

get-docker-compose: clean
	curl https://raw.githubusercontent.com/NASA-AMMOS/aerie-mission-model-template/main/docker-compose.yml --output docker-compose.yml

# curl https://raw.githubusercontent.com/NASA-AMMOS/aerie-mission-model-template/main/docker-compose.yml --output docker-compose.yml

# kubectl config use-context docker-desktop
# kubectl create namespace aerie-dev
# kubectl apply -f .
# kubectl get pods -n aerie-dev
# kubectl delete namespace aerie-dev

kompose-convert: installs clean get-docker-compose ## convert docker-compose to kompose
	mkdir -p kompose-output/ && \
	cd ./kompose-output && \
	kompose convert -f ../docker-compose.yml

clean:
	rm -f ./docker-compose.yml ./kompose-output/*.y*l

references:
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