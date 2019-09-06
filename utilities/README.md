# CBPP Utility funcntions

- `EN_one_fold.m`, `MLR_one_fold.m` and `SVR_one_fold.m`: runs Elastic nets (EN), multiple linear regression (MLR) or Support Vector Regression (SVR) using one cross-validation fold. 

- `regress_confounds_y.m`: regresses out the confounding variables from prediction targets (y) by estimating linear regression coefficients between them. If the coefficients are given, then no estiamtion is done; the regression is simply performed using the given coefficients.

- `select_feature_corr.m`: performs feature selection based on Pearson correlation between features (x) and target variables (y).
