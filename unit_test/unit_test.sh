#! /usr/bin/env bash
# This script runs the unit test for this repository
# Jianxiao Wu, last edited on 18-Mar-2020

###########################################
# Define paths
###########################################

ROOT_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")

###########################################
# Main commands
###########################################
main(){

date

# set up parameters
n_sub=50
parc_ind_surf=5 # left V1 parcel
parc_ind_mni=317 # left anterior hippocampus parcel

# create temporary subject list
sublist_surf_orig=$ROOT_DIR/bin/sublist/HCP_surf_gsr_allRun_sub.csv
sublist_surf=$output_dir/HCP_surf_gsr_allRun_sub.csv
sublist_mni_orig=$ROOT_DIR/bin/sublist/HCP_MNI_fix_wmcsf_allRun_sub.csv
sublist_mni=$output_dir/HCP_MNI_fix_wmcsf_allRun_sub.csv
head -$n_sub $sublist_surf_orig > $sublist_surf
head -$n_sub $sublist_mni_orig > $sublist_mni

if [ $type == "full" ]; then 
  # step 0
  cmd="$ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step0_GSR.sh -d $input_dir -o $output_dir/HCP_GSR -s $sublist_surf"
  echo $cmd
  eval $cmd
  date
  cmd="$ROOT_DIR/HCP_volume_CBPP/HCPvol_CBPP_step0_regress.sh -d $input_dir -o $output_dir/HCP_regress -s $sublist_mni"
  echo $cmd
  eval $cmd
  date

  # step 1
  cmd="$ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step1_parcellate.sh -d $output_dir/HCP_GSR -p gsr \
  -o $output_dir/parcellation -s $sublist_surf"
  echo $cmd
  eval $cmd
  date
  cmd="$ROOT_DIR/HCP_volume_CBPP/HCPvol_CBPP_step1_parcellate.sh -d $output_dir/HCP_regress \
  -o $output_dir/parcellation -s $sublist_mni"
  echo $cmd
  eval $cmd
  date

  # step 2
  cmd="$ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step2_fc.sh -d $output_dir/parcellation -o $output_dir/FC \
  -p gsr -s $sublist_surf"
  echo $cmd
  eval $cmd
  date
  cmd="$ROOT_DIR/HCP_volume_CBPP/HCPvol_CBPP_step2_fc.sh -d $output_dir/parcellation -o $output_dir/FC -s $sublist_mni"
  echo $cmd
  eval $cmd
  date

  # step 3
  cmd="$ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step3_combine.sh -d $output_dir/FC -o $output_dir/FC_combined \
  -p gsr -s $sublist_surf -r 1"
  echo $cmd
  eval $cmd
  date
  cmd="$ROOT_DIR/HCP_volume_CBPP/HCPvol_CBPP_step3_combine.sh -d $output_dir/FC -o $output_dir/FC_combined \
  -s $sublist_mni -r 1"
  echo $cmd
  eval $cmd
  date
fi

# step 4 whole-brain
cmd="$ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step4_wbCBPP.sh -d $output_dir/FC_combined -o $output_dir/CBPP_perf \
-y $deriv_dir/unit_test_surf_y.mat -v $deriv_dir/unit_test_surf_conf.mat -m $deriv_dir/HCP_famID.mat -s 1 -p gsr \
-l $sublist_surf"
echo $cmd
eval $cmd
date
cmd="$ROOT_DIR/HCP_volume_CBPP/HCPvol_CBPP_step4_wbCBPP.sh -d $output_dir/FC_combined -o $output_dir/CBPP_perf \
-y $deriv_dir/unit_test_vol_y.mat -v $deriv_dir/unit_test_vol_conf.mat -m $deriv_dir/HCP_famID.mat -s 1 -l $sublist_mni"
echo $cmd
eval $cmd
date

# step 4 parcel-wise
cmd="$ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step4_pwCBPP.sh -d $output_dir/FC_combined -o $output_dir/CBPP_perf \
-y $deriv_dir/unit_test_surf_y.mat -v $deriv_dir/unit_test_surf_conf.mat -m $deriv_dir/HCP_famID.mat -i $parc_ind_surf \
-s 1 -p gsr -l $sublist_surf"
echo $cmd
eval $cmd
date
cmd="$ROOT_DIR/HCP_volume_CBPP/HCPvol_CBPP_step4_pwCBPP.sh -d $output_dir/FC_combined -o $output_dir/CBPP_perf \
-y $deriv_dir/unit_test_vy.mat -v $deriv_dir/unit_test_vol_conf.mat -m $deriv_dir/HCP_famID.mat -i $parc_ind_mni -s 1 \
-l $sublist_mni"
echo $cmd
eval $cmd
date

# compare results and done
echo "Comparing surface-based results ..."
wb_output=$output_dir/CBPP_perf/wbCBPP_SVR_standard_HCP_gsr_parc300_Pearson_fixSeed.mat
wb_compare=$ROOT_DIR/unit_test/ground_truth/wbCBPP_SVR_standard_HCP_gsr_parc300_Pearson_fixSeed.mat
pw_output=$output_dir/CBPP_perf/pwCBPP_SVR_standard_HCP_gsr_parc300_Pearson_fixSeed_parcel$parc_ind_surf.mat
pw_compare=$ROOT_DIR/unit_test/ground_truth/pwCBPP_SVR_standard_HCP_gsr_parc300_Pearson_fixSeed_parcel$parc_ind_surf.mat
matlab -nodesktop -nosplash -r "addpath('$ROOT_DIR/unit_test'); \
                                unit_test_compare('$wb_output', '$wb_compare'); \
                                unit_test_compare('$pw_output', '$pw_compare'); \
                                exit"
echo "Comparing volume-based results ..."
wb_output=$output_dir/CBPP_perf/wbCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson_fixSeed.mat
wb_compare=$ROOT_DIR/unit_test/ground_truth/wbCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson_fixSeed.mat
pw_output=$output_dir/CBPP_perf/pwCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson_fixSeed_parcel$parc_ind_mni.mat
pw_compare=$ROOT_DIR/unit_test/ground_truth/pwCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson_fixSeed_parcel$parc_ind_mni.mat
matlab -nodesktop -nosplash -r "addpath('$ROOT_DIR/unit_test'); \
                                unit_test_compare('$wb_output', '$wb_compare'); \
                                unit_test_compare('$pw_output', '$pw_compare'); \
                                exit"

# clean up
rm $sublist

date

}

