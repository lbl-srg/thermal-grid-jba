#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 11 11:50:10 2025

@author: casper
"""

import os
import glob
import pandas as pd
import numpy as np
from buildingspy.io.outputfile import Reader

CWD = os.getcwd()

PRINT_RESULTS = False
WRITE_TO_XLSX = True
PATH_XLSX = os.path.join(CWD, "seasonal_cop.xlsx")
# CASE_LIST = ["ETS_All_futu",
#             "cluster_A_futu",
#             "cluster_B_futu",
#             "cluster_C_futu",
#             "cluster_D_futu",
#             "cluster_E_futu"]
CASE_LIST = [os.path.join("seasonal_cop", "ETS_All_futu")]

#%%
if WRITE_TO_XLSX:
    w = pd.ExcelWriter(PATH_XLSX, engine='xlsxwriter')

for cas in CASE_LIST:

    # mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", cas, "ConnectedETSWithDHW.mat"))
    mat_file_path = os.path.realpath(glob.glob(os.path.join(CWD, "simulations", cas, "*.mat"))[0])
    
    r=Reader(mat_file_path, 'dymola')
    
    (t, COP) = r.values('bui.ets.chi.chi.COP')
    (t, uCoo) = r.values('bui.ets.chi.uCoo')
    (t, uHea) = r.values('bui.ets.chi.uHea')
    (t, TEvaEnt) = r.values('bui.ets.chi.senTEvaEnt.T')
    (t, TEvaLvg) = r.values('bui.ets.chi.senTEvaLvg.T')
    (t, TConEnt) = r.values('bui.ets.chi.senTConEnt.T')
    (t, TConLvg) = r.values('bui.ets.chi.senTConLvg.T')
    
    data = pd.DataFrame({'t': t,
                         'COP': COP,
                         'uCoo': uCoo,
                         'uHea': uHea,
                         'TEvaEnt' : TEvaEnt,
                         'TEvaLvg' : TEvaLvg,
                         'TConEnt' : TConEnt,
                         'TConLvg' : TConLvg})
    
    # Convert the timestamp to datetime format
    data['datetime'] = pd.to_datetime(data['t'], unit='s', origin='2025-01-01')
    
    # Filter
    data = data[data['COP'] > 0.01]
    data = data[data['COP'] < 15.0] # start up transient
    data = data[np.isclose(data['t'] % 3600, 0)] # only keep hourly sampled values
    data = data.iloc[:-1] # drop the last point which would be categorised to the next year
    
    # Section the data to each calendar month
    data['month'] = data['datetime'].dt.to_period('M')
    
    # Filter data based on operational modes
    conditions = [
        (data['uCoo'] == 1) & (data['uHea'] == 1),
        (data['uCoo'] == 1) & (data['uHea'] == 0),
        (data['uCoo'] == 0) & (data['uHea'] == 1)
                  ]
    modes = ['simultaneous', 'coolingonly', 'heatingonly']
    data['mode'] = np.select(conditions, modes, default='other')
    
    # Calculate the average of the specified columns by month and mode
    avg_data = data.groupby(['month', 'mode'])[['COP', 'TEvaEnt', 'TEvaLvg', 'TConEnt', 'TConLvg']].mean().unstack(fill_value=np.nan)
    
    # Count the number of occurrences of each month & mode combination
    count_data = data.groupby(['month', 'mode']).size().unstack(fill_value=0)
    
    avg_data.index = avg_data.index.strftime('%B')
    count_data.index = count_data.index.strftime('%B')
    
    if PRINT_RESULTS:
        print('='*10)
        print(cas)
        print(avg_data)
        print('')
        print(count_data)
    
    if WRITE_TO_XLSX:
        sheet_name = cas.split(os.sep)[-1]
        avg_data.to_excel(w, sheet_name=f'{sheet_name}_cop')
        count_data.to_excel(w, sheet_name=f'{sheet_name}_hours')

if WRITE_TO_XLSX:
    w.close()
    print(f"Results wrote to {PATH_XLSX}.")