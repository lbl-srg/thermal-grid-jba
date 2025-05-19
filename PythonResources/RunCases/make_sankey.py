#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 19 11:27:46 2025

@author: casper
"""

import plotly.graph_objects as go
import plotly.io as pio
pio.renderers.default='browser'

# Semantic input data
data = [("Electricity input", "HRC - cooling only", 8, "electricity"),
        ("Electricity input", "HRC - heating only", 4, "electricity"),
        ("Electricity input", "HRC - simultaneous", 2, "electricity"),
        ("ETS hex", "HRC - cooling only", 8, "heat rejection"),
        ("ETS hex", "HRC - heating only", 4, "cooling rejection"),
        ("HRC - cooling only", "Cooling load", 10, "cooling"),
        ("HRC - heating only", "Heating load", 10, "space heating"),
        ("HRC - heating only", "DHW load", 1, "domestic hot water"),
        ("HRC - simultaneous", "Cooling load", 5, "cooling"),
        ("HRC - simultaneous", "Heating load", 6, "space heating"),
        ("HRC - simultaneous", "DHW load", 1, "domestic hot water")]

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
source = [node_indices[src] for src, tgt, val, carrier in data]
target = [node_indices[tgt] for src, tgt, val, carrier in data]
value = [val for src, tgt, val, carrier in data]
color = [dict_color[carrier] for src, tgt, val, carrier in data]

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