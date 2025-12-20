#!/usr/bin/env bash

set -e

echo "Authenticating to Vault via AWS IAM..."
LOGIN_JSON=$(vault login -method=aws \
    role=backup-role \
    -format=json)

export VAULT_TOKEN=$(echo $LOGIN_JSON | jq -r '.auth.client_token')

if [[ "$DEBUG" == "on" ]]; then
    vault token lookup
fi

TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
BACKUP_NAME="vault-raft-snapshot-${TIMESTAMP}.tgz"

echo "Starting Vault snapshot..."
vault operator raft snapshot save /tmp/${BACKUP_NAME}

echo "Uploading to S3..."
aws s3 cp /tmp/${BACKUP_NAME} s3://${S3_BUCKET}/${BACKUP_NAME}

echo "Backup successful: ${BACKUP_NAME}"
rm /tmp/${BACKUP_NAME}
