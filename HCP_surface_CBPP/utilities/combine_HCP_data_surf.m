function combine_HCP_data_surf(sub_list, in_dir, n_parc, preproc, corr, out_dir)
% combine_HCP_data_surf(sub_list, in_dir, n_parc, preproc, corr, out_dir)
%
% This function combines functional connectivity (FC) data from HCP
%
% Inputs:
%       - sub_list:
%                  absolute path to subject-list file, where each line contains the
%                  (numerical) subject ID of one HCP subject
%       - in_dir :
%                  absolute path to input directory
%       - n_parc :
%                 parcellation granularity used. Possible values are: 100, 200, 300 and 400
%       - preproc:
%                 preprocessing used for input data. Possible options are: 'minimal', 'fix' and 'fix_gsr'
%        -corr   : 
%                 correlation method used for computing FC. Possible options are: 'Pearson' and 'partial_l2'
%       - out_dir:
%                 Absolute path to output directory
%
% Output:
%       - A .mat file is created in out_dir, containing the the variable 'fc'
%
% Jianxiao Wu, last edited on 12-Sept-2019

% get HCP FC data
sublist = csvread(sub_list);
fc = zeros(n_parc, n_parc, length(sublist));
for i = 1:length(sublist)
    sub = num2str(sublist(i));

    % get average FC across 4 runs
    for runs = {'REST1_LR', 'REST1_RL', 'REST2_LR', 'REST2_RL'};
        run_i = runs{1};

        file_name = ['HCP_' preproc '_parc' num2str(n_parc) '_sub' sub '_' run_i '_' corr '.mat'];
        run_fc = load(fullfile(in_dir, file_name), 'fc');
        fc(:, :, i) = fc(:, :, i) + (run_fc.fc ./ 4);
    end
end

    
% save both data to .mat file
output_file = ['HCP_' preproc '_parc' num2str(n_parc) '_' corr '.mat'];
save(fullfile(out_dir, output_file), 'fc');
