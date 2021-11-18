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
matlab_cmd="matlab -nodesktop -nosplash -nodisplay -singleCompThread -nojvm -r"

###########################################
# Data processing functions
###########################################

hcp_proc() {

sublist=$BIN_DIR/sublist/HCP_MNI_fix_wmcsf_allRun_sub.csv
$matlab_cmd "
             sublist = csvread(fullfile('$BIN_DIR', ))
             input = $in_dir/ \
             regressors \
             exit"

for subject in $sublist; do 
  for run in REST1_LR REST1_RL REST2_LR REST2_RL; do
  done
done

}

hcpa_proc() {

sublist=`cat $BIN_DIR/sublist/HCP-A_allRun_sub.csv`
}

enki_proc() {
  
sublist=`cat $BIN_DIR/sublist/eNKI-RS_int_allRun_sub.csv`
}

gsp_proc() {

sublist=`cat $BIN_DIR/sublist/GSP_allRun_sub.csv`
}



main(){

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

}

###########################################
# Function usage
###########################################

usage() { echo "
Usage: $0 -d dataset -a atlas -i input_dir -c conf_dir -o output_dir

This script processes the resting-state data with nuisance regression, followed by parcellation and functional 
connectivity (FC) computation.

-d dataset      short-form name of the dataset/cohort. Choose from 'HCP-YA', 'eNKI-RS', 'GSP', and 'HCP-A'
-a atlas        short-form name of the atlas to use for parcellation. Choose from 'AICHA', 'SchMel1', 'SchMel2', 
                'SchMel3' and 'SchMel4'
-i input_dir    absolute path to input directory
-c conf_dir     absolute path to confounds directory
-o output_dir   absolute path to output directory
-h              display help message

OUTPUTS:
$0 will create 1 output file in the output directory containing the combined FC matrix across all subjects
For example: fc_HCP-YA_AICHA.mat

" 1>&2; exit 1; }

#Display help message if no argument is supplied
if [ $# -eq 0 ]; then
  usage; 1>&2; exit 1
fi

###########################################
# Parse arguments
###########################################
while getopts "d:a:i:c:o:h" opt; do
  case $opt in
    d) dataset=${OPTARG} ;;
    a) atlas=${OPTARG} ;;
    i) in_dir=${OPTARG} ;;
    c) conf_dir=${OPTARG} ;;
    o) out_dir=${OPTARG} ;;
    h) usage; exit ;;
    *) usage; 1>&2; exit 1 ;;
  esac
done

###########################################
# Check parameters
###########################################

if [ -z $dataset ]; then
  echo "Dataset not defined."; 1>&2; exit 1;
fi

if [ -z $atlas]; then
  echo "Atlas not defined."; 1>&2; exit 1;
fi

if [ -z $in_dir ]; then
  echo "Input directory not defined."; 1>&2; exit 1;
fi

if [ -z $conf_dir ]; then
  echo "Confounds directory not defined."; 1>&2; exit 1;
fi

if [ -z $out_dir ]; then
  echo "Output directory not defined."; 1>&2; exit 1;
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

case $dataset in
  HCP-YA)
    hcp_proc ;;
  HCP-A)
    hcpa_proc ;;
  eNKI-RS)
    enki_proc ;;
  GSP)
    gsp_proc ;;
  *)
    echo "Invalid dataset option."; 1>&2; exit 1 ;;
esac
