#!/usr/bin/env bash

set -xe

SNAPSHOT_NAME=${1}

if [ -z "$SNAPSHOT_NAME" ]; then
    echo "No snapshot name provided. Fetching the latest from S3..."
    SNAPSHOT_NAME=$(aws s3 ls s3://${S3_BUCKET}/ | sort | tail -n 1 | awk '{print $4}')
fi

echo "Downloading snapshot: ${SNAPSHOT_NAME}"
aws s3 cp s3://${S3_BUCKET}/${SNAPSHOT_NAME} /tmp/${SNAPSHOT_NAME}

echo "Authenticating to Vault via AWS IAM..."
LOGIN_JSON=$(vault login -method=aws \
    role=backup-role \
    -format=json)

export VAULT_TOKEN=$(echo $LOGIN_JSON | jq -r '.auth.client_token')

if [[ "$DEBUG" == "on" ]]; then
    vault token lookup
fi

echo "Starting Vault restoration..."
if [[ "$FORCE" == "on" ]]; then
    vault operator raft snapshot restore -force /tmp/${SNAPSHOT_NAME}
else
    vault operator raft snapshot restore /tmp/${SNAPSHOT_NAME}
fi

echo "Restore command sent successfully. Removing local file..."
rm /tmp/${SNAPSHOT_NAME}
