#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <board-size>" >&2
  exit 1
fi

BOARD_SIZE="$1"
case "${BOARD_SIZE}" in
  3)
    HIDDEN_SIZE=16
    ;;
  4)
    HIDDEN_SIZE=32
    ;;
  5)
    HIDDEN_SIZE=64
    ;;
  6 | 7 | 8)
    HIDDEN_SIZE=128
    ;;
  *)
    echo "Board size must be between 3 and 8." >&2
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
POLICY_COMMAND="${PROJECT_DIR}/.venv/bin/tictactoe-policy"
OUTPUT_DIR="${PROJECT_DIR}/stage"
MODEL_PATH="${OUTPUT_DIR}/tictactoe-${BOARD_SIZE}x${BOARD_SIZE}.pt"
TRAINING_PATH="${OUTPUT_DIR}/tictactoe-${BOARD_SIZE}x${BOARD_SIZE}-training.json"
EVALUATION_PATH="${OUTPUT_DIR}/tictactoe-${BOARD_SIZE}x${BOARD_SIZE}-evaluation.json"

if [[ ! -x "${POLICY_COMMAND}" ]]; then
  echo "Missing ${POLICY_COMMAND}. Install requirements into .venv first." >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

"${POLICY_COMMAND}" train \
  --board-size "${BOARD_SIZE}" \
  --hidden-size "${HIDDEN_SIZE}" \
  --samples 10000 \
  --search-depth 3 \
  --epochs 50 \
  --learning-rate 0.01 \
  --seed 42 \
  --output "${MODEL_PATH}" \
  > "${TRAINING_PATH}"

"${POLICY_COMMAND}" evaluate \
  --model "${MODEL_PATH}" \
  --samples 1000 \
  --search-depth 3 \
  --games 20 \
  --seed 42 \
  > "${EVALUATION_PATH}"

echo "Generated ${MODEL_PATH}"
echo "Training report: ${TRAINING_PATH}"
echo "Evaluation report: ${EVALUATION_PATH}"
