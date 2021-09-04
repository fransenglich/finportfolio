

%%
% The data.
% 3 assets are made up for now until we have real data from Bloomberg.

% The standard deviations
sds = [23, 45, 37];

% Returns
rs = [0.02, 0.05, 0.04];

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

% Sharpe ratio of portfolio.
% QF L2S30.
SRp = rf + (r_p - rf) / sd_p;