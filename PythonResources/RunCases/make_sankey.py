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
_i = r'%%i%%' # placeholder string to be replaced with index
J_to_kWh = 2.7777777777777776e-07

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
var_list += ['datDis.cpWatLiq',
             'cenPla.gen.ind.ySea',
             'TDisWatSup.T',
             'TDisWatRet.T',
             'pumDis.m_flow',
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
data_dict = {
    ("Electricity import", "ETS chiller", "electricity") : 0,
    ("Reservoir loop", "ETS chiller", "reservoir heat") : 0,
    ("Reservoir loop", "ETS chiller", "reservoir cooling") : 0,
    ("ETS chiller", "Cooling load", "cooling") : 0,
    ("ETS chiller", "Heating load", "space heating") : 0,
    ("ETS chiller", "DHW load", "domestic hot water") : 0,
    ("Reservoir loop", "Ground", "ground anergy") : 0,
    ("Ground", "Reservoir loop", "ground anergy") : 0,
    ("Dry cooler", "Economizer", "heat rejection") : 0,
    ("Dry cooler", "Economizer", "cooling rejection") : 0,
    ("Economizer", "Reservoir loop", "reservoir heat") : 0,
    ("Economizer", "Reservoir loop", "reservoir cooling") : 0,
    ("Electricity import", "Central chiller", "electricity") : 0,
    ("Dry cooler", "Central chiller", "heat rejection") : 0,
    ("Dry cooler", "Central chiller", "cooling rejection") : 0,
    ("Central chiller", "Reservoir loop", "reservoir heat") : 0,
    ("Central chiller", "Reservoir loop", "reservoir cooling") : 0,
    ("Borefield center", "Reservoir loop", "borefield center anergy") : 0,
    ("Reservoir loop", "Borefield center", "borefield center anergy") : 0,
    ("Borefield perimeter", "Reservoir loop", "borefield perimeter anergy") : 0,
    ("Reservoir loop", "Borefield perimeter", "borefield perimeter anergy") : 0
        }

# each building
for i in range(1,nBui+1):
    data_dict[("Electricity import", "ETS chiller", "electricity")] += \
        abs(integrate_result(results, f'bui[{i}].ets.PCoo'))
    data_dict[("Reservoir loop", "ETS chiller", "reservoir heat")] += \
        abs(integrate_result(results, f'QEtsHex_flow.u[{i}]', 'negative'))
    data_dict[("Reservoir loop", "ETS chiller", "reservoir cooling")] += \
        abs(integrate_result(results, f'QEtsHex_flow.u[{i}]', 'positive'))
    data_dict[("ETS chiller", "Cooling load", "cooling")] += \
        abs(integrate_result(results, f'bui[{i}].dHChiWat_flow'))
    data_dict[("ETS chiller", "Heating load", "space heating")] += \
        abs(integrate_result(results, f'bui[{i}].dHHeaWat_flow'))
    if i != 1: # bui[1] doesn't have dhw
        data_dict[("ETS chiller", "DHW load", "domestic hot water")] += \
            abs(integrate_result(results, f'bui[{i}].dHHotWat_flow'))

# ground
for i in range(1,nBui+2):
    data_dict[("Reservoir loop", "Ground", "ground anergy")] += \
        abs(integrate_result(results, f'dis.heatPorts[{i}].Q_flow','negative'))
    data_dict[("Ground", "Reservoir loop", "ground anergy")] += \
        abs(integrate_result(results, f'dis.heatPorts[{i}].Q_flow','positive'))

# Central plant
# economiser
data_dict[("Dry cooler", "Economizer", "heat rejection")] = \
    abs(integrate_result(results, 'cenPla.gen.hex.Q1_flow', 'negative'))
data_dict[("Dry cooler", "Economizer", "cooling rejection")] = \
    abs(integrate_result(results, 'cenPla.gen.hex.Q1_flow', 'positive'))
data_dict[("Economizer", "Reservoir loop", "reservoir heat")] = \
    data_dict[("Dry cooler", "Economizer", "cooling rejection")]
data_dict[("Economizer", "Reservoir loop", "reservoir cooling")] = \
    data_dict[("Dry cooler", "Economizer", "heat rejection")]

# central chiller
data_dict[("Electricity import", "Central chiller", "electricity")] = \
    abs(integrate_result(results, 'cenPla.gen.heaPum.P'))
data_dict[("Dry cooler", "Central chiller", "cooling rejection")] =\
    abs(integrate_result(results, 'cenPla.gen.heaPum.QEva_flow', 'negative'))
data_dict[("Dry cooler", "Central chiller", "heat rejection")] =\
    abs(integrate_result(results, 'cenPla.gen.heaPum.QEva_flow', 'positive'))
data_dict[("Central chiller", "Reservoir loop", "reservoir heat")] =\
    abs(integrate_result(results, 'cenPla.gen.heaPum.QCon_flow', 'positive'))
data_dict[("Central chiller", "Reservoir loop", "reservoir cooling")] =\
    abs(integrate_result(results,'cenPla.gen.heaPum.QCon_flow', 'negative'))

# borefield
data_dict[("Borefield center", "Reservoir loop", "borefield center anergy")] =\
    abs(integrate_result(results,'cenPla.QBorCen_flow', 'positive'))
data_dict[("Reservoir loop", "Borefield center", "borefield center anergy")] =\
    abs(integrate_result(results,'cenPla.QBorCen_flow', 'negative'))
data_dict[("Borefield perimeter", "Reservoir loop", "borefield perimeter anergy")] =\
    abs(integrate_result(results,'cenPla.QBorPer_flow', 'positive'))
data_dict[("Reservoir loop", "Borefield perimeter", "borefield perimeter anergy")] =\
    abs(integrate_result(results,'cenPla.QBorPer_flow', 'negative'))

#%% make sankey diagram

# Map energy carriers to colors
dict_color = {
    "electricity": 'rgba(60, 179, 113, 0.8)',
    "cooling": 'rgba(0, 0, 255, 0.8)',
    "space heating": 'rgba(255, 0, 0, 0.8)',
    "domestic hot water": 'rgba(106, 90, 205, 0.8)',
    "heat rejection": 'rgba(255, 0, 0, 0.4)',
    "cooling rejection": 'rgba(0, 0, 255, 0.4)',
    "reservoir heat": 'rgba(255, 0, 0, 0.6)',
    "reservoir cooling": 'rgba(0, 0, 255, 0.6)',
    "ground anergy": 'rgba(165, 165, 0, 0.8)',
    "borefield center anergy": 'rgba(255, 165, 0, 0.8)',
    "borefield perimeter anergy": 'rgba(165, 255, 0, 0.8)'
}

# Extract unique nodes and creat a mapping from node name to index
nodes = sorted(set(node for pair in data_dict.keys() for node in pair[:2]))
node_indices = {node: idx for idx, node in enumerate(nodes)}

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

fig.update_layout(title_text="Energy flow", font_size=10)
fig.show()

#%% validation
# checks first-law conservation
# compares numbers from other sources

print("### VALIDATION ###")
print('\n- Integration of load -')
print(f'total cooling load = {data_dict[("ETS chiller", "Cooling load", "cooling")]*J_to_kWh:.3g} kWh')
print(f'    reference from load files: {16908188:.3g} kWh')
print(f'total heating load = {data_dict[("ETS chiller", "Heating load", "space heating")]*J_to_kWh:.3g} kWh')
print(f'    reference from load files: {10080563.2344998:.3g} kWh')
print(f'total dhw load = {data_dict[("ETS chiller", "DHW load", "domestic hot water")]*J_to_kWh:.3g} kWh')
print(f'    reference from load files: {4748967.95197562:.3g} kWh')

print('\n- ETS chiller -')
ets_chi_in  = data_dict[("Electricity import", "ETS chiller", "electricity")] \
            + data_dict[("Reservoir loop", "ETS chiller", "reservoir cooling")] \
            + data_dict[("ETS chiller", "Cooling load", "cooling")]
ets_chi_out = data_dict[("Reservoir loop", "ETS chiller", "reservoir heat")] \
            + data_dict[("ETS chiller", "Heating load", "space heating")] \
            + data_dict[("ETS chiller", "DHW load", "domestic hot water")]
print(f"ets chiller ele + eva = {ets_chi_in*J_to_kWh:.3g} kWh")
print(f"ets chiller con       = {ets_chi_out*J_to_kWh:.3g} kWh")

print('\n- Central plant chiller -')
cen_chi_in  = data_dict[("Electricity import", "Central chiller", "electricity")] \
            + data_dict[("Dry cooler", "Central chiller", "cooling rejection")] \
            + data_dict[("Central chiller", "Reservoir loop", "reservoir cooling")]
cen_chi_out = data_dict[("Dry cooler", "Central chiller", "heat rejection")] \
            + data_dict[("Central chiller", "Reservoir loop", "reservoir heat")]
print(f"central chiller ele + eva = {cen_chi_in*J_to_kWh:.3g} kWh")
print(f"central chiller con       = {cen_chi_out*J_to_kWh:.3g} kWh")

print('\n- Reservoir loop -')
res_loo_in  = data_dict[("Reservoir loop", "ETS chiller", "reservoir heat")] \
            + data_dict[("Ground", "Reservoir loop", "ground anergy")] \
            + data_dict[("Economizer", "Reservoir loop", "reservoir heat")] \
            + data_dict[("Central chiller", "Reservoir loop", "reservoir heat")] \
            + data_dict[("Borefield center", "Reservoir loop", "borefield center anergy")] \
            + data_dict[("Borefield perimeter", "Reservoir loop", "borefield perimeter anergy")]
res_loo_out = data_dict[("Reservoir loop", "ETS chiller", "reservoir cooling")] \
            + data_dict[("Reservoir loop", "Ground", "ground anergy")] \
            + data_dict[("Economizer", "Reservoir loop", "reservoir cooling")] \
            + data_dict[("Central chiller", "Reservoir loop", "reservoir cooling")] \
            + data_dict[("Reservoir loop", "Borefield center", "borefield center anergy")] \
            + data_dict[("Reservoir loop", "Borefield perimeter", "borefield perimeter anergy")]
print(f"energy into reservoir loop   = {res_loo_in*J_to_kWh:.3g} kWh")
print(f"energy out of reservoir loop = {res_loo_out*J_to_kWh:.3g} kWh")

