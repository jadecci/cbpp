#! /usr/bin/env bash
# This script runs the unit test 2 for this repository
# Jianxiao Wu, last edited on 22-Nov-2021

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

n_sub=50
matlab_cmd="matlab95 -nodesktop -nosplash -nodisplay -nojvm -singleCompThread -r"

# create temporary subject lists
sublist_HCPYA=$output_dir/HCP_MNI_fix_wmcsf_allRun_sub.csv
head -$n_sub $ROOT_DIR/bin/sublist/HCP_MNI_fix_wmcsf_allRun_sub.csv > $sublist_HCPYA
sublist_HCPA=$output_dir/HCP-A_allRun_sub.csv
head -$n_sub $ROOT_DIR/bin/sublist/HCP-A_allRun_sub.csv > $sublist_HCPA
sublist_eNKIRS=$output_dir/eNKI-RS_fluidcog_allRun_sub.csv
head -$n_sub $ROOT_DIR/bin/sublist/eNKI-RS_fluidcog_allRun_sub.csv > $sublist_eNKIRS
sublist_GSP=$output_dir/GSP_allRun_sub.csv
head -$n_sub $ROOT_DIR/bin/sublist/GSP_allRun_sub.csv > $sublist_GSP

if [ $type == "full" ]; then 
  # step 0: get all directory names
  fmri_HCPYA=`head -1 $fmri_list | tail -1`
  fmri_HCPA=`head -2 $fmri_list | tail -1`
  fmri_eNKIRS=`head -3 $fmri_list | tail -1`
  fmri_GSP=`head -4 $fmri_list | tail -1`
  conf_HCPYA=`head -1 $conf_list | tail -1`
  conf_HCPA=`head -2 $conf_list | tail -1`
  conf_eNKIRS=`head -3 $conf_list | tail -1`
  conf_GSP=`head -4 $conf_list | tail -1`

  # step 1
  func=generalise_data_proc
  $matlab_cmd "addpath('$ROOT_DIR/generalisability_CBPP'); \
               $func('HCP-YA', 'SchMel1', '$fmri_HCPYA', '$conf_HCPYA', '$deriv_dir/unit_test_MNI_y.csv', \
               '$deriv_dir/unit_test_MNI_conf.csv', '$output_dir', '$sublist_HCPYA'); \
               $func('HCP-A', 'SchMel1', '$fmri_HCPA', '$conf_HCPA', '$deriv_dir/HCP-A_y.csv', \
               '$deriv_dir/HCP-A_conf.csv', '$output_dir', '$sublist_HCPA'); \
               $func('eNKI-RS', 'SchMel3', '$fmri_eNKIRS', '$conf_eNKIRS', '$deriv_dir/eNKI-RS_fluidcog_y.csv', \
               '$deriv_dir/eNKI-RS_fluidcog_conf.csv', '$output_dir', '$sublist_eNKIRS'); \
               $func('GSP', 'AICHA', '$fmri_GSP', '$conf_GSP', '$deriv_dir/GSP_y.csv', \
               '$deriv_dir/GSP_conf.csv', '$output_dir', '$sublist_GSP'); \
               exit"
fi

# step 2: pwCBPP with eNKI-RS, wbCBPP with GSP
func=generalise_cbpp
$matlab_cmd "addpath('$ROOT_DIR/generalisability_CBPP'); \
             $func('region-wise', 'eNKI-RS', 'SchMel3', '$output_dir', '$output_dir', 0, '$sublist_eNKIRS'); \
             $func('whole-brain', 'GSP', 'AICHA', '$output_dir', '$output_dir', 0, '$sublist_GSP'); \
             exit"

# step 3: cross-dataset predictions with HCP-YA and HCP-A
func=generalise_cross_dataset
$matlab_cmd "addpath('$ROOT_DIR/generalisability_CBPP'); \
             $func('HCP-YA', 'HCP-A', 'SchMel1', '$output_dir', '$output_dir'); \
             exit"

# compare results
func=unit_test_compare
gt_dir=$ROOT_DIR/unit_test/ground_truth
pw_file=pwCBPP_SVR_eNKI-RS_SchMel3_parcel1.mat
wb_file=wbCBPP_SVR_GSP_AICHA.mat
cross_file=pwCBPP_SVR_HCP-YA_HCP-A_SchMel1.mat
$matlab_cmd "addpath('$ROOT_DIR/unit_test'); \
             fprintf('Comparing within-dataset region-wise CBPP performance:\n'); \
             $func('$output_dir/$pw_file', '$gt_dir/$pw_file'); \
             fprintf('Comparing within-dataset whole-brain CBPP performance:\n'); \
             $func('$output_dir/$wb_file', '$gt_dir/$wb_file'); \
             fprintf('Comparing cross-dataset region-wise CBPP performance:\n'); \
             $func('$output_dir/$cross_file', '$gt_dir/$cross_file'); \
             exit"

# clean up
rm $sublist_HCPYA $sublist_HCPA $sublist_eNKIRS $sublist_GSP

date

}

##################################################################
# Function usage
##################################################################

# Usage
usage() { echo "
Usage: $0 -i fmri_list -c conf_list -d deriv_dir -o output_dir

This script parcellates and computes the connectivity of 50 HCP-YA subjects, 50 HCP-A subjects, 50 eNKI-RS subjects, and 50 GSP subjects using their resting-state fMRI data in MNI152 space, and use the corresponding combined FC matrix for within-dataset using whole-brain CBPP and region-wise CBPP, as well as cross-dataset predictions using region-wise CBPP.
The prediction results for are compared to their corresponding ground truth files. If all results are identical, the unit test is successful.

REQUIRED ARGUMENTS:
  -i <fmri_list>    (.csv) list of absolute paths of fMRI directory of HCP-YA, HCP-A, eNKI-RS and GSP
  -c <conf_list>    (.csv) list of absolute paths of confounds directory of HCP-YA, HCP-A, eNKI-RS and GSP
  -d <deriv_dir>    absolute path to unit test psychometric, confounds and comparison data
  -o <output_dir> 	absolute path to output directory

OPTIONAL ARGUMENTS:
  -t <type>         choose to run 'light' or 'full' unit test
                    [ default: 'full' ]
  -h			    display help message

OUTPUTS:
	$0 will create 4 files containing the combined FC matrix of all subjects
	The file names will be: 
		fc_HCP-YA_SchMel1.mat
    fc_HCP-A_SchMel1.mat
    fc_eNKI-RS_SchMel3.mat
    fc_GSP_AICHA.mat

	$0 will then create 3 files corresponding to the prediction performance of within-dataset whole-brain CBPP, within-dataset region-wise CBPP and cross-dataset region-wise CBPP predictions respectively
	The file names will be: 
		pwCBPP_SVR_eNKI-RS_SchMel3_fluidcog.mat
		wbCBPP_SVR_GSP_AICHA_openness.mat
    pwCBPP_SVR_HCP-YA_HCP-A_SchMel1.mat

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
while getopts "i:c:d:o:t:h" opt; do
  case $opt in
    i) fmri_list=${OPTARG} ;;
    c) conf_list=${OPTARG} ;;
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

if [ -z $fmri_list ]; then
  echo "fMRI directory list not defined."; 1>&2; exit 1
fi
if [ -z $conf_list ]; then
  echo "Confounds directory list not defined."; 1>&2; exit 1
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

