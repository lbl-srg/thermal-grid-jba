#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 19 11:27:46 2025

@author: casper

This file extracts values from the results file to make the Sankey diagram.
  The diagram needs to be made manually in e!Sankey which only runs on Windows.
"""

import os
import numpy as np
import pandas as pd

from GetVariables import *
# python file under same folder

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))
mat_file_name = os.path.join(CWD, "simulations", "2025-07-10_base-crit", "2025-07-10-base-DetailedPlantFiveHubs.mat")

nBui = 5 # Ensure this is consistent with the mat file
_i = r'%%i%%' # placeholder string to be replaced with index
J_to_kWh = 2.7777777777777776e-07

#%% read results file
var_list = list()
# buildings
var_list_pre_index = [
    f'bui[{_i}].ets.PCoo',
    f'bui[{_i}].dHChiWat_flow',
    f'bui[{_i}].dHHeaWat_flow',
    f'bui[{_i}].bui.disFloHea.PPum',
    f'bui[{_i}].bui.disFloCoo.PPum',
    f'QEtsHex_flow.u[{_i}]']
var_list += index_var_list(var_list_pre_index,
                           _i,
                           range(1,nBui+1))
# bui[1] doesn't have dhw
var_list += index_var_list([f'bui[{_i}].dHHotWat_flow',
                            f'bui[{_i}].ets.tanDhw.PEle'],
                           _i,
                           range(2,nBui+1))
# ground connection has (nBui + 1) elements
var_list += index_var_list(f'dis.heatPorts[{_i}].Q_flow',
                           _i,
                           range(1,nBui+2))
# variables without an index
var_list += ['cenPla.gen.ind.ySea',
             'cenPla.gen.hex.Q1_flow',
             'cenPla.gen.heaPum.P',
             'cenPla.gen.heaPum.QCon_flow',
             'cenPla.gen.heaPum.QEva_flow',
             'cenPla.QBorPer_flow',
             'cenPla.QBorCen_flow',
             'cenPla.gen.fanDryCoo.P',
             'cenPla.gen.pumDryCoo.P',
             'cenPla.gen.dryCoo.Q1_flow',
             'pumDis.P',
             'PEleNonHva.y',
             'PFanBuiSum.y',
             'EPvBat.u'
             ]
results = get_vars(var_list,
                   mat_file_name,
                   'dymola')

#%% process results data
# (source node, target node)
#   `energy carrier` influences colouring in the diagram
data_dicts = [
    {
    ("PV and bettery", "Electricity") : 0,
    ("Electricity", "Buildings fans + non HVAC") : 0,
    ("Electricity", "Pump coo") : 0,
    ("Electricity", "Pump hea") : 0,
    ("Electricity", "Pump DHW") : 0,
    ("Electricity", "ETS") : 0,
    ("Electricity", "Central plant chiller") : 0,
    ("Electricity", "Dry cooler") : 0,
    ("Electricity", "Pump district") : 0,
    ("Heat ambient", "Dry cooler") : 0,
    ("TEN", "Central plant chiller") : 0,
    ("Dry cooler", "Heat ambient") : 0,
    ("Central plant chiller", "TEN") : 0,
    ("Economiser", "TEN") : 0,
    ("Borefield", "TEN") : 0,
    ("Ground", "TEN") : 0,
    ("ETS", "Pump district") : 0,
    ("TEN", "Economiser") : 0,
    ("TEN", "Borefield") : 0,
    ("TEN", "Ground") : 0,
    ("Pump district", "ETS") : 0,
    ("Pump coo", "ETS") : 0,
    ("ETS", "Pump hea") : 0,
    ("ETS", "DHW") : 0
        }
    for _ in range(5)]

for sea in range(5):
# for sea in range(1):
    if sea == 0:
        condition = None
    else:
        condition = np.array(results['cenPla.gen.ind.ySea'] == sea)
    
    data_dict = data_dicts[sea]
    
    # Electricity node
    data_dict[("PV and bettery", "Electricity")] = \
        abs(integrate_with_condition(results, 'EPvBat.u',
                                     condition = condition))
    data_dict[("Electricity", "Buildings fans + non HVAC")] = \
        abs(integrate_with_condition(results, 'PEleNonHva.y',
                                     condition = condition)) + \
        abs(integrate_with_condition(results, 'PFanBuiSum.y',
                                     condition = condition))
    data_dict[("Electricity", "Central plant chiller")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.heaPum.P',
                                     condition = condition))
    data_dict[("Electricity", "Dry cooler")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.fanDryCoo.P',
                                     condition = condition)) + \
        abs(integrate_with_condition(results, 'cenPla.gen.pumDryCoo.P',
                                     condition = condition))
    data_dict[("Electricity", "Pump district")] = \
        abs(integrate_with_condition(results, 'pumDis.P',
                                     condition = condition))
    # each building
    for i in range(1,nBui+1):
        data_dict[("Electricity", "ETS")] += \
            abs(integrate_with_condition(results, f'bui[{i}].ets.PCoo',
                                         condition = condition))
        data_dict[("Electricity", "Pump coo")] += \
            abs(integrate_with_condition(results, f'bui[{i}].bui.disFloCoo.PPum',
                                         condition = condition))
        data_dict[("Electricity", "Pump hea")] += \
            abs(integrate_with_condition(results, f'bui[{i}].bui.disFloHea.PPum',
                                         condition = condition))
        if i != 1: # bui[1] doesn't have dhw
            data_dict[("Electricity", "Pump DHW")] += \
                abs(integrate_with_condition(results, f'bui[{i}].ets.tanDhw.PEle',
                                             condition = condition))
    
    # Central plant node, previously computed links excluded
    data_dict[("Heat ambient", "Dry cooler")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.dryCoo.Q1_flow',
                                      sign = 'negative',
                                      condition = condition))
    data_dict[("Dry cooler", "Heat ambient")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.dryCoo.Q1_flow',
                                      sign = 'positive',
                                      condition = condition))
    data_dict[("Central plant chiller", "TEN")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.heaPum.QCon_flow',
                                      sign = 'positive',
                                      condition = condition))
    data_dict[("TEN", "Central plant chiller")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.heaPum.QCon_flow',
                                      sign = 'negative',
                                      condition = condition))

    # TEN node, previously computed links excluded
    data_dict[("Economiser", "TEN")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.hex.Q1_flow',
                                     sign = 'positive',
                                     condition = condition))
    data_dict[("TEN", "Economiser")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.hex.Q1_flow',
                                     sign = 'negative',
                                     condition = condition))
    data_dict[("Borefield", "TEN")] = \
        abs(integrate_with_condition(results, 'cenPla.QBorCen_flow',
                                      sign = 'positive',
                                      condition = condition)) + \
        abs(integrate_with_condition(results, 'cenPla.QBorPer_flow',
                                      sign = 'positive',
                                      condition = condition))
    data_dict[("TEN", "Borefield")] = \
        abs(integrate_with_condition(results, 'cenPla.QBorCen_flow',
                                      sign = 'negative',
                                      condition = condition)) + \
        abs(integrate_with_condition(results, 'cenPla.QBorPer_flow',
                                      sign = 'negative',
                                      condition = condition))
    # each pipe section
    for i in range(1,nBui+2):
        data_dict[("Ground", "TEN")] += \
            abs(integrate_with_condition(results, f'dis.heatPorts[{i}].Q_flow',
                                          sign = 'positive',
                                          condition = condition))
        data_dict[("TEN", "Ground")] += \
            abs(integrate_with_condition(results, f'dis.heatPorts[{i}].Q_flow',
                                          sign = 'negative',
                                          condition = condition))
    # each building
    for i in range(1,nBui+1):
        data_dict[("Pump district", "ETS")] += \
            abs(integrate_with_condition(results, f'QEtsHex_flow.u[{i}]',
                                          sign = 'positive',
                                          condition = condition))
        data_dict[("ETS", "Pump district")] += \
            abs(integrate_with_condition(results, f'QEtsHex_flow.u[{i}]',
                                          sign = 'negative',
                                          condition = condition))

    # ETS node, previously computed links excluded
    # each building
    for i in range(1,nBui+1):
        data_dict[("Pump coo", "ETS")] += \
            abs(integrate_with_condition(results, f'bui[{i}].dHChiWat_flow',
                                          condition = condition))
        data_dict[("ETS", "Pump hea")] += \
            abs(integrate_with_condition(results, f'bui[{i}].dHHeaWat_flow',
                                          condition = condition))
        if i != 1: # bui[1] doesn't have dhw
            data_dict[("ETS", "DHW")] += \
                abs(integrate_with_condition(results, f'bui[{i}].dHHotWat_flow',
                                              condition = condition))

#%% output to Excel
seasons = ['Whole year', 'Winter', 'Spring', 'Summer', 'Fall']
with pd.ExcelWriter('sankey_modelica.xlsx', engine='openpyxl') as writer:
    for season, data_dict in zip(seasons, data_dicts):
        # Convert the dictionary to a DataFrame
        df = pd.DataFrame(list(data_dict.items()), columns=['From-To', 'kWh'])
        df[['From', 'To']] = pd.DataFrame(df['From-To'].tolist(), index=df.index)
        df['kWh'] = df['kWh'] * J_to_kWh
        df = df[['From', 'To', 'kWh']]
        
        df.to_excel(writer, sheet_name=season, index=False)
