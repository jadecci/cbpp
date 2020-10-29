function [perf, weights, b, k] = RR_one_fold(x, y, cv_ind, fold, ks)
% [perf, weights, b, k] = RR_one_fold(x, y, cv_ind, fold, ks)
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
% Jianxiao Wu, last edited on 30-Oct-2020

% usage
if nargin < 4
    disp('Usage: [perf, weights, b, k] = RR_one_fold(x, y, cv_ind, fold, ks)');
    return
end

% default k values
% see sklearn.linear_model.RidgeCV for list of k/alpha values
if nargin < 5
    ks = 0:0.1:10;
end

% outer-loop sets
x_train = x(cv_ind ~= fold, :);
y_train = y(cv_ind ~= fold);
x_test = x(cv_ind == fold, :);
y_test = y(cv_ind == fold);

% inner-loop sets
n_fold = max(cv_ind);
if fold == n_fold; fold_inner = 1; else; fold_inner = fold + 1; end
x_val_inner = x(cv_ind==fold_inner, :);
y_val_inner = y(cv_ind==fold_inner);
train_ind_inner = (cv_ind ~= fold) .* (cv_ind ~= fold_inner);
x_train_inner = x(train_ind_inner==1, :);
y_train_inner = y(train_ind_inner==1);

% find best k
model = fitrlinear(x_train_inner, y_train_inner, 'Learner', 'leastsquares', 'Regularization', 'ridge', 'Lambda', ks);
y_val_pred_inner = x_val_inner * model.Beta + model.Bias;
r_val = corr(y_val_pred_inner, y_val_inner, 'type', 'Pearson', 'Rows', 'complete');

% best model
[~, k_ind] = max(r_val);
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

