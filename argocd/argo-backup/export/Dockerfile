FROM ubuntu:18.04

RUN apt update && apt install -y curl wget tar bash sudo ca-certificates build-essential cmake zlib1g-dev libcppunit-dev git && \
    mkdir /backup /secrets /scripts && \
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
    chmod +x /usr/local/bin/argocd && \
    apt update && apt install -y kubectl && rm -rf /var/lib/apt/lists/*

RUN wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2k.tar.gz -O - | tar -xz
WORKDIR /openssl-1.0.2k
RUN ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl && make && make install

ADD argocd_export.sh /scripts/argocd_export.sh

RUN chmod +x /scripts/argocd_export.sh

ADD backup.key /secrets/

ENTRYPOINT ["/scripts/argocd_export.sh"]
