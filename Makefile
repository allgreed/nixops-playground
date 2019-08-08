.DEFAULT_GOAL := help

NOMAD_ADDR := 165.22.94.177#TODO: dehardcode it
NOMAD_URL := http://$(NOMAD_ADDR):4646

JOBS := $(shell find jobs -type f -name '*.nomad')

.PHONY: up down
up: ## ble

down: ##  ble ble
	
.PHONY: $(JOBS) workload
workload: $(JOBS) ## apply latest jobs configuration

$(JOBS):
	nomad job run -address=$(NOMAD_URL) $@

.PHONY: help
help: ## print this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
