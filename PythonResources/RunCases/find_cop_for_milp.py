#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 11 11:50:10 2025

@author: casper
"""

import os
#import glob
import pandas as pd
import numpy as np
#from buildingspy.io.outputfile import Reader
from scipy import trapz

# Dymola-python interface: see Dymola user manual 12.3
from dymola.dymola_interface import DymolaInterface
# Install this with
#    <...>/Dymola-2025x-x86_64/Modelica/Library/python_interface/dymola-2024.1-py3-none-any.whl
dymola = DymolaInterface("/usr/local/bin/dymola")
# Replace the argument with the location of your Dymola excecutable.

from GetVariables import get_vars, index_var_list
# python file under same folder

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))
#mat_file_name = os.path.join(CWD, "simulations", "2025-05-05-simulations", "detailed_plant_five_hubs_futu", "DetailedPlantFiveHubs.mat")
mat_file_name = os.path.join(CWD, "simulations", "2025-05-25", "DetailedPlantFiveHubs.mat")

PRINT_RESULTS = False
WRITE_TO_XLSX = True
PATH_XLSX = os.path.join(CWD, "cop_for_milp.xlsx")
nBui = 5

# remarks to be written to the output file
WRITE_REMARKS = True

def get_commit_hash():
    import git
    repo = git.Repo(search_parent_directories=True)
    sha = repo.head.object.hexsha
    return sha

if WRITE_REMARKS:
    remarks = pd.DataFrame(np.array([['Model', 'ThermalGridJBA.Networks.Validation.DetailedPlantFiveHubs'],
                                     ['Weather scenario', 'fTMY'],
                                     ['Result file at commit', '343b6a5a47399dbee9441f1aaf96fb83d38b8aa6'],
                                     ['This file generated at commit', get_commit_hash()]]))

def safe_cop(QCon, PChi):
    """ Returns nan if PChi == 0.
          This is needed because not all operational modes are present
          in all months.
    """
    if PChi > 0.01:
        COP = QCon / PChi
    else:
        COP = np.nan
    
    return COP

#%% Copied from make_sankey.py
def integrate_with_condition(df, var, sign = None, condition = None):
    """ Integrates df[var] along df['Time']
        `sign` can be the following (case insensitive):
            'positive' - Only integrates positive values of u,
                           zero crossing points are found linearly and inserted
                           to the series.
            'negative' - Similar to above but negative.
        `condition` is a Boolean array.
            Only integrates u where condition is True,
            when `condition` flips from True at t1 to False at t2,
              a point (t2, 0) is inserted after (t2, u2) to create a step down;
            when `condition` flips from False at t3 to True at t4,
              a point (t4, 0) is inserted before (t4, u4) to create a step up;
            set u = 0 for all points between t2 and t3.
                           
    """
    
    u = np.array(df[var])
    t = np.array(df['Time'])
    
    # `condition` must to be evaluated before `sign`
    #   because it relies on the original array length
    #   and both `condition` and `sign` may add elements to the array.
    if not condition is None:
        
        _t = []
        _u = []
        i = 0
        
        while i < len(t) - 1:
            _t.append(t[i])
            
            if condition[i] and not condition[i + 1]:
                # creates a step down at True to False
                _t.append(t[i+1])
                _u.append(u[i])
                _u.append(0.)
        
            elif not condition[i] and condition[i + 1]:
                # creates a step up at False to True
                _t.append(t[i+1])
                _u.append(0.)
                _u.append(u[i+1])
        
            else:
                if condition[i]:
                    _u.append(u[i])
                else:
                    _u.append(0.)
            i += 1
        
        # last point
        _t.append(t[i])
        _u.append(u[i])
        
        t = _t
        u = _u
    
    def find_zero_crossings(t, u):
        """ Find indices where the sign of u changes
        """
        sign_changes = np.where(np.diff(np.sign(u)))[0]
        
        # Initialize lists to store zero crossing times and values
        zero_crossing_times = []
        zero_crossing_values = []
    
        for i in sign_changes:
            # Perform linear interpolation to find the exact zero crossing time
            t1, t2 = t[i], t[i + 1]
            u1, u2 = u[i], u[i + 1]
            
            # Calculate the zero crossing time
            t_zero = t1 - u1 * (t2 - t1) / (u2 - u1)
            u_zero = 0.0
            
            # Append the zero crossing time and value to the lists
            zero_crossing_times.append(t_zero)
            zero_crossing_values.append(u_zero)
    
        return zero_crossing_times, zero_crossing_values
    
    if sign in ['positive', 'negative']:
        t_crossing, u_crossing = find_zero_crossings(t, u)
        # Insert zero crossings into the original time series
        for t_zero, u_zero in zip(t_crossing, u_crossing):
            idx = np.searchsorted(t, t_zero)
            t = np.insert(t, idx, t_zero)
            u = np.insert(u, idx, u_zero)
        
        if sign == 'positive':
            u[u<0] = 0
        if sign == 'negative':
            u[u>0] = 0
        
    I = trapz(u, t)
    return I

#%% Generate variable list
index_holder = r'%%i%%' # placeholder string to be replaced with index

# keys are the var names to be read from the result file
# values are their corresponding short nicknames
var_dict_pre_index = {
    f'bui[{index_holder}].ets.chi.chi.COP'       : 'COP',      # not directly used for taking average
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

var_list = index_var_list(var_list_pre_index, index_holder, range(1,nBui+1))

#%% Read mat file
result_full = get_vars(var_list,
                       mat_file_name,
                       'dymola')

# Convert the timestamp to datetime format
result_full['datetime'] = pd.to_datetime(result_full['Time'], unit='s', origin='2025-01-01')

#%% Crunch data for each building index

if WRITE_TO_XLSX:
    w = pd.ExcelWriter(PATH_XLSX, engine='xlsxwriter')

month_order = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
all_sums = {}
for i in range(1,nBui+1):
#for i in [1]:
    # initialise list
    var_list_bui = ['Time', 'datetime'] # initialise
    
    # indexed var names for this building
    var_list_bui += index_var_list(var_list_pre_index, index_holder, i)
    result_bui = result_full[var_list_bui]
    
    # dict for renaming pd columns
    var_dict_indexed = {key.replace(index_holder, str(i)): value for key, value in var_dict_pre_index.items()}
    result_bui = result_bui.rename(columns=var_dict_indexed)
    
    # Filter
    #result_bui = result_bui[result_bui['COP'] > 0.01] # only when chiller on
    result_bui = result_bui[result_bui['COP'] < 15.0] # remove transient at initialisation
    #result_bui = result_bui[np.isclose(result_bui['Time'] % 3600, 0)] # only keep hourly sampled values
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
    
    # Monthly
    grouped = result_bui.groupby(['month', 'mode'])
    
    cop_mon_results = []
    for (month, mode), group in grouped:
        # QCon_sum = group['QCon'].sum()
        # PChi_sum = group['PChi'].sum()
        
        if mode == 'other':
            continue
        
        condition = np.array(np.logical_and(result_bui['month'] == month,
                                            result_bui['mode'] == mode))
        QCon_sum = integrate_with_condition(result_bui, 'QCon',
                                            sign = None,
                                            condition = condition)
        PChi_sum = integrate_with_condition(result_bui, 'PChi',
                                            sign = None,
                                            condition = condition)
        
        if (month, mode) not in all_sums:
            all_sums[(month, mode)] = {'QCon': 0, 'PChi': 0}
        all_sums[(month, mode)]['QCon'] += QCon_sum
        all_sums[(month, mode)]['PChi'] += PChi_sum
        
        COP_mon = safe_cop(QCon_sum,PChi_sum)
        
        TEvaEnt_avg = group['TEvaEnt'].mean() - 273.15
        TEvaLvg_avg = group['TEvaLvg'].mean() - 273.15
        TConEnt_avg = group['TConEnt'].mean() - 273.15
        TConLvg_avg = group['TConLvg'].mean() - 273.15
        duration = len(group)
        
        cop_mon_results.append((month, mode, COP_mon, TEvaEnt_avg, TEvaLvg_avg, TConEnt_avg, TConLvg_avg, duration))
    
    column_names = ['COP_h', 'TEvaEnt_avg|C', 'TEvaLvg_avg|C', 'TConEnt_avg|C', 'TConLvg_avg|C', 'Duration|h']
    
    cop_mon_df = pd.DataFrame(cop_mon_results, columns=['month', 'mode'] + column_names)
    
    # Convert the 'month' column to abbreviated month names and order it
    cop_mon_df['month'] = cop_mon_df['month'].dt.strftime('%b')
    cop_mon_df['month'] = pd.Categorical(cop_mon_df['month'], categories=month_order, ordered=True)
    
    # Pivot the DataFrame
    cop_mon_df_pivot = cop_mon_df.pivot_table(
        index='month',
        columns='mode',
        values=column_names,
        aggfunc='first'
    ).swaplevel(axis=1).sort_index(axis=1)
    
    # Annual
    cop_ann_results = []
    for mode in modes:
        QCon_sum = result_bui[result_bui['mode'] == mode]['QCon'].sum()
        PChi_sum = result_bui[result_bui['mode'] == mode]['PChi'].sum()
        
        COP_ann = safe_cop(QCon_sum, PChi_sum)
        
        TEvaEnt_avg = result_bui[result_bui['mode'] == mode]['TEvaEnt'].mean() - 273.15
        TEvaLvg_avg = result_bui[result_bui['mode'] == mode]['TEvaLvg'].mean() - 273.15
        TConEnt_avg = result_bui[result_bui['mode'] == mode]['TConEnt'].mean() - 273.15
        TConLvg_avg = result_bui[result_bui['mode'] == mode]['TConLvg'].mean() - 273.15
        duration = len(result_bui[result_bui['mode'] == mode])
        
        cop_ann_results.append((mode, COP_ann, TEvaEnt_avg, TEvaLvg_avg, TConEnt_avg, TConLvg_avg, duration))
    
    cop_ann_df = pd.DataFrame(cop_ann_results, columns=['mode'] + column_names)
    
    if PRINT_RESULTS:
        print(f"Results for ETS #{i}:")
        print("Monthly COP:")
        print(cop_mon_df_pivot)
        print("\nAnnual COP:")
        print(cop_ann_df)
    
    if WRITE_TO_XLSX:
        sheet_name = f'ETS_{i}'
        cop_mon_df_pivot.to_excel(w, sheet_name=f'{sheet_name}_monthly', index=True)
        cop_ann_df.to_excel(w, sheet_name=f'{sheet_name}_annual', index=False)

# Compute all-building COP for each month and mode, also whole-year by mode
cop_all_results = []
cop_all_mode_sums = {
    'simultaneous': {'QCon': 0, 'PChi': 0},
    'coolingonly': {'QCon': 0, 'PChi': 0},
    'heatingonly': {'QCon': 0, 'PChi': 0}
    }
for (month, mode), sums in all_sums.items():
    # All-building COP of each month each mode
    QCon_all_sum = sums['QCon']
    PChi_all_sum = sums['PChi']
    
    COP_all = safe_cop(QCon_all_sum, PChi_all_sum)
    cop_all_results.append((month, mode, COP_all))
    
    # All-building whole-year
    cop_all_mode_sums[mode]['QCon'] += sums['QCon']
    cop_all_mode_sums[mode]['PChi'] += sums['PChi']

column_names = ['COP_h']

cop_all_df = pd.DataFrame(cop_all_results, columns=['month', 'mode'] + column_names)

# Convert the 'month' column to abbreviated month names
cop_all_df['month'] = cop_all_df['month'].dt.strftime('%b')

# All-building whole-year COP
#   Needs to be after month string formatting
for mode in modes:
    COP_all = safe_cop(cop_all_mode_sums[mode]['QCon'], cop_all_mode_sums[mode]['PChi'])
        
    cop_all_results.append(('Whole year', mode, COP_all))
    cop_all_df.loc[len(cop_all_df)] = ["Whole year", mode, COP_all]

cop_all_df['month'] = pd.Categorical(cop_all_df['month'], categories=month_order+['Whole year'], ordered=True)

# Pivot the DataFrame
cop_all_df_pivot = cop_all_df.pivot_table(
    index='month',
    columns='mode',
    values=column_names,
    aggfunc='first'
).swaplevel(axis=1).sort_index(axis=1)

if PRINT_RESULTS:
    print("COP across all buildings:")
    print(cop_all_df_pivot)

if WRITE_TO_XLSX:
    cop_all_df_pivot.to_excel(w, sheet_name='All buildings', index=True)
    if WRITE_REMARKS:
        remarks.to_excel(w, sheet_name="remarks", index=False)
    w.close()
    print(f"Results wrote to {PATH_XLSX}.")