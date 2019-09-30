function [p, p_thr] = ttest_permutation(test_perf, null_perf, mcc_type)
% function [p, p_thr] = ttest_permutation(test_perf, null_perf, mcc_type)
%
% This function computes the P values based on null distribution generated from permutation testing, 
% as well as the threshold for P values for the specified type of multiple comparison correction.
%
% Inputs:
%       - test_perf:
%                   1xN array containing non-permuted test performance for N different tests
%       - null_perf:
%                   MxN array containing permuatation test performance (i.e. the null distribution) 
%                   for N tests across M different permutations
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
% p = pval_permutation(test_perf, null_perf)
% This command finds the P values for each test performance in test_perf
%
% Jianxiao Wu, last edited on 22-May-2019

% usage
if nargin < 2
    disp('[p, p_thr] = ttest_permutation(test_perf, null_perf, mcc_type)');
    return
end

% set default parameter
if nargin < 3
    mcc_type = 'fdr';
end
dir_bin = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(dir_bin, 'external_packages'));

% set NaN to 0 
null_perf(isnan(null_perf)==1) = 0;

% get rankings from full distribution
full_perf = [test_perf; null_perf];
[m1, n] = size(full_perf);
[~, rank] = sort(full_perf, 'descend');

% compute p values
[ind, ~] = find(rank==1);
p = ind / m1;

% control for multiple comparison
if strcmp(mcc_type, 'fdr')
    p_thr = fdr(p);
elseif strcmp(mcc_type, 'bonferroni')
    p_thr = 0.05 / n;
end


    



