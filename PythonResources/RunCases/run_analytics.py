#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 28 15:07:23 2025

@author: casper

This script compares numbers (min, max, duration of y>0.99, etc.)
    from multiple model result files.

Todo:
    Wrap analysis scenarios in a different file.
"""

import os
import numpy as np
import unyt as uy
from buildingspy.io.outputfile import Reader
from datetime import datetime, timedelta

PRINT_COMPARISON = True # percentage comparison
TABLE_WIDTH = 15

# from PythonResources/Data/Consumption/Anemoi.py
_year = 2025 # dummy year, no effect
hotday = datetime(_year, 8, 2)
heat_wave_from = datetime(_year, 7, 27)
heat_wave_to = datetime(_year, 8, 9)
coldday = datetime(_year, 3, 1)
cold_snap_from = datetime(_year, 2, 23)
cold_snap_to = datetime(_year, 3, 8)

def soy(dt):
    # Second of year
    start_of_year = datetime(dt.year, 1, 1)
    return int((dt - start_of_year).total_seconds())

SHORT_TERM_ANALYSIS = True # set true to only analyse data in the period below
# ANALYSIS_START_SECONDS = soy(heat_wave_from)
# ANALYSIS_END_SECONDS = soy(heat_wave_to)
ANALYSIS_START_SECONDS = soy(cold_snap_from)
ANALYSIS_END_SECONDS = soy(cold_snap_to)

CWD = os.getcwd()

#%%
units = {'power':
             {'unit'        : uy.W,
              'displayUnit' : uy.kW},
         'energy':
             {'unit'        : uy.J,
              'displayUnit' : uy.MWh},
         'time':
             {'unit'        : uy.s,
              'displayUnit' : uy.s}
        }

# 'caption' is optional. 
# if 'quantity' not given, treated as unit 1.
variables = [
                {'name' : 'EChi.u',
                 'quantity': 'power',
                 'action'  : max,
                 'caption' : 'Peak electric power input of ETS heat recovery chiller '
                 },
                {'name' : 'EChi.y',
                 'quantity': 'energy',
                 'action'  : lambda y: y[-1] - y[0],
                 'caption' : 'Total electrical consumption of ETS heat recovery chiller '
                 },
                {'name' : 'bui.bui.QReqHea_flow',
                 'quantity': 'power',
                 'action'  : max,
                 'caption' : 'Peak end-use space heating load'
                 },
                {'name' : 'bui.bui.QReqCoo_flow',
                 'quantity': 'power',
                 'action'  : min,
                 'caption' : 'Peak end-use cooling load'
                 },
                {'name' : 'dHHeaWat.y',
                 'quantity': 'energy',
                 'action'  : lambda y: y[-1] - y[0],
                 'caption' : 'Total end-use space heating load'
                 },
                {'name' : 'dHChiWat.y',
                 'quantity': 'energy',
                 'action'  : lambda y: y[-1] - y[0],
                 'caption' : 'Total end-use cooling load'
                 },
                {'name' : 'bui.ets.chi.chi.ySet',
                 'quantity': 'time',
                 'action'  : lambda y: condition_duration(t, y, lambda y: y > 0.99),
                 'caption' : 'Total duration of chiller speed > 0.99'}
            ]

# Comparing results from 3 weather scenarios.
scenarios = [
                {'name'    : 'fTMY',
                  'matFile' : os.path.join('ETS_All_futu','ConnectedETSWithDHW.mat'),
                  'results' : {}
                  },
                {'name'    : 'Heat wave',
                  'matFile' : os.path.join('ETS_All_heat','ConnectedETSWithDHW.mat'),
                  'results' : {}
                  },
                {'name'    : 'Cold snap',
                  'matFile' : os.path.join('ETS_All_cold','ConnectedETSWithDHW.mat'),
                  'results' : {}
                  }
            ]

# Listing results from the ETS based on building clusters.
# scenarios = [
#                 {'name'    : 'A',
#                   'matFile' : os.path.join('cluster_A_futu','ConnectedETSNoDHW.mat'),
#                   'results' : {}
#                   },
#                 {'name'    : 'B',
#                   'matFile' : os.path.join('cluster_B_futu','ConnectedETSWithDHW.mat'),
#                   'results' : {}
#                   },
#                 {'name'    : 'C',
#                   'matFile' : os.path.join('cluster_C_futu','ConnectedETSWithDHW.mat'),
#                   'results' : {}
#                   },
#                 {'name'    : 'D',
#                   'matFile' : os.path.join('cluster_D_futu','ConnectedETSWithDHW.mat'),
#                   'results' : {}
#                   },
#                 {'name'    : 'E',
#                   'matFile' : os.path.join('cluster_E_futu','ConnectedETSWithDHW.mat'),
#                   'results' : {}
#                   }
#             ]

def find_var(n, print_message = True):
    """ Find the exact var name in results.
        If variable found, returns the values;
        Else, prints error message unless print_message == False.
    """
    
    if r.varNames(f'^{n}$'):
        (t, y) = r.values(n)
    else:
        y = []
        if print_message:
            print(f'No variable found with name: "{n}".')
        
    return y

def condition_duration(t, y, condition):
    """ Duration of time during which y meets the condition.
    """
    indices = np.where(condition(y))[0]
    duration = 0.0
    for i in range(1, len(indices)):
        if indices[i] == indices[i-1] + 1:  # Check if the indices are consecutive
            duration += t[indices[i]] - t[indices[i-1]]
            
    return duration

def section_data(t, y, seconds_start = 0, seconds_end = 365*24*3600):
    """ Take out a section of the data.
    """
    mask = (t >= seconds_start) & (t < seconds_end)
    t_sectioned = t[mask]
    y_sectioned = y[mask]
    
    return t_sectioned, y_sectioned

#%%
for scenario in scenarios:
    mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", scenario['matFile']))
    r=Reader(mat_file_path, 'dymola')
    for var in variables:
        #y = find_var(var['name'])
        (t, y) = r.values(var['name'])
        if SHORT_TERM_ANALYSIS:
            t, y = section_data(t, y, ANALYSIS_START_SECONDS, ANALYSIS_END_SECONDS)
        if len(t) > 2 and not 'time' in scenario['results']:
            scenario['results']['time'] = t # writes the time stamp
        v = var['action'](y)
        scenario['results'][var['name']] = v

#%%
row = f"{'Scenarios:':<{TABLE_WIDTH}}"
for s in scenarios:
    row += f" | {s['name']:<{TABLE_WIDTH}}"
print(row)
for var in variables:
    if 'caption' in var.keys():
        row = var['caption']
    else:
        row = var['name']
    print(row)
    
    if 'quantity' in var.keys():
        unit_with_bracket = f"[{units[var['quantity']]['displayUnit']}]"
    else:
        unit_with_bracket = "[1]"
    row = f"{unit_with_bracket:>{TABLE_WIDTH}}"
    for i,scenario in enumerate(scenarios):
        v = scenario['results'][var['name']]
        if 'quantity' in var.keys():
            displayValue = f"{(v * units[var['quantity']]['unit']).to(units[var['quantity']]['displayUnit']).value:.0f}"
        else:
            displayValue = f"{v:.0f}"
        if PRINT_COMPARISON:
            if i == 0 :
                vBase = v
            else:
                displayCompare = f"{v/vBase-1:+.1%}"
                displayValue += f' ({displayCompare})'
        row += f" | {displayValue:>{TABLE_WIDTH}}"
    print(row)
    
