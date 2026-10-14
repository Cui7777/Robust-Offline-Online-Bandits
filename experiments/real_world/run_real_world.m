function result = run_real_world(dataset,repetitions,dataDir,T,outputDir)
% Original real-data algorithms at alpha=3; default T follows each dataset.
if nargin<1,dataset='amazon';end
if nargin<2,repetitions=20;end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));addpath(fullfile(root,'utils'));
if nargin<3,dataDir=fullfile(root,'data');end
if nargin<4,T=10000;if strcmp(dataset,'amazon'),T=5000;end,end
validateattributes(T,{'numeric'},{'scalar','integer','>=',40});
validateattributes(repetitions,{'numeric'},{'scalar','integer','positive'});
rng(20261013,'twister');[online,offline,params]=load_experiment(dataset,dataDir,T);
names={'VirUCB','RobVirUCB','EffVirUCB'}; fs={@Alg1_VirUCB,@Alg2_RobVirUCB,@Alg3_EffVirUCB};
regret=zeros(repetitions,T,3); usage=regret;
for r=1:repetitions
    for a=1:3
        rng(20261013+r,'twister');[g,~,rest]=fs{a}(params,online,offline);
        regret(r,:,a)=g;usage(r,:,a)=height(offline)-rest;
    end
end
result=struct('dataset',dataset,'params',params,'alpha',3,'names',{names}, ...
    'regret',regret,'usage',usage,'offline',offline,'seed',20261013);
out=fullfile(root,'results');if ~exist(out,'dir'),mkdir(out);end
if nargin>=5 && ~isempty(outputDir),out=outputDir;if ~exist(out,'dir'),mkdir(out);end,end
save(fullfile(out,[dataset '_alpha3.mat']),'result');
end
