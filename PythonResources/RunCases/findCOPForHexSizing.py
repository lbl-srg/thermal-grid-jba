#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 31 23:10:52 2025

@author: casper

commit: 8d86f82816bbf00f84af8f0e64a19392caf6f1e3
simulateModel("ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW", tolerance=1e-6, startTime=0, stopTime=365*24*3600, method="CVode", resultFile="ConnectedETSWithDHW");
filNam="modelica://ThermalGridJBA/Resources/Data/Consumptions/All.mos"

"""

import os
import numpy as np
from buildingspy.io.outputfile import Reader

CWD = os.getcwd()
MAT_FILE_NAME = "ConnectedETSWithDHW_All.mat"
mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", MAT_FILE_NAME))

r=Reader(mat_file_path, "dymola")

(t,y) = r.values('bui.ets.chi.chi.COP')
data = np.array(y)

data = data[10:]
data = data[data > 0.01]

maximum = np.max(data)
percentile_95 = np.percentile(data, 95)
median = np.median(data)
percentile_5 = np.percentile(data, 5)
minimum = np.min(data)
mean = np.mean(data)

print(f"Maximum: {maximum}")
print(f"95th Percentile: {percentile_95}")
print(f"Median: {median}")
print(f"5th Percentile: {percentile_5}")
print(f"Minimum: {minimum}")
print(f"Mean: {mean}")
