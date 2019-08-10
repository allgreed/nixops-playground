.DEFAULT_GOAL := help

NODE_IP := `nixops info -d single --no-eval --plain | grep -Po '\d+.\d+.\d+\.\d+' | head -n 1`
DEPLOYMENT ?= single

NOMAD_URL := http://$(NODE_IP):4646
JOBS := $(shell find jobs -type f -name '*.nomad')


.PHONY: up down tunnel deploy
up: ## create the environement
	nixops deploy -d $(DEPLOYMENT) --allow-reboot
	./isoltate-mutli-user-target # ensure congreunt deployment

deploy: ## apply changes
	nixops deploy -d $(DEPLOYMENT)
	./isoltate-mutli-user-target # ensure congreunt deployment

down: ## destroy the environment
	nixops destroy -d $(DEPLOYMENT)

tunnel: ## setup local port forwarding for Consul UI
	ssh root@$(NODE_IP) -L :8500:localhost:8500 -T
	

.PHONY: $(JOBS) workload
workload: $(JOBS) ## apply latest jobs configuration

$(JOBS):
	nomad job run -address=$(NOMAD_URL) $@


.PHONY: help
help: ## print this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
