#!/bin/bash -e

TIME=$(date '+%d-%m-%Y-%H-%M')
BACKUP_SCRIPT=$0
BACKUP_ACTION=export
BACKUP_LOCATION=azure
BACKUP_FILENAME=argocd-backup-$TIME.yaml
BACKUP_EXPORT_LOCATION=/tmp/${BACKUP_FILENAME}
BACKUP_ENCRYPT_LOCATION=/backup/${BACKUP_FILENAME}
SECRETS_PATH=/secrets
BACKUP_KEY_LOCATION=${SECRETS_PATH}/backup.key
STORAGE_ACCOUNT_NAME=foxutechacistorage
BLOB_CONTAINER_NAME=argocd
SAS_TOKEN="KEEP YOUR SAS TOKEN HERE"

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
    argocd -n argocd admin export > ${BACKUP_EXPORT_LOCATION}
}

encrypt_backup () {
    echo "encrypting argo-cd backup"
    openssl enc -aes-256-cbc -salt -pass file:${BACKUP_KEY_LOCATION} -in ${BACKUP_EXPORT_LOCATION} -out ${BACKUP_ENCRYPT_LOCATION}
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
    azcopy cp ${BACKUP_ENCRYPT_LOCATION} 'https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${BLOB_CONTAINER_NAME}/${SAS_TOKEN}' --recursive=true
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
