function summary = run_runtime(repetitions,dataDir,horizons,outputDir)
% Serial wall-clock timing of original real-data implementations, no trimming.
% CPU time is also recorded as a diagnostic. Original per-repeat output retained.
if nargin<1,repetitions=20;end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));addpath(fullfile(root,'utils'));
if nargin<2,dataDir=fullfile(root,'data');end
if nargin<3,horizons=[5000 10000 10000];end
validateattributes(repetitions,{'numeric'},{'scalar','integer','>=',2});
validateattributes(horizons,{'numeric'},{'row','numel',3,'integer','>=',40});
datasets={'amazon','movielens','yelp'};names={'VirUCB','RobVirUCB','EffVirUCB'};
fs={@Alg1_VirUCB,@Alg2_RobVirUCB,@Alg3_EffVirUCB};
records=cell(0,7);seconds=nan(3,3,repetitions);
out=fullfile(root,'results');if ~exist(out,'dir'),mkdir(out);end
if nargin>=4 && ~isempty(outputDir),out=outputDir;if ~exist(out,'dir'),mkdir(out);end,end
metadata=struct('matlab',version,'computer',computer,'horizons',horizons, ...
    'repetitions',repetitions,'alpha',3,'seed',20261013);
for d=1:3
    rng(20261013+d,'twister');[online,offline,params]=load_experiment(datasets{d},dataDir,horizons(d));
    save(fullfile(out,[datasets{d} '_runtime_inputs.mat']),'online','offline','params');
    for a=1:3,rng(20261013+100*d,'twister');[~,~,~]=fs{a}(params,online,offline);end
    for r=1:repetitions
        for a=mod((0:2)+r-1,3)+1
            rng(20261013+10000*d+r,'twister');cpu0=cputime;timer=tic;
            [g,~,rest]=fs{a}(params,online,offline);
            elapsed=toc(timer);cpu=cputime-cpu0;seconds(d,a,r)=elapsed;
            records(end+1,:)={datasets{d},names{a},r,elapsed,cpu,g(end),height(offline)-rest(end)};
            raw=cell2table(records,'VariableNames',{'Dataset','Algorithm','Repeat','Seconds','CPU_seconds','Final_regret','Offline_used'});
            writetable(raw,fullfile(out,'runtime_raw.csv'));
            save(fullfile(out,'runtime_results.mat'),'seconds','metadata');
        end
    end
end
rows=cell(0,7);
for d=1:3
    for a=1:3
        x=squeeze(seconds(d,a,:));
        rows(end+1,:)={datasets{d},names{a},repetitions,mean(x),std(x),median(x),horizons(d)};
    end
end
summary=cell2table(rows,'VariableNames',{'Dataset','Algorithm','N','Mean_seconds','SD_seconds','Median_seconds','T'});
writetable(summary,fullfile(out,'runtime_summary.csv'));disp(summary);
end
