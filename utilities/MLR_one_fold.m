function [r_test, r_train, weights] = MLR_one_fold(x, y, cv_ind, fold)
% [r_test, r_train, weights] = MLR_one_fold(x, y, cv_ind, fold)
%
% This function runs multiple linear regression (MLR) for one cross-validation fold. The 
% relationship between features and targets is assumed to be y = [x 1] * weights.
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
%                 (P+1)x1 matrix containing weights of the P features and
%                 the intercepts
%
% Example:
% [r_test, r_train, weights] = MLR_one_fold(x, y, cv_ind, 1)
% This command runs MLR using fold 1 as validation set, and the rest as training set
%
% Jianxiao Wu, last edited on 26-Aug-2019

% usage
if nargin ~= 4
    disp('Usage: [r_test, r_train, weights] = MLR_one_fold(x, y, cv_ind, fold)');
    return
end

% turn off rank deficient warning
warning('off', 'stats:regress:RankDefDesignMat');

% training
x_train = x(cv_ind ~= fold, :);
y_train = y(cv_ind ~= fold);
weights = regress(y_train, [x_train, ones(size(x_train, 1), 1)]); % x needs to be appended by a vector of 1s

% get training performance
ypred_train = [x_train, ones(size(x_train, 1), 1)] * weights;
r_train = corr(y_train, ypred_train, 'type', 'Pearson', 'Rows', 'complete');

% get test performance
x_test = x(cv_ind == fold, :);
y_test = y(cv_ind == fold);
ypred_test = [x_test, ones(size(x_test, 1), 1)] * weights;
r_test = corr(y_test, ypred_test, 'type', 'Pearson', 'Rows', 'complete');





