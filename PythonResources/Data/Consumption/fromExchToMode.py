#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 12 13:52:38 2024

@author: casper

This file converts the energy consumption profiles in the csv exchange files
    to Modelica input mos files.
The mos files are generated at four levels of grouping indicated in the file name:
    1. B0000.mos is for a single building, e.g. B1380.
        Note that the medical complex B1058x1060 is considered one building.
    2. H00.mos is for a hub used in MILP, e.g. H04 = B1690 + B1691 + B1692.
    3. CX.mos is for a cluster, which is intended to limit the number of ETS
        to keep the computation tractable, e.g. CA = H01 + H14 = B1500 + B1345.
    4. All.mos is for all buildings combined.
    
"""

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
        MID_coo = f'futu_{buil_no}_coo'
        df['coo'] = df['coo'] - np.array(readMID(MID_coo)) * 1000
        MID_hea = f'futu_{buil_no}_hea'
        df['hea'] = df['hea'] + np.array(readMID(MID_hea)) * 1000
        MID_dhw = f'futu_{buil_no}_dhw'
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
        
        # weather file name
        f.write('#\n')
        f.write(f'#Weather file name = "{weatherfile["futu"]}"\n')
        
        # data
        f.write('double tab1(8760,4)\n')
        f.write(df.to_csv(path_or_buf=None,
                          header=None,
                          index=False,
                          float_format='%.0f'))
        
        print(f'Output file generated: {fno}')

#%% Preprocessing
flag_deleteOldDirectory = True
if flag_deleteOldDirectory:
    shutil.rmtree(dirWritMode)
    os.makedirs(dirWritMode, exist_ok = True)

# list of hubs
dict_hub = {'H01' : ['1500'],
            'H02' : ['1560'],
            'H03' : ['1569'],
            'H04' : ['1690', '1691', '1692'],
            'H05' : ['1800'],
            'H06' : ['1676'],
            'H07' : ['1657'],
            'H08' : ['1631'],
            'H09' : ['1359', '1380'],
            'H10' : ['1045'],
            'H11' : ['1065'],
            'H12' : ['1058x1060'],
            'H13' : ['1349'],
            'H14' : ['1345']}

# list of clusters
dict_clu = {'CA' : ['1345', '1500'],
            'CB' : ['1349', '1058x1060'],
            'CC' : ['1045', '1065'],
            'CD' : ['1359', '1380'],
            'CE' : ['1560', '1569', '1631', '1657', '1676', '1690', '1691', '1692', '1800']}


#%% Example call

#main(['1560'])


#%% Generate files

# 1. individual buildings
for buil_no in buil_nos:
    main([buil_no],f'B{buil_no}')

# 2. hubs as used in MILP
for hub, buils in dict_hub.items():
    main(buils, hub)

# 3. clusters as needed for Modelica
for hub, buils in dict_clu.items():
    main(buils, hub)

# 4. all buildings combined
main(buil_nos, "All")
