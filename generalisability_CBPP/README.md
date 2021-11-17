## Reference 

Wu J, Eickhoff SB, Li J, Yeo BTT, Genon S. **Replication (or not) of connectivity-based psychometric prediction patterns in distinct population neuroscience cohorts**. *In prep.*

## Data Processing

The imaging data were first processed with nuisance regression (24 motion parameter, WM, CSF and derivatives), and then parcellated by a group atlas (AICHA, 4 versions of Schaefer+Melbourne at different granularity). The functional connectivity matrix was computed for each subject (and for each run for HCP-YA and HCP-Aging) and saved in one combined `.mat` file. These are done using the `generalise_data_proc.sh` script.

For example, to process all HCP-YA subjects using the 350-parcel Schaefer-Melbourne atlas, saving the results in the current directory:

```
bash generalise_data_proc.sh -d HCP-YA -a SchMel3 -o $(pwd)
```

For more detailed usage of the script: `bash generalise_data_proc.sh -h`

**Note** that this step can be computationally intensive and should preferably be split into multiple jobs/processes in actual implementation

## Whole-brain & Region-wise CBPP

Connectivity-based psychometric prediction (CBPP) was run using support vector regression (SVR) with 100 repeats of 10-fold cross-validation, using the `generalise_cbpp.sh` script.

For example, to run region-wise CBPP for openness prediction for all parcels in the AICHA altas for eNKI-RS data, saving the performance results in the current directory:

```
bash generalise_cbpp.sh -m region-wise -s openness -d eNKI-RS -a AICHA -o $(pwd)
```

To run whole-brain CBPP and save the regression weights on the same data, but for fluid cognition:

```
bash generalise_cbpp.sh -m whole-brain -s fluidcog -d eNKI-RS -a AICHA -o $(pwd) -w
```

For more detailed usage of the script: `bash generalise_cbpp.sh -h`

## Cross-dataset Generalisability

For assessing cross-dataset generalisability, we trained region-wise CBPP models for fluid cognition prediction on one dataset and tested them on another. This was done using the `generalise_cross_dataset.sh` script.

For example, to train region-wise CBPP models on HCP-Aging and test them on HCP-YA for all parcels in the 454-parcel Schaefer-Melbourne atlas, saving the results in the current directory:

```
bash generalise_cross_dataset.sh -x HCP-A -y HCP-YA -a SchMel4 -o $(pwd)
```
