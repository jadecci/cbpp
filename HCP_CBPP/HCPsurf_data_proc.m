function HCPsurf_data_proc(in_dir, out_dir, options)
% Process HCP surface data with optional global signal regression, followed by parcellation and functional connectivity
% (FC) computation.
%
% ARGUMENTS:
% in_dir    absolute path to input directory of HCP data, which should be organised in the same way as the original data
%               downloaded from HCP
% out_dir   absolute path to the output directory
% options   (Optional) see below for available settings
%
% OPTIONS:
% sub_list      absolute path to a .csv file containing one HCP subject Id on each line. Default subject-list file is
%                   chosen from the 'bin/sublist' folder according to the 'preproc' options.
% preproc       preprocessed data to use or preprocessing to apply.
%                   'minimal': only HCP processing pipeline
%                   'fix' (default): 'minimal' with ICA-FIX denoising
%                   'gsr': 'FIX' with global signal regression
% atlas         Schaefer atlas granularity to use for parcellating the data: 100, 200, 300 (default), or 400
% fc_method     type of correlation to compute for functional connectivity
%                   'Pearson' (default): Pearson correlation
%                   'partial_l2': partial correlation with L2 regularisation
%
% OUTPUTS:
% One .mat file will be saved to out_dir, containing the combined FC matrix across all subjects in sub_list
% For example: HCP_surf_fix_300_Pearson.mat
%
% Jianxiao Wu, last edited on 29-Nov-2021

if nargin < 2
    disp('Usage: HCPsurf_data_proc(in_dir, out_dir, <options>'); return
end

script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(script_dir, 'utilities'));
addpath(fullfile(fileparts(script_dir), 'bin', 'external_packages', 'cifti-matlab'));

if nargin < 3; options = []; end
if ~isfield(options, 'preproc'); options.preproc = 'fix'; end
if ~isfield(options, 'sub_list')
    options.sub_list = fullfile(fileparts(script_dir), 'bin', 'sublist', ...
                       ['HCP_surf_' options.preproc '_allRun_sub.csv']); 
end
if ~isfield(options, 'atlas'); options.atlas = 300; end
if ~isfield(options, 'fc_method'); options.fc_method = 'Pearson'; end

output = fullfile(out_dir, ['HCP_surf_' options.preproc '_' num2str(options.atlas) '_' options.fc_method '.mat']);
if isfile(output)
    fprintf('Output %s already exists\n', output); return
end

subjects = csvread(options.sub_list);
run = {'rfMRI_REST1_LR', 'rfMRI_REST1_RL', 'rfMRI_REST2_LR', 'rfMRI_REST2_RL'};
fc = zeros(options.atlas, options.atlas, length(subjects));
for sub_ind = 1:length(subjects)
    subject = num2str(subjects(sub_ind));
    for i = 1:length(run)
        input_dir = fullfile(in_dir, subject, 'MNINonLinear', 'Results', run{i});

        % preprocessing
        switch options.preproc
        case 'minimal'
            input = ft_read_cifti(fullfile(input_dir, [run{i} '_Atlas.dtseries.nii']));
        case 'fix'
            input = ft_read_cifti(fullfile(input_dir, [run{i} '_Atlas_hp2000_clean.dtseries.nii']));
        case 'gsr'
            input = ft_read_cifti(fullfile(input_dir, [run{i} '_Atlas_hp2000_clean.dtseries.nii']));
            regressors = global_signal_withDiff(input.dtseries);
            [resid, ~, ~, ~] = CBIG_glm_regress_matrix(single(input.dtseries)', regressors', 1, []);
            input.dtseries = resid';
        otherwise
            error('Invalid preprocessing option'); return
        end

        % parcellation
        parc_data = parcellate_Schaefer_fslr(input.dtseries, options.atlas);

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

function regressors = global_signal_withDiff(input)

t_series = input(1:64984, :);
t_series(isnan(t_series(:, 1))==1, :) = [];
gs = mean(t_series, 1);
gs_d = [0 diff(gs)];
regressors = [gs; gs_d];

end

function parc_data = parcellate_Schaefer_fslr(input, level)

parc_file = fullfile(fileparts(script_dir), 'bin', 'parcellations', ...
        ['Schaefer2018_' num2str(level) 'Parcels_17Networks_order.dlabel.nii']);
parc = ft_read_cifti(parc_file);

t_series = input(1:length(parc.parcels), :);
n_t = size(t_series, 2);
parc_data = zeros(n_parc, n_t);
for parcel = 1:n_parc
    selected = t_series(parc.parcels==parcel, :);
    selected(isnan(selected(:, 1))==1, :) = []; % exclude NaN values from averaging
    parc_data(parcel, :) = mean(selected, 1);
end

end
