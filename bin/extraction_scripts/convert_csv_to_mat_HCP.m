function convert_csv_to_mat_HCP(psych_file, conf_unres_file, conf_res_file, out_dir, out_prefix)
% convert_csv_to_mat_HCP(psych_file, conf_unres_file, conf_res_file, out_dir, out_prefix)
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
%
% Output:
%        2 files will be saved to the output directory, containing the converted psychometric and confounding variables
%        respectively. The files would be named as:
%           out_prefix_y.mat
%           out_prefix_conf.mat
%
% Jianxiao Wu, last edited on 08-Apr-2020

% usage
if nargin ~= 5
    disp('Usage: convert_csv_to_mat_HCP(psych_file, conf_unres_file, conf_res_file, out_dir, out_prefix)');
    return
end

% psychometric variables
y = csvread(psych_file, 1);
n = size(y, 1);

% confounding variables
conf_unres = readtable(conf_unres_file);
conf_res = readtable(conf_res_file);
conf = zeros(n, 9);
% Age
conf(:, 1) = table2array(conf_res(:, 1));
% Gender
gender = table2cell(conf_unres(:, 2));
for i = 1:n; if strcmp(gender{i}, 'M'); conf(i, 2) = 1; else; conf(i, 2) = 2; end; end
% Handedness
conf(:, 3) = table2array(conf_res(:, 2));
% Brain size
conf(:, 4) = table2array(conf_unres(:, 4));
% Age^2
conf(:, 5) = conf(:, 1).^2;
% Gender x age
conf(:, 6) = conf(:, 1) .* conf(:, 2);
% Gender x age^2
conf(:, 7) = conf(:, 6) .* conf(:, 1);
% ICV
conf(:, 8) = table2array(conf_unres(:, 3));
% Acquisition quarter
acq = table2cell(conf_unres(:, 1));
for i = 1:n; conf(i, 9) = str2double(acq{i}(2:end)); end

% save results\
save(fullfile(out_dir, [out_prefix '_y.mat']), 'y');
save(fullfile(out_dir, [out_prefix '_conf.mat']), 'conf');