# Ansible Bootstrap Makefile - Multi-OS Support with Vault Options
# Usage: make <target> [USERS=<user1,user2>] [LIMIT=<group_or_host>] [VAULT=<true|false>]

# Default variables
INVENTORY ?= hosts/production/hosts
PLAYBOOK_RHEL ?= playbooks/ansible-setup-rhel-vault.yml
PLAYBOOK_RHEL_NO_VAULT ?= playbooks/ansible-setup-rhel.yml
PLAYBOOK_UBUNTU ?= playbooks/ansible-setup-ubuntu-vault.yml
PLAYBOOK_UBUNTU_NO_VAULT ?= playbooks/ansible-setup-ubuntu.yml
PLAYBOOK_RHEL_INFISICAL ?= playbooks/ansible-setup-rhel-infisical.yml
PLAYBOOK_UBUNTU_INFISICAL ?= playbooks/ansible-setup-ubuntu-infisical.yml
USERS ?= eric,ansible
ANSIBLE_OPTS ?= 
LIMIT ?= all
VAULT ?= true

# Color codes for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m

.PHONY: help deploy deploy-rhel deploy-ubuntu deploy-no-vault deploy-rhel-no-vault deploy-ubuntu-no-vault check ping

help: ## Show this help message
	@echo "$(GREEN)Ansible Bootstrap - Multi-OS Support$(NC)"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Variables:"
	@echo "  $(YELLOW)USERS$(NC)     = $(USERS)"
	@echo "  $(YELLOW)LIMIT$(NC)     = $(LIMIT)"
	@echo "  $(YELLOW)VAULT$(NC)     = $(VAULT)"
	@echo "  $(YELLOW)INVENTORY$(NC) = $(INVENTORY)"

deploy: ## Deploy to all systems (auto-detect OS, with Vault)
ifeq ($(VAULT),true)
	@echo "$(GREEN)Deploying to RHEL systems with Vault...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL) --limit ansible_rhel $(ANSIBLE_OPTS) || true
	@echo "$(GREEN)Deploying to Ubuntu systems with Vault...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU) --limit ansible_ubuntu $(ANSIBLE_OPTS) || true
else
	@echo "$(GREEN)Deploying to RHEL systems without Vault...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL_NO_VAULT) --limit ansible_rhel $(ANSIBLE_OPTS) || true
	@echo "$(GREEN)Deploying to Ubuntu systems without Vault...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU_NO_VAULT) --limit ansible_ubuntu $(ANSIBLE_OPTS) || true
endif

deploy-no-vault: ## Deploy to all systems without Vault
	@echo "$(GREEN)Deploying to RHEL systems without Vault...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL_NO_VAULT) --limit ansible_rhel $(ANSIBLE_OPTS) || true
	@echo "$(GREEN)Deploying to Ubuntu systems without Vault...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU_NO_VAULT) --limit ansible_ubuntu $(ANSIBLE_OPTS) || true

deploy-rhel: ## Deploy to RHEL/CentOS systems with Vault
	@echo "$(GREEN)Deploying to RHEL systems with Vault...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL) --limit ansible_rhel $(ANSIBLE_OPTS)

deploy-rhel-no-vault: ## Deploy to RHEL/CentOS systems without Vault
	@echo "$(GREEN)Deploying to RHEL systems without Vault...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL_NO_VAULT) --limit ansible_rhel $(ANSIBLE_OPTS)

deploy-ubuntu: ## Deploy to Ubuntu/Debian systems with Vault
	@echo "$(GREEN)Deploying to Ubuntu systems with Vault...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU) --limit ansible_ubuntu $(ANSIBLE_OPTS)

deploy-ubuntu-no-vault: ## Deploy to Ubuntu/Debian systems without Vault
	@echo "$(GREEN)Deploying to Ubuntu systems without Vault...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU_NO_VAULT) --limit ansible_ubuntu $(ANSIBLE_OPTS)

deploy-infisical: ## Deploy to all systems with Infisical
	@echo "$(GREEN)Deploying to RHEL systems with Infisical...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL_INFISICAL) --limit ansible_rhel $(ANSIBLE_OPTS) || true
	@echo "$(GREEN)Deploying to Ubuntu systems with Infisical...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU_INFISICAL) --limit ansible_ubuntu $(ANSIBLE_OPTS) || true

deploy-rhel-infisical: ## Deploy to RHEL/CentOS systems with Infisical
	@echo "$(GREEN)Deploying to RHEL systems with Infisical...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL_INFISICAL) --limit ansible_rhel $(ANSIBLE_OPTS)

deploy-ubuntu-infisical: ## Deploy to Ubuntu/Debian systems with Infisical
	@echo "$(GREEN)Deploying to Ubuntu systems with Infisical...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU_INFISICAL) --limit ansible_ubuntu $(ANSIBLE_OPTS)

check: ## Check playbook syntax
	@echo "$(GREEN)Checking RHEL playbook syntax...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL) --syntax-check
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_RHEL_NO_VAULT) --syntax-check
	@echo "$(GREEN)Checking Ubuntu playbook syntax...$(NC)"
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU) --syntax-check
	@ansible-playbook -i $(INVENTORY) $(PLAYBOOK_UBUNTU_NO_VAULT) --syntax-check

ping: ## Test connectivity to all hosts
	@echo "$(GREEN)Testing connectivity...$(NC)"
	@ansible -i $(INVENTORY) all -m ping --limit $(LIMIT)

clean: ## Clean retry files
	@echo "$(GREEN)Cleaning retry files...$(NC)"
	@find . -name "*.retry" -delete
	@echo "Retry files cleaned."