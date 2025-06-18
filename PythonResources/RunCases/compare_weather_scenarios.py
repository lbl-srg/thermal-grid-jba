#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 17 11:38:55 2025

@author: casper
"""

import os
from datetime import datetime, timedelta
from GetVariables import get_vars, index_var_list, integrate_with_condition
# python file under same folder

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))
mat_file_base = os.path.join(CWD, "simulations", "2025-06-09_weatherscenarios", "DetailedPlantFiveHubs-001.mat")
mat_file_heat = os.path.join(CWD, "simulations", "2025-06-09_weatherscenarios", "DetailedPlantFiveHubs-004.mat")
mat_file_cold = os.path.join(CWD, "simulations", "2025-06-09_weatherscenarios", "DetailedPlantFiveHubs-003.mat")

J_to_kWh = 1 / 3600 * 1e-3
J_to_MWh = 1 / 3600 * 1e-6

#%% construct var list
_i = '%%i%%'
nBui = 5

var_list = list()
var_list += ['ETot.y',      # Total ele consumption, J
             'EHeaPum.y']   # Total compressor ele consumption, J
var_pre_index = [f'bui[{_i}].bui.loa.y[1]', # Building cooling load, W
                 f'bui[{_i}].bui.loa.y[2]'] # Building sp. heating load, W

var_list += index_var_list(var_pre_index,
                           _i,
                           range(1, nBui+1))

#%% get vars
results_base = get_vars(var_list, mat_file_base, 'dymola')
results_heat = get_vars(var_list, mat_file_heat, 'dymola')

#%% get time stamps in seconds
def soy(dt):
    """ Returns second of year
    """
    start_of_year = datetime(dt.year, 1, 1)
    return int((dt - start_of_year).total_seconds())

# start and end dates of the weather events, both dates inclusive
# see PythonResources/Data/Consumption/Anemoi.py
_year = 2025 # dummy year, has no effect
sec_heat_from = soy(datetime(_year, 7, 27))
sec_heat_to   = soy(datetime(_year, 8,  9)) + 24*3600
sec_cold_from = soy(datetime(_year, 2, 23))
sec_cold_to   = soy(datetime(_year, 3,  8)) + 24*3600

#%% Compute and compare variables
def get_section(df, sec_from, sec_to):
    """ Make a copy of the dataframe where
            df['Time'] >= sec_from and df['Time'] < sec_to
    """
    df_section = df[(df['Time'] >= sec_from) & (df['Time'] < sec_to)].copy()
    
    return df_section

def print_comparison(df_base,
                     df_even,
                     varname,
                     integrate : bool,
                     conversion = 1,
                     description = None):
    """ Prints the comparison of a value.
          if integrate:
              value = series[-1] - series[0]
          else:
              value = trapz(t = [from, to], y)
        df_base : dataframe of the base scenario
        df_even : dataframe of the event scenario
        varname : variable name, also column name in the dataframe
        integrate : boolean flag
        conversion : unit conversion factor
        description : description of the variable
        
    """
    
    if description is None:
        description = varname
    
    if integrate:
        v_base = integrate_with_condition(df_base, varname)
        v_even = integrate_with_condition(df_even, varname)
    else:
        v_base = (df_base[varname].iloc[-1] - df_base[varname].iloc[0])
        v_even = (df_even[varname].iloc[-1] - df_even[varname].iloc[0])
    v_base = abs(v_base) * conversion
    v_even = abs(v_even) * conversion
    diff_v = v_even - v_base
    diff_p = diff_v / v_base
    print(description)
    print(f"Base case: {v_base:,.0f}")
    print(f"Event: {v_even:,.0f}")
    print(f"Diff: {diff_v:,.0f}, {diff_p:.1%}")

# heat wave
df_heat_base = get_section(results_base, sec_heat_from, sec_heat_to)
df_heat_heat = get_section(results_heat, sec_heat_from, sec_heat_to)

print_comparison(df_base = df_heat_base,
                 df_even = df_heat_heat,
                 varname = 'ETot.y',
                 integrate = False,
                 conversion = J_to_MWh,
                 description = 'Total ele use [MWh]')

cols_coo = [f'bui[{_i}].bui.loa.y[1]' for _i in range(1, nBui+1)]
df_heat_base['CooLoa'] = df_heat_base[cols_coo].sum(axis=1)
df_heat_heat['CooLoa'] = df_heat_heat[cols_coo].sum(axis=1)
print_comparison(df_base = df_heat_base,
                 df_even = df_heat_heat,
                 varname = 'CooLoa',
                 integrate = True,
                 conversion = J_to_MWh,
                 description = 'Total cooling load [MWh]')
