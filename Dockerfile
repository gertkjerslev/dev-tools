FROM python:3.11-alpine

RUN apk update
#Some Tools
RUN apk add --no-cache curl bash-completion ncurses-terminfo-base ncurses-terminfo readline ncurses-libs bash nano ncurses docker git k9s go powershell nodejs npm yarn neovim vim vim-tutor tmux dos2unix lazygit neovim ripgrep alpine-sdk

#Google Kubernetes control cmd
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

#Expose for kubectl proxy
EXPOSE 8001

#install etcdctl
RUN wget https://github.com/etcd-io/etcd/releases/download/v3.5.11/etcd-v3.5.11-linux-amd64.tar.gz && \
tar -xvzf etcd-v3.5.11-linux-amd64.tar.gz && \
cd etcd-v3.5.11-linux-amd64 && \
mv etcdctl /usr/local/bin/


#Install TPM
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

#tmux conf
RUN mkdir -p /tmp/tmux-0 && chmod 700 /tmp/tmux-0 && chown root:root /tmp/tmux-0

#K8 Helm
RUN wget -q "https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz" -O helm.tar.gz && \
tar -xzf helm.tar.gz && \
rm helm.tar.gz && \
mv linux-amd64/helm /usr/local/bin/helm

# ClusterCtl
RUN curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.4.2/clusterctl-linux-amd64 -o clusterctl
RUN chmod +x ./clusterctl
RUN mv ./clusterctl /usr/local/bin/clusterctl

# ArgoCD
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
RUN install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
RUN rm argocd-linux-amd64

# Install kubnt
# Set kube-no-trouble version
ARG KUBENT_VERSION="0.7.3"

# Download, extract, and install kube-no-trouble
RUN curl -L -o /tmp/kubent.tar.gz "https://github.com/doitintl/kube-no-trouble/releases/download/${KUBENT_VERSION}/kubent-${KUBENT_VERSION}-linux-amd64.tar.gz" && \
    tar -xzf /tmp/kubent.tar.gz -C /tmp && \
    mv /tmp/kubent /usr/local/bin/ && \
    chmod +x /usr/local/bin/kubent && \
    rm -rf /tmp/kubent.tar.gz && \
    ls -lah /usr/local/bin/kubent && \
    file /usr/local/bin/kubent

# Flux CLI
RUN bash -c "$(curl -s https://fluxcd.io/install.sh)"

#AiAC
RUN git clone https://github.com/gofireflyio/aiac.git && \
cd aiac && \
go build


#Azure CLI
WORKDIR azure-cli
ENV AZ_CLI_VERSION=2.67.0
RUN wget -q "https://github.com/Azure/azure-cli/archive/azure-cli-${AZ_CLI_VERSION}.tar.gz" -O azcli.tar.gz && \
    tar -xzf azcli.tar.gz && ls -l
RUN cp azure-cli-azure-cli-${AZ_CLI_VERSION}/** /azure-cli/ -r && \
    rm azcli.tar.gz
RUN apk add --no-cache bash openssh ca-certificates jq curl openssl perl git zip \
 && apk add --no-cache --virtual .build-deps gcc make openssl-dev libffi-dev musl-dev linux-headers \
 && apk add --no-cache libintl icu-libs libc6-compat \
 && apk add --no-cache bash-completion \
 && update-ca-certificates

#install azure-common
RUN pip install azure-common


ARG JP_VERSION="0.1.3"

RUN curl -L https://github.com/jmespath/jp/releases/download/${JP_VERSION}/jp-linux-amd64 -o /usr/local/bin/jp \
 && chmod +x /usr/local/bin/jp

# 1. Build packages and store in tmp dir
# 2. Install the cli and the other command modules that weren't included
RUN ./scripts/install_full.sh \
 && cat /azure-cli/az.completion > ~/.bashrc \
 && runDeps="$( \
    scanelf --needed --nobanner --recursive /usr/local \
        | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
        | sort -u \
        | xargs -r apk info --installed \
        | sort -u \
    )" \
 && apk add --virtual .rundeps $runDeps

# Remove CLI source code and normalize line endings
RUN rm -rf ./azure-cli && \
    dos2unix /root/.bashrc && \
    if [ -f /usr/local/bin/az ]; then dos2unix /usr/local/bin/az; fi
ENV AZ_INSTALLER=DOCKER

# Set the default timezone to Europe/Copenhagen
ENV TZ="Europe/Copenhagen"

# Install Azure Powershell module

# Tab completion
#RUN cat  /azure-cli/az.completion >> ~/.bashrc
#RUN echo -e "\n" >> ~/.bashrc
RUN echo -e "source <(kubectl completion bash)" >> ~/.bashrc
#RUN echo "source /etc/profile.d/bash_completion.sh" >> ~/.bashrc
RUN echo "alias k=kubectl" >> ~/.bashrc

#Install Krew plugin manager
RUN echo "( \
  set -x; cd "$(mktemp -d)" && \
  OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
  KREW="krew-${OS}_${ARCH}" && \
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
  tar zxvf "${KREW}.tar.gz" && \
  ./"${KREW}" install krew \
)" >> ~/.bashrc

# RUN echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
RUN echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> /etc/profile
# Set up environment for interactive shell
ENV PATH="/root/.krew/bin:$PATH"

# Install starship
RUN mkdir -p ~/.config
# copy the starship config from github
RUN wget https://raw.githubusercontent.com/gertkjerslev/dotfiles/main/starship/.config/starship.toml -O ~/.config/starship.toml
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y
RUN echo -e 'eval "$(starship init bash)"' >> ~/.bashrc

WORKDIR /

ENTRYPOINT ["bash"]
