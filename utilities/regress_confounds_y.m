function [y, reg_y] = regress_confounds_y(y, confounds, existing_reg)
% [y, reg_y] = regress_confounds_y(y, confounds, existing_reg)
%
% This function regresses out confounds from prediction targets y. Note that regression coefficients 
% should be estimated using only training data.
%
% For training data, pass in y and the confounds to perform regression, obtaining the new y and 
% regression coefficients reg_y. 
%
% For test data, also pass in the regression coefficients obtained from the training data. 
%
% Inputs:
%       - y           :
%                      NxT matrix containing T target values from N subjects
%       - confounds   :
%                      NxD matrix containing D confounds for N subjects.
%       - existing_reg:
%                      (Optional) Existing regression coefficients to use for regressing out 
%                      confounds in the test set.
%
% Output:
%        - y    :
%                NxT matrix containing the target values with confounds removed
%        - reg_y:
%                (D+1)xT array containing the regression coefficient for each confound. The last 
%                element correspond to the offset, i.e. a confound of constant 1.
%
% Example:
% 1) [y_train, reg_y] = regress_confounds_y(y_train, confounds)
%    This regresses out confounds from the training data, also returning the regression coefficients
% 2) y_val = regress_confounds_y(y_val, confounds, reg_y)
%    This regresses out confounds from the test data, using the regression coefficients previously 
%    determined based on training data
%
% Jianxiao Wu, last edited on 15-May-2018

% usage
if nargin < 2
    disp('Usage: [y, reg_y] = regress_confounds_y(y, confounds, existing_reg)');
    return
end

% set up
t = size(y, 2);
n = size(y, 1);
d = size(confounds, 2);

% perform regression
% note that a vecotr of 1s needs to be appended to confounds
if nargin < 3
    % for training set
    reg_y = zeros(d+1, t);
    for target = 1:t
        [reg_y(:, target), ~, y(:, target)] = regress(y(:, target), [confounds, ones(n, 1)]);
    end
else
    % for test set
    y = y - [confounds, ones(n, 1)] * existing_reg;
    reg_y = existing_reg;
end
