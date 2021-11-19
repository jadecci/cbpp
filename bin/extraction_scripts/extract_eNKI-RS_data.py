import numpy as np
import pandas as pd
import argparse
from pathlib import Path
import os

def add_data(in_dir, in_file, i_col, score_name, sub, ses, base_data):
    input = in_dir + '/' + in_file
    score_data = pd.read_csv(input, index_col=False, usecols=[0, 4, i_col], skiprows=[0])
    score_data = score_data.assign(Subject=('sub-'+score_data['ID'])).drop(columns=['ID'])
    score_data = score_data.assign(Session=('ses-'+score_data['VISIT'])).drop(columns=['VISIT'])
    for col in score_data.columns.values:
        if col != 'Subject' and col != 'Session':
            score_data = score_data.rename(columns={col: score_name})
    score_data.dropna(inplace=True)
    score_data.reset_index(drop=True, inplace=True)
    
    ind = base_data.loc[base_data['Subject']==sub].loc[base_data['Session']==ses].index.values[0]
    score_ind = score_data.loc[score_data['Subject']==sub].loc[score_data['Session']==ses].index.values
    score_ind_V1 = score_data.loc[score_data['Subject']==sub].loc[score_data['Session']=='ses-V1'].index.values
    if score_ind.size:
        if score_data.at[score_ind[0], score_name] != ' ':
            base_data.at[ind, score_name] = score_data.at[score_ind[0], score_name]
    elif score_ind_V1.size:
        if score_data.at[score_ind_V1[0], score_name] != ' ':
            base_data.at[ind, score_name] = score_data.at[score_ind_V1[0], score_name]
        
    return base_data

parser = argparse.ArgumentParser(description="Extract psychometric and confounding variables for eNKI-RS",
                                 formatter_class=lambda prog: argparse.ArgumentDefaultsHelpFormatter(prog, width=100))
parser.add_argument("in_dir", type=str, help="Absolute path to input directory")
parser.add_argument("--psy", dest="psy", type=str, default="fluidcog", 
                    help="Psychometric variable to include. Choose from 'fluidcog' and 'openness'")
parser.add_argument("--out_dir", dest="out_dir", type=str, default=os.getcwd(), 
                    help="Absolute path to the output directory")
parser.add_argument("--unit_test", dest="ut", action="store_true", help="Only get the first 50 subjects for unit test")
args = parser.parse_args()

sub_list = str(Path(__file__).parent.parent.resolve()) + '/sublist/eNKI-RS_' + args.psy + '_allRun_sub.csv'
data = pd.read_csv(sub_list, header=0, names=['Subject', 'Session', 'SessionRS'])
# Psychometric variables
for i, row in data.iterrows():
    if args.psy == 'openness':
        data = add_data(args.in_dir, '8100_NEO-FFI-3_20180806.csv', 75, args.psy, row['Subject'], row['Session'], data)
    elif args.psy == 'fluidcog':
        data = add_data(args.in_dir, '8100_WASI-II_20180806.csv', 19, args.psy, row['Subject'], row['Session'], data)

# Confounding variables
conf_list = ['Age', 'Sex', 'Handedness', 'BMI', 'Age2', 'SexAge', 'SexAge2']
for i, row in data.iterrows():
    data = add_data(args.in_dir, '8100_Age_20180806.csv', 6, conf_list[0], row['Subject'], row['Session'], data)
    data = add_data(args.in_dir, '8100_Demos_20180806.csv', 7, conf_list[1], row['Subject'], row['Session'], data)
    data = add_data(args.in_dir, '8100_EHQ_20180806.csv', 36, conf_list[2], row['Subject'], row['Session'], data)
    data = add_data(args.in_dir, '8100_HT-WT,_Vitals_20180806.csv', 10, conf_list[3], row['Subject'], row['Session'], data)
data = data.astype({conf_list[1]: 'float64'})
# Secondary confounding variables
data = data.assign(Age2=np.power(data[conf_list[0]], 2))
data = data.assign(SexAge=data[conf_list[1]]*data[conf_list[0]])
data = data.assign(SexAge2=data[conf_list[1]] * np.power(data[conf_list[0]], 2))

# save outputs separately
if args.ut:
    data = data.iloc[range(50)]
data[args.psy].to_csv((args.out_dir + '/eNKI-RS_' + args.psy + '_y.csv'), index=None, header=None)
data[conf_list].to_csv((args.out_dir + '/eNKI-RS_' + args.psy + '_conf.csv'), index=None, header=None)