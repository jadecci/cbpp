import numpy as np
import pandas as pd
import argparse
from pathlib import Path
import os

def add_data(input, col, colname, coltype, data):
    coltypes = {'Subject_ID': str, colname: coltype}
    colnames = ['Sub_Key', colname]
    data_curr = pd.read_csv(input, index_col=False, header=0, usecols=[0, col], dtype=coltypes, names=colnames)
    data_curr = data_curr.dropna().reset_index(drop=True).drop_duplicates(subset='Sub_Key')
    data = data.merge(data_curr, how='inner', on='Sub_Key')
    
    return data

parser = argparse.ArgumentParser(description="Extract psychometric and confounding variables for GSP",
                                 formatter_class=lambda prog: argparse.ArgumentDefaultsHelpFormatter(prog, width=100))
parser.add_argument("input", type=str, help="Absolute path to input file")
parser.add_argument("--out_dir", dest="out_dir", type=str, default=os.getcwd(), 
                    help="Absolute path to the output directory")
parser.add_argument("--unit_test", dest="ut", action="store_true", help="Only get the first 50 subjects for unit test")
args = parser.parse_args()

sub_list = str(Path(__file__).parent.parent.resolve()) + '/sublist/GSP_allRun_sub.csv'
data = pd.read_csv(sub_list, header=None, names=['Sub_Key'], squeeze=False)
data['Sub_Key'] = 'Sub' + data['Sub_Key'].map('{:04d}'.format) + '_S1'
# Psychometric variables
psy_list = ['NEO_O', 'EstIQ_Shipley_Int_Bin']
data = add_data(args.input, 94, psy_list[0], float, data)
data = add_data(args.input, 125, psy_list[1], float, data)

# Confounding variables
conf_list = ['Sex', 'Age_Bin', 'Hand', 'BrainSegVol', 'ICV', 'age2', 'sexAge', 'sexAge2']
data= add_data(args.input, 4, conf_list[0], str, data)
data[conf_list[0]] = pd.get_dummies(data[conf_list[0]]).astype(int)
data = add_data(args.input, 5, conf_list[1], float, data)
data = add_data(args.input, 6, conf_list[2], str, data)
data[conf_list[2]] = pd.get_dummies(data[conf_list[2]])['LFT'].astype(int)
data = add_data(args.input, 49, conf_list[3], float, data)
data = add_data(args.input, 48, conf_list[4], float, data)
# Secondary confounding variables
data = data.assign(age2=np.power(data[conf_list[1]], 2))
data = data.assign(sexAge=data[conf_list[0]]*data[conf_list[1]])
data = data.assign(sexAge2=data[conf_list[0]] * np.power(data[conf_list[1]], 2))

# save outputs separately
if args.ut:
    data = data.iloc[range(50)]
data[psy_list].to_csv((args.out_dir + '/GSP_y.csv'), index=None, header=None)
data[conf_list].to_csv((args.out_dir + '/GSP_conf.csv'), index=None, header=None)