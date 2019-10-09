.DEFAULT_GOAL := help

DEPLOYMENT ?= multi

NODE_IP := `nixops info --deployment $(DEPLOYMENT) --no-eval --plain | grep -Po '\d+.\d+.\d+\.\d+' | head -n 1`

NOMAD_URL := http://$(NODE_IP):4646
JOBS := $(shell find jobs -type f -name '*.nomad')


.PHONY: up down tunnel deploy all upfs
all: up upfs workload ## set the whole thing up

up: ## create the environement
	nixops deploy --deployment $(DEPLOYMENT) --allow-reboot
	sleep 10 # don't fucking ask...
	nixops deploy --deployment $(DEPLOYMENT) --allow-reboot
	./isoltate-mutli-user-target # ensure congruent deployment

upfs: ## setup main gluster volume
	./setup-glusterfs-cluster
	./mount-glusterfs

deploy: ## apply changes
	nixops deploy --deployment $(DEPLOYMENT)
	./isoltate-mutli-user-target # ensure congruent deployment

down: ## destroy the environment
	nixops destroy --deployment $(DEPLOYMENT)

.PHONY: $(JOBS) workload
workload: $(JOBS) ## apply latest jobs configuration

$(JOBS):
	nomad job run -address=$(NOMAD_URL) $@

tunnel: ## setup local port forwarding for Consul UI
	ssh root@$(NODE_IP) -L :8500:localhost:8500 -T

.PHONY: restart-nomad
restart-nomad: ## restart nomad service on all hosts
	nixops ssh-for-each -p systemctl restart nomad-server.service
	sleep 3
	nixops ssh-for-each -p systemctl restart nomad-client.service


.PHONY: help
help: ## print this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
