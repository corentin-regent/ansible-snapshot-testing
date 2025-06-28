#!/bin/bash

set -e

. .venv/bin/activate

ANSIBLE_LIMIT="$1"

if [[ -z "$ANSIBLE_LIMIT" ]]; then
   echo "Please provide the comma-separated ansible limit as the first command-line argument" >&2
   exit 1
fi

ansible-playbook \
  -i hosts.yml \
  --limit "$ANSIBLE_LIMIT" \
  snapshot.yml \
  -e "decrypted_snapshot_destination=snapshots/expected/decrypted" \
  -e "encrypted_snapshot_destination=snapshots/expected/encrypted"
