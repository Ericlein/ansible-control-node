# Ansible Bootstrap Makefile
# Usage: make <target> [USERS=<user1,user2>]

# Default variables
INVENTORY ?= hosts/production/hosts
PLAYBOOK ?= playbooks/ansible-setup.yml
USERS ?= eric,ansible
ANSIBLE_OPTS ?= 

# Color codes for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help deploy check ping syntax lint clean install-deps

# Default target
help: ## Show this help message
	@echo "$(GREEN)Ansible Bootstrap - Available Commands:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(YELLOW)%-20s$(NC) %s\n", $1, $2}'
	@echo ""
	@echo "$(GREEN)Examples:$(NC)"
	@echo "  make deploy                              # Deploy with default users"
	@echo "  make deploy USERS='alice,bob'           # Deploy with specific users"
	@echo "  make check                               # Dry run"
	@echo "  make ping                                # Test connectivity"

deploy: ## Deploy Ansible bootstrap to servers
	@echo "$(GREEN)Deploying Ansible bootstrap...$(NC)"
	@echo "$(YELLOW)Users: $(USERS)$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) -e create_users="$(USERS)" $(ANSIBLE_OPTS)

check: ## Run deployment in check mode (dry run)
	@echo "$(GREEN)Running deployment check (dry run)...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) -e create_users="$(USERS)" --check --diff $(ANSIBLE_OPTS)

ping: ## Test connectivity to all hosts
	@echo "$(GREEN)Testing connectivity to hosts...$(NC)"
	ansible -i $(INVENTORY) all -m ping

syntax: ## Check playbook syntax
	@echo "$(GREEN)Checking playbook syntax...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --syntax-check

lint: ## Run ansible-lint on playbooks
	@echo "$(GREEN)Running ansible-lint...$(NC)"
	@command -v ansible-lint >/dev/null 2>&1 || { echo "$(RED)ansible-lint not found. Install with: pip install ansible-lint$(NC)"; exit 1; }
	ansible-lint $(PLAYBOOK)

# Individual role targets
deploy-git: ## Deploy only Git configuration
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --tags git -e create_users="$(USERS)" $(ANSIBLE_OPTS)

deploy-users: ## Deploy only user management
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --tags users -e create_users="$(USERS)" $(ANSIBLE_OPTS)

deploy-vault: ## Deploy only Vault components
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --tags vault-install,vault-environment -e create_users="$(USERS)" $(ANSIBLE_OPTS)

deploy-ansible: ## Deploy only Ansible configuration
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --tags ansible-configuration,ansible-galaxy -e create_users="$(USERS)" $(ANSIBLE_OPTS)

# Utility targets
install-deps: ## Install required Python packages (if needed)
	@echo "$(GREEN)Installing Python dependencies...$(NC)"
	@echo "$(YELLOW)Note: Python packages are installed automatically by the playbook$(NC)"

clean: ## Clean up temporary files
	@echo "$(GREEN)Cleaning up temporary files...$(NC)"
	find . -name "*.retry" -delete
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

facts: ## Gather facts from all hosts
	@echo "$(GREEN)Gathering facts from hosts...$(NC)"
	ansible -i $(INVENTORY) all -m setup

list-hosts: ## List all hosts in inventory
	@echo "$(GREEN)Hosts in inventory:$(NC)"
	ansible -i $(INVENTORY) all --list-hosts

list-tags: ## List all available tags
	@echo "$(GREEN)Available tags:$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --list-tags

# Verbose deployment
deploy-verbose: ## Deploy with verbose output
	$(MAKE) deploy ANSIBLE_OPTS="-vvv"

# Emergency/Recovery
emergency-deploy: ## Deploy with maximum verbosity and no host key checking
	@echo "$(RED)Emergency deployment - bypassing host key checking!$(NC)"
	$(MAKE) deploy ANSIBLE_OPTS="-vvv --ssh-extra-args='-o StrictHostKeyChecking=no'"

# Development helpers
dev-check: ## Run syntax check and lint
	$(MAKE) syntax
	$(MAKE) lint

# Show configuration
show-config: ## Show current configuration
	@echo "$(GREEN)Current Configuration:$(NC)"
	@echo "$(YELLOW)Inventory:$(NC) $(INVENTORY)"
	@echo "$(YELLOW)Playbook:$(NC) $(PLAYBOOK)"
	@echo "$(YELLOW)Default Users:$(NC) $(USERS)"
	@echo "$(YELLOW)Ansible Options:$(NC) $(ANSIBLE_OPTS)"