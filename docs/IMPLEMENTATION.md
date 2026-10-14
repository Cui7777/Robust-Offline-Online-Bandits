# Implementation and provenance

## Synthetic algorithms

The synthetic kernel is extracted from the validated revision experiment `run_robustness_T2000_gamma01.m`, which vectorizes independent repetitions of the original `21-aaai-Figure/02 Robustness/Alg0_UCB.m` through `Alg3_EffVirUCB.m`. Public algorithm files select a method in this shared kernel, avoiding five duplicate simulation loops. The configurable runner preserves the seed schedule, original drawing code, and arithmetic; it runs serially.

Each input row has two blocks of K means, sorted in descending order within each context. Rewards are Bernoulli, contexts equiprobable, and regret is accumulated only for online actions. The original four algorithms first take one online observation per context-arm pair. RobVirUCB does not filter its first post-initialization round; EffVirUCB filters immediately. UCB ties within 1e-4 are randomized. The logarithmic clock counts observations across both contexts; offline samples contribute when consumed.

HistoricalUCB instead incorporates all offline samples before online play. Counts/means are per context-arm pair, and its confidence clock is global across contexts. An unobserved arm has infinite index. It has no forced online initialization. This adaptation follows the pseudocode in Tang (2022), Section 2.3.3 / Figure 2.4; it is not an official upstream HistoricalUCB package.

The root runner uses seed 20261013 to generate common reward-mean environments and seed `20261013+1000*method` for each algorithm, reset at each alpha. Methods with fewer repetitions use a prefix of the environments. Changing repetition counts changes the generated environments; small runs are demonstrations, not the published full-run values.

## Real-world algorithms

`experiments/real_world/private/Alg1_VirUCB.m`, `Alg2_RobVirUCB.m`, and `Alg3_EffVirUCB.m` retain the original source from `21-01-30-update-RobVirUCB/8 real_data_experiment_update_get_offline_data/`. Preparation helpers have only been renamed. Wrappers validate inputs and set seeds. These original routines use per-context confidence clocks and draw a context at each virtual-play attempt; they are not interchangeable with the synthetic kernel.

Runtime calls use one full warmup per algorithm/dataset, rotating execution order, and matched seeds across algorithms within each repeat. All wall-clock observations are saved without filtering; CPU times are diagnostics. This measures the complete implementation, including table-based feedback simulation, rather than isolated decision cost. Machine load and sampling can affect times; no speed ordering is guaranteed.

## Rob-LRLinUCB representative example

`RobLRLinUCB.m` is adapted from `20-12-27-update-RobVirUCB/1 example/lrlinucb.m`. The file is named by its confidence-width gating mechanism, not by the old filename. It fits offline ridge regression, compares the candidate post-update confidence width with the offline width, adds a predicted virtual outcome when appropriate, and incorporates real online rewards. It fixes K=2, d=2, feature matrix=identity, and theta=[0.8;0.2]. It is not a general random-context runner.

Packaging changes: renamed entry point, optional repetition count, explicit input checks, suppressed progress printing, and removal of unused offline-consumption outputs (the original counters did not track virtual predictions). The decision/reward/update arithmetic is retained. The older `roblrlinucb.m` with its extra UCB-argmax filter is not used. This example is not claimed to reproduce the contextual robustness figure.

## Validation

Run `setup; run_smoke_tests`. This checks repeatability and zero-regret cases, exercises all five public synthetic entry points, the contextual example, and real-world runners on a temporary artificial fixture. The fixture is only a software test and never represents Amazon, MovieLens, or Yelp results. Additional release checks compared extracted/refactored code with the local original implementations under matched random seeds.
