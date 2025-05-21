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

from scipy.integrate import trapz

from GetVariables import get_vars, index_var_list
# python file under same folder

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))
mat_file_name = os.path.join(CWD, "simulations", "2025-05-19", "DetailedPlantFiveHubs.mat")

nBui = 5 # Ensure this is consistent with the mat file
ranBui = range(1,nBui+1)
_i = r'%%i%%' # placeholder string to be replaced with index

def integrate_result(df, var, option = None):
    """ Integrates df[var] along df['Time']
        option = [None, 'positive', 'negative']
          to only integrate positive or negative values
    """
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
    
    t = np.array(df['Time'])
    u = np.array(df[var])
    
    if option in ['positive', 'negative']:
        t_crossing, u_crossing = find_zero_crossings(t, u)
        # Insert zero crossings into the original time series
        for t_zero, u_zero in zip(t_crossing, u_crossing):
            idx = np.searchsorted(t, t_zero)
            t = np.insert(t, idx, t_zero)
            u = np.insert(u, idx, u_zero)
        
        if option == 'positive':
            u[u<0] = 0
        if option == 'negative':
            u[u>0] = 0

    I = trapz(u, t)
    return I

#%% read results file
var_list = list()
# bui[1] doesn't have dhw
var_list += index_var_list(f'bui[{_i}].dHHotWat_flow',
                           _i,
                           range(2,nBui+1))
var_list_pre_index = [
    f'bui[{_i}].ets.PCoo',
    f'bui[{_i}].dHChiWat_flow',
    f'bui[{_i}].dHHeaWat_flow',
    f'bui[{_i}].ets.hex.hex.Q1_flow',
    'cenPla.gen.ind.ySea']
var_list += index_var_list(var_list_pre_index,
                           _i,
                           ranBui)
results = get_vars(var_list,
                   mat_file_name,
                   'dymola')

#%% process results data
data_dict = {
    ("Electricity import", "ETS chiller", "electricity") : 0,
    ("ETS hex", "ETS chiller", "heat rejection") : 0,
    ("ETS hex", "ETS chiller", "cooling rejection") : 0,
    ("ETS chiller", "Cooling load", "cooling") : 0,
    ("ETS chiller", "Heating load", "space heating") : 0,
    ('ETS chiller', 'DHW load', 'domestic hot water') : 0,
        }
for i in ranBui:
    data_dict[("Electricity import", "ETS chiller", "electricity")] += \
        abs(integrate_result(results, f'bui[{i}].ets.PCoo'))
    data_dict[("ETS hex", "ETS chiller", "heat rejection")] += \
        abs(integrate_result(results, f'bui[{i}].ets.hex.hex.Q1_flow', 'positive'))
    data_dict[("ETS hex", "ETS chiller", "cooling rejection")] += \
        abs(integrate_result(results, f'bui[{i}].ets.hex.hex.Q1_flow', 'negative'))
    data_dict[("ETS chiller", "Cooling load", "cooling")] += \
        abs(integrate_result(results, f'bui[{i}].dHChiWat_flow'))
    data_dict[("ETS chiller", "Heating load", "space heating")] += \
        abs(integrate_result(results, f'bui[{i}].dHHeaWat_flow'))
    if i != 1: # bui[1] doesn't have dhw
        data_dict[("ETS chiller", "DHW load", "domestic hot water")] += \
            abs(integrate_result(results, f'bui[{i}].dHHotWat_flow'))

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

#%% validation
J_to_kWh = 2.7777777777777776e-07
veri_ele_coo = data_dict[("Electricity import", "ETS chiller", "electricity")] \
             + data_dict[("ETS hex", "ETS chiller", "cooling rejection")] \
             + data_dict[("ETS chiller", "Cooling load", "cooling")]
veri_hea     = data_dict[("ETS hex", "ETS chiller", "heat rejection")] \
             + data_dict[("ETS chiller", "Heating load", "space heating")] \
             + data_dict[("ETS chiller", "DHW load", "domestic hot water")]
print("### VALIDATION ###")
print(f'total cooling load = {data_dict[("ETS chiller", "Cooling load", "cooling")]*J_to_kWh:.5g} kWh')
print(f'    reference from load files: {16908188:.5g} kWh')
print(f'total heating load = {data_dict[("ETS chiller", "Heating load", "space heating")]*J_to_kWh:.5g} kWh')
print(f'    reference from load files: {10080563.2344998:.5g} kWh')
print(f'total dhw load = {data_dict[("ETS chiller", "DHW load", "domestic hot water")]*J_to_kWh:.5g} kWh')
print(f'    reference from load files: {4748967.95197562:.5g} kWh')
print(f"chiller ele + eva = {veri_ele_coo*J_to_kWh:.5g} kWh")
print(f"chiller con       = {veri_hea*J_to_kWh    :.5g} kWh")