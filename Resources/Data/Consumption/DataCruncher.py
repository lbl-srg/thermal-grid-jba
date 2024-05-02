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

def constructDataset(buil: list):
    # Constructs the xarray dataset for monthly values
    # NOTE: DO NOT pass a np object to xr.Dataset to assign initial values!
    #         It will pass the object pointer (?) not the values.
    #         As a result, modifying monthly.peak will also modify monthly.total,
    #         because it is the underlying object that is being modified.
    monthly = xr.Dataset(
               {
                   'peak':  (['retr', 'util', 'buil', 'mon'],
                             np.zeros((2,len(utils),len(buil),len(mons)),dtype=float)),
                   'total': (['retr', 'util', 'buil', 'mon'],
                             np.zeros((2,len(utils),len(buil),len(mons)),dtype=float))
               },
               coords = 
               {
                   'retr': ['base', 'post'],
                   'util': utils,
                   'buil': buil,
                   'mon' : mons
               })
    
    return monthly

def runBuildings(listBui,                 
                 retr : str,
                 figtitle : str,
                 filename : str,
                 builcoord : str,
                 saveFigures = True,
                 titleOnFigure = False):

    def setXAxisMonths():
        # Set x-axis to display months.
        #   The texts only show in the lowest subplot.
        #   All other subplots only show the tick marks but not the texts.
        X = plt.gca().xaxis
        X.set_major_locator(mdates.MonthLocator())
        X.set_major_formatter(mdates.DateFormatter('%b'))
        
    def makePlot(figtitle : str,
                 filename : str,
                 hasDhw : bool,
                 titleOnFigure = True):
            
        ele = hourly.sel(retr=retr,util='ele')
        coo = hourly.sel(retr=retr,util='coo')
        hea = hourly.sel(retr=retr,util='hea')
        dhw = hourly.sel(retr=retr,util='dhw')
        net = hea + dhw - coo
        
        cooPea = monthly.peak.sel(retr=retr,util='coo',buil=builcoord)
        heaPea = monthly.peak.sel(retr=retr,util='hea',buil=builcoord)
        
        linewidth = 0.8
        
        fig = plt.figure()
        plt.rcParams['figure.figsize'] = [6, 6]
    
        ax = fig.add_subplot(311)
        ax.set_title('Hourly Consumption (kWh/h)',
                     loc = 'left',
                     fontsize = 12)
        h1, = ax.plot(t_hoy, hea,
                      'r', linewidth = linewidth)
        h1, = ax.plot(t_hoy, - coo,
                      'b', linewidth = linewidth)
        if hasDhw:
            h1, = ax.plot(t_hoy, dhw,
                          'm', linewidth = linewidth)
        setXAxisMonths()
        ax.xaxis.set_major_formatter(plt.NullFormatter())
        plt.grid()
        
        ax = fig.add_subplot(312)
        ax.set_title('Monthly Peak (kW)',
                     loc = 'left',
                     fontsize = 12)
        h1 = ax.bar(t_ms, heaPea,
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
        h1, = ax.plot(t_hoy, np.cumsum(hea)/1000,
                      'r', linewidth = linewidth, label = 'heating')
        h1, = ax.plot(t_hoy, - np.cumsum(coo)/1000,
                      'b', linewidth = linewidth, label = 'cooling')
        if hasDhw:
            h1, = ax.plot(t_hoy, np.cumsum(dhw)/1000,
                          'm', linewidth = linewidth, label = 'dom. hot water')
        h1, = ax.plot(t_hoy, np.cumsum(net)/1000,
                      'k', linewidth = linewidth, label = 'net energy')
        plt.axhline(0, color = 'k', linewidth = linewidth/2)
        setXAxisMonths()
        xlabels = [item.get_text() for item in ax.get_xticklabels()]
        xlabels[-1] = ''
        ax.set_xticks(ax.get_xticks())
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
            
    ## ===== Start of main of sub-routine =====
    
    # consumption sum of buildings selected
    hourly = xr.DataArray(
               0.0,
               coords = [
                   ('retr', ['base', 'post']),
                   ('util', utils),
                   ('time', t_dt)],
               attrs = {
                   'hasDhw': False
                   })
    
    # Read MIDs and sum them up
    for buil_no in listBui:        
        hasDhw = os.path.isfile(os.path.join(dirExch, f'{retr}_{buil_no}_dhw.csv'))
        for util in utils:
            if util == 'dhw' and not hasDhw:
                continue
            elif util == 'dhw' and hasDhw:
                hourly.attrs['hasDhw'] = True
            hourly.loc[dict(retr=retr,util=util)] \
                = hourly.sel(retr=retr,util=util) \
                + np.array(readMID(f'{retr}_{buil_no}_{util}'))
    
    for util, mon in [(util, mon) for util in utils for mon in mons]:
        monthly.peak.loc[dict(retr=retr,util=util,buil=builcoord,mon=mon)] \
            = hourly.sel(retr=retr,util=util,time=(hourly.time.dt.month==mon)).max().item()
        monthly.total.loc[dict(retr=retr,util=util,buil=builcoord,mon=mon)] \
            = hourly.sel(retr=retr,util=util,time=(hourly.time.dt.month==mon)).sum().item()
    
    makePlot(figtitle = figtitle,
             filename = filename,
             hasDhw = hourly.attrs['hasDhw'],
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
saveTables = True

titleOnFigure = True # Set false if figures used for Latex

#listBui - list of buildings, consumption is combined
#   only used with mode == 'spec'
#listBui = buil_nos # 
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

#%% Run buildings

if mode == 'spec':
    # Run specified list of buildings (can have only one)
    builcoord = filename_spec
    monthly=constructDataset([builcoord])
    runBuildings(listBui_spec,
                 retr = retr,
                 figtitle = figtitle_spec,
                 filename = filename_spec,
                 builcoord = builcoord,
                 saveFigures = saveFigures,
                 titleOnFigure = titleOnFigure)
    saveTablesMode = 'a'
    saveTablesHeader = False
elif mode == 'each':
    # Run each building
    monthly=constructDataset(buil_nos)
    for buil_no in buil_nos:
        figtitle = f'{buil_no} '.replace('x','&') \
                + dfBldg.loc[dfBldg['buil_no'] == buil_no,'name'].tolist()[0] \
                + f' - {retr_tit}'
        filename = f'{retr}_{buil_no}.pdf'
        builcoord = buil_no
        runBuildings([buil_no],
                     retr = retr,
                     figtitle = figtitle,
                     filename = filename,
                     builcoord = builcoord,
                     saveFigures = saveFigures,
                     titleOnFigure = titleOnFigure)
    saveTablesMode = 'w'
    saveTablesHeader = True
elif mode == 'west':
    # Combine buildings but exclude 5300 & 5301 which are east of the runway
    listBui = [elem for elem in buil_nos if elem not in {'5300', '5301'}]
    figtitle = f'West Combined - {retr_tit}'
    filename = f'{retr}_west.pdf'
    builcoord = 'west'
    monthly=constructDataset([builcoord])
    runBuildings(listBui,
                 retr = retr,
                 figtitle = figtitle,
                 filename = filename,
                 builcoord = builcoord,
                 saveFigures = saveFigures,
                 titleOnFigure = titleOnFigure)
    saveTablesMode = 'a'
    saveTablesHeader = False

#%% Save tables

if saveTables:
    
    for util in utils:
        dfPea = pd.DataFrame(columns = ['building', 'Annual'] + calendar.month_name[1:13])
        dfTot = pd.DataFrame(columns = ['building', 'Annual'] + calendar.month_name[1:13])
        for rowname in monthly.coords['buil'].values:
            _row_mon = monthly.peak.sel(retr=retr,util=util,buil=rowname).values.tolist()
            dfPea.loc[len(dfPea.index) + 1] = [rowname, np.max(_row_mon)] + _row_mon
            _row_mon = monthly.total.sel(retr=retr,util=util,buil=rowname).values.tolist()
            dfTot.loc[len(dfTot.index) + 1] = [rowname, np.sum(_row_mon)] + _row_mon
        dfPea.to_csv(os.path.join(dirTabl,f'Peak_{util}_{retr}.csv'),
                    sep = delimiter,
                    index = False,
                    mode = saveTablesMode,
                    header = saveTablesHeader)
        dfTot.to_csv(os.path.join(dirTabl,f'Total_{util}_{retr}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = saveTablesMode,
                        header = saveTablesHeader)
