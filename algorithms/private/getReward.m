function [ y ] = getReward( ER )
%
% Bernoulli reward model
if rand() < ER
    y = 1;
else
    y = 0;
end
% Gaussian reward model
% y = normrnd(ER, 1);

