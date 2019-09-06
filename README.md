# Connectivity-based Psychometric Prediction (CBPP)

## Reference

Wu J, Eickhoff SB, Hoffstaedter F, Patil KR, Schwender H, Genon S. **A connectivity-based psychometric prediction framework for brain-behavior relationship studies**, *In prep*.

## Background

Fundamental to human brain mapping is the relationship between brain regions and functions (or behaviours). The recent availability population-based studies with extensive psychometric characterization opens promising perspective to investigate such relationships. The CBPP framework is an effort to summarize the general workflow of and systematically assess the common parameters in psychometric prediction studies.

Shown below is the workflow (left) and approaches investigated at each step in this project. We utilised the resting state fMRI data and 98 psychometric measures from over 900 Human Connectome Project (HCP) subjects, to evaluate a total of 72 combinations of approches. These are referred to as **whole-brain CBPP** approaches, as all region-to-region connectivity values are used as initial features.

<img src="bin/images/root_readme_img1.png" height="500" />

In a cognitive and clinical neuroscience framework, not only the the prediction performance, but also the neurobiological validity (or interpretability) of the model matters. However, post-hoc analysis on feature weights assigned to connectivity edegs during whole-brain CBPP is inherently problematic. Instead, we propose a parcel-wise prediction approach, referred to as **parcel-wise CBPP**, where models are trained on each parcel's connectivity profiles separately.

The applications of the parcel-wise CBPP approach is two-fold: 1) a **psychometric profile** can be established for a given parcel, showing its predictive power for different psychometric variables; 2) a predictive power map across parcels can be generated for a given psychometric variable. In this manner, we can directly examine the brain-behaviour associations from the parcel's perspective and the psychometric variable's perspective.

## Code Release

- The `utilities` folder contains the functions for running **whole-brain CBPP** and **parcel-wise CBPP**. Specifically, `CBPP_wholebbrain.m` and `CBIG_parcelwise.m` are generic functions to run any combination of approaches with existing data. See their respective help messages for the usage.

- The `HCP_surface_CBPP` folder contains the wrapper codes for running psychometric prediction, usingg HCP surface data (on 32k fsLR surface). Specifically, `HCP_surface_CBPP/wholebrain_CBPP` contains codes for **whole-brain CBPP**, while `HCP_surface_CBPP/parcelwise_CBPP` contains codes for **parcel-wise CBPP**. Refer to README in the respective folders for instructions on implementation.

## Bugs and Questions

Please contact Jianxiao Wu at jianxiao.wu.veronica@gmail.com.