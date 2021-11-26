function generalise_cross_dataset(dataset1, dataset2, atlas, in_dir, out_dir)
% This script runs cross-dataset region-wise CBPP across all parcels for a pair of datasets
%
% ARGUMENTS:
% dataset1     short-form name of the first dataset/cohort. Choose from 'HCP-YA', 'eNKI-RS', 'GSP', and 'HCP-A'
% dataset2     short-form name of the second dataset/cohort. Choose from 'HCP-YA', 'eNKI-RS', 'GSP', and 'HCP-A'
% atlas        short-form name of the atlas used for parcellation. Choose from 'AICHA', 'SchMel1', 'SchMel2', 
%                'SchMel3' and 'SchMel4'
% input_dir    absolute path to input directory
% output_dir   absolute path to output directory
%
% OUTPUT:
% 1 output file in the output directory containing the prediction performance
% For example: pwCBPP_SVR_HCP-YA_eNKI-RS_AICHA.mat
%
% Jianxiao Wu, last edited on 26-Nov-2021

if nargin ~= 5
    disp('generalise_cross_dataset(dataset1, dataset2, atlas, in_dir, out_dir)'); return
end

script_dir = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(script_dir)));
addpath(fullfile(fileparts(script_dir), 'utilities'));

data1 = load(fullfile(in_dir, [dataset1 '_fix_wmcsf_' atlas '_Pearson.mat']), 'fc', 'y', 'conf');
y1 = regress_confounds_y(data1.y(:, 1), data1.conf); % fluid cognition
data2 = load(fullfile(in_dir, [dataset2 '_fix_wmcsf_' atlas '_Pearson.mat']), 'fc', 'y', 'conf');
y2 = regress_confounds_y(data2.y(:, 2), data2.conf); % fluid cognition

n_fold = 10; n_repeat = 100;
nparc = size(data1.fc, 1);

r_train = zeros(nparc, 2);
r_test = zeros(nparc, 2);
nrmsd_train = zeros(nparc, 2);
nrmsd_test = zeros(nparc, 2);
for parcel = 1:nparc
    x1 = squeeze(data1.fc(parcel, :, :)); x1(parcel, :) = [];
    x2 = squeeze(data1.fc(parcel, :, :)); x2(parcel, :) = [];
    traintest_split = [ones(length(y1), 1), 2*ones(length(y2), 1)];

    perf = SVR_one_fold([x1, x2]', [y1; y2], traintest_split, 1);
    r_train(parcel, 1) = perf.r_train;
    r_test(parcel, 1) = perf.r_test;
    nrmsd_train(parcel, 1) = perf.nrmsd_train;
    nrmsd_test(parcel, 1) = perf.nrmsd_test;

    perf = SVR_one_fold([x1, x2]', [y1; y2], traintest_split, 2);
    r_train(parcel, 2) = perf.r_train;
    r_test(parcel, 2) = perf.r_test;
    nrmsd_train(parcel, 2) = perf.nrmsd_train;
    nrmsd_test(parcel, 2) = perf.nrmsd_test;
end

output = fullfile(out_dir, ['pwCBPP_SVR_' dataset1 '_' dataset2 '_' atlas '.mat']);
save(output, 'r_train', 'r_test', 'nrmsd_train', 'nrmsd_test');

end