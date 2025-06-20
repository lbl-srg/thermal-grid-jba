#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 18 21:40:30 2025

@author: casper
"""

import os
import pandas as pd
import numpy as np
from GetVariables import integrate_with_condition
from buildingspy.io.outputfile import Reader

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))
mat_file_name = os.path.join(CWD, "simulations", "2025-06-16", "2025-06-16-11d10-DetailedPlantFiveHubs.mat")

J_to_MWh = 1 / 3.6e9

#%%
r=Reader(mat_file_name, "dymola")

#%%
def read_parameter(varName):
    """ Returns the first value of a series read from mat file.
    """
    (t, y) = r.values(varName)
    return y[0]

def read_last(varName):
    """ Returns the last value of a series read from mat file.
    """
    (t, y) = r.values(varName)
    return np.array(y)[-1]

def read_max_abs(varName):
    """ Returns the max of abs of a series read from the mat file.
    """
    return max(r.max(varName), abs(r.min(varName)))

def sum_elements_series(varPattern):
    """ Returns a series of the sum of all variables that fit the regex pattern.
    """
    varnames = r.varNames(varPattern)
    (_t, _y) = r.values(varnames[0])
    y = np.zeros(len(_t))
    
    for var in varnames:
        (_t, _y) = r.values(var)
        y += _y
        
    return y

def sum_elements_parameter(varPattern):
    """ Returns the sum of the varname[0] for all varname that fits the regex pattern.
    """
    varnames = r.varNames(varPattern)
    y = 0.
    
    for var in varnames:
        y += read_parameter(var)
    
    return y

def construct_df(varNames):
    """ Construct a pandas datafram with the given variable names.
          'Time' will be added as well.
        This is for compatibility with functions from GetVariables.
    """
    data = {}
    (_t, _y) = r.values(varNames[0])
    data['Time'] = _t
    
    for var in varNames:
        (_t, _y) = r.values(var)
        data[var] = _y
    
    df= pd.DataFrame(data)
    
    return df    

def print_row(desc,
              valu,
              conv,
              form,
              unit
              ):
    
    print(f'{desc}: {valu*conv:{form}} {unit}')
    
print_row(desc = 'Imported energy',
          valu = read_last("ETot.y"),
          conv = J_to_MWh,
          form = ',.0f',
          unit = 'MWh'
          )

print_row(desc = 'Peak electricity import',
          valu = read_max_abs("multiSum.y"),
          conv = 1e-3,
          form = '.0f',
          unit = 'kW'
          )

print(f'Life-cycle cost: ** in progress **')
print(f'Life-cycle cost: ** in progress **')
print(f'Levelized cost of thermal energy: ** in progress **')
print('')

val = abs(sum_elements_parameter("bui\[.\].ets.heaPum.heaPum.QHea_flow_nominal"))
print_row(desc = 'Capacity of ETS HP (heating)',
          valu = val,
          conv = 1e-6,
          form = ',.1f',
          unit = 'MW'
          )

val = abs(sum_elements_parameter("bui\[.\].ets.heaPum.heaPum.QCoo_flow_nominal"))
print_row(desc = 'Capacity of ETS HP (cooling)',
          valu = val,
          conv = 1e-6,
          form = ',.1f',
          unit = 'MW'
          )

# COP of ETS HP
ets_modes = ['overall',
             'heating only',
             'cooling only',
             'simultaneous']
Q_ets = {mode : 0. for mode in ets_modes}
P_ets = {mode : 0. for mode in ets_modes}

for i in range(1,6):
    df_etsHp = construct_df([f'bui[{i}].ets.heaPum.heaPum.QCon_flow',
                             f'bui[{i}].ets.heaPum.heaPum.QEva_flow',
                             f'bui[{i}].ets.heaPum.heaPum.P',
                             f'bui[{i}].ets.heaPum.con.hea.y',
                             f'bui[{i}].ets.heaPum.con.uCoo'])
    
    conditions = dict()
    conditions['heating'] = np.array(df_etsHp[f'bui[{i}].ets.heaPum.con.hea.y'] > 0.9)
    conditions['cooling'] = np.array(df_etsHp[f'bui[{i}].ets.heaPum.con.uCoo'] > 0.9)
    conditions['overall']      = np.logical_or(conditions['heating'], conditions['cooling'])
    conditions['heating only'] = np.logical_and(conditions['heating'], np.logical_not(conditions['cooling']))
    conditions['cooling only'] = np.logical_and(np.logical_not(conditions['heating']), conditions['cooling'])
    conditions['simultaneous'] = np.logical_and(conditions['heating'], conditions['cooling'])
    
    for mode in ets_modes:
        Q_ets[mode] += integrate_with_condition(df_etsHp, f'bui[{i}].ets.heaPum.heaPum.QCon_flow',
                                                condition = conditions[mode])
        P_ets[mode] += integrate_with_condition(df_etsHp, f'bui[{i}].ets.heaPum.heaPum.P',
                                                condition = conditions[mode])

for mode in ets_modes:
    val = Q_ets[mode] / P_ets[mode]
    print_row(desc = f'Average COP of ETS HP ({mode})',
              valu = val,
              conv = 1,
              form = '.2f',
              unit = '-'
              )

print_row(desc = 'Capacity of central HP (heating)',
          valu = abs(read_parameter("cenPla.gen.heaPum.QHea_flow_nominal")),
          conv = 1e-6,
          form = '.1f',
          unit = 'MW'
          )

print_row(desc = 'Capacity of central HP (cooling)',
          valu = abs(read_parameter("cenPla.gen.heaPum.QCoo_flow_nominal")),
          conv = 1e-6,
          form = '.1f',
          unit = 'MW'
          )

df_cenHp = construct_df(['cenPla.gen.heaPum.QCon_flow',
                         'cenPla.gen.heaPum.QEva_flow',
                         'cenPla.gen.heaPum.P',
                         'cenPla.gen.heaPum.hea'])

condition = np.array(df_cenHp['cenPla.gen.heaPum.hea'] > 0.9) # heating mode
val = integrate_with_condition(df_cenHp, 'cenPla.gen.heaPum.QCon_flow',
                               condition = condition) / \
      integrate_with_condition(df_cenHp, 'cenPla.gen.heaPum.P',
                               condition = condition)
print_row(desc = 'Average COP of central HP (heating)',
          valu = val,
          conv = 1,
          form = '.2f',
          unit = '-'
          )

condition = np.array(df_cenHp['cenPla.gen.heaPum.hea'] < 0.1) # cooling mode
val = integrate_with_condition(df_cenHp, 'cenPla.gen.heaPum.QEva_flow',
                               condition = condition) / \
      integrate_with_condition(df_cenHp, 'cenPla.gen.heaPum.P',
                               condition = condition)
print_row(desc = 'Average COP of central HP (cooling)',
          valu = val,
          conv = 1,
          form = '.2f',
          unit = '-'
          )

print_row(desc = 'BTES capacity',
          valu = read_max_abs("EBorPer.y") + read_max_abs("EBorCen.y"),
          conv = J_to_MWh,
          form = ',.0f',
          unit = 'MWh'
          )

print('PV capacity: 8.68 MWp (directly using MILP value)')
print('Battery capacity: 4.36 MWh (directly using MILP value)')

