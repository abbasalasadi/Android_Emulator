SHELL := /usr/bin/env bash

# -----------------------
# Config (edit if needed)
# -----------------------
INSTANCE ?= A
AVD ?=
DEFAULT_PORT ?=
EMULATOR_PORT ?=
GPU ?= swiftshader_indirect

SCRIPTS := scripts
ENV_SH := $(SCRIPTS)/env.sh

.PHONY: help doctor run start stop list-avds port show-url icon

help: ## Show available commands and variables
	@echo ""
	@echo "Android Emulator Kit (reusable for audits)"
	@echo ""
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
	@echo ""
	@echo "Variables: INSTANCE=$(INSTANCE) AVD=$(AVD) DEFAULT_PORT=$(DEFAULT_PORT) EMULATOR_PORT=$(EMULATOR_PORT) GPU=$(GPU)"
	@echo ""

doctor: ## Show tool and AVD status
	@test -f "$(ENV_SH)" || (echo "Missing $(ENV_SH). Create env.sh first." && exit 1)
	@source "$(ENV_SH)" && ./scripts/doctor.sh

list-avds: ## List available AVDs
	@test -f "$(ENV_SH)" || (echo "Missing $(ENV_SH). Create env.sh first." && exit 1)
	@source "$(ENV_SH)" && emulator -list-avds

start: ## Start emulator directly using INSTANCE or explicit AVD/EMULATOR_PORT
	@test -f "$(ENV_SH)" || (echo "Missing $(ENV_SH). Create env.sh first." && exit 1)
	@source "$(ENV_SH)" && INSTANCE="$(INSTANCE)" AVD="$(AVD)" EMULATOR_PORT="$(EMULATOR_PORT)" GPU="$(GPU)" ./scripts/run_with_port.sh

stop: ## Stop all running emulators
	@test -f "$(ENV_SH)" || (echo "Missing $(ENV_SH). Create env.sh first." && exit 1)
	@source "$(ENV_SH)" && ./scripts/stop_emulators.sh

run: ## Open the launcher popup, choose instance/backend port, then start that emulator
	@test -f "$(ENV_SH)" || (echo "Missing $(ENV_SH). Create env.sh first." && exit 1)
	@source "$(ENV_SH)" && INSTANCE="$(INSTANCE)" AVD="$(AVD)" DEFAULT_PORT="$(DEFAULT_PORT)" EMULATOR_PORT="$(EMULATOR_PORT)" GPU="$(GPU)" ./scripts/run_with_port.sh

port: ## Print saved backend port for INSTANCE (falls back to legacy file)
	@instance_key="$$(printf '%s' '$(INSTANCE)' | tr '[:upper:]' '[:lower:]')"; \
	file="./var/instances/$${instance_key}/last_port"; \
	if [[ -f "$$file" ]]; then cat "$$file"; elif [[ -f ./last_port ]]; then cat ./last_port; else echo "unset"; fi

show-url: ## Print backend URL for INSTANCE based on the saved port
	@PORT="$$( $(MAKE) --no-print-directory port INSTANCE=$(INSTANCE) )"; echo "http://10.0.2.2:$${PORT}"

icon: ## Create or update the Desktop icon launcher for the emulator kit
	@./scripts/create_desktop_icon.sh
