function run_smoke_tests
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);setup;
mu=[.8 .4 .2 .7 .5 .1;.9 .6 .2 .6 .3 .1];I=[8 2 0];T=60;
fs={@UCB,@VirUCB,@RobVirUCB,@EffVirUCB,@HistoricalUCB};
for a=1:5
    rng(7);x=fs{a}(mu,I,T);rng(7);y=fs{a}(mu,I,T);
    assert(isequal(x,y)&&isequal(size(x),[2 1])&&all(isfinite(x))&&all(x>=0)&all(x<=T));
    rng(7);z=fs{a}(.5*ones(2,6),I,T);assert(all(z==0));
end
rng(7);x=RobLRLinUCB(30,2,[20 0],2);rng(7);y=RobLRLinUCB(30,2,[20 0],2);
assert(isequal(x,y)&&all(isfinite(x))&&all(diff(x)>=-1e-12));
failed=false;try,RobLRLinUCB(30,3,[1 1 1],1);catch,failed=true;end;assert(failed);
% Artificial fixture exercises file loading and complete real-data pipelines.
tmp=tempname;mkdir(tmp);cleanup=onCleanup(@()rmdir(tmp,'s'));
[u,a,j]=ndgrid(1:2,1:20,1:3);user=u(:);arm=a(:);reward=mod(arm+j(:)+user,5)+1;
data=table(user,arm,reward);
for name={'amazon','movielens','yelp'},writetable(data,fullfile(tmp,['_',name{1},'_datas.csv']));end
r=run_real_world('amazon',1,tmp,45,fullfile(tmp,'results'));assert(isequal(size(r.regret),[1 45 3]));
s=run_runtime(2,tmp,[45 45 45],fullfile(tmp,'results'));assert(height(s)==9&&all(s.Mean_seconds>0));
fprintf('PASS: synthetic repeatability/zero regret, contextual checks, real-data and timing pipelines.\n');
end
