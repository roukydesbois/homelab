#!/bin/bash
# bootstrap.sh — run once on first boot via cloud-init
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
USERNAME="thomas"

### System update ###
apt-get update -qq
apt-get upgrade -y -qq

### Base packages ###
apt-get install -y -qq \
  curl wget git tmux \
  jq unzip \
  htop ripgrep fd-find fzf \
  openssh-server ca-certificates \
  gnupg lsb-release apt-transport-https \
  fish

### Helix editor ###
# Install via PPA (https://docs.helix-editor.com/install.html)
add-apt-repository -y ppa:maveonair/helix-editor
apt-get update -qq
apt-get install -y -qq helix

### ttyd ###
TTYD_VERSION=$(curl -s https://api.github.com/repos/tsl0922/ttyd/releases/latest | jq -r .tag_name)
curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64" \
  -o /usr/local/bin/ttyd
chmod +x /usr/local/bin/ttyd

### kubectl ###
KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
  -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

### talosctl ###
TALOS_VERSION=$(curl -s https://api.github.com/repos/siderolabs/talos/releases/latest | jq -r .tag_name)
curl -fsSL "https://github.com/siderolabs/talos/releases/download/${TALOS_VERSION}/talosctl-linux-amd64" \
  -o /usr/local/bin/talosctl
chmod +x /usr/local/bin/talosctl

### OpenTofu ###
curl -fsSL https://get.opentofu.org/install-opentofu.sh | bash -s -- --install-method standalone
# Installs to /usr/local/bin/tofu

### Tailscale ###
curl -fsSL https://tailscale.com/install.sh | sh
# Note: run 'tailscale up --authkey <key>' after boot,
# or inject via a Sealed Secret / cloud-init environment variable.

### Helm ###
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

### k9s ###
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r .tag_name)
curl -fsSL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" \
  | tar -xz -C /usr/local/bin k9s

### Claude Code (native installer — npm install is deprecated) ###
curl -fsSL https://claude.ai/install.sh | bash
# Installs to /usr/local/bin/claude, auto-updates itself

### Shell config for thomas ###
THOMAS_HOME="/home/${USERNAME}"

# tmux config
cat > "${THOMAS_HOME}/.tmux.conf" <<'EOF'
set -g default-terminal "screen-256color"
set -g history-limit 50000
set -g mouse on

# Prefix: Ctrl-a
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Split panes with | and -
bind | split-window -h
bind - split-window -v

# Status bar
set -g status-bg colour235
set -g status-fg white
set -g status-right '%Y-%m-%d %H:%M'
EOF
chown ${USERNAME}:${USERNAME} "${THOMAS_HOME}/.tmux.conf"

### Fish shell config ###
FISH_CONFIG_DIR="${THOMAS_HOME}/.config/fish"
mkdir -p "${FISH_CONFIG_DIR}/functions" "${FISH_CONFIG_DIR}/conf.d"

cat > "${FISH_CONFIG_DIR}/config.fish" <<'EOF'
set -gx EDITOR hx

# kubectl abbreviations (fish abbr expands inline, nicer than aliases)
abbr -a k kubectl
abbr -a kg 'kubectl get'
abbr -a kd 'kubectl describe'
abbr -a kl 'kubectl logs'

# tofu abbreviation
abbr -a tf tofu

# Completions — generated at shell start, cached automatically by fish
if command -q kubectl
    kubectl completion fish | source
end
if command -q talosctl
    talosctl completion fish | source
end
if command -q tofu
    tofu completion fish | source
end
if command -q helm
    helm completion fish | source
end

# fzf key bindings
if test -f /usr/share/fzf/shell/key-bindings.fish
    source /usr/share/fzf/shell/key-bindings.fish
end
EOF

chown -R ${USERNAME}:${USERNAME} "${FISH_CONFIG_DIR}"

# Set fish as the default shell for thomas
chsh -s /usr/bin/fish ${USERNAME}

### Helix config — sensible defaults ###
HX_CONFIG_DIR="${THOMAS_HOME}/.config/helix"
mkdir -p "${HX_CONFIG_DIR}"
cat > "${HX_CONFIG_DIR}/config.toml" <<'EOF'
[editor]
line-number = "relative"
mouse = true
auto-save = true
color-modes = true

[editor.cursor-shape]
insert = "bar"
normal = "block"
select = "underline"

[editor.statusline]
left = ["mode", "spinner", "file-name", "file-modification-indicator"]
right = ["diagnostics", "selections", "position", "file-encoding", "file-line-ending", "file-type"]

[editor.file-picker]
hidden = false

[keys.normal]
C-h = "jump_view_left"
C-l = "jump_view_right"
C-j = "jump_view_down"
C-k = "jump_view_up"
EOF
chown -R ${USERNAME}:${USERNAME} "${THOMAS_HOME}/.config"

### ttyd systemd service ###
# Launches fish inside tmux — binds to loopback only
cat > /etc/systemd/system/ttyd.service <<'EOF'
[Unit]
Description=ttyd web terminal
After=network.target

[Service]
User=thomas
ExecStart=/usr/local/bin/ttyd \
  --port 7681 \
  --writable \
  tmux new-session -A -s main /usr/bin/fish
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ttyd
systemctl start ttyd

echo "Bootstrap complete. Run 'tailscale up' to connect to your tailnet."
