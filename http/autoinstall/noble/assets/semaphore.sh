#!/bin/bash

exePath="$(dirname -- "${BASH_SOURCE[0]}")"
source "$exePath/semaphore.id"

semaphore_host="192.168.123.180:3000"
semaphore_project="Docker Desktops"
semaphore_template="Ubuntu Desktop - caching all roles"


curl -v -GET \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H "Authorization: Bearer $semaphore_token_ansible" \
http://${semaphore_host}/api/projects | jq > /mnt/projects.json

project_id=$(jq -r --arg project_name "$semaphore_project" '.[] | select(.name == $project_name) | .id' /mnt/projects.json)

curl -v -GET \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H "Authorization: Bearer $semaphore_token_ansible" \
http://${semaphore_host}/api/project/$project_id/templates | jq > /mnt/templates.json

template_id=$(jq -r --arg template_name "$semaphore_template" '.[] | select(.name == $template_name) | .id' /mnt/templates.json)

cat > /target/etc/systemd/system/semaphore_rollout.service <<EOF
[Unit]
Description=Send curl POST request to start the ansible semaphore rollout template
After=cloud-init.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c '[ -e /etc/cloud/cloud-init.disabled ] || exit 1;'
ExecStart=/usr/bin/curl -v -X POST \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'Authorization: Bearer ${semaphore_token_ansible}' \
  -d '{"template_id": ${template_id}, "debug": false, "dry_run": false, "diff": false, "playbook": "", "environment": "{}", "limit": ""}' \
  http://${semaphore_host}/api/project/${project_id}/tasks
ExecStartPost=/bin/sh -c '[ -e /etc/cloud/cloud-init.disabled ] || exit 1; \
  systemctl stop semaphore_rollout.timer; \
  sleep 2; \
  rm -f /etc/systemd/system/multi-user.target.wants/semaphore_rollout.timer; \
  rm -f /etc/systemd/system/semaphore_rollout.timer; \
  rm -f /etc/systemd/system/semaphore_rollout.service; \
  systemctl daemon-reload'

[Install]
WantedBy=multi-user.target
EOF

cat > /target/etc/systemd/system/semaphore_rollout.timer <<EOF
[Unit]
Description=Run semaphore_rollout.service every 10 seconds

[Timer]
OnBootSec=10s
OnUnitActiveSec=10s

[Install]
WantedBy=timers.target
EOF

curtin in-target --target=/target -- systemctl daemon-reload
curtin in-target --target=/target -- systemctl enable semaphore_rollout.timer
