![ansible-bootstrap](https://skillicons.dev/icons?i=ansible)
# ansible-control-node

Complete setup and configuration of an Ansible control node (master server) with HashiCorp Vault integration, user management, and development environment supporting both RHEL/CentOS and Ubuntu/Debian systems.

## Overview

This project provides comprehensive Ansible playbooks to bootstrap new Ansible control node servers across multiple operating systems. It automates the installation and configuration of Ansible, HashiCorp Vault, user management with SSH keys, security configurations, and development environments.

## Features

- **Multi-OS Support**: Separate playbooks for RHEL/CentOS and Ubuntu/Debian systems
- **Automated Ansible Installation**: Sets up Ansible with custom configuration
- **HashiCorp Vault Integration**: Installs and configures Vault client with environment variables
- **User Management**: Creates users with SSH key authentication and sudo access
- **Security Configuration**: Configures iptables firewall rules with IP whitelisting
- **Git Repository Setup**: Clones your Ansible repository for each user
- **Python Dependencies**: Installs required Python packages (hvac, PyMySQL, jmespath, etc.)
- **Ansible Galaxy Collections**: Installs community.general collection
- **Makefile Automation**: Convenient targets for deployment and management

## Prerequisites

- Target server running RHEL/CentOS or Ubuntu/Debian
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
   Edit both role variable files and update the `ansible_git_repo` variable:
   - `roles/ansible-setup-rhel/vars/main.yml`
   - `roles/ansible-setup-ubuntu/vars/main.yml`
   
   Change:
   ```yaml
   ansible_git_repo: "git@github.com:your-username/ansible.git"  # Replace with your repo
   ```

4. **Configure your target server inventory**:
   Edit `hosts/production/hosts`:
   ```ini
   [ansible_rhel]
   rhel-server1 ansible_host=192.168.1.100 hostname=rhel-ansible1.example.com
   rhel-server2 ansible_host=192.168.1.101 hostname=rhel-ansible2.example.com

   [ansible_ubuntu]
   ubuntu-server1 ansible_host=192.168.1.110 hostname=ubuntu-ansible1.example.com
   ubuntu-server2 ansible_host=192.168.1.111 hostname=ubuntu-ansible2.example.com

   [ansible:children]
   ansible_rhel
   ansible_ubuntu
   ```

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

7. **Configure SSH access restrictions**:
   Update the `ssh_allowed_ips` in both:
   - `roles/ansible-setup-rhel/vars/main.yml`
   - `roles/ansible-setup-ubuntu/vars/main.yml`
   
   Replace `"YOUR_IP_ADDRESS"` with your actual IP addresses:
   ```yaml
   ssh_allowed_ips:
     - "203.0.113.1"      # Your office IP
     - "198.51.100.0/24"  # Your network range
   ```

### Step 3: Environment Setup

8. **Set up SSH access**:
   - Ensure you can SSH to your target server as root
   - Your SSH public key should be in the target server's `/root/.ssh/authorized_keys`

9. **Set Vault credentials** (if using Vault):
   ```bash
   export VAULT_ROLE_ID="your-vault-role-id"
   export VAULT_SECRET_ID="your-vault-secret-id"
   ```

### Step 4: Deploy

10. **Test connectivity**:
    ```bash
    make ping
    ```

11. **Deploy to all systems**:
    ```bash
    make deploy
    ```
    
    Or deploy to specific OS types:
    ```bash
    make deploy-rhel     # RHEL/CentOS only
    make deploy-ubuntu   # Ubuntu/Debian only
    ```

### Step 5: Verification

12. **Check playbook syntax**:
    ```bash
    make check
    ```

13. **SSH to your new Ansible server**:
    ```bash
    ssh yourusername@your-ansible-server
    cd ansible
    ansible --version
    ```

## Makefile Targets

The project includes a convenient Makefile with the following targets:

```bash
make help           # Show available targets and variables
make deploy         # Deploy to all systems (auto-detect OS)
make deploy-rhel    # Deploy to RHEL/CentOS systems only
make deploy-ubuntu  # Deploy to Ubuntu/Debian systems only
make check          # Check playbook syntax for both OS types
make ping           # Test connectivity to all hosts
make clean          # Clean retry files
```

### Makefile Variables

You can customize deployment using these variables:

```bash
make deploy USERS=eric,ansible LIMIT=rhel-server1
make ping INVENTORY=hosts/staging/hosts
```

Available variables:
- `USERS`: Comma-separated list of users (default: eric,ansible)
- `LIMIT`: Limit deployment to specific hosts or groups
- `INVENTORY`: Path to inventory file
- `ANSIBLE_OPTS`: Additional ansible-playbook options

## Configuration

### Inventory Configuration

The inventory supports grouping by operating system:

```ini
[ansible_rhel]
rhel-server1 ansible_host=YOUR_RHEL_IP hostname=YOUR_RHEL_HOSTNAME

[ansible_ubuntu]
ubuntu-server1 ansible_host=YOUR_UBUNTU_IP hostname=YOUR_UBUNTU_HOSTNAME

[ansible:children]
ansible_rhel
ansible_ubuntu
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

Update the `create_users` list in role variables to specify which users to create:
```yaml
create_users:
  - eric
  - ansible
  - newuser
```

### Operating System Specific Variables

#### RHEL/CentOS Variables (`roles/ansible-setup-rhel/vars/main.yml`)
- Uses `yum` package manager
- Installs Python 3.11 via get-pip.py script
- HashiCorp repository configuration for RHEL

#### Ubuntu/Debian Variables (`roles/ansible-setup-ubuntu/vars/main.yml`)
- Uses `apt` package manager
- Installs Python 3.11 via apt packages
- HashiCorp repository configuration for Ubuntu

## What Gets Configured

### System Components
- **RHEL/CentOS**: Python 3.11 with pip via get-pip.py, yum packages
- **Ubuntu/Debian**: Python 3.11 with pip via apt packages
- Required Python packages (hvac, PyMySQL, jmespath, passlib, pywinrm)
- HashiCorp Vault client (OS-specific installation)
- Ansible with custom configuration
- Community.general Galaxy collection

### Security
- iptables firewall rules with IP-based SSH access control
- User accounts with SSH key authentication
- Sudo access without password for created users
- SSH key distribution (copies root's keys to user accounts)

### Environment
- Vault environment variables in user bash profiles
- Custom Ansible configuration
- Git repository cloned for each user with proper ownership
- Git safe.directory configuration

## Environment Variables

The playbook uses these environment variables:

- `VAULT_ROLE_ID` - Vault AppRole role ID
- `VAULT_SECRET_ID` - Vault AppRole secret ID
- `VAULT_ADDR` - Vault server address (set from group_vars)

## Required Variables

Before running the playbooks, ensure these variables are defined:

- `ansible_git_repo` - Your Ansible repository URL
- `ssh_allowed_ips` - List of IP addresses allowed SSH access
- Both variables must be set in the respective role vars files

Check specific OS deployment:
```bash
make deploy-rhel ANSIBLE_OPTS="-vvv"
make deploy-ubuntu ANSIBLE_OPTS="-vvv"
```

## Security Considerations

- Users are created with sudo NOPASSWD access
- Private SSH keys are copied from root to all users
- Vault credentials are stored in bash profiles
- iptables rules restrict SSH access to specified IPs only

**Important**: Review and customize the security settings for your environment, especially the SSH allowed IPs and user sudo permissions.

## License

MIT License - see LICENSE file for details.

<div align="center">

[⭐ Star this repo](https://github.com/Ericlein/ansible-bootstrap)
</div>