#!/usr/bin/env bash
# This script extracts content from a csv file by the column headers provided in another csv file
# Jianxiao Wu, last edited on 04-Apr-2020

# input parameter
input_file=$1
header_file=$2
output_file=$3

# usage
if [ $# -ne 3 ]; then
  echo "Usage: $0 input_file header_file output_file"
  exit
fi

# set-up
n_header=`cat $header_file | wc -l | sed 's/^ *//'`
n_col=`head -1 $input_file | awk -F, '{print NF}'`
extract_cmd="cat $input_file | cut -d ',' -f"
first_col=1
if [ -e $output_file ]; then rm $output_file; fi

# search for columns with matching header
for i in $(seq 1 $n_header); do
  header=`head -$i $header_file | tail -1`

  for j in  $(seq 1 $n_col); do
    curr_header=`head -1 $input_file | cut -d ',' -f $j`
    if [ "$curr_header" == "$header" ]; then
      if [ $first_col -eq 1 ]; then 
        extract_cmd="$extract_cmd $j"
        col_ind="$j"
        first_col=0
      else 
        extract_cmd="${extract_cmd},$j"
        col_ind="${col_ind},$j"
      fi
      echo "Found header $i: $header in input column $j"
      break
    fi
  done

done

# extract the selected columns
echo $extract_cmd
eval "$extract_cmd" > $output_file
echo "$col_ind" >> $output_file
