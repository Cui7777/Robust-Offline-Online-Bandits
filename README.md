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

Use either `gamma=0.1` or `0.5` for each configuration. The imbalance grid is `-1:0.2:3`; default repetitions are **200/500/1000/1000/1000** for UCB/VirUCB/RobVirUCB/EffVirUCB/HistoricalUCB. Full runs, especially K=100, can be slow. If graphics export crashes on Windows, start MATLAB with `-softwareopengl` (used for release validation). MAT/CSV data and EPS/PDF/PNG figures are written to `results/`.

## Contents

- `algorithms/`: public synthetic algorithm entry points and the shared simulation kernel; `RobLRLinUCB.m` is the original **fixed-feature, two-arm example**, adapted from `lrlinucb.m`.
- `experiments/synthetic/`: one configurable robustness runner.
- `experiments/real_world/`: original table-based implementations, an alpha=3 experiment runner, and serial runtime measurement.
- `experiments/contextual/`: `run_contextual_example(1000,200)` compares no offline data with linear-regression virtual feedback. It does **not** reproduce the paper's random-context alpha-sweep figure.
- `utils/`, `data/`: offline-data preparation and dataset format instructions.

For real-data experiments, first provide the processed CSV files described in [data/README.md](data/README.md), then run:

```matlab
run_real_world('amazon',20);
run_runtime(20); % all three datasets, no automatic outlier removal
```

The nominal synthetic offline size is `gamma*T*K` **in total**, divided equally between two contexts; per-arm rounding may slightly change it. Runtime measurements exclude file loading, offline-data generation, and result saving, and include feedback simulation and trajectory recording. Use MATLAB's `-singleCompThread` option to match the original timing configuration.

HistoricalUCB follows Qiao Tang's *Research on Online Bandit Algorithms Based on Imbalanced Offline Data* (Chongqing University, 2022), Section 2.3.3, Figure 2.4, with a two-context adaptation. See [implementation notes](docs/IMPLEMENTATION.md) for provenance, initialization and scope. This is a compact representative release, not a complete archive of every paper figure. License: [MIT](LICENSE).
