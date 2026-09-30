#!/bin/bash

IMDS="http://169.254.169.254/latest"

# Obtém token IMDSv2
TOKEN=$(curl -sS --fail \
    --connect-timeout 2 \
    --max-time 5 \
    -X PUT \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
    "$IMDS/api/token") || {
    echo "{}"
    exit 0
}

# Obtém lista de tags
TAG_KEYS=$(curl -sS --fail \
    --connect-timeout 2 \
    --max-time 5 \
    -H "X-aws-ec2-metadata-token: $TOKEN" \
    "$IMDS/meta-data/tags/instance/") || {
    echo "{}"
    exit 0
}

TAGS_JSON="{}"

while IFS= read -r KEY; do

    # Ignora linhas vazias
    [ -z "$KEY" ] && continue

    VALUE=$(curl -sS --fail \
        --connect-timeout 2 \
        --max-time 5 \
        -H "X-aws-ec2-metadata-token: $TOKEN" \
        "$IMDS/meta-data/tags/instance/$KEY") || continue

    TAGS_JSON=$(echo "$TAGS_JSON" | jq \
        --arg key "$KEY" \
        --arg value "$VALUE" \
        '. + {($key): $value}')

done <<< "$TAG_KEYS"

echo "$TAGS_JSON"
