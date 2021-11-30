# Unit Test 1

## Reference

Wu J, Eickhoff SB, Hoffstaedter F, Patil KR, Schwender H, Yeo BTT, Genon S. 2021. **A connectivity-based psychometric prediction framework for brain-behavior relationship studies**. Cerebral Cortex. 31(8): 3732-3751. [https://doi.org/10.1093/cercor/bhab044](https://doi.org/10.1093/cercor/bhab044).

## Data

The unit test script uses the resting-state fMRI and psychometric data from the Human Connectome Project (HCP). The first 50 subjects according to the FIX+GSR data subject list (`bin/sublist/HCP_surf_gsr_cortex_allRun_sub.csv`) is used for surface implementation, while the first 50 subjects according to the FIX+WM/CSF data subject list (`bin/sublist/HCP_MNI_fix_wmcsf_allRun_sub.csv`) is used for volumetric implementation.

The resting-state data should be stored with HCP's original folder structure, under `$fmri_dir` where each subject folder is named by the subject ID. The imaging confounding data should be stored in `$conf_dir`, with the same folder structure as `$fmri_dir`.

For the psychometric and confounding variables, they should be extracted and saved in .csv files under `$deriv_dir`. For automatic extraction, see `README` in `bin/extraction_scripts`. Name the files as `HCP_y.csv` and `HCP_conf.csv`.

Lastly, all subjects' IDs and corresponding family IDs should be saved in a .mat file as variables `all_subID` and `all_famID` (both as string arrays). Save the file as `$deriv_dir/HCP_famID.mat`. 

## Code

To run the unit test, call `unit_test1.sh` with the following command:

```bash
bash unit_test1.sh -i $fmri_dir -c $conf_dir -d $deriv_dir -o $output_dir
``` 

The mean Pearson correlation and nRMSD measures across test sets will be comapred to the corresponding results in `ground_truth` fodler. The unit test is successful if the screen prints `The two volumes are identical` twice for all 4 results.

This should take about `23h40m` to run on 1 core.

If only prediction steps need to be tested, make sure you have the existing combined FC files named `$out_dir/FC_combined/HCP_surf_gsr_300_Pearson.mat` and `$out_dir/FC_combined/HCP_vol_fix_wmcsf_AICHA_Pearson.mat`. Then run the unit test script with the `-t 'light'` flag. This light version of unit test should take about `12m` to run.

# Unit Test 2

## Reference 

Wu J, Eickhoff SB, Li J, Yeo BTT, Genon S. **Replication (or not) of connectivity-based psychometric prediction patterns in distinct population neuroscience cohorts**. *In prep.*

## Data

The unit test script uses the resting-state fMRI and psychometric data from the first 50 subjects from HCP-YA (FIX+WM/CSF), HCP-A, eNKI-RS and GSP.

The resting-state data for HCP-YA and HCP-A should be stored with HCP's original folder structure, under `$fmri_HCPYA_dir` and `$fmri_HCPA_dir`. The resting-state data for eNKI should be the fMRIprep output under `$fmri_eNKIRS_dir`. The resting-state data for GSP should be stored in `$fmri_GSP_dir` where each subject's file is named `sub-xxxx/ses-01/wsub-xxxx_ses-01.nii.g`.

The imaging confounding data should be stored in `$conf_HCPYA_dir`, `$conf_HCPA_dir`, `$conf_eNKIRS_dir` and `$conf_GSP_dir`.

The psychometric and confounding variables should be extracted and saved in .csv files under `$deriv_dir`. For automatic extraction, see `README.md` in `bin/extraction_scripts`. These files should be named:

- HCP-YA: `unit_test_MNI_y.csv` and `unit_test_MNI_conf.csv`. 
- HCP-A: `HCP-A_y.csv` and `HCP-A_conf.csv`
- eNKI-RS: `eNKI-RS_fluidcog_y.csv` and `eNKI-RS_fluidcog_conf.csv`
- GSP: `GSP_y.csv` and `GSP_conf.csv`

For HCP-YA, all subjects' IDs and corresponding family IDs should be saved in a .mat file as variables `all_subID` and `all_famID` (both as string arrays). Save the file as `$deriv_dir/HCP_famID.mat`.

# Code

To run this unit test, call `unit_test2.sh` after preparing all the data:

```bash
echo "${fmri_HCP-YA_dir}\n${fmri_HCP-YA_dir}\n${fmri_eNKI-RS_dir}\n${fmri_GSP_dir}" > temp_fmri_dir.csv
echo "${conf_HCP-YA_dir}\n${conf_HCP-YA_dir}\n${conf_eNKI-RS_dir}\n${conf_GSP_dir}" > temp_conf_dir.csv
bash unit_test2.sh -i temp_fmri_dir.csv -c temp_conf_dir.csv -d $deriv_dir -o $output_dir
```

This should take about `6h` to run on 1 cores.

If only prediction steps need to be tested, make sure you have the existing combined FC files named `$out_dir/HCP-YA_fix_wmcsf_SchMel1_Pearson.mat`, `$out_dir/HCP-A_fix_wmcsf_SchMel1_Pearson.mat`, `$out_dir/eNKI-RS_fix_wmcsf_SchMel3_Pearson.mat` and `$out_dir/GSP_fix_wmcsf_AICHA_Pearson.mat`. Then run the unit test script with the `-t light` flag. This light version of unit test should take about `35m` to run.

When testing with Matlab 2018b and 2021a, it seems that identical performance cannot be achieved with identical data anymore, at least with these existing subjects. Therefore, the unit test can be considered successful if the mean `r` and `nrmsd` differences are lower or around `0.1`.