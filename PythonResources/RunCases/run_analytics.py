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
MAT_FILE_NAME = "ConnectedETSNoDHW_futu.mat"
PRINT_ACTION_NOT_FOUND = False

#%%

mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", MAT_FILE_NAME))

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

variables = [
                {'name' : 'EChi.u',
                 'desc' : 'ETS heat recovery chiller electric power input',
                 'quantity' : 'power',
                 'actions'  : ['max', 'plot'],
                 'captions' : ['Peak heat recovery chiller electric power input',
                               'Heat recovery chiller electric power input']
                 },
                {'name' : 'EChi.y',
                 'desc' : 'ETS heat recovery chiller electrical energy consumption',
                 'quantity' : 'energy',
                 'actions'  : ['last'],
                 'captions' : ['Total heat recovery chiller electrical consumption']
                 },
                {'name' : 'bui.bui.QReqHea_flow',
                 'desc' : 'Space heating demand at the coil',
                 'quantity' : 'power',
                 'actions'  : ['max', 'plot'],
                 'captions' : ['Peak space heating load',
                               'Space heating load']
                 },
                {'name' : 'bui.bui.QReqCoo_flow',
                 'desc' : 'Space cooling demand at the coil',
                 'quantity' : 'power',
                 'actions'  : ['min', 'plot'],
                 'captions' : ['Peak cooling load',
                               'Cooling load']
                 },
                {'name' : 'dHHeaWat.y',
                 'desc' : 'Space heating load at the coil',
                 'quantity' : 'energy',
                 'actions'  : ['last'],
                 'captions' : ['Total space heating load']
                 },
                {'name' : 'dHChiWat.y',
                 'desc' : 'Space cooling load at the coil',
                 'quantity' : 'energy',
                 'actions'  : ['last'],
                 'captions' : ['Total cooling load']
                 },
            ]

actions = {'max': max,
           'min': min,
           'last': lambda y: y[-1]
           }

# the first scenario will be the baseline to be compared against
### replace this with a list of dict?
scenarios = [
                {'name'     : 'fTMY',
                 'mat_file' : 'ConnectedETSNoDHW_futu.mat',
                 'results'  : {}
                 },
                {'name'     : 'Heat wave',
                 'mat_file' : 'ConnectedETSNoDHW_heat.mat',
                 'results'  : {}
                 },
                {'name'     : 'Cold snap',
                 'mat_file' : 'ConnectedETSNoDHW_cold.mat',
                 'results'  : {}
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
for i, scenario in enumerate(scenarios):
    mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", scenario['mat_file']))
    r=Reader(mat_file_path, 'dymola')
    print(f'Scenario: {scenario["name"]}')
    for var in variables:
        y = find_var(var['name'])
        if len(y):
            scenario['results'][var['name']] = {}
            for action in var['actions']:
                if action in actions:
                    v = actions[action](y)
                    vstr = str_with_unit(v, var['quantity'])
                    msg = ' '*4+f"{var['captions'][0]}: {vstr:,.0f}"
                    print(msg)
                    
                    scenario['results'][var['name']][action] = v
                    # if i > 0:
                    #     baseline_value = scenario_results[scenarios[0]][var['name']][action]
                    #     comparison_msg = f"Comparison with baseline ({scenarios[0]}): {var['captions'][0]}: {vstr:,.0f} vs {str_with_unit(baseline_value, var['quantity']):,.0f}"
                    #     print(comparison_msg)
                else:
                    msg = f'## The action "{action}" is not defined for the varialbe "{var["name"]}"'
                    if PRINT_ACTION_NOT_FOUND:
                        print(msg)

