# Python script converting
#   the exchange csv file
#   to Sympheny input xlsx files.
# It is interfaced with the shell using argparse.


from _config_estcp import * # This imports os and pandas as pd

import argparse
import shutil

import numpy as np

#%% Main function
def main(stag: str, util: str, buil_nos, hubname = ''):

    df = pd.DataFrame({'row' : np.linspace(1,8760,8760,dtype = int),
                       'value' : np.zeros(8760)})
    buillist = '' # building list, remains '' if hub name hubname provided
    
    flag = False # flag when data found to generate output files
    for buil_no in buil_nos:
        MID = f'{stag}_{buil_no}_{util}' # meter ID
        fni = os.path.join(dirExch, f'{MID}.csv')
        if os.path.isfile(fni):
            df['value'] = df['value'] + readMID(MID)
            if hubname == '':
                # construct file name from buil list if no hub name provided
                buillist = '-'.join(filter(None,[buillist,buil_no]))
            flag = True
        else:
            print(f'Not found: {MID}')

    if flag:
        fno = '_'.join(filter(None,[stag,buillist,hubname,util])) + '.xlsx'
            # file name output; either buillist or hubname would be '' and omitted
            #   example using building list: 'base_1045-1380_coo.xlsx'
            #   example using hub name: 'base_medical_coo.xlsx'
        df.to_excel(os.path.join(dirWritSymp,fno),
                    engine = 'xlsxwriter',
                    header = False,
                    index = False)
        print(f'Output file generated: {fno}')
    else:
        print('No meter found. No output file generated.')

#%% Preprocessing
flag_deleteOldDirectory = True
if flag_deleteOldDirectory:
    shutil.rmtree(dirWritSymp)
    os.makedirs(dirWritSymp, exist_ok = True)

#%% Example call
"""
main('base', 'ele', ['1380','1045'])
"""

#%% Each building
for stag, util, buil_no in [(stag, util, buil_no) for stag in stags for util in utils for buil_no in buil_nos]:
    main(stag=stag, util=util, buil_nos=[buil_no])

for stag, buil_no in [(stag, buil_no) for stag in stags for buil_no in buil_nos]:
    for util in utils:
        main(stag=stag, util=util, buil_nos=[buil_no])

#%% Hub list
#%% Customary list
"""
# validation
hub_dict = {'1058x1060':['1058x1060'],
            '1065':['1065'],
            'medical':['1058x1060','1065']}
for hubname in hub_dict:
    main('base','ele',buil_nos=hub_dict[hubname],hubname=hubname)

"""
stag = 'post' # 'base' baseline or 'post' post-stagofit
hub_dict = {'medical':['1058x1060','1065'],
            'dorm':['1631','1657','1690','1691','1692']}
for hubname in hub_dict:
    for util in utils:
        main(stag=stag,util=util,buil_nos=hub_dict[hubname],hubname=hubname)

#%% Shell interface with argparse
"""
parser = argparse.ArgumentParser()
parser.add_argument('r',
                    type = str,
                    choices = ['base', 'post'],
                    help = 'retrofit status, {base, post}')
parser.add_argument('u',
                    type = str,
                    choices = utils,
                    help = 'type of utility, {ele, coo, hea, dhw}')
parser.add_argument('b',
                    nargs='+',
                    type = str,
                    choices = buil_nos,
                    help = '4-digit building number or \'1058x1060\'')
args = parser.parse_args()

main(args.r, args.u, args.b)
"""