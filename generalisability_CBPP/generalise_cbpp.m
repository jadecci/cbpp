function generalise_cbpp(model, dataset, atlas, in_dir, out_dir, saveWeights, sublist, parcel)
% This script runs whole-brain or region-wise CBPP using combined connectivity data
%
% ARGUMENTS:
% model        'whole-brain' or 'region-wise'
% dataset      short-form name of the dataset/cohort. Choose from 'HCP-YA', 'eNKI-RS', 'GSP', and 'HCP-A'
% atlas        short-form name of the atlas used for parcellation. Choose from 'AICHA', 'SchMel1', 'SchMel2', 
%                'SchMel3' and 'SchMel4'
% input_dir    absolute path to input directory
% output_dir   absolute path to output directory
% saveWeights  (default: 0) set to 1 to also save the regression weights from whole-brain CBPP models
% sublist      (optional) absolute path to custom subject list (.csv file where each line is one subject ID)
% parcel       (optional) pick one parcel to run region-wise CBPP
%
% OUTPUT:
% 1 output file in the output directory containing the prediction performance, and whole-brain model regression
% weights if saveWeights=1
% For example: wbCBPP_SVR_eNKI-RS_AICHA_fluidcog.mat
%
% Jianxiao Wu, last edited on 26-Nov-2021

if nargin < 5
    disp('generalise_cbpp(model, dataset, atlas, in_dir, out_dir, <saveWeights>, <sublist>, <parcel>)'); return
end

if nargin < 6
    saveWeights = 0;
end

if nargin < 7
    sublist='';
end

script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(script_dir)));
addpath(fullfile(fileparts(script_dir), 'HCP_CBPP', 'utilities'));

load(fullfile(in_dir, [dataset '_fix_wmcsf_' atlas '_Pearson.mat']), 'fc', 'y', 'conf');
n_fold = 10; n_repeat = 100;
options = []; options.save_weights = saveWeights;

switch dataset
case 'HCP-YA'
    if nargin < 7
        sublist = fullfile(fileparts(script_dir), 'bin', 'sublist', 'HCP_MNI_fix_wmcsf_allRun_sub.csv');
    end
    cv_ind = CVPart_HCP(n_fold, n_repeat, sublist, fullfile(in_dir, 'HCP-YA_famID.mat'), 1);
case 'HCP-A'
    if nargin < 7
        sublist = fullfile(fileparts(script_dir), 'bin', 'sublist', 'HCP-A_allRun_sub.csv');
    end
    cv_ind = CVPart_noFam(n_fold, n_repeat, size(readtable(sublist), 1), 1);
case 'eNKI-RS'
    if nargin < 7
        subdata = fullfile(fileparts(script_dir), 'bin', 'sublist', 'eNKI-RS_int_allRun_sub.csv');
    end
    cv_ind = CVPart_noFam(n_fold, n_repeat, size(readtable(sublist), 1), 1);
case 'GSP'
    if nargin < 7
        sublist = fullfile(fileparts(script_dir), 'bin', 'sublist', 'GSP_allRun_sub.csv');
    end
    cv_ind = CVPart_noFam(n_fold, n_repeat, length(csvread(sublist)), 1);
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

if nargin < 8
    parcels = 1:nparc;
else
    parcels = parcel;
end

if strcmp(model, 'whole-brain')
    options.prefix = [dataset '_' atlas];
    CBPP_wholebrain(fc, y, conf, cv_ind, out_dir, options);
elseif strcmp(model, 'region-wise')
    for parcel = parcels
        options.prefix = [dataset '_' atlas '_parcel' num2str(parcel)];
        x = squeeze(fc(parcel, :, :)); x(parcel, :) = [];
        CBPP_parcelwise(x, y, conf, cv_ind, out_dir, options);
    end
else
    error('Invalid model option'); return
end

end

function cv_ind = CVPart_noFam(n_fold, n_repeat, n_sub, seed)

rng(seed);
cv_ind = zeros(n_sub, n_repeat);
for repeat = 1:n_repeat
    cv_part = cvpartition(n_sub, 'KFold', n_fold);
    for fold = 1:n_fold
        test_ind = cv_part.test(fold);
        cv_ind(test_ind==1, repeat) = fold;
    end
end

end

