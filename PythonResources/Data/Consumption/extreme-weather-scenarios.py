#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 25 23:12:11 2025

@author: casper
"""

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import os
import numpy as np
from datetime import datetime, timedelta
from matplotlib.lines import Line2D

CWD = os.getcwd()

# plot configurations
linewidth = 0.25
linecolor = {
    'fTMY' : 'k',
    'Heat wave' : 'r',
    'Cold snap' : 'b'
    }
xticksC = np.arange(-10,50,10)
xticksF = np.arange(5,110,15)
    
legend_elements = [Line2D([0], [0], label='fTMY',      color=linecolor['fTMY'],      lw=linewidth*5),
                   Line2D([0], [0], label='Heat wave', color=linecolor['Heat wave'], lw=linewidth*5),
                   Line2D([0], [0], label='Cold snap', color=linecolor['Cold snap'], lw=linewidth*5)]

def celsius_to_fahrenheit(celsius):
    return (celsius * 9/5) + 32

mos_base = os.path.realpath(os.path.join(CWD,"../Weather/fTMY_Maryland_Prince_George's_NORESM2_2020_2039.mos"))
mos_heat = os.path.realpath(os.path.join(CWD,"../Weather/USA_MD_Andrews.AFB.fTMY.HeatWave.mos"))
mos_cold = os.path.realpath(os.path.join(CWD,"../Weather/USA_MD_Andrews.AFB.fTMY.ColdSnap.mos"))

df_base = pd.read_csv(mos_base, skiprows=40, delimiter = '\t', header=None)
df_heat = pd.read_csv(mos_heat, skiprows=40, delimiter = '\t', header=None)
df_cold = pd.read_csv(mos_cold, skiprows=40, delimiter = '\t', header=None)

soy = df_base[0] # second of year
tdb = df_base[1].copy() # dry-bulb temp from the reference

_indices = (df_base.iloc[:, 1] != df_heat.iloc[:, 1])
indices_heat = _indices[_indices].index.tolist()
tdb_hole_heat = tdb.copy()
tdb_hole_heat[indices_heat] = np.nan # heat wave points are replaced with nan

_indices = (df_base.iloc[:, 1] != df_cold.iloc[:, 1])
indices_cold = _indices[_indices].index.tolist()
tdb_hole_cold = tdb.copy()
tdb_hole_cold[indices_cold] = np.nan # cold snap points are replaced with nan

# Convert seconds of year to datetime objects
base_date = datetime(2025, 1, 1)
dates = [base_date + timedelta(seconds=int(s)) for s in soy]
formatted_dates = [d.strftime('%b-%d') for d in dates]

# Create a figure and two subplots sharing the same x-axis
fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True)

# Top plot for heat wave
ax1.plot(formatted_dates, tdb_hole_heat,
         label='fTMY',
         linewidth=linewidth,
         color=linecolor['fTMY'])
ax1.plot([formatted_dates[i] for i in indices_heat], df_heat.iloc[indices_heat, 1],
         label='Heat wave',
         linewidth=linewidth,
         color=linecolor['Heat wave'])
ax1.yaxis.set_ticks(xticksC)
ax1.grid(True)
fig.text(0.0, 0.5, 'Dry-Bulb Temperature (°C)', va='center', rotation='vertical')
ax1.text(1, 35, '(a) Heat wave',
         bbox=dict(facecolor='white', edgecolor='none'))
#ax1.set_title('(a) Heat wave')
#ax1.legend()

secax1 = ax1.secondary_yaxis('right', functions=(celsius_to_fahrenheit, lambda f: (f - 32) * 5/9))
secax1.yaxis.set_ticks(xticksF)
fig.text(0.98, 0.5, 'Dry-Bulb Temperature (°F)', va='center', rotation='vertical')

# Bottom plot for cold snap
ax2.plot(formatted_dates, tdb_hole_cold,
         label='fTMY',
         linewidth=linewidth,
         color=linecolor['fTMY'])
ax2.plot([formatted_dates[i] for i in indices_cold], df_cold.iloc[indices_cold, 1],
         label='Cold snap',
         linewidth=linewidth,
         color=linecolor['Cold snap'])
ax2.yaxis.set_ticks(xticksC)
ax2.grid(True)
ax2.text(1, 35, '(b) Cold snap',
         bbox=dict(facecolor='white', edgecolor='none'))
ax2.legend(handles = legend_elements,
           loc = 'upper center',
           bbox_to_anchor = (0.5, 1.4, 0., 0.),
           fancybox = True,
           shadow = True,
           ncol = 3)

secax2 = ax2.secondary_yaxis('right', functions=(celsius_to_fahrenheit, lambda f: (f - 32) * 5/9))
secax2.yaxis.set_ticks(xticksF)

# Set the major ticks to be at the start of each month
ax2.xaxis.set_major_locator(mdates.MonthLocator())
ax2.xaxis.set_major_formatter(mdates.DateFormatter('%b-%-d'))
plt.xticks(rotation=45)
plt.tight_layout()

# plt.show()
plt.savefig("extreme-weather-scenarios.pdf",
            bbox_inches = 'tight')
plt.close()