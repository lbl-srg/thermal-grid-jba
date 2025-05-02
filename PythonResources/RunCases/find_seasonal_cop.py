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
    (t, QCon) = r.values('bui.ets.chi.chi.QCon_flow')  # chiller condenser heat, W
    (t, PChi) = r.values('bui.ets.chi.chi.P')          # chiller electric input, W
    (t, TEvaEnt) = r.values('bui.ets.chi.senTEvaEnt.T') # K
    (t, TEvaLvg) = r.values('bui.ets.chi.senTEvaLvg.T') # K
    (t, TConEnt) = r.values('bui.ets.chi.senTConEnt.T') # K
    (t, TConLvg) = r.values('bui.ets.chi.senTConLvg.T') # K
    
    data = pd.DataFrame({'t': t,
                         'COP': COP,
                         'uCoo': uCoo,
                         'uHea': uHea,
                         'QCon': QCon,
                         'PChi': PChi,
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
    
    # Group by month and mode
    grouped = data.groupby(['month', 'mode'])
    
    # Calculate COP_mon, averages, and size for each group
    cop_mon_results = []
    for (month, mode), group in grouped:
        QCon_sum = group['QCon'].sum()
        PChi_sum = group['PChi'].sum()
        
        if PChi_sum != 0:
            COP_mon = QCon_sum / PChi_sum
        else:
            COP_mon = np.nan  # or some other value indicating undefined COP
        
        TEvaEnt_avg = group['TEvaEnt'].mean()
        TEvaLvg_avg = group['TEvaLvg'].mean()
        TConEnt_avg = group['TConEnt'].mean()
        TConLvg_avg = group['TConLvg'].mean()
        size = len(group)
        
        cop_mon_results.append((month, mode, COP_mon, TEvaEnt_avg, TEvaLvg_avg, TConEnt_avg, TConLvg_avg, size))
    
    cop_mon_df = pd.DataFrame(cop_mon_results, columns=['month', 'mode', 'COP_mon', 'TEvaEnt_avg', 'TEvaLvg_avg', 'TConEnt_avg', 'TConLvg_avg', 'size'])
    
    # Calculate COP, averages, and size for the entire dataset for each mode
    overall_cop_results = []
    for mode in modes:
        QCon_sum = data[data['mode'] == mode]['QCon'].sum()
        PChi_sum = data[data['mode'] == mode]['PChi'].sum()
        
        if PChi_sum != 0:
            COP_overall = QCon_sum / PChi_sum
        else:
            COP_overall = np.nan  # or some other value indicating undefined COP
        
        TEvaEnt_avg = data[data['mode'] == mode]['TEvaEnt'].mean()
        TEvaLvg_avg = data[data['mode'] == mode]['TEvaLvg'].mean()
        TConEnt_avg = data[data['mode'] == mode]['TConEnt'].mean()
        TConLvg_avg = data[data['mode'] == mode]['TConLvg'].mean()
        size = len(data[data['mode'] == mode])
        
        overall_cop_results.append((mode, COP_overall, TEvaEnt_avg, TEvaLvg_avg, TConEnt_avg, TConLvg_avg, size))
    
    overall_cop_df = pd.DataFrame(overall_cop_results, columns=['mode', 'COP_overall', 'TEvaEnt_avg', 'TEvaLvg_avg', 'TConEnt_avg', 'TConLvg_avg', 'size'])
    
    if PRINT_RESULTS:
        print(f"Results for case {cas}:")
        print("Monthly COP:")
        print(cop_mon_df)
        print("\nOverall COP:")
        print(overall_cop_df)
    
    if WRITE_TO_XLSX:
        sheet_name = cas.split(os.sep)[-1]
        cop_mon_df.to_excel(w, sheet_name=f'{sheet_name}_monthly', index=False)
        overall_cop_df.to_excel(w, sheet_name=f'{sheet_name}_overall', index=False)

if WRITE_TO_XLSX:
    w.close()
    print(f"Results wrote to {PATH_XLSX}.")