This README includes the instruction on how to run the unit test for the Connectivity-based Psychometric Prediction (CBPP) project.

## Reference

Wu J, Eickhoff SB, Hoffstaedter F, Patil KR, Schwender H, Genon S. **A connectivity-based psychometric prediction framework for brain-behavior relationship studies**, *In prep*.

## Data

The unit test script uses the Human Connectome Project (HCP) data. On the **INM7 server**, the downloaded data are in the folder:


`/data/BnB3/BnB1/Raw_Data_nonBIDS/HCP`

where each subject folder is named by the subject ID. Within each subject folder, the resting-state fMRI data are in the sub-folders `MNINonLinear/Results/rfMRI_$run`, where `run` could be REST1_LR, REST1_RL, REST2_LR or REST2_RL. 

In total, 50 subjects's FIX+GSR processed data were used in the unit test, corresponding to the first 50 subjects in the subject list (`bin/sublist/HCP_surf_fix_allRun_sub.csv`).

In addition, the psychometric and confounding variables for these 50 subjects are taken from `/data/BnB2/Projects/jwu_HCP_Derivatives/unit_test_data`.

## Code

To run the unit test, call `unit_test.sh` with the following command:

```
./unit_test.sh -i /data/BnB3/BnB1/Raw_Data_nonBIDS/HCP -d /data/BnB2/Projects/jwu_HCP_Derivatives/unit_test_data -o $output_dir
```

The whole-brain CBPP performance on test set will be compared to the default results in `wbCBPP_SVR_standard_fix_parc300_Pearson_fixSeed.mat`. The parcel-wise CBPP performance on test set will be compared to the default resutls in `pwCBPP_SVR_standard_fix_parc300_Pearson_fixSeed_parcel5.mat`. 

The unit test is successful if the screen prints `The two volumes are identical` twice (for whole-brain and parcel-wise results respectively).

This should take about `4h28m` to run.

If only prediction steps need to be tested, put an existing combined FC file in `$out_dir/FC_combined/HCP_gsr_parc300_Pearson.mat` and add `-t 'light'` to the command. This light version of unit test should take about `17m` to run.

## Running Unit Test Outside INM7

As the unit test uses HCP data, it is currently only tested on the **INM7 server**. In order to run the unit test outside INM7, the data need to be prepared in the same structure.

For resting-state fMRI data, follow the description in the `Data` section, saving the data in `$fmri_dir`. Use the subject IDs of the first 50 subjects in `bin/sublist/HCP_surf_fix_allRun_sub.csv`. Save the psychometric data (N subject x P features matrix) as variable `y` in `$deriv_dir/unit_test_y.mat`. Save the confounding variables (N subject x C variables matrix) as variable `conf` in `$deriv_dir/unit_test_conf.mat`.

Then call the unit test script with the following command:

```
./unit_test.sh -i $fmri_dir -d $deriv_dir -o $output_dir
```