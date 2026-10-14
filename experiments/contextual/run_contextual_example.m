function result = run_contextual_example(T,repetitions)
% Representative fixed-feature example; not a reproduction of the paper's alpha sweep.
if nargin<1,T=1000;end
if nargin<2,repetitions=200;end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(root,'algorithms'));
rng(20261013,'twister'); result.online=RobLRLinUCB(T,2,[0 0],repetitions);
rng(20261013,'twister'); result.augmented=RobLRLinUCB(T,2,[200 0],repetitions);
result.T=T; result.repetitions=repetitions;
out=fullfile(root,'results'); if ~exist(out,'dir'),mkdir(out);end
save(fullfile(out,'contextual_example.mat'),'result');
figure;plot(1:T,result.online,'k--',1:T,result.augmented,'k-','LineWidth',1.3);
xlabel('Round');ylabel('Regret');legend('No offline data','Linear-regression virtual feedback','Location','best');
end
