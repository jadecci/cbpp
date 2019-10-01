# CBPP Implementatin using HCP Data

The procedure of the CBPP implementation using HCP data is as shown below:

<img src="../bin/images/HCPsurf_readme_img1.png" height="900" />


# Example Commands

Use the following commands (while in this folder) in sequence for running the SVR-FIX+GSR-Pearson combination of strategies at 300-parcel granularity. 

The input directory (`/path/to/input/dir`) should contain a sub-folder for each subject, which then contains a sub-folder for each run. The psychometric file (/path/to/psychometric/file) is assumed to be a .mat file containing a variable `y` of dimension NxY (N = number of subjects, Y = number of psychometric variables). Similarly, the confounds file (`/path/to/confounds/file`) is assumed to be a .mat file containing a variable `conf` of dimension NxC (C = number of confounding variables).

Step 0: `./HCP_CBPP_step0_GSR.sh -d /path/to/input/dir`

Step 1: `./HCP_CBPP_step1_parcellate.sh -d (pwd)/results/HCP_GSR`

Step 2: `./HCP_CBPP_step2_fc.sh -d $(pwd)/results/parcellation`

Step 3: `./HCP_CBPP_step3_combine.sh -d $(pwd)/results/FC`

Step 4: 

- whole-brain CBPP: `./HCP_CBPP_step4_wbCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file`

- parcel-wise CBPP: `./HCP_CBPP_step4_pwCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file`