#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb  8 20:41:08 2024

@author: casper

Makes figures that express load (im)balance.
"""

import os

import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import numpy as np
import pandas as pd

from _config_estcp import *

def setXAxisMonths():
    # Set x-axis to display months
    #   The texts only show in the lowest subplot.
    #   All other subplots only show the tick marks but not the texts.
    X = plt.gca().xaxis
    X.set_major_locator(mdates.MonthLocator())
    X.set_major_formatter(mdates.DateFormatter('%b'))
    
def makePlot(tit: str):
    linewidth = 0.8
    
    fig = plt.figure()
    plt.rcParams['figure.figsize'] = [6, 6]

    ax = fig.add_subplot(311)
    ax.set_title('Hourly Consumption (kWh/h)',
                 loc = 'left',
                 fontsize = 12)
    h1, = ax.plot(t_hoy, hea,
                  'r', linewidth = linewidth)
    h1, = ax.plot(t_hoy, dhw, 'm',
                  linewidth = linewidth)
    h1, = ax.plot(t_hoy, - coo,
                  'b', linewidth = linewidth)
    setXAxisMonths()
    ax.xaxis.set_major_formatter(plt.NullFormatter())
    
    ax = fig.add_subplot(312)
    ax.set_title('Monthly Peak (kW)',
                 loc = 'left',
                 fontsize = 12)
    h1, = ax.plot(t_ms, heaPea,
                  'r', linewidth = linewidth)
    h1, = ax.plot(t_ms, dhwPea,
                  'm', linewidth = linewidth)
    h1, = ax.plot(t_ms, - cooPea,
                  'b', linewidth = linewidth)
    h1, = ax.plot(t_ms, netPea,
                  'k', linewidth = linewidth)
    plt.axhline(0, color = 'k', linewidth = linewidth/2)
    setXAxisMonths()
    ax.xaxis.set_major_formatter(plt.NullFormatter())

    ax = fig.add_subplot(313)
    ax.set_title('Cumulative Consumption (thousand kWh)',
                 loc = 'left',
                 fontsize = 12)
    h1, = ax.plot(t_hoy, np.cumsum(hea)/1000,
                  'r', linewidth = linewidth, label = 'sp. heating')
    h1, = ax.plot(t_hoy, np.cumsum(dhw)/1000,
                  'm', linewidth = linewidth, label = 'dom. hot water')
    h1, = ax.plot(t_hoy, - np.cumsum(coo)/1000,
                  'b', linewidth = linewidth, label = 'cooling')
    h1, = ax.plot(t_hoy, np.cumsum(net)/1000,
                  'k', linewidth = linewidth, label = 'net energy')
    plt.axhline(0, color = 'k', linewidth = linewidth/2)
    setXAxisMonths()
    xlabels = [item.get_text() for item in ax.get_xticklabels()]
    xlabels[-1] = ''
    ax.set_xticklabels(xlabels)
    ax.legend(loc = 'upper center',
              bbox_to_anchor = (0.5, -0.2, - 0.1, 0.),
              fancybox = True,
              shadow = True,
              ncol = 4)
    
    plt.suptitle(tit,
                 x = 0.05,
                 y = 0.96,
                 horizontalalignment = 'left',
                 fontsize = 14)
    fig.tight_layout()
    
    if not flag_debug:    
        plt.savefig(os.path.join(dirFigu,tit + '.png'))
        plt.close()

###########################################################################
## Start of main process ##

flag_debug = False
sBui_debug = '1539'
# debug for plotting a single building
#   will not delete existing plot files
#   will not save the plot
#   will not close the plot (so that it displays in spyder)
#   will not plot the combined energy

if not flag_debug:
    # Deletes the folder of the previous written exchange files
    #   and remake the directory'
    os.system('rm -rf ' + dirFigu)
    os.makedirs(dirFigu)

t_dt = pd.date_range(start='2005-01-01',
                     end='2006-01-01',
                     freq='h')[0:8760] # time array as date
t_hoy = np.array(t_dt.tolist()) # hour of year
t_moy = np.array(t_dt.month.tolist()) # month of year, for each hour
mons = np.linspace(1,12,12,dtype = int)
t_ms = pd.date_range(start='2005-01-01',
                     end='2006-01-01',
                     freq='MS')[0:12].tolist() # list for month starts
"""
MOY = pd.date_range(start='2005-01-01',
                    end='2006-01-01',
                    freq='h').month.tolist()[0:8760]
    # array for month of year across one non-leap year
"""

heaSum = np.zeros(8760) # heating, sum of all buildings
dhwSum = np.zeros(8760) # domestic hot water, sum of all buildings
cooSum = np.zeros(8760) # cooling, sum of all buildings
netSum = np.zeros(8760) # net energy, sum of all buildings

#sBui = '1569'
if flag_debug:
    sBuis = [sBui_debug]
for sBui in sBuis:
    ## Read MIDs
    hea = np.array(readMID(sBui + '_hea'))
    heaSum += hea
    hasDhw = os.path.isfile(os.path.join(dirExch, sBui + '_dhw.csv'))
    if hasDhw:
        dhw = np.array(readMID(sBui + '_dhw'))
        dhwSum += dhw
    else:
        dhw = np.zeros(8760)
    coo = np.array(readMID(sBui + '_coo'))
    cooSum += coo
    net = hea + dhw - coo
    netSum += net
    
    # Compute monthly peaks
    heaPea = np.zeros(12)
    dhwPea = np.zeros(12)
    cooPea = np.zeros(12)
    for m in mons:
        heaPea[m-1] = np.max(hea[t_moy == m])
        dhwPea[m-1] = np.max(dhw[t_moy == m])
        cooPea[m-1] = np.max(coo[t_moy == m])
    netPea = heaPea + dhwPea - cooPea
    
    makePlot(sBui + ' ' + dfBldg.loc[dfBldg['bldg_no'] == sBui,'name'].tolist()[0])

if not flag_debug:
    hea = heaSum
    dhw = dhwSum
    coo = cooSum
    net = netSum
    
    heaPea = np.zeros(12)
    dhwPea = np.zeros(12)
    cooPea = np.zeros(12)
    for m in mons:
        heaPea[m-1] = np.max(hea[t_moy == m])
        dhwPea[m-1] = np.max(dhw[t_moy == m])
        cooPea[m-1] = np.max(coo[t_moy == m])
    netPea = heaPea + dhwPea - cooPea
    
    makePlot('Combined ({} buildings)'.format(len(sBuis)))

"""
ax = fig.add_subplot(512)
h1, = ax.plot(t, net, 'k')
plt.axhline(0, color = 'k')

ax = fig.add_subplot(513)
h1, = ax.plot(np.array(t).reshape(int(8760/3),3)[:,0],
              np.sum(np.array(net).reshape(int(8760/3),3), axis = 1),
              'k')
plt.axhline(0, color = 'k')

ax = fig.add_subplot(514)
h1, = ax.plot(np.array(t).reshape(int(8760/24),24)[:,0],
              np.sum(np.array(net).reshape(int(8760/24),24), axis = 1),
              'k')
plt.axhline(0, color = 'k')
"""


