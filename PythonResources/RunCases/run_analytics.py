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

# 'caption' is optional.
# if 'quantity' not given, treated as unit 1.
variables = [
                {'name' : 'EChi.u',
                 'quantity': 'power',
                 'action'  : max,
                 'caption' : 'ETS heat recovery chiller peak electric power input'
                 },
                {'name' : 'EChi.y',
                 'quantity': 'energy',
                 'action'  : lambda y: y[-1],
                 'caption' : 'ETS heat recovery chiller total electrical consumption'
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
                 'action'  : lambda y: y[-1],
                 'caption' : 'Total end-use space heating load'
                 },
                {'name' : 'dHChiWat.y',
                 'quantity': 'energy',
                 'action'  : lambda y: y[-1],
                 'caption' : 'Total end-use cooling load'
                 },
                {'name' : 'bui.ets.heaPum.heaPum.ySet',
                 'quantity': 'time',
                 'action'  : lambda y: condition_duration(t, y, lambda y: y > 0.99),
                 'caption' : 'Total duration of chiller speed > 0.99'}
            ]

# scenarios = [
#                 {'name'    : 'fTMY',
#                   'matFile' : os.path.join('cluster_B_futu','ConnectedETSWithDHW.mat'),
#                   'results' : {}
#                   },
#                 {'name'    : 'Heat wave',
#                   'matFile' : os.path.join('cluster_B_heat','ConnectedETSWithDHW.mat'),
#                   'results' : {}
#                   },
#                 {'name'    : 'Cold snap',
#                   'matFile' : os.path.join('cluster_B_cold','ConnectedETSWithDHW.mat'),
#                   'results' : {}
#                   }
#             ]

scenarios = [
                {'name'    : 'A',
                  'matFile' : os.path.join('cluster_A_futu','ConnectedETSNoDHW.mat'),
                  'results' : {}
                  },
                {'name'    : 'B',
                  'matFile' : os.path.join('cluster_B_futu','ConnectedETSWithDHW.mat'),
                  'results' : {}
                  },
                {'name'    : 'C',
                  'matFile' : os.path.join('cluster_C_futu','ConnectedETSWithDHW.mat'),
                  'results' : {}
                  },
                {'name'    : 'D',
                  'matFile' : os.path.join('cluster_D_futu','ConnectedETSWithDHW.mat'),
                  'results' : {}
                  },
                {'name'    : 'E',
                  'matFile' : os.path.join('cluster_E_futu','ConnectedETSWithDHW.mat'),
                  'results' : {}
                  }
            ]

# scenarios = [
#                 {'name'    : 'fTMY',
#                   'matFile' : 'ETS_All_futu/ConnectedETSWithDHW.mat',
#                   'results' : {}
#                   },
#                 {'name'    : 'Heat wave',
#                   'matFile' : 'ETS_All_heat/ConnectedETSWithDHW.mat',
#                   'results' : {}
#                   },
#                 {'name'    : 'Cold snap',
#                   'matFile' : 'ETS_All_cold/ConnectedETSWithDHW.mat',
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

def section_data(t, y, timeperiod):
    """ Take out a section of the data.
    """
    indices = np.where(condition(y))[0]
    duration = 0.0
    for i in range(1, len(indices)):
        if indices[i] == indices[i-1] + 1:  # Check if the indices are consecutive
            duration += t[indices[i]] - t[indices[i-1]]

    return duration


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
            v_converted = (v * units[var['quantity']]['unit']).to(units[var['quantity']]['displayUnit']).value
            if abs(v_converted) >= 1000:
                format_string = r',.0f'
            else:
                format_string = r'.3g'
            displayValue = f"{v_converted:{format_string}}"
        else:
            displayValue = f"{v:.3g}"
        if PRINT_COMPARISON:
            if i == 0 :
                vBase = v
            else:
                displayCompare = f"{v/vBase-1:+.1%}"
                displayValue += f' ({displayCompare})'
        row += f" | {displayValue:>{TABLE_WIDTH}}"
    print(row)

