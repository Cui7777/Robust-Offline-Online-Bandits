# Processed real-world data

Place `_amazon_datas.csv`, `_movielens_datas.csv`, and `_yelp_datas.csv` here. Rating datasets are not bundled.

Required CSV header: `user,arm,reward`. Here `user` means **context group**, not an original reviewer ID. IDs must be `user=1,2` and `arm=1,...,20`, with at least one rating per context-arm pair and finite numeric rewards.

To prepare the paper's input format:
1. Select the 20 items with the largest numbers of ratings.
2. Sort each item's ratings chronologically; split into the first and second halves.
3. Encode those halves as contexts 1 and 2, and the selected items as arms 1 through 20. Keep each individual rating as a row; do not normalize the original rating scale.

The runner ranks arms by empirical mean separately within each context and samples offline ratings with replacement. It uses 2000 nominal offline observations per context at alpha=3. T is 5000 for Amazon and 10000 for MovieLens/Yelp. Exact reproduction requires the same dataset snapshot and tie/split conventions; no snapshot download is automated here.

Dataset sources: [Amazon movie reviews](https://snap.stanford.edu/data/web-Movies.html), [MovieLens](https://grouplens.org/datasets/movielens/), [Yelp](https://www.yelp.com/dataset).
