function HCPvol_data_proc(in_dir, conf_dir, out_dir, options)
% Process HCP surface data with optional nuisance or global signal regression, followed by parcellation (using the
% AICHA atlas) and functional connectivity (FC) computation.
%
% ARGUMENTS:
% in_dir    absolute path to input directory of HCP data, which should be organised in the same way as the original data
%               downloaded from HCP
% conf_dir  absolute path to confounds directory. The folder structure should be the same as 'in_dir'
% out_dir   absolute path to the output directory
% options   (Optional) see below for available settings
%
% OPTIONS:
% sub_list      absolute path to a .csv file containing one HCP subject Id on each line. Default subject-list file is
%                   chosen from the 'bin/sublist' folder according to the 'preproc' options.
% preproc       preprocessed data to use or preprocessing to apply.
%                   'fix': HCP minimal processing pipeline and ICA-FIX denoising
%                   'fix_wmcsf' (default): 'FIX' with nuisance regression 
%                                           (24 motion parameters, WM, CSF and derivatives)
%                   'fix_gsr': 'FIX' with global signal regression
% fc_method     type of correlation to compute for functional connectivity
%                   'Pearson' (default): Pearson correlation
%                   'partial_l2': partial correlation with L2 regularisation
%
% OUTPUTS:
% One .mat file will be saved to out_dir, containing the combined FC matrix across all subjects in sub_list
% For example: HCP_MNI_fix_wmcsf_AICHA_Pearson.mat
%
% Jianxiao Wu, last edited on 29-Nov-2021

if nargin < 3
    disp('Usage: HCPvol_data_proc(in_dir, conf_dir, out_dir, <options>'); return
end

script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(script_dir, 'utilities'));

if nargin < 4; options = []; end
if ~isfield(options, 'preproc'); options.preproc = 'fix_wmcsf'; end
if ~isfield(options, 'sub_list')
    options.sub_list = fullfile(fileparts(script_dir), 'bin', 'sublist', ...
                        ['HCP_MNI_' options.preproc '_allRun_sub.csv']); 
end
if ~isfield(options, 'fc_method'); options.fc_method = 'Pearson'; end

output = fullfile(out_dir, ['HCP_MNI_' options.preproc '_AICHA_' options.fc_method '.mat']);
if isfile(output)
    fprintf('Output %s already exists\n', output); return
end

subjects = csvread(options.sub_list);
run = {'rfMRI_REST1_LR', 'rfMRI_REST1_RL', 'rfMRI_REST2_LR', 'rfMRI_REST2_RL'};
fc = zeros(384, 384, length(subjects));
for sub_ind = 1:length(subjects)
    subject = num2str(subjects(sub_ind));
    for i = 1:length(run)
        input_dir = fullfile(in_dir, subject, 'MNINonLinear', 'Results', run{i});
        input = MRIread(fullfile(input_dir, [run{i} '_hp2000_clean.nii.gz']));
        load(fullfile(conf_dir, subject, 'MNINonLinear', 'Results', run{i}, ['Confounds_' subject '.mat']));

        % preprocessing
        dim = size(input.vol);
        input.vol = reshape(input.vol, prod(dim(1:3)), dim(4));
        switch options.preproc
        case 'fix'
            resid = input.vol';
        case 'fix_wmcsf'
            regressors = [reg(:, 9:32) gx2([2:3], :)' [zeros(1, 2); diff(gx2([2:3], :)')]];
            [resid, ~, ~, ~] = CBIG_glm_regress_matrix(input.vol', regressors, 1, []);
        case 'fix_gsr'
            regressors = [reg(:, 9:32) gx2(4, :)' [zeros(1, 1); diff(gx2(4, :)')]];
            [resid, ~, ~, ~] = CBIG_glm_regress_matrix(input.vol', regressors, 1, []);
        otherwise
            error('Invalid preprocessing option'); return
        end

        % parcellation
        parc_data = parcellate_AICHA_MNI(resid');

        % connectivity computation
        switch options.fc_method
        case 'Pearson'
            fc(:, :, sub_ind) = fc(:, :, sub_ind) + FC_Pearson(parc_data);
        case 'partial_l2'
            addpath(fullfile(fileparts(script_dir), 'bin', 'external_packages', 'FSLNets'));
            fc(:, :, sub_ind) = fc(:, :, sub_ind) + nets_netmats(parc_data', 1, 'ridgep');
        otherwise
            error('Invalid FC option'); return
        end
    end
    fc(:, :, sub_ind) = fc(:, :, sub_ind) ./ length(run);
end

save(output, 'fc');

end

function parc_data = parcellate_AICHA_MNI(input)

parc = MRIread(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'bin', 'parcellations', 'AICHA.nii'));
parc = parc.vol;
parcels = unique(parc);

parc_data = zeros(length(parcels)-1, size(input, 2));
for parcel_ind = 2:length(parcels)
    selected = input(parc==parcels(parcel_ind), :);
    selected(isnan(selected(:, 1))==1, :) = [];
    selected(abs(mean(selected, 2))<eps, :) = []; % non-brain voxels
    parc_data(parcel_ind-1, :) = mean(selected, 1);
end

end
    