## Reference 

Wu J, Eickhoff SB, Li J, Yeo BTT, Genon S. **Replication (or not) of connectivity-based psychometric prediction patterns in distinct population neuroscience cohorts**. *In prep.*

## Data Processing

The imaging data were first processed with nuisance regression (24 motion parameter, WM, CSF and derivatives), and then parcellated by a group atlas (AICHA, 4 versions of Schaefer+Melbourne at different granularity). The functional connectivity matrix was computed for each subject (and for each run for HCP-YA and HCP-Aging) and saved in one combined `.mat` file. These are done using the `generalise_data_proc.m` script.

For example, to process all HCP-YA subjects using the 350-parcel Schaefer-Melbourne atlas, run in Matlab:

```
generalise_data_proc('HCP-YA', 'SchMel3', in_dir, conf_dir, out_dir)
```

For more detailed usage of the script: `help generalise_data_proc`

**Note** that this step can be computationally intensive and should be split into multiple jobs/processes in actual implementation

## Whole-brain & Region-wise CBPP

Connectivity-based psychometric prediction (CBPP) was run using support vector regression (SVR) with 100 repeats of 10-fold cross-validation, using the `generalise_cbpp.sh` script.

The input directory can be the output directory from data processing. The psychometric file (`psy_file`) is assumed to be a .mat file containing a variable `y` of dimension NxY (N = number of subjects, Y = number of psychometric variables). Similarly, the confounds file (`conf_file`) is assumed to be a .mat file containing a variable `conf` of dimension NxC (C = number of confounding variables). Also, a family ID file (`HCP-YA_famID.mat`) should be put in the input directory for HCP-YA predictions, which is a .mat file containing two string array variables `all_famID` and `all_subID` listng the family IDs and subject IDs of all subjects.

For example, to run region-wise CBPP for openness prediction for all parcels in the AICHA altas for eNKI-RS data, saving the performance results in the current directory:

```
generalise_cbpp(model, measure, dataset, atlas, in_dir, psy_file, conf_file, out_dir, saveWeights)
```

To run whole-brain CBPP and save the regression weights on the same data, but for fluid cognition:

```
generalise_cbpp(model, measure, dataset, atlas, in_dir, psy_file, conf_file, out_dir, saveWeights)
```

For more detailed usage of the script: `bash generalise_cbpp.sh -h`

## Cross-dataset Generalisability

For assessing cross-dataset generalisability, we trained region-wise CBPP models for fluid cognition prediction on one dataset and tested them on another. This was done using the `generalise_cross_dataset.sh` script.

For example, to train region-wise CBPP models on HCP-Aging and test them on HCP-YA for all parcels in the 454-parcel Schaefer-Melbourne atlas, saving the results in the current directory:

```
bash generalise_cross_dataset.sh -x HCP-A -y HCP-YA -a SchMel4 -i $input_dir -o $(pwd)
```
