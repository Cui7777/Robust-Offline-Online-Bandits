function [data_reindex, average_reward] = reindex_rewards(data)

    users = sort(unique(data{:, 'user'}));
    arms = sort(unique(data{:, 'arm'}));

    users_num = length(users);
    arms_num = length(arms);

    data_reindex = table();
    average_reward = zeros(users_num, arms_num);

    for user_index = 1:users_num

        user = users(user_index);

        for arm_index = 1:arms_num
            arm = arms(arm_index);
            average_reward(user_index, arm_index) = mean(data{data{:, 'user'}==user & data{:, 'arm'}==arm, 'reward'});
        end

        [average_reward(user_index, :), reindex] = sort(average_reward(user_index, :), 'descend');

        for arm_index = 1:arms_num
            arm = reindex(arm_index);
            data_arm = data(data{:, 'user'}==user & data{:, 'arm'}==arm, :);
            data_arm(:, 'arm') = table(arm_index*ones(size(data_arm, 1), 1));

            data_reindex = vertcat(data_reindex, data_arm);
        end

    end

end

