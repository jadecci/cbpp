## HCP-YA data extraction

The script `extract_HCP_data.py` helps to extract psychometric and confounding variables from HCP Young Adults (S1200 release) based on a subject list, using the unrestricted and restricted data csv downloaded from HCP. The extracted data are stored in two .csv files named according to the space and preprocessing of the fMRI data.

For example, to extract the phenotype data corresponding to subjects with surface FIX denoised data:

```bash
python3 extract_HCP_data.py $unrestricted_csv $restricted_csv --space 'surf' --preproc 'fix'
```

For extracting the relevant data only for the 3 selected psychometric vairables for `generalisability_CBPP`:

```bash
echo 'NEOFAC_O,CogFluidComp_AgeAdj,PMAT24_A_CR' > temp_psylist.csv
python3 extract_HCP_data.py $unrestricted_csv $restricted_csv --space 'MNI' --preproc 'fix_wmcsf' \
        --psy_list temp_psylist.csv
```

## HCP-A data extraction

The script `extract_HCP-A_data.py` helps to extract psychometric and confounding variables from the HCP Aging (Release 2.0) based on a subject list. The input directory should contain the original phenotype `.txt` files downloaded from NDA. The extracted data are stored in `HCP-A_y.csv` and `HCP-A_conf.csv` respectively.

For example, to extract the data into current directory:

```bash
python3 extract_HCP-A_data.py $input_dir
```

## eNKI-RS data extraction

The script `extract_HCP-A_data.py` helps to extract psychometric and confounding variables from eNKI-RS based on a subject list. The input directory should contain the original phenotype `.csv` files downloaded from COINS. Note that the WASI-II intelligence and openness data need to be extracted separately, as they involve different numbers of subjects.

For extracting the WASI-II intelligence related data into current directory:

```bash
python3 extract_eNKI-RS_data.py $input_dir
```

For extracting the openness related data into current directory:

```bash
python3 extract_eNKI-RS_data.py $input_dir --psy openness
```

## GSP data extraction

The script `extract_GSP_data.py` helps to extract psychometric and confounding variables from GSP based on a subject list. The input file should be the extended phenotype file `GSP_extended_140630.csv` downloaded from LONI. The extracted data are stored in `GSP_y.csv` and `GSP_conf.csv` respectively.

For example, to extract the data into current directory:

```bash
python3 extract_GSP_data.py $input
```

## Data extraction for unit test 1

The HCP-YA phenotype data required for unit test 1 can be extracted using with `extract_HCP_data.py`. The `-u 1` flag will set the preprocessing option and range of subjects automatically, but not the space.

To obtain all 4 files needed for the unit test 1 in `$deriv_dir`, call the extraction script twice:

```bash
python3 extract_HCP_data.py $unrestricted_csv $restricted_csv --preproc 'gsr' --unit_test --out_dir $deriv_dir
python3 extract_HCP_data.py $unrestricted_csv $restricted_csv --space 'MNI' --preproc 'fix_wmcsf' --unit_test \
        --out_dir $deriv_dir
```

## Data extraction for unit test 2

To extract the HCP-YA phenotype data required for unit test 2 in `$deriv_dir`:

```bash
echo 'NEOFAC_O,\nPMAT24_A_CR,\nCogFluidComp_AgeAdj' > temp_psylist.csv
python3 extract_HCP_data.py $unrestricted_csv $restricted_csv --space 'MNI' --preproc 'fix_wmcsf' \
        --psy_list temp_psylist.csv --unit_test --out_dir $deriv_dir
```

To extract the HCP-A phenotype data required for unit test 2 in `$deriv_dir`:

```bash
python3 extract_HCP-A_data.py $input_dir --unit_test --out_dir $deriv_dir
```

To extract the eNKI-RS phenotype data required for unit test 2 in `$deriv_dir`:

```bash
python3 extract_eNKI-RS_data.py $input_dir --unit_test --out_dir $deriv_dir
```
To extract the GSP phenotype data required for unit test 2 in `$deriv_dir`:

```bash
python3 extract_GSP_data.py $input --unit_test --out_dir $deriv_dir
```