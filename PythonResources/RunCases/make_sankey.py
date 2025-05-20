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

from GetVariables import get_vars # python file under same folder

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))
mat_file_name = os.path.join(CWD, "simulations", "2025-05-19", "DetailedPlantFiveHubs.mat")
csv_file_name = mat_file_name.replace('.mat', '.csv')

#%% read results file
var_list = [
    'bui[1].ets.chi.chi.COP',
    'bui[1].ets.chi.chi.P',
    'bui[1].ets.chi.chi.QCon_flow',
    'bui[1].ets.chi.chi.QEva_flow',
    'bui[1].ets.chi.con.uCoo',
    'bui[1].ets.chi.con.uHea',
    'cenPla.gen.ind.ySea']
results = get_vars(var_list,
                   mat_file_name,
                   'dymola')

#%% process results data
# filter results
results = results[results['bui[1].ets.chi.chi.COP'] > 0.01] # only when chiller on
results = results[results['bui[1].ets.chi.chi.COP'] < 15.0] # remove transient at initialisation
results = results[np.isclose(results['Time'] % 3600, 0)] # only keep hourly sampled values
results = results.iloc[:-1] # drop the last point which would be categorised to the next year

# filter data based on operational modes
conditions = [
    (results['bui[1].ets.chi.con.uCoo'] == 1) & (results['bui[1].ets.chi.con.uHea'] == 1),
    (results['bui[1].ets.chi.con.uCoo'] == 1) & (results['bui[1].ets.chi.con.uHea'] == 0),
    (results['bui[1].ets.chi.con.uCoo'] == 0) & (results['bui[1].ets.chi.con.uHea'] == 1)
              ]
modes = ['simultaneous', 'coolingonly', 'heatingonly']
results['mode'] = np.select(conditions, modes, default='other')

#%% make sankey diagram
# All connections
# (source, target, energy carrier, value)
data = [("Electricity input", "HRC - cooling only", "electricity",
         abs(results.loc[results['mode'] == 'coolingonly', 'bui[1].ets.chi.chi.P'].sum())),
        ("Electricity input", "HRC - heating only", "electricity",
         abs(results.loc[results['mode'] == 'heatingonly', 'bui[1].ets.chi.chi.P'].sum())),
        ("Electricity input", "HRC - simultaneous", "electricity",
         abs(results.loc[results['mode'] == 'simultaneous', 'bui[1].ets.chi.chi.P'].sum())),
        ("ETS hex", "HRC - cooling only", "heat rejection",
         abs(results.loc[results['mode'] == 'coolingonly', 'bui[1].ets.chi.chi.QCon_flow'].sum())),
        ("ETS hex", "HRC - heating only", "cooling rejection",
         abs(results.loc[results['mode'] == 'heatingonly', 'bui[1].ets.chi.chi.QEva_flow'].sum())),
        ("HRC - cooling only", "Cooling load", "cooling",
         abs(results.loc[results['mode'] == 'coolingonly', 'bui[1].ets.chi.chi.QEva_flow'].sum())),
        ("HRC - heating only", "Heating load", "space heating",
         abs(results.loc[results['mode'] == 'heatingonly', 'bui[1].ets.chi.chi.QCon_flow'].sum())),
        ("HRC - simultaneous", "Cooling load", "cooling",
         abs(results.loc[results['mode'] == 'simultaneous', 'bui[1].ets.chi.chi.QEva_flow'].sum())),
        ("HRC - simultaneous", "Heating load", "space heating",
         abs(results.loc[results['mode'] == 'simultaneous', 'bui[1].ets.chi.chi.QCon_flow'].sum()))]

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
nodes = sorted(set(node for pair in data for node in pair[:2]))
node_indices = {node: idx for idx, node in enumerate(nodes)}

# Creat source, target, and value lists
source = [node_indices[src] for src, tgt, crr, val in data]
target = [node_indices[tgt] for src, tgt, crr, val in data]
value = [val for src, tgt, crr, val in data]
color = [dict_color[crr] for src, tgt, crr, val in data]

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