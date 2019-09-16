#! /usr/bin/env bash
# This script runs the unit test for this repository
# Jianxiao Wu, last edited on 12-Sept-2019

###########################################
# Define paths
###########################################

ROOT_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")
deriv_dir=/data/BnB2/Projects/jwu_HCP_Derivatives/unit_test_data
input_dir=/data/BnB3/BnB1/Raw_Data_nonBIDS/HCP

###########################################
# Main commands
###########################################
main(){

# set up parameters
n_sub=50
parc_ind=5 # left V1 parcel

# step 1
cmd="for sub_ind in {1..$n_sub}; do $ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step1_parcellate.sh -d $input_dir \
-o $output_dir/parcellation -i $sub_ind; done"
echo $cmd
eval $cmd

# step 2
cmd="for sub_ind in {1..$n_sub}; do $ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step2_fc.sh -d $output_dir/parcellation \
-o $output_dir/FC -i $sub_ind; done"
echo $cmd
eval $cmd

# step 3
cmd="$ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step3_combine.sh -d $output_dir/FC -o $output_dir/FC_combined -r 1"
echo $cmd
eval $cmd

# step 4 whole-brain
cmd="$ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step4_wbCBPP.sh -d $output_dir/FC_combined -o $output_dir/CBPP_perf \
-y $deriv_dir/unit_test_y.mat -v $deriv_dir/unit_test_conf.mat -s 1"
echo $cmd
eval $cmd

# step 4 parcel-wise
cmd="$ROOT_DIR/HCP_surface_CBPP/HCP_CBPP_step4_pwCBPP.sh -d $output_dir/FC_combined -o $output_dir/CBPP_perf \
-y $deriv_dir/unit_test_y.mat -v $deriv_dir/unit_test_conf.mat -i $parc_ind -s 1"
echo $cmd
eval $cmd

# compare results and done
echo "Comparing whole-brain CBPP results ..."
wb_output=$output_dir/wbCBPP_SVR_standard_fix_parc300_Pearson_fixSeed.mat
wb_compare=$deriv_dir/wbCBPP_SVR_standard_fix_parc300_Pearson_fixSeed.mat
matlab -nodesktop -nosplash -r "addpath('$ROOT_DIR/unit_test'); \
                                unit_test_compare('$wb_output', '$wb_compare'); \
                                exit"
echo "Comparing parcel-wise CBPP results ..."
pw_output=$output_dir/pwCBPP_SVR_standard_fix_parc300_Pearson_fixSeed_parcel5.mat
pw_compare=$deriv_dir/pwCBPP_SVR_standard_fix_parc300_Pearson_fixSeed_parcel5.mat
matlab -nodesktop -nosplash -r "addpath('$ROOT_DIR/unit_test'); \
                                unit_test_compare('$pw_output', '$pw_compare'); \
                                exit"

}

##################################################################
# Function usage
##################################################################

# Usage
usage() { echo "
Usage: $0 -o output_dir

This script parcellates and computes the connectivity of 50 HCP subjects and use the combined FC matrix for whole-brain and parcel-wise CBPP.
The prediction results should be compared to $deriv_dir/wbCBPP_SVR_standard_fix_parc300_Pearson_fixSeed.mat and $deriv_dir/pwCBPP_SVR_standard_fix_parc300_Pearson_fixSeed_parcel5.mat. 

Note that this unit test can only be run on the INM7 cluster.

REQUIRED ARGUMENTS:
	-o <output_dir> 	absolute path to output directory

OPTIONAL ARGUMENTS:
	-h			display help message

OUTPUTS:
	$0 will create 2 folders.

	1) FC_combined folder: 1 file will be generated containing the combined FC matrix of all subjects
	The file name will be: 
		HCP_fix_parc300_Pearson.mat

	2) CBPP_perf folder: 2 files will be generated, corresponding to the prediction performance of whole-brain CBPP and parcel-wise CBPP respectively
	The file names will be: 
		wbCBPP_SVR_standard_fix_parc300_Pearson_fixSeed.mat
		pwCBPP_SVR_standard_fix_parc300_Pearson_fixSeed_parcel5.mat

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
while getopts "o:h" opt; do
  case $opt in
    o) output_dir=${OPTARG} ;;
    h) usage; exit ;;
    *) usage; 1>&2; exit 1 ;;
  esac
done

##################################################################
# Check parameter
##################################################################

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

