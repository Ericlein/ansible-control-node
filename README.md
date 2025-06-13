![ansible-control-node](https://skillicons.dev/icons?i=ansible)
# Ansible Control Node Bootstrap

**Quickly setup production-ready Ansible control nodes on RHEL/CentOS or Ubuntu/Debian with HashiCorp Vault or Infisical secret management.**

## ⚡ What This Does

- **Installs Ansible** with Python 3.11 and required packages
- **Sets up users** with SSH keys and sudo access
- **Configures secret management** (Infisical or Vault)
- **Clones your Git repository** to all users
- **Secures the server** with firewall rules
- **Installs collections** (community.general, infisical.vault/vault)


## 🚀 Step-by-Step Deployment Guide

### Option A: No Secret Management (Basic Setup)
**Use this if you don't need Infisical or Vault integration**

#### Using Makefile:
```bash
# 1. Configure your files (see Required Configuration below)
# 2. Test connectivity
make ping
# 3. Deploy
make deploy-no-vault
```

#### Using Ansible directly:
```bash
ansible-playbook -i hosts/production/hosts playbooks/ansible-setup-ubuntu.yml
# or for RHEL
ansible-playbook -i hosts/production/hosts playbooks/ansible-setup-rhel.yml
```

---

### Option B: With Infisical (Recommended for Modern Teams)
**Use this if your company uses Infisical for secret management**

#### Using Makefile:
```bash
# 1. Configure your files (see Required Configuration below)
# 2. Set Infisical credentials
export INFISICAL_CLIENT_ID="your-client-id"
export INFISICAL_CLIENT_SECRET="your-client-secret"
export INFISICAL_PROJECT_ID="your-project-id"

# 3. Test connectivity
make ping
# 4. Deploy
make deploy-ubuntu-infisical  # or deploy-rhel-infisical
```

#### Using Ansible directly:
```bash
# Set credentials
export INFISICAL_CLIENT_ID="your-client-id" 
export INFISICAL_CLIENT_SECRET="your-client-secret"
export INFISICAL_PROJECT_ID="your-project-id"

# Deploy
ansible-playbook -i hosts/production/hosts playbooks/ansible-setup-ubuntu-infisical.yml
# or for RHEL
ansible-playbook -i hosts/production/hosts playbooks/ansible-setup-rhel-infisical.yml

# Alternative: Pass credentials directly
ansible-playbook -i hosts/production/hosts playbooks/ansible-setup-ubuntu-infisical.yml \
  -e "infisical_client_id=your-id" \
  -e "infisical_client_secret=your-secret" \
  -e "infisical_project_id=your-project"
```

---

### Option C: With HashiCorp Vault (Enterprise)
**Use this if your company uses HashiCorp Vault**

#### Using Makefile:
```bash
# 1. Configure your files (see Required Configuration below)
# 2. Set Vault credentials
export VAULT_ROLE_ID="your-role-id"
export VAULT_SECRET_ID="your-secret-id"

# 3. Test connectivity  
make ping
# 4. Deploy
make deploy-ubuntu  # or deploy-rhel
```

#### Using Ansible directly:
```bash
# Set credentials
export VAULT_ROLE_ID="your-role-id"
export VAULT_SECRET_ID="your-secret-id"

# Deploy
ansible-playbook -i hosts/production/hosts playbooks/ansible-setup-ubuntu-vault.yml
# or for RHEL  
ansible-playbook -i hosts/production/hosts playbooks/ansible-setup-rhel-vault.yml

# Alternative: Pass credentials directly
ansible-playbook -i hosts/production/hosts playbooks/ansible-setup-ubuntu-vault.yml \
  -e "vault_role_id=your-role-id" \
  -e "vault_secret_id=your-secret-id"
```

## 🔧 Required Configuration

**Before running ANY deployment, you MUST update these files:**

### 1. Inventory: `hosts/production/hosts`
```ini
[ansible_ubuntu]
my-server ansible_host=YOUR_SERVER_IP hostname=my-server.example.com
```

### 2. SSH Keys: `roles/ssh-public-keys/vars/main.yml`
```yaml
ssh_users:
  - name: yourusername
    ssh_key: "ssh-rsa AAAAB3... your-email@example.com"
```

### 3. Network Security: `roles/ansible-setup-common/vars/main.yml`
```yaml
ssh_allowed_ips:
  - "YOUR_IP_ADDRESS"  # Replace with your actual IP!
ansible_git_repo: "git@github.com:your-username/your-repo.git"
```

### 4. Secret Management URLs (Only if using secrets)

**For Infisical:** `roles/infisical-setup/defaults/main.yml`
```yaml
infisical_url: "http://your-infisical-server:8080"  # Update this!
```

**For Vault:** `hosts/production/group_vars/vault.yml` 
```yaml
vault_addr: "https://your-vault-server:8200"  # Update this!
```

## 📋 Available Commands

```bash
make help                    # Show all available commands

# Infisical deployments
make deploy-infisical        # Deploy to all systems with Infisical
make deploy-ubuntu-infisical # Deploy to Ubuntu with Infisical
make deploy-rhel-infisical   # Deploy to RHEL with Infisical

# Vault deployments  
make deploy                  # Deploy to all systems with Vault
make deploy-ubuntu           # Deploy to Ubuntu with Vault
make deploy-rhel             # Deploy to RHEL with Vault

# No secrets management
make deploy-no-vault         # Deploy without any secret management

# Utilities
make ping                    # Test connectivity
make check                   # Check playbook syntax
make clean                   # Clean retry files
```

## 🔐 Credentials Setup

### Option 1: Environment Variables (Recommended)
```bash
# For Infisical
export INFISICAL_CLIENT_ID="your-client-id"
export INFISICAL_CLIENT_SECRET="your-client-secret"
export INFISICAL_PROJECT_ID="your-project-id"

# For Vault
export VAULT_ROLE_ID="your-role-id"
export VAULT_SECRET_ID="your-secret-id"
```

### Option 2: Command Line Parameters
```bash
ansible-playbook playbooks/ansible-setup-ubuntu-infisical.yml \
  -e "infisical_client_id=your-id" \
  -e "infisical_client_secret=your-secret" \
  -e "infisical_project_id=your-project"
```

## 🎯 After Setup

SSH to your server and verify:
```bash
ssh yourusername@your-server-ip
cd ansible
ansible --version

# If you deployed with Infisical, check integration:
echo $INFISICAL_URL
echo $INFISICAL_PROJECT_ID

# If you deployed with Vault, check integration:
echo $VAULT_ADDR
echo $VAULT_ROLE_ID
```

## ⚠️ Important Security Notes

- **Firewall Warning**: This configures iptables rules that could lock you out if your IP isn't in `ssh_allowed_ips`
- **Have console access** to your server (not just SSH) as backup
- **Test firewall rules carefully** before deploying to production
- **Secrets are stored** in user bash profiles after setup

## 🛠️ Disaster Recovery

If your Ansible control node dies, quickly recover:
```bash
# On new server
ssh root@new-server
apt update && apt install -y git python3-pip
git clone https://github.com/Ericlein/ansible-control-node.git
cd ansible-control-node

# Set credentials and bootstrap
export INFISICAL_CLIENT_ID="your-id"
export INFISICAL_CLIENT_SECRET="your-secret"  
export INFISICAL_PROJECT_ID="your-project"
```

## 📞 Support

**Common Issues:**
- **Connection refused**: Check if your IP is in `ssh_allowed_ips`
- **Git clone fails**: Verify SSH key access to your repository
- **Secret errors**: Ensure credentials are set and Infisical/Vault is accessible

## 📄 License

MIT License - Feel free to use this in your organization.

---

<div align="center">

***Ready to deploy production-grade Ansible infrastructure in minutes!***

[⭐ Star this repo](https://github.com/Ericlein/ansible-control-node)

</div>