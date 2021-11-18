function convert_csv_to_mat_HCP(psych_file, conf_unres_file, conf_res_file, out_dir, out_prefix, mat_out)
% convert_csv_to_mat_HCP(psych_file, conf_unres_file, conf_res_file, out_dir, out_prefix, mat_out)
%
% This function converts extracted psychometric and confounding variables in csv files to .mat files, which can then be
% used for CBPP_wholebrain.m, CBPP_parcelwise.m or unit test.
%
% Inputs:
%       - psych_file       :
%                           Absolute path to the csv file containing extracted psychometric variables. The first row is
%                           assumed to be the headers
%       - conf__unres_file :
%                           Absolute path to the csv file containing extracted confounding variables from unrestricted 
%                           data. The first row is assumed to be the headers
%       - conf__res_file   :
%                           Absolute path to the csv file containing extracted confounding variables from restricted 
%                           data. The first row is assumed to be the headers
%       - out_dir          :
%                           Absolute path to the output directory
%       - out_prefix       :
%                           Prefix for output file
%       - mat_out          :
%                           Set to 0 to save output files in .csv format. Set to 1 to save in .mat format instead
%
% Output:
%        2 files will be saved to the output directory, containing the converted psychometric and confounding variables
%        respectively. The files would be named as:
%           out_prefix_y.csv
%           out_prefix_conf.csv
%
% Jianxiao Wu, last edited on 18-Nov-2021

% usage
if nargin ~= 6
    disp('Usage: convert_csv_to_mat_HCP(psych_file, conf_unres_file, conf_res_file, out_dir, out_prefix, mat_out)');
    return
end

% psychometric variables
psych = csvread(psych_file, 1);
n = size(psych, 1) - 1;
n_score = size(psych, 2);
col_ind = psych(end, :);
[~, sort_ind] = sort(col_ind, 'ascend');
y = zeros(n, n_score);
for i = 1:n_score; y(:, i) = psych(1:n, sort_ind==i); end

% confounding variables
conf_unres = readtable(conf_unres_file);
conf_res = readtable(conf_res_file);
conf = zeros(n, 9);
% Age
conf(:, 1) = table2array(conf_res(1:n, 1));
% Gender
gender = table2cell(conf_unres(1:n, 2));
for i = 1:n; if strcmp(gender{i}, 'M'); conf(i, 2) = 1; else; conf(i, 2) = 2; end; end
% Handedness
conf(:, 3) = table2array(conf_res(1:n, 2));
% Brain size
conf(:, 4) = table2array(conf_unres(1:n, 4));
% Age^2
conf(:, 5) = conf(1:n, 1).^2;
% Gender x age
conf(:, 6) = conf(1:n, 1) .* conf(1:n, 2);
% Gender x age^2
conf(:, 7) = conf(1:n, 6) .* conf(1:n, 1);
% ICV
conf(:, 8) = round(table2array(conf_unres(1:n, 3)) .* 1000) ./ 1000; % keep 9 decimal places to be consistent
% Acquisition quarter
acq = table2cell(conf_unres(1:n, 1));
for i = 1:n; conf(i, 9) = str2double(acq{i}(2:end)); end

% save results
if mat_out == 0
    dlmwrite(fullfile(out_dir, [out_prefix '_y.csv']), y, 'precision', 6);
    dlmwrite(fullfile(out_dir, [out_prefix '_conf.csv']), conf, 'precision', 6);
elseif mat_out == 1
    save(fullfile(out_dir, [out_prefix '_y.mat']), 'y');
    save(fullfile(out_dir, [out_prefix '_conf.mat']), 'conf');
end