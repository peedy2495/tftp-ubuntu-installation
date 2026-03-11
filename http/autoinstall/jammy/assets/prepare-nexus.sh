#!/bin/bash
set -euo pipefail

exePath="$(dirname -- "${BASH_SOURCE[0]}")"

source $exePath/.semaphore_vars
source $exePath/.semaphore_token

REPO_GROUPS="$(echo "$REPO_GROUPS" | sed -E 's/[[:space:]]*,[[:space:]]*/,/g')"

PROJECT_ID="$(curl -sS -H "Authorization: Bearer $SEMAPHORE_TOKEN" \
  "$SEMAPHORE_URL/api/projects" | jq -r ".[] | select(.name==\"$PROJECT_NAME\") | .id")"

TEMPLATE_ID="$(curl -sS -H "Authorization: Bearer $SEMAPHORE_TOKEN" \
  "$SEMAPHORE_URL/api/project/$PROJECT_ID/templates" | jq -r ".[] | select(.name==\"$TEMPLATE_NAME\") | .id")"

ENV_JSON="$(jq -cn \
  --argjson groups "$(jq -n --arg groups "$REPO_GROUPS" '$groups | split(",")')" \
  "{repository_groups:\$groups}")"

curl -sS -X POST \
  -H "Authorization: Bearer $SEMAPHORE_TOKEN" \
  -H "Content-Type: application/json" \
  "$SEMAPHORE_URL/api/project/$PROJECT_ID/tasks" \
  -d "$(jq -cn --argjson tid "$TEMPLATE_ID" --arg env "$ENV_JSON" "{template_id:\$tid, environment:\$env}")"
