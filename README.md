# Connectivity-based Psychometric Prediction (CBPP)

## Reference

Wu J, Eickhoff SB, Hoffstaedter F, Patil KR, Schwender H, Genon S. **A connectivity-based psychometric prediction framework for brain-behavior relationship studies**, *In prep*.

## Background

The CBPP framework is an effort to summarize the general workflow of and systematically assess the common parameters in connectivity-based psychometric prediction studies. Our work consists of 2 aspects:

1. **Whole-brain CBPP**: In the preliminary analysis, we utilised all region-to-region connectivity values for prediction to find the overall best combination of approaches.

2. **Parcel-wise CBPP**: In order to improve the neurobiological validity (or interpretability) of psychometric prediction models, We propose a parcel-wise prediction approach, where models are trained on each parcel's connectivity profiles separately. We further illustrate 2 applications for this aproach:

    - **single parcel's psychometric profile** (i.e. a parcel's predictive power variation across different psychometric variables)
    <img src="bin/images/root_readme_img1.png" height="300" />
    - **single psychometric variable's predictive power variation across parcels**
    <img src="bin/images/root_readme_img2.png" height="200" />

## Replication

Please see the README in the `HCP_surface_CBPP` folder for how to replicate the results in our paper.

## Code Release

We release two Matlab functions, `CBPP_wholebbrain.m` and `CBIG_parcelwise.m`, for implementing any combination of approaches investigated in our paper. 

**Note** that the connectivity and psychometric data should be prepared before using these functions. For computing preprocessing, connectivity, etc. as done in our paper, see the README in `HCP_surface_CBPP` folder.

To run whole-brain or parcel-wise CBPP, use the following commands in Matlab:

```
CBPP_wholebrain(fc, y, conf, cv_ind, out_dir, options)
```

```
CBPP_parcelwise(fc, y, conf, cv_ind, out_dir, options)
```

For more detailed usage for each function, use the following commands in Matlab:

```
help CBPP_wholebrain
```
```
help CBPP_parcelwise
```

## Additional Information

1. A flowchart explaining the general workflow in more details is in the `Additional Information` section of the README file in the `HCP_surface_CBPP` folder.

2. Flowcharts explaining the cross-validation procedures for each regression algorithm used is in the README file in the `bin/cv_procedure` folder.

3. Scripts used to compare different whole-brain CBPP approach and compute statistical significance for parcel-wise CBPP results can be found in the `bin/evaluation_scripts` folder. See the README in the folder for their usage.

## Bugs and Questions

Please contact Jianxiao Wu at jianxiao.wu.veronica@gmail.com.
