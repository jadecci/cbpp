# CBPP Implementatin using HCP Data

The CBPP implementation using HCP data involves the following steps:

Step 1: parcellate timeseries data from each run of each subject with Schaefer atlas

Step 2: compute connectivity & get average connectivity matrix across 4 runs

Step 3: combine the average connectivity matrices in one aggregate matrix

Step 4: perform whole-brain or parcel-wise CBPP using a chosen regression method with 10 repeats of 10-fold cross-validation with confound controlling and feature selection


# Example Commands

Use the following commands (while in this folder) in sequence for running the SVR-FIX-Pearson combination of strategies at 300-parcel granularity. 

The input directory (/path/to/input/dir) should contain a sub-folder for each subject, which then contains a sub-folder for each run. The psychometric file (/path/to/psychometric/file) is assumed to be a .mat file containing a variable 'y' of dimension NxP (N = number of subjects, P = number of psychometric variables). Similarly, the confounds file (/path/to/confounds/file) is assumed to be a .mat file containing a variable 'conf' of dimension NxC (C = number of confounding variables).

Step 1: `./HCP_CBPP_step1_parcellate.sh -d /path/to/input/dir`

Step 2: `./HCP_CBPP_step2_fc.sh -d $(pwd)/results/parcellation`

Step 3: `./HCP_CBPP_step3_combine.sh -d $(pwd)/results/FC`

Step 4: 

- whole-brain CBPP: `./HCP_CBPP_step4_wbCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file`

- parcel-wise CBPP: `./HCP_CBPP_step4_pwCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file`