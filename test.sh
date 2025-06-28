#!/bin/bash

set -e

. .venv/bin/activate

ACTUAL_SNAPSHOTS_DIR=snapshots/actual
DECRYPTED_EXPECTED_SNAPSHOTS_DIR=snapshots/expected/decrypted
ENCRYPTED_EXPECTED_SNAPSHOTS_DIR=snapshots/expected/encrypted

rm -rf "$ACTUAL_SNAPSHOTS_DIR"
rm -rf "$DECRYPTED_EXPECTED_SNAPSHOTS_DIR"

ansible-playbook \
  -i hosts.yml \
  snapshot.yml \
  -e "decrypted_snapshot_destination=$ACTUAL_SNAPSHOTS_DIR"

find "$ENCRYPTED_EXPECTED_SNAPSHOTS_DIR" -type f -printf '%P\n' | \
while read file; do
    dirname "$DECRYPTED_EXPECTED_SNAPSHOTS_DIR/$file" | xargs mkdir -p
    ansible-vault decrypt \
        --output "$DECRYPTED_EXPECTED_SNAPSHOTS_DIR/$file" \
        "$ENCRYPTED_EXPECTED_SNAPSHOTS_DIR/$file"
done

if ! diff -r "$ACTUAL_SNAPSHOTS_DIR" "$DECRYPTED_EXPECTED_SNAPSHOTS_DIR"; then
    echo "Error: Snapshot tests failed!" >&2
    exit 1
fi

echo "Snapshot tests passed successfully!"
