function cv_ind = CVPart_HCP(preproc, n_fold, n_repeat, data_dir, seed)
% cv_ind = CVPart_HCP(preproc, n_fold, n_repeat, data_dir, seed)
%
% This function generates cross-validation indices for HCP subjects, keeping family members inside
% the same fold. 
%
% Inputs:
%       - preproc :
%                  Pre-processing used in the data. Choose from 'minimal' and 'fix'.
%       - n_fold  :
%                  Number of folds
%       - n_repeat:
%                  Number of repeats
%       - data_dir:
%                  Directory where lists of subject IDs and family IDs are stored.
%       - seed    :
%                  (Optional) Seed used to set up the random number generator. Default is 'shuffle'
%
% Output:
%       - cv_ind:
%                NxM matrix containing cross-validation fold assignment for
%                N subjects across M repeats
%
% Example:
% cv_ind = CVPart_HCP('fix', 10, 10, '~/cbpp/bin/sublist')
% This command generates cross-validation indices for a 10-fold cross-validation scheme repeating 10 
% times, using the ICA-FIX data
%
% Jianxiao Wu, last edited on 1-Jul-2018

% usage
if nargin < 3
    disp('Usage: cv_ind = CVPart_HCP(preproc, n_fold, n_repeat, data_dir, seed)');
    return
end

% set up default parameters
if nargin < 5
    seed = 'shuffle';
end

% add utility functions to path
my_path = fileparts(mfilename('fullpath'));
addpath(my_path);

% get ID data
load(fullfile(data_dir, 'HCP_famID.mat'), 'all_famID', 'all_subID');
sublist = string(csvread(fullfile(data_dir, ['HCP_surf_' preproc '_allRun_sub.csv'])));

% extract family IDs from subjects with all 4 sessions
famID = string(1:length(sublist))';
[all_subID, sort_ind] = sort(all_subID);
all_famID = all_famID(sort_ind);
index = 1;
for i = 1:length(sublist)
    done = 0;
    while ~done
        if strcmp(all_subID(index), sublist(i))
            famID(i) = all_famID(index);
            done = 1;
        end
        index = index + 1;
    end   
end

% get cross-validation indices
cv_ind = CVPart_protect_famStruct(famID, n_fold, n_repeat, seed);
