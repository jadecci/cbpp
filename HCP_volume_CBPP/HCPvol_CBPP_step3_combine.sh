#! /usr/bin/env bash
# This script is a wrapper to combine HCP FC data in MNI space into a single .mat file.
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
UTILITIES_DIR=$SCRIPT_DIR/utilities
BIN_DIR=$(dirname "$SCRIPT_DIR")/bin

###########################################
# Main commands
###########################################
main(){

# check if all subjects are present
sub_ids=`cat $sub_list`
all_present=1
for sub_id in $sub_ids; do
  for run in REST1_LR REST1_RL REST2_LR REST2_RL; do
    input=$input_dir/HCP_${preproc}_AICHA_sub${sub_id}_${run}_${corr}.mat
    if [ ! -e $input ]; then
      echo "Subject $sub_id $run is missing! Expecting input $input"
      all_present=0
    fi
  done
done

# continue if all subjects are present
if [ $all_present -eq 1 ]; then
  if [ ! -e $out_dir/HCP_${preproc}_AICHA_${corr}.mat ]; then
    matlab95 -nodesktop -nosplash -r "addpath('$UTILITIES_DIR'); \
                                    combine_HCP_data_MNI('$sub_list', '$input_dir', 'AICHA', '$preproc', '$corr', '$out_dir'); \
                                    exit"
  else
    echo "Combined FC matrix output already exists"
  fi
fi

# clean up if required
if [ $clean_up -eq 1 ]; then
  rm -rf $(pwd)/results/parcellation
  rm -rf $(pwd)/results/FC
  if [ -d $(pwd)/results/HCP_regress ]; then rm -rf $(pwd)/results/HCP_regress; fi
fi

}

###########################################
# Function usage
###########################################

usage() { echo "
Usage: $0 -d <input_dir> -p <preproc> -c <corr> -s <sub_list> -r <clean_up> -o <output_dir>

This script is a wrapper to combine the functional connectivity (FC) for HCP fMRI data in MNI space, 
into a single .mat file for later usage. 

All subjects in the \$sub_list are used. To use only a subset of subjects, use the -s option to provide
a custom subject-list file.

REQUIRED ARGUMENT:
  -d <input_dir>  absolute path to input directory. The directory is assumed to be the output directory 
                  in step 2

OPTIONAL ARGUMENTS:
  -p <preproc>    preprocessing used for input data. Possible options are:
                  'fix': for data processed with ICA-FIX
                  'fix_wmcsf': for data processed with 'ICA-FIX' and WM/CSF nuisance regression
                  'fix_gsr': for data processed with 'ICA-FIX' and global signal regression (GSR)
                  [ default: 'fix_wmcsf' ]
  -c <corr>       correlation method used for computing FC. Possible options are:
                  'Pearson': Pearson (or full) correlation
                  'partial_l2': partial correlation with L2 regularisation
                  [ default: 'Pearson' ]
  -s <sub_list>   absolute path to the subject-list file, where each line of the file contains the 
                  subject ID of one HCP subject (e.g. '100206').
                  [ default: $BIN_DIR/sublist/HCP_MNI_\$preproc_allRun_sub.csv ]
  -r <clean_up>   set this to 1 to clean up the parcellation and FC results computed in step 1 and 2
                  [ default: 0 ]
  -o <output_dir> absolute path to output directory
                  [ default: $(pwd)/results/FC_combined ]
  -h              display help message

OUTPUTS:
  $0 will create 1 output file in the output directory for all the subjects
  For example: HCP_fix_wmcsf_AICHA_Pearson.mat

EXAMPLE:
  $0 -d \$(pwd)/results/FC -r 1
  $0 -d \$(pwd)/results/FC -n 100 -p fix_gsr -c partial_l2 -i 100206

" 1>&2; exit 1; }

#Display help message if no argument is supplied
if [ $# -eq 0 ]; then
  usage; 1>&2; exit 1
fi

###########################################
# Parse arguments
###########################################

# Default parameters
preproc=fix_wmcsf
corr=Pearson
clean_up=0
out_dir=$(pwd)/results/FC_combined
sub_list=$BIN_DIR/sublist/HCP_MNI_${preproc}_allRun_sub.csv

# Assign arguments
while getopts "p:c:d:s:r:o:h" opt; do
  case $opt in
    p) preproc=${OPTARG} ;;
    c) corr=${OPTARG} ;;
    d) input_dir=${OPTARG} ;;
    s) sub_list=${OPTARG} ;;
    r) clean_up=${OPTARG} ;;
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

