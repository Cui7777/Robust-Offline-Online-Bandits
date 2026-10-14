function regret = RobVirUCB(mu, offlinePerArm, T)
% RobVirUCB: two-context Bernoulli simulation, one output per repetition.
% mu: R-by-(2*K), two descending-sorted blocks of true reward means.
% offlinePerArm: 1-by-K nonnegative counts, repeated for each context.
% T >= 2*K. Randomness uses the caller's RNG; see experiments/synthetic.
% The shared kernel preserves the original synthetic decision rules.
regret = synthetic_kernel(mu,offlinePerArm,T,3);
end
