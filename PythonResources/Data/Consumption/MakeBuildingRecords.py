#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
!!! No longer useful !!!

This file creates Modelica records
    for building load profile file name and set points.

Created on Fri Jun 28 16:31:13 2024

@author: casper
"""

from _config_estcp import *

import glob
import numpy as np
import os

#%% Flags
dirOutput  = os.path.realpath(os.path.join(os.path.realpath(__file__),'../../../../ThermalGridJBA/Data/Individual'))

flagRemoveOldFiles = True

#%% Functions
def writeOneFile(buil_no : str):
    """
    Writes one Modelica record for the selected building.
    
    Parameters
    ----------
    buil_no : str
        building number
        
    """
    
    dict_bui=dfBldg.loc[dfBldg['buil_no']==buil_no].to_dict('records')[0]
    
    name=dict_bui['name']
    filNam=f'"modelica://ThermalGridJBA/Resources/Data/Hubs/Individual/{buil_no}.mos"'
    TChi=f_to_c_T(f=dict_bui['chw_sup_f'])
    dTChi=f_to_c_dT(f=dict_bui['chw_dt_f'])
    THea=f_to_c_T(f=dict_bui['hhw_sup_f'])
    if THea > 60:
        THea = 60 # Forces HHW supply to be no higher than 60 C (140 F)
    dTHea=min(f_to_c_dT(f=dict_bui['hhw_dt_f']), dTChi) # Use dTChi for dTHea
    THot=f_to_c_T(f=dict_bui['dhw_sup_f'])
    haveHot=dict_bui['have_dhw']
    
    with open(os.path.join(dirOutput, f'B{buil_no}.mo'), 'w') as f:
        # header
        f.write(f'within ThermalGridJBA.Data.Individual;\n')
        f.write(f'record B{buil_no}\n')
        f.write(f'  "Data record for {buil_no} {name}"\n')
        f.write(f'  extends GenericConsumer(\n')
        
        # parameters
        f.write(f'    filNam={filNam},\n')
        f.write(f'    TChiWatSup_nominal={TChi}+273.15,\n')
        f.write(f'    dTChiWat_nominal={dTChi},\n')
        f.write(f'    THeaWatSup_nominal={THea}+273.15,\n')
        f.write(f'    dTHeaWat_nominal={dTHea},\n')
        f.write(f'    THotWatSup_nominal={THot}+273.15,\n')
        f.write(f'    have_hotWat={haveHot});\n')
        
        # tail
        f.write(f'end B{buil_no};')
    
    open(os.path.join(dirOutput,'package.order'),'a').write(f'B{buil_no}\n')
    
#%% Main process
# Remove old files    
if flagRemoveOldFiles:
    for f in glob.glob(os.path.join(dirOutput,'B*.mo')):
        os.remove(f)
    open(os.path.join(dirOutput,'package.order'),'w').close()

for bui in buil_nos:
    writeOneFile(bui)
