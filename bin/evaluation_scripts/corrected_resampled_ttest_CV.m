function [p, p_thr] = corrected_resampled_ttest_CV(perf, mcc_type)
% function [p, p_thr] = corrected_resampled_ttest(perf, mcc_type)
%
% This function tests if test performances using different combinations of approaches are different
% using corrected resampled ttest for cross-validation. The P value is computed for each pair of 
% combination of approaches. The threshold for P values after multiple comparison correction is also 
% returned.
%
% Inputs:
%       - perf     :
%                   MxKxN array containing test performance 1 in M repeats of K-fold cross-validation
%                   for N different scenarios
%       - mcc_type :
%                   Type of multiple comparison correction to use. Choose from 'fdr' and 'bonferroni'                 
%                   default: 'fdr'
%
% Output:
%        - p    :
%                1xN array containing P values for the N tests
%        - p_thr:
%                The threshold for rejecting null hypothesis according to the multiple comparison 
%                correction used               
%
% Example:
% p = corrected_resampled_ttest(perf)
% This command finds the P values for test performances in 'matrix perf
%
% Jianxiao Wu, last edited on 03-Jul-2019

% usage
if nargin < 1
    disp('[p, p_thr] = corrected_resampled_ttest(perf, mcc_type)');
    return
end

% set default parameter
if nargin < 2
    mcc_type = 'fdr';
end
dir_bin = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(dir_bin, 'external_packages'));

% set NaN to 0 
perf(isnan(perf)==1) = 0;

% compute t statistics
[m, k, n] = size(perf);
p = zeros(n, n);
for i = 1:n
    for j = (i+1):n
        diff = perf(:, :, i) - perf(:, :, j); 
        t = mean(diff(:)) / (sqrt(1/(k * m) + 1/(k - 1)) * std(diff(:))); % variance is corrected for CV
        p(i, j) = 2 * tcdf(abs(t), m*k-1, 'upper'); % plut in t distribution
    end
end

% control for multiple comparison
p_vec = p(triu(ones(size(p)), 1)==1);
if strcmp(mcc_type, 'fdr')
    p_thr = fdr(p_vec);
elseif strcmp(mcc_type, 'bonferroni')
    p_thr = 0.05 / length(p_vec);
end