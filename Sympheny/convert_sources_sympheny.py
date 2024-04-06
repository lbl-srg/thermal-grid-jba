# -*- coding: utf-8 -*-
"""
Created on Thu Apr  4 10:51:53 2024

@author: remi
"""

import pandas as pd
import numpy as np
import os

dir_ini = r'C:\git\thermal-grid-jba\Resources\Data\Consumption\exchange'
dir_end = r'C:\git\thermal-grid-jba\Resources\Data\Consumption\to_sympheny'

files_ini = [k for k in os.listdir(dir_ini) if k.endswith('.csv')]

for k in files_ini:
    lect = pd.read_csv(os.path.join(dir_ini, k), header=None)
    lect.index = np.arange(1, len(lect) + 1)
    lect.to_excel(os.path.join(dir_end, k.replace('.csv', '.xlsx')), header=None)
    
#%%

dir_end = r'C:\git\thermal-grid-jba\Resources\Data\Consumption\to_sympheny'
files = os.listdir(dir_end)
hubs = set([k.split('_')[0] for k in files])
hubs = sorted(hubs)