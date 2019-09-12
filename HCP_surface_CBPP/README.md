# CBPP Implementatin using HCP Data

The CBPP implementation using HCP data involves the following steps:

Step 1: parcellate timeseries data from each run of each subject with Schaefer atlas

Step 2: compute connectivity & get average connectivity matrix across 4 runs

Step 3: combine the average connectivity matrices in one aggregate matrix

Step 4: perform whole-brain or parcel-wise CBPP using a chosen regression method with 10 repeats of 10-fold cross-validation with confound controlling and feature selection


# Example Commands

Use the following commands in sequence for running the SVR-FIX-Pearson combination of strategies at 300-parcel granularity. The input directory (/path/to/input/dir) should contain a sub-folder for each subject, which then contains a sub-folder for each run. 

Step 1: `HCP_CBPP_step1_parcellate.sh -n 300 -p gsr_cortex -d /path/to/gsr/output/dir`