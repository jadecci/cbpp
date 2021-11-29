# Utility Functions for CBPP Implementation using HCP Data

This folder contains utility functions used by functions in the `HCP_surface_CBPP` folder. These functions do not need to be called by the users.

- `CVPart_HCP.m` and `CVPart_protect_famStruct.m`: creates a matrix of cross-validation indices where family members are always kept in the same folds, for HCP data and for general use respectively.

- `FC_Pearson.m`: computes functional connectivity (FC) matrix using Pearson correlation