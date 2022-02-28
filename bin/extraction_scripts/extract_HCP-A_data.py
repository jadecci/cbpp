import numpy as np
import pandas as pd
import argparse
from pathlib import Path
import os

def add_data(in_dir, in_file, col, sub_col, colname, coltype, data):
    input = in_dir + '/' + in_file
    coltypes = {'subjectkey': str, colname: coltype}
    colnames = ['Sub_Key', colname]
    data_curr = pd.read_table(input, sep='\t', header=0, skiprows=[1], usecols=[sub_col, col], dtype=coltypes, 
                                     names=colnames)
    data_curr = data_curr.dropna().reset_index(drop=True).drop_duplicates(subset='Sub_Key')
    data = data.merge(data_curr, how='inner', on='Sub_Key')
    
    return data

parser = argparse.ArgumentParser(description="Extract psychometric and confounding variables for HCP-Aging",
                                 formatter_class=lambda prog: argparse.ArgumentDefaultsHelpFormatter(prog, width=100))
parser.add_argument("in_dir", type=str, help="Absolute path to input directory")
parser.add_argument("--psy", dest="psy", type=str, default="fluidcog", 
                    help="Psychometric variable to include. Choose from 'fluidcog' and 'openness'")
parser.add_argument("--out_dir", dest="out_dir", type=str, default=os.getcwd(), 
                    help="Absolute path to the output directory")
parser.add_argument("--unit_test", dest="ut", action="store_true", help="Only get the first 50 subjects for unit test")
args = parser.parse_args()

sub_list = str(Path(__file__).parent.parent.resolve()) + '/sublist/HCP-A_' + args.psy + '_allRun_sub.csv'
data = pd.read_csv(sub_list, header=None, names=['Sub_Key'], squeeze=False)
# Psychometric variables
psy_list = ['neo2_score_op', 'nih_fluidcogcomp_ageadjusted']
if args.psy == 'openness':
    data = add_data(args.in_dir, 'nffi01.txt', 78, 4, psy_list[0], float, data)
elif args.psy == 'fluidcog':
    data = add_data(args.in_dir, 'cogcomp01.txt', 14, 4, psy_list[1], float, data)

# Confounding variables
conf_list = ['grip_standardsc_dom', 'grip_standardsc_nondom', 'interview_age', 'sex', 'hcp_handedness_score',
             'age2', 'sexAge', 'sexAge2']
data= add_data(args.in_dir, 'tlbx_motor01.txt', 22, 4, conf_list[0], float, data)
data = add_data(args.in_dir, 'tlbx_motor01.txt', 23, 4, conf_list[1], float, data)
data = add_data(args.in_dir, 'ssaga_cover_demo01.txt', 5, 4, conf_list[2], float, data)
data = add_data(args.in_dir, 'ssaga_cover_demo01.txt', 7, 4, conf_list[3], str, data)
data[conf_list[3]] = pd.get_dummies(data[conf_list[3]]).astype(int)
data = add_data(args.in_dir, 'edinburgh_hand01.txt', 70, 5, conf_list[4], float, data)
# Secondary confounding variables
data = data.assign(age2=np.power(data[conf_list[2]], 2))
data = data.assign(sexAge=data[conf_list[3]]*data[conf_list[2]])
data = data.assign(sexAge2=data[conf_list[3]] * np.power(data[conf_list[2]], 2))

# save outputs separately
if args.ut:
    data = data.iloc[range(50)]
data[psy_list].to_csv((args.out_dir + '/HCP-A_' + args.psy + '_y.csv'), index=None, header=None)
data[conf_list].to_csv((args.out_dir + '/HCP-A_' + args.psy + '_conf.csv'), index=None, header=None)