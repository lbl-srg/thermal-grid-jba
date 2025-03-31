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
                 'actions'  : ['last'],'unit' : uy.J,
                 'captions' : ['Total space heating load']
                 },
                {'name' : 'dHChiWat.y',
                 'desc' : 'Space cooling load at the coil',
                 'quantity' : 'energy',
                 'actions'  : ['last'],
                 'captions' : ['Total space cooling load']
                 },
            ]


r=Reader(mat_file_path, "dymola")

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
    

for var in variables:
    y = find_var(var['name'])
    if len(y):
        if 'max' in var['actions']:
            v = max(y)
        if 'min' in var['actions']:
            v = min(y)
        if 'last' in var['actions']:
            v = y[-1]
        vstr = str_with_unit(v, var['quantity'])
        msg = f"{var['captions'][0]}: {vstr:,.0f}"
        print(msg)

