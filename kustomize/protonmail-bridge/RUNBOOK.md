# ProtonMail Bridge Runbook

## Re-login after session expiry

This happens when the bridge loses its authenticated session (e.g. after a password change, 2FA reset, or prolonged downtime). Symptoms: pods are Running but SMTP/IMAP clients report authentication failures, or the liveness probe fails causing a CrashLoop.

### Steps

**1. Get the pod name**
```bash
kubectl get pods -n protonmail-bridge
```

**2. Exec into the pod**
```bash
kubectl exec -it <pod-name> -n protonmail-bridge -- /bin/sh
```

**3. Open the bridge interactive CLI**
```bash
/protonmail/bridge --cli
```

**4. Check current account status**
```
>>> list
```

**5. Login**
```
>>> login
```
Follow the prompts: email address, password, then TOTP code if 2FA is enabled.

**6. Verify the session is active**
```
>>> list
```
The account should appear as logged in.

**7. Exit the CLI**
```
>>> exit
```

The bridge daemon keeps running. No pod restart is needed — once SMTP starts accepting connections on port 25, the liveness probe will pass and the pod will return to Ready.

### Notes

- Session data is persisted in the PVC (`protonmail-bridge-pvc`) mounted at `/root/`, so re-login survives pod restarts.
- The bridge image used is `shenxn/protonmail-bridge` (v3.x). The `--cli` flag attaches to the already-running bridge instance.
- The Service exposes SMTP (port 25) and IMAP (port 143) as ClusterIP, accessible via Tailscale on the `protonmail-bridge` service hostname.
