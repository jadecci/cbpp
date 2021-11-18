#! /usr/bin/env bash
# Jianxiao Wu, last edited on 17-Nov-2021

###########################################
# Define paths
###########################################

if [ "$(uname)" == "Linux" ]; then
  SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
elif [ "$(uname)" == "Darwin" ]; then
  SCRIPT_DIR=$(dirname "$0")
  SCRIPT_DIR=$(cd "$SCRIPT_DIR"; pwd)
fi
BIN_DIR=$(dirname "$SCRIPT_DIR")/bin

###########################################
# Main commands
###########################################
main(){

# get all subject names
if [ -z $sub_id ]; then sub_names=`cat $sub_list`; else sub_names=$sub_id; fi

# loop through each subject
for sub_id_curr in $sub_names; do

  # loop through each run
  for run in REST1_LR REST1_RL REST2_LR REST2_RL
  do
    output=$out_dir/HCP_fix_${reg_type}_sub${sub_id_curr}_${run}.nii.gz
    if [ ! -e $output ]; then
      echo "Running sub$sub_id_curr $run"
      
      # Generate global signal regressors
      input=$input_dir/$sub_id_curr/MNINonLinear/Results/rfMRI_$run/rfMRI_${run}_hp2000_clean.nii.gz
      regressors=$conf_dir/Confounds_${sub_id_curr}_${run}.mat
      matlab -nodesktop -nosplash -r "addpath('$BIN_DIR/external_packages'); \
                                      input = MRIread('$input'); \
                                      dim = size(input.vol); \
                                      vol = reshape(input.vol, prod(dim(1:3)), dim(4)); \
                                      load('$regressors'); \
                                      if strcmp('$reg_type', 'wmcsf'); signals = gx2([2:3],:); \
                                      elseif strcmp('$reg_type', 'gsr'); signals = gx2(4,:); end; \
                                      deriv = [zeros(1, size(signals,1)); diff(signals')]; \
                                      regressors = [reg(:, 9:32) signals' deriv]; \
                                      [resid, ~, ~, ~] = CBIG_glm_regress_matrix(vol', regressors, 1, []); \
                                      input.vol = reshape(resid', dim); \
                                      MRIwrite(input, '$output'); \
                                      exit"
    else
      echo "sub$sub_id_curr $run output already exists"
    fi
  done
done
}

###########################################
# Function usage
###########################################

usage() { echo "
Usage: $0 -d dataset -a atlas -o output_dir

This script processes the resting-state data with nuisance regression, followed by parcellation and functional 
connectivity (FC) computation.

-d dataset      short-form name of the dataset/cohort. Choose from 'HCP-YA', 'eNKI-RS', 'GSP', and 'HCP-A'
-a atlas        short-form name of the atlas to use for parcellation. Choose from 'AICHA', 'SchMel1', 'SchMel2', 
                'SchMel3' and 'SchMel4'
-o output_dir   absolute path to output directory
-h              display help message

OUTPUTS:
  $0 will create 1 output file in the output directory containing the combined FC matrix across all subjects
  For example: fc_HCP-YA_AICHA.mat

EXAMPLE:
  $0 -d ~/data -r 'gsr' -i 100206

" 1>&2; exit 1; }

#Display help message if no argument is supplied
if [ $# -eq 0 ]; then
  usage; 1>&2; exit 1
fi

###########################################
# Parse arguments
###########################################

# Default parameters
out_dir=$(pwd)/results/HCP_GSR
sub_list=$BIN_DIR/sublist/HCP_surf_fix_allRun_sub.csv

# Assign arguments
while getopts "d:c:r:s:i:o:h" opt; do
  case $opt in
    d) input_dir=${OPTARG} ;;
    c) conf_dir=${OPTARG} ;;
    r) reg_type=${OPTARG} ;;
    s) sub_list=${OPTARG} ;;
    i) sub_id=${OPTARG} ;;
    o) out_dir=${OPTARG} ;;
    h) usage; exit ;;
    *) usage; 1>&2; exit 1 ;;
  esac
done

###########################################
# Check parameters
###########################################

if [ -z $input_dir ]; then
  echo "Input directory not defined."; 1>&2; exit 1;
fi

if [ -z $conf_dir ]; then
  echo "Confounds directory not defined."; 1>&2; exit 1;
fi

if [ -z $reg_type ]; then
  echo "Regression type not defined."; 1>&2; exit 1;
elif [ $reg_type != 'wmcsf' -a $reg_type != 'gsr' ]; then
  echo "Regression type not recognised."; 1>&2; exit 1;
fi

###########################################
# Other set-ups
###########################################

# Make sure output directory is set up
if [ ! -d $out_dir ]; then
  echo "Output directory does not exist. Creating now..."
  mkdir -p $out_dir
fi

###########################################
#Implementation
###########################################

main