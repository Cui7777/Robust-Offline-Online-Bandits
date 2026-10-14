function regret = synthetic_kernel(mu,I0,T,method)
validateattributes(mu,{'numeric'},{'2d','real','finite','nonempty','>=',0,'<=',1});
assert(mod(size(mu,2),2)==0,'mu must contain two context blocks.');
K=size(mu,2)/2;
validateattributes(I0,{'numeric'},{'row','numel',K,'integer','nonnegative','finite'});
validateattributes(T,{'numeric'},{'scalar','integer','>=',2*K,'finite'});
assert(all(all(diff(mu(:,1:K),1,2)<=0)) && all(all(diff(mu(:,K+1:end),1,2)<=0)), ...
    'Each context block must be sorted by decreasing true mean.');
% Vectorize only the independent repetitions; retain original decision rules.
[R,C]=size(mu); K=C/2; rows=(1:R)';
N=zeros(R,C); S=N; remaining=repmat([I0,I0],R,1);
clock=zeros(R,1); regret=zeros(R,1);
best=[mu(:,1),mu(:,K+1)];
if method==5
    % All historical observations are independent Bernoulli samples.
    N=remaining;
    for col=1:C
        count=N(1,col);
        % Chunking bounds memory without any distributional approximation.
        for first=1:1024:count
            width=min(1024,count-first+1);
            S(:,col)=S(:,col)+sum(rand(R,width)<mu(:,col),2);
        end
    end
    clock=sum(N,2); remaining(:)=0; firstRound=1;
else
    % Original forced initialization: one online observation per context/arm.
    for t=1:C
        col=t; xt=1+(t>K); ix=rows+(col-1)*R;
        N(ix)=1; S(ix)=rand(R,1)<mu(ix); clock=clock+1;
        regret=regret+best(:,xt)-mu(ix);
    end
    firstRound=C+1;
end
for t=firstRound:T
    xt=1+(rand(R,1)>=0.5);
    pending=rows; action=zeros(R,1);
    while ~isempty(pending)
        ids=pending+(xt(pending)-1)*K*R+(0:K-1)*R;
        nn=N(ids); yy=S(ids)./max(nn,1);
        upper=yy+sqrt(2*log(max(clock(pending),1))./max(nn,1));
        upper(nn==0)=Inf; % Standard unobserved-arm convention.
        mx=max(upper,[],2);
        ties=abs(upper-mx)<1e-4 | (isinf(upper)&isinf(mx));
        rank=ceil(rand(numel(pending),1).*sum(ties,2)); rank=max(rank,1);
        a=1+sum(cumsum(ties,2)<rank,2);
        ix=pending+((xt(pending)-1)*K+a-1)*R;
        action(pending)=a;
        take=false(size(pending));
        if method>=2 && method<=4
            take=remaining(ix)>0;
            % RobVirUCB does not intervene in its first post-warm-up round.
            if method==4 || (method==3 && t>C+1)
                [~,greedy]=max(yy,[],2); take=take & a~=greedy;
            end
        end
        offlineRows=pending(take); offIx=ix(take);
        if ~isempty(offlineRows)
            S(offIx)=S(offIx)+(rand(numel(offIx),1)<mu(offIx));
            N(offIx)=N(offIx)+1; clock(offlineRows)=clock(offlineRows)+1;
            remaining(offIx)=remaining(offIx)-1;
        end
        pending=offlineRows;
    end
    ix=rows+((xt-1)*K+action-1)*R;
    S(ix)=S(ix)+(rand(R,1)<mu(ix)); N(ix)=N(ix)+1; clock=clock+1;
    regret=regret+best(rows+(xt-1)*R)-mu(ix);
end
assert(all(remaining(:)>=0) && all(S(:)>=0) && all(S(:)<=N(:)));
assert(all(sum(N,2)==clock));
if method==1, assert(all(clock==T)); end
if method==5, assert(all(clock==T+2*sum(I0))); end
if method>=2 && method<=4, assert(all(clock+sum(remaining,2)==T+2*sum(I0))); end
end

