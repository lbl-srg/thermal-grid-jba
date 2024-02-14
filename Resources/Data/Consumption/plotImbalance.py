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
    X = plt.gca().xaxis
    X.set_major_locator(mdates.MonthLocator())
    X.set_major_formatter(mdates.DateFormatter('%b'))
    
def makePlot(tit: str):
    fig = plt.figure()

    ax = fig.add_subplot(311)
    h1, = ax.plot(t_hoy, hea, 'r')
    h1, = ax.plot(t_hoy, dhw, 'm')
    h1, = ax.plot(t_hoy, - coo, 'b')
    #plt.title(sBui + ' ' + dfBldg.loc[dfBldg['bldg_no'] == sBui,'name'].tolist()[0])
    #plt.title('Combined (six buildings)')
    plt.title(tit)
    setXAxisMonths()
    ax.xaxis.set_major_formatter(plt.NullFormatter())
    
    ax = fig.add_subplot(312)
    h1, = ax.plot(t_ms, heaPea, 'r')
    h1, = ax.plot(t_ms, dhwPea, 'm')
    h1, = ax.plot(t_ms, - cooPea, 'b')
    h1, = ax.plot(t_ms, netPea, 'k')
    plt.axhline(0, color = 'k')
    setXAxisMonths()
    ax.xaxis.set_major_formatter(plt.NullFormatter())

    ax = fig.add_subplot(313)
    h1, = ax.plot(t_hoy, np.cumsum(hea), 'r')
    h1, = ax.plot(t_hoy, np.cumsum(dhw), 'm')
    h1, = ax.plot(t_hoy, - np.cumsum(coo), 'b')
    h1, = ax.plot(t_hoy, np.cumsum(net), 'k')
    plt.axhline(0, color = 'k')
    setXAxisMonths()
    
    plt.savefig(os.path.join(dirFigu,tit + '.png'))
    plt.close()

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
sBuis = ['1045', '1380']
for sBui in sBuis:
#for sBui in ['1045']:
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

makePlot('Combined (six buildings)')

#t = np.linspace(1,8760,8760,dtype = int)

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


