#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 31 23:10:52 2025

@author: casper

commit: 365ad83a95dcb9e98b65be55b2e049833461cb06
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
COP = np.array(y)
(t,y) = r.values('bui.ets.valIsoEva.y_actual')
yIsoEva = np.array(y)
(t,y) = r.values('bui.ets.valIsoCon.y_actual')
yIsoCon = np.array(y)

# remove the start up transient
COP = COP[10:]
yIsoEva = yIsoEva[10:]
yIsoCon = yIsoCon[10:]

COP_rejCoo = COP[yIsoEva > 0.5] # rejecting cooling
COP_rejCoo = COP_rejCoo[COP_rejCoo > 0.01]
COP_rejHea = COP[yIsoCon > 0.5] # rejecting heating
COP_rejHea = COP_rejHea[COP_rejHea > 0.01]

print(f"Max of COP_rejCoo = {max(COP_rejCoo)}")
print(f"Min of COP_rejHea = {min(COP_rejHea)}")
