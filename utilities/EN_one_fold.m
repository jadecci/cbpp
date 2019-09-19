function [r_test, r_train, weights, b, alpha] = EN_one_fold(x, y, cv_ind, fold)
% [r_test, r_train, weights, b] = EN_one_fold(x, y, cv_ind, fold)
%
% This function runs Elastic nets for one cross-validation fold. The relationship between features 
% and targets is assumed to be y = x * weights + b.
%
% Inputs:
%       - x       :
%                  NxP matrix containing P features from N subjects
%       - y       :
%                  NxT matrix containing T target values from N subjects
%       - cv_ind  :
%                  Nx1 matrix containing cross-validation fold assignment for N subjects. Values 
%                  should range from 1 to K for a K-fold cross-validation
%       - fold    :
%                  Fold to be used as validation set 
%
% Output:
%       - r_test  :
%                 Pearson correlation between predicted target values and actual target values in 
%                 validation set
%       - r_train:
%                 Pearson correlation between predicted target values and actual target values in 
%                 training set
%       - weights:
%                 Px1 matrix containing weights of the P features
%       - b      :
%                 Intercept value
%       - alpha  :
%                 L1-to-L2-ratios chosen by performance on the validation set. A larger alpha means 
%                 higher weightage on the L1 penalty term; at alpha=1 the model is purely LASSO
%
% Example:
% [r_test, r_train, weights, b] = EN_one_fold(x, y, cv_ind, 1)
% This command runs EN using fold 1 as test set, fold 2 as inner-loop validation set, and the rest 
% as training set
%
% Jianxiao Wu, last edited on 1-Jul-2019

% usage
if nargin ~= 4
    disp('Usage: [r_test, r_train, weights, b] = EN_one_fold(x, y, cv_ind, fold)');
    return
end

% add glmnet library to path
root_path = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root_path, 'bin', 'external_packages', 'glmnet_matlab'));

% set-up lambda tuning parameters
n_fold_lambda = 10; % 10-fold inner CV loop to tune lambda
options = [];
options.nlambda = 10;
options.standardize = false;

% validation set
n_fold = max(cv_ind);
if fold == n_fold; fold_inner = 1; else; fold_inner = fold + 1; end
x_val = x(cv_ind == fold_inner, :);
y_val = y(cv_ind == fold_inner, :);

% training set
train_ind_inner = (cv_ind ~= fold) .* (cv_ind ~= fold_inner);
x_train = x(train_ind_inner==1, :);
y_train = y(train_ind_inner==1, :);

% test set
x_test = x(cv_ind == fold, :);
y_test = y(cv_ind == fold);

% select best alpha value
% see sklearn.linear_model.ElasticNetCV for list of alpha values
% an alpha value of 0.01 is added based on Dubois et al. 2018
for alpha = [0.01 0.1 0.5 0.7 0.9 0.95 0.99 1] 
    options.alpha = alpha;
    
    % train model and fetch parameters
    fit = cvglmnet(x_train, y_train, 'gaussian', options, 'mse', n_fold_lambda);
    ind = find(fit.lambda==fit.lambda_min, 1); % Kaustubh suggested that lambda_min gives better accuracy
    
    % test prediction on validation set
    ypred_val = x_val * fit.glmnet_fit.beta(:, ind) + fit.glmnet_fit.a0(ind);
    r_curr = corr(y_val, ypred_val, 'type', 'Pearson', 'Rows', 'complete');

    % initialise best model
    if alpha == 0.01
        r_train = r_curr;
        weights = fit.glmnet_fit.beta(:, ind);
        b = fit.glmnet_fit.a0(ind);
        alpha_best = alpha;
    end

    % update best model if needed
    if r_curr > r_train
        r_train = r_curr;
        weights = fit.glmnet_fit.beta(:, ind);
        b = fit.glmnet_fit.a0(ind);
        alpha_best = alpha;
    end
end
alpha = alpha_best;

% get test performance
ypred_test = x_test * weights + b;
r_test = corr(y_test, ypred_test, 'type', 'Pearson', 'Rows', 'complete');





