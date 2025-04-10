#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 28 15:07:23 2025

@author: casper
"""

import os
import numpy as np
import unyt as uy
from buildingspy.io.outputfile import Reader

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
                 'action'  : 'max',
                 'caption' : 'ETS heat recovery chiller peak electric power input'
                 },
                {'name' : 'EChi.y',
                 'quantity': 'energy',
                 'action'  : 'last',
                 'caption' : 'ETS heat recovery chiller total electrical consumption'
                 },
                {'name' : 'bui.bui.QReqHea_flow',
                 'quantity': 'power',
                 'action'  : 'max',
                 'caption' : 'Peak end-use space heating load'
                 },
                {'name' : 'bui.bui.QReqCoo_flow',
                 'quantity': 'power',
                 'action'  : 'min',
                 'caption' : 'Peak end-use cooling load'
                 },
                {'name' : 'dHHeaWat.y',
                 'quantity': 'energy',
                 'action'  : 'last',
                 'caption' : 'Total end-use space heating load'
                 },
                {'name' : 'dHChiWat.y',
                 'quantity': 'energy',
                 'action'  : 'last',
                 'caption' : 'Total end-use cooling load'
                 },
                {'name' : 'bui.ets.chi.chi.ySet',
                 'quantity': 'time',
                 'action'  : 'duration>0.99',
                 'caption' : 'Total duration of chiller speed > 0.99'}
            ]

actions = {'max': max,
           'min': min,
           'last': lambda y: y[-1],
           'duration>0.99': lambda y: find_duration(t, y)
           }

# the first scenario will be the baseline to be compared against
### replace this with a list of dict?
scenarios = [
                {'name'    : 'fTMY',
                 'matFile' : 'ConnectedETSNoDHW_futu.mat',
                 'results' : {}
                 },
                {'name'    : 'Heat wave',
                 'matFile' : 'ConnectedETSNoDHW_heat.mat',
                 'results' : {}
                 },
                {'name'    : 'Cold snap',
                 'matFile' : 'ConnectedETSNoDHW_cold.mat',
                 'results' : {}
                 }
            ]

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

def find_duration(t, y):
    
    indices = np.where(y > 0.99)[0]
    duration = 0.0
    for i in range(1, len(indices)):
        if indices[i] == indices[i-1] + 1:  # Check if the indices are consecutive
            duration += t[indices[i]] - t[indices[i-1]]
            
    return duration
    
    
#%%
for scenario in scenarios:
    mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", scenario['matFile']))
    r=Reader(mat_file_path, 'dymola')
    for var in variables:
        #y = find_var(var['name'])
        (t, y) = r.values(var['name'])
        if len(t) > 2 and not 'time' in scenario['results']:
            scenario['results']['time'] = t # writes the time stamp
        v = actions[var['action']](y)
        scenario['results'][var['name']] = v

#%% 
tableWidth = 15
row = f"{'Scenarios:':<{tableWidth}}"
for s in scenarios:
    row += f" | {s['name']:<{tableWidth}}"
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
    row = f"{unit_with_bracket:>{tableWidth}}"
    for i,scenario in enumerate(scenarios):
        v = scenario['results'][var['name']]
        if 'quantity' in var.keys():
            displayValue = f"{(v * units[var['quantity']]['unit']).to(units[var['quantity']]['displayUnit']).value:.0f}"
        else:
            displayValue = f"{v:.0f}"
        if i == 0 :
            vBase = v
        else:
            displayCompare = f"{v/vBase-1:+.1%}"
            displayValue += f' ({displayCompare})'
        row += f" | {displayValue:>{tableWidth}}"
    print(row)
    
