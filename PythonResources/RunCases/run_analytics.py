#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 28 15:07:23 2025

@author: casper
"""

import os
import matplotlib.pyplot as plt
import unyt as uy
from buildingspy.io.outputfile import Reader

CWD = os.getcwd()

#%%
units =    [
                {'quantity' : 'power',
                 'unit'     : uy.W,
                 'displayUnit' : uy.kW
                 },
                {'quantity' : 'energy',
                 'unit'     : uy.J,
                 'displayUnit' : uy.MWh
                 }
            ]

# 'caption' is optional. 
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
            ]

actions = {'max': max,
           'min': min,
           'last': lambda y: y[-1]
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

def str_with_unit(value, quantity):
    """
    """
    u = next((item for item in units if item.get('quantity') == quantity), None)
    return (value * u['unit']).to(u['displayUnit'])

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
    
    unit_with_bracket = f"[{str_with_unit(0, var['quantity']).units}]"
    row = f"{unit_with_bracket:>{tableWidth}}"
    for i,scenario in enumerate(scenarios):
        v = scenario['results'][var['name']]
        displayValue = f"{str_with_unit(v,var['quantity']).value:.0f}"
        if i == 0 :
            vBase = v
        else:
            displayCompare = f"{v/vBase-1:+.1%}"
            displayValue += f' ({displayCompare})'
        row += f" | {displayValue:>{tableWidth}}"
    print(row)
    
