#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb  8 20:41:08 2024

@author: casper

Makes csv table for annual and monthly peaks.
Makes figures that express load (im)balance.
"""

import os
import calendar
import shutil

import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import numpy as np
import pandas as pd

from _config_estcp import *

def runBuildings(listBui,
                 sRet = 'post',
                 tit = '',
                 saveFigures = True):

    def setXAxisMonths():
        # Set x-axis to display months.
        #   The texts only show in the lowest subplot.
        #   All other subplots only show the tick marks but not the texts.
        X = plt.gca().xaxis
        X.set_major_locator(mdates.MonthLocator())
        X.set_major_formatter(mdates.DateFormatter('%b'))
        
    def getMonthly(bldg : str):
        # Compute annual and monthly peaks and totals.
        #   Heating is space heating and domestic hot water combined.
        
        for m in mons:
            elePea[m-1] = np.max(ele[t_moy == m])
            heaPea[m-1] = np.max(hea[t_moy == m])
            dhwPea[m-1] = np.max(dhw[t_moy == m])
            sndPea[m-1] = np.max(snd[t_moy == m])
            cooPea[m-1] = np.max(coo[t_moy == m])
            #netPea[m-1] = np.max(net[t_moy == m])
            #netPea[m-1] = net.flat[abs(net).argmax()]
            
            eleTot[m-1] = np.sum(ele[t_moy == m])
            heaTot[m-1] = np.sum(hea[t_moy == m])
            dhwTot[m-1] = np.sum(dhw[t_moy == m])
            sndTot[m-1] = np.sum(snd[t_moy == m])
            cooTot[m-1] = np.sum(coo[t_moy == m])
            
        #monPeaHea = calendar.month_name[np.argmax(sndPea) + 1]
        #monPeaCoo = calendar.month_name[np.argmax(cooPea) + 1]
        
        dfPeaEle.loc[len(dfPeaEle.index) + 1] = [bldg, np.max(elePea)] + elePea.tolist()
        dfPeaSnd.loc[len(dfPeaSnd.index) + 1] = [bldg, np.max(sndPea)] + sndPea.tolist()
        dfPeaCoo.loc[len(dfPeaCoo.index) + 1] = [bldg, np.max(cooPea)] + cooPea.tolist()
        
        dfTotEle.loc[len(dfTotEle.index) + 1] = [bldg, np.sum(eleTot)] + eleTot.tolist()
        dfTotSnd.loc[len(dfTotSnd.index) + 1] = [bldg, np.sum(sndTot)] + sndTot.tolist()
        dfTotCoo.loc[len(dfTotCoo.index) + 1] = [bldg, np.sum(cooTot)] + cooTot.tolist()
        
    def makePlot(tit: str):
        linewidth = 0.8
        
        fig = plt.figure()
        plt.rcParams['figure.figsize'] = [6, 6]
    
        ax = fig.add_subplot(311)
        ax.set_title('Hourly Consumption (kWh/h)',
                     loc = 'left',
                     fontsize = 12)
        h1, = ax.plot(t_hoy, snd,
                      'r', linewidth = linewidth)
        h1, = ax.plot(t_hoy, - coo,
                      'b', linewidth = linewidth)
        setXAxisMonths()
        ax.xaxis.set_major_formatter(plt.NullFormatter())
        plt.grid()
        
        ax = fig.add_subplot(312)
        ax.set_title('Monthly Peak (kW)',
                     loc = 'left',
                     fontsize = 12)
        """
        h1, = ax.plot(t_ms, sndPea,
                      'r', linewidth = linewidth)
        h1, = ax.plot(t_ms, - cooPea,
                      'b', linewidth = linewidth)
        #h1, = ax.plot(t_ms, netPea,
        #              'k', linewidth = linewidth)
        """
        h1 = ax.bar(t_ms, sndPea,
                    color = 'r',
                    width = 10)
        h1 = ax.bar(t_ms, - cooPea,
                    color = 'b',
                    width = 10)
        plt.axhline(0, color = 'k', linewidth = linewidth/2)
        setXAxisMonths()
        ax.xaxis.set_major_formatter(plt.NullFormatter())
        plt.grid()
    
        ax = fig.add_subplot(313)
        ax.set_title('Cumulative Consumption (thousand kWh)',
                     loc = 'left',
                     fontsize = 12)
        h1, = ax.plot(t_hoy, np.cumsum(snd)/1000,
                      'r', linewidth = linewidth, label = 'combined heating')
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
        plt.grid()
        
        plt.suptitle(tit,
                     x = 0.05,
                     y = 0.96,
                     horizontalalignment = 'left',
                     fontsize = 14)
        fig.tight_layout()
        
        if saveFigures:
            plt.savefig(os.path.join(dirFigu,tit + '.pdf'))
            plt.close()

    # Sum of all buildings selected
    ele = np.zeros(8760) # end-use electricity
    hea = np.zeros(8760) # space heating
    dhw = np.zeros(8760) # domestic hot water
    snd = np.zeros(8760) # space heating and domestic hot water combined
    coo = np.zeros(8760) # cooling
    net = np.zeros(8760) # net energy
    
    # Read MIDs and sum them up
    for sBui in listBui:
        ele_tmp = np.array(readMID(f'{sRet}_{sBui}_ele'))
        ele += ele_tmp
        hea_tmp = np.array(readMID(f'{sRet}_{sBui}_hea'))
        hea += hea_tmp
        hasDhw = os.path.isfile(os.path.join(dirExch, f'{sRet}_{sBui}_dhw.csv'))
        if hasDhw:
            dhw_tmp = np.array(readMID(f'{sRet}_{sBui}_dhw'))
        else:
            dhw_tmp = np.zeros(8760)
        dhw += dhw_tmp
        #snd_tmp = hea_tmp + dhw_tmp
        coo_tmp = np.array(readMID(f'{sRet}_{sBui}_coo'))
        coo += coo_tmp
    
    snd = hea + dhw
    net = hea + dhw - coo
    
    # Monthly peaks
    elePea = np.zeros(12)
    heaPea = np.zeros(12)
    dhwPea = np.zeros(12)
    sndPea = np.zeros(12)
    cooPea = np.zeros(12)
    netPea = np.zeros(12)
    
    # Monthly totals
    eleTot = np.zeros(12)
    heaTot = np.zeros(12)
    dhwTot = np.zeros(12)
    sndTot = np.zeros(12)
    cooTot = np.zeros(12)
    netTot = np.zeros(12)
    
    if tit == '':
        if len(listBui) == 1:
            tit = f'{sBui} '.replace('x','&') \
                + dfBldg.loc[dfBldg['bldg_no'] == sBui,'name'].tolist()[0] \
                + f' ({retr_tit})'
        else:
            tit = 'Combined ({} buildings)'.format(len(listBui))
    getMonthly(sBui if len(listBui) == 1 else tit)
    makePlot(tit)

###########################################################################
## Start of main process ##

#%% ======= FLAGS AND SWITCHES =======
flag_deleteOldFiles = False
retr = 'post' # retrofit status: 'base' baseline,
              #                  'post' post-ECM

mode = 'west'
    # 'spec' -  plot a specified list of buildings (can have only one)
    #           add a row to tables, if saveTables
    # 'each' -  plot all of each individual building
    #           rewrite the tables, if saveTables
    # 'west' -  plot 18 west-wing buildings combined
    #           add a row to the tables, if saveTables
saveFigures = False
saveTablesPeak = False
saveTablesTotal = False

#listBui - list of buildings, consumption is combined
#   only used with mode == 'spec'
#listBui = sBuis # 
#listBui_spec = ['1045']
listBui_spec = ['1045', '1349']
tit_spec = ''

#%%

if flag_deleteOldFiles:
    # Deletes the folder of the previous written exchange files
    #   and remake the directory'
    shutil.rmtree(dirFigu)
    os.makedirs(dirFigu, exist_ok = True)
if retr == 'base':
    retr_tit = 'Baseline'
elif retr == 'post':
    retr_tit = 'Post ECM'

t_dt = pd.date_range(start='2005-01-01',
                     end='2006-01-01',
                     freq='h')[0:8760] # time array as date
t_hoy = np.array(t_dt.tolist()) # hour of year
t_moy = np.array(t_dt.month.tolist()) # month of year, for each hour
mons = np.linspace(1,12,12,dtype = int)
t_ms = pd.date_range(start='2005-01-01',
                     end='2006-01-01',
                     freq='MS')[0:12].tolist() # list for month starts

# Dataframes for monthly peaks
dfPeaEle = pd.DataFrame(columns = ['bldg', 'Annual'] + calendar.month_name[1:13])
dfPeaSnd = pd.DataFrame(columns = ['bldg', 'Annual'] + calendar.month_name[1:13])
dfPeaCoo = pd.DataFrame(columns = ['bldg', 'Annual'] + calendar.month_name[1:13])

# Dataframes for monthly totals
dfTotEle = pd.DataFrame(columns = ['bldg', 'Annual'] + calendar.month_name[1:13])
dfTotSnd = pd.DataFrame(columns = ['bldg', 'Annual'] + calendar.month_name[1:13])
dfTotCoo = pd.DataFrame(columns = ['bldg', 'Annual'] + calendar.month_name[1:13])

if mode == 'spec':
    # Run specified list of buildings (can have only one)
    runBuildings(listBui_spec,
                 sRet = retr,
                 tit = tit_spec,
                 saveFigures = saveFigures)
    if saveTablesPeak:
        dfPeaEle.to_csv(os.path.join(dirTabl,f'Peaks_endUseElectricity_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
        dfPeaSnd.to_csv(os.path.join(dirTabl,f'Peaks_combinedHeating_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
        dfPeaCoo.to_csv(os.path.join(dirTabl,f'Peaks_cooling_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
    if saveTablesPeak:
        dfTotEle.to_csv(os.path.join(dirTabl,f'Total_endUseElectricity_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
        dfTotSnd.to_csv(os.path.join(dirTabl,f'Total_combinedHeating_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
        dfTotCoo.to_csv(os.path.join(dirTabl,f'Total_cooling_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
elif mode == 'each':
    # Run each building
    for sBui in sBuis:
        runBuildings([sBui],
                     sRet = retr,
                     saveFigures = saveFigures)
    if saveTablesPeak:
        dfPeaEle.to_csv(os.path.join(dirTabl,f'Peaks_endUseElectricity_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False)
        dfPeaSnd.to_csv(os.path.join(dirTabl,f'Peaks_combinedHeating_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False)
        dfPeaCoo.to_csv(os.path.join(dirTabl,f'Peaks_cooling_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False)
    if saveTablesPeak:
        dfTotEle.to_csv(os.path.join(dirTabl,f'Total_endUseElectricity_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False)
        dfTotSnd.to_csv(os.path.join(dirTabl,f'Total_combinedHeating_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False)
        dfTotCoo.to_csv(os.path.join(dirTabl,f'Total_cooling_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False)
elif mode == 'west':
    # Combine buildings but exclude 5300 & 5301 which are east of the runway
    listBui = [elem for elem in sBuis if elem not in {'5300', '5301'}]
    tit = f'West Combined - {retr_tit}'
    runBuildings(listBui,
                 sRet = retr,
                 tit = tit,
                 saveFigures = saveFigures)
    if saveTablesPeak:
        dfPeaEle.to_csv(os.path.join(dirTabl,f'Peaks_endUseElectricity_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
        dfPeaSnd.to_csv(os.path.join(dirTabl,f'Peaks_combinedHeating_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
        dfPeaCoo.to_csv(os.path.join(dirTabl,f'Peaks_cooling_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
    if saveTablesPeak:
        dfTotEle.to_csv(os.path.join(dirTabl,f'Total_endUseElectricity_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
        dfTotSnd.to_csv(os.path.join(dirTabl,f'Total_combinedHeating_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
        dfTotCoo.to_csv(os.path.join(dirTabl,f'Total_cooling_{retr_tit}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = 'a',
                        header = False)
