
clear all;
close all;

%%
% The data.
% 5 assets are made up for now until we have real data from Bloomberg.
nassets = 5;

% Expected returns.
ers = [2, 5, 3, 6, 7];

% 3 years of daily observations.
n_obs = 30 * 12 * 3;

g_sd = [7, 8, 6, 10, 12];

rng('default');

% Array of returns, columns are assets.
rs = [];

% Randomly generate the returns.
for i = 1:nassets
    new = normrnd(ers(i), g_sd(i), [n_obs, 1]);
    rs = cat(2, rs, new);
end

mu = mean(rs)';

% Covariance of returns.
Sigma = cov(rs);

% SD
sigma = std(rs)';

%%
% Compute the optimal weights through maximisation.

f = @(x) sqrt(x' * Sigma * x) * 100;

% Our starting values for fmincon(). It is the assets equally weighted.
w_0 = repmat(1 / nassets, nassets, 1);

% Linear equality constraints.
% TODO understand this.
C = [ones(1, nassets); mu'];    
d = [1; 0.015];

%%
% Compute and write out our optimal portfolio weights.
w_opt1 = fmincon(f, w_0, [], [], C, d);

fid = fopen('weights.tex','w');

for i = 1:size(w_opt1, 1)
    fprintf(fid,                    ...
            '%s & %f & %g \\\\\n',  ...
            int2str(i),             ...
            w_opt1(i),              ...
            round(w_opt1(i) * 100, 0));
end

fclose(fid);

%%
% Draw the MV frontier.

mu_bar = (0 : 0.001 : 0.025)';

%Pre-define a matrix for the weights.
w_MV = zeros(size(mu_bar, 1), nassets);

% Pre-define a matrix for standard deviations.
sigma_MV = zeros(size(mu_bar, 1), 1);  

for i = 1 : size(mu_bar, 1)  
    w_opt = fmincon(f, w_0, [], [], C, [1; mu_bar(i)]);    

    % Saving the optimal weights.
    w_MV(i, :) = w_opt';

    % Saving the corresponding S.D.
    sigma_MV(i) = sqrt(w_opt' * Sigma * w_opt);
end

figure;

% The MV frontier.
plot(sigma_MV, mu_bar);

hold all;

% The original portfolios.
plot(sigma, mu, 'ob');

xlabel('Standard deviation');
ylabel('Mean');

saveas(gcf, "figures/mv_frontier.eps", 'epsc');

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