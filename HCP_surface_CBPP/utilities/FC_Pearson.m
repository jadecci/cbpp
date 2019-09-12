function fc = FC_Pearson(parc_data, out_dir, out_prefix)
% fc = FC_Pearson(parc_data, out_dir, out_prefix)
%
% This function computes functional connectivity (FC) given parcellated data, using Pearson correlation
%
% Inputs:
%       - parc_data :
%                    PxT matrix containing T time-point data from P parcels
%       - out_dir   :
%                    Absolute path to output directory
%       - out_prefix:
%                    Prefix for output file name. The output file will be named as 'out_prefix_Pearson.mat'
%
% Output:
%       - fc:
%            PxP matrix containing Pearson correlation coefficients between every pair of time-point data
%       - A .mat file is also created in out_dir, containing the the variable 'fc'
%
% Example:
% FC_Pearson(parc_data, 'results');
% This command computes Pearson connectivity using parc_data, and save the results to 'results' directory
%
% Jianxiao Wu, last edited on 18-Mar-2018

% usage
if nargin < 3
    disp('Usage: fc = FC_Pearson(parc_data, out_dir, out_prefix)');
    return
end

% set-up
n_parc = size(parc_data, 1);

% compute FC
fc = zeros(n_parc, n_parc);
for i = 1:n_parc
    for j = i:n_parc
        
        % find Pearson corr coefficient
        r = corrcoef(parc_data(i, :), parc_data(j, :));
        
        % Fisher z-transformation
        if abs(r(1, 2) - 1) < eps
            z = 1; %set diagonal to 1
        else
            z = 0.5*(log(1+r(1,2)) - log(1-r(1,2))); 
        end
        
        % assign to both upper&lower triangle
        fc(i, j) = z;
        fc(j, i) = fc(i, j);
    end
end

% save results
save([out_dir '/' out_prefix '_Pearson.mat'], 'fc');
    


