function [levene_p, parcel_p, var_p] = compare_pwCBPP_denoising(in_dir, n_parc, prefix1, prefix2, levene_sel)
% function [levene_p, parcel_p, var_p] = compare_pwCBPP_denoising(in_dir, n_parc, prefix1, prefix2, levene_sel)
%
% This function compares parcel-wise CBPP performance using different combinations of approaches (we
% only compared between minimal processing and FIX for preprocessing in the paper, but other
% comparisons are also posisble). 
%
% First, Levene's test is used to compare the variance of the prediction accuracies distribution
% across parcels between the two performance results.
%
% Second, Euclidean distance between each pair of parcel's psychometric profiles (i.e. prediction
% accuracies across psychometric variables) is computed for the two combinations of approaches separately.
% A paired t-test is performed to check if the mean Euclidean distances are distinguishable.
%
% Third, Euclidean distance between each pair of psychometric variable's prediction accuracies
% distribution is computed for the two combinations of approaches separately. A paired t-test is 
% again performed.
%
% Note that the performance results should be first combined using combine_CBPP_results.m
%
% Inputs:
%       - in_dir    :
%                    Absolute path to input directory containing the performance results
%       - n_parc    :
%                    Total number of parcels, i.e. parcellation granularity used
%       - prefix1   :
%                    Combined results file prefix for the 1st combination of approaches. For example, the 
%                    performance results for parcel 1 from should be named: pwCBPP_prefix1_parcel1.csv
%       - prefix2   :
%                    Combined results file prefix for the 2nd combination of approaches.
%       - levene_sel:
%                    (Optional) a vector containing indices of psychometric variables to perform 
%                    Levene's test on. By default, all 40 variables are selected.
%                    default: 1:40
%
% Output:
%        - levene_p:
%                   A vector of P values from the Levene's test
%        - parcel_p:
%                   The P value from the paired t-test for Euclidean distances between parcel's 
%                   psychometric profiles
%        - var_p   :
%                   The P value from the paired t-test for Euclidean distances between psychometric
%                   variables' prediction accuracy distributions
%
% Example:
% compare_pwCBPP_denoising('input_dir', 300, 'SVR_standard_HCP_fix_parc300_Pearson', 
% 'SVR_standard_HCP_minimal_parc300_Pearson')
% This compares parcel-wise CBPP performance for SVR-Pearson combinations at 300-parcel granularity,
% using minimally processed data and FIX data respectively.
%
% Jianxiao Wu, last edited on 30-Sept-2019

% usage
if nargin < 4
    disp('[levene_p, parcel_p, var_p] = compare_pwCBPP_denoising(in_dir, n_parc, prefix1, prefix2, [levene_sel])');
    return
end

% default parameter
if nargin < 5
    levene_sel = 1:40;
end

% add path to external package
dir_bin = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(dir_bin, 'external_packages'));

% set up parameters
sample = csvread(fullfile(in_dir, ['pwCBPP_' prefix1 '_parcel1.csv']), 0, 2);
yd = length(sample);

%%% load performance results
% get results for combination of approaches 1
perf1 = zeros(yd, n_parc);
for parc_curr = 1:n_parc
    input_curr = fullfile(in_dir, ['pwCBPP_' prefix1 '_parcel' num2str(parc_curr) '.csv']);
    perf1(:, parc_curr) = csvread(input_curr, 0, 2);
end
% get results for combination of approaches 2
perf2 = zeros(yd, n_parc);
for parc_curr = 1:n_parc
    input_curr = fullfile(in_dir, ['pwCBPP_' prefix2 '_parcel' num2str(parc_curr) '.csv']);
    perf2(:, parc_curr) = csvread(input_curr, 0, 2);
end

%%% 1. Levene's test
fprintf('1. Levene's test between prediction accuracy distributions: \n');
% perform Levene's test for selected psychometric variables
levene_p = zeros(length(levene_sel), 1);
for y_ind = 1:length(levene_sel)
    y_curr = levene_sel(y_ind);
    x = [perf1(y_curr, :), perf2(y_curr, :); ones(1, n_parc), 2*ones(1, n_parc)]';
    levene_p(y_ind) = levenetest(x);

    % print results if significant (alpha = 0.05)
    if levene_p(y_ind) < 0.05
        fprintf('Levene's test significant for psychometric variable No.%i with p = %.4f.', ...
                y_curr, levene_p(y_ind));
        if var(perf1(y_curr, :)) > var(perf2(y_curr, :))
            fprintf('Variance of the 1st combination of approaches is larger. \n');
        else
            fprintf('Variance of the 2nd combination of approaches is larger. \n');
        end
    end
end
% print results if nothing was significant :/
if min(levene_p) >= 0.05
    fprintf('No significant comparison found among selected variables. \n');
end

%%% 2. Distance between psychometric profiles
fprintf('2. Paired t-test for distributions of Euclidean distances between psychometric profiles \n')
% compute Euclidean distance between parcel's profiles
for i = 1:n_parc
    for j = (i+1):n_parc
        dist_parcel1(i, j) = sqrt(sum((perf1(:, i)-perf1(:, j)).^2));
        dist_parcel2(i, j) = sqrt(sum((perf2(:, i)-perf2(:, j)).^2));
    end
end
% perform paired t-test
[h, parcel_p] = ttest(dist_parcel1, dist_parcel2);
% print results
if h == 1
    fprintf('Null hypothesis rejected with p = %.4f \n', parcel_p);
    if mean(dist_parcel1 - dist_parcel2) > 0
        fprintf('Mean Euclidean distance of the 1st combination of approaches is larger. \n');
    else
        fprintf('Mean Euclidean distance of the 2nd combination of approaches is larger. \n');
    end
else
    fprintf('Null hypothesis cannot be rejected. \n');
end

%%% 3. Distance between prediction accuracies distributions
fprintf('3. Paired t-test for distributions of Euclidean distances between prediction accuracies distributions \n')
% compute Euclidean distances across psychometric variables
for i = 1:yd
    for j = (i+1):yd
        dist_var1(i, j) = sqrt(sum((perf1(i, :)-perf1(j, :)).^2));
        dist_var2(i, j) = sqrt(sum((perf2(i, :)-perf2(j, :)).^2));
    end
end
% perform paired t-test
[h, var_p] = ttest(dist_var1, dist_var2);
% print results
if h == 1
    fprintf('Null hypothesis rejected with p = %.4f \n', var_p);
    if mean(dist_var1 - dist_var2) > 0
        fprintf('Mean Euclidean distance of the 1st combination of approaches is larger. \n');
    else
        fprintf('Mean Euclidean distance of the 2nd combination of approaches is larger. \n');
    end
else
    fprintf('Null hypothesis cannot be rejected. \n');
end



    
