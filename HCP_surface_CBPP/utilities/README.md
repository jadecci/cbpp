# Utility Functions for CBPP Implementation using HCP Data

- `CBIG_glm_regress_matrix.m`: performs general linear model (GLM) regression using provided regressors on an input matrix. This script is copied exactly from the Computational Brain Imaging Group (CBIG) repository (`https://github.com/ThomasYeoLab/CBIG/utilities/matlab/stats/`) under MIT license (`https://github.com/ThomasYeoLab/CBIG/LICENSE.md`).

- `CVPart_HCP.m` and `CVPart_protect_famStruct.m`: creates a matrix of cross-validation indices where family members are always kept in the same folds, for HCP data and for general use respectively.

- `FC_Pearson.m`: computes functional connectivity (FC) matrix using Pearson correlation

- `combine_HCP_data_surf.m`: combine FC matrices of subjects from a subject list into a single matrix and save it for easier loading in the future

- `global_signal_withDiff.m`: computes global average signal and its temporal derivative across specified vertices

- `parcellate_Schaefer_fslr.m`: parcellates timeseries using the Schaefer atlas at a specified granularity 