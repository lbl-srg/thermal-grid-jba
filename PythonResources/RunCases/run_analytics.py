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
import analyses

WHAT_TO_RUN = "coldsnap"
""" See `analyses.py`, case insensitive:
        cluster: minimum test to see if things can run
        heatwave: explicitly listed cases
        coldsnap: each building, differentiating with or without DHW
"""

PRINT_COMPARISON = True # percentage comparison
TABLE_WIDTH = 15

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

def section_data(t, y, timeperiod):
    """ Take out a section of the data.
    """
    seconds_start = timeperiod[0]
    seconds_end = timeperiod[1]
    mask = (t >= seconds_start) & (t < seconds_end)
    t_sectioned = t[mask]
    y_sectioned = y[mask]
    
    return t_sectioned, y_sectioned

#%%
analysis = analyses.get_analysis(WHAT_TO_RUN)

for scenario in analysis['scenarios']:
    mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", scenario['matFile']))
    r=Reader(mat_file_path, 'dymola')
    for var in analysis['variables']:
        #y = find_var(var['name'])
        (t, y) = r.values(var['name'])
        t, y = section_data(t, y, analysis['timePeriod'])
        if len(t) > 2 and not 'time' in scenario['results']:
            scenario['results']['time'] = t # writes the time stamp
        v = var['action'](t, y)
        scenario['results'][var['name']] = v

#%%
row = f"{'Scenarios:':<{TABLE_WIDTH}}"
for s in analysis['scenarios']:
    row += f" | {s['name']:<{TABLE_WIDTH}}"
print(row)
for var in analysis['variables']:
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
    for i,scenario in enumerate(analysis['scenarios']):
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
    
