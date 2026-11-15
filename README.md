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
├── ...
├── tictactoe-8x8-<version>.pt
├── tictactoe-8x8-training-<version>.json
└── tictactoe-8x8-evaluation-<version>.json
```

The training script uses a deterministic seed and selects the network size for
each board dimension. The committed script is the record of the parameters used
to produce the models. The version comes from the Makefile's `version` variable
and is included immediately before each generated file extension.

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
