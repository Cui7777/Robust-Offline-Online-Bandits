function [ E_Regrets, E_Rewards, E_restI] = Alg3_EffVirUCB(params, online_data_orgin, offline_data)
% the classic ucb algorithm
% input: T the number of time round
%       K the number of action
%       I the number of logged data of each arm

mu = params.mu;
optimal_arm = params.optimal_arm;
action_name = params.action_name;
reward_name = params.reward_name;
user_name = params.user_name;

U = params.user_num;
T = params.T;
K = params.K;
iterator_times = params.iterator_times;

E_Rewards = zeros(1, T);
E_restI = zeros(1, T);
E_Regrets =zeros(1, T);

for repeat=1:iterator_times

    repeat


    online_data = online_data_orgin;

    reward_in_each_round = zeros(1, T);  % record the cumulate_reward
    rest_number_of_offline_data = zeros(1, T);
    regret_in_each_round = zeros(1, T);

    y_hat = zeros(U, K);   % the estimated reward
    na = zeros(U, K); % times of arm i be choosen

    offline_data_current = offline_data(randperm(size(offline_data, 1)), :);

    for u=1:U
        for k=1:K
            t = (u-1)*K + k;
            action_t = k;
            rewards_to_be_selected = online_data{online_data{:, action_name}==action_t & online_data{:, user_name}==u, reward_name};
            if isempty(rewards_to_be_selected)
                error('reward error');
            else
                % choose a reward randomly
                rewards_num = length(rewards_to_be_selected);
                reward_t = rewards_to_be_selected(ceil(rand()*rewards_num));
            end

            % update
            na(u, action_t) = na(u, action_t) + 1;
            y_hat(u, action_t) = ((na(u, action_t)-1)*y_hat(u, action_t) + reward_t )/(na(u, action_t));

            % record reward
            reward_in_each_round(t) = reward_t;
            regret_in_each_round(t) = mu(u, optimal_arm(u)) - mu(u, action_t);
            rest_number_of_offline_data(t) = size(offline_data_current, 1);

        end
    end


    for t=U*K+1:T

        while true

            user_t = ceil(rand() * U);

            % estimate the optimal arm
            max_y_value = -inf;
            max_y_index = -1;

            for temp_action = 1:K

                temp_y = y_hat(user_t,temp_action);
                if temp_y > max_y_value
                    max_y_value = temp_y;
                    max_y_index = temp_action;
                end
            end

            % select an arm which has the largest ucb

            max_action_ucb = -inf;     % record the max ucb of each arm
            max_action_index = -1;      % record the index of the arm with max ucb

            % traversal the alternative actions
            for temp_action = 1:K

                temp_ucb = y_hat(user_t,temp_action) + sqrt(2*log(sum(na(user_t, :)))/na(user_t,temp_action));
                if temp_ucb > max_action_ucb
                    max_action_ucb = temp_ucb;
                    max_action_index = temp_action;
                end
            end

            action_t = max_action_index;

            if action_t == max_y_index
                break;
            else
                % judge whether exist the offline data
                if ~isempty(offline_data_current)
                    offline_data_action = find(offline_data_current{:, action_name}==action_t & offline_data_current{:, user_name}==user_t);
                else
                    break;
                end

                if ~isempty(offline_data_action)
                    match_action = action_t;
                    match_index = offline_data_action(randi(length(offline_data_action)));
                    match_reward = offline_data_current{match_index, reward_name};

                    % delete the data item matched
                    offline_data_current(match_index, :) = [];

                    % update
                    na(user_t, match_action) = na(user_t, match_action) + 1;
                    y_hat(user_t, match_action) = ((na(user_t, match_action)-1)*y_hat(user_t, match_action) + match_reward )/(na(user_t, match_action));
                else
                    break;
                end

            end

        end

        % get reward
        rewards_to_be_selected = online_data{online_data{:, action_name}==action_t & online_data{:, user_name}==user_t, reward_name};
        if isempty(rewards_to_be_selected)
            error('reward error');
        else
            % choose a reward randomly
            rewards_num = length(rewards_to_be_selected);
            reward_t = rewards_to_be_selected(ceil(rand()*rewards_num));
        end

        % update
        na(user_t, action_t) = na(user_t, action_t) + 1;
        y_hat(user_t, action_t) = ((na(user_t, action_t)-1)*y_hat(user_t, action_t) + reward_t )/(na(user_t, action_t));

        % record reward
        reward_in_each_round(t) = reward_t;
        regret_in_each_round(t) = mu(user_t, optimal_arm(user_t)) - mu(user_t, action_t);
        rest_number_of_offline_data(t) = size(offline_data_current, 1);
    end

    % calculate the mean of the regret
    cumsum_rewards = cumsum(reward_in_each_round);
    cumsum_regrets = cumsum(regret_in_each_round);
    E_Rewards = ((repeat-1)*E_Rewards + cumsum_rewards)/repeat;
    E_Regrets = ((repeat-1)*E_Regrets + cumsum_regrets)/repeat;
    E_restI = ((repeat-1)*E_restI + rest_number_of_offline_data)/repeat;
end


end

