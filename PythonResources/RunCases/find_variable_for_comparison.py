#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May 28 11:02:11 2025

@author: casper

This script integrates the variables from the Modelica results file.
    Useful when such a number is needed but not integrated inside the Modelica model.
"""

import os
import csv
import numpy as np
import pandas as pd

#from scipy.integrate import trapz

from GetVariables import get_vars
# python file under same folder

CWD = os.path.dirname(os.path.abspath(__file__))
mat_file_name = os.path.join(CWD, "simulations", "2025-05-25", "DetailedPlantFiveHubs.mat")
J_to_kWh = 2.7777777777777776e-07

remarks = pd.DataFrame(np.array([['Model', 'ThermalGridJBA.Networks.Validation.DetailedPlantFiveHubs'],
                                 ['Weather scenario', 'fTMY'],
                                 ['Result file at commit', '418c50b5f58d31d87fa7d35beb31b2f020e8b66e']]))

#%% read results file
# {var name in Modelica: description}
var_dict = {
    'ETot.y': 'Total electric energy',
    'EFanBui.y': 'Building terminal fans',
    'EEleNonHvaETS.y': 'Non-HVAC electric use and AHU fans',
    'EPumETS.y': 'ETS pumps',
    'EHeaPum.y': 'ETS heat pump compressor',
    'EFanDryCoo.y': 'Central plant dry cooler fan',
    'EPumPla.y': 'Central plant pumps',
    'EComPla.y': 'Central plant heat pump compressor',
    'EPumDis.y': 'District distribution pump'
    }
var_list = list(var_dict.keys())
results = get_vars(var_list,
                   mat_file_name,
                   'dymola')

#%% print

data = []
for var in var_list:
    varname = var
    vardesc = var_dict[var]
    value = np.array(results[var])[-1] * J_to_kWh
    unit = 'kWh/a'
    
    data.append({
        'description': vardesc,
        'variable name': varname,
        'value': value,
        'unit': unit
    })
    
    print(f"{vardesc} ({varname}):")
    print(' '*4 + f'{value:,.0f} {unit}')

df = pd.DataFrame(data)

with pd.ExcelWriter('variables_for_comparison.xlsx', engine='xlsxwriter') as w:
    df.to_excel(w, sheet_name='variables', index=False)
    remarks.to_excel(w, sheet_name="remarks", index=False)
