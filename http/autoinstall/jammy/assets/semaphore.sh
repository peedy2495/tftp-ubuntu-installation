#!/bin/bash
set -euo pipefail

trap 'echo "ERROR: semaphore.sh line ${LINENO}, exit code $?" >&2' ERR

exePath="$(dirname -- "${BASH_SOURCE[0]}")"
source "$exePath/semaphore.id"

semaphore_host="192.168.123.180:3000"
semaphore_project="Docker Desktops"
semaphore_template="Ubuntu Desktop - caching all roles"

# Projekt-ID ermitteln
project_id=$(curl -fsS \
  -H "Authorization: Bearer ${semaphore_token_ansible}" \
  "http://${semaphore_host}/api/projects" \
  | jq -er --arg name "$semaphore_project" \
    '.[] | select(.name == $name) | .id')

# Template-ID ermitteln
template_id=$(curl -fsS \
  -H "Authorization: Bearer ${semaphore_token_ansible}" \
  "http://${semaphore_host}/api/project/${project_id}/templates" \
  | jq -er --arg name "$semaphore_template" \
    '.[] | select(.name == $name) | .id')

echo "Project ID: $project_id"
echo "Template ID: $template_id"

# Verzeichnisse im Zielsystem vorbereiten
install -d /target/usr/local/sbin
install -d /target/etc/systemd/system

# Geschützte Konfigurationsdatei erstellen
(
  umask 077
  printf 'semaphore_host=%q\n' "$semaphore_host"
  printf 'semaphore_token_ansible=%q\n' "$semaphore_token_ansible"
  printf 'project_id=%q\n' "$project_id"
  printf 'template_id=%q\n' "$template_id"
) > /target/etc/semaphore_rollout.conf

chmod 600 /target/etc/semaphore_rollout.conf

# Rollout-Script erstellen
cat > /target/usr/local/sbin/semaphore_rollout.sh <<'EOF'
#!/bin/bash
set -euo pipefail

source /etc/semaphore_rollout.conf

# Cloud-Init prüfen
if [[ ! -e /var/lib/cloud/instance/boot-finished ]]; then
  echo "Cloud-init not finished. Retrying later."
  exit 1
fi

echo "Cloud-init finished. Starting Semaphore task."

# Semaphore-Task starten
if ! response=$(curl -fsS -X POST \
  --connect-timeout 10 \
  --max-time 30 \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${semaphore_token_ansible}" \
  -d "$(jq -n --argjson id "$template_id" \
    '{template_id: $id, debug: false, dry_run: false, diff: false, playbook: "", environment: "{}", limit: ""}')" \
  "http://${semaphore_host}/api/project/${project_id}/tasks"); then

  echo "ERROR: Semaphore API request failed."
  exit 1
fi

# Semaphore-Antwort validieren
if ! echo "$response" | jq -e \
  --argjson pid "$project_id" \
  --argjson tid "$template_id" \
  '(.id | type == "number" and . > 0) and
   (.project_id == $pid) and
   (.template_id == $tid)' >/dev/null; then

  echo "ERROR: Invalid Semaphore API response."
  exit 1
fi

# Task-ID und Status protokollieren
task_id=$(echo "$response" | jq -r '.id')
task_status=$(echo "$response" | jq -r '.status')

echo "SUCCESS: Semaphore task ${task_id} created."
echo "Task status: ${task_status}"

EOF

chmod 700 /target/usr/local/sbin/semaphore_rollout.sh

# Systemd-Service erstellen
cat > /target/etc/systemd/system/semaphore_rollout.service <<'EOF'
[Unit]
Description=Start Semaphore rollout after cloud-init
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=0

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/semaphore_rollout.sh
ExecStartPost=/usr/bin/systemctl disable --now semaphore_rollout.timer
ExecStartPost=/usr/bin/rm -f /etc/systemd/system/semaphore_rollout.timer /etc/systemd/system/semaphore_rollout.service /usr/local/sbin/semaphore_rollout.sh /etc/semaphore_rollout.conf
ExecStartPost=/usr/bin/systemctl daemon-reload
StandardOutput=journal
StandardError=journal
EOF

# Systemd-Timer erstellen
cat > /target/etc/systemd/system/semaphore_rollout.timer <<'EOF'
[Unit]
Description=Retry Semaphore rollout every 10 seconds

[Timer]
OnBootSec=10s
OnUnitInactiveSec=10s
AccuracySec=1s
Unit=semaphore_rollout.service

[Install]
WantedBy=timers.target
EOF

# Timer für den ersten Boot aktivieren
curtin in-target --target=/target -- systemctl enable semaphore_rollout.timer
