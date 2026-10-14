function [ offline_data, N_offline ] = prepare_offline_data( alpha, N_offline, data_reindex)
% input params: a;pha, gamma, data_reindex

    K = length(unique(data_reindex{:, 'arm'}));
    user_num = length(unique(data_reindex{:, 'user'}));

    x = [0.1 1:K-1];
    rate = x.^(-alpha);
    rate = rate/sum(rate);
    I = round(rate*N_offline/2);

    offline_data = table();

    for user_index=1:user_num
        for arm_index=1:K
            offline_data_num = I(arm_index);
            offline_data_temp = data_reindex(data_reindex{:, 'user'}==user_index & data_reindex{:, 'arm'}==arm_index, :);

            % update in 2020-02-01, get each offline data independently
            random_index = ceil(rand(offline_data_num)*size(offline_data_temp, 1));
            offline_data = vertcat(offline_data, offline_data_temp(random_index(1:offline_data_num), :));
        end
    end

    N_offline = size(offline_data, 1);
end

