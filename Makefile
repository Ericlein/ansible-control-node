# Ansible Bootstrap Makefile - Multi-OS Support
# Usage: make <target> [USERS=<user1,user2>] [OS=<rhel|ubuntu|mixed>]

# Default variables
OS ?= rhel
INVENTORY_RHEL ?= hosts/production/hosts-rhel
INVENTORY_UBUNTU ?= hosts/production/hosts-ubuntu
INVENTORY_MIXED ?= hosts/production/hosts-mixed
PLAYBOOK_RHEL ?= playbooks/ansible-setup-rhel.yml
PLAYBOOK_UBUNTU ?= playbooks/ansible-setup-ubuntu.yml
PLAYBOOK_UNIFIED ?= playbooks/ansible-setup-unified.yml
USERS ?= eric,ansible
ANSIBLE_OPTS ?= 

# Set inventory and playbook based on OS
ifeq ($(OS),ubuntu)
    INVENTORY := $(INVENTORY_UBUNTU)
    PLAYBOOK := $(PLAYBOOK_UBUNTU)
else ifeq ($(OS),mixed)
    INVENTORY := $(INVENTORY_MIXED)
    PLAYBOOK := $(PLAYBOOK_UNIFIED)
else
    INVENTORY := $(INVENTORY_RHEL)
    PLAYBOOK := $(PLAYBOOK_RHEL)
endif

# Color codes for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m

.PHONY: help deploy deploy-rhel deploy-ubuntu deploy-mixed check ping

help: ## Show this help message
	@echo "$(GREEN)Ansible Bootstrap - Multi-OS Support$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(YELLOW)%-20s$(NC) %s\n", $1, $2}'
	@echo ""
	@echo "$(GREEN)Examples:$(NC)"
	@echo "  make deploy                              # Deploy to RHEL (default)"
	@echo "  make deploy OS=ubuntu                   # Deploy to Ubuntu"
	@echo "  make deploy OS=mixed                    # Deploy to mixed environment"
	@echo "  make deploy-ubuntu USERS='alice,bob'    # Deploy Ubuntu with specific users"

deploy: ## Deploy Ansible bootstrap (specify OS=rhel|ubuntu|mixed)
	@echo "$(GREEN)Deploying Ansible bootstrap for $(OS)...$(NC)"
	@echo "$(YELLOW)Users: $(USERS)$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) -e create_users="$(USERS)" $(ANSIBLE_OPTS)

deploy-rhel: ## Deploy to RHEL/CentOS systems
	@echo "$(GREEN)Deploying to RHEL/CentOS systems...$(NC)"
	ansible-playbook -i $(INVENTORY_RHEL) $(PLAYBOOK_RHEL) -e create_users="$(USERS)" $(ANSIBLE_OPTS)

deploy-ubuntu: ## Deploy to Ubuntu/Debian systems
	@echo "$(GREEN)Deploying to Ubuntu/Debian systems...$(NC)"
	ansible-playbook -i $(INVENTORY_UBUNTU) $(PLAYBOOK_UBUNTU) -e create_users="$(USERS)" $(ANSIBLE_OPTS)

deploy-mixed: ## Deploy to mixed environment
	@echo "$(GREEN)Deploying to mixed environment...$(NC)"
	ansible-playbook -i $(INVENTORY_MIXED) $(PLAYBOOK_UNIFIED) -e create_users="$(USERS)" $(ANSIBLE_OPTS)

check: ## Run deployment in check mode
	@echo "$(GREEN)Running deployment check for $(OS)...$(NC)"
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) -e create_users="$(USERS)" --check --diff $(ANSIBLE_OPTS)

ping: ## Test connectivity to all hosts
	@echo "$(GREEN)Testing connectivity to $(OS) hosts...$(NC)"
	ansible -i $(INVENTORY) all -m ping