#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This file makes various misc load computations.
1. How long it takes to charge 24 hrs of DHW tank capacity
    with nomical HRC capacity
2. How the HHW supply temp can be reset from baseline to post-ECM peak load

Created on Fri Jul 12 22:10:25 2024

@author: casper
"""

from _config_estcp import *

import numpy as np

#%% 1. Compute DHW tank charging time with nominal HRC capacity
stag = 'post'
for bui in buil_nos:
    if findMeta(bui,'have_dhw') == 'false':
        continue
    hea = np.array(readMID(f'{stag}_{bui}_hea'))
    coo = np.array(readMID(f'{stag}_{bui}_coo'))
    dhw = np.array(readMID(f'{stag}_{bui}_dhw'))
    Qhea_n = np.max(hea) # nominal heating heat flow rate
    Qcoo_n = np.max(coo) # nominal cooling heat flow rate
    #dThea = f_to_c_T(findMeta(bui,'hhw_dt_f')) # heating Delta-T
    #cp = 4186 # specific heat capacity of water
    Edhw_d = np.sum(dhw[0:24]) # daily DHW consumption, same every day
    COPc = 5 # cooling COP
    tcharge_h = Edhw_d / Qhea_n
    tcharge_c = Edhw_d / (Qcoo_n * (1+COPc)/COPc)
    print(f'{bui}: {Edhw_d:.0f} kWh/d, {Qhea_n:.0f} kW, {tcharge_h:.1f} h, -{Qcoo_n:.0f} kW, {tcharge_c:.1f} h')

#%% 2. Compute HHW supply temp reset from baseline to post-ECM peak load
for bui in buil_nos:
    Qhea_base = np.max(np.array(readMID(f'base_{bui}_hea')))
    Qhea_post = np.max(np.array(readMID(f'post_{bui}_hea')))
    gamma = Qhea_post / Qhea_base
    Tsup_base = f_to_c_T(findMeta(bui, 'hhw_sup_f'))
    dT = f_to_c_dT(findMeta(bui,'hhw_dt_f'))
    Troo = f_to_c_T(70)
    Tsup_post = gamma * Tsup_base + (1-gamma) * (dT/2 + Troo)
    print(f'{bui}: {gamma:.2f}, {Tsup_base:.0f} C, {Tsup_post:.0f} C')
    