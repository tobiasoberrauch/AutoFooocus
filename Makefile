# AutoFooocus - Automated Batch Processing for Fooocus
# Pure shell/Makefile implementation

SHELL := /bin/bash
PROJECT_NAME := AutoFooocus

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help setup install download-models test clean status

# Default target
help:
	@echo "$(GREEN)AutoFooocus - Automated Batch Processing$(NC)"
	@echo "=========================================="
	@echo ""
	@echo "Available targets:"
	@echo "  $(YELLOW)setup$(NC)              - Complete setup (install + download models)"
	@echo "  $(YELLOW)install$(NC)            - Install Fooocus and dependencies"
	@echo "  $(YELLOW)update-scripts$(NC)     - Update AutoFooocus scripts"
	@echo "  $(YELLOW)download-models$(NC)    - Download essential models"
	@echo "  $(YELLOW)download-recommended$(NC) - Download recommended models"
	@echo "  $(YELLOW)list-models$(NC)        - List downloaded models"
	@echo "  $(YELLOW)test-single$(NC)        - Test with single prompt"
	@echo "  $(YELLOW)test-config$(NC)        - Test with batch configuration"
	@echo "  $(YELLOW)status$(NC)             - Show installation status"
	@echo "  $(YELLOW)clean$(NC)              - Clean installation"
	@echo ""
	@echo "Examples:"
	@echo "  make setup"
	@echo "  make test-single PROMPT=\"mountain landscape\""
	@echo "  make download-recommended"

# Complete setup process
setup: install download-models
	@echo "$(GREEN)✓ AutoFooocus setup complete!$(NC)"
	@echo ""
	@echo "Next steps:"
	@echo "  make test-single PROMPT=\"your prompt here\""
	@echo "  make list-models"

# Install Fooocus using shell script
install:
	@./scripts/setup_fooocus.sh install

# Update scripts without reinstalling
update-scripts:
	@./scripts/setup_fooocus.sh update-scripts

# Download essential models
download-models:
	@./scripts/setup_fooocus.sh download-models essentials

# Download recommended models
download-recommended:
	@./scripts/setup_fooocus.sh download-models recommended

# List downloaded models
list-models:
	@if [ -d "Fooocus" ]; then \
		cd Fooocus && ../scripts/download_models.sh list; \
	else \
		echo "$(RED)Error: Fooocus not installed. Run 'make install' first.$(NC)"; \
	fi

# Check disk space
check-space:
	@./scripts/download_models.sh check-space

# Test with single prompt using shell script
test-single:
	@if [ -z "$(PROMPT)" ]; then \
		echo "$(RED)Error: PROMPT not specified$(NC)"; \
		echo "Usage: make test-single PROMPT=\"your prompt here\""; \
		exit 1; \
	fi
	@if [ ! -d "Fooocus" ]; then \
		echo "$(RED)Error: Fooocus not installed. Run 'make install' first.$(NC)"; \
		exit 1; \
	fi
	@cd Fooocus && ../scripts/batch_generator.sh -p "$(PROMPT)" -n "$(NEGATIVE)" -s "$(STEPS)" -c "$(COUNT)"

# Test with config file (uses Python script)
test-config:
	@if [ ! -d "Fooocus" ]; then \
		echo "$(RED)Error: Fooocus not installed. Run 'make install' first.$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Testing batch configuration...$(NC)"
	@cd Fooocus && \
		source venv/bin/activate && \
		python working_batch.py --config batch_config.json

# Show installation status
status:
	@./scripts/setup_fooocus.sh status

# Clean installation
clean:
	@./scripts/setup_fooocus.sh clean

# View results (requires Python)
view-results:
	@if [ ! -d "Fooocus" ]; then \
		echo "$(RED)Error: Fooocus not installed$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Creating HTML viewer for results...$(NC)"
	@cd Fooocus && \
		source venv/bin/activate && \
		python view_results.py --html
	@echo "$(GREEN)✓ HTML viewer created$(NC)"

# Backup results
backup-results:
	@if [ -d "Fooocus/batch_outputs" ]; then \
		BACKUP_NAME="autofooocus_results_$$(date +%Y%m%d_%H%M%S).tar.gz"; \
		echo "$(YELLOW)Creating backup: $$BACKUP_NAME$(NC)"; \
		tar -czf "$$BACKUP_NAME" -C Fooocus batch_outputs; \
		echo "$(GREEN)✓ Backup created: $$BACKUP_NAME$(NC)"; \
	else \
		echo "$(RED)No results to backup$(NC)"; \
	fi

# Show recent results
show-results:
	@if [ -d "Fooocus/batch_outputs" ]; then \
		echo "$(YELLOW)Recent batch results:$(NC)"; \
		ls -lt Fooocus/batch_outputs | head -10; \
	else \
		echo "$(RED)No results found$(NC)"; \
	fi

# Variables with defaults
PROMPT ?= a majestic mountain landscape at sunset
NEGATIVE ?= blurry, low quality, distorted
STEPS ?= 30
COUNT ?= 1

# Quick test with defaults
quick-test:
	@make test-single PROMPT="beautiful landscape" STEPS=20 COUNT=1