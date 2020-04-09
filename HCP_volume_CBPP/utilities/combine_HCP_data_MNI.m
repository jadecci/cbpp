function combine_HCP_data_MNI(sub_list, in_dir, atlas, preproc, corr, out_dir)
% combine_HCP_data_MNI(sub_list, in_dir, atlas, preproc, corr, out_dir)
%
% This function combines functional connectivity (FC) data from HCP
%
% Inputs:
%       - sub_list:
%                  absolute path to subject-list file, where each line contains the
%                  (numerical) subject ID of one HCP subject
%       - in_dir :
%                  absolute path to input directory
%       - atlas  :
%                 atlas used for parcellation
%       - preproc:
%                 preprocessing used for input data. Possible options are: 'minimal' and 'fix'
%        -corr   :
%                 correlation method used for computing FC. Possible options are: 'Pearson' and 'partial_l2'
%       - out_dir:
%                 Absolute path to output directory
%
% Output:
%       - A .mat file is created in out_dir, containing the the variable 'fc'
%
% Jianxiao Wu, last edited on 02-Apr-2020

% set up combined FC matrix
sublist = csvread(sub_list);
fc_init = load(fullfile(in_dir, ['HCP_' preproc '_' atlas '_sub' num2str(sublist(1)) '_REST1_LR_' corr '.mat']), 'fc');
n_parc = size(fc_init.fc, 1);
fc = zeros(n_parc, n_parc, length(sublist));

% get all FC data
for i = 1:length(sublist)
    sub = num2str(sublist(i));

    % get average FC across 4 runs
    for runs = {'REST1_LR', 'REST1_RL', 'REST2_LR', 'REST2_RL'}
        run_i = runs{1};

        file_name = ['HCP_' preproc '_' atlas '_sub' sub '_' run_i '_' corr '.mat'];
        run_fc = load(fullfile(in_dir, file_name), 'fc');
        fc(:, :, i) = fc(:, :, i) + (run_fc.fc ./ 4);
    end
end

    
% save both data to .mat file
output_file = ['HCP_' preproc '_' atlas '_' corr '.mat'];
save(fullfile(out_dir, output_file), 'fc');