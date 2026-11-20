#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <board-size>" >&2
  exit 1
fi

BOARD_SIZE="$1"
MODEL_VERSION="${MODEL_VERSION:?MODEL_VERSION is required}"

if [[ ! "${MODEL_VERSION}" =~ ^[0-9A-Za-z][0-9A-Za-z.+-]*$ ]]; then
  echo "MODEL_VERSION contains unsupported filename characters." >&2
  exit 1
fi

case "${BOARD_SIZE}" in
  3)
    HIDDEN_SIZE=128
    SAMPLE_COUNT=10000
    SEARCH_DEPTH=3
    EPOCH_COUNT=500
    LEARNING_RATE=0.01
    EVALUATION_SAMPLES=1000
    MIN_AGREEMENT=0.995
    MIN_WIN_ACCURACY=0.99
    MIN_BLOCK_ACCURACY=0.95
    MAX_RANDOM_LOSSES=0
    MAX_TEACHER_LOSSES=0
    ;;
  4)
    HIDDEN_SIZE=128
    SAMPLE_COUNT=50000
    SEARCH_DEPTH=4
    EPOCH_COUNT=300
    LEARNING_RATE=0.005
    EVALUATION_SAMPLES=5000
    MIN_AGREEMENT=0.85
    MIN_WIN_ACCURACY=0.90
    MIN_BLOCK_ACCURACY=0.90
    MAX_RANDOM_LOSSES=5
    MAX_TEACHER_LOSSES=15
    ;;
  5)
    HIDDEN_SIZE=256
    SAMPLE_COUNT=75000
    SEARCH_DEPTH=3
    EPOCH_COUNT=300
    LEARNING_RATE=0.005
    EVALUATION_SAMPLES=5000
    MIN_AGREEMENT=0.85
    MIN_WIN_ACCURACY=0.90
    MIN_BLOCK_ACCURACY=0.90
    MAX_RANDOM_LOSSES=5
    MAX_TEACHER_LOSSES=15
    ;;
  6)
    HIDDEN_SIZE=256
    SAMPLE_COUNT=100000
    SEARCH_DEPTH=3
    EPOCH_COUNT=300
    LEARNING_RATE=0.005
    EVALUATION_SAMPLES=5000
    MIN_AGREEMENT=0.82
    MIN_WIN_ACCURACY=0.90
    MIN_BLOCK_ACCURACY=0.90
    MAX_RANDOM_LOSSES=5
    MAX_TEACHER_LOSSES=15
    ;;
  7)
    HIDDEN_SIZE=256
    SAMPLE_COUNT=125000
    SEARCH_DEPTH=3
    EPOCH_COUNT=300
    LEARNING_RATE=0.005
    EVALUATION_SAMPLES=5000
    MIN_AGREEMENT=0.82
    MIN_WIN_ACCURACY=0.90
    MIN_BLOCK_ACCURACY=0.90
    MAX_RANDOM_LOSSES=5
    MAX_TEACHER_LOSSES=15
    ;;
  8)
    HIDDEN_SIZE=512
    SAMPLE_COUNT=150000
    SEARCH_DEPTH=3
    EPOCH_COUNT=300
    LEARNING_RATE=0.005
    EVALUATION_SAMPLES=5000
    MIN_AGREEMENT=0.82
    MIN_WIN_ACCURACY=0.90
    MIN_BLOCK_ACCURACY=0.90
    MAX_RANDOM_LOSSES=5
    MAX_TEACHER_LOSSES=15
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
MODEL_PATH="${OUTPUT_DIR}/tictactoe-${BOARD_SIZE}x${BOARD_SIZE}-${MODEL_VERSION}.pt"
TRAINING_PATH="${OUTPUT_DIR}/tictactoe-${BOARD_SIZE}x${BOARD_SIZE}-training-${MODEL_VERSION}.json"
EVALUATION_PATH="${OUTPUT_DIR}/tictactoe-${BOARD_SIZE}x${BOARD_SIZE}-evaluation-${MODEL_VERSION}.json"

validate_evaluation() {
  local report_path="$1"
  if ! jq --exit-status \
    --argjson agreement "${MIN_AGREEMENT}" \
    --argjson win_accuracy "${MIN_WIN_ACCURACY}" \
    --argjson block_accuracy "${MIN_BLOCK_ACCURACY}" \
    --argjson random_losses "${MAX_RANDOM_LOSSES}" \
    --argjson teacher_losses "${MAX_TEACHER_LOSSES}" \
    '
      .illegal_move_rate == 0 and
      .move_agreement >= $agreement and
      .immediate_win_accuracy >= $win_accuracy and
      .required_block_accuracy >= $block_accuracy and
      .games_vs_random_as_x.losses <= $random_losses and
      .games_vs_random_as_o.losses <= $random_losses and
      .games_vs_teacher_as_x.losses <= $teacher_losses and
      .games_vs_teacher_as_o.losses <= $teacher_losses
    ' "${report_path}" > /dev/null; then
    echo "Model quality gate failed: ${report_path}" >&2
    jq '.' "${report_path}" >&2
    return 1
  fi
}

if [[ ! -x "${POLICY_COMMAND}" ]]; then
  echo "Missing ${POLICY_COMMAND}. Install requirements into .venv first." >&2
  exit 1
fi
if ! command -v jq > /dev/null 2>&1; then
  echo "jq is required to validate model evaluation reports." >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

"${POLICY_COMMAND}" train \
  --board-size "${BOARD_SIZE}" \
  --hidden-size "${HIDDEN_SIZE}" \
  --samples "${SAMPLE_COUNT}" \
  --search-depth "${SEARCH_DEPTH}" \
  --epochs "${EPOCH_COUNT}" \
  --learning-rate "${LEARNING_RATE}" \
  --seed 42 \
  --output "${MODEL_PATH}" \
  > "${TRAINING_PATH}"

for evaluation_seed in 42 314 2718; do
  report_path="${OUTPUT_DIR}/tictactoe-${BOARD_SIZE}x${BOARD_SIZE}"
  report_path="${report_path}-evaluation-seed${evaluation_seed}-${MODEL_VERSION}.json"
  if [[ "${evaluation_seed}" == "42" ]]; then
    report_path="${EVALUATION_PATH}"
  fi
  "${POLICY_COMMAND}" evaluate \
    --model "${MODEL_PATH}" \
    --samples "${EVALUATION_SAMPLES}" \
    --search-depth "${SEARCH_DEPTH}" \
    --games 100 \
    --seed "${evaluation_seed}" \
    > "${report_path}"
  validate_evaluation "${report_path}"
  echo "Evaluation report: ${report_path}"
done

echo "Generated ${MODEL_PATH}"
echo "Training report: ${TRAINING_PATH}"
