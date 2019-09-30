function regressors = global_signal_withDiff(input, vertices)
% regressors = global_signal_withDiff(input, vertices)
%
% This function computes global signal and its temporal derivative (diff)
% from a fMRI input, by averaging across all selected vertices at each time
% point.
%
% Inputs:
%       - input   :
%                  VxT matrix containing time-series data across T time
%                  points from V vertices
%       - vertices:
%                  Nx1 array containing vertices to use in computing global
%                  signal
%
% Output:
%       - regressors:
%                    2xT matrix containing two regressors, the global
%                    signal and its temporal derivative
%
% Example:
% regressors = global_signal_withDiff(HCP_input.dtseries, 1:64984);
% This command computes global signal and derivative from the dense time
% series of a HCP subject, using all the cortical vertices
%
% Jianxiao Wu, last edited on 3-Apr-2018


% usage
if nargin ~= 2
    disp('Usage: regressors = global_signal_withDiff(input, vertices)');
    return
end

% get all time series needed
t_series = input(vertices, :);
t_series(isnan(t_series(:, 1))==1, :) = [];

% get global signal and derivative
gs = mean(t_series, 1);
gs_d = [0 diff(gs)];

% collect output
regressors = [gs; gs_d];
