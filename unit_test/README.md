This README includes the instruction on how to run the unit test for the Connectivity-based Psychometric Prediction (CBPP) project. Note that the unit test **runs on the INM7 server only**.

## Reference

Wu J, Eickhoff SB, Hoffstaedter F, Patil KR, Schwender H, Genon S. **A connectivity-based psychometric prediction framework for brain-behavior relationship studies**, *In prep*.

## Data

The unit test script uses the Human Connectome Project (HCP) data. The downloaded data are in the folder:


`/data/BnB3/BnB1/Raw_Data_nonBIDS/HCP`

where each subject folder is named by the subject ID. Within each subject folder, the resting-state fMRI data are in the sub-folders `MNINonLinear/Results/rfMRI_$run`, where `run` could be REST1_LR, REST1_RL, REST2_LR or REST2_RL. 

In total, 50 subjects's FIX+GSR processed data were used in the unit test, corresponding to the first 50 subjects in the subject list (`bin/sublist/HCP_surf_fix_allRun_sub.csv`).

In addition, the psychometric and confounding variables for these 50 subjects are taken from `/data/BnB2/Projects/jwu_HCP_Derivatives/unit_test_data`.

## Code

To run the unit test, call `unit_test.sh`, using the `-o` option to specify where the results should be put.

The whole-brain CBPP performance on test set will be compared to the default results in `/data/BnB2/Projects/jwu_HCP_Derivatives/unit_test_data/wbCBPP_SVR_standard_fix_parc300_Pearson_fixSeed.mat`. The parcel-wise CBPP performance on test set will be compared to the default resutls in `/data/BnB2/Projects/jwu_HCP_Derivatives/unit_test_data/pwCBPP_SVR_standard_fix_parc300_Pearson_fixSeed_parcel5.mat`. 

The unit test is successful if the screen prints `The two volumes are identical` twice (for whole-brain and parcel-wise results respectively).

This should take about `2h40m` to run.

If only prediction steps need to be tested, an existing combined FC file can be used while commenting out step 1-3. This light version of unit test
should take about `13m` to run.
