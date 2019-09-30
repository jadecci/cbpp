# External packages/scripts

- `cifti-matlab`: Matlab codes for reading and writing Cifti files. See README in the folder for more information.

- `FSLNets`: FSLNets Matlab package from the FMRIB Analysis Group (http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLNets), which was used to compute partial correlation with L2 regularisation in this project.

- `glmnet_matlab`: GLMnet Matlab package, which was used to implement elastic net in this project.

- `CBIG_glm_regress_matrix.m`: performs general linear model (GLM) regression using provided regressors on an input matrix. This script is copied exactly from the Computational Brain Imaging Group (CBIG) repository (`https://github.com/ThomasYeoLab/CBIG/utilities/matlab/stats/`) under MIT license (`https://github.com/ThomasYeoLab/CBIG/LICENSE.md`).

- `fdr.m`: computes P value threshold for multiple comparison by controlling the false discovery rate (FDR)

- `levenetest.m`: performs Levene's test for checking whether two distributions have the same variance. The script was slightly modified to return the P value instead of printing out the results