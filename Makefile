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
	@echo "$(GREEN)Ansible Bootstrap - Single Inventory$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*

## 🛡️ Security Improvements

### 4. **Enhance Security Configurations**

#### **iptables Template Update**
```jinja2
# roles/*/templates/iptables.j2
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:IN-filtered-ssh - [0:0]

# Allow loopback
-A INPUT -i lo -j ACCEPT

# Allow established connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# SSH filtering
-A INPUT -p tcp -m tcp --dport 22 -j IN-filtered-ssh
-A IN-filtered-ssh -s 127.0.0.1 -j ACCEPT -m comment --comment "Localhost"
{% for allowed_ip in ssh_allowed_ips | default(['127.0.0.1']) %}
-A IN-filtered-ssh -s {{ allowed_ip }} -j ACCEPT -m comment --comment "Allowed IP"
{% endfor %}
-A IN-filtered-ssh -j DROP

# Drop everything else
-A INPUT -j DROP
COMMIT