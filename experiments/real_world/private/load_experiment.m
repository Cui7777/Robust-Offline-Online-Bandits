function [online,offline,params] = load_experiment(dataset,dataDir,T)
% Processed tables must use context IDs 1:2, arm IDs 1:20 and finite ratings.
assert(ismember(dataset,{'amazon','movielens','yelp'}),'Unknown dataset.');
path=fullfile(dataDir,['_',dataset,'_datas.csv']);
assert(isfile(path),'Missing processed data file: %s. See data/README.md.',path);
raw=readtable(path);
assert(all(ismember({'user','arm','reward'},raw.Properties.VariableNames)));
assert(isnumeric(raw.user)&&isnumeric(raw.arm)&&isnumeric(raw.reward));
assert(isequal(unique(raw.user),(1:2)') && isequal(unique(raw.arm),(1:20)'));
assert(all(isfinite(raw.reward)));
for u=1:2
    for a=1:20,assert(any(raw.user==u & raw.arm==a),'Each context-arm pair needs ratings.');end
end
[online,mu]=reindex_rewards(raw);
[offline,~]=prepare_offline_data(3,4000,online);
params=struct('user_name','user','action_name','arm','reward_name','reward', ...
    'user_num',2,'T',T,'K',20,'iterator_times',1,'optimal_arm',[1 1],'mu',mu);
end
