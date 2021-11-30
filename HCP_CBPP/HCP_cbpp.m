function HCP_cbpp(model, in_dir, out_dir, options)
% Runs whole-brain or region-wise CBPP using FC matrices
%
% ARGUMENTS:
% model     'whole-brain' or 'region-wise'
% in_dir    absolute path to input directory, where files containing combined FC matrices, psychometric variables and
%               confounding vairables can be found
% out_dir   absolute path to the output directory
% options   (Optional) see below for available settings
%
% OPTIONS:
% space         'surf' (default) or 'MNI'
% sub_list      absolute path to a .csv file containing one HCP subject Id on each line. Default subject-list file is
%                   chosen from the 'bin/sublist' folder according to the 'preproc' options.
% preproc       preprocessing option applied in data processing:
%                   'minimal' ('surf' only): only HCP processing pipeline
%                   'fix' ('surf' and 'MNI', default): HCP minimal processing pipeline and ICA-FIX denoising
%                   'fix_wmcsf' ('MNI' only): 'FIX' with nuisance regression 
%                                             (24 motion parameters, WM, CSF and derivatives)
%                   'gsr' ('surf'): 'FIX' with global signal regression
%                   'fix_gsr' (''MNI'): 'FIX' with global signal regression
% atlas         ('surf; only) Schaefer atlas granularity to use for parcellating the data: 
%                   100, 200, 300 (default), or 400
% fc_method     type of correlation used for computing functional connectivity
%                   'Pearson' (default): Pearson correlation
%                   'partial_l2': partial correlation with L2 regularisation
% reg_method    regression algorithm to use for prediction:
%                   'SVR': support vector regression
%                   'RR': ridge regression
%                   'EN': elastic nets
%                   'MLR': multiple linear regression
% parcel        select a sinlge parcel for region-wise CBPP. Default is to use all parcels
%
% OUTPUTS:
% One .mat file will be saved to out_dir, containing the prediction performance
% For example: wbCBPP_SVR_HCP_surf_fix_300_Pearson.mat
%
% Jianxiao Wu, last edited on 29-Nov-2021

if nargin < 3
    disp('HCP_cbpp(model, in_dir, out_dir, <options>)'); return
end

script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(script_dir)));
addpath(fullfile(script_dir, 'utilities'));

if nargin < 4; options = []; end
if ~isfield(options, 'space'); options.space = 'surf'; end
if ~isfield(options, 'preproc'); options.preproc = 'fix'; end
if ~isfield(options, 'sub_list')
    options.sub_list = fullfile(fileparts(script_dir), 'bin', 'sublist', ...
                        ['HCP_' options.space '_' options.preproc '_allRun_sub.csv']); 
end
if ~isfield(options, 'atlas'); options.atlas = 300; end
if strcmp(options.space, 'MNI'); options.atlas = 384; end
if ~isfield(options, 'parcel'); options.parcel = 1:options.atlas; end
options.atlas = num2str(options.atlas);
if strcmp(options.space, 'MNI'); options.atlas = 'AICHA'; end
if ~isfield(options, 'fc_method'); options.fc_method = 'Pearson'; end
if ~isfield(options, 'reg_method'); options.reg_method = 'SVR'; end
options.method = options.reg_method;

load(fullfile(in_dir, ['HCP_' options.space '_' options.preproc '_' options.atlas '_' options.fc_method '.mat']), 'fc');
y = csvread(fullfile(in_dir, 'HCP_y.csv'));
conf = csvread(fullfile(in_dir, 'HCP_conf.csv'));
n_fold = 10; n_repeat = 100;
cv_ind = CVPart_HCP(n_fold, n_repeat, options.sub_list, fullfile(in_dir, 'HCP_famID.mat'), 1); 

switch model
case 'whole-brain'
    options.prefix = ['HCP_' options.space '_' options.preproc '_' options.atlas '_' options.fc_method];
    CBPP_wholebrain(fc, y, conf, cv_ind, out_dir, options);
case 'region-wise'
    for parcel = parcels
        options.prefix = ['HCP_' options.space '_' options.preproc '_' options.atlas '_' options.fc_method ...
                          '_parcel' num2str(parcel)];
        x = squeeze(fc(parcel, :, :)); x(parcel, :) = [];
        CBPP_parcelwise(x, y, conf, cv_ind, out_dir, options);
    end
otherwise
    error('Invalid model option'); return
end