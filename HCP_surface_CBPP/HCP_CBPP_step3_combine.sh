#! /usr/bin/env bash
# This script is a wrapper to combine HCP FC data in fsLR space into a single .mat file.
# Jianxiao Wu, last edited on 12-Sept-2019

###########################################
# Define paths
###########################################

UTILITIES_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")/utilities
BIN_DIR=$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")/bin

###########################################
# Main commands
###########################################
main(){

# check if all subjects are present
sub_ids=`cat $sub_list`
all_present=1
for sub_id in $sub_ids; do
  input=$input_dir/HCP_${preproc}_parc${n_parc}_sub${sub_id}_${run}_${corr}.mat
  if [ ! -e $input ]; then
    echo "Subject $sub_id $run is missing!"
    all_present=0
  fi
done

# continue if all subjects are present
if [ $all_present -eq 1 ]; then
  matlab -nodesktop -nosplash -r "addpath('$UTILITIES_DIR'); \
                                  combine_HCP_data_surf('$sub_list', '$input_dir', $n_parc, '$preproc', '$corr', '$output_dir'); \
                                  exit"
fi

}

###########################################
# Function usage
###########################################

usage() { echo "
Usage: $0 -d <input_dir> -n <n_parc> -p <preproc> -c <corr> -s <sub_list> -r <clean_up> -o <output_dir>

This script is a wrapper to combine the functional connectivity (FC) for HCP fMRI data in fsLR space, 
into a single .mat file for later usage. 

All subjects in the \$sub_list are used. To use only a subset of subjects, use the -s option to provide
a custom subject-list file.

REQUIRED ARGUMENT:
  -d <input_dir>  absolute path to input directory. The directory is assumed to be the output directory 
                  in step 2

OPTIONAL ARGUMENTS:
  -n <n_parc>     parcellation granularity used. Possible values are: 100, 200, 300 and 400
                  [ default: 300 ]
  -p <preproc>    preprocessing used for input data. Possible options are:
                  'minimal': for data only processed with the HCP minimal preprocessing pipeline
                  'fix': for data processed with 'minimal' and ICA-FIX
                  [ default: 'fix' ]
  -c <corr>       correlation method used for computing FC. Possible options are:
                  'Pearson': Pearson (or full) correlation
                  'partial_l2': partial correlation with L2 regularisation
                  [ default: 'Pearson' ]
  -s <sub_list>   absolute path to the subject-list file, where each line of the file contains the 
                  subject ID of one HCP subject (e.g. '100206').
                  [ default: $BIN_DIR/sublist/HCP_surf_\$preproc_allRun_sub.csv ]
  -r <clean_up>   set this to 1 to clean up the parcellation and FC results computed in step 1 and 2
                  [ default: 0 ]
  -o <output_dir> absolute path to output directory
                  [ default: $(pwd)/results/FC_combined ]
  -h              display help message

OUTPUTS:
  $0 will create 1 output file in the output directory for all the subjects
  For example: HCP_fix_parc300_Pearson.mat

EXAMPLE:
  $0 -d \$(pwd)/results/FC -r 1
  $0 -d \$(pwd)/results/FC -n 100 -p minimal -c partial_l2 -i 100206

" 1>&2; exit 1; }

#Display help message if no argument is supplied
if [ $# -eq 0 ]; then
  usage; 1>&2; exit 1
fi

###########################################
# Parse arguments
###########################################

# Default parameters
n_parc=300
preproc=fix
corr=Pearson
clean_up=0
output_dir=$(pwd)/results/FC_combined

# Assign arguments
while getopts "n:p:c:d:s:r:o:h" opt; do
  case $opt in
    n) n_parc=${OPTARG} ;;
    p) preproc=${OPTARG} ;;
    c) corr=${OPTARG} ;;
    d) input_dir=${OPTARG} ;;
    s) sub_list=${OPTARG} ;;
    r) clean_up=${OPTARG} ;;
    o) output_dir=${OPTARG} ;;
    h) usage; exit ;;
    *) usage; 1>&2; exit 1 ;;
  esac
done

# Default subject-list
if [ -z $sub_list ]; then
  sub_list=$BIN_DIR/sublist/HCP_surf_${preproc}_allRun_sub.csv
fi

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

