# Server Management Playbook

This directory contains Ansible playbooks for managing server updates with notification support.

## Files

- `update-servers.yml` - Main playbook for updating servers
- `../inventory.yml` - Sample inventory file defining server groups
- `../group_vars/all.yml` - Global variables including ntfy configuration

## Features

- **APT Package Updates**: Performs `dist-upgrade`, cache updates, autoremove, and autoclean
- **YunoHost Updates**: Runs `yunohost tools update` and conditionally executes system/apps upgrades
- **NTFY Notifications**: Sends notifications to a custom ntfy server when packages are updated
- **Conditional Execution**: Only runs updates when `update_methods` includes 'apt' or 'yunohost'
- **Error Handling**: Notification failures don't stop the playbook execution

## Quick Start

1. **Configure your ntfy server** in `../group_vars/all.yml`:
   ```yaml
   ntfy_server_url: "https://your-ntfy-server.com"
   ntfy_topic: "your-topic"
   ```

2. **Update the inventory** in `../inventory.yml` with your servers:
   ```yaml
   sbcs:
     hosts:
       your-server.example.com:
         ansible_host: 192.168.1.100
         ansible_user: your_user
   yunohost:
     hosts:
       yunohost.example.com:
         ansible_host: 192.168.1.200
         ansible_user: root
   ```

3. **Run the playbook**:
   ```bash
   ansible-playbook -i inventory.yml server-management/update-servers.yml
   ```

## Configuration

### NTFY Settings

The following variables can be set in `group_vars/all.yml` or overridden per host/group:

- `ntfy_server_url`: Your custom ntfy server URL (required for notifications)
- `ntfy_topic`: Topic/channel name for notifications (default: "homelab-updates")
- `ntfy_priority`: Notification priority - low, default, high, max
- `ntfy_tags`: Comma-separated tags for notifications

#### Authentication (Optional)

NTFY supports two authentication methods:

**Method 1: Basic Authentication (username/password)**
```yaml
ntfy_username: "your_username"
ntfy_password: "your_password"
```

**Method 2: Token Authentication (recommended)**
```yaml
ntfy_token: "tk_your_access_token_here"
```

**Secure Credential Storage with Ansible Vault:**

For production environments, store credentials securely:

1. Create an encrypted vault file:
   ```bash
   ansible-vault create group_vars/all_vault.yml
   ```

2. Add your credentials to the vault:
   ```yaml
   ---
   vault_ntfy_username: "your_username"
   vault_ntfy_password: "your_secure_password"
   vault_ntfy_token: "tk_your_access_token"
   ```

3. Reference vault variables in `all.yml`:
   ```yaml
   ntfy_username: "{{ vault_ntfy_username | default(omit) }}"
   ntfy_password: "{{ vault_ntfy_password | default(omit) }}"
   # OR for token auth:
   ntfy_token: "{{ vault_ntfy_token | default(omit) }}"
   ```

4. Run playbooks with vault password:
   ```bash
   ansible-playbook -i inventory.yml server-management/update-servers.yml --ask-vault-pass
   ```

### Update Methods

Set `update_methods` to control which update mechanisms to use:

```yaml
update_methods:
  - apt       # Enable APT updates
  - yunohost  # Enable YunoHost updates
```

#### YunoHost Update Method

The YunoHost update method performs the following steps:

1. **Update Check**: Runs `yunohost tools update` as root to check for available updates
2. **Conditional System Upgrade**: If system updates are detected, runs `yunohost tools upgrade system`
3. **Conditional Apps Upgrade**: If app updates are detected, runs `yunohost tools upgrade apps`
4. **Notification**: Sends detailed ntfy notification with update status and results

**Requirements for YunoHost servers:**
- Must run as root user (set `ansible_user: root` in inventory)
- YunoHost must be installed and configured
- Server must have network access to download updates

## Notification Details

When packages are updated, the ntfy notification includes:

### APT Updates
- **Title**: "Server Update Complete: [hostname]"
- **Body**: Update status with timestamp and autoremove information
- **Priority**: Configurable priority level
- **Tags**: Configurable tags for filtering

### YunoHost Updates
- **Title**: "YunoHost Update Complete: [hostname]"
- **Body**: Detailed update status including:
  - Whether system/apps upgrades were needed
  - Whether upgrades were performed
  - Original update check output
- **Priority**: Configurable priority level
- **Tags**: Includes 'yunohost' tag by default

## Example Run

```bash
# Update all servers in the sbcs group
ansible-playbook -i inventory.yml server-management/update-servers.yml

# Update only YunoHost servers
ansible-playbook -i inventory.yml server-management/update-servers.yml --limit yunohost

# Update with vault-encrypted credentials
ansible-playbook -i inventory.yml server-management/update-servers.yml --ask-vault-pass

# Update specific server
ansible-playbook -i inventory.yml server-management/update-servers.yml --limit server1.example.com

# Run without notifications (skip ntfy vars)
ansible-playbook -i inventory.yml server-management/update-servers.yml -e ntfy_server_url=""

# Test with different authentication methods
ansible-playbook -i inventory.yml server-management/update-servers.yml -e ntfy_token="tk_test_token"
```

## Troubleshooting

- **No notifications**: Check that `ntfy_server_url` is defined and accessible
- **Wrong topic**: Verify `ntfy_topic` is set correctly
- **Permission errors**: Ensure the playbook runs with `become: yes` for apt operations
- **YunoHost permission errors**: Ensure `ansible_user: root` is set for YunoHost servers
- **YunoHost command not found**: Verify YunoHost is properly installed on target servers
- **Network issues**: Notification failures are ignored to prevent blocking updates

## Security Notes

- **Always use Ansible Vault** for storing ntfy credentials in production environments
- **Use HTTPS** for ntfy server URLs to encrypt communication
- **Token authentication** is preferred over username/password authentication
- **Restrict topic access** on your ntfy server if notifications contain sensitive information
- **Rotate tokens regularly** and use different tokens for different environments
- **Limit token permissions** to only the topics/operations needed
- **Use environment-specific vault files** for dev/staging/prod credentials

## Authentication Troubleshooting

- **401 Unauthorized**: Check username/password or token validity
- **403 Forbidden**: Verify token has permission to publish to the topic
- **Authentication ignored**: Ensure both username AND password are provided for basic auth
- **Vault decryption errors**: Verify vault password and file encryption status