#! /usr/bin/env bash
# This script runs the unit test for this repository
# Jianxiao Wu, last edited on 03-Apr-2020

###########################################
# Define paths
###########################################

if [ "$(uname)" == "Linux" ]; then
  SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
elif [ "$(uname)" == "Darwin" ]; then
  SCRIPT_DIR=$(dirname "$0")
  SCRIPT_DIR=$(cd "$SCRIPT_DIR"; pwd)
fi
ROOT_DIR=$(dirname "$SCRIPT_DIR")

###########################################
# Main commands
###########################################
main(){

date

# set up parameters
n_sub=50
matlab_cmd="matlab95 -nodesktop -nosplash -nodisplay -nojvm -singleCompThread -r"

# create temporary subject list
sublist_surf=$output_dir/HCP_surf_gsr_allRun_sub.csv
sublist_mni=$output_dir/HCP_MNI_fix_wmcsf_allRun_sub.csv
head -$n_sub $ROOT_DIR/bin/sublist/HCP_surf_gsr_allRun_sub.csv > $sublist_surf
head -$n_sub $ROOT_DIR/bin/sublist/HCP_MNI_fix_wmcsf_allRun_sub.csv > $sublist_mni

if [ $type == "full" ]; then 
  # step 1: data processing
  $matlab_cmd "addpath('$ROOT_DIR/HCP_CBPP'); \
               options = struct('sub_list', '$sublist_surf', 'preproc', 'gsr'); \
               HCPsurf_data_proc('$input_dir', '$output_dir', options); \
               options = struct('sub_list', '$sublist_mni'); \
               HCPvol_data_proc('$input_dir', '$conf_dir', '$output_dir', options); \
               exit"
fi

# step 2: wbCBPP and pwCBPP
$matlab_cmd "addpath('$ROOT_DIR/HCP_CBPP'); \
             options = struct('sub_list', '$sublist_surf', 'preproc', 'gsr'); \
             HCP_cbpp('whole-brain', '$output_dir', '$output_dir', options); \
             options = struct('space', 'MNI', 'sub_list', '$sublist_mni', 'preproc', 'fix_wmcsf'); \
             HCP_cbpp('whole-brain', '$output_dir', '$output_dir', options); \
             options = struct('sub_list', '$sublist_surf', 'preproc', 'gsr', 'parcel', 5); \
             HCP_cbpp('region-wise', '$output_dir', '$output_dir', options); \
             options = struct('space', 'MNI', 'sub_list', '$sublist_mni', 'preproc', 'fix_wmcsf', 'parcel', 317); \
             HCP_cbpp('region-wise', '$output_dir', '$output_dir', options); \
             exit"

# compare results
gt_dir=$ROOT_DIR/unit_test/ground_truth
wb_surf=wbCBPP_SVR_standard_HCP_surf_gsr_300_Pearson.mat
wb_mni=wbCBPP_SVR_standard_HCP_MNI_fix_wmcsf_AICHA_Pearson.mat
pw_surf=pwCBPP_SVR_standard_HCP_surf_gsr_300_Pearson_parcel5.mat
pw_mni=pwCBPP_SVR_standard_HCP_MNI_fix_wmcsf_AICHA_Pearson_parcel317.mat
$matlab_cmd "addpath('$ROOT_DIR/unit_test'); \
             disp('Comparing surface-based whole-brain CBPP results:'); \
             unit_test_compare('$output_dir/$wb_surf', '$gt_dir/$wb_surf'); \
             disp('Comparing volume-based whole-brain CBPP results:'); \
             unit_test_compare('$output_dir/$wb_mni', '$gt_dir/$wb_mni'); \
             disp('Comparing surface-based region-wise CBPP results:'); \
             unit_test_compare('$output_dir/$pw_surf', '$gt_dir/$pw_surf'); \
             disp('Comparing volume-based region-wise CBPP results:'); \
             unit_test_compare('$output_dir/$pw_mni', '$gt_dir/$pw_mni'); \
             exit"

# clean up
rm $sublist_surf $sublist_mni

date

}

##################################################################
# Function usage
##################################################################

# Usage
usage() { echo "
Usage: $0 -i input_dir -c conf_list -o output_dir

This script parcellates and computes the connectivity of 50 HCP subjects using their surface (fsLR) and 50 subjects using their MNI data. The corresponding combined FC matrix was then used for whole-brain and parcel-wise CBPP.
The prediction results are compared to their corresponding ground truth files.

REQUIRED ARGUMENTS:
  -i <input_dir>    absolute path to fMRI input directory
  -c <conf_dir>     absolute path to imaging confounds directory
  -o <output_dir> 	absolute path to output directory

OPTIONAL ARGUMENTS:
  -t <type>         choose to run 'light' or 'full' unit test
                    [ default: 'full' ]
  -h			          display help message

OUTPUTS:
	$0 will create 2 files containing the combined FC matrix for surface and volumetric data respectively:
		HCP_gsr_parc300_Pearson.mat
    HCP_fix_wmcsf_AICHA_Pearson.mat

	$0 will create 4 files containing the prediction performance of whole-brain CBPP and parcel-wise CBPP for surface and volumetric data respectively:
		wbCBPP_SVR_standard_HCP_surf_gsr_300_Pearson.mat
		pwCBPP_SVR_standard_HCP_surf_gsr_300_Pearson_parcel5.mat
    wbCBPP_SVR_standard_HCP_vol_fix_wmcsf_AICHA_Pearson.mat
    pwCBPP_SVR_standard_HCP_vol_fix_wmcsf_AICHA_Pearson_parcel317.mat

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
while getopts "i:c:o:t:h" opt; do
  case $opt in
    i) input_dir=${OPTARG} ;;
    c) conf_dir=${OPTARG} ;;
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
if [ -z $conf_dir ]; then
  echo "Confounds directory not defined."; 1>&2; exit 1
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

