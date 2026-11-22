![Avatar](avatar.jpg)

[![Build Status](https://github.com/littlegodzillalaboratory/wayang-tactics/actions/workflows/ci-workflow.yaml/badge.svg)](https://github.com/littlegodzillalaboratory/wayang-tactics/actions/workflows/ci-workflow.yaml)

# TicTacToe Models

TicTacToe Models generates trained policy models and evaluation metadata for
configurable-size Tic-Tac-Toe boards from 3×3 through 8×8. Model training and
evaluation are provided by the published [TicTacToe Policy](https://pypi.org/project/tictactoe-policy/) Python package.

## Installation

Create a virtual environment and install the pinned dependencies:

```shell
make deps
```

Model quality validation also requires `jq`; the Studio development image
installs it through `make deps-extra-apt`.

## Usage

Generate one model and its reports:

```shell
make gen BOARD_SIZE=3
```

Generate models for every supported board size:

```shell
make gen-all
```

Remove generated files:

```shell
make clean
```

Generated files are written to `stage/`:

```text
stage/
├── tictactoe-3x3-<version>.pt
├── tictactoe-3x3-training-<version>.json
├── tictactoe-3x3-evaluation-<version>.json
├── tictactoe-3x3-evaluation-seed314-<version>.json
├── tictactoe-3x3-evaluation-seed2718-<version>.json
├── ...
├── tictactoe-8x8-<version>.pt
├── tictactoe-8x8-training-<version>.json
└── tictactoe-8x8-evaluation-<version>.json
```

The training script uses a deterministic seed and selects the network size for
each board dimension. The committed script is the record of the parameters used
to produce the models. The version comes from the Makefile's `version` variable
and is included immediately before each generated file extension.

## Training Configuration

| Board | Hidden units | Samples | Search depth | Epochs | Learning rate |
| ----- | -----------: | ------: | -----------: | -----: | ------------: |
| 3×3 | 256 | exhaustive | exact | 2,000 | 0.01 |
| 4×4 | 256 | 50,000 | 4 | 1,000 | 0.005 |
| 5×5 | 256 | 75,000 | 3 | 300 | 0.005 |
| 6×6 | 256 | 100,000 | 3 | 300 | 0.005 |
| 7×7 | 256 | 125,000 | 3 | 300 | 0.005 |
| 8×8 | 512 | 150,000 | 3 | 300 | 0.005 |

Every model is evaluated with 100 games per opponent and player assignment
using seeds 42, 314, and 2718. Generation fails if any report misses its
minimum teacher agreement, legality, or loss thresholds.
This prevents a release from publishing a model merely because training
completed successfully.

Immediate-win and required-block accuracy remain in the evaluation reports as
diagnostic measurements. They are not independent release gates: the sampled
rates can have small denominators, and a required-block position can contain
multiple simultaneous threats that no move can block. Teacher agreement and
complete games provide the stable acceptance signals.

The stronger 3×3 candidate reached 100% optimal-move agreement, 100%
immediate-win accuracy, and no losses against either random or perfect-minimax
opponents. Generation still verifies these results in the build environment
before accepting the model.

The stronger 4×4 candidate reached 95.7% teacher agreement, 96.5%
immediate-win accuracy, 99.7% required-block accuracy, and no losses in 400
evaluation games. `gen-all` completes every board-size attempt and reports all
quality failures across every board size and evaluation seed before returning a
failed status.

| Board | Agreement | Random losses | Teacher losses |
| ----- | --------: | ------------: | -------------: |
| 3×3 | 100% | 0 | 0 |
| 4×4 | 90% | ≤5 | ≤15 |
| 5×5 | 75% | ≤5 | ≤15 |
| 6×6 | 75% | ≤5 | ≤15 |
| 7×7 | 72% | ≤5 | ≤15 |
| 8×8 | 75% | ≤5 | ≤15 |

Loss limits apply independently to games played as X and O in every evaluation
report. All three seeded reports must pass before generation succeeds.

## Models

Each `.pt` file is a `tictactoe-policy` checkpoint containing the trained
network weights, checkpoint format version, board size, winning length, and
hidden-layer size. Load a generated model with the published package:

```python
from tictactoe_policy import TicTacToePolicy

policy = TicTacToePolicy.load("stage/tictactoe-3x3-<version>.pt")
move = policy.choose_move([
    1, -1, 0,
    0, 1, 0,
    -1, 0, 0,
])
```
