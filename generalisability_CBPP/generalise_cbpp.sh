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
ROOT_DIR=$(dirname "$SCRIPT_DIR")

###########################################
# Main commands
###########################################
main(){

# set up variables
prefix=HCP_${preproc}_AICHA_${corr}
input=$input_dir/$prefix.mat
if [ $fix_seed -eq 1 ]; then prefix=${prefix}_fixSeed; fi
output=$out_dir/wbCBPP_${method}_${conf_opt}_${prefix}.mat

# run regression
if [ ! -e $output ]; then
  matlab_cmd="matlab -nodesktop -nodisplay -nosplash -singleCompThread -nojvm -r"
  $matlab_cmd "load('$input', 'fc'); \
               load('$psych_file', 'y'); \
               load('$conf_file', 'conf'); \
               if $fix_seed == 1; seed = 1; else seed = 'shuffle'; end; \
               addpath('$ROOT_DIR/HCP_surface_CBPP/utilities'); \
               cv_ind = CVPart_HCP(10, 10, '$sub_list', '$famID_file', seed); \
               options = []; options.conf_opt = '$conf_opt'; \
               options.method = '$method'; options.prefix = '$prefix'; \
               if $fix_seed == 1; options.in_seed = 1; else options.in_seed = 'shuffle'; end;
               addpath('$ROOT_DIR'); \
               CBPP_wholebrain(fc, y, conf, cv_ind, '$out_dir', options); \
               exit"
else
  echo "Output $output already exists!"
fi

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