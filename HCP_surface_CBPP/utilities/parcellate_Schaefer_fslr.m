function parc_data = parcellate_Schaefer_fslr(input, n_parc, parc_file)
% parc_data = parcellate_Schaefer_fslr(input, n_parc, parc_file)
%
% This function parcellates input fMRI data using Schaefer atlas on the fsLR surface, at the 
% specified granularity
%
% Inputs:
%       - input    :
%                   VxT matrix containing time-series data across T time points from V vertices
%       - n_parc   :
%                   Granularity of parcellation
%       - parc_file:
%                   absolute path to the parcellation file (.dlabel.nii)
%
% Output:
%       - parc_data:
%                   PxT matrix containing T time-point data from P parcels
%
% Example:
% parc_data = parcellate_Schaefer_fslr(HCP_input.dtseries, 100);
% This parcellates the time series from a HCP subject into 100 parcels using the Schaefer atlas
%
% Jianxiao Wu, last edited on 06-Sept-2019

% usage
if nargin ~= 3
    disp('Usage: parc_data = parcellate_Schaefer_fslr(input, n_parc, parc_file)');
    return
end

% load parcellation
parc = ft_read_cifti(parc_file);
n_vertex = length(parc.parcels);

% parcellate input
t_series = input(1:n_vertex, :);
n_t = size(t_series, 2);
parc_data = zeros(n_parc, n_t);
for parcel = 1:n_parc
    selected = t_series(parc.parcels==parcel, :);
    selected(isnan(selected(:, 1))==1, :) = []; % exclude NaN values from averaging
    parc_data(parcel, :) = mean(selected, 1);
end







