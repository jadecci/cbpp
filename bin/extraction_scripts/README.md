## HCP psychometric/confounds data extraction

This folder contains scripts to extract psychometric and confounding variables based on a subject list and header lists, from the HCP unrestricted and restricted data csv. The extracted data are stored in `.mat` files, ready to use for `CBPP_wholebrain.m`, `CBPP_parcelwise.m` and the unit test. 

For example, to extract the relevant data for the first 100 subjects with `FIX+GSR` data in `MNI` space:

```
./extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -s 'MNI' -p 'gsr' -b 100
```

For more detailed help message, run `./extract_HCP_data.sh` on command line. 

Note that the extraction could take a very long time if a large number of subjects is to be selected.

### Data extraction for unit test

Specially, the extraction script can set the preprocessing option and range of subjects automatically if `-u 1` is passed, although the space still needs to be specified.

To obtain all 4 `.mat` files needed for the unit test in `$deriv_dir`, call the extraction script twice:

```
./extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -u 1 -o $deriv_dir
./extract_HCP_data.sh -i $unrestricted_csv -j $restricted_csv -s 'MNI' -u 1 -o $deriv_dir
```