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
pio.renderers.default='browser'

from GetVariables import get_vars, index_var_list
# python file under same folder

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))
mat_file_name = os.path.join(CWD, "simulations", "2025-05-19", "DetailedPlantFiveHubs.mat")

nBui = 5 # Ensure this is consistent with the mat file
ranBui = range(1,nBui+1)
_i = r'%%i%%' # placeholder string to be replaced with index

#%% read results file
var_list_pre_index = [
    f'bui[{_i}].ets.chi.chi.COP',
    f'bui[{_i}].ets.chi.chi.P',
    f'bui[{_i}].ets.chi.chi.QCon_flow',
    f'bui[{_i}].ets.chi.chi.QEva_flow',
    f'bui[{_i}].ets.chi.con.uCoo',
    f'bui[{_i}].ets.chi.con.uHea',
    'cenPla.gen.ind.ySea']
var_list = index_var_list(var_list_pre_index,
                          _i,
                          ranBui)
results = get_vars(var_list,
                   mat_file_name,
                   'dymola')

#%% process results data
# filter results
results = results[np.isclose(results['Time'] % 3600, 0)] # only keep hourly sampled values
results = results.iloc[:-1] # drop the last point which would be categorised to the next year

# initialise data dict
# (source, target, energy carrier) : value
data_dict = {
    ("Electricity input", "HRC - cooling only", "electricity") : 0,
    ("Electricity input", "HRC - heating only", "electricity") : 0,
    ("Electricity input", "HRC - simultaneous", "electricity") : 0,
    ("ETS hex", "HRC - cooling only", "heat rejection") : 0,
    ("ETS hex", "HRC - heating only", "cooling rejection") : 0,
    ("HRC - cooling only", "Cooling load", "cooling") : 0,
    ("HRC - heating only", "Heating load", "space heating") : 0,
    ("HRC - simultaneous", "Cooling load", "cooling") : 0,
    ("HRC - simultaneous", "Heating load", "space heating") : 0
        }
for i in ranBui:
    # filter out data of the specified index
    results_bui = results[['Time'] + [col for col in results.columns if col.startswith(f'bui[{i}].')]]
    
    # only when chiller on
    results_bui = results_bui[results_bui[f'bui[{i}].ets.chi.chi.COP'] > 0.01]
    # remove transient at initialisation
    results_bui = results_bui[results_bui[f'bui[{i}].ets.chi.chi.COP'] < 15.0]

    # filter data based on operational modes
    conditions = [
        (results_bui[f'bui[{i}].ets.chi.con.uCoo'] == 1) & (results_bui[f'bui[{i}].ets.chi.con.uHea'] == 1),
        (results_bui[f'bui[{i}].ets.chi.con.uCoo'] == 1) & (results_bui[f'bui[{i}].ets.chi.con.uHea'] == 0),
        (results_bui[f'bui[{i}].ets.chi.con.uCoo'] == 0) & (results_bui[f'bui[{i}].ets.chi.con.uHea'] == 1)
                  ]
    modes = ['simultaneous', 'coolingonly', 'heatingonly']
    results_bui['mode'] = np.select(conditions, modes, default='other')
    
    data_dict[("Electricity input", "HRC - cooling only", "electricity")] += \
        abs(results_bui.loc[results_bui['mode'] == 'coolingonly', f'bui[{i}].ets.chi.chi.P'].sum())
    data_dict[("Electricity input", "HRC - heating only", "electricity")] += \
        abs(results_bui.loc[results_bui['mode'] == 'heatingonly', f'bui[{i}].ets.chi.chi.P'].sum())
    data_dict[("Electricity input", "HRC - simultaneous", "electricity")] += \
        abs(results_bui.loc[results_bui['mode'] == 'simultaneous', f'bui[{i}].ets.chi.chi.P'].sum())
    data_dict[("ETS hex", "HRC - cooling only", "heat rejection")] += \
        abs(results_bui.loc[results_bui['mode'] == 'coolingonly', f'bui[{i}].ets.chi.chi.QCon_flow'].sum())
    data_dict[("ETS hex", "HRC - heating only", "cooling rejection")] += \
        abs(results_bui.loc[results_bui['mode'] == 'heatingonly', f'bui[{i}].ets.chi.chi.QEva_flow'].sum())
    data_dict[("HRC - cooling only", "Cooling load", "cooling")] += \
        abs(results_bui.loc[results_bui['mode'] == 'coolingonly', f'bui[{i}].ets.chi.chi.QEva_flow'].sum())
    data_dict[("HRC - heating only", "Heating load", "space heating")] += \
        abs(results_bui.loc[results_bui['mode'] == 'heatingonly', f'bui[{i}].ets.chi.chi.QCon_flow'].sum())
    data_dict[("HRC - simultaneous", "Cooling load", "cooling")] += \
        abs(results_bui.loc[results_bui['mode'] == 'simultaneous', f'bui[{i}].ets.chi.chi.QEva_flow'].sum())
    data_dict[("HRC - simultaneous", "Heating load", "space heating")] += \
        abs(results_bui.loc[results_bui['mode'] == 'simultaneous', f'bui[{i}].ets.chi.chi.QCon_flow'].sum())

#%% make sankey diagram

# Map energy carriers to colors
dict_color = {
    "electricity": 'rgba(60, 179, 113, 0.8)',
    "cooling": 'rgba(0, 0, 255, 0.8)',
    "space heating": 'rgba(255, 0, 0, 0.8)',
    "domestic hot water": 'rgba(106, 90, 205, 0.8)',
    "heat rejection": 'rgba(255, 0, 0, 0.4)',
    "cooling rejection": 'rgba(0, 0, 255, 0.4)'
}

# Extract unique nodes and creat a mapping from node name to index
nodes = sorted(set(node for pair in data_dict.keys() for node in pair[:2]))
node_indices = {node: idx for idx, node in enumerate(nodes)}

# Creat source, target, and value lists
source = [node_indices[src] for src, tgt, crr in data_dict.keys()]
target = [node_indices[tgt] for src, tgt, crr in data_dict.keys()]
value = [data_dict[key] for key in data_dict.keys()]
color = [dict_color[crr] for src, tgt, crr in data_dict.keys()]

# Creat the Sankey diagram
fig = go.Figure(data=[go.Sankey(
    node=dict(
        pad=15,
        thickness=20,
        line=dict(color="black", width=0.5),
        label=nodes,
        color="blue"
    ),
    link=dict(
        source=source,
        target=target,
        value=value,
        color=color
    )
)])

fig.update_layout(title_text="Basic Sankey Diagram", font_size=10)
fig.show()