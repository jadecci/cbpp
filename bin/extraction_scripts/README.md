## HCP-YA data extraction

The script `extract_HCP_data.sh` helps to extract psychometric and confounding variables based on a subject list and header lists, from the HCP Yound Adult unrestricted and restricted data csv. The extracted data are stored in `.csv` files, which can also be converted to `.mat` files with the `-m` flag. 

For example, to extract the relevant data for all 40 selected psychometric variables for the first 100 subjects with `FIX+GSR` data in `MNI` space:

```bash
bash extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -s 'MNI' -p 'gsr' -b 100
```

For extracting the relevant data only for the 3 selected psychometric vairables for `generalisability_CBPP`:

```bash
echo 'NEOFAC_O,CogFluidComp_AgeAdj,PMAT24_A_CR' > temp_psylist.csv
bash extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -s 'MNI' -p 'fix_wmcsf' -l temp_psylist.csv
```

For more detailed help message, run `bash extract_HCP_data.sh -h` on command line. 

Note that the extraction could take a very long time if a large number of subjects is to be selected.

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

The HCP-YA phenotype data required for unit test 1 can be extracted using with `extract_HCP_data.sh`. This `-u 1` flag will set the preprocessing option and range of subjects automatically, but not the space.

To obtain all 4 `.mat` files needed for the unit test 1 in `$deriv_dir`, call the extraction script twice:

```bash
bash extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -u 1 -o $deriv_dir -m 1
bash extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -s 'MNI' -u 1 -o $deriv_dir -m 1
```

## Data extraction for unit test 2

To extract the HCP-YA phenotype data required for unit test 2 in `$deriv_dir`:

```bash
echo 'NEOFAC_O,PMAT24_A_CR,CogFluidComp_AgeAdj' > temp_psylist.csv
bash extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -s 'MNI' -l temp_psylist.csv -u 1 -o $deriv_dir
```

To extract the HCP-A phenotype data required for unit test 2 in `$deriv_dir`:

```bash
python3 extract_HCP-A_data.py $input_dir --unit_test --out_dir $deriv_dir
```

To extract the eNKI-RS phenotype data required for unit test 2 in `$deriv_dir`:

```bash
python3 extract_eNKI-RS_data.py $input_dir --unit_test --out_dir $deriv_dir
python3 extract_eNKI-RS_data.py $input_dir --psy openness --unit_test --out_dir $deriv_dir
```
To extract the GSP phenotype data required for unit test 2 in `$deriv_dir`:

```bash
python3 extract_GSP_data.py $input --unit_test --out_dir $deriv_dir
```