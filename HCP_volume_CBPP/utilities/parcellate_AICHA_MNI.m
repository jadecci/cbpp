function parc_data = parcellate_AICHA_MNI(input, parc_file)
% parc_data = parcellate_AIHCA_MNI(input, parc_file)
%
% This function parcellates input fMRI data using AIHCA atlas in 2mm MNI152
% space
%
% Inputs:
%       - input   :
%                  109x91x91xT matrix containing time-series data across T
%                  time points from voxels in MNI152 2mm volumetric space.
%       - parc_file:
%                   absolute path to the parcellation file (.nii file)
%
% Output:
%       - parc_data:
%                   384xT matrix containing T time-point data from 384 parcels
%
% Example:
% parc_data = parcellate_AICHA_MNI(HCP_input.vol, 'AICHA.nii');
% This command parcellates the time series from a HCP subject into
% 384 parcels using the AICHA atlas
%
% Jianxiao Wu, last edited on 02-Apr-2020

% usage
if nargin ~= 2
    disp('Usage: parc_data = parcellate_AICHA_MNI(input, parc_file)');
    return
end

% load parcellation
parc = MRIread(parc_file);
parc = parc.vol(:);

% get parcels indices
n_parc = length(unique(parc))-1;
parcels = 1:n_parc;

% parcellate the data
n_t = size(input, 4);
parc_data = zeros(n_parc, n_t);
t_series = reshape(input, size(input,1)*size(input,2)*size(input,3), n_t);
n_nonbrain = 0;
for ind_parc = 1:n_parc
    parcel = parcels(ind_parc);
    % select voxels within the parcel
    selected = t_series(parc==parcel, :);
    selected(isnan(selected(:, 1))==1, :) = [];
    % exclude non-brain voxels
    n_nonbrain = n_nonbrain + sum(abs(mean(selected, 2)) < eps);
    selected(abs(mean(selected, 2)) < eps, :) = [];
    % compute average time series
    parc_data(ind_parc, :) = mean(selected, 1);
end
    
% check how many non-brain voxels were excluded
n_tot = sum(parc ~= 0);
perc_nonbrain = 100 * n_nonbrain / n_tot;
disp([num2str(perc_nonbrain) '% voxels were excluded (non-brain).']);

