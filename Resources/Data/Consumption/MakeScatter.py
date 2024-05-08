#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May  7 14:52:42 2024

@author: casper

This script makes plots associated with the weather file.
"""

from _config_estcp import *

import numpy as np
import seaborn as sns

def getEnergy(stag, buils : list, util):
    ene = np.zeros(8760)
    for buil in buils:
        ene = ene + np.array(readMID(f'{stag}_{buil}_{util}'))
    return ene

#%% Configurations
stag = 'base'
buils = west
util = 'coo'


#%% Load weather data
i_start = 40 # starting index in the weather mos file
Tdb = np.zeros(8760)
with open('../Weather/USA_MD_Andrews.AFB.745940_TMY3.mos', 'r') as fwea:
    for i, line in enumerate(fwea):
        if i >= i_start:
            Tdb[i-i_start] = line.split('\t')[1]

#%% Load energy use data
ene = getEnergy(stag=stag, buils=buils, util=util)

#%% seaborn config
sns.set_theme(style='darkgrid')

#%% Plot energy vs. weather
#sns.scatterplot(x=Tdb, y=ene)

#%% Plot weather TS
t_dt = pd.date_range(start='2005-01-01',
                     end='2006-01-01',
                     freq='h')[0:8760] # time array as date
sns.lineplot(x=t_dt,y=Tdb)
