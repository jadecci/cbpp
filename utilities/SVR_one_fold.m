function [perf, weights, b] = SVR_one_fold(x, y, cv_ind, fold)
% [perf, weights, b] = SVR_one_fold(x, y, cv_ind, fold)
%
% This function runs Support Vector Regression for one cross-validation fold. The relationship 
% between features and targets is assumed to be y = x * weights + b.
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
%       - perf   :
%                 A structure containing the performance metrics: Pearson correlation between 
%                 predicted and observed values ('r_train' and 'r_test'); normalised root mean
%                 sqaured deviation between predicted and observed values ('nrmsd_train' and 
%                 'nrmsd_test')
%       - weights:
%                 Px1 matrix containing weights of the P features
%       - b      :
%                 Intercept value
%
% Jianxiao Wu, last edited on 26-Mar-2020

% usage
if nargin ~= 4
    disp('Usage: [perf, weights, b] = SVR_one_fold(x, y, cv_ind, fold)');
    return
end

% training
x_train = x(cv_ind ~= fold, :);
y_train = y(cv_ind ~= fold);
model = fitrlinear(x_train, y_train); % fitrlinear uses SVR by default

% get model
b = model.Bias;
weights = model.Beta;

% get training performance
ypred_train = predict(model, x_train);
perf.r_train = corr(y_train, ypred_train, 'type', 'Pearson', 'Rows', 'complete');
perf.nrmsd_train = sqrt(sum((y_train - ypred_train).^2) / (length(y_train) - 1)) / std(y_train);

% get test performance
x_test = x(cv_ind == fold, :);
y_test = y(cv_ind == fold);
ypred_test = predict(model, x_test);
perf.r_test = corr(y_test, ypred_test, 'type', 'Pearson', 'Rows', 'complete');
perf.nrmsd_test = sqrt(sum((y_test- ypred_test).^2) / (length(y_test) - 1)) / std(y_test);




