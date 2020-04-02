#! /usr/bin/env bash
# This script is a wrapper to apply GSR to a HCP subjects. 
# Jianxiao Wu, last edited on 30-Sept-2019

###########################################
# Define paths
###########################################

UTILITIES_DIR=$(dirname "$(readlink -f "$0")")/utilities
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
    output_name=$out_dir/HCP_GSRcortex_sub${sub_id_curr}_${run}
    if [ ! -e $output_name.dtseries.nii ]; then
      echo "Running sub$sub_id_curr $run"
      
      # Generate global signal regressors
      input=$input_dir/$sub_id_curr/MNINonLinear/Results/rfMRI_$run/rfMRI_${run}_Atlas_hp2000_clean.dtseries.nii
      matlab -nodesktop -nosplash -r "addpath(genpath('$BIN_DIR/external_packages'), '$UTILITIES_DIR'); \
                                      input = ft_read_cifti('$input'); \
                                      regressors = global_signal_withDiff(input.dtseries, 1:64984); \
                                      input_matrix = single(input.dtseries); \
                                      [resid, ~, ~, ~] = CBIG_glm_regress_matrix(input_matrix', regressors', 1, []); \
                                      input.dtseries = resid'; \
                                      ft_write_cifti('$output_name', input, 'parameter', 'dtseries'); \
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
Usage: $0 -d <input_dir> -n <n_parc> -p <preproc> -s <sub_list> -i <sub_id> -o <output_dir>

This script is a wrapper to run global signal regression (GSR) for HCP fMRI data in fsLR space, after 
minimal preprocessing pipeline and ICA-FIX. 

By default, all subjects in the specified sub_list are used. For better parallelisation, use the -i 
option to specify one subject to run at a time.

Note that the fMRI data should be in cifti format, i.e. the file should ends in .dtseries.nii

REQUIRED ARGUMENT:
  -d <input_dir>  absolute path to input directory. The directory is assumed to be oragnised in the 
                  same way as the data downloaded from HCP 

OPTIONAL ARGUMENTS:
  -s <sub_list>   absolute path to the subject-list file, where each line of the file contains the 
                  subject ID of one HCP subject (e.g. '100206').
                  [ default: $BIN_DIR/sublist/HCP_surf_fix_allRun_sub.csv ]
  -i <sub_id>     subject ID of the specific subject to run (e.g. '100206')
                  [ default: unset ]
  -o <output_dir> absolute path to output directory
                  [ default: $(pwd)/results/HCP_GSR ]
  -h              display help message

OUTPUTS:
  $0 will create 4 output files in the output directory for the 4 runs of each subject
  For example: HCP_GSRcortex_sub100206_REST1_LR.dtseries.nii for the first run of subject 100206

EXAMPLE:
  $0 -d ~/data -i 100206

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
while getopts "d:s:i:o:h" opt; do
  case $opt in
    d) input_dir=${OPTARG} ;;
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