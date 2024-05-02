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
#import pandas as pd
import xarray as xr

from _config_estcp import *

def runBuildings(listBui,                 
                 retr : str,
                 figtitle : str,
                 filename : str,
                 saveFigures = True,
                 titleOnFigure = False):

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
        
    def makePlot(figtitle : str,
                 filename : str,
                 titleOnFigure = True):
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
        
        if titleOnFigure:
            plt.suptitle(figtitle,
                         x = 0.05,
                         y = 0.96,
                         horizontalalignment = 'left',
                         fontsize = 14)
        fig.tight_layout()
        
        if saveFigures:
            plt.savefig(os.path.join(dirFigu,filename))
            plt.close()
            
    ## ===== Start of sub-main process =====
    
    # consumption sum of buildings selected
    hourly = xr.DataArray(
               0.0,
               coords = [
                   ('retr', ['base', 'post']),
                   ('util', utils),
                   ('dttm', t_dt)],
               attrs = {
                   'hasDhw': False
                   })
    monthly = xr.DataArray(
               0.0,
               coords = [
                   ('retr', ['base', 'post']),
                   ('util', utils),
                   ('mon' , mons)],
               attrs = {
                   'hasDhw': False
                   })
    
    # Read MIDs and sum them up
    for bldg_no in listBui:        
        hasDhw = os.path.isfile(os.path.join(dirExch, f'{retr}_{bldg_no}_dhw.csv'))
        for util in utils:
            if util == 'dhw' and not hasDhw:
                continue
            elif util == 'dhw' and hasDhw:
                hourly.attrs['hasDhw'] = True
            hourly.sel(retr=retr,util=util).values += np.array(readMID(f'{retr}_{bldg_no}_{util}'))
    
    ele = hourly.sel(retr=retr,util='ele')
    coo = hourly.sel(retr=retr,util='coo')
    hea = hourly.sel(retr=retr,util='hea')
    dhw = hourly.sel(retr=retr,util='dhw')
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
    
    getMonthly(bldg_no if len(listBui) == 1 else figtitle)
    makePlot(figtitle = figtitle,
             filename = filename,
             titleOnFigure = titleOnFigure)

###########################################################################
## Start of main process ##

#%% ======= FLAGS AND SWITCHES =======
flag_deleteOldFigures = False     # Deletes the folder of figures
                                  #   and remake the directory
retr = 'post' # retrofit status: 'base' baseline,
              #                  'post' post-ECM

mode = 'west'
    # 'spec' -  specify one building or a list of buildings to be combined,
    #           add a row to tables, if saveTables;
    # 'each' -  each individual building processed separately,
    #           rewrite the tables, if saveTables;
    # 'west' -  buildings on the west wing combined,
    #           add a row to the tables, if saveTables;
saveFigures = False
saveTablesPeak = False
saveTablesTotal = False

titleOnFigure = True # Set false if figures used for Latex

#listBui - list of buildings, consumption is combined
#   only used with mode == 'spec'
#listBui = bldg_nos # 
#listBui_spec = ['1045']
listBui_spec = ['1045', '1349']
figtitle_spec = 'spec' # Title of the figure (on figure or in caption)
filename_spec = 'spec' # Title of the figure file

#%% Configure based on flags & switches

if flag_deleteOldFigures:
    shutil.rmtree(dirFigu)
    os.makedirs(dirFigu, exist_ok = True)
if retr == 'base':
    retr_tit = 'Baseline'
elif retr == 'post':
    retr_tit = 'Post ECM'

#%% Construct
t_dt = pd.date_range(start='2005-01-01',
                     end='2006-01-01',
                     freq='h')[0:8760] # time array as date
t_hoy = np.array(t_dt.tolist()) # hour of year, 1 to 8760
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

#%% Run buildings

if mode == 'spec':
    # Run specified list of buildings (can have only one)
    
    runBuildings(listBui_spec,
                 retr = retr,
                 figtitle = figtitle_spec,
                 filename = filename_spec,
                 saveFigures = saveFigures,
                 titleOnFigure = titleOnFigure)
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
    for bldg_no in bldg_nos:
        figtitle = f'{bldg_no} '.replace('x','&') \
                + dfBldg.loc[dfBldg['bldg_no'] == bldg_no,'name'].tolist()[0] \
                + f' - {retr_tit}'
        filename = f'{retr}_{bldg_no}.pdf'
        runBuildings([bldg_no],
                     retr = retr,
                     figtitle = figtitle,
                     filename = filename,
                     saveFigures = saveFigures,
                     titleOnFigure = titleOnFigure)
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
    listBui = [elem for elem in bldg_nos if elem not in {'5300', '5301'}]
    figtitle = f'West Combined - {retr_tit}'
    filename = f'{retr}_west.pdf'
    runBuildings(listBui,
                 retr = retr,
                 figtitle = figtitle,
                 filename = filename,
                 saveFigures = saveFigures,
                 titleOnFigure = titleOnFigure)
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
