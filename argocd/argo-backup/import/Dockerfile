FROM ubuntu:18.04

RUN apt update && apt install -y curl wget tar bash openssl && mkdir /restore /secrets /scripts && \
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd

#ADD azcopy /usr/local/bin/azcopy
ADD argocd_import.sh /scripts/argocd_import.sh

RUN chmod +x /scripts/argocd_import.sh

ADD backup.key /secrets/

ENTRYPOINT ["/scripts/argocd_import.sh"]
