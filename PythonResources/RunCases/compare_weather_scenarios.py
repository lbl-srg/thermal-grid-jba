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
from GetVariables import *
# python file under same folder

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))
mat_file = dict()
mat_file['ets'] = dict()
mat_file['ets']['base'] = os.path.join(CWD, "simulations", "2025-06-09_weatherscenarios", "DetailedPlantFiveHubs-001.mat")
mat_file['ets']['heat'] = os.path.join(CWD, "simulations", "2025-06-09_weatherscenarios", "DetailedPlantFiveHubs-004.mat")
mat_file['ets']['cold'] = os.path.join(CWD, "simulations", "2025-06-09_weatherscenarios", "DetailedPlantFiveHubs-003.mat")
# placeholder
mat_file['ets']['crit'] = os.path.join(CWD, "simulations", "2025-06-09_weatherscenarios", "DetailedPlantFiveHubs-001.mat")
mat_file['awhp'] = dict()
mat_file['awhp']['base'] = os.path.join(CWD, "simulations", "awhp", "AirToWater-base.mat")
mat_file['awhp']['heat'] = os.path.join(CWD, "simulations", "awhp", "AirToWater-heat.mat")
mat_file['awhp']['cold'] = os.path.join(CWD, "simulations", "awhp", "AirToWater-cold.mat")
mat_file['awhp']['crit'] = os.path.join(CWD, "simulations", "awhp", "AirToWater-crit.mat")

J_to_kWh = 1 / 3600 * 1e-3
J_to_MWh = 1 / 3600 * 1e-6
J_to_MMBtu = 1 / 1.05505585262e9

_i = '%%i%%' # index placeholder

#%% construct results dfs
results = dict()
models = ['ets', 'awhp']
events = ['base', 'heat', 'cold', 'crit']

# ets
model = 'ets'
nBui = 5 # will be checked against 'nBui' from the mat file

var_list = list()
var_list += ['nBui',        # number of buildings, for verification
             'cenPla.gen.heaPum.QCon_flow', # plant nominal condenser output, W
             'cenPla.gen.heaPum.QEva_flow', # plant nominal evaporator output, W
             'cenPla.gen.heaPum.P',         # plant compressor power, W
             'cenPla.gen.heaPum.hea',       # heating = 1, cooling = 0
             'EHeaPum.y',                   # total ets compressor energy, J
             'EComPla.y',                   # total plant compressor energy, J
             ]

var_pre_index = [f'bui[{_i}].ets.heaPum.con.uCoo',  # cooling mode
                 f'bui[{_i}].ets.heaPum.con.hea.y', # heating mode, including dhw
                 f'bui[{_i}].bui.loa.y[1]', # building cooling load, W
                 f'bui[{_i}].bui.loa.y[2]', # building sp. heating load, W
                 f'bui[{_i}].ets.heaPum.heaPum.QCon_flow', # ets condenser output, W
                 f'bui[{_i}].ets.heaPum.heaPum.P', # ets compressor power, W
                 ]
var_list += index_var_list(var_pre_index,
                           _i,
                           range(1, nBui+1))

results[model] = dict()
for key in events:
    results[model][key] = get_vars(var_list, mat_file[model][key], 'dymola')

assert nBui == results['ets']['base']['nBui'].iloc[0], """
Error: For the ETS model,
`nBui` from the python code and `nBui` from the baseline mat file do not match.
Execution aborted."""

# awhp
model = 'awhp'
nHp = 3 # will be checked against 'pla.nHp' from the mat file

var_list = list()
var_list += ['pla.nHp'] # number of heat pumps, for verification
var_pre_index = [f'pla.hp.hp[{_i}].hp.uMod',        # mode, cooling -1, heating +1, off 0
                 f'pla.hp.hp[{_i}].hp.QLoa_flow',   # load side heat flow
                 f'pla.hp.hp[{_i}].hp.QSou_flow',   # source side heat flow
                 f'pla.hp.hp[{_i}].hp.P',           # compressor power
                 ]
var_list += index_var_list(var_pre_index,
                           _i,
                           range(1, nHp+1))

results[model] = dict()
for key in events:
    results[model][key] = get_vars(var_list, mat_file[model][key], 'dymola')

assert nHp == results['awhp']['base']['pla.nHp'].iloc[0], """
Error: For the AWHP model,
`nHp` from the python code and `pla.nHp` from the baseline mat file do not match.
Execution aborted."""

#%% get time stamps in seconds
def soy(dt):
    """ Returns second of year
    """
    start_of_year = datetime(dt.year, 1, 1)
    return int((dt - start_of_year).total_seconds())

# start and end dates of the weather events, both dates inclusive
# see PythonResources/Data/Consumption/Anemoi.py
_year = 2025 # dummy year, has no effect
duration = {}
duration['heat'] = [soy(datetime(_year, 7, 27)),            # 17884800
                    soy(datetime(_year, 8,  9)) + 24*3600   # 19094400
                    ]
duration['cold'] = [soy(datetime(_year, 2, 23)),            #  4579200
                    soy(datetime(_year, 3,  8)) + 24*3600   #  5788800
                    ]
