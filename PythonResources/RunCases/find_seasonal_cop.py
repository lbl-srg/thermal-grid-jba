#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 11 11:50:10 2025

@author: casper
"""

import os
import glob
import pandas as pd
import numpy as np
from buildingspy.io.outputfile import Reader

CWD = os.getcwd()

#%%

for cas in ["ETS_All_futu",
            "cluster_A_futu",
            "cluster_B_futu",
            "cluster_C_futu",
            "cluster_D_futu",
            "cluster_E_futu"]:

    # mat_file_path = os.path.realpath(os.path.join(CWD, "simulations", cas, "ConnectedETSWithDHW.mat"))
    mat_file_path = os.path.realpath(glob.glob(os.path.join(CWD, "simulations", cas, "*.mat"))[0])
    
    r=Reader(mat_file_path, 'dymola')
    
    (t, COP) = r.values('bui.ets.chi.chi.COP')
    (t, uCoo) = r.values('bui.ets.chi.uCoo')
    (t, uHea) = r.values('bui.ets.chi.uHea')
    
    data = pd.DataFrame({'t': t, 'COP': COP, 'uCoo': uCoo, 'uHea': uHea})
    
    # Convert the timestamp to datetime format
    data['datetime'] = pd.to_datetime(data['t'], unit='s', origin='2025-01-01')
    
    # Filter
    data = data[data['COP'] > 0.01]
    data = data[data['COP'] < 15.0] # start up transient
    data = data[np.isclose(data['t'] % 3600, 0)] # only keep hourly sampled values
    data = data.iloc[:-1] # drop the last point which would be categorised to the next year
    
    # Section the data to each calendar month
    data['month'] = data['datetime'].dt.to_period('M')
    
    # Filter data based on operational modes
    conditions = [
        (data['uCoo'] == 1) & (data['uHea'] == 1),
        (data['uCoo'] == 1) & (data['uHea'] == 0),
        (data['uCoo'] == 0) & (data['uHea'] == 1)
                  ]
    modes = ['simultaneous', 'coolingonly', 'heatingonly']
    data['mode'] = np.select(conditions, modes, default='other')
    
    # Calculate the average of y for each month and each mode
    result = data.groupby(['month', 'mode'])['COP'].mean().unstack(fill_value=np.nan)
    result_count = data.groupby(['month', 'mode']).size().unstack(fill_value=0)
    # result = data.groupby(['month'])['COP'].mean()
    
    result.index = result.index.strftime('%B')
    result_count.index = result_count.index.strftime('%B')
    
    print(cas)
    print(result)
    print(result_count)