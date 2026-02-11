SHELL := /usr/bin/env bash

# -----------------------
# Config (edit if needed)
# -----------------------
AVD ?= pixel_api34
DEFAULT_PORT ?= 5001
GPU ?= swiftshader_indirect

SCRIPTS := scripts
ENV_SH := $(SCRIPTS)/env.sh

.PHONY: help doctor run start stop list-avds port show-url icon

help: 
	@echo ""
	@echo "Android Emulator Kit (reusable for audits)"
	@echo ""
	@echo "Usage:"
	@echo "  make <target> [AVD=...] [DEFAULT_PORT=...] [GPU=...]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS=":.*##"} \
		/^[a-zA-Z0-9_.-]+:.*##/ { \
			printf "  %-18s %s\n", $$1, $$2 \
		}' $(MAKEFILE_LIST) | sort
	@echo ""
	@echo "Variables:"
	@echo "  AVD=$(AVD) DEFAULT_PORT=$(DEFAULT_PORT) GPU=$(GPU)"
	@echo ""

doctor: ## Show tool + AVD status (doctor)
	@test -f "$(ENV_SH)" || (echo "Missing $(ENV_SH). Create env.sh first." && exit 1)
	@source "$(ENV_SH)" && ./scripts/doctor.sh

list-avds: ## List available AVDs
	@test -f "$(ENV_SH)" || (echo "Missing $(ENV_SH). Create env.sh first." && exit 1)
	@source "$(ENV_SH)" && emulator -list-avds

start: ## Start emulator (uses AVD=$(AVD), GPU=$(GPU))
	@test -f "$(ENV_SH)" || (echo "Missing $(ENV_SH). Create env.sh first." && exit 1)
	@source "$(ENV_SH)" && ./scripts/start_emulator.sh "$(AVD)" "$(GPU)"

stop: ## Stop all running emulators
	@test -f "$(ENV_SH)" || (echo "Missing $(ENV_SH). Create env.sh first." && exit 1)
	@source "$(ENV_SH)" && ./scripts/stop_emulators.sh

run: ## Prompt for PORT (GUI if zenity) then start emulator; saves last_port + audit_env.sh
	@test -f "$(ENV_SH)" || (echo "Missing $(ENV_SH). Create env.sh first." && exit 1)
	@source "$(ENV_SH)" && AVD="$(AVD)" DEFAULT_PORT="$(DEFAULT_PORT)" GPU="$(GPU)" ./scripts/run_with_port.sh

port: ## Print last chosen port (or DEFAULT_PORT if none saved)
	@cat ./last_port 2>/dev/null || echo "$(DEFAULT_PORT)"

show-url: ## Print last backend URL for emulator (http://10.0.2.2:PORT)
	@PORT="$$(cat ./last_port 2>/dev/null || echo $(DEFAULT_PORT))"; echo "http://10.0.2.2:$${PORT}"

icon: ## Create/update Desktop icon launcher for the emulator kit
	@./scripts/create_desktop_icon.sh
