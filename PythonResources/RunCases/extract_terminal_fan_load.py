#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu May 29 16:38:59 2025

@author: casper
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

#%% read results file
results = get_vars(['EFanBui.y'],
                   mat_file_name,
                   'dymola')

#%% resample the variable to hourly
time = np.array(results['Time'])
efan = np.array(results['EFanBui.y'])

t = np.arange(1, 8761)
y = np.array([efan[np.isclose(time, _t * 3600)][-1] * J_to_kWh for _t in t])

u = np.empty_like(y)
u[0] = y[0]
u[1:] = y[1:] - y[:-1]

print("# VALIDATION #")
print(f"  sum of u is {sum(u):,.0f} kWh")
print(f"  and it should be {efan[-1]*J_to_kWh:,.0f} kWh")

df = pd.DataFrame({'Time|s': t, 'EFanBui.y|kWh': u})
fn = 'terminal_fan_load.xlsx'
df.to_excel(fn,
            engine = 'xlsxwriter',
            header = False,
            index = False)
print(f'Output file generated: {os.path.join(CWD,fn)}')