
clear all;
close all;

%% The data.
% 5 assets are made up for now until we have real data from Bloomberg.
nassets = 5; % = size(mu, 1);

% Expected returns.
ers = [2, 5, 3, 6, 7];

asset_names = string(1:nassets);

for i = 1:nassets
    asset_names(i) = strcat("Asset ", asset_names(i));
end

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
sd = std(ret)';
correl = corr(ret);

% Covariance of returns.
Covar = diag(sd) * correl * diag(sd);

%% Compute the optimal weights through maximisation.
f = @(x) sqrt(x' * Covar * x) * 100;

% Our starting values for fmincon(). It is the assets equally weighted.
w_0 = repmat(1 / nassets, nassets, 1);

% Linear equality constraints.
Aeq = ones(1, nassets);
beq = 1;

% We do this because we cannot short.
lb = zeros(nassets, 1);

% Compute and write out our optimal portfolio weights.
% Aeq * x = beq
w_opt = fmincon(f, w_0, [], [], Aeq, beq, lb, []);

fid = fopen('generated_weights.tex', 'w');

for i = 1:size(w_opt, 1)
    fprintf(fid,                    ...
            '%s & %f & %g \\\\\n',  ...
            asset_names(i),         ...
            w_opt(i),               ...
            round(w_opt(i) * 100, 0));
end

fclose(fid);

%% Draw the MV frontier.

mu_bar = (0 : 0.1 : round(max(mu) * 1.2))'; % TODO right?

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
    sigma_MV(i) = sqrt(w_opt_cand' * Covar * w_opt_cand);
end

figure;

% The MV frontier.
plot(sigma_MV, mu_bar);

xlim([0, max(sigma_MV)]);
ylim([0, max(mu_bar)]);

hold all;

% The original portfolios.
plot(sd, mu, 'ob');


xlabel('Standard deviation');
ylabel('Mean');

%% Add the optimal portfolio to the plot.
% Note, risk-free is irrelevant in our case, so the equations are adapted
% accordingly.

w_tilde = inv(Covar) * mu;
w_opt = w_tilde / (w_tilde' * ones(nassets, 1));

opt_mu = w_opt' * mu;
opt_sigma = w_opt' * sd;

plot(opt_sigma, opt_mu, '+');

saveas(gcf, "generated_mv_frontier.eps", 'epsc');

%% Compute & write out SR.
opt_SR = opt_mu / sqrt(opt_sigma);

fid = fopen('generated_constants.tex', 'w');
fprintf(fid, '\\def\\optSR{%g}\n', round(opt_SR, 2));
fclose(fid);
