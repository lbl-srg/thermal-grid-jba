#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 14 13:53:10 2025

@author: casper
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

CWD = os.getcwd()

epw_file = os.path.realpath(os.path.join(CWD,"../Weather/USA_MD_Andrews.AFB.745940_TMY3.epw"))

df = pd.read_csv(epw_file, skiprows=8, header=None)

year = df[0] # Will be overwritten to 2005
month = df[1]
day = df[2]
hour = df[3] - 1 # converts 1 to 24 to 0 to 23
dry_bulb_temp = df[6]
dew_point_temp = df[7]
relative_humidity = df[8]

date_time = pd.to_datetime('2005' + '-' + 
                           month.astype(str).str.zfill(2) + '-' + 
                           day.astype(str).str.zfill(2) + ' ' + 
                           hour.astype(str).str.zfill(2) + ':00', 
                           format='%Y-%m-%d %H:%M')

fig, ax = plt.subplots(1,1,figsize=(10, 4))

ax.plot(date_time, dry_bulb_temp,linewidth=0.5)

    