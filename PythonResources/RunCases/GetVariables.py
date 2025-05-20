#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 12 22:04:07 2025

@author: casper

This file gets variables from the result mat file and returns at pandas dataframe.
There are two options:
    1. Ready the mat file directly with BuildingsPy.
    2. First convert the mat file to a csv file with only the needed variables,
         then read it with pandas. This is for when the mat file is too big.
"""

import os

import pandas as pd

from typing import Literal, get_args

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))

#%%
_methods = Literal["buildingspy", "dymola"]
def get_vars(var_list,
             mat_file_path,
             method : _methods = 'buildingspy',
             csv_file_path = None,
             delete_csv = False):
    """    
    """
    def generate_dymola_command(var_list, mat_file_path, csv_file_path):
        """ Generate Dymola command to export csv from large mat file
        """ 
        s = ''
        s += f'DataFiles.convertMATtoCSV("{mat_file_path}", '
        s += '{"'
        s += '","'.join(var_list)
        s += '"}, '
        s += f'"{csv_file_path}");'
            
        return s    
        # __ref = r'DataFiles.convertMATtoCSV("/home/casper/gitRepo/thermal-grid-jba/PythonResources/RunCases/simulations/2025-05-05-simulations/detailed_plant_five_hubs_futu/DetailedPlantFiveHubs.mat", {"bui[1].ets.chi.chi.COP","bui[1].ets.chi.uCoo"}, "/home/casper/gitRepo/thermal-grid-jba/PythonResources/RunCases/simulations/2025-05-05-simulations/detailed_plant_five_hubs_futu/trimmed.csv");'
    
    if csv_file_path is None:
        csv_file_path = mat_file_path.replace('.mat', '.csv')
    
    df = pd.DataFrame()
    methods = list(get_args(_methods))
    
    if method == methods[0]:
        # 'buildingspy'
        from buildingspy.io.outputfile import Reader
        r=Reader(mat_file_path, 'dymola')
        for var in var_list:
            (t, y) = r.values(var)
            if len(t) > 2 and not 'Time' in df.columns:
                df['Time'] = t # writes the time stamp
            df[var] = y
    
    if method == methods[1]:
        # 'dymola'
        # Dymola-python interface: see Dymola user manual 12.3
        from dymola.dymola_interface import DymolaInterface
        # Install this with
        #    <...>/Dymola-2025x-x86_64/Modelica/Library/python_interface/dymola-2024.1-py3-none-any.whl
        dymola = DymolaInterface("/usr/local/bin/dymola")
        dymola_command = generate_dymola_command(var_list,
                                                 mat_file_path,
                                                 csv_file_path)
        dymola.ExecuteCommand(dymola_command)
        df = pd.read_csv(csv_file_path, header = 0)
        
        if delete_csv:
            os.remove(csv_file_path)
            
    return df        

#%%
def index_var_list(pre_index, holder, i):
    """ Replaces the `holder` string in `pre_index` with index `i`.
        Both `pre_index` and `i` can be either a single value or a list.
    """
    
    _pre_index = [pre_index] if isinstance(pre_index, str) else pre_index
    _i = [i] if isinstance(i, int) else i
    
    var_list = list()
    for pre, ind in [(pre, ind) for pre in _pre_index for ind in _i]:
        var_list.append(pre.replace(holder,str(ind)))
        
    return var_list

#%%
if __name__ == "__main__":
    mat_file_path = os.path.join(CWD, "simulations", "ETS_All_futu", "ConnectedETSWithDHW.mat")
    #csv_file_path = os.path.join(CWD, "simulations", "ETS_All_futu", "ConnectedETSWithDHW.csv")
    
    var_list = ['EChi.u', 'EChi.y']
    
    df_bp = get_vars(var_list,
                     mat_file_path,
                     'buildingspy')
    df_dy = get_vars(var_list,
                     mat_file_path,
                     'dymola')
    