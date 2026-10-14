function result = run_robustness(K,T,gamma,repetitions,outputDir)
% RUN_ROBUSTNESS Configurable two-context synthetic robustness experiment.
% Paper configurations: K=10,T=2000/4000 or K=100,T=20000; gamma=0.1/0.5.
if nargin<1,K=10;end
if nargin<2,T=2000;end
if nargin<3,gamma=0.1;end
if nargin<4,repetitions=[];end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(root,'algorithms'));
if nargin<5 || isempty(outputDir),outputDir=fullfile(root,'results');end
validateattributes(K,{'numeric'},{'scalar','integer','positive','finite'});
validateattributes(T,{'numeric'},{'scalar','integer','>=',2*K,'finite'});
validateattributes(gamma,{'numeric'},{'scalar','nonnegative','finite'});
algorithms={@UCB,@VirUCB,@RobVirUCB,@EffVirUCB,@HistoricalUCB};
if isempty(repetitions), repetitions = [200 500 1000 1000 1000]; end
if isscalar(repetitions), repetitions = repmat(repetitions,1,5); end
assert(numel(repetitions)==5 && all(repetitions>=1) && all(mod(repetitions,1)==0));

if ~exist(outputDir,'dir'), mkdir(outputDir); end
cfg.T = T; cfg.gamma = gamma; cfg.K = K;
cfg.alpha = linspace(-1,3,21); cfg.repetitions = repetitions;
cfg.seed = 20261013; cfg.nominalTotalOffline = cfg.gamma*cfg.T*cfg.K;
cfg.names = {'UCB','VirUCB','RobVirUCB','EffVirUCB','HistoricalUCB'};
cfg.clock = 'global count over both contexts, including consumed offline samples';
cfg.source = 'Original synthetic robustness implementation; see docs/IMPLEMENTATION.md';
cfg.historical = 'Tang Qiao thesis, Section 2.3.3, Fig.2.4 (printed page 15)';
stem = sprintf('robustness-K%d-T%d-gamma%g',K,T,gamma);
Rmax = max(repetitions); rng(cfg.seed,'twister');
% Share the same random environments across algorithms and alpha values.
environment = [sort(rand(Rmax,cfg.K),2,'descend'),sort(rand(Rmax,cfg.K),2,'descend')];
regrets = zeros(21,5); sem = regrets; actualOffline = zeros(21,1);
samples = cell(21,5); startTime = tic;
for ia = 1:21
    w = [0.1,1:cfg.K-1].^(-cfg.alpha(ia));
    I0 = round(w/sum(w)*round(cfg.gamma*cfg.T*cfg.K/2));
    actualOffline(ia) = 2*sum(I0);
    for method = 1:5
        % UCB has no alpha dependence: exactly reuse its reproducible rerun.
        if method==1 && ia>1
            samples{ia,method}=samples{1,method};
        else
            rng(cfg.seed+1000*method,'twister');
            samples{ia,method}=algorithms{method}(environment(1:repetitions(method),:),I0,cfg.T);
        end
        regrets(ia,method)=mean(samples{ia,method});
        sem(ia,method)=std(samples{ia,method})/sqrt(repetitions(method));
    end
    fprintf('%s alpha=%4.1f [%s] elapsed %.1fs\n',stem,cfg.alpha(ia),sprintf(' %.3f',regrets(ia,:)),toc(startTime));
    save(fullfile(outputDir,[stem '_checkpoint.mat']),'cfg','regrets','sem','samples','actualOffline','ia');
end
assert(all(isfinite(regrets(:))) && all(regrets(:)>=0) && all(regrets(:)<=cfg.T));
result=struct('config',cfg,'regrets',regrets,'standardError',sem,...
    'samples',{samples},'actualOffline',actualOffline,'elapsedSeconds',toc(startTime));
save(fullfile(outputDir,[stem '.mat']),'result');
tbl=array2table([cfg.alpha(:),actualOffline,regrets,sem], 'VariableNames',...
    {'alpha','ActualOffline','UCB','VirUCB','RobVirUCB','EffVirUCB','HistoricalUCB',...
     'UCB_SE','VirUCB_SE','RobVirUCB_SE','EffVirUCB_SE','HistoricalUCB_SE'});
writetable(tbl,fullfile(outputDir,[stem '.csv']));
drawResult(result,outputDir,stem);
fprintf('DONE %s (%.1f seconds)\n',stem,toc(startTime));
end

function drawResult(result,out,stem)
f=figure('Visible','off','Color','w','Units','inches','Position',[1 1 4.5 3.55],...
    'Renderer','painters');
ax=axes(f,'Position',[0.17 0.17 0.79 0.78]); hold(ax,'on');
markers={'*','^','s','o','d'};
for j=1:5
    plot(ax,result.config.alpha,result.regrets(:,j),'Color','k','LineStyle','--',...
        'Marker',markers{j},'MarkerSize',6,'LineWidth',1.35,'MarkerFaceColor','none');
end
set(ax,'FontName','Arial','FontSize',12,'FontWeight','bold','Box','on',...
    'TickDir','in','XLim',[-1 3],'XTick',-1:3,'YLim',[0 ceil(max(result.regrets(:))*1.12/50)*50]);
xlabel(ax,'\alpha','FontName','Times New Roman','FontSize',15,'FontWeight','normal');
ylabel(ax,'Regret','FontSize',14,'FontWeight','bold');
if result.config.gamma==0.1, location='southeast'; else, location='northwest'; end
legend(ax,result.config.names,'Location',location,'FontSize',10,'FontWeight','bold','Box','off');
set(f,'PaperUnits','inches','PaperPosition',[0 0 4.5 3.55],'PaperSize',[4.5 3.55]);
savefig(f,fullfile(out,[stem '.fig']));
print(f,fullfile(out,[stem '.eps']),'-depsc2','-painters');
print(f,fullfile(out,[stem '.pdf']),'-dpdf','-painters');
print(f,fullfile(out,[stem '.png']),'-dpng','-r180');
close(f);
end
