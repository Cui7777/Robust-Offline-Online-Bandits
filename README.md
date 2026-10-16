# Robust Offline-Online Bandits

Representative MATLAB implementations for **Unify Offline Causal Inference and Online Multi-armed Bandit Learning Robustly and Efficiently**.

## Quick start

Tested with MATLAB R2023a; the supplied serial runners do not require Parallel Computing Toolbox. From the repository root:

```matlab
setup
run_smoke_tests
run_robustness(10, 2000, 0.1, 5); % quick demonstration, 5 repetitions per method
```

For the full synthetic configurations, omit the repetition override:

```matlab
run_robustness(10, 2000, 0.1);
run_robustness(10, 4000, 0.5);
run_robustness(100, 20000, 0.1);
```

Use either `gamma=0.1` or `0.5` for each configuration. The imbalance grid is `-1:0.2:3`. Full runs, especially K=100, can be slow. If graphics export crashes on Windows, start MATLAB with `-softwareopengl` (used for release validation). MAT/CSV data and EPS/PDF/PNG figures are written to `results/`.

## Contents

- `algorithms/`: public synthetic algorithm entry points and the shared simulation kernel.
- `experiments/synthetic/`: one configurable robustness runner.
- `experiments/real_world/`: original table-based implementations, an alpha=3 experiment runner, and serial runtime measurement.
- `experiments/contextual/`: `run_contextual_example(1000,200)` compares no offline data with linear-regression virtual feedback. 
- `utils/`, `data/`: offline-data preparation and dataset format instructions.

For real-data experiments, first provide the processed CSV files described in [data/README.md](data/README.md), then run:

```matlab
run_real_world('amazon',20);
run_runtime(20); % all three datasets, no automatic outlier removal
```



