#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr 15 18:28:30 2025

@author: casper
"""

import os
import numpy as np
from datetime import datetime, timedelta

def get_analysis(whattorun : str):
    ''' Return the analysis cases to be run.

        For inputs see `run_analysis.py`.
    '''
    
    hup = whattorun.upper()
    analysis = dict()
    if hup == 'CLUSTER':
        analysis = cluster_results()
    elif hup == 'HEATWAVE':
        analysis = heat_wave()
    elif hup == 'COLDSNAP':
        analysis = cold_snap()
        
    return analysis

def cluster_results():
    """ List ETS cluster results.
        Not meant for comparison.
    """
    analysis = {}
    analysis['timePeriod'] = [0, 365*24*3600]
    
    variables = [
                    {'name' : 'EChi.u',
                     'quantity': 'power',
                     'action'  : lambda t, y: max(y),
                     'caption' : 'Peak electric power input of ETS heat recovery chiller'
                     },
                    {'name' : 'EChi.y',
                     'quantity': 'energy',
                     'action'  : lambda t, y: y[-1] - y[0],
                     'caption' : 'Total electrical consumption of ETS heat recovery chiller'
                     },
                    {'name' : 'bui.bui.QReqHea_flow',
                     'quantity': 'power',
                     'action'  : lambda t, y: max(y),
                     'caption' : 'Peak end-use space heating load'
                     },
                    {'name' : 'bui.bui.QReqCoo_flow',
                     'quantity': 'power',
                     'action'  : lambda t, y: min(y),
                     'caption' : 'Peak end-use cooling load'
                     },
                    {'name' : 'dHHeaWat.y',
                     'quantity': 'energy',
                     'action'  : lambda t, y: y[-1] - y[0],
                     'caption' : 'Total end-use space heating load'
                     },
                    {'name' : 'dHChiWat.y',
                     'quantity': 'energy',
                     'action'  : lambda t, y: y[-1] - y[0],
                     'caption' : 'Total end-use cooling load'
                     },
                    {'name' : 'bui.ets.chi.chi.ySet',
                     'quantity': 'time',
                     'action'  : lambda t, y: condition_duration(t, y, lambda y: y > 0.99),
                     'caption' : 'Total duration of chiller speed > 0.99'}
                ]
    
    scenarios = [
                    {'name'    : 'A',
                      'matFile' : os.path.join('cluster_A_futu','ConnectedETSNoDHW.mat'),
                      'results' : {}
                      },
                    {'name'    : 'B',
                      'matFile' : os.path.join('cluster_B_futu','ConnectedETSWithDHW.mat'),
                      'results' : {}
                      },
                    {'name'    : 'C',
                      'matFile' : os.path.join('cluster_C_futu','ConnectedETSWithDHW.mat'),
                      'results' : {}
                      },
                    {'name'    : 'D',
                      'matFile' : os.path.join('cluster_D_futu','ConnectedETSWithDHW.mat'),
                      'results' : {}
                      },
                    {'name'    : 'E',
                      'matFile' : os.path.join('cluster_E_futu','ConnectedETSWithDHW.mat'),
                      'results' : {}
                      }
                ]
    
    analysis['variables'] = variables
    analysis['scenarios'] = scenarios
    
    return analysis
    
def heat_wave():
    
    # from PythonResources/Data/Consumption/Anemoi.py
    _year = 2025 # dummy year, no effect
    # hotday = datetime(_year, 8, 2)
    heat_wave_from = datetime(_year, 7, 27)
    heat_wave_to = datetime(_year, 8, 9)
    
    analysis = {}
    analysis['timePeriod'] = [soy(heat_wave_from), soy(heat_wave_to)]
    
    variables = [
                    {'name' : 'EChi.y',
                     'quantity': 'energy',
                     'action'  : lambda t, y: y[-1] - y[0],
                     'caption' : 'Total electrical consumption of ETS heat recovery chiller'
                     },
                    {'name' : 'dHHeaWat.y',
                     'quantity': 'energy',
                     'action'  : lambda t, y: y[-1] - y[0],
                     'caption' : 'Total end-use space heating load'
                     },
                    {'name' : 'dHChiWat.y',
                     'quantity': 'energy',
                     'action'  : lambda t, y: y[-1] - y[0],
                     'caption' : 'Total end-use cooling load'
                     },
                    {'name' : 'bui.ets.chi.chi.ySet',
                     'quantity': 'time',
                     'action'  : lambda t, y: condition_duration(t, y, lambda y: y > 0.99),
                     'caption' : 'Total duration of chiller speed > 0.99'},
                    {'name' : 'bui.ets.chi.chi.COP',
                     'action'  : lambda t, y: np.mean(y[(np.isclose(t % 3600, 0)) & (y > 0.01)]),
                     'caption' : 'ETS chiller average COP when on'}
                ]

    scenarios = [
                    {'name'    : 'fTMY',
                      'matFile' : os.path.join('ETS_All_futu','ConnectedETSWithDHW.mat'),
                      'results' : {}
                      },
                    {'name'    : 'Heat wave',
                      'matFile' : os.path.join('ETS_All_heat','ConnectedETSWithDHW.mat'),
                      'results' : {}
                      },
                ]

    analysis['variables'] = variables
    analysis['scenarios'] = scenarios
    
    return analysis

def cold_snap():

    # from PythonResources/Data/Consumption/Anemoi.py
    _year = 2025 # dummy year, no effect
    # coldday = datetime(_year, 3, 1)
    cold_snap_from = datetime(_year, 2, 23)
    cold_snap_to = datetime(_year, 3, 8)
    
    analysis = {}
    analysis['timePeriod'] = [soy(cold_snap_from), soy(cold_snap_to)]

    variables = [
                    {'name' : 'EChi.y',
                     'quantity': 'energy',
                     'action'  : lambda t, y: y[-1] - y[0],
                     'caption' : 'Total electrical consumption of ETS heat recovery chiller'
                     },
                    {'name' : 'dHHeaWat.y',
                     'quantity': 'energy',
                     'action'  : lambda t, y: y[-1] - y[0],
                     'caption' : 'Total end-use space heating load'
                     },
                    {'name' : 'dHChiWat.y',
                     'quantity': 'energy',
                     'action'  : lambda t, y: y[-1] - y[0],
                     'caption' : 'Total end-use cooling load'
                     },
                    {'name' : 'bui.ets.chi.chi.ySet',
                     'quantity': 'time',
                     'action'  : lambda t, y: condition_duration(t, y, lambda y: y > 0.99),
                     'caption' : 'Total duration of chiller speed > 0.99'},
                    {'name' : 'bui.ets.chi.chi.COP',
                     'action'  : lambda t, y: np.mean(y[(np.isclose(t % 3600, 0)) & (y > 0.01)]),
                     'caption' : 'ETS chiller average COP when on'}
                ]

    scenarios = [
                    {'name'    : 'fTMY',
                      'matFile' : os.path.join('ETS_All_futu','ConnectedETSWithDHW.mat'),
                      'results' : {}
                      },
                    {'name'    : 'Cold snap',
                      'matFile' : os.path.join('ETS_All_cold','ConnectedETSWithDHW.mat'),
                      'results' : {}
                      }
                ]

    analysis['variables'] = variables
    analysis['scenarios'] = scenarios
    
    return analysis

def condition_duration(t, y, condition):
    """ Duration of time during which y meets the condition.
    """
    indices = np.where(condition(y))[0]
    duration = 0.0
    for i in range(1, len(indices)):
        if indices[i] == indices[i-1] + 1:  # Check if the indices are consecutive
            duration += t[indices[i]] - t[indices[i-1]]
            
    return duration

def soy(dt):
    # Second of year
    start_of_year = datetime(dt.year, 1, 1)
    return int((dt - start_of_year).total_seconds())