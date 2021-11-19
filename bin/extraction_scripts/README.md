## HCP-YA data extraction

The script `extract_HCP_data.sh` helps to extract psychometric and confounding variables based on a subject list and header lists, from the HCP Yound Adult unrestricted and restricted data csv. The extracted data are stored in `.csv` files, which can also be converted to `.mat` files with the `-m` flag. 

For example, to extract the relevant data for the first 100 subjects with `FIX+GSR` data in `MNI` space:

```bash
./extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -s 'MNI' -p 'gsr' -b 100
```

For extracting the relevant data for `generalisability_CBPP`:

```bash
echo 'NEOFAC_O,PMAT24_A_CR,CogFluidComp_AgeAdj' > temp_psylist.csv
./extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -s 'MNI' -p 'fix_wmcsf' -l temp_psylist.csv
```

For more detailed help message, run `./extract_HCP_data.sh` on command line. 

Note that the extraction could take a very long time if a large number of subjects is to be selected.

### Data extraction for unit test

Specially, this extraction script can set the preprocessing option and range of subjects automatically if `-u 1` is passed, although the space still needs to be specified.

To obtain all 4 `.mat` files needed for the unit test 1 in `$deriv_dir`, call the extraction script twice:

```bash
./extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -u 1 -o $deriv_dir -m 1
./extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -s 'MNI' -u 1 -o $deriv_dir -m 1
```