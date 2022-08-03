#!/bin/bash -e

TIME=$(date '+%d-%m-%Y-09-52')
BACKUP_SCRIPT=$0
BACKUP_ACTION=import
BACKUP_LOCATION=azure
BACKUP_FILENAME=argocd-backup-$TIME.yaml
BACKUP_EXPORT_LOCATION=/restore/${BACKUP_FILENAME}
RESTORE_ENCRYPT_LOCATION=/tmp/${BACKUP_FILENAME}
SECRETS_PATH=/secrets
BACKUP_KEY_LOCATION=${SECRETS_PATH}/backup.key
STORAGE_ACCOUNT_NAME=foxutechacistorage
BLOB_CONTAINER_NAME=argocd
SAS_TOKEN="KEEP YOUR SAS TOKEN HERE"

import_argocd () {
    echo "importing argo-cd"
    install_azcopy
    pull_backup
    decrypt_backup
    load_backup
    echo "argo-cd import complete"
}

install_azcopy () {
        cd /tmp
        wget https://aka.ms/downloadazcopy-v10-linux
        tar -xvf downloadazcopy-v10-linux
        cp ./azcopy_linux_amd64_*/azcopy /usr/local/bin/
        rm -rf ./azcopy_linux_amd64_*/ downloadazcopy-v10-linux
}

pull_backup () {
    case  ${BACKUP_LOCATION} in
        "azure")
            pull_azure
            ;;
    esac
}

pull_azure () {
    echo "pulling argo-cd backup from azure"
    BACKUPFILE=${BACKUP_FILENAME}
    echo $BACKUPFILE
    BLOB_PATH="https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${BLOB_CONTAINER_NAME}/${BACKUPFILE}?${SAS_TOKEN}"
    echo $BLOB_PATH
    /usr/local/bin/azcopy cp $BLOB_PATH ${RESTORE_ENCRYPT_LOCATION} --recursive=true
}

decrypt_backup () {
    echo "decrypting argo-cd backup"
    openssl enc -d -aes-256-cbc -d -pass file:${BACKUP_KEY_LOCATION} -in ${RESTORE_ENCRYPT_LOCATION} -out ${BACKUP_EXPORT_LOCATION}
}

load_backup () {
    echo "loading argo-cd backup"
    argocd admin -n argocd import - < ${BACKUP_EXPORT_LOCATION}
}

usage () {
    echo "usage: ${BACKUP_SCRIPT} export|import"
}

case  ${BACKUP_ACTION} in
    "import")
        import_argocd
        ;;
    *)
    usage
esac
