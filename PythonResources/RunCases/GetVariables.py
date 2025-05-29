#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 12 22:04:07 2025

@author: casper

This file defines a few utility functions for post processing.
"""

import os

import numpy as np
import pandas as pd

from typing import Literal, get_args
from scipy.integrate import trapz

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))

#%%
_methods = Literal["buildingspy", "dymola"]
def get_vars(var_list,
             mat_file_path,
             method : _methods = 'buildingspy',
             csv_file_path = None,
             delete_csv = False):
    """ Gets variables from the result mat file and returns at pandas dataframe.
        There are two options:
        1. Ready the mat file directly with BuildingsPy.
        2. First convert the mat file to a csv file with only the needed variables,
             then read it with pandas. This is for when the mat file is too big.
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
    no_index = set()
    for pre in _pre_index:
        if holder in pre:  # check if `pre` has an index holder
            for ind in _i:
                var_list.append(pre.replace(holder, str(ind)))
        else:
            no_index.add(pre)  # if not, put it in a set to avoid duplicating
    var_list += list(no_index)
    
    return var_list

#%%
def integrate_with_condition(df, var, sign = None, condition = None):
    """ Integrates df[var] along df['Time']
        `sign` can be the following (case insensitive):
            'positive' - Only integrates positive values of u,
                           zero crossing points are found linearly and inserted
                           to the series.
            'negative' - Similar to above but negative.
        `condition` is a Boolean array.
            Only integrates u where condition is True,
            when `condition` flips from True at t1 to False at t2,
              a point (t2, 0) is inserted after (t2, u2) to create a step down;
            when `condition` flips from False at t3 to True at t4,
              a point (t4, 0) is inserted before (t4, u4) to create a step up;
            set u = 0 for all points between t2 and t3.
        The input needs to be a pandas dataframe because the results data are
            often stored as such, and it is easy to make a copy-vs-write mistake
            when assessing series originated from a pandas dataframe.
            By making the conversion inside this function, this operation is
            centralised and such mistakes are easier to spot and fix.
            https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
    """
    
    u = np.array(df[var])
    t = np.array(df['Time'])
    
    # `condition` must to be evaluated before `sign`
    #   because it relies on the original array length
    #   and both `condition` and `sign` may add elements to the array.
    if not condition is None:
        
        _t = []
        _u = []
        i = 0
        
        while i < len(t) - 1:
            _t.append(t[i])
            
            if condition[i] and not condition[i + 1]:
                # creates a step down at True to False
                _t.append(t[i+1])
                _u.append(u[i])
                _u.append(0.)
        
            elif not condition[i] and condition[i + 1]:
                # creates a step up at False to True
                _t.append(t[i+1])
                _u.append(0.)
                _u.append(u[i+1])
        
            else:
                if condition[i]:
                    _u.append(u[i])
                else:
                    _u.append(0.)
            i += 1
        
        # last point
        _t.append(t[i])
        _u.append(u[i])
        
        t = _t
        u = _u
    
    def find_zero_crossings(t, u):
        """ Find indices where the sign of u changes
        """
        sign_changes = np.where(np.diff(np.sign(u)))[0]
        
        # Initialize lists to store zero crossing times and values
        zero_crossing_times = []
        zero_crossing_values = []
    
        for i in sign_changes:
            # Perform linear interpolation to find the exact zero crossing time
            t1, t2 = t[i], t[i + 1]
            u1, u2 = u[i], u[i + 1]
            
            # Calculate the zero crossing time
            t_zero = t1 - u1 * (t2 - t1) / (u2 - u1)
            u_zero = 0.0
            
            # Append the zero crossing time and value to the lists
            zero_crossing_times.append(t_zero)
            zero_crossing_values.append(u_zero)
    
        return zero_crossing_times, zero_crossing_values
    
    if sign in ['positive', 'negative']:
        t_crossing, u_crossing = find_zero_crossings(t, u)
        # Insert zero crossings into the original time series
        for t_zero, u_zero in zip(t_crossing, u_crossing):
            idx = np.searchsorted(t, t_zero)
            t = np.insert(t, idx, t_zero)
            u = np.insert(u, idx, u_zero)
        
        if sign == 'positive':
            u[u<0] = 0
        if sign == 'negative':
            u[u>0] = 0
        
    I = trapz(u, t)
    return I

#%%
if __name__ == "__main__":
    # mat_file_path = os.path.join(CWD, "simulations", "ETS_All_futu", "ConnectedETSWithDHW.mat")
    # #csv_file_path = os.path.join(CWD, "simulations", "ETS_All_futu", "ConnectedETSWithDHW.csv")
    
    # var_list = ['EChi.u', 'EChi.y']
    
    # df_bp = get_vars(var_list,
    #                  mat_file_path,
    #                  'buildingspy')
    # df_dy = get_vars(var_list,
    #                  mat_file_path,
    #                  'dymola')
    
    _i = r'%%i%%'
    var_list_pre_index = [f'with_index[{_i}]', 'no_index']
    var_list_indexed = index_var_list(var_list_pre_index,
                                      _i,
                                      [1,2])
    