#!/usr/bin/env bash
# This script extracts psychometric and confounding variables for the HCP dataset
# Jianxiao Wu, last edited on 08-Apr-2020

if [ "$(uname)" == "Linux" ]; then
  SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
elif [ "$(uname)" == "Darwin" ]; then
  SCRIPT_DIR=$(dirname "$0")
  SCRIPT_DIR=$(cd "$SCRIPT_DIR"; pwd)
fi
BIN_DIR=$(dirname "$SCRIPT_DIR")

###########################################
# Main commands
###########################################
main(){
# set-up for unit test data extraction
if [ $unit_test -eq 1 ]; then
  sub_start=1
  sub_stop=50
  if [ "$space" == "surf" ]; then preproc=gsr; else preproc=fix_wmcsf; fi
fi

# create list of subjects needed
sublist_orig=$BIN_DIR/sublist/HCP_${space}_${preproc}_allRun_sub.csv
if [ -z $sub_stop ]; then sub_stop=`cat $sublist_orig | wc -l | sed 's/^ *//'`; fi
sublist_temp=$out_dir/temp_sublist.csv
head -$sub_stop $sublist_orig | tail -$((sub_stop-sub_start+1)) > $sublist_temp

date

# extract psychometric data
row_temp=$out_dir/temp_rowExtracted.csv
psych_temp=$out_dir/temp_psychometricExtracted.csv
$SCRIPT_DIR/extract_csv_by_rowHeader.sh $unres_file $sublist_temp $row_temp 1
$SCRIPT_DIR/extract_csv_by_colHeader.sh $row_temp $psy_list $psych_temp

# extract confounding variables
row_temp=$out_dir/temp_rowExtracted.csv
conf_unres_temp=$out_dir/temp_confExtracted_unres.csv
conf_res_temp=$out_dir/temp_confExtracted_res.csv
$SCRIPT_DIR/extract_csv_by_colHeader.sh $row_temp $SCRIPT_DIR/HCP_conf_list.csv $conf_unres_temp
$SCRIPT_DIR/extract_csv_by_rowHeader.sh $res_file $sublist_temp $row_temp 1
$SCRIPT_DIR/extract_csv_by_colHeader.sh $row_temp $SCRIPT_DIR/HCP_conf_list.csv $conf_res_temp

# output final .csv files or convert extracted data to .mat format
out_prefix=HCP_${space}_${preproc}_sub${sub_start}to${sub_stop}
if [ $unit_test -eq 1 ]; then out_prefix=unit_test_${space}; fi
matlab_cmd="matlab -nodesktop -nosplash -singleCompThread -r"
$matlab_cmd "addpath('$SCRIPT_DIR'); \
            HCP_extraction_output('$psych_temp', '$conf_unres_temp', '$conf_res_temp', '$out_dir', '$out_prefix', $mat_out); \
            rmpath('$SCRIPT_DIR'); \
            exit"

date

# clean up
rm $sublist_temp $row_temp $psych_temp $conf_unres_temp $conf_res_temp
}

###########################################
# Function usage
###########################################

usage() { echo "
Usage: $0 -i unres_file -j res_file -s <space> -p <preproc> -a <sub_start> -b <sub_stop> -u <unit_test> -l <psy_list> 
          -o <out_dir> -m <mat_out>

This script is a wrapper to extract the psychometric and confounding variables from the HCP unrestricted and restricted csv file. 

Subject IDs from subject lists in $BIN_DIR are used to select the subjects (rows in the csv file), while the headers from HCP_psychometric_list.csv and HCP_conf_list.csv are used to select the columns in the csv file.

REQUIRED ARGUMENT:
  -i unres_file   absolute path to the unrestricted data csv file
  -j res_file>    absolute path to the restricted data csv file

OPTIONAL ARGUMENTS:
  -s <space>      space of the fMRI data. Choose from 'surf' (fsLR space) and 'MNI' (MNI152 space)
                  [ default : 'surf' ]
  -p <preproc>    preprocessing used for input data. Possible options are:
                  'surf' data: 'minimal', 'fix', 'gsr' 
                  'MNI' data: 'fix', 'fix_wmcsf', 'fix_gsr'
                  [ default: 'fix' ]
  -a <sub_start>  index of subject in the subject list to start from
                  [ default: 1 ]
  -b <sub_stop>   index of subject in the subject list to stop at. 
                  [ default: (the last subject) ]
  -u <unit_test>  set to 1 if the outputs are to be used by the unit test. In this case, 'preproc', 'sub_start' and 
                  'sub_stop' are automatically set (user choice will be overridden)
                  [ default: 0 ] 
  -l <psy_list>   absolute path to psychometric variable list
                  [ default: $SCRIPT_DIR/HCP_psychometric_list.csv ]
  -o <out_dir>    absolute path to output directory
                  [ default: $(pwd)/results ]
  -m <mat_out>    set to 1 to convert .csv outputs to .mat files
                  [ default: 0 ]
  -h              display help message

OUTPUTS:
  $0 will create 2 output files in the output directory for the psychometric and confounding variables respectively
  For example: HCP_surf_fix_sub1to923_y.csv
               HCP_surf_fix_sub1to923_conf.csv

EXAMPLE:
  $0 -i ~/data/HCP_unrestricted_data.csv -j ~/data/HCP_restricted_data.csv
  $0 -i ~/data/HCP_unrestricted_data.csv -j ~/data/HCP_restricted_data.csv -s 'MNI' -u 1

" 1>&2; exit 1; }

#Display help message if no argument is supplied
if [ $# -eq 0 ]; then
  usage; 1>&2; exit 1
fi

###########################################
# Parse arguments
###########################################

# Default parameters
space=surf
preproc=fix
sub_start=1
unit_test=0
psy_list=$SCRIPT_DIR/HCP_psychometric_list.csv
out_dir=$(pwd)/results
mat_out=0

# Assign arguments
while getopts "i:j:s:p:a:b:u:l:o:m:h" opt; do
  case $opt in
    i) unres_file=${OPTARG} ;;
    j) res_file=${OPTARG} ;;
    s) space=${OPTARG} ;;
    p) preproc=${OPTARG} ;;
    a) sub_start=${OPTARG} ;;
    b) sub_stop=${OPTARG} ;;
    u) unit_test=${OPTARG} ;;
    l) psy_list=${OPTARG} ;;
    o) out_dir=${OPTARG} ;;
    m) mat_out=${OPTARG} ;;
    h) usage; exit ;;
    *) usage; 1>&2; exit 1 ;;
  esac
done

###########################################
# Check parameters
###########################################

if [ -z $unres_file ]; then
  echo "Unrestricted data file not defined."; 1>&2; exit 1;
fi

if [ -z $res_file ]; then
  echo "Restricted data file not defined."; 1>&2; exit 1;
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
