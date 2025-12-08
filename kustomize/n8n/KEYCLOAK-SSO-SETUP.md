# n8n Keycloak SSO Configuration Guide

## Overview

n8n currently does not support configuring OIDC/SSO via environment variables. The OIDC configuration must be done through the n8n web UI after deployment.

## Prerequisites

- n8n deployed and accessible via Tailscale ingress at `https://n8n`
- Keycloak instance running and accessible
- Admin access to both n8n and Keycloak

## Keycloak Configuration

### 1. Create a new Client in Keycloak

1. Log into your Keycloak admin console
2. Navigate to your realm (e.g., `master` or your custom realm)
3. Go to **Clients** → **Create Client**
4. Configure the client:
   - **Client ID**: `n8n`
   - **Client Protocol**: `openid-connect`
   - **Root URL**: `https://n8n` (or your n8n URL)
5. Click **Save**

### 2. Configure Client Settings

1. In the client settings:
   - **Access Type**: `confidential`
   - **Standard Flow Enabled**: `ON`
   - **Valid Redirect URIs**: `https://n8n/*`
   - **Web Origins**: `https://n8n`
2. Click **Save**
3. Go to the **Credentials** tab and note the **Client Secret**

### 3. Create Client Scopes

1. Go to **Client Scopes** → **Create**
2. Create a scope named `n8n`
3. In the `n8n` scope, go to **Mappers** → **Create**
4. Add two mappers:

#### Mapper 1: n8n_instance_role
- **Name**: `n8n_instance_role`
- **Mapper Type**: `User Attribute`
- **User Attribute**: `n8n_instance_role`
- **Token Claim Name**: `n8n_instance_role`
- **Claim JSON Type**: `String`
- **Add to ID token**: `ON`
- **Add to access token**: `ON`
- **Add to userinfo**: `ON`

#### Mapper 2: n8n_projects
- **Name**: `n8n_projects`
- **Mapper Type**: `User Attribute`
- **User Attribute**: `n8n_projects`
- **Token Claim Name**: `n8n_projects`
- **Claim JSON Type**: `String`
- **Add to ID token**: `ON`
- **Add to access token**: `ON`
- **Add to userinfo**: `ON`

5. Go back to your **n8n client** → **Client Scopes** tab
6. Add the `n8n` scope to **Assigned Default Client Scopes**

### 4. Configure User Attributes

For each user that should access n8n:

1. Go to **Users** → Select user → **Attributes** tab
2. Add attributes:
   - **n8n_instance_role**: `admin` or `member` or `owner`
   - **n8n_projects**: Comma-separated project IDs (e.g., `project1,project2`)

## n8n Configuration

### 1. Get Keycloak OIDC Discovery Endpoint

1. In Keycloak, go to **Realm Settings**
2. Click on **OpenID Endpoint Configuration** link
3. Copy the URL (e.g., `https://your-keycloak/realms/master/.well-known/openid-configuration`)
4. The discovery endpoint is: `https://your-keycloak/realms/master`

### 2. Configure SSO in n8n

1. Log into n8n as an admin user
2. Go to **Settings** → **Users & Roles** → **SSO**
3. Configure OIDC:
   - **Discovery Endpoint**: Your Keycloak discovery endpoint
   - **Client ID**: `n8n`
   - **Client Secret**: The secret from Keycloak credentials tab
4. Click **Save** and test the connection

## References

- [n8n OIDC Setup Documentation](https://docs.n8n.io/user-management/oidc/setup/)
- [Keycloak OIDC Authentication with n8n](https://www.janua.fr/keycloak-oidc-authentication-with-n8n-workflow/)
- [n8n Community: SSO OIDC Configuration](https://community.n8n.io/t/sso-oidc-configuration-via-environment-variables-or-config-file/163195)

## Note

As of late 2025, native n8n OIDC environment variable configuration is not yet available. This configuration must be done through the UI.
