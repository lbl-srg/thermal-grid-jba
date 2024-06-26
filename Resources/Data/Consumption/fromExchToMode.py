#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 12 13:52:38 2024

@author: casper
"""

# Python script converting
#   the exchange csv file
#   to Modelica input mos files.

from _config_estcp import * # This imports os and pandas as pd

import shutil

import numpy as np

#%% Main function
def main(buil_nos, hubname = ''):

    df = pd.DataFrame({'time' : np.linspace(0,8759,8760,dtype = float)*3600,
                       'coo' : np.zeros(8760),
                       'hea' : np.zeros(8760),
                       'dhw' : np.zeros(8760)})
    buillist = '' # building list, remains '' if hub name hubname provided
    
    flag = False # flag when data found to generate output files
    #for buil_no, util in [(buil_no, util) for buil_no in buil_nos for util in utils]:
    for buil_no in buil_nos:
        MID_coo = f'post_{buil_no}_coo'
        df['coo'] = df['coo'] - np.array(readMID(MID_coo)) * 1000
        MID_hea = f'post_{buil_no}_hea'
        df['hea'] = df['hea'] + np.array(readMID(MID_hea)) * 1000
        MID_dhw = f'post_{buil_no}_dhw'
        if os.path.isfile(os.path.join(dirExch, f'{MID_dhw}.csv')):
            df['dhw'] = df['dhw'] + np.array(readMID(MID_dhw)) * 1000        
        
        # MID = f'{stag}_{buil_no}_{util}' # meter ID
        # fni = os.path.join(dirExch, f'{MID}.csv')
        # if os.path.isfile(fni):
        #     df['value'] = df['value'] + readMID(MID)

        #     flag = True
        # else:
        #     print(f'Not found: {MID}')

    if hubname == '':
        # construct file name from buil list if no hub name provided
        buillist = '-'.join(filter(None,[buillist,buil_no]))
    fno = '_'.join(filter(None,[buillist,hubname])) + '.mos'
        # file name output; either buillist or hubname would be '' and omitted
        
    # df.to_excel(os.path.join(dirWritSymp,fno),
    #             engine = 'xlsxwriter',
    #             header = False,
    #             index = False)
    # print(f'Output file generated: {fno}')

    with open(os.path.join(dirWritMode,fno), 'w') as f:
        # head
        f.write('''#1
#
#First column: Seconds in the year (loads are hourly)
#Second column: cooling loads in Watts (as negative numbers).
#Third column: space heating loads in Watts
#Fourth column: domestic water heating loads in Watts\n''')
        
        # peak
        f.write('#\n')
        f.write(f'#Peak space cooling load = {min(df["coo"]):.0f} Watts\n')
        f.write(f'#Peak space heating load = {max(df["hea"]):.0f} Watts\n')
        f.write(f'#Peak water heating load = {max(df["dhw"]):.0f} Watts\n')

        # data
        f.write('double tab1(8760,4)\n')
        f.write(df.to_csv(path_or_buf=None,
                          header=None,
                          index=False,
                          float_format='%.0f'))
        
        print(f'Output file generated: {fno}')

#%% Preprocessing
flag_deleteOldDirectory = False
if flag_deleteOldDirectory:
    shutil.rmtree(dirWritMode)
    os.makedirs(dirWritMode, exist_ok = True)

#%% Example call

#main(['1560'])


#%% Individual files for each building

for buil_no in buil_nos:
    main([buil_no])
