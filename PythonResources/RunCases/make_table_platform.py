#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 18 21:40:30 2025

@author: casper
"""

import os
import pandas as pd
import numpy as np
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
print('')

val = abs(sum_elements_parameter("bui\[.\].ets.heaPum.heaPum.QHea_flow_nominal"))
print_row(desc = 'Capacity of ETS HP (heating)',
          valu = val,
          conv = 1e-6,
          form = ',.1f',
          unit = 'MW'
          )

# cooling + heating + dhw load sums from load files, kWh.
# hardcoded here because they are not integrated in the Modelica model.
# should not change as long as the weather scenario doesn't change
val = (16908187.6350861 + 10080563.2344998 + 4748967.95197562)/1000 / (read_last("EHeaPum.y")*J_to_MWh)
print_row(desc = 'Average COP of ETS HP',
          valu = val,
          conv = 1,
          form = '.2f',
          unit = '-'
          )

print_row(desc = 'Capacity of central HP (cooling)',
          valu = abs(read_parameter("cenPla.gen.heaPum.QCoo_flow_nominal")),
          conv = 1e-6,
          form = '.1f',
          unit = 'MW'
          )

print(f'Average COP of central HP: ** in progress **')

print_row(desc = 'BTES capacity',
          valu = read_max_abs("EBorPer.y") + read_max_abs("EBorCen.y"),
          conv = J_to_MWh,
          form = ',.0f',
          unit = 'MWh'
          )

print('PV capacity: N/A')

