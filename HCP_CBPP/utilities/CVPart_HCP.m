function cv_ind = CVPart_HCP(n_fold, n_repeat, sub_file, fam_file, seed)
% cv_ind = CVPart_HCP(n_fold, n_repeat, sub_file, fam_file, seed)
%
% This function generates cross-validation indices for HCP subjects in the subject list, keeping 
% family members inside the same fold. 
%
% Inputs:
%       - n_fold  :
%                  Number of folds
%       - n_repeat:
%                  Number of repeats
%       - sub_file:
%                  Absolute path to the .csv file containing all the subject IDs needed
%       - fam_file:
%                  (Optional) Absolute path to the .mat file containing all the family IDs
%                  Note that the default path only works on INM7 server
%                  Default is: /data/BnB_USER/jwu/data/HCP_famID.mat
%       - seed    :
%                  (Optional) Seed used to set up the random number generator. Default is 'shuffle'
%
% Output:
%       - cv_ind:
%                NxM matrix containing cross-validation fold assignment for
%                N subjects across M repeats
%
% Example:
% cv_ind = CVPart_HCP(10, 10, '~/cbpp/bin/sublist/HCP_surf_fix_allRun_sub.csv')
% This command generates cross-validation indices for a 10-fold cross-validation scheme repeating 10 
% times, using the ICA-FIX data
%
% Jianxiao Wu, last edited on 16-Sept-2019

% usage
if nargin < 3
    disp('Usage: cv_ind = CVPart_HCP(n_fold, n_repeat, sub_file, fam_file, seed)');
    return
end

% set up default parameters
if nargin < 4; fam_file = '/data/BnB_USER/jwu/data/HCP_famID.mat'; end
if nargin < 5; seed = 'shuffle'; end

% add utility functions to path
my_path = fileparts(mfilename('fullpath'));
addpath(my_path);

% get ID data
load(fullfile(fam_file), 'all_famID', 'all_subID');
sublist = string(csvread(sub_file));

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
