# Python script converting
#   the exchange csv file
#   to Sympheny input xlsx files.
# It is interfaced with the shell using argparse.

import os
import argparse
import shutil

import numpy as np
import pandas as pd

from _config_estcp import *

#%% Main function
def main(sRet: str, sUti: str, sBuis, sHub = ''):

    df = pd.DataFrame({'row' : np.linspace(1,8760,8760,dtype = int),
                       'value' : np.zeros(8760)})
    sBuiLis = '' # building list, remains '' if hub name sHub provided
    
    flag = False # flag when data found to generate output files
    for sBui in sBuis:
        MID = f'{sRet}_{sBui}_{sUti}' # meter ID
        fni = os.path.join(dirExch, f'{MID}.csv')
        if os.path.isfile(fni):
            df['value'] = df['value'] + readMID(MID)
            if sHub == '':
                # construct file name from bldg list if no hub name provided
                sBuiLis = '-'.join(filter(None,[sBuiLis,sBui]))
            flag = True
        else:
            print(f'Not found: {MID}')

    if flag:
        fno = '_'.join(filter(None,[sRet,sBuiLis,sHub,sUti])) + '.xlsx'
            # file name output; either sBuiLis or sHub would be '' and omitted
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
    os.makedirs(dirWritSymp)

#%% Example call
"""
main('base', 'ele', ['1380','1045'])
"""

#%% Hub list
"""
# validation
dictHubs = {'1058x1060':['1058x1060'],
            '1065':['1065'],
            'medical':['1058x1060','1065']}
for sHub in dictHubs:
    main('base','ele',sBuis=dictHubs[sHub],sHub=sHub)

"""
sRet = 'base' # 'base' baseline or 'post' post-retrofit
dictHubs = {'medical':['1058x1060','1065'],
            'dorm':['1631','1657','1690','1691','1692']}
for sHub in dictHubs:
    for sUti in sUtis:
        main('base',sUti,sBuis=dictHubs[sHub],sHub=sHub)

#%% Shell interface with argparse
"""
parser = argparse.ArgumentParser()
parser.add_argument('r',
                    type = str,
                    choices = ['base', 'post'],
                    help = 'retrofit status, {base, post}')
parser.add_argument('u',
                    type = str,
                    choices = sUtis,
                    help = 'type of utility, {ele, coo, hea, dhw}')
parser.add_argument('b',
                    nargs='+',
                    type = str,
                    choices = sBuis,
                    help = '4-digit building number or \'1058x1060\'')
args = parser.parse_args()

main(args.r, args.u, args.b)
"""