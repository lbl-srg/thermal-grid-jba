#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
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
    
    def f_to_c_T(f):
        """
        Converts temperature from F to C.
        
        Parameters
        ----------
        f : float
            farenheit

        """
        c = (f-32)*5/9
        return c
    
    def f_to_c_dT(f):
        """
        Converts temperature difference from F to C (K).

        Parameters
        ----------
        f : float
            farenheit

        """
        c = f*5/9
        return c
    
    dict_bui=dfBldg.loc[dfBldg['buil_no']==buil_no].to_dict('records')[0]
    
    name=dict_bui['name']
    filNam=f'"modelica://ThermalGridJBA/Resources/Data/Hubs/Individual/{buil_no}.mos"'
    TChi=f_to_c_T(f=dict_bui['chw_sup_f'])
    dTChi=f_to_c_dT(f=dict_bui['chw_dt_f'])
    THea=f_to_c_T(f=dict_bui['hhw_sup_f'])
    dTHea=f_to_c_dT(f=dict_bui['hhw_dt_f'])    
    
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
        f.write(f'    dTHeaWat_nominal={dTHea});\n')
        
        # tail
        f.write(f'end B{buil_no};')
        
#%% Main process
# Remove old files    
if flagRemoveOldFiles:
    for f in glob.glob(os.path.join(dirOutput,'B*.mo')):
        os.remove(f)

writeOneFile('1380')
