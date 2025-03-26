#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 26 11:35:45 2025

@author: casper
"""

import matplotlib.pyplot as plt
import os

from buildingspy.io.outputfile import Reader

CWD = os.getcwd()

MAT_FILES = [{'scenario' : 'futu',
              'mat_file' : 'ConnectedETSNoDHW_futu.mat'},
             {'scenario' : 'heat',
              'mat_file' : 'ConnectedETSNoDHW_heat.mat'},
             {'scenario' : 'cold',
              'mat_file' : 'ConnectedETSNoDHW_cold.mat'}]

for mat in MAT_FILES:
    print(f"Scenario: {mat['scenario']}")
    filepath = os.path.realpath(os.path.join(CWD, '../../RunCases/simulations', mat['mat_file']))
    r=Reader(filepath, "dymola")
    (t, y) = r.values('EChi.u')
    v = max(y)/1000
    print(" "*4 + f"Max chiller power input = {v:.0f} kW")
    (t, y) = r.values('EChi.y')
    v = y[-1]/3600/1000/1000
    print(" "*4 + f"Cumulative chiller power input = {v:.0f} MWh")

