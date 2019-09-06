function [r_test, r_train, weights, b] = SVR_one_fold(x, y, cv_ind, fold)
% [r_test, r_train, weights, b] = SVR_one_fold(x, y, cv_ind, fold)
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
%       - r_test :
%                 Pearson correlation between predicted target values and actual target values in 
%                 validation set
%       - r_train:
%                 Pearson correlation between predicted target values and actual target values in 
%                 training set
%       - weights:
%                 Px1 matrix containing weights of the P features
%       - b      :
%                 Intercept value
%
% Example:
% [r_test, r_train] = SVR_one_fold(x, y, cv_ind, 1)
% This command runs SVR using fold 1 as validation set, and the rest as training set
%
% Jianxiao Wu, last edited on 08-Apr-2019

% usage
if nargin ~= 4
    disp('Usage: [r_test, r_train, weights, b] = SVR_one_fold(x, y, cv_ind, fold)');
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
r_train = corr(y_train, ypred_train, 'type', 'Pearson', 'Rows', 'complete');

% get test performance
x_test = x(cv_ind == fold, :);
y_test = y(cv_ind == fold);
ypred_test = predict(model, x_test);
r_test = corr(y_test, ypred_test, 'type', 'Pearson', 'Rows', 'complete');





