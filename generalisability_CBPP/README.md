## Reference 

Wu J, Eickhoff SB, Li J, Yeo BTT, Genon S. **Replication (or not) of connectivity-based psychometric prediction patterns in distinct population neuroscience cohorts**. *In prep.*

## Data Processing

The imaging data were first processed with nuisance regression (24 motion parameter, WM, CSF and derivatives), and then parcellated by a group atlas (AICHA, 4 versions of Schaefer+Melbourne at different granularity). The functional connectivity matrix was computed for each subject (and for each run for HCP-YA and HCP-Aging) and saved in one combined `.mat` file, together with the psychometric variables and confounding variables. These are done using the `generalise_data_proc.m` script.

The psychometric file (`psy_file`) is assumed to be a .csv file containing NxY values (N = number of subjects, Y = number of psychometric variables). For HCP-YA dataset, the psychometric variables are openness, fluid cognition and fluid intelligence (in that order). For the other 3 datasets, the psychometric variables are openness and fluid cognition. 

Similarly, the prediction confounds file (`conf_file`) is assumed to be a .csv file containing NxC values (C = number of confounding variables). This is not to be confused with `conf_dir`, where files containing imaging confounds are placed.

For automatic extraction of psychometric and confounding variables, see `README.md` in the `bin/extraction_scripts` folder.

For example, to process all HCP-YA subjects using the 350-parcel Schaefer-Melbourne atlas, run in Matlab:

```matlab
generalise_data_proc('HCP-YA', 'SchMel3', in_dir, conf_dir, psy_file, conf_file, out_dir)
```

For more detailed usage of the script: `help generalise_data_proc`

**Note** that this step can be computationally intensive and should be split into multiple jobs/processes in actual implementation

## Whole-brain & Region-wise CBPP

Connectivity-based psychometric prediction (CBPP) was run using support vector regression (SVR) with 100 repeats of 10-fold cross-validation, using the `generalise_cbpp.sh` script.

The input directory can be the output directory from data processing. Also, a family ID file (`HCP-YA_famID.mat`) should be put in the input directory for HCP-YA predictions, which is a .mat file containing two string array variables `all_famID` and `all_subID` listng the family IDs and subject IDs of all subjects.

For example, to run region-wise CBPP for openness prediction for all parcels in the AICHA altas for eNKI-RS data, run in Matlab:

```matlab
generalise_cbpp('region-wise', 'eBKI-RS', 'AICHA', in_dir, out_dir)
```

To run whole-brain CBPP and save the regression weights on the same data:

```matlab
generalise_cbpp('whole-brain', 'eBKI-RS', 'AICHA', in_dir, out_dir, 1)
```

For more detailed usage of the script: `help generalise_cbpp`

## Cross-dataset Generalisability

For assessing cross-dataset generalisability, we trained region-wise CBPP models for fluid cognition prediction on one dataset and tested them on another. This was done using the `generalise_cross_dataset.m` script. Again, the input directory could be the output directory from data processing.

For example, to run cross-dataset predictions on HCP-Aging and HCP-YA data for all parcels in the 454-parcel Schaefer-Melbourne atlas, run in Matlab:

```matlab
generalise_cross_dataset('HCP-YA', 'HCP-A', 'SchMel4', in_dir, out_dir)
```