##################################################################
# Function usage
##################################################################

# Usage
usage() { echo "
Usage: $0 -i input_dir -d deriv_dir -o output_dir

This script parcellates and computes the connectivity of 50 HCP subjects using their surface (fsLR) and MNI data, and use the corresponding combined FC matrix for whole-brain and parcel-wise CBPP.
The prediction results for surface data are compared to wbCBPP_SVR_standard_gsr_parc300_Pearson_fixSeed.mat and pwCBPP_SVR_standard_gsr_parc300_Pearson_fixSeed_parcel5.mat. For volumetric data, the results are compared to wbCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson_fixSeed.mat and pwCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson_fixSeed_parcel317.mat

REQUIRED ARGUMENTS:
  -i <input_dir>    absolute path to input directory
  -d <deriv_dir>    absolute path to unit test psychometric, confounds and comparison data
	-o <output_dir> 	absolute path to output directory

OPTIONAL ARGUMENTS:
  -t <type> choose to run 'light' or 'full' unit test
            [ default: 'full' ]
	-h			  display help message

OUTPUTS:
	$0 will create 2 folders.

	1) FC_combined folder: 2 files will be generated containing the combined FC matrix of all subjects
	The file names will be: 
		HCP_gsr_parc300_Pearson.mat
    HCP_fix_wmcsf_AICHA_Pearson.mat

	2) CBPP_perf folder: 4 files will be generated, corresponding to the prediction performance of whole-brain CBPP and parcel-wise CBPP for surface and volumetric data respectively
	The file names will be: 
		wbCBPP_SVR_standard_gsr_parc300_Pearson_fixSeed.mat
		pwCBPP_SVR_standard_gsr_parc300_Pearson_fixSeed_parcel5.mat
    wbCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson_fixSeed.mat
    pwCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson_fixSeed_parcel317.mat

EXAMPLE:
	$0 -o ~/unit_test_results
" 1>&2; exit 1; }

# Display help message if no argument is supplied
if [ $# -eq 0 ]; then
  usage; 1>&2; exit 1
fi

##################################################################
# Assign input variables
##################################################################

# Assign parameter
type='full'
while getopts "i:d:o:t:h" opt; do
  case $opt in
    i) input_dir=${OPTARG} ;;
    d) deriv_dir=${OPTARG} ;;
    o) output_dir=${OPTARG} ;;
    t) type=${OPTARG} ;;
    h) usage; exit ;;
    *) usage; 1>&2; exit 1 ;;
  esac
done

##################################################################
# Check parameter
##################################################################

if [ -z $input_dir ]; then
  echo "Input directory not defined."; 1>&2; exit 1
fi
if [ -z $deriv_dir ]; then
  echo "Unit test directory not defined."; 1>&2; exit 1
fi
if [ -z $output_dir ]; then
  echo "Output directory not defined."; 1>&2; exit 1
fi

##################################################################
# Set up output directory
##################################################################

if [ ! -d "$output_dir" ]; then
  echo "Output directory does not exist. Making directory now..."
  mkdir -p $output_dir
fi

###########################################
# Implementation
###########################################

main

