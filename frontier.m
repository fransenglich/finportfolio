

%%
% The data.
% 5 assets are made up for now until we have real data from Bloomberg.
nassets = 5;

% Expected returns
ers = [2, 5, 3, 6, 7];

% 3 years of daily observations.
g_nobs = 30 * 12 * 3;

g_sd = [7, 8, 6, 10, 12];

rng('default');

rs = [];

for i = 1:nassets
    new = normrnd(ers(i), g_sd(i), [g_nobs, 1]);
    rs = cat(2, rs, new);
end

% The standard deviations
sds = [23, 45, 37];

% Returns

%%

% Portfolio weights.
w = [0.2, 0.3, 0.5];

% Covariance of returns.
Sigma = cov(rs);

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