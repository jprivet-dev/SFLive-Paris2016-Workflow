DC = docker-compose
EXEC_PHP = $(DC) exec php-fpm
PHP = $(EXEC_PHP) php
SF = $(PHP) bin/console
C = $(EXEC_PHP) composer

.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-.]+[^:]+:.*##.*?$$)|(^##)' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = "## "}; \
		{ \
			split($$1, command, ":"); \
			target=command[1]; \
			description=$$2; \
			if (target && target!="##")\
				printf "\033[32m%-25s \033[0m%s\n", target, description; \
			else \
				printf "\033[33m%s\n", description; \
		}'
.PHONY: help

##
## ENVIRONMENT VARIABLES
## ---------------------
##

.env: .env.dist ## Check `.env` existence & copy `.env.dist` if `.env` not exists
	@if [ -f .env ]; \
	then\
		echo -e '\033[1;41m/!\ The .env.dist file has changed. Please check your .env file (this message will not be displayed again).\033[0m';\
		touch .env;\
		exit 1;\
	else\
		echo cp .env.dist .env;\
		cp .env.dist .env;\
	fi

##
## PROJECT
## -------
##

install: .env vendor db ## Install all the project
.PHONY: install

vendor: composer.lock ## Composer install
	$(C) install
.PHONY: vendor

db: ## Update schema
	$(SF) doctrine:schema:update --force
.PHONY: db

db_clean: ## Drop & Create DB
	$(SF) doctrine:database:drop --if-exists --force
	$(SF) doctrine:database:create --if-not-exists
.PHONY: db_clean

clean: kill ## Stop the project and remove generated files
	rm -rf .env
.PHONY: clean

##
## SYMFONY
## -------
##

cc: ## Clear current env cache
	$(SF) cache:clear
.PHONY: cc

ccp: ## Clear prod cache
	$(SF) cache:clear --env=prod
.PHONY: ccp

##
## SYMFONY WORKFLOW
## -------
##

graph: ## Generate Graphviz image
	$(SF) workflow:build:svg state_machine.task
	$(SF) workflow:build:svg workflow.article
.PHONY: graph

##
## DOCKER
## ------
##

build: .env ## Services are built once and then tagged
	$(DC) build
.PHONY: build

start: .env ## Builds, (re)creates, starts, and attaches to containers for a service
	$(DC) up -d --remove-orphans
.PHONY: start

stop: ## Stops running containers without removing them
	$(DC) stop
.PHONY: stop

kill: ## Forces running containers to stop and removes containers, networks, volumes, and images created by up
	$(DC) kill
	$(DC) down --volumes --remove-orphans
.PHONY: kill

phpbash: ## Open PHP Docker bash
	$(EXEC_PHP) bash
.PHONY: phpbash

rm_containers: ## Remove all containers
	docker rm -f $$(docker ps -a -q)
.PHONY: rm_containers

rm_images: ## Remove all images
	docker rmi -f $$(docker images -q)
.PHONY: rm_images


