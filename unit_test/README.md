This README includes the instruction on how to run the unit test for the Connectivity-based Psychometric Prediction (CBPP) project.

## Reference

Wu J, Eickhoff SB, Hoffstaedter F, Patil KR, Schwender H, Genon S. **A connectivity-based psychometric prediction framework for brain-behavior relationship studies**, *In prep*.

## Data

The unit test script uses the resting-state fMRI and psychometric data from the Human Connectome Project (HCP). The first 50 subjects according to the FIX data subject list (`bin/sublist/HCP_surf_fix_allRun_sub.csv`) is used.

The resting-state data should be stored with HCP's original folder structure, under `$fmri_dir` where each subject folder is named by the subject ID. 

For the psychometric and confounding variables, they should be extracted and saved in a `.mat` file each, under `$deriv_dir`. Save the psychometric data (50 subject x 100 features matrix) as variable `y` in `$deriv_dir/unit_test_y.mat`. Save the confounding variables (50 subject x 9 variables matrix) as variable `conf` in `$deriv_dir/unit_test_conf.mat`.

Lastly, all subjects' IDs and corresponding family IDs should be saved in a `.mat` file as variables `all_subID` and `all_famID` (both as string arrays). Save the file as `$deriv_dir/HCP_famID.mat`.

## Code

To run the unit test, call `unit_test.sh` with the following command:

```
bash unit_test.sh -i $fmri_dir -d $deriv_dir -o $output_dir
```

The whole-brain CBPP performance on test set will be compared to the default results in `wbCBPP_SVR_standard_fix_parc300_Pearson_fixSeed.mat`. The parcel-wise CBPP performance on test set will be compared to the default resutls in `pwCBPP_SVR_standard_fix_parc300_Pearson_fixSeed_parcel5.mat`. 

The unit test is successful if the screen prints `The two volumes are identical` twice (for whole-brain and parcel-wise results respectively).

This should take about `4h28m` to run.

If only prediction steps need to be tested, add an existing combined FC file named `$out_dir/FC_combined/HCP_gsr_parc300_Pearson.mat` and add `-t 'light'` to the command. This light version of unit test should take about `17m` to run.
