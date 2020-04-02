#! /usr/bin/env bash
# This script is a wrapper to apply nuisance regression to a HCP subjects. 
# Jianxiao Wu, last edited on 30-Mar-2020

###########################################
# Define paths
###########################################

BIN_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")/bin

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
      input=$input_dir/$sub_id_curr/MNINonLinear/Results/rfMRI_$run/rfMRI_${run}_hp2000_clean.nii
      regressors=$conf_dir/Confounds_${sub_id_curr}_${run}.mat
      matlab -nodesktop -nosplash -r "addpath('$BIN_DIR/external_packages'); \
                                      input = MRIread('$input'); \
                                      dim = size(input.vol); \
                                      vol = reshape(input.vol, prod(dim(1:3)), dim(4)); \
                                      load('$regressors'); \
                                      if strcmp('$reg_type', 'wmcsf'); signals = gx2[2:3],:); \
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
Usage: $0 -d <input_dir> -c <conf_dir> -r <reg_type> -n <n_parc> -p <preproc> -s <sub_list> -i <sub_id> -o <output_dir>

This script is a wrapper to run nuisance regression for HCP fMRI data in MNI space, following ICA-FIX. 

By default, all subjects in the specified sub_list are used. For better parallelisation, use the -i 
option to specify one subject to run at a time.

REQUIRED ARGUMENT:
  -d <input_dir>  absolute path to input directory. The directory is assumed to be oragnised in the 
                  same way as the data downloaded from HCP 
  -c <conf_dir>   absolute path to confounds directory. Check the README file in 'HCP_volume_CBPP' on
                  instructions on how to obtain these data or how they should be organised
  -r <reg_type>   type of signals to include in nuisance regression. 24 motion parameters and derivatives
                  of the signals are always included. Choose from 'wmcsf' and 'gsr'.

OPTIONAL ARGUMENTS:
  -s <sub_list>   absolute path to the subject-list file, where each line of the file contains the 
                  subject ID of one HCP subject (e.g. '100206').
                  [ default: $BIN_DIR/sublist/HCP_MNI_fix_allRun_sub.csv ]
  -i <sub_id>     subject ID of the specific subject to run (e.g. '100206')
                  [ default: unset ]
  -o <output_dir> absolute path to output directory
                  [ default: $(pwd)/results/HCP_GSR ]
  -h              display help message

OUTPUTS:
  $0 will create 4 output files in the output directory for the 4 runs of each subject
  For example: HCP_fix_gsr_sub100206_REST1_LR.nii.gz for the first run of subject 100206

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
elif [ $reg_type != 'wmcsf' -o $reg_type != 'gsr' ]; then
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