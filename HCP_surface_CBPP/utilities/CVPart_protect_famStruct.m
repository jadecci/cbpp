function cv_ind = CVPart_protect_famStruct(fam_ID, n_fold, n_repeat, seed)
% cv_ind = CVPart_protect_famStruct(fam_ID, n_fold, n_repeat, seed)
%
% This function generates cross-validation indices while protecting family structure i.e. subjects 
% with the same family ID are kept together within folds
%
% Inputs:
%       - fam_ID  :
%                  Nx1 string array containing family IDs from N subjects
%       - n_fold  :
%                  Number of folds
%       - n_repeat:
%                  Number of repeats
%       - seed    :
%                  (Optional) Seed used to set up the random number generator. Default is 'shuffle'
%
% Output:
%       - cv_ind:
%                NxM matrix containing cross-validation fold assignment for N subjects across M repeats
%
% Example:
% cv_ind = CVPart_protect_famStruct(fam_ID, 10, 10)
% This command generates cross-validation indices for a 10-fold cross-validation scheme repeating 10 
% times, using the family IDs provided
%
% Jianxiao Wu, last edited on 18-Mar-2018

% usage
if nargin < 3
    disp('Usage: cv_ind = CVPart_protect_famStruct(fam_ID, n_fold, n_repeat, seed)');
    return
end

% set RNG seed
if nargin >= 4
    rng(seed);
else
    rng('shuffle')
end

% other set-up
n = length(fam_ID);
fold_size_min = round(n/n_fold);

% get partition indices
cv_ind = zeros(n, n_repeat);
for repeat = 1:n_repeat
    ind_toFill = 1:n;
    for fold = 1:n_fold
        while (length(ind_toFill) > (n - fold * fold_size_min)) && ...
                (~ isempty(ind_toFill))
            
            % start by assigning fold to a random non-filled subject
            fill_start = randi(length(ind_toFill));
            fill_start_actual = ind_toFill(fill_start);
            cv_ind(fill_start_actual, repeat) = fold;
            ind_toFill(fill_start) = [];
            
            % then add all its family members to the fold
            fill_famID = fam_ID(fill_start_actual);
            fill_famInd = find(fam_ID==fill_famID);
            fill_famInd(fill_famInd==fill_start_actual) = [];
            cv_ind(fill_famInd, repeat) = fold;
            
            % remove all filled subjects from the to-fill list
            for l = 1:length(fill_famInd)
                ind_toFill(ind_toFill==fill_famInd(l)) = [];
            end
        end
    end
end
            


