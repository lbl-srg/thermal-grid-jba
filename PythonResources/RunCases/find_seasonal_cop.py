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
import sdf
from buildingspy.io.outputfile import Reader

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))

PRINT_RESULTS = True
WRITE_TO_XLSX = True
PATH_XLSX = os.path.join(CWD, "seasonal_cop.xlsx")
# CASE_LIST = ["ETS_All_futu",
#             "cluster_A_futu",
#             "cluster_B_futu",
#             "cluster_C_futu",
#             "cluster_D_futu",
#             "cluster_E_futu"]
# CASE_LIST = [os.path.join("seasonal_cop", "ETS_All_futu")]
CASE_LIST = [os.path.join("2025-05-05-simulations", "detailed_plant_five_hubs_futu")]
nBui = 5

#%% Generate variable list
def generate_indexed_var_list(pre_index, holder, i):
    """ Replaces the `holder` string in `pre_index` with index `i`.
        Both `pre_index` and `i` can be either a single value or a list.
    """
    
    _pre_index = [pre_index] if isinstance(pre_index, str) else pre_index
    _i = [i] if isinstance(i, int) else i
    
    var_list = list()
    for pre, ind in [(pre, ind) for pre in _pre_index for ind in _i]:
        var_list.append(pre.replace(holder,str(ind)))
        
    return var_list
    
#var_list_pre_index = list()
index_holder = r'%%i%%' # placeholder string to be replaced with index

# keys are the var names to be read from the result file
# values are their corresponding short nicknames
var_dict_pre_index = {
    f'bui[{index_holder}].ets.chi.chi.COP'       : 'COP',
    f'bui[{index_holder}].ets.chi.uCoo'          : 'uCoo',
    f'bui[{index_holder}].ets.chi.uHea'          : 'uHea',
    f'bui[{index_holder}].ets.chi.chi.QCon_flow' : 'QCon',     # chiller condenser heat, W
    f'bui[{index_holder}].ets.chi.chi.P'         : 'PChi',     # chiller electric input, W
    f'bui[{index_holder}].ets.chi.senTEvaEnt.T'  : 'TEvaEnt',  # K
    f'bui[{index_holder}].ets.chi.senTEvaLvg.T'  : 'TEvaLvg',  # K
    f'bui[{index_holder}].ets.chi.senTConEnt.T'  : 'TConEnt',  # K
    f'bui[{index_holder}].ets.chi.senTConLvg.T'  : 'TConLvg'   # K
    }

var_list_pre_index = list(var_dict_pre_index.keys())

var_list = generate_indexed_var_list(var_list_pre_index, index_holder, range(1,nBui+1))

#%% Generate Dymola command to export csv from large mat file
def generate_dymola_command(var_list, mat_file_path, csv_file_path):
    
    s = ''
    s += f'DataFiles.convertMATtoCSV("{mat_file_path}", '
    s += '{"'
    s += '","'.join(var_list)
    s += '"}, '
    s += f'"{csv_file_path}");'
        
    return s    
    # __ref = r'DataFiles.convertMATtoCSV("/home/casper/gitRepo/thermal-grid-jba/PythonResources/RunCases/simulations/2025-05-05-simulations/detailed_plant_five_hubs_futu/DetailedPlantFiveHubs.mat", {"bui[1].ets.chi.chi.COP","bui[1].ets.chi.uCoo"}, "/home/casper/gitRepo/thermal-grid-jba/PythonResources/RunCases/simulations/2025-05-05-simulations/detailed_plant_five_hubs_futu/trimmed.csv");'

mat_file_name = "/home/casper/gitRepo/thermal-grid-jba/PythonResources/RunCases/simulations/2025-05-05-simulations/detailed_plant_five_hubs_futu/DetailedPlantFiveHubs.mat"
csv_file_name = "/home/casper/gitRepo/thermal-grid-jba/PythonResources/RunCases/simulations/2025-05-05-simulations/detailed_plant_five_hubs_futu/DetailedPlantFiveHubs.csv"

dymola_command = generate_dymola_command(var_list,
                                         mat_file_name,
                                         csv_file_name)

#%% Read exported result csv file
result_full = pd.read_csv(csv_file_name, header = 0)
    
# Convert the timestamp to datetime format
result_full['datetime'] = pd.to_datetime(result_full['Time'], unit='s', origin='2025-01-01')

#%% 

# for cas in CASE_LIST:

    # mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", cas, "ConnectedETSWithDHW.mat"))
    # mat_file_path = os.path.realpath(glob.glob(os.path.join(CWD, "simulations", cas, "*.mat"))[0])
    
    # r=Reader(mat_file_path, 'dymola')
    # sdfData = sdf.load(mat_file_path)
    
    # i = 1
    
    # (t, COP) = r.values('bui[i].ets.chi.chi.COP')
    # (t, uCoo) = r.values('bui[i].ets.chi.uCoo')
    # (t, uHea) = r.values('bui[i].ets.chi.uHea')
    # (t, QCon) = r.values('bui[i].ets.chi.chi.QCon_flow')  # chiller condenser heat, W
    # (t, PChi) = r.values('bui[i].ets.chi.chi.P')          # chiller electric input, W
    # (t, TEvaEnt) = r.values('bui[i].ets.chi.senTEvaEnt.T') # K
    # (t, TEvaLvg) = r.values('bui[i].ets.chi.senTEvaLvg.T') # K
    # (t, TConEnt) = r.values('bui[i].ets.chi.senTConEnt.T') # K
    # (t, TConLvg) = r.values('bui[i].ets.chi.senTConLvg.T') # K
    
    # data = pd.DataFrame({'t': t,
    #                      'COP': COP,
    #                      'uCoo': uCoo,
    #                      'uHea': uHea,
    #                      'QCon': QCon,
    #                      'PChi': PChi,
    #                      'TEvaEnt' : TEvaEnt,
    #                      'TEvaLvg' : TEvaLvg,
    #                      'TConEnt' : TConEnt,
    #                      'TConLvg' : TConLvg})

