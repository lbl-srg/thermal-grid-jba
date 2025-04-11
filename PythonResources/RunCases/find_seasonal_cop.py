#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 11 11:50:10 2025

@author: casper
"""

import os
import pandas as pd
import numpy as np
from buildingspy.io.outputfile import Reader

CWD = os.getcwd()

mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", "ETS_All_futu", "ConnectedETSWithDHW.mat"))

r=Reader(mat_file_path, 'dymola')

#%%
(t, COP) = r.values('bui.ets.chi.chi.COP')
(t, valIsoEva) = r.values('bui.ets.valIsoEva.y_actual')
(t, valIsoCon) = r.values('bui.ets.valIsoCon.y_actual')

#t[-1] -= 10 # so that it won't be categorised to the next year

data = pd.DataFrame({'t': t, 'y': COP, 'u1': valIsoEva, 'u2': valIsoCon})

# Convert the timestamp to datetime format
data['datetime'] = pd.to_datetime(data['t'], unit='s', origin='2025-01-01')

# Filter
data = data[data['y'] > 0.01]
data = data[data['y'] < 10.0] # start up transient
data = data[np.isclose(data['t'] % 3600, 0)] # only keep hourly sampled values

# Section the data to each calendar month
data['month'] = data['datetime'].dt.to_period('M')

# Filter data based on operational modes
conditions = [
    (data['u1'] < 0.01) & (data['u2'] < 0.01),
    (data['u1'] < 0.01) & (data['u2'] > 0.99),
    (data['u1'] > 0.99) & (data['u2'] < 0.01)
]
modes = ['simultaneous', 'coolingonly', 'heatingonly']
data['mode'] = np.select(conditions, modes, default='other')

# Calculate the average of y for each month and each mode
result = data.groupby(['month', 'mode'])['y'].mean().unstack(fill_value=np.nan)
result.index = result.index.strftime('%B')

print(result)