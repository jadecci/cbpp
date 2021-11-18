function generalise_cbpp(model, measure, dataset, atlas, in_dir, psy_file, conf_file, out_dir, saveWeights)
% This script runs whole-brain or region-wise CBPP using combined connectivity data
%
% ARGUMENTS:
% model        'whole-brain' or 'region-wise'
% measure      psychometric measure to predict. Choose from 'openness', 'fluidcog' and 'fluidint' (HCP-YA only)
% dataset      short-form name of the dataset/cohort. Choose from 'HCP-YA', 'eNKI-RS', 'GSP', and 'HCP-A'
% atlas        short-form name of the atlas used for parcellation. Choose from 'AICHA', 'SchMel1', 'SchMel2', 
%                'SchMel3' and 'SchMel4'
% input_dir    absolute path to input directory
% psy_file     absolute path to the .mat file containing the psychometric variables to predict
% conf_file    absolute path to the .mat file containing the confounding variables
% output_dir   absolute path to output directory
% saveWeights  (default: 0) set to 1 to also save the regression weights from whole-brain CBPP models
%
% OUTPUT:
% 1 output file in the output directory containing the prediction performance, and whole-brain model regression
% weights if saveWeights=1
% For example: wbCBPP_SVR_eNKI-RS_AICHA_fluidcog.mat
%
% Jianxiao Wu, last edited on 18-Nov-2021

if nargin ~= 9
    generalise_cbpp(model, measure, dataset, atlas, in_dir, psy_file, conf_file, out_dir, saveWeights)
end

script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(script_dir), 'HCP_surface_CBPP', 'utilities'));

load(fullfile(in_dir, [dataset '_fix_wmcsf_' atlas '_Pearson.mat']), 'fc');
load(psy_file, 'y');
load(conf_file, 'conf');
n_fold = 10; n_repeat = 100;
options = []; options.conf_opt = 'standard'; options.method = 'SVR'; options.save_weights = saveWeights;

switch dataset
case 'HCP-YA'
    sublist = csvread(fullfile(fileparts(script_dir), 'bin', 'sublist', 'HCP_MNI_fix_wmcsf_allRun_sub.csv'));
    cv_ind = CVPart_HCP(n_fold, n_repeat, sublist, fullfile(in_dir, 'HCP-YA_famID.mat'), 1);
case 'HCP-A'
    sublist = csvread(fullfile(fileparts(script_dir), 'bin', 'sublist', 'HCP-A_allRun_sub.csv'));
    cv_ind = CVPart_noFam(n_fold, n_repeat, length(sublist), 1);
case 'eNKI-RS'
    subdata = readtable(fullfile(fileparts(script_dir), 'bin', 'sublist', 'eNKI-RS_int_allRun_sub.csv'));
    cv_ind = CVPart_noFam(n_fold, n_repeat, length(sublist), 1);
case 'GSP'
    sublist = csvread(fullfile(fileparts(script_dir), 'bin', 'sublist', 'GSP_allRun_sub.csv'));
    cv_ind = CVPart_noFam(n_fold, n_repeat, length(sublist), 1);
otherwise
    error('Invalid dataset option.'); return
end

switch atlas
case 'AICHA'
    nparc = 384;
case 'SchMel1'
    nparc = 100 + 16;
case 'SchMel2'
    nparc = 200 + 32;
case 'SchMel3'
    nparc = 300 + 50;
case 'SchMel4'
    nparc = 400 + 54;
otherwise
    error('Invalid atlas option'); return
end

if strcmp(model, 'whole-brain')
    options.prefix = [dataset '_' atlas '_' measure];
    CBPP_wholebrain(fc, y, conf, cv_ind, out_dir, options);
elseif strcmp(model, 'region-wise')
    for parcel = 1:nparc
        options.prefix = [dataset '_' atlas '_' measure '_parcel' num2str(parcel)];
        x = squeeze(fc(parcel, :, :)); x(parcel, :) = [];
        CBPP_parcelwise(x, y, conf, cv_ind, out_dir, options);
    end
else
    error('Invalid model option'); return
end

end

function CVPart_noFam(n_fold, n_repeat, n_sub, seed)

rng(seed);
cv_ind = zeros(n_sub, n_repeat);
for repeat = 1:n_repeat
    cv_part = cvpartition(n_sub, 'KFold', n_fold);
    for fold = 1:n_fold
        test_ind = cvpart.test(fold);
        cv_ind(test_ind==1, repeat) = fold;
    end
end

end

