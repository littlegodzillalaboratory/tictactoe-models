# TicTacToe Models

TicTacToe Models generates trained policy models and evaluation metadata for
configurable-size Tic-Tac-Toe boards from 3×3 through 8×8. Model training and
evaluation are provided by the published `tictactoe-policy` Python package.

## Installation

Create a virtual environment and install the pinned dependencies:

```shell
make deps
```

## Usage

Generate one model and its reports:

```shell
make model BOARD_SIZE=3
```

Generate models for every supported board size:

```shell
make models
```

Remove the virtual environment and generated files:

```shell
make clean
```

Generated files are written to `stage/`:

```text
stage/
├── tictactoe-3x3.pt
├── tictactoe-3x3-training.json
├── tictactoe-3x3-evaluation.json
├── ...
├── tictactoe-8x8.pt
├── tictactoe-8x8-training.json
└── tictactoe-8x8-evaluation.json
```

The training script uses a deterministic seed and selects the network size for
each board dimension. The committed script is the record of the parameters used
to produce the models.

## Models

Each `.pt` file is a `tictactoe-policy` checkpoint containing the trained
network weights, checkpoint format version, board size, winning length, and
hidden-layer size. Load a generated model with the published package:

```python
from tictactoe_policy import TicTacToePolicy

policy = TicTacToePolicy.load("stage/tictactoe-3x3.pt")
move = policy.choose_move([
    1, -1, 0,
    0, 1, 0,
    -1, 0, 0,
])
```
