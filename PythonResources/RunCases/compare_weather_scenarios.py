#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 17 11:38:55 2025

@author: casper
"""

import os
import numpy as np
import pandas as pd
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
J_to_MMBtu = 1 / 1.05505585262e9

#%% construct var list
_i = '%%i%%'
nBui = 5

var_list = list()
var_list += ['ETot.y',      # Total ele consumption, J
             'EHeaPum.y',   # ETS compressor ele consumption, J
             'EComPla.y',   # Plant compressor ele consumption, J
             'EPumETS.y',   # ETS pump ele consumption, J
             'EPumPla.y']   # Plant pump ele consumption, J
var_pre_index = [f'bui[{_i}].bui.loa.y[1]', # Building cooling load, W
                 f'bui[{_i}].bui.loa.y[2]', # Building sp. heating load, W
                 f'bui[{_i}].bui.terUniCoo.TLoaODE.TAir', # Room temp for cooling, K
                 f'bui[{_i}].bui.terUniHea.TLoaODE.TAir'] # Room temp for heating, K

var_list += index_var_list(var_pre_index,
                           _i,
                           range(1, nBui+1))

#%% get vars
results_base = get_vars(var_list, mat_file_base, 'dymola')
results_heat = get_vars(var_list, mat_file_heat, 'dymola')
results_cold = get_vars(var_list, mat_file_cold, 'dymola')

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

def write_latex_table(df_base,
                      df_even,
                      event : str):
    """ df_base : baseline
        df_even : event
        event : ['heat', 'cold']
    """
    
    def write_row(description,
                  v_base,
                  v_even,
                  unit_si : str,
                  factor_si,
                  to_ip = False,
                  unit_ip = None,
                  factor_ip = None):
        """ Returns one row of the latex table if ip unit not needed,
              otherwise returns also a second row in ip unit.
            description : first column,
            v_base : baseline value in native unit,
            v_even : event value in native unit,
            unit_si : display unit string,
            factor_si : conversion factor to si unit,
            to_ip : boolean, if true returns second row in ip unit,
            unit_ip : display unit string for ip,
            factor_ip : conversion factor for ip.
        """
        
        tab = ""
        
        v_base_si = v_base * factor_si
        v_even_si = v_even * factor_si
        diff_v_si = v_even_si - v_base_si
        if abs(v_base_si) < 1e-10:
            diff_p_str = ""
        else:
            diff_p_str = f'{diff_v_si/v_base_si*100:+.1f}\\%'
        
        tab += f"{description} & [{unit_si}] & {v_base_si:,.0f} & {v_even_si:,.0f} & \\textit{{{diff_v_si:+,.0f}}} & \\textit{{{diff_p_str}}} \\\\\n"
        
        if to_ip:
            v_base_ip = v_base * factor_ip
            v_even_ip = v_even * factor_ip
            diff_v_ip = v_even_ip - v_base_ip
            
            tab += f" & [{unit_ip}] & {v_base_ip:,.0f} & {v_even_ip:,.0f} & \\textit{{{diff_v_ip:+,.0f}}} & \\\\\n"
            
        return tab
    
    if event == 'heat':
        event_str = 'Heat wave'
    else:
        event_str = 'Cold snap'
    
    # header
    tab = ""
    tab += "% *remarks*\n\n"
    tab += "\\begin{tabular}{lrrrrr}\n"
    tab += "\\toprule\n"
    tab += f"During the event & & Baseline & {event_str} & & \\\\\n"
    tab += "\\hline\n"
    
    # main body
    
    if event == 'heat':
        # load
        cols_coo = [f'bui[{_i}].bui.loa.y[1]' for _i in range(1, nBui+1)]
        df_base['CooLoa'] = df_base[cols_coo].sum(axis=1)
        df_even['CooLoa'] = df_even[cols_coo].sum(axis=1)
        
        tab += write_row(description = "End-use cooling load",
                         v_base = abs(integrate_with_condition(df_base, 'CooLoa')),
                         v_even = abs(integrate_with_condition(df_even, 'CooLoa')),
                         unit_si = 'MWh',
                         factor_si = J_to_MWh,
                         to_ip = True,
                         unit_ip = 'MMBtu',
                         factor_ip = J_to_MMBtu)
    
    if event == 'cold':
        # load
        cols_hea = [f'bui[{_i}].bui.loa.y[2]' for _i in range(1, nBui+1)]
        df_base['HeaLoa'] = df_base[cols_hea].sum(axis=1)
        df_even['HeaLoa'] = df_even[cols_hea].sum(axis=1)
        
        tab += write_row(description = "End-use space heating load",
                         v_base = integrate_with_condition(df_base, 'HeaLoa'),
                         v_even = integrate_with_condition(df_even, 'HeaLoa'),
                         unit_si = 'MWh',
                         factor_si = J_to_MWh,
                         to_ip = True,
                         unit_ip = 'MMBtu',
                         factor_ip = J_to_MMBtu)
    
    # compressor load
    tab += write_row(description = "Compressor electricity use",
                     v_base = df_base['EHeaPum.y'].iloc[-1] - df_base['EHeaPum.y'].iloc[0]
                            + df_base['EComPla.y'].iloc[-1] - df_base['EComPla.y'].iloc[0],
                     v_even = df_even['EHeaPum.y'].iloc[-1] - df_even['EHeaPum.y'].iloc[0]
                            + df_even['EComPla.y'].iloc[-1] - df_even['EComPla.y'].iloc[0],
                     unit_si = 'MWh',
                     factor_si = J_to_MWh,
                     to_ip = False)
    
    # pump load
    tab += write_row(description = "Pump electricity use",
                     v_base = df_base['EPumETS.y'].iloc[-1] - df_base['EPumETS.y'].iloc[0]
                            + df_base['EPumPla.y'].iloc[-1] - df_base['EPumPla.y'].iloc[0],
                     v_even = df_even['EPumETS.y'].iloc[-1] - df_even['EPumETS.y'].iloc[0]
                            + df_even['EPumPla.y'].iloc[-1] - df_even['EPumPla.y'].iloc[0],
                     unit_si = 'MWh',
                     factor_si = J_to_MWh,
                     to_ip = False)
    
    # footer
    tab += "\\bottomrule\n"
    tab += "\\end{tabular}"

    return tab

# heat wave
df_heat_base = get_section(results_base, sec_heat_from, sec_heat_to)
df_heat_even = get_section(results_heat, sec_heat_from, sec_heat_to)

tab_heat = write_latex_table(df_base = df_heat_base,
                             df_even = df_heat_even,
                             event = 'heat')

# cold snap
df_cold_base = get_section(results_base, sec_cold_from, sec_cold_to)
df_cold_even = get_section(results_cold, sec_cold_from, sec_cold_to)
tab_cold = write_latex_table(df_base = df_cold_base,
                             df_even = df_cold_even,
                             event = 'cold')
