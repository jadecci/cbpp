#! /usr/bin/env bash
# This script is a wrapper to run parcelation for HCP fMRI data in fsLR space.
# Jianxiao Wu, last edited on 06-Sept-2019

###########################################
# Define paths
###########################################

UTILITIES_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")/utilities
BIN_DIR=$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")/bin

###########################################
# Main commands
###########################################
main(){

# get total number of subjects to run
if [ -z $sub_id ]; then n_sub=`cat $sub_list | wc -l`; else; n_sub=1; fi
# get parcellation file
parc_file=$BIN_DIR/parcellations/Schaefer2018_${n_parc}Parcels_17Networks_order.dlabel.nii

# loop through each subject
for i in {1..$n_sub}; do
  
  # get subject ID from subject-list file if not provided
  if [ -z $sub_id ]; then sub_id=`head -$i $sublist | tail -1`; fi

  # loop througgh each run
  for run in REST1_LR REST1_RL REST2_LR REST2_RL
  do
    echo "Running sub$sub_id $run"

    # get input
    case "$preproc" in
      fix)
        input=$input_dir/$sub_id/rfMRI_$run/rfMRI_${run}_Atlas_hp2000_clean.dtseries.nii ;;
      minimal)
        input=$input_dir/$sub_id/rfMRI_$run/rfMRI_${run}_Atlas.dtseries.nii ;;
      gsr_cortex)
        input=$input_dir/HCP_fix_sub${sub_id}_${run}_cortex_GSR.dtseries.nii ;;
    esac
    output=$output_dir/HCP_${preproc}_parc${n_parc}_sub${sub_id}_${run}.mat

    # get parcellation
    matlab -nodesktop -nosplash -r "addpath('$BIN_DIR/external_packages/cifti-matlab', '$UTILITIES_DIR'); \
                                    input = ft_read_cifti('$input'); \
                                    vol_parc = parcellate_Schaefer_fslr(input.dtseries, $n_parc, '$parc_file'); \
                                    save('$output', 'vol_parc'); \
                                    rmpath('$BIN_DIR/external_packages/cifti-matlab', '$UTILITIES_DIR'); \
                                    exit"
  done
done
}

###########################################
# Function usage
###########################################

usage() { echo "
Usage: $0 -n <n_parc> -p <preproc> -d <input_dir> -s <sub_list> -i <sub_id> -o <output_dir>

This script is a wrapper to run parcelation for HCP fMRI data in fsLR space, using the Schaefer atlas. 

By default, all subjects in the specified sub_list are parcellated. For better parallelisation, use the 
-i option to specify one subject to run at a time.

Note that the fMRI data should be in cifti format, i.e. the file should ends in .dtseries.nii

REQUIRED ARGUMENT:
  -n <n_parc>     parcellation granularity to use. Possible values are: 100, 200, 300 and 400
  -p <preproc>    preprocessing used for input data. Possible options are:
                  'minimal': for data only processed with the HCP minimal preprocessing pipeline
                  'fix': for data processed with 'minimal' and ICA-FIX
                  'gsr_cortex': for data processed with 'fix' and global signal regression (GSR). Note 
                                that global signals for suface data were computed only across cortical
                                vertices
  -d <input_dir>  absolute path to input directory. For 'minimal' and 'fix' data, this directory should
                  be the folder containing all subjects. For 'gsr_cortex', this directory is the 
                  output_directory in step 0

OPTIONAL ARGUMENTS:
  -s <sub_list>   absolute path to the subject-list file, where each line of the file contains the 
                  subject ID of one HCP subject (e.g. '100206').
                  [ default: $BIN_DIR/sublist/HCP_surf_\$preproc_allRun_sub.csv ]
  -i <sub_id>     subject ID of the specific subject to run (e.g. '100206')
                  [ default: unset ]
  -o <output_dir> absolute path to output directory
                  [ default: $(pwd)/results ]
  -h              display help message

OUTPUTS:
  $0 will create 1 output file in the output directory for each subject
  For example: HCP_fix_parc300_sub100206_REST1_LR.mat

EXAMPLE:
  $0 -n 300 -p fix
  $0 -n 300 -p fix -i 100206

" 1>&2; exit 1; }

#Display help message if no argument is supplied
if [ $# -eq 0 ]; then
  usage; 1>&2; exit 1
fi

###########################################
# Parse arguments
###########################################

# Assign arguments
while getopts "n:p:d:s:i:o:h" opt; do
  case $opt in
    n) n_parc=${OPTARG} ;;
    p) preproc=${OPTARG} ;;
    d) input_dir=${OPTARG} ;;
    s) sub_list=${OPTARG} ;;
    i) sub_id=${OPTARG} ;;
    o) output_dir=${OPTARG} ;;
    h) usage; exit ;;
    *) usage; 1>&2; exit 1 ;;
  esac
done

# Default subject-list
if [ -z $sub_list ]; then
  sub_list=$BIN_DIR/sublist/HCP_surf_${preproc}_allRun_sub.csv
fi

# Default output directory
if [ -z $output_dir ]; then
  output_dir=$(pwd)/results
fi

###########################################
# Check parameters
###########################################

if [ -z $n_parc ]; then
  echo "Parcellation granularity not defined."; 1>&2; exit 1;
fi

if [ -z $preproc ]; then
  echo "Preprocessing not defined."; 1>&2; exit 1;
fi

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
