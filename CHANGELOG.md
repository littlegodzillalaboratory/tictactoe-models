# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
### Changed
- Strengthen per-board training configurations with larger networks, more
  samples, and longer training runs.
- Evaluate models across multiple seeds and reject generated models that miss
  quality thresholds for teacher agreement, tactical accuracy, legality, or
  game losses.
- Make 3×3 training converge more reliably across PyTorch environments and add
  NumPy explicitly for PyTorch initialization.
- Increase 4×4 model capacity and training duration to improve tactical
  accuracy, and report quality failures for all board sizes in one build.
- Calibrate teacher-agreement thresholds by board size and retain tactical
  accuracy as diagnostic metadata instead of a volatile release gate.
- Complete all seeded evaluations when a model fails so CI reports every
  quality result in one run.

## 0.10.0 - 2026-11-15
### Added
- Initial version
