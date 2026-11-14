#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for board_size in 3 4 5 6 7 8; do
  "${SCRIPT_DIR}/generate-model.sh" "${board_size}"
done
