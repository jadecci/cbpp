## Reference

Wu J, Eickhoff SB, Hoffstaedter F, Patil KR, Schwender H, Yeo BTT, Genon S. 2021. **A connectivity-based psychometric prediction framework for brain-behavior relationship studies**. Cerebral Cortex. 31(8): 3732-3751. [https://doi.org/10.1093/cercor/bhab044](https://doi.org/10.1093/cercor/bhab044).

## Data Processing

The surface and volumetric imaging data were processed with similar steps but with different options. The already processed data were downloaded from HCP, processed with optional nuisance regression or global signal regression, and then parcellated by a group atlas. Finally, the functional connectivity (FC) matrix was computed for each subject and saved in one combined .mat file.

The input directory `in_dir` should contain the resting-state fMRI data stored with HCP's original folder structure. The confounds directory `conf_dir` is required for `fix_wmcsf` and `fix_gsr` preprocessing of volumetric data, and should contain the motion, WM and CSF confounds with the same folder structure as `in_dir`.

1. For processing the surface imaging data, use the `HCPsurf_data_proc.m` script. These options are available for each step of data processing:

   - **preprocessing**: `minimal` (only minimal processing pipeline), `fix` ('minimal' + FIX denoising), `gsr` ('FIX' + global signal regression)

   - **parcellation granularity (Schaefer atlas)**: `100`, `200`, `300`, `400`

   - **FC**: `Pearson` (Pearson correlation), `partial_l2` (partial correlation with L2 regularisation)

    For example, to compute the Pearson FC matrices for all subjects with gloabl signal regression and the 200-parcel Schaefer atlas, run in Matlab:

    ```matlab
    options = struct('preproc', 'gsr', 'atlas', 200, 'fc_method', 'Pearson');
    HCPsurf_data_proc(in_dir, out_dir, options);
    ```

2. For processing the volumetric data, use the `HCPvol_data_proc.m` script. These options are available for each step of data processing:

   - **preprocessing**: `fix` (minimal processing pipeline + FIX denoising), `fix_wmcsf` ('FIX' + nuisance regression of 24 motion parameters, WM, CSF and derivatives), `fix_gsr` ('FIX' + nuisance rgression of 24 motion parameters, global signal and derivative)

   - **parcellation**: `AICHA` (384 cortical & subcortical parcels)

   - **functional connectivity**: `Pearson` (Pearson correlation), `partial_l2` (partial correlation with L2 regularisation)

    For example, to compute the Pearson FC matrices for all subjects with nuisance regression, run in Matlab:

    ```matlab
    options = struct('preproc', 'fix_wmcsf', 'fc_method', 'Pearson');
    HCPvol_data_proc(in_dir, out_dir, options);
    ```

**Note** that this step can be computationally intensive and should be split into multiple jobs/processes in actual implementation

## Whole-brain & Region-wise CBPP

Connectivity-based psychometric prediction (CBPP) can be run with 4 different regression algorithms (`SVR`: support vector regression, `RR`: ridge regression, `EN`: elastic nets, `MLR`: multiple linear regression), with 100 repeats of 10-fold cross-validation, using the `HCP_cbpp.m` script.

The input directory can be the output directory from data processing. Besides the combined FC matrix from data processing, the input directory should also contain the following files:

- `HCP_famID.mat`: contains two string array variables `all_famID` and `all_subID`, listing the family IDs and subject IDs of all subjects

- `HCP_y.csv`: contains NxY values (N = number of subjects, Y = number of psychometric variables) 
  
- `HCP_conf.csv`: contains NxC values (C = number of phenotype confounding variables), not to be confused with the imaging confounds

The psychometric confounds data can be automatically extracted using scripts from `bin/extraction_scripts`. See `README` in the folder for more details.

For example, to run whole-brain CBPP for surface FIX denoised data, parcellated with the 400-parcel Schaefer atlas, using their Pearson connectivity matrices and elastic nets:

```matlab
options = struct('space', 'surf', 'preproc', 'fix', 'atlas', 400, 'fc_method', 'Pearson', 'reg_method', 'EN');
HCP_cbpp('whole-brain', in_dir, out_dir, options);
```

For an alternative example, to run region-wise CBPP using volumetric FIX denoised data with nuisance regression, using their Pearson connectivity matrices and support vector regression:

```matlab
options = struct('space', 'MNI', 'preproc', 'fix', 'fc_method', 'Pearson', 'reg_method', 'SVR');
HCP_cbpp('region-wise', in_dir, out_dir, options);
```