.DEFAULT_GOAL := help

NOMAD_ADDR := 167.71.44.161#TODO: dehardcode it
NOMAD_URL := http://$(NOMAD_ADDR):4646
JOBS := $(shell find jobs -type f -name '*.nomad')

.PHONY: all init
all: provision clean workload ## apply latest configuration (machine + jobs)
	
init: bootstrap all
	

.PHONY: bootstrap provision jobs
bootstrap: ## run initial configuration (once per new machine)
	ansible-playbook --inventory=inventory --ask-pass bootstrap.yml --user=root
provision: galaxy_roles ## apply latest machine configuration
	ansible-playbook --inventory=inventory --ask-become-pass playbook.yml

.PHONY: $(JOBS)
workload: $(JOBS) ## apply latest jobs configuration

$(JOBS):
	nomad job run -address=$(NOMAD_URL) $@

galaxy_roles: requirements.yml
	ansible-galaxy install --force -r requirements.yml --roles-path galaxy_roles

.PHONY: clean
clean:
	rm *.retry

.PHONY: help
help: ## print this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
