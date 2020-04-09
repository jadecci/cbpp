function [levene_p, parcel_p, var_p] = compare_pwCBPP_denoising(in_dir, n_parc, prefix1, prefix2, eval_type)
% function [levene_p, parcel_p, var_p] = compare_pwCBPP_denoising(in_dir, n_parc, prefix1, prefix2, eval_type)
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
% Inputs:
%       - in_dir    :
%                    Absolute path to input directory containing the performance results
%       - n_parc    :
%                    Total number of parcels, i.e. parcellation granularity used
%       - prefix1   :
%                    Combined results file prefix for the 1st combination of approaches. For example, the 
%                    performance results for parcel 1 from should be named: pwCBPP_prefix1_parcel1.mat
%       - prefix2   :
%                    Combined results file prefix for the 2nd combination of approaches.
%       - eval_type :
%                    Type of evaluation measure to use. Choose from 'r_test' and 'nrmsd_test'
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
% Jianxiao Wu, last edited on 09-Apr-2020

% usage
if nargin ~= 5
    disp('[levene_p, parcel_p, var_p] = compare_pwCBPP_denoising(in_dir, n_parc, prefix1, prefix2, eval_type)');
    return
end

% add path to external package
dir_bin = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(dir_bin, 'external_packages'));

% set up parameters
sample = load(fullfile(in_dir, ['pwCBPP_' prefix1 '_parcel1.mat']), eval_type);
sample = squeeze(mean(mean(sample.(eval_type))));
yd = length(sample);

%%% load performance results
% get results for combination of approaches 1
perf1 = zeros(yd, n_parc);
for parc_curr = 1:n_parc
    input_curr = load(fullfile(in_dir, ['pwCBPP_' prefix1 '_parcel' num2str(parc_curr) '.mat'], eval_type));
    perf1(:, parc_curr) = squeeze(mean(mean(input_curr.(eval_type))));
end
% get results for combination of approaches 2
perf2 = zeros(yd, n_parc);
for parc_curr = 1:n_parc
    input_curr = load(fullfile(in_dir, ['pwCBPP_' prefix2 '_parcel' num2str(parc_curr) '.mat']), eval_type);
    perf2(:, parc_curr) = squeeze(mean(mean(input_curr.(eval_type))));
end

%%% 1. Levene's test
fprintf("1. Levene's test between prediction accuracy distributions: \n");
% perform Levene's test for selected psychometric variables
levene_p = zeros(yd, 1);
for y_curr = 1:yd
    x = [perf1(y_curr, :), perf2(y_curr, :); ones(1, n_parc), 2*ones(1, n_parc)]';
    levene_p(y_curr) = levenetest(x);

    % print results if significant (alpha = 0.05)
    if levene_p(y_curr) < 0.05
        fprintf("Levene's test significant for psychometric variable No.%i with p = %.4f.", ...
                y_curr, levene_p(y_curr));
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
index = 1;
for i = 1:n_parc
    for j = (i+1):n_parc
        dist_parcel1(index) = sqrt(sum((perf1(:, i)-perf1(:, j)).^2));
        dist_parcel2(index) = sqrt(sum((perf2(:, i)-perf2(:, j)).^2));
        index = index + 1;
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
index = 1
for i = 1:yd
    for j = (i+1):yd
        dist_var1(index) = sqrt(sum((perf1(i, :)-perf1(j, :)).^2));
        dist_var2(index) = sqrt(sum((perf2(i, :)-perf2(j, :)).^2));
        index = index + 1;
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



    
