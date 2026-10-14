function E_regrets = RobLRLinUCB(arg_T, arg_K, arg_I, repetitions)
% Representative fixed-feature example adapted from the original lrlinucb.m.
% Two arms, d=2, theta=[0.8;0.2], x=eye(2); not the alpha-sweep figure.
% Returns only online cumulative pseudo-regret. Virtual predictions do not
% consume discrete rows; the old unused data-consumption counters are omitted.
if nargin<4, repetitions=200; end
validateattributes(arg_T,{'numeric'},{'scalar','integer','positive'});
assert(isequal(arg_K,2),'This original example supports exactly two arms.');
validateattributes(arg_I,{'numeric'},{'row','numel',2,'integer','nonnegative','finite'});
validateattributes(repetitions,{'numeric'},{'scalar','integer','positive'});
% the classic ucb algorithm
% input: T the number of time round
%       K the number of action
%       I the number of logged data of each arm

T = arg_T;
K = arg_K;  % the number of arms(actions)

E_regrets = zeros(1,T);

I0 = arg_I;

for repeat=1:repetitions



    d = 2;

    theta = [0.8; 0.2];
    x = [1, 0; 0, 1];

    Mu = theta' * x; % expect reward of the arms
    Mu_max = max(Mu);

    I = I0;

    regret = 0;
    regrets = zeros(1,T);

    V = eye(d);
    b = zeros(d, 1);
    beta = 1 + sqrt(2*log(1+1)+log(det(V)));

    n = 1;

    V_offline = eye(d);
    b_offline = zeros(d, 1);
    % init
    for k=1:K
        Ii = I(k);
        for i=1:Ii
            xk = x(:, k);
            y = getReward(Mu(k));
            V_offline = V_offline + xk*xk';
            b_offline = b_offline + y * xk;
        end
    end
    theta_hat_offline = V_offline \ b_offline;


    for t=1:T

        % the offline phase
        while true
            %---------------- function play(x)-----------------------
            % calculate the value of ucb to select the arm with max(ucb)
            theta_hat = V \ b;
            y_hat = zeros(1, K);
            for k = 1:K
                xk = x(:, k);
                y_hat(k) = theta_hat' * xk + beta * sqrt(xk' / V * xk);
            end

            y_hat_max = max(y_hat);

            % Find all the arms with the largest estimator mean value of the reward estimate
            actions = [];
            for k = 1:K
                if abs(y_hat_max - y_hat(k)) < 0.0001
                    actions = [actions k];
                end
            end

            action = actions(int32(ceil(rand()*length(actions))));

            %----------------- get_outcome(x, a)-------------------------
            % action 1 has infinite logged data
            xa = x(:, action);
            V_temp = V + xa*xa';
            if xa' / V_temp * xa > xa' / V_offline * xa
                n = n + 1;
                yt = xa' * theta_hat_offline;
                V = V_temp;
                b = b + yt * xa;
                beta = 1 + sqrt(2*log(1+n)+log(det(V)));
            else
                break;
            end
            %---------------------------end-------------------------------
        end

        % online phase
        yt = getReward(Mu(action));
        %update
        xa = x(:, action);
        V = V + xa*xa';
        b = b + yt * xa;
        beta = 1 + sqrt(2*log(1+n)+log(det(V)));
        n = n + 1;

        regret = regret + Mu_max - Mu(action);
        regrets(t) = regret;

    end

    E_regrets = (E_regrets*(repeat-1) + regrets)/repeat;
end

end

