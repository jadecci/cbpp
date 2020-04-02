This folder contains codes to replicate all 72 combination of approaches used in our paper. These approaches are available for surface data at each step of CBPP:

- **preprocessing**: `minimal` (only minimal processing pipeline), `FIX` ('minimal' + FIX denoising), `FIX+GSR` ('FIX' + global signal regression)

- **parcellation granularity (Schaefer atlas)**: `100`, `200`, `300`, `400`

- **functional connectivity**: `Pearson` (Pearson correlation), `partial_l2` (partial correlation with L2 regularisation)

- **regression/prediction**: `SVR` (Support Vector Regression), `EN` (Elastic nets), `KRRcorr` (Kernel Ridge Regression with correlation kernel)

For `minimally processed` or `FIX`data, follow Example 1; for `FIX+GSR` data, follow Example 2. At each step, if any parameter needs to be switched, you can check the respective script's usage by running it with no argument (e.g. run `./HCP_CBPP_step1_parcellate.sh` on command line).

For more detailed description of the CBPP implementation using HCP surface data, see `bin/procedure_descriptions/README.md`.


# Example 1: SVR-minimal-Pearson-300-parcel

Use the following commands (while in this folder) in sequence for running the SVR-minimal-Pearson combination of strategies at 300-parcel granularity. 

The input directory (`/path/to/input/dir`) should contain a sub-folder for each subject, which then contains a sub-folder for each run. The psychometric file (/path/to/psychometric/file) is assumed to be a .mat file containing a variable `y` of dimension NxY (N = number of subjects, Y = number of psychometric variables). Similarly, the confounds file (`/path/to/confounds/file`) is assumed to be a .mat file containing a variable `conf` of dimension NxC (C = number of confounding variables).

Step 1: `./HCP_CBPP_step1_parcellate.sh -d /path/to/input/dir -p minimal`

Step 2: `./HCP_CBPP_step2_fc.sh -d $(pwd)/results/parcellation -p minimal`

Step 3: `./HCP_CBPP_step3_combine.sh -d $(pwd)/results/FC -p minimal`

Step 4: 

- whole-brain CBPP: `./HCP_CBPP_step4_wbCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file -p minimal`

- parcel-wise CBPP: `./HCP_CBPP_step4_pwCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file -p minimal`

# Example 2: SVR-FIX+GSR-Pearson-300-parcel

Use the following commands (while in this folder) in sequence for running the SVR-FIX+GSR-Pearson combination of strategies at 300-parcel granularity. 

The input directory (`/path/to/input/dir`) should contain a sub-folder for each subject, which then contains a sub-folder for each run. The psychometric file (/path/to/psychometric/file) is assumed to be a .mat file containing a variable `y` of dimension NxY (N = number of subjects, Y = number of psychometric variables). Similarly, the confounds file (`/path/to/confounds/file`) is assumed to be a .mat file containing a variable `conf` of dimension NxC (C = number of confounding variables).

Step 0: `./HCP_CBPP_step0_GSR.sh -d /path/to/input/dir`

Step 1: `./HCP_CBPP_step1_parcellate.sh -d (pwd)/results/HCP_GSR -p gsr`

Step 2: `./HCP_CBPP_step2_fc.sh -d $(pwd)/results/parcellation -p gsr`

Step 3: `./HCP_CBPP_step3_combine.sh -d $(pwd)/results/FC -p gsr`

Step 4: 

- whole-brain CBPP: `./HCP_CBPP_step4_wbCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file -p gsr`

- parcel-wise CBPP: `./HCP_CBPP_step4_pwCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file -p gsr`
