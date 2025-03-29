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

variables = [
                {'name' : 'EChi.u',
                 'desc' : 'ETS heat recovery chiller electric power input',
                 'unit' : uy.W,
                 'actions' : ['max', 'plot']
                 },
                {'name' : 'EChi.y',
                 'desc' : 'ETS heat recovery chiller electrical energy consumption',
                 'unit' : uy.J,
                 'actions' : ['last']
                 },
                {'name' : 'bui.bui.QReqHea_flow',
                 'desc' : 'Space heating demand at the coil',
                 'unit' : uy.W,
                 'actions' : ['max', 'plot']
                 },
                {'name' : 'bui.bui.QReqCoo_flow',
                 'desc' : 'Space cooling demand at the coil',
                 'unit' : uy.W,
                 'actions' : ['min', 'plot']
                 },
                {'name' : 'dHHeaWat.y',
                 'desc' : 'Space heating load at the coil',
                 'unit' : uy.J,
                 'actions' : ['last']
                 },
                {'name' : 'dHChiWat.y',
                 'desc' : 'Space cooling load at the coil',
                 'unit' : uy.J,
                 'actions' : ['last']
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

for var in variables:
    y = find_var(var['name'])
    if len(y):
        if 'max' in var['actions']:
            print(max(y))
        if 'min' in var['actions']:
            print(min(y))
        if 'last' in var['actions']:
            print(y[-1])

