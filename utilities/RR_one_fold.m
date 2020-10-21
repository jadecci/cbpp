function [perf, weights, b, k] = RR_one_fold_val(x, y, conf, cv_ind, fold, seed, ks)
% [perf, weights, b, k] = RR_one_fold_val(x, y, conf, cv_ind, fold, ks)
%
% This function runs Ridge Regression for one cross-validation fold. The relationship between features and targets is 
% assumed to be y = x * weights + b.
%
% Inputs:
%       - x       :
%                  NxP matrix containing P features from N subjects
%       - y       :
%                  NxT matrix containing T target values from N subjects
%       - cv_ind  :
%                  Nx1 matrix containing cross-validation fold assignment for N subjects. Values should range from 1 
%                  to K for a K-fold cross-validation
%       - fold    :
%                  Fold to be used as validation set 
%       - ks      :
%                  Vector of values to try for tuning the ridge parameter k
%                  default: 0:0.1:10
%
% Output:
%       - perf    :
%                 A structure containing the performance metrics: Pearson correlation between predicted and observed 
%                 values ('r_train' and 'r_test'); normalised root mean sqaured deviation between predicted and 
%                 observed values ('nrmsd_train' and 'nrmsd_test')
%       - weights:
%                 Px1 matrix containing weights of the P features
%       - b      :
%                 Intercept value
%
% Jianxiao Wu, last edited on 21-Oct-2020

% usage
if nargin < 6
    disp('Usage: [perf, weights, b, k] = RR_one_fold_val(x, y, conf, cv_ind, fold, ks)');
    return
end

% default k values
% see sklearn.linear_model.RidgeCV for list of k/alpha values
if nargin < 7
    ks = 0:0.1:10;
end

% outer-loop sets
x_train = x(cv_ind ~= fold, :);
y_train = y(cv_ind ~= fold);
x_test = x(cv_ind == fold, :);
y_test = y(cv_ind == fold);
if numel(conf) ~= 0
	conf_train = conf(cv_ind ~= fold, :);
	conf_val = conf(cv_ind == fold, :);
end

% inner-loop cross-validation
rng(seed);
inner_ind = cvpartition(size(x_train, 1), 'KFold', 10); %10-fold CV
r_k = zeros(length(ks), 1);
for fold_inner = 1:10
    x_train_inner = x_train(inner_ind.training(fold_inner), :);
    y_train_inner = y_train(inner_ind.training(fold_inner));
    x_val_inner = x_train(inner_ind.test(fold_inner), :);
    y_val_inner = y_train(inner_ind.test(fold_inner));

    % regress out confounds if necessary
    if numel(conf) ~= 0
        conf_train_inner = conf_train(inner_ind.training(fold_inner), :);
        conf_val_inner = conf_train(inner_ind.test(fold_inner), :);
        [y_train_inner, reg_y] = regress_confounds_y(y_train_inner, conf_train_inner);
        y_val_inner = regress_confounds_y(y_val_inner, conf_val_inner, reg_y);
    end

    % test different k values
    model = fitrlinear(x_train_inner, y_train_inner, 'Learner', 'leastsquares', 'Regularization', 'ridge', 'Lambda', ks);
    y_val_pred_inner = x_val_inner * model.Beta + model.Bias;
    r_curr = corr(y_val_pred_inner, y_val_inner, 'type', 'Pearson', 'Rows', 'complete');
    r_k = r_k + r_curr;
end

% Best model
[~, k_ind] = max(r_k);
k = ks(k_ind);
model = fitrlinear(x_train, y_train, 'Learner', 'leastsquares', 'Regularization', 'ridge', 'Lambda', k);
weights = model.Beta;
b = model.Bias;

% get training performance
y_train_pred = x_train * weights + b;
perf.r_train = corr(y_train, y_train_pred, 'type', 'Pearson', 'Rows', 'complete');
perf.nrmsd_train = sqrt(sum((y_train - y_train_pred).^2) / (length(y_train) - 1)) / std(y_train);

% test performance
y_test_pred = x_test * weights + b;
perf.r_val = corr(y_test, y_test_pred , 'type', 'Pearson', 'Rows', 'complete');
perf.nrmsd_val = sqrt(sum((y_test - y_test_pred ).^2) / (length(y_test) - 1)) / std(y_test);

