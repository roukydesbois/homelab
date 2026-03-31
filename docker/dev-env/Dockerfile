FROM debian:bookworm-slim

ARG TARGETARCH

# Tool versions — update these to upgrade
ARG HELIX_VERSION=24.07
ARG KUBECTL_VERSION=v1.31.3
ARG TALOSCTL_VERSION=v1.8.4
ARG HELM_VERSION=v3.16.4
ARG TOFU_VERSION=1.8.8
ARG SOPS_VERSION=v3.9.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    tmux \
    git \
    curl \
    ca-certificates \
    fish \
    age \
    sudo \
    xz-utils \
    bash \
    && rm -rf /var/lib/apt/lists/*

# helix — binary + runtime
RUN HARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x86_64") && \
    curl -fsSL "https://github.com/helix-editor/helix/releases/download/${HELIX_VERSION}/helix-${HELIX_VERSION}-${HARCH}-linux.tar.xz" \
    | tar -xJ -C /tmp && \
    mv "/tmp/helix-${HELIX_VERSION}-${HARCH}-linux/hx" /usr/local/bin/hx && \
    mkdir -p /usr/local/share/helix && \
    mv "/tmp/helix-${HELIX_VERSION}-${HARCH}-linux/runtime" /usr/local/share/helix/runtime && \
    rm -rf /tmp/helix-*
ENV HELIX_RUNTIME=/usr/local/share/helix/runtime

# kubectl
RUN curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
    -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# talosctl
RUN curl -fsSL "https://github.com/siderolabs/talos/releases/download/${TALOSCTL_VERSION}/talosctl-linux-${TARGETARCH}" \
    -o /usr/local/bin/talosctl && chmod +x /usr/local/bin/talosctl

# helm
RUN curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
    | tar -xz --strip-components=1 -C /usr/local/bin "linux-${TARGETARCH}/helm"

# OpenTofu
RUN curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${TARGETARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin tofu

# sops
RUN curl -fsSL "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${TARGETARCH}" \
    -o /usr/local/bin/sops && chmod +x /usr/local/bin/sops

# SSH server setup
RUN mkdir /var/run/sshd && \
    mkdir -p /etc/ssh/authorized_keys && \
    chmod 755 /etc/ssh/authorized_keys
COPY sshd_config /etc/ssh/sshd_config

# Create user thomas with fish shell and passwordless sudo
RUN useradd -m -s /usr/bin/fish thomas && \
    passwd -d thomas && \
    echo "thomas ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/thomas

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