#%% Crunch data for each building index

if WRITE_TO_XLSX:
    w = pd.ExcelWriter(PATH_XLSX, engine='xlsxwriter')
    
#for i in range(1,nBui+1):
for i in [1]:
    # initialise list
    var_list_bui = ['Time', 'datetime'] # initialise
    # indexed var names for this building
    var_list_bui += generate_indexed_var_list(var_list_pre_index, index_holder, i)
    result_bui = result_full[var_list_bui]
    # dict for renaming pd columns
    var_dict_indexed = {key.replace(index_holder, str(i)): value for key, value in var_dict_pre_index.items()}
    result_bui = result_bui.rename(columns=var_dict_indexed)
    
    # Filter
    result_bui = result_bui[result_bui['COP'] > 0.01] # only when chiller on
    result_bui = result_bui[result_bui['COP'] < 15.0] # remove transient at initialisation
    result_bui = result_bui[np.isclose(result_bui['Time'] % 3600, 0)] # only keep hourly sampled values
    result_bui = result_bui.iloc[:-1] # drop the last point which would be categorised to the next year
    
    # Section the data to each calendar month
    result_bui['month'] = result_bui['datetime'].dt.to_period('M')
    
    # Filter data based on operational modes
    conditions = [
        (result_bui['uCoo'] == 1) & (result_bui['uHea'] == 1),
        (result_bui['uCoo'] == 1) & (result_bui['uHea'] == 0),
        (result_bui['uCoo'] == 0) & (result_bui['uHea'] == 1)
                  ]
    modes = ['simultaneous', 'coolingonly', 'heatingonly']
    result_bui['mode'] = np.select(conditions, modes, default='other')
    
    # Group by month and mode
    grouped = result_bui.groupby(['month', 'mode'])
    
    # Calculate COP_mon, averages, and size for each group
    cop_mon_results = []
    for (month, mode), group in grouped:
        QCon_sum = group['QCon'].sum()
        PChi_sum = group['PChi'].sum()
        
        if PChi_sum != 0:
            COP_mon = QCon_sum / PChi_sum
        else:
            COP_mon = np.nan
        
        TEvaEnt_avg = group['TEvaEnt'].mean()
        TEvaLvg_avg = group['TEvaLvg'].mean()
        TConEnt_avg = group['TConEnt'].mean()
        TConLvg_avg = group['TConLvg'].mean()
        size = len(group)
        
        cop_mon_results.append((month, mode, COP_mon, TEvaEnt_avg, TEvaLvg_avg, TConEnt_avg, TConLvg_avg, size))
    
    list_value = ['COP_mon', 'TEvaEnt_avg|K', 'TEvaLvg_avg|K', 'TConEnt_avg|K', 'TConLvg_avg|K', 'size|h']
    
    cop_mon_df = pd.DataFrame(cop_mon_results, columns=['month', 'mode'] + list_value)
    
    # Convert the 'month' column to abbreviated month names
    cop_mon_df['month'] = cop_mon_df['month'].dt.strftime('%b')
    
    # Pivot the DataFrame
    cop_mon_df_pivot = cop_mon_df.pivot_table(
        index='month',
        columns='mode',
        values=list_value,
        aggfunc='first'
    ).swaplevel(axis=1).sort_index(axis=1)
    
    # Calculate COP, averages, and size for the entire dataset for each mode
    overall_cop_results = []
    for mode in modes:
        QCon_sum = result_bui[result_bui['mode'] == mode]['QCon'].sum()
        PChi_sum = result_bui[result_bui['mode'] == mode]['PChi'].sum()
        
        if PChi_sum != 0:
            COP_overall = QCon_sum / PChi_sum
        else:
            COP_overall = np.nan  # or some other value indicating undefined COP
        
        TEvaEnt_avg = result_bui[result_bui['mode'] == mode]['TEvaEnt'].mean()
        TEvaLvg_avg = result_bui[result_bui['mode'] == mode]['TEvaLvg'].mean()
        TConEnt_avg = result_bui[result_bui['mode'] == mode]['TConEnt'].mean()
        TConLvg_avg = result_bui[result_bui['mode'] == mode]['TConLvg'].mean()
        size = len(result_bui[result_bui['mode'] == mode])
        
        overall_cop_results.append((mode, COP_overall, TEvaEnt_avg, TEvaLvg_avg, TConEnt_avg, TConLvg_avg, size))
    
    overall_cop_df = pd.DataFrame(overall_cop_results, columns=['mode'] + list_value)
    
    if PRINT_RESULTS:
        print(f"Results for ETS #{i}:")
        print("Monthly COP:")
        print(cop_mon_df_pivot)
        print("\nOverall COP:")
        print(overall_cop_df)
    
    if WRITE_TO_XLSX:
        #sheet_name = cas.split(os.sep)[-1]
        sheet_name = f'ETS_{i}'
        cop_mon_df_pivot.to_excel(w, sheet_name=f'{sheet_name}_monthly', index=True)
        overall_cop_df.to_excel(w, sheet_name=f'{sheet_name}_overall', index=False)

if WRITE_TO_XLSX:
    w.close()
    print(f"Results wrote to {PATH_XLSX}.")