duration['crit_cold'] = [soy(datetime(_year, 3,  1)),            #  5097600
                         soy(datetime(_year, 3,  7)) + 24*3600   #  5702400
                         ]
duration['crit_heat'] = [soy(datetime(_year, 8,  2)),            #  18403200
                         soy(datetime(_year, 8,  8)) + 24*3600   #  19008000
                         ]

#%% Compute and compare variables
def copy_section(df, duration):
    """ Make a copy of the dataframe where
            df['Time'] >= duration[0] and df['Time'] < duration[1]
    """
    df_section = df[(df['Time'] >= duration[0]) &
                    (df['Time'] < duration[1])].copy()
    
    return df_section

def write_row(description,
              v_base,
              v_even,
              unit_si : str,
              factor_si,
              format_si = ',.0f',
              to_ip = False,
              unit_ip = None,
              format_ip = ',.0f',
              factor_ip = None,
              skip_compare = False):
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
        skip_compare : skip printing the percentage
    """
    
    tab = ""
    
    v_base_si = v_base * factor_si
    v_even_si = v_even * factor_si
    if skip_compare:
        diff_v_si = ""
    else:
        _diff_v_si = v_even_si - v_base_si
        diff_v_si = f'{_diff_v_si:+{format_si}}'
    if abs(v_base_si) < 1e-10 or skip_compare:
        diff_p_str = ""
    else:
        _diff_p = _diff_v_si/v_base_si*100
        diff_p_str = f'{_diff_p:+.3g}\\%'
    
    tab += f"{description} & [{unit_si}] & {v_base_si:{format_si}} & {v_even_si:{format_si}} & \\textit{{{diff_v_si}}} & \\textit{{{diff_p_str}}} \\\\\n"
    
    if to_ip:
        v_base_ip = v_base * factor_ip
        v_even_ip = v_even * factor_ip
        if skip_compare:
            diff_v_ip = ""
        else:
            _diff_v_ip = v_even_ip - v_base_ip
            diff_v_ip = f'{_diff_v_ip:+{format_ip}}'
        
        tab += f" & [{unit_ip}] & {v_base_ip:{format_ip}} & {v_even_ip:{format_ip}} & \\textit{{{diff_v_ip}}} & \\\\\n"
        
    return tab

def write_latex_table_weather(event : str):
    """ event : ['heat', 'cold']
    """
    
    scenarios = ['base', event]
    
    # copy sub-dataframes for the duration of the event for each model each scenario
    dfs = {model:
                {sce: copy_section(results[model][sce], duration[event])
                      for sce in scenarios}
                for model in models}
    # energy and cop computation
    QCon = {model:
                 {sce: 0. for sce in scenarios}
                          for model in models}
    PEle = {model:
                 {sce: 0. for sce in scenarios}
                          for model in models}
    COP  = {model:
                 {sce: 0. for sce in scenarios}
                          for model in models}
    for sce in scenarios:
        model = 'ets'
        # each ets
        for i in range(1, nBui+1):
            if event == 'heat':
                condition = np.array(dfs[model][sce][f'bui[{i}].ets.heaPum.con.uCoo'] == 1)
            else:
                condition = np.array(dfs[model][sce][f'bui[{i}].ets.heaPum.con.hea.y'] == 1)
            QCon[model][sce] += integrate_with_condition(dfs[model][sce], f'bui[{i}].ets.heaPum.heaPum.QCon_flow',
                                                         condition = condition)
            PEle[model][sce] += integrate_with_condition(dfs[model][sce], f'bui[{i}].ets.heaPum.heaPum.P',
                                                         condition = condition)
        # central plant
        if event == 'heat':
            condition = np.array(dfs[model][sce]['cenPla.gen.heaPum.hea'] == 0)
        else:
            condition = np.array(dfs[model][sce]['cenPla.gen.heaPum.hea'] == 1)
        QCon[model][sce] += integrate_with_condition(dfs[model][sce], 'cenPla.gen.heaPum.QCon_flow',
                                                     sign = 'positive') + \
                            integrate_with_condition(dfs[model][sce], 'cenPla.gen.heaPum.QEva_flow',
                                                     sign = 'positive')
        PEle[model][sce] += integrate_with_condition(dfs[model][sce], 'cenPla.gen.heaPum.P',
                                                     condition = condition)
        COP[model][sce] = QCon[model][sce] / PEle[model][sce]
            
        model = 'awhp'
        cols = [f'pla.hp.hp[{_i}].hp.P' for _i in range(1, nHp+1)]
        for i in range(1, nHp+1):
            if event == 'heat':
                condition = np.array(dfs[model][sce][f'pla.hp.hp[{i}].hp.uMod'] == -1)
            else:
                condition = np.array(dfs[model][sce][f'pla.hp.hp[{i}].hp.uMod'] == 1)
            # because the hp is reversible, the condenser is whichever side is positive
            QCon[model][sce] += integrate_with_condition(dfs[model][sce], f'pla.hp.hp[{i}].hp.QLoa_flow',
                                                         condition = condition, sign = 'positive') + \
                                integrate_with_condition(dfs[model][sce], f'pla.hp.hp[{i}].hp.QSou_flow',
                                                         condition = condition, sign = 'positive')
            PEle[model][sce] += integrate_with_condition(dfs[model][sce], f'pla.hp.hp[{i}].hp.P',
                                                         condition = condition)
        COP[model][sce] = QCon[model][sce] / PEle[model][sce]
        
    if event == 'heat':
        event_str = 'Heat wave'
    else:
        event_str = 'Cold snap'
    
    # header
    tab = ""
    tab += "% *remarks*\n\n"
    tab += "\\begin{tabular}{lrrrrr}\n"
    tab += "\\toprule\n"
    tab += f" & & Baseline & {event_str} & & \\\\\n"
    tab += "\\hline\n"
    
    # main body
    
    # end-use heating or cooling load
    if event == 'heat':
        desc = "End-use cooling load"
        cols = [f'bui[{_i}].bui.loa.y[1]' for _i in range(1, nBui+1)]
    else:
        desc = "End-use heating load"
        cols = [f'bui[{_i}].bui.loa.y[2]' for _i in range(1, nBui+1)]
    for sce in scenarios:
        dfs['ets'][sce]['Load'] = dfs['ets'][sce][cols].sum(axis=1)
    tab += write_row(description = desc,
                     v_base = abs(integrate_with_condition(dfs['ets']['base'], 'Load')),
                     v_even = abs(integrate_with_condition(dfs['ets'][event], 'Load')),
                     unit_si = 'MWh',
                     factor_si = J_to_MWh,
                     to_ip = True,
                     unit_ip = 'MMBtu',
                     factor_ip = J_to_MMBtu)
    
    # ets
    tab += "ETS system & & & & & \\\\\n"
    model = 'ets'
    
    # ets compressor load
    tab += write_row(description = r"\hspace{0.5cm}" + "System-wide compressor load",
                     v_base = PEle[model]['base'],
                     v_even = PEle[model][event],
                     unit_si = 'MWh',
                     factor_si = J_to_MWh,
                     to_ip = False)
    
    # ets COP
    
    tab += write_row(description = r"\hspace{0.5cm}" + "Average COP",
                     v_base = COP[model]['base'],
                     v_even = COP[model][event],
                     unit_si = '-',
                     factor_si = 1.,
                     format_si = '.2f',
                     skip_compare = True)
    
    # awhp# ets
    tab += "AWHP system & & & & & \\\\\n"
    model = 'awhp'
    
    # awhp compressor load
    
    tab += write_row(description = r"\hspace{0.5cm}" + "System-wide compressor load",
                     v_base = PEle[model]['base'],
                     v_even = PEle[model][event],
                     unit_si = 'MWh',
                     factor_si = J_to_MWh,
                     to_ip = False)
    
    # awhp COP
    tab += write_row(description = r"\hspace{0.5cm}" + "Average COP",
                     v_base = COP[model]['base'],
                     v_even = COP[model][event],
                     unit_si = '-',
                     factor_si = 1.,
                     format_si = '.2f',
                     skip_compare = True)
    
    # footer
    tab += "\\bottomrule\n"
    tab += "\\end{tabular}"

    return tab

def write_latex_table_critical():
    
    scenarios = ['crit_cold', 'crit_heat']
    
    # copy sub-dataframes for the duration of the event for each model each scenario
    dfs = {model:
                {'crit_cold' : copy_section(results[model]['crit'], duration['crit_cold']),
                 'crit_heat' : copy_section(results[model]['crit'], duration['crit_heat']),
                    }
                for model in models}
    
    # header
    tab = ""
    tab += "% *remarks*\n\n"
    tab += "\\begin{tabular}{lrrrrr}\n"
    tab += "\\toprule\n"
    tab += f" & & ETS & AWHP &  & \\\\\n"
    tab += "\\hline\n"
    
    # main body
    
    # power outage after each event
    desc = {'crit_cold' : 'After cold snap',
            'crit_heat' : 'After heat wave'
            }
    for sce in scenarios:
        v_base = dfs['ets'][sce]['EHeaPum.y'].iloc[-1] - dfs['ets'][sce]['EHeaPum.y'].iloc[0] + \
                 dfs['ets'][sce]['EComPla.y'].iloc[-1] - dfs['ets'][sce]['EComPla.y'].iloc[0]
        PEle = 0
        for i in range(1, nHp+1):
            PEle += integrate_with_condition(dfs['awhp'][sce], f'pla.hp.hp[{i}].hp.P')
        v_even = PEle
        tab += write_row(description = desc[sce],
                         v_base = v_base,
                         v_even = v_even,
                         unit_si = 'MWh',
                         factor_si = J_to_MWh,
                         to_ip = False)
    
    # footer
    tab += "\\bottomrule\n"
    tab += "\\end{tabular}"
    
    return tab

#%%
if __name__ == "__main__":

    # heat wave
    tab_heat = write_latex_table_weather('heat')
    
    # cold snap
    tab_cold = write_latex_table_weather('cold')
    
    # critical load
    tab_crit = write_latex_table_critical()