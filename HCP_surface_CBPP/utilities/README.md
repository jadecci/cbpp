# Utility Functions for CBPP Implementation using HCP Data

This folder contains utility functions used by functions in the `HCP_surface_CBPP` folder. These functions do not need to be called by the users.

- `CVPart_HCP.m` and `CVPart_protect_famStruct.m`: creates a matrix of cross-validation indices where family members are always kept in the same folds, for HCP data and for general use respectively.

- `FC_Pearson.m`: computes functional connectivity (FC) matrix using Pearson correlation

- `combine_HCP_data_surf.m`: combine FC matrices of subjects from a subject list into a single matrix and save it for easier loading in the future

- `global_signal_withDiff.m`: computes global average signal and its temporal derivative across specified vertices

- `parcellate_Schaefer_fslr.m`: parcellates timeseries using the Schaefer atlas at a specified granularity 