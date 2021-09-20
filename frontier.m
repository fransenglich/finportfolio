
clear all;
close all;

%% The data.
% 5 assets are made up for now until we have real data from Bloomberg.
nassets = 5; % = size(mu, 1);

% Expected returns.
ers = [2, 5, 3, 6, 7];

% 3 years of daily observations.
n_obs = 30 * 12 * 3;

g_sd = [7, 8, 6, 10, 12];

rng('default');

% Array of returns, columns are assets.
mktret = [];

ret = [];

% Randomly generate the returns.
for i = 1:nassets
    new = normrnd(ers(i), g_sd(i), [n_obs, 1]);
    ret = cat(2, ret, new);
end

%% ------------- FOREIGN ----------------------------
%load data_Matlab1          %load data

%Pick a subperiod and a subset of the portfolios
%index_date=date>=198001 & date<=201512;
%index_portfolio=[3,20,2,14,17];
%ret=ret(index_date,index_portfolio);
%mktret=mktret(index_date);
% -------------------------------------------------------

%% Basic paramaters.
mu = mean(ret)';

sigma = std(ret)';

correl = corr(ret);

% Covariance of returns.
Sigma = diag(sigma) * correl * diag(sigma);

%% Compute the optimal weights through maximisation.

f = @(x) sqrt(x' * Sigma * x) * 100;

% Our starting values for fmincon(). It is the assets equally weighted.
w_0 = repmat(1 / nassets, nassets, 1);

% Linear equality constraints.
Aeq = ones(1, nassets);
beq = 1;

% We do this because we cannot short.
noshort = zeros(nassets, 1);

% Compute and write out our optimal portfolio weights.
% Aeq * x = beq
w_opt1 = fmincon(f, w_0, [], [], Aeq, beq, noshort, []);

fid = fopen('generated_weights.tex','w');

for i = 1:size(w_opt1, 1)
    fprintf(fid,                    ...
            '%s & %f & %g \\\\\n',  ...
            int2str(i),             ...
            w_opt1(i),              ...
            round(w_opt1(i) * 100, 0));
end

fclose(fid);

%% Draw the MV frontier.

% This is the scale of the Y-axis.
mu_bar = (0 : 0.1 : round(max(mu) * 1.2))';

% Pre-define a matrix for the weights.
w_MV = zeros(size(mu_bar, 1), nassets);

% Pre-define a matrix for standard deviations.
sigma_MV = zeros(size(mu_bar, 1), 1);  

Aeq = [ones(1, nassets); mu']; 

for i = 1 : size(mu_bar, 1)  
    w_opt_cand = fmincon(f, w_0, [], [], Aeq, [1; mu_bar(i)]);    

    % Saving the optimal weights.
    w_MV(i, :) = w_opt_cand';

    % Saving the corresponding S.D.
    sigma_MV(i) = sqrt(w_opt_cand' * Sigma * w_opt_cand);
end

figure;

% The MV frontier.
plot(sigma_MV, mu_bar);

hold all;

% The original portfolios.
plot(sigma, mu, 'ob');

xlabel('Standard deviation');
ylabel('Mean');

%% Add the optimal portfolio to the plot.

opt_mu = w_opt1' * mu;
opt_sigma = w_opt1' * sigma;

plot(opt_sigma, opt_mu, '+');

saveas(gcf, "generated_mv_frontier.eps", 'epsc');

%% Unused stuff.

% Swedish risk-free rate. Fetched 04-09-2021 from
% https://www.statista.com/statistics/885803/average-risk-free-rate-sweden/
rf = 0.009;

% My risk-aversion
gamma = 0;

% Plot the efficient frontier.

% Expected portfolio return
r_p = 0;

% SD of portfolio.
sd_p = 0;

% Tangency portfolio (its weights).
W_T = [];

% Sharpe ratio of portfolio.
% QF L2S30.
SRp = rf + (r_p - rf) / sd_p;