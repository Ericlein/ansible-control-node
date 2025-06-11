![ansible-bootstrap](https://skillicons.dev/icons?i=ansible)
# ansible-server-setup


Setup a new Ansible server in seconds with automated configuration, user management, and HashiCorp Vault integration.

## Overview

This project provides a complete Ansible playbook to bootstrap a new Ansible control node server. It automates the installation and configuration of Ansible, HashiCorp Vault, user management with SSH keys, and security configurations.

## Features

- **Automated Ansible Installation**: Sets up Ansible with custom configuration
- **HashiCorp Vault Integration**: Installs and configures Vault client with environment variables
- **User Management**: Creates users with SSH key authentication and sudo access
- **Security Configuration**: Configures iptables firewall rules
- **Git Repository Setup**: Clones your Ansible repository for each user
- **Python Dependencies**: Installs required Python packages (hvac, PyMySQL, jmespath, etc.)
- **Ansible Galaxy Collections**: Installs community.general collection

## Prerequisites

- Target server running RHEL/CentOS (uses yum package manager)
- SSH access to the target server as root
- Git repository with your Ansible configurations
- HashiCorp Vault server (optional but recommended)

## Quick Start

### Step 1: Initial Setup

1. **Fork and clone this repository**:
   ```bash
   git clone https://github.com/yourusername/ansible-bootstrap.git
   cd ansible-bootstrap
   ```

2. **Create your own Ansible repository** (if you don't have one):
   - Create a new GitHub repository (e.g., `yourorg/ansible`)
   - This will store your actual Ansible playbooks and configurations
   - Make note of the SSH clone URL: `git@github.com:yourorg/ansible.git`

### Step 2: Configuration

3. **Update the Git repository reference**:
   Edit `roles/ansible-setup/tasks/git.yml` and change:
   ```yaml
   repo: git@github.com:yourorg/ansible.git  # Replace with your repo
   ```

4. **Configure your target server inventory**:
   Edit `hosts/production/hosts`:
   ```ini
   [ansible]
   ansible_server ansible_host=192.168.1.100 hostname=ansible.yourdomain.com server_id=PROD001
   
   [vault]
   vault_server ansible_host=192.168.1.101 hostname=vault.yourdomain.com server_id=PROD002
   ```
   Replace with your actual:
   - Server IP addresses
   - Hostnames/FQDNs
   - Server identifiers

5. **Configure Vault server** (if using HashiCorp Vault):
   Edit `hosts/production/group_vars/vault.yml`:
   ```yaml
   vault_addr: "https://vault.yourdomain.com:8200"  # Your Vault server URL
   ```

6. **Add your SSH public keys and users**:
   Edit `roles/ssh-public-keys/vars/main.yml`:
   ```yaml
   ssh_users:
     - name: yourusername           # Replace with your username
       ssh_key: "ssh-rsa AAAAB3... yourusername@yourdomain.com"  # Your SSH public key
     - name: ansible                # Keep this for automation
       ssh_key: "ssh-rsa AAAAB3... root@ansible"                 # Ansible server's public key
   ```

### Step 3: Environment Setup

7. **Set up SSH access**:
   - Ensure you can SSH to your target server as root
   - Your SSH public key should be in the target server's `/root/.ssh/authorized_keys`

8. **Set Vault credentials** (if using Vault):
   ```bash
   export VAULT_ROLE_ID="your-vault-role-id"
   export VAULT_SECRET_ID="your-vault-secret-id"
   ```

### Step 4: Deploy

9. **Test connectivity**:
   ```bash
   make ping
   ```

10. **Run the bootstrap playbook**:
   ```bash
   make deploy
   ```
   
   Or manually:
   ```bash
   ansible-playbook -i hosts/production/hosts playbooks/ansible-setup.yml
   ```

### Step 5: Verification

11. **Verify the setup**:
   ```bash
   make check
   ```

12. **SSH to your new Ansible server**:
   ```bash
   ssh yourusername@your-ansible-server
   cd ansible
   ansible --version
   ```

## Configuration

### Inventory Configuration

Edit `hosts/production/hosts`:
```ini
[ansible]
ansible_server ansible_host=YOUR_SERVER_IP hostname=YOUR_HOSTNAME server_id=YOUR_ID

[vault]
vault_server ansible_host=YOUR_VAULT_IP hostname=YOUR_VAULT_HOSTNAME server_id=YOUR_VAULT_ID
```

### Vault Configuration

Edit `hosts/production/group_vars/vault.yml`:
```yaml
vault_addr: "https://your-vault-server:8200"
```

### User Management

Edit `roles/ssh-public-keys/vars/main.yml` to add users and their SSH public keys:
```yaml
ssh_users:
  - name: username
    ssh_key: "ssh-rsa AAAAB3... user@example.com"
```

### Git Repository

Update `roles/ansible-setup/tasks/git.yml` to point to your organization's Ansible repository:
```yaml
repo: git@github.com:your-organization/ansible.git
```

## Playbook Structure

```
ansible-bootstrap/
├── hosts/production/
│   ├── hosts                    # Inventory file
│   └── group_vars/
│       └── vault.yml           # Vault configuration
├── playbooks/
│   └── ansible-setup.yml       # Main playbook
└── roles/
    ├── ansible-setup/          # Main setup role
    │   ├── tasks/              # Individual task files
    │   ├── templates/          # Configuration templates
    │   └── handlers/           # Event handlers
    └── ssh-public-keys/        # SSH key management
        └── vars/main.yml       # User definitions
```

## Available Tags

Run specific parts of the setup using tags:

```bash
# Install only Git components
ansible-playbook ... --tags git

# Setup only user accounts
ansible-playbook ... --tags users

# Configure only Ansible
ansible-playbook ... --tags ansible-configuration

# Install Vault only
ansible-playbook ... --tags vault-install
```

## What Gets Configured

### System Components
- Python 3.11 with pip
- Required Python packages (hvac, PyMySQL, jmespath, passlib, pywinrm)
- HashiCorp Vault client
- Ansible with custom configuration
- Community.general Galaxy collection

### Security
- iptables firewall rules (SSH access restricted to localhost by default)
- User accounts with SSH key authentication
- Sudo access without password for created users

### Environment
- Vault environment variables in user bash profiles
- Custom Ansible configuration
- Git repository cloned for each user

## Environment Variables

The playbook uses these environment variables:

- `VAULT_ROLE_ID` - Vault AppRole role ID
- `VAULT_SECRET_ID` - Vault AppRole secret ID
- `VAULT_ADDR` - Vault server address (set from group_vars)

## Troubleshooting

### Common Issues

1. **SSH connection fails**: Ensure you have SSH access to the target server
2. **Git clone fails**: Verify SSH keys are set up for Git access
3. **Vault authentication fails**: Check VAULT_ROLE_ID and VAULT_SECRET_ID
4. **Permission denied**: Ensure you're running as root or with sudo

### Debugging

Run with verbose output:
```bash
ansible-playbook ... -vvv
```

## Security Considerations

- Users are created with sudo NOPASSWD access
- Private SSH keys are copied from root to all users
- Vault credentials are stored in bash profiles

**Important**: Review and customize the security settings for your environment.

## License

MIT License - see LICENSE file for details.

<div align="center">

[⭐ Star this repo](https://github.com/Ericlein/ansible-bootstrap)
</div>
