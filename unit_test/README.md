This README includes the instruction on how to run the unit test for the Connectivity-based Psychometric Prediction (CBPP) project.

## Reference

Wu J, Eickhoff SB, Hoffstaedter F, Patil KR, Schwender H, Genon S. **A connectivity-based psychometric prediction framework for brain-behavior relationship studies**, *In prep*.

## Data

The unit test script uses the resting-state fMRI and psychometric data from the Human Connectome Project (HCP). The first 50 subjects according to the FIX+GSR data subject list (`bin/sublist/HCP_surf_gsr_cortex_allRun_sub.csv`) is used for surface implementation, while the first 50 subjects according to the FIX+WM/CSF data subject list (`bin/sublist/HCP_MNI_fix_wmcsf_allRun_sub.csv`) is used for volumetric implementation.

The resting-state data should be stored with HCP's original folder structure, under `$fmri_dir` where each subject folder is named by the subject ID. 

For the psychometric and confounding variables, they should be extracted and saved in a `.mat` file each, under `$deriv_dir`. Save the psychometric data (50 subject x 100 features matrix) as variable `y` in `$deriv_dir/unit_test_surf_y.mat` and `$deriv_dir/unit_test_vol_y.mat` for the surface and volumetric data respectively. Similarly, save the confounding variables (50 subject x 9 variables matrix) as variable `conf` in `$deriv_dir/unit_test_surf_conf.mat` and `$deriv_dir/unit_test_vol_conf.mat` respectively.

Lastly, all subjects' IDs and corresponding family IDs should be saved in a `.mat` file as variables `all_subID` and `all_famID` (both as string arrays). Save the file as `$deriv_dir/HCP_famID.mat`.

## Code

To run the unit test, call `unit_test.sh` with the following command:

```
bash unit_test.sh -i $fmri_dir -d $deriv_dir -o $output_dir
```

For surface-based results, the whole-brain CBPP performance on test set will be compared to the default results in `ground_truth/wbCBPP_SVR_standard_HCP_gsr_parc300_Pearson_fixSeed.mat`, while he parcel-wise CBPP performance on test set will be compared to the default resutls in `ground_truth/pwCBPP_SVR_standard_HCP_gsr_parc300_Pearson_fixSeed_parcel5.mat`. 

For volume-based results, the whole-brain CBPP performance on test set will be compared to the default results in `ground_truth/wbCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson_fixSeed.mat`, while he parcel-wise CBPP performance on test set will be compared to the default resutls in `ground_truth/pwCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson_fixSeed_parcel317.mat`. 

The unit test is successful if the screen prints `The two volumes are identical` for all 4 results.

This should take about `4h28m` to run.

If only prediction steps need to be tested, add existing combined FC files named `$out_dir/FC_combined/HCP_gsr_parc300_Pearson.mat` and `$out_dir/FC_combined/HCP_fix_wmcsf_AICHA_Pearson.mat`, then add `-t 'light'` to the command. This light version of unit test should take about `17m` to run.
