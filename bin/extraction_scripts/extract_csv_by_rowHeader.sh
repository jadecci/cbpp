#!/usr/bin/env bash
# This script extracts content from a csv file by the row headers provided in another csv file
# Jianxiao Wu, last edited on 04-Apr-2020

# input parameter
input_file=$1
header_file=$2
output_file=$3
keep_first_row=$4

# usage
if [ $# -ne 4 ]; then
  echo "Usage: $0 input_file header_file output_file keep_first_row"
  exit
fi

# set-up
n_header=`cat $header_file | wc -l | sed 's/^ *//'`
n_row=`cat $input_file | wc -l | sed 's/^ *//'`
if [ -e $output_file ]; then rm $output_file; fi

# keep first row if required
row_start=1
if [ $keep_first_row -eq 1 ]; then
  head -1 $input_file > $output_file
  row_start=2
fi

# extract rows with matching header
for i in $(seq 1 $n_header); do
  header=`head -$i $header_file | tail -1`

  for j in  $(seq $row_start $n_row); do
    curr_header=`head -$j $input_file | tail -1 | cut -d ',' -f 1`
    if [ "$curr_header" == "$header" ]; then
      head -$j $input_file | tail -1 >> $output_file
      echo "Found header $i: $header in input row $j"
      break
    fi
  done

done
