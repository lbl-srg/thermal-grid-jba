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

CWD = os.getcwd()

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

indices = (df_base.iloc[:, 1] != df_heat.iloc[:, 1]) | (df_base.iloc[:, 1] != df_cold.iloc[:, 1])
indices_hole = indices[indices].index.tolist()
tdb_hole = tdb
tdb_hole[indices_hole] = np.nan
indices = (df_base.iloc[:, 1] != df_heat.iloc[:, 1])
indices_heat = indices[indices].index.tolist()
indices = (df_base.iloc[:, 1] != df_cold.iloc[:, 1])
indices_cold = indices[indices].index.tolist()

# Convert seconds of year to datetime objects
base_date = datetime(2025, 1, 1)
dates = [base_date + timedelta(seconds=int(s)) for s in soy]
formatted_dates = [d.strftime('%b-%d') for d in dates]

# Create a figure and two subplots sharing the same x-axis
fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True)

# Plot the fTMY on the top subplot
ax1.plot(formatted_dates, df_base[1],
         label='fTMY',
         linewidth=0.5,
         color = 'grey')
fig.text(0.0, 0.5, 'Dry-Bulb Temperature (°C)', va='center', rotation='vertical')
#ax1.set_title('Top Figure')
#ax1.legend()

secax1 = ax1.secondary_yaxis('right', functions=(celsius_to_fahrenheit, lambda f: (f - 32) * 5/9))
fig.text(0.98, 0.5, 'Dry-Bulb Temperature (°F)', va='center', rotation='vertical')

# Plot the first half of cold snap and the second half of heat wave on the bottom subplot
ax2.plot(formatted_dates, tdb_hole,
         label="fTMY",
         linewidth=0.5,
         color = "grey")
ax2.plot([formatted_dates[i] for i in indices_heat], df_heat.iloc[indices_heat, 1],
         label="Heat wave",
         linewidth=0.5,
         color = "red")
ax2.plot([formatted_dates[i] for i in indices_cold], df_cold.iloc[indices_cold, 1],
         label="Cold snap",
         linewidth=0.5,
         color = "blue")
ax2.legend()

secax2 = ax2.secondary_yaxis('right', functions=(celsius_to_fahrenheit, lambda f: (f - 32) * 5/9))

# Set the major ticks to be at the start of each month
ax2.xaxis.set_major_locator(mdates.MonthLocator())
ax2.xaxis.set_major_formatter(mdates.DateFormatter('%b-%-d'))
plt.xticks(rotation=45)
plt.tight_layout()

