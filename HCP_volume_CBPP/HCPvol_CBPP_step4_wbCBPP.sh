#! /usr/bin/env bash
# This script is a wrapper to run CBPP on HCP data in MNI space
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

# set up variables
prefix=HCP_${preproc}_AICHA_${corr}
input=$input_dir/$prefix.mat
if [ $fix_seed -eq 1 ]; then prefix=${prefix}_fixSeed; fi
output=$out_dir/wbCBPP_${method}_${conf_opt}_${prefix}.mat

# run regression
if [ ! -e $output ]; then
  matlab_cmd="matlab95 -nodesktop -nodisplay -nosplash -singleCompThread -nojvm -r"
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
Usage: $0 -d input_dir -y psych_file -v conf_file -m famID_file -r <method> -p <preproc> -c <corr> -s <fix_seed> -l <sub_list> -o <output_dir>

This script is a wrapper to run whole-brain CBPP using combined connectivity data from HCP.

REQUIRED ARGUMENT:
  -d <input_dir>  absolute path to input directory. The directory is assumed to be the output directory 
                  in step 3
  -y <psych_file> absolute path to psychometric file, which should be a .mat file containing a variable 
                  'y' of dimension NxP (N = number of subjects, P = number of psychometric variables)
  -v <conf_file>  absolute path to confounds file, which should be a .mat file containing a variable
                  'conf' of dimension NxC (C = number of confounding variables)
  -m <famID_file> absolute path to the family ID file, which should be a .mat file containing two string 
                  array variables 'all_famID' and 'all_subID' of dimension Nx1

OPTIONAL ARGUMENTS:
  -r <method>     regression method to use for prediction. Possible options are:
                  'MLR': multiple linear regression
                  'SVR': Support Vector Regression
                  'EN': Elastic net
                  'RR': ridge regression
                  [ default: 'SVR' ]
  -p <preproc>    preprocessing used for input data. Possible options are:
                  'fix': for data processed with ICA-FIX
                  'fix_wmcsf': for data processed with 'ICA-FIX' and WM/CSF nuisance regression
                  'fix_gsr': for data processed with 'ICA-FIX' and global signal regression (GSR)
                  [ default: 'fix_wmcsf' ]
  -c <corr>       correlation method used for computing FC. Possible options are:
                  'Pearson': Pearson (or full) correlation
                  'partial_l2': partial correlation with L2 regularisation
                  [ default: 'Pearson' ]
  -f <conf_opt>   confound controlling approach. Possible options are:
                  'standard': regress out confounding variables
                  'str_conf': same as 'standard', but used to highlight that only confounds correlated
                              with strength were provided in \$conf_file (i.e. sex, brain size and ICV)
                  'add_conf': confounds are added as features
                  'no_conf': no confound controlling will be used
                  [ default: 'standard' ]
  -s <fix_seed>   set this to 1 to fix the seed for generating cross-validation partitions, so that 
                  statistical tests can be performed. By default, the seed is randomly set.
                  [ default: 0 ]
  -l <sub_list>   absolute path to the subject-list file, where each line of the file contains the subject
                  ID of one HCP subject (e.g. '100206')
                  [ default: $ROOT_DIR/bin/sublist/HCP_surf_\$preproc_allRun_sub.csv ]
  -o <output_dir> absolute path to output directory
                  [ default: $(pwd)/results/CBPP_perf ]
  -h              display help message

OUTPUTS:
  $0 will create 1 output file in the output directory, containing the prediction performance
  For example: wbCBPP_SVR_standard_HCP_fix_wmcsf_AICHA_Pearson.mat

EXAMPLE:
  $0 -d \$(pwd)/results/FC_combined
  $0 -d \$(pwd)/results/FC_combined -p fix_gsr -c partial_l2 -r EN

" 1>&2; exit 1; }

#Display help message if no argument is supplied
if [ $# -eq 0 ]; then
  usage; 1>&2; exit 1
fi

###########################################
# Parse arguments
###########################################

# Default parameters
method=SVR
preproc=fix_wmcsf
corr=Pearson
conf_opt=standard
fix_seed=0
out_dir=$(pwd)/results/CBPP_perf
sub_list=$BIN_DIR/sublist/HCP_MNI_${preproc}_allRun_sub.csv

# Assign arguments
while getopts "p:c:d:y:v:m:r:f:s:l:o:h" opt; do
  case $opt in
    p) preproc=${OPTARG} ;;
    c) corr=${OPTARG} ;;
    d) input_dir=${OPTARG} ;;
    y) psych_file=${OPTARG} ;;
    v) conf_file=${OPTARG} ;;
    m) famID_file=${OPTARG} ;;
    r) method=${OPTARG} ;;
    f) conf_opt=${OPTARG} ;;
    s) fix_seed=${OPTARG} ;;
    l) sub_list=${OPTARG} ;;
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

if [ -z $psych_file ]; then
  echo "Psychometric file not defined."; 1>&2; exit 1;
fi

if [ -z $conf_file ]; then
  echo "Confounds file not defined."; 1>&2; exit 1;
fi

if [ -z $famID_file ]; then
  echo "Family ID file not defined."; 1>&2; exit 1;
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
