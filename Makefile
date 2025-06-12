# Ansible Bootstrap Makefile - Multi-OS Support
# Usage: make <target> [USERS=<user1,user2>] [LIMIT=<group_or_host>]

# Default variables
INVENTORY ?= hosts/production/hosts
PLAYBOOK_RHEL ?= playbooks/ansible-setup-rhel.yml
PLAYBOOK_UBUNTU ?= playbooks/ansible-setup-ubuntu.yml
USERS ?= eric,ansible
ANSIBLE_OPTS ?= 
LIMIT ?= all

# Color codes for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m

.PHONY: help deploy deploy-rhel deploy-ubuntu check ping

help: ## Show this help message
	@echo "$(GREEN)Ansible Bootstrap - Multi-OS Support$(NC)"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Variables:"
	@echo "  $(YELLOW)USERS$(NC)     = $(USERS)"
	@echo "  $(YELLOW)LIMIT$(NC)     = $(LIMIT)"
	@echo "  $(YELLOW)INVENTORY$(NC) = $(INVENTORY)"

deploy: ## Deploy to all systems (auto-detect OS)
	@echo "$(GREEN)Deploying to RHEL systems...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL) --limit ansible_rhel $(ANSIBLE_OPTS) || true
	@echo "$(GREEN)Deploying to Ubuntu systems...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU) --limit ansible_ubuntu $(ANSIBLE_OPTS) || true

deploy-rhel: ## Deploy to RHEL/CentOS systems only
	@echo "$(GREEN)Deploying to RHEL systems...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL) --limit ansible_rhel $(ANSIBLE_OPTS)

deploy-ubuntu: ## Deploy to Ubuntu/Debian systems only
	@echo "$(GREEN)Deploying to Ubuntu systems...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU) --limit ansible_ubuntu $(ANSIBLE_OPTS)

check: ## Check playbook syntax
	@echo "$(GREEN)Checking RHEL playbook syntax...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL) --syntax-check
	@echo "$(GREEN)Checking Ubuntu playbook syntax...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU) --syntax-check

ping: ## Test connectivity to all hosts
	@echo "$(GREEN)Testing connectivity...$(NC)"
	@ansible -i $(INVENTORY) all -m ping --limit $(LIMIT)

clean: ## Clean retry files
	@echo "$(GREEN)Cleaning retry files...$(NC)"
	@find . -name "*.retry" -delete
	@echo "Retry files cleaned."