import numpy as np
import pandas as pd
import argparse
from pathlib import Path
import os

script_dir = str(Path(__file__).parent.resolve())
parser = argparse.ArgumentParser(description="Extract psychometric and confounding variables for HCP Young Adults",
                                 formatter_class=lambda prog: argparse.ArgumentDefaultsHelpFormatter(prog, width=100))
parser.add_argument("unres_file", type=str, help="Absolute path to the unrestricted data csv file")
parser.add_argument("res_file", type=str, help="Absolute path to the restricted data csv file")
parser.add_argument("--space", dest="space", type=str, default="surf", help="Space of the fMRI data: 'surf' or 'MNI")
parser.add_argument("--preproc", dest="preproc", type=str, default="fix", help=("Preprocessing used for surface data "
                    + "('minimal', 'fix', or 'gsr') or volumetric data ('fix', 'fix_wmcsf', or 'fix_gsr')"))
parser.add_argument("--psy_list", dest="psy_list", type=str, default=(script_dir+"/HCP_psychometric_list.csv"),
                    help="Absolute path to psychometric variable list")
parser.add_argument("--out_dir", dest="out_dir", type=str, default=os.getcwd(), 
                    help="Absolute path to the output directory")
parser.add_argument("--unit_test", dest="ut", action="store_true", help="Only get the first 50 subjects for unit test")
args = parser.parse_args()

sub_list = (str(Path(__file__).parent.parent.resolve()) + '/sublist/HCP_' + args.space + '_' + args.preproc 
            + '_allRun_sub.csv')
data = pd.read_csv(sub_list, header=None, names=['Subject'], squeeze=False)
psy_list = pd.read_csv(args.psy_list, header=None, names=['Psychometric_Var'])
conf_list = pd.read_csv((script_dir+'/HCP_conf_list.csv'), header=None, names=['Confound_Var'])

# psychometric variables
psy_var = [psy_list.iloc[i][0] for i in range(len(psy_list))]
psy_var.insert(0, 'Subject')
unres_data = pd.read_csv(args.unres_file)
data = data.merge(unres_data[psy_var], how='inner', on='Subject')

# unrestricted confounding variables: sex, brain size, ICV, acquisition
conf_var_unres = [conf_list.iloc[i][0] for i in [1, 3, 4, 5]]
conf_var_unres.insert(0, 'Subject')
data = data.merge(unres_data[conf_var_unres], how='inner', on='Subject')
data[conf_var_unres[1]] = pd.get_dummies(data[conf_var_unres[1]]).astype(int)
data[conf_var_unres[3]] = np.round(data[conf_var_unres[3]]*1000, decimals=9)/1000
data[conf_var_unres[4]] = [int(item[1:]) for item in data[conf_var_unres[4]]]

# restricted confounding variables: age, handedness
conf_var_res = [conf_list.iloc[i][0] for i in [0, 2]]
conf_var_res.insert(0, 'Subject')
res_data = pd.read_csv(args.res_file)
data = data.merge(res_data[conf_var_res], how='inner', on='Subject')

# secondary confounding variables
data = data.assign(age2=np.power(data[conf_var_res[1]], 2))
data = data.assign(sexAge=data[conf_var_unres[1]]*data[conf_var_res[1]])
data = data.assign(sexAge2=data[conf_var_unres[1]]*np.power(data[conf_var_res[1]], 2))

# save outputs separately
if args.ut:
    data = data.iloc[range(50)]
data[psy_var].to_csv((args.out_dir + '/HCP_' + args.space + '_' + args.preproc + '_y.csv'), index=None, header=None)
conf_var = [conf_list.iloc[i][0] for i in range(len(conf_list))]
data[conf_var].to_csv((args.out_dir + '/HCP_' + args.space + '_' + args.preproc + '_conf.csv'), index=None, header=None)