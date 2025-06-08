#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 31 23:10:52 2025

@author: casper

commit: 365ad83a95dcb9e98b65be55b2e049833461cb06
simulateModel("ThermalGridJBA.Hubs.Validation.ConnectedETSWithDHW", tolerance=1e-6, startTime=0, stopTime=365*24*3600, method="CVode", resultFile="ConnectedETSWithDHW");
filNam="modelica://ThermalGridJBA/Resources/Data/Consumptions/All_futu.mos"

"""

import os
import numpy as np
from buildingspy.io.outputfile import Reader

CWD = os.getcwd()
MAT_FILE_NAME = os.path.join("ETS_All_futu","ConnectedETSWithDHW.mat")
mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", MAT_FILE_NAME))

r=Reader(mat_file_path, "dymola")

(t,y) = r.values('bui.ets.heaPum.heaPum.COP')
COP = np.array(y)
(t,y) = r.values('bui.ets.valIsoEva.y_actual')
yIsoEva = np.array(y)
(t,y) = r.values('bui.ets.valIsoCon.y_actual')
yIsoCon = np.array(y)
(t,y) = r.values('bui.ets.chi.senTConEnt.T')
TConEnt = np.array(y)
(t,y) = r.values('bui.ets.chi.senTConLvg.T')
TConLvg = np.array(y)
(t,y) = r.values('bui.ets.chi.senTEvaEnt.T')
TEvaEnt = np.array(y)
(t,y) = r.values('bui.ets.chi.senTEvaLvg.T')
TEvaLvg = np.array(y)

# remove the start up transient
COP = COP[10:]
yIsoEva = yIsoEva[10:]
yIsoCon = yIsoCon[10:]
TConEnt = TConEnt[10:]
TConLvg = TConLvg[10:]
TEvaEnt = TEvaEnt[10:]
TEvaLvg = TEvaLvg[10:]

# cooling rejection
mask_cooRej = (yIsoEva > 0.5) & (COP > 0.01)
max_index_cooRej = np.argmax(COP[mask_cooRej])
COP_cooRej = COP[mask_cooRej][max_index_cooRej]
TConEnt_cooRej = TConEnt[mask_cooRej][max_index_cooRej]
TConLvg_cooRej = TConLvg[mask_cooRej][max_index_cooRej]
TEvaEnt_cooRej = TEvaEnt[mask_cooRej][max_index_cooRej]
TEvaLvg_cooRej = TEvaLvg[mask_cooRej][max_index_cooRej]

# heating rejection
mask_heaRej = (yIsoCon > 0.5) & (COP > 0.01)
max_index_heaRej = np.argmin(COP[mask_heaRej])
COP_heaRej = COP[mask_heaRej][max_index_heaRej]
TConEnt_heaRej = TConEnt[mask_heaRej][max_index_heaRej]
TConLvg_heaRej = TConLvg[mask_heaRej][max_index_heaRej]
TEvaEnt_heaRej = TEvaEnt[mask_heaRej][max_index_heaRej]
TEvaLvg_heaRej = TEvaLvg[mask_heaRej][max_index_heaRej]

#%%
def temp_c_f(T):
    c = T - 273.15
    f = c * 9 / 5 + 32

    return f"{c:.2f} C / {f:.2f} F"


print("** Cooling rejection: **")
print(f"COP = {COP_cooRej:.2f}")
print(f"TConEnt = {temp_c_f(TConEnt_cooRej)}")
print(f"TConLvg = {temp_c_f(TConLvg_cooRej)}")
print(f"TEvaEnt = {temp_c_f(TEvaEnt_cooRej)}")
print(f"TEvaLvg = {temp_c_f(TEvaLvg_cooRej)}")

print("** Heating rejection: **")
print(f"COP = {COP_heaRej:.2f}")
print(f"TConEnt = {temp_c_f(TConEnt_heaRej)}")
print(f"TConLvg = {temp_c_f(TConLvg_heaRej)}")
print(f"TEvaEnt = {temp_c_f(TEvaEnt_heaRej)}")
print(f"TEvaLvg = {temp_c_f(TEvaLvg_heaRej)}")