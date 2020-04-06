#! /usr/bin/env bash
# This script is a wrapper to run parcelation for HCP fMRI data in MNI space.
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

# get all subject names
if [ -z $sub_id ]; then sub_names=`cat $sub_list`; else sub_names=$sub_id; fi
# get parcellation file
parc_file=$BIN_DIR/parcellations/AICHA.nii

# loop through each subject
for sub_id_curr in $sub_names; do

  # loop througgh each run
  for run in REST1_LR REST1_RL REST2_LR REST2_RL
  do

    # get input
    case "$preproc" in
      fix)
        input=$input_dir/$sub_id_curr/MNINonLinear/Results/rfMRI_$run/rfMRI_${run}_hp2000_clean.nii.gz ;;
      fix_gsr|fix_wmcsf)
        input=$input_dir/HCP_${preproc}_sub${sub_id_curr}_${run}.nii.gz ;;
    esac
    output=$out_dir/HCP_${preproc}_AICHA_sub${sub_id_curr}_${run}.mat

    # run parcellation if necessary
    if [ ! -e $output ]; then
      echo "Running sub$sub_id_curr $run"
      matlab -nodesktop -nosplash -r "input = MRIread('$input'); \
                                      addpath('$UTILITIES_DIR'); \
                                      vol_parc = parcellate_AICHA_MNI(input.vol, '$parc_file'); \
                                      save('$output', 'vol_parc'); \
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
Usage: $0 -d <input_dir> -p <preproc> -s <sub_list> -i <sub_id> -o <output_dir>

This script is a wrapper to run parcelation for HCP fMRI data in MNI space, using the AICHA atlas. 

By default, all subjects in the specified sub_list are parcellated. For better parallelisation, use the 
-i option to specify one subject to run at a time.

REQUIRED ARGUMENT:
  -d <input_dir>  absolute path to input directory. For FIX data, the directory is assumed to be oragnised in the 
                  same way as the data downloaded from HCP 

OPTIONAL ARGUMENTS:
  -p <preproc>    preprocessing used for input data. Possible options are:
                  'fix': for data processed with ICA-FIX
                  'fix_wmcsf': for data processed with 'ICA-FIX' and WM/CSF nuisance regression
                  'fix_gsr': for data processed with 'ICA-FIX' and global signal regression (GSR)
                  [ default: 'fix_wmcsf' ]
  -s <sub_list>   absolute path to the subject-list file, where each line of the file contains the 
                  subject ID of one HCP subject (e.g. '100206').
                  [ default: $BIN_DIR/sublist/HCP_MNI_\$preproc_allRun_sub.csv ]
  -i <sub_id>     subject ID of the specific subject to run (e.g. '100206')
                  [ default: unset ]
  -o <output_dir> absolute path to output directory
                  [ default: $(pwd)/results/parcellation ]
  -h              display help message

OUTPUTS:
  $0 will create 4 output files in the output directory for the 4 runs of each subject
  For example: HCP_fix_wmcsf_AICHA_sub100206_REST1_LR.mat for the first run of subject 100206

EXAMPLE:
  $0 -d ~/data
  $0 -d ~/data -n 100 -p fix_gsr -i 100206

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
out_dir=$(pwd)/results/parcellation
sub_list=$BIN_DIR/sublist/HCP_MNI_${preproc}_allRun_sub.csv

# Assign arguments
while getopts "p:d:s:i:o:h" opt; do
  case $opt in
    p) preproc=${OPTARG} ;;
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
