function selected = select_feature_corr(x, y, sig_sel, n_limit, top_perc, p_thr)
% selected = select_feature(x, y, sig_sel, edge_limit, top_perc, p_thr)
%
% This function selects features based on feature-target correlation. Pearson correlation is 
% computed between each feature (x) and each target (y). Features are then selected either by 
% significance or correlation strength ranking. 
%
% Inputs:
%       - x       :
%                  NxP matrix containing P features from N subjects
%       - y       :
%                  NxT matrix containing T target values from N subjects
%       - sig_sel :
%                  Set this to 1 if insignificant edges should be all excluded. Set to 0 otherwise.
%       - n_limit :
%                  Maximum number of features to select for each target. Set this to 0 if all 
%                  (significant) features should be included
%       - top_perc:
%                  Percentage of features to select for each target. For example, setting this to 30 
%                  will cause the top 30% features (rounded down) most correalted to each target 
%                  to be selected. Note that this parameter is only checked if sig_sel = 0
%       - p_thr   :
%                  (Optional) threshold for determining significance of correlation. Only neccessary 
%                  if sig_sel = 1
%                  Default: 0.01
%
% Output:
%       - selected:
%                  PxT binary matrix containg selected status (1 for selected, 0 for not selected) 
%                  for all P features, separately each of the T targets
%
% Example:
% 1) selected = select_feature_corr(x, y, 1, 0);
%    This command selects all features from x that are significantly correlated to each target in y 
%    with P < 0.01
% 2) selected = select_feature_corr(x, y, 1, 100);
%    This command selects features from x that are significantly correlated to each target in y with 
%    P < 0.01, but limits the number of features selected for each target to 100
% 3) selected = select_feature_corr(x, y, 0, 0, 30);
%    This command selects the top 30% most correlated feature with each target in y.
%
% Last edited by Jianxiao Wu on 15-Mar-2019  

% usage
if nargin < 4
    disp('Usage: selected = select_feature_corr(x, y, sig_sel, n_limit, top_perc, p_thr)');
    return
end

% set default P threshold
if sig_sel == 1 && nargin < 6; p_thr = 0.01; end
      
% set up
p = size(x, 2);
t = size(y, 2);

% get actual maximum of features to select if top_perc is used (rounding down)
if sig_sel == 0; n_limit = floor(p * top_perc / 100); end

% compute correlation between every feature and every target
[selected, p_val] = corr(x, y);
selected(isnan(selected)==1) = 0; % set NaN to 0 (indicating zero variance in a feature)

% remove insignificant features if specified
if sig_sel == 1; selected(p_val > p_thr) = 0; end

% only keep top features if specified
selected_count = sum(selected ~= 0);
[~, selected_rank] = sort(abs(selected), 'descend');
if n_limit ~= 0
    for col = 1:t
        for rank = (n_limit+1):selected_count(col)
            selected(selected_rank(rank, col), col) = 0;
        end
    end
end

% set selected features to 1
selected(selected~=0) = 1;
    

            
