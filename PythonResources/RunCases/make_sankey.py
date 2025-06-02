#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 19 11:27:46 2025

@author: casper
"""

import os
import numpy as np
import plotly.graph_objects as go
import plotly.io as pio
pio.renderers.default='browser' # if the IDE doesn't render plotly output

from GetVariables import get_vars, index_var_list, integrate_with_condition
# python file under same folder

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))
mat_file_name = os.path.join(CWD, "simulations", "2025-05-25", "DetailedPlantFiveHubs.mat")

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
    f'QEtsHex_flow.u[{_i}]']
var_list += index_var_list(var_list_pre_index,
                           _i,
                           range(1,nBui+1))
# bui[1] doesn't have dhw
var_list += index_var_list(f'bui[{_i}].dHHotWat_flow',
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
             'cenPla.QBorCen_flow'
             ]
results = get_vars(var_list,
                   mat_file_name,
                   'dymola')

#%% process results data
# (source, target, energy carrier)
#   `energy carrier` influences colouring in the diagram
data_dicts = [
    {
    ("Electricity import", "ETS chiller", "electricity") : 0,
    ("Electricity import", "Central chiller", "electricity") : 0,
    ("Dry cooler", "Central chiller", "plant heat rejection") : 0,
    ("Dry cooler", "Central chiller", "plant cooling rejection") : 0,
    ("Dry cooler", "Economizer", "plant heat rejection") : 0,
    ("Dry cooler", "Economizer", "plant cooling rejection") : 0,
    ("Central chiller", "Reservoir loop", "plant cooling") : 0,
    ("Central chiller", "Reservoir loop", "plant heating") : 0,
    ("Reservoir loop", "ETS chiller", "ETS heat rejection") : 0,
    ("Reservoir loop", "ETS chiller", "ETS cooling rejection") : 0,
    ("ETS chiller", "Cooling load", "cooling load") : 0,
    ("ETS chiller", "Heating load", "space heating load") : 0,
    ("ETS chiller", "DHW load", "domestic hot water") : 0,
    ("Reservoir loop", "Ground", "ground anergy") : 0,
    ("Ground", "Reservoir loop", "ground anergy") : 0,
    ("Economizer", "Reservoir loop", "plant heating") : 0,
    ("Economizer", "Reservoir loop", "plant cooling") : 0,
    ("Borefield center", "Reservoir loop", "borefield center anergy") : 0,
    ("Reservoir loop", "Borefield center", "borefield center anergy") : 0,
    ("Borefield perimeter", "Reservoir loop", "borefield perimeter anergy") : 0,
    ("Reservoir loop", "Borefield perimeter", "borefield perimeter anergy") : 0
        }
    for _ in range(5)]

for sea in range(5):
# for sea in range(1):
    if sea == 0:
        condition = None
    else:
        condition = np.array(results['cenPla.gen.ind.ySea'] == sea)
    
    data_dict = data_dicts[sea]
    
    # each building
    for i in range(1,nBui+1):
        data_dict[("Electricity import", "ETS chiller", "electricity")] += \
            abs(integrate_with_condition(results, f'bui[{i}].ets.PCoo',
                                         condition = condition))
        data_dict[("Reservoir loop", "ETS chiller", "ETS cooling rejection")] += \
            abs(integrate_with_condition(results, f'QEtsHex_flow.u[{i}]',
                                         sign = 'positive',
                                         condition = condition))
        data_dict[("Reservoir loop", "ETS chiller", "ETS heat rejection")] += \
            abs(integrate_with_condition(results, f'QEtsHex_flow.u[{i}]',
                                         sign = 'negative',
                                         condition = condition))
        data_dict[("ETS chiller", "Cooling load", "cooling load")] += \
            abs(integrate_with_condition(results, f'bui[{i}].dHChiWat_flow',
                                         condition = condition))
        data_dict[("ETS chiller", "Heating load", "space heating load")] += \
            abs(integrate_with_condition(results, f'bui[{i}].dHHeaWat_flow',
                                         condition = condition))
        if i != 1: # bui[1] doesn't have dhw
            data_dict[("ETS chiller", "DHW load", "domestic hot water")] += \
                abs(integrate_with_condition(results, f'bui[{i}].dHHotWat_flow',
                                             condition = condition))
    
    # ground
    for i in range(1,nBui+2):
        data_dict[("Reservoir loop", "Ground", "ground anergy")] += \
            abs(integrate_with_condition(results, f'dis.heatPorts[{i}].Q_flow',
                                         sign = 'negative',
                                         condition = condition))
        data_dict[("Ground", "Reservoir loop", "ground anergy")] += \
            abs(integrate_with_condition(results, f'dis.heatPorts[{i}].Q_flow',
                                         sign = 'positive',
                                         condition = condition))
    
    # Central plant
    # economiser
    data_dict[("Dry cooler", "Economizer", "plant heat rejection")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.hex.Q1_flow',
                                     sign = 'negative',
                                     condition = condition))
    data_dict[("Dry cooler", "Economizer", "plant cooling rejection")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.hex.Q1_flow',
                                     sign = 'positive',
                                     condition = condition))
    data_dict[("Economizer", "Reservoir loop", "plant heating")] = \
        data_dict[("Dry cooler", "Economizer", "plant cooling rejection")]
    data_dict[("Economizer", "Reservoir loop", "plant cooling")] = \
        data_dict[("Dry cooler", "Economizer", "plant heat rejection")]
    
    # central chiller
    data_dict[("Electricity import", "Central chiller", "electricity")] = \
        abs(integrate_with_condition(results, 'cenPla.gen.heaPum.P',
                                     condition = condition))
    data_dict[("Dry cooler", "Central chiller", "plant cooling rejection")] =\
        abs(integrate_with_condition(results, 'cenPla.gen.heaPum.QEva_flow',
                                     sign = 'negative',
                                     condition = condition))
    data_dict[("Dry cooler", "Central chiller", "plant heat rejection")] =\
        abs(integrate_with_condition(results, 'cenPla.gen.heaPum.QEva_flow',
                                     sign = 'positive',
                                     condition = condition))
    data_dict[("Central chiller", "Reservoir loop", "plant heating")] =\
        abs(integrate_with_condition(results, 'cenPla.gen.heaPum.QCon_flow',
                                     sign = 'positive',
                                     condition = condition))
    data_dict[("Central chiller", "Reservoir loop", "plant cooling")] =\
        abs(integrate_with_condition(results, 'cenPla.gen.heaPum.QCon_flow',
                                     sign = 'negative',
                                     condition = condition))
    
    # borefield
    data_dict[("Borefield center", "Reservoir loop", "borefield center anergy")] =\
        abs(integrate_with_condition(results, 'cenPla.QBorCen_flow',
                                     sign = 'positive',
                                     condition = condition))
    data_dict[("Reservoir loop", "Borefield center", "borefield center anergy")] =\
        abs(integrate_with_condition(results, 'cenPla.QBorCen_flow',
                                     sign = 'negative',
                                     condition = condition))
    data_dict[("Borefield perimeter", "Reservoir loop", "borefield perimeter anergy")] =\
        abs(integrate_with_condition(results, 'cenPla.QBorPer_flow',
                                     sign = 'positive',
                                     condition = condition))
    data_dict[("Reservoir loop", "Borefield perimeter", "borefield perimeter anergy")] =\
        abs(integrate_with_condition(results, 'cenPla.QBorPer_flow',
                                     sign = 'negative',
                                     condition = condition))

#%% make sankey diagram

# Map energy carriers to colors
# Scheme:
#   Electricity is green;
#   Cooling l-t-r (left to right) is blue 'rgba(0, 0, 255, x)',
#     Note that cooling _rejection_ from a chiller is r-t-l,
#     therefore it follows the colour for heating l-t-r.
#   Heating l-t-r is red 'rgba(255, 0, 0, x)',
#     Note that heat _rejection_ from a chiller is r-t-l,
#     therefore it follows the colour for cooling l-t-r.
#   Storage / anergy forming a loop is yellow 'rgba(u, v, 0, x)'.
#   DHW is magent 'rgba(165, 255, 0, x)'.
dict_color = {
    "electricity": 'rgba(60, 179, 113, 0.8)',
    "plant heat rejection": 'rgba(0, 0, 255, 0.3)',
    "plant cooling rejection": 'rgba(255, 0, 0, 0.3)',
    "plant cooling": 'rgba(0, 0, 255, 0.5)',
    "plant heating": 'rgba(255, 0, 0, 0.5)',
    "ETS heat rejection": 'rgba(0, 0, 255, 0.7)',
    "ETS cooling rejection": 'rgba(255, 0, 0, 0.7)',
    "cooling load": 'rgba(0, 0, 255, 0.9)',
    "space heating load": 'rgba(255, 0, 0, 0.9)',
    "domestic hot water": 'rgba(106, 90, 205, 0.9)',
    "ground anergy": 'rgba(165, 165, 0, 0.8)',
    "borefield center anergy": 'rgba(255, 165, 0, 0.8)',
    "borefield perimeter anergy": 'rgba(165, 255, 0, 0.8)'
}

# Map node names to coordinates
#   The origin is at the top left, from 0 to 1.
#   The x-positions reflect the columns.
#   The y-positions need to be manually adjusted after the diagram is generated.
dict_coord = {
    "Electricity import": (0.1, 0.1),
    "Dry cooler": (0.1, 0.4),
    "Central chiller": (0.3, 0.4),
    "Economizer": (0.3, 0.6),
    "Borefield center": (0.3, 0.7),
    "Borefield perimeter": (0.3, 0.8),
    "Ground": (0.3, 0.85),
    "Reservoir loop": (0.5, 0.6),
    "ETS chiller": (0.7, 0.35),
    "Cooling load": (0.9, 0.2),
    "Heating load": (0.9, 0.6),
    "DHW load": (0.9, 0.8)
    }

# Season names
seasons = ['Whole year', 'Winter', 'Spring', 'Summer', 'Fall']

for idx, data_dict in enumerate(data_dicts):
    # Extract unique nodes and creat a mapping from node name to index
    nodes = sorted(set(node for pair in data_dict.keys() for node in pair[:2]))
    node_indices = {node: idx for idx, node in enumerate(nodes)}
    nodex = [dict_coord[node][0] for node in nodes]
    nodey = [dict_coord[node][1] for node in nodes]
    label = ["District loop" if item == "Reservoir loop" else item for item in nodes]
    # Replaces the node name "Reservoir loop" with the label display "District loop".
    #   The reason for not directly naming the node "District loop" is
    #   that it triggers a Plotly bug that renders link direction incorrectly.
    #   This bug seems to be related to how the node name strings are sorted.
    
    # Creat source, target, and value lists
    source = [node_indices[src] for src, tgt, crr in data_dict.keys()]
    target = [node_indices[tgt] for src, tgt, crr in data_dict.keys()]
    value = [data_dict[key] for key in data_dict.keys()]
    color = [dict_color[crr] for src, tgt, crr in data_dict.keys()]
    value = np.array(value)*J_to_kWh
    
    # Creat the Sankey diagram
    fig = go.Figure(data=[go.Sankey(
        valueformat = ",.0f",
        valuesuffix = "kWh",
        node=dict(
            pad=15,
            thickness=20,
            line=dict(color="black", width=0.5),
            label=label,
            align='center',
            x=nodex,
            y=nodey,
            color="blue"
        ),
        link=dict(
            source=source,
            target=target,
            value=value,
            color=color
        )
    )])
    
    fig.update_layout(font=dict(size = 30))
    fig.show()

#%% validation
# checks first-law conservation
# compares numbers from other sources

print("### VALIDATION ###")
print('\n- Integration of load -')
print(f'total cooling load = {data_dicts[0][("ETS chiller", "Cooling load", "cooling load")]*J_to_kWh:.3g} kWh')
print(f'    reference from load files: {16908188:.3g} kWh')
print(f'total heating load = {data_dicts[0][("ETS chiller", "Heating load", "space heating load")]*J_to_kWh:.3g} kWh')
print(f'    reference from load files: {10080563.2344998:.3g} kWh')
print(f'total dhw load = {data_dicts[0][("ETS chiller", "DHW load", "domestic hot water")]*J_to_kWh:.3g} kWh')
print(f'    reference from load files: {4748967.95197562:.3g} kWh')

print('\n- ETS chiller -')
ets_chi_in  = data_dicts[0][("Electricity import", "ETS chiller", "electricity")] \
            + data_dicts[0][("Reservoir loop", "ETS chiller", "ETS cooling rejection")] \
            + data_dicts[0][("ETS chiller", "Cooling load", "cooling load")]
ets_chi_out = data_dicts[0][("Reservoir loop", "ETS chiller", "ETS heat rejection")] \
            + data_dicts[0][("ETS chiller", "Heating load", "space heating load")] \
            + data_dicts[0][("ETS chiller", "DHW load", "domestic hot water")]
print(f"ets chiller ele + eva = {ets_chi_in*J_to_kWh:.3g} kWh")
print(f"ets chiller con       = {ets_chi_out*J_to_kWh:.3g} kWh")

print('\n- Central plant chiller -')
cen_chi_in  = data_dicts[0][("Electricity import", "Central chiller", "electricity")] \
            + data_dicts[0][("Dry cooler", "Central chiller", "plant cooling rejection")] \
            + data_dicts[0][("Central chiller", "Reservoir loop", "plant cooling")]
cen_chi_out = data_dicts[0][("Dry cooler", "Central chiller", "plant heat rejection")] \
            + data_dicts[0][("Central chiller", "Reservoir loop", "plant heating")]
print(f"central chiller ele + eva = {cen_chi_in*J_to_kWh:.3g} kWh")
print(f"central chiller con       = {cen_chi_out*J_to_kWh:.3g} kWh")

print('\n- Reservoir loop -')
res_loo_in  = data_dicts[0][("Reservoir loop", "ETS chiller", "ETS heat rejection")] \
            + data_dicts[0][("Ground", "Reservoir loop", "ground anergy")] \
            + data_dicts[0][("Economizer", "Reservoir loop", "plant heating")] \
            + data_dicts[0][("Central chiller", "Reservoir loop", "plant heating")] \
            + data_dicts[0][("Borefield center", "Reservoir loop", "borefield center anergy")] \
            + data_dicts[0][("Borefield perimeter", "Reservoir loop", "borefield perimeter anergy")]
res_loo_out = data_dicts[0][("Reservoir loop", "ETS chiller", "ETS cooling rejection")] \
            + data_dicts[0][("Reservoir loop", "Ground", "ground anergy")] \
            + data_dicts[0][("Economizer", "Reservoir loop", "plant cooling")] \
            + data_dicts[0][("Central chiller", "Reservoir loop", "plant cooling")] \
            + data_dicts[0][("Reservoir loop", "Borefield center", "borefield center anergy")] \
            + data_dicts[0][("Reservoir loop", "Borefield perimeter", "borefield perimeter anergy")]
print(f"energy into reservoir loop   = {res_loo_in*J_to_kWh:.3g} kWh")
print(f"energy out of reservoir loop = {res_loo_out*J_to_kWh:.3g} kWh")

