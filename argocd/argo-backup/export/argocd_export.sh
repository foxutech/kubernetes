#!/bin/bash -e

TIME=$(date +%F)
BACKUP_SCRIPT=$0
BACKUP_ACTION=export
BACKUP_LOCATION=azure
ARGOCD_NAMESPACE=${NAMESPACE}
BACKUP_FILENAME=argocd-backup-$TIME.yaml
BACKUP_EXPORT_LOCATION=/tmp/${BACKUP_FILENAME}
BACKUP_ENCRYPT_LOCATION=/backup/${BACKUP_FILENAME}
SECRETS_PATH=/secrets
BACKUP_KEY_LOCATION=${SECRETS_PATH}/backup.key
AZURE_STORAGE_ACCOUNT_NAME=${STORAGE_ACCOUNT_NAME}
AZURE_BLOB_CONTAINER_NAME=${BLOB_CONTAINER_NAME}
AZURE_SAS_TOKEN=${SAS_TOKEN}

export_argocd () {
    echo "exporting argo-cd"
    create_backup
    encrypt_backup
    install_azcopy
    push_backup
    echo "argo-cd export complete"
}

create_backup () {
    echo "creating argo-cd backup"
    echo $NAMESPACE
    argocd -n $NAMESPACE admin export > ${BACKUP_EXPORT_LOCATION}
    ls -lrt ${BACKUP_EXPORT_LOCATION}
}

encrypt_backup () {
    echo "encrypting argo-cd backup"
    openssl version
    /usr/local/openssl/bin/openssl enc -aes-256-cbc -salt -pass file:${BACKUP_KEY_LOCATION} -in ${BACKUP_EXPORT_LOCATION} -out ${BACKUP_ENCRYPT_LOCATION}
    ls -lrt ${BACKUP_ENCRYPT_LOCATION}
    rm ${BACKUP_EXPORT_LOCATION}
}

install_azcopy () {
        cd /tmp
        wget https://aka.ms/downloadazcopy-v10-linux
        tar -xvf downloadazcopy-v10-linux
        cp ./azcopy_linux_amd64_*/azcopy /usr/local/bin/
	rm -rf ./azcopy_linux_amd64_*/ downloadazcopy-v10-linux
}

push_backup () {
    case  ${BACKUP_LOCATION} in
        "azure")
            push_azure
            ;;
    esac
}

push_azure () {
    echo "pushing argo-cd backup to azure"
    echo "https://$AZURE_STORAGE_ACCOUNT_NAME.blob.core.windows.net/${AZURE_BLOB_CONTAINER_NAME}/$ARGOCD_NAMESPACE/$BACKUP_FILENAME?$AZURE_SAS_TOKEN"
    BLOB_PATH="https://${AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${AZURE_BLOB_CONTAINER_NAME}/$ARGOCD_NAMESPACE/?${AZURE_SAS_TOKEN}"
    echo $BLOB_PATH
    azcopy copy ${BACKUP_ENCRYPT_LOCATION} ${BLOB_PATH} --recursive=true
}

usage () {
    echo "usage: ${BACKUP_SCRIPT} export|import"
}

case  ${BACKUP_ACTION} in
    "export")
        export_argocd
        ;;
    *)
    usage
esac
