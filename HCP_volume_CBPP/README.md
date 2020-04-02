This folder contains codes to implement similar combinations of approaches used in `HCP_surface_CBPP` to volumetric HCP data. See the `Additional Information` section for the approaches available for volumetric data.

For `FIX` data, follow Example 1; for `FIX+WM/CSF` or `FIX+GSR` data, follow Example 2. At each step, if any parameter needs to be switched, you can check the respective script's usage by running it with no argument (e.g. run `./HCPvol_CBPP_step1_parcellate.sh` on command line).


# Example 1: SVR-FIX-Pearson-AICHA

Use the following commands (while in this folder) in sequence for running the SVR-minimal-Pearson combination of strategies using the AICHA atlas. 

The input directory (`/path/to/input/dir`) should contain a sub-folder for each subject, which then contains a sub-folder for each run. The psychometric file (/path/to/psychometric/file) is assumed to be a .mat file containing a variable `y` of dimension NxY (N = number of subjects, Y = number of psychometric variables). Similarly, the confounds file (`/path/to/confounds/file`) is assumed to be a .mat file containing a variable `conf` of dimension NxC (C = number of confounding variables).

Step 1: `./HCPvol_CBPP_step1_parcellate.sh -d /path/to/input/dir -p minimal`

Step 2: `./HCPvol_CBPP_step2_fc.sh -d $(pwd)/results/parcellation -p minimal`

Step 3: `./HCPvol_CBPP_step3_combine.sh -d $(pwd)/results/FC -p minimal`

Step 4: 

- whole-brain CBPP: `./HCPvol_CBPP_step4_wbCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file -p minimal`

- parcel-wise CBPP: `./HCPvol_CBPP_step4_pwCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file -p minimal`

# Example 2: SVR-FIX+WM/CSF-Pearson-AICHA

Use the following commands (while in this folder) in sequence for running the SVR-FIX+WM/CSF-Pearson combination of strategies using the AICHA atlas. 

The input directory (`/path/to/input/dir`) should contain a sub-folder for each subject, which then contains a sub-folder for each run. The psychometric file (/path/to/psychometric/file) is assumed to be a .mat file containing a variable `y` of dimension NxY (N = number of subjects, Y = number of psychometric variables). Similarly, the confounds file (`/path/to/confounds/file`) is assumed to be a .mat file containing a variable `conf` of dimension NxC (C = number of confounding variables).

Step 0: `./HCPvol_CBPP_step0_regress.sh -d /path/to/input/dir`

Step 1: `./HCPvol_CBPP_step1_parcellate.sh -d (pwd)/results/HCP_GSR -p gsr`

Step 2: `./HCPvol_CBPP_step2_fc.sh -d $(pwd)/results/parcellation -p gsr`

Step 3: `./HCPvol_CBPP_step3_combine.sh -d $(pwd)/results/FC -p gsr`

Step 4: 

- whole-brain CBPP: `./HCPvol_CBPP_step4_wbCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file -p gsr`

- parcel-wise CBPP: `./HCPvol_CBPP_step4_pwCBPP.sh -d $(pwd)/results/FC_combined -y /path/to/psychometric/file -v /path/to/confounds/file -p gsr`

# Additional Information

These approaches are availabble for volumetric data at each step of CBPP:

- **preprocessing**: `FIX` (only FIX denoising), `FIX+WM/CSF` (FIX denoising + nuisance regression of 24 motion parameters, WM, CSF and derivatives), `FIX+GSR` (FIX denoising + nuisance rgression of 24 motion parameters, global signal and derivative)

- **parcellation**: `AICHA` (384 cortical & subcortical parcels), `Schaefer+AICHA` (300 cortical parcels from Schaefer atlas + 84 subcortical parcels from AICHA atlas)

- **functional connectivity**: `Pearson` (Pearson correlation), `partial_l2` (partial correlation with L2 regularisation)

- **regression/prediction**: `SVR` (Support Vector Regression), `EN` (Elastic nets), `KRRcorr` (Kernel Ridge Regression with correlation kernel)

