#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failed=0

for board_size in 3 4 5 6 7 8; do
  if ! "${SCRIPT_DIR}/generate-model.sh" "${board_size}"; then
    echo "Model generation failed for ${board_size}x${board_size}." >&2
    failed=1
  fi
done

exit "${failed}"
