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
import datetime
import shutil

import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import matplotlib.ticker as tic
import numpy as np
import xarray as xr

from _config_estcp import * # This imports os and pandas as pd

def constructDataset(buils: list):
    # Constructs the xarray dataset for monthly values
    # NOTE: DO NOT pass a np object to xr.Dataset to assign initial values!
    #         It will pass the object pointer (?) not the values.
    #         As a result, modifying monthly.peak will also modify monthly.total,
    #         because it is the underlying object that is being modified.
    monthly = xr.Dataset(
               {
                   'peak':  (['stag', 'util', 'buil', 'mon'],
                             np.zeros((len(stags),len(utils),len(buils),len(mons)),dtype=float)),
                   'total': (['stag', 'util', 'buil', 'mon'],
                             np.zeros((len(stags),len(utils),len(buils),len(mons)),dtype=float))
               },
               coords = 
               {
                   'stag': stags,
                   'util': utils,
                   'buil': buils,
                   'mon' : mons
               })
    
    return monthly

def runBuildings(listBui,
                 figtitle : str,
                 filename : str,
                 builcoord : str,
                 saveFigures = True,
                 titleOnFigure = False):
        
    def makePlot(figtitle : str,
                 filename : str,
                 hasDhw : bool,
                 titleOnFigure = True):
        
        def setPrimaryY(ax,label):
            """
            Set primary y-axis with SI units
            """
            ax.set_ylabel(label)
            ax.get_yaxis().set_major_formatter(
                tic.FuncFormatter(lambda x, p: format(int(x), ',')))
            ax.yaxis.set_major_locator(plt.MaxNLocator(5))
        
        def setSecondY(ax,label):
            """
            Set secondary y-axis with IP units
            """
            fac = 3.41214
            axr = ax.twinx()
            ymin, ymax = ax.get_ylim()
            axr.set_ylim(ymin*fac,ymax*fac)
            axr.set_ylabel(label)
            axr.get_yaxis().set_major_formatter(
                tic.FuncFormatter(lambda x, p: format(int(x), ',')))
            axr.yaxis.set_major_locator(plt.MaxNLocator(5))
        
        linewidth = 0.8
        # three subplots for two different stages
        fig, ((ax11,ax12),
              (ax21,ax22),
              (ax31,ax32)) = plt.subplots(3,2,
                                          sharex=True,
                                          sharey='row',
                                          figsize=(9,5))
        
        for stag in stags:
            ele = hourly.sel(stag=stag,util='ele')
            coo = hourly.sel(stag=stag,util='coo')
            hea = hourly.sel(stag=stag,util='hea')
            dhw = hourly.sel(stag=stag,util='dhw')
            net = hea + dhw - coo
            
            cooPea = monthly.peak.sel(stag=stag,util='coo',buil=builcoord)
            heaPea = monthly.peak.sel(stag=stag,util='hea',buil=builcoord)
            if hasDhw:
                dhwPea = monthly.peak.sel(stag=stag,util='dhw',buil=builcoord)
            
            if stag == stags[0]:
                ax1 = ax11
                ax2 = ax21
                ax3 = ax31
            elif stag == stags[1]:
                ax1 = ax12
                ax2 = ax22
                ax3 = ax32
            
            if stag == stags[0]:
                ax1.set_title('Baseline',
                              loc = 'right',
                              fontsize = 12)
            elif stag == stags[1]:
                ax1.set_title('Post-ECM',
                              loc = 'left',
                              fontsize = 12)
            h1, = ax1.plot(t_hoy, hea,
                          'r', linewidth = linewidth)
            h1, = ax1.plot(t_hoy, - coo,
                          'b', linewidth = linewidth)
            if hasDhw:
                h1, = ax1.plot(t_hoy, dhw,
                              'm', linewidth = linewidth)
            if stag == stags[0]:
                setPrimaryY(ax1,'Hourly Use\n(kWh/h)')
            if stag == stags[1]:
                setSecondY(ax1,'(kBtu/hr)')
            ax1.grid()
              
            if hasDhw:
                _t_ms_shift = [t + datetime.timedelta(days=-5) for t in t_ms]
            else:
                _t_ms_shift = t_ms
            h1 = ax2.bar(_t_ms_shift, heaPea,
                        color = 'r',
                        width = 10)
            _t_ms_shift = [t + datetime.timedelta(days=5) for t in _t_ms_shift]
            h1 = ax2.bar(t_ms, - cooPea,
                        color = 'b',
                        width = 10)
            if hasDhw:
                _t_ms_shift = [t + datetime.timedelta(days=5) for t in t_ms]
                h1 = ax2.bar(_t_ms_shift, dhwPea,
                            color = 'm',
                            width = 10)
            plt.axhline(0, color = 'k', linewidth = linewidth/2)
            if stag == stags[0]:
                setPrimaryY(ax2,'Monthly Peak\n(kW)')
            elif stag == stags[1]:
                setSecondY(ax2,'(kBtu/hr)')
            ax2.grid()
            
            h1, = ax3.plot(t_hoy, np.cumsum(hea)/1000,
                          'r', linewidth = linewidth,
                          label = 'heating' if stag==stags[0] else '')
            h1, = ax3.plot(t_hoy, - np.cumsum(coo)/1000,
                          'b', linewidth = linewidth,
                          label = 'cooling'  if stag==stags[0] else '')
            if hasDhw:
                h1, = ax3.plot(t_hoy, np.cumsum(dhw)/1000,
                              'm', linewidth = linewidth,
                              label = 'dom. hot water' if stag==stags[0] else '')
            h1, = ax3.plot(t_hoy, np.cumsum(net)/1000,
                          'k', linewidth = linewidth * 2,
                          label = 'net energy' if stag==stags[0] else '')
            if stag == stags[0]:
                setPrimaryY(ax3,'Cumulative Use\n(thousand kWh)')
            elif stag == stags[1]:
                setSecondY(ax3,'(MMBtu)')
            
            # Format the x-axis
            ax3.xaxis.set_major_locator(mdates.MonthLocator())
            ax3.xaxis.set_major_formatter(mdates.DateFormatter('%b'))
            plt.draw() # This forces xticklabels to populate
            xlabels = [item.get_text() for item in ax3.get_xticklabels()]
            for i in range(0,len(xlabels)):
                if i % 2 == 0:
                    xlabels[i] = xlabels[i] + '-1'
                else:
                    xlabels[i] = ''
            ax3.set_xticks(ax3.get_xticks())
            ax3.set_xticklabels(xlabels)
            ax3.tick_params(axis='x', labelrotation=60)
            ax3.grid()
        
        fig.legend(loc = 'upper center',
                   bbox_to_anchor = (0.5, 0.02, 0., 0.),
                   fancybox = True,
                   shadow = True,
                   ncol = 4)
        
        if titleOnFigure:
            plt.suptitle(figtitle,
                         x = 0.05,
                         y = 0.96,
                         horizontalalignment = 'left',
                         fontsize = 14)
        fig.tight_layout()
        
        if saveFigures:
            plt.savefig(os.path.join(dirFigu,filename),
                        bbox_inches = 'tight')
            plt.close()
            
    ## ===== Start of main of sub-routine =====
    
    # consumption sum of buildings selected
    hourly = xr.DataArray(
               0.0,
               coords = [
                   ('stag', stags),
                   ('util', utils),
                   ('time', t_dt)],
               attrs = {
                   'hasDhw': False
                   })
    
    # Read MIDs and sum them up
    for stag, buil_no in [(stag, buil_no) for stag in stags for buil_no in listBui]:        
        _hasDhw = os.path.isfile(os.path.join(dirExch, f'{stag}_{buil_no}_dhw.csv'))
        for util in utils:
            if util == 'dhw' and not _hasDhw:
                continue
            elif util == 'dhw' and _hasDhw:
                hourly.attrs['hasDhw'] = True
            hourly.loc[dict(stag=stag,util=util)] \
                = hourly.sel(stag=stag,util=util) \
                + np.array(readMID(f'{stag}_{buil_no}_{util}'))
    
    for stag, util, mon in [(stag, util, mon) for stag in stags for util in utils for mon in mons]:
        monthly.peak.loc[dict(stag=stag,util=util,buil=builcoord,mon=mon)] \
            = hourly.sel(stag=stag,util=util,time=(hourly.time.dt.month==mon)).max().item()
        monthly.total.loc[dict(stag=stag,util=util,buil=builcoord,mon=mon)] \
            = hourly.sel(stag=stag,util=util,time=(hourly.time.dt.month==mon)).sum().item()
    
    makePlot(figtitle = figtitle,
             filename = filename,
             hasDhw = hourly.attrs['hasDhw'],
             titleOnFigure = titleOnFigure)
    global hasDhw
    if hourly.attrs['hasDhw']:
        hasDhw = True

###########################################################################
## Start of main process ##

#%% ======= FLAGS AND SWITCHES =======
flag_deleteOldFigures = False     # Deletes the folder of figures
                                  #   and remake the directory

mode = 'west'
    # 'spec' -  specify one building or a list of buildings to be combined,
    #           add a row to tables, if saveTables;
    # 'each' -  each individual building processed separately,
    #           rewrite the tables, if saveTables;
    # 'west' -  buildings on the west wing combined,
    #           add a row to the tables, if saveTables;
saveFigures = False
saveTables = False

titleOnFigure = True # Set false if figures used for Latex

#listBui - list of buildings, consumption is combined
#   only used with mode == 'spec'
#listBui = buil_nos # 
#listBui_spec = ['1045']
listBui_spec = ['1045', '1349']
figtitle_spec = 'spec' # Title of the figure (on figure or in caption)
filename_spec = 'spec' # Name of the figure file

#%% Configure based on flags & switches

if flag_deleteOldFigures:
    shutil.rmtree(dirFigu)
    os.makedirs(dirFigu, exist_ok = True)
hasDhw = False # global dhw flag

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
                + dfBldg.loc[dfBldg['buil_no'] == buil_no,'name'].tolist()[0]
        filename = f'{buil_no}.pdf'
        builcoord = buil_no
        runBuildings([buil_no],
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
    figtitle = f'West Combined'
    filename = f'west.pdf'
    builcoord = 'west'
    monthly=constructDataset([builcoord])
    runBuildings(listBui,
                 figtitle = figtitle,
                 filename = filename,
                 builcoord = builcoord,
                 saveFigures = saveFigures,
                 titleOnFigure = titleOnFigure)
    saveTablesMode = 'a'
    saveTablesHeader = False

#%% Save tables

if saveTables:
    
    for stag, util in [(stag, util) for stag in stags for util in utils]:
        if util == 'dhw' and not hasDhw:
            continue
        dfPea = pd.DataFrame(columns = ['building', 'Annual'] + calendar.month_name[1:13])
        dfTot = pd.DataFrame(columns = ['building', 'Annual'] + calendar.month_name[1:13])
        for rowname in monthly.coords['buil'].values:
            _row_mon = monthly.peak.sel(stag=stag,util=util,buil=rowname).values.tolist()
            dfPea.loc[len(dfPea.index) + 1] = [rowname, np.max(_row_mon)] + _row_mon
            _row_mon = monthly.total.sel(stag=stag,util=util,buil=rowname).values.tolist()
            dfTot.loc[len(dfTot.index) + 1] = [rowname, np.sum(_row_mon)] + _row_mon
        dfPea.to_csv(os.path.join(dirTabl,f'Peak_{util}_{stag}.csv'),
                    sep = delimiter,
                    index = False,
                    mode = saveTablesMode,
                    header = saveTablesHeader)
        dfTot.to_csv(os.path.join(dirTabl,f'Total_{util}_{stag}.csv'),
                        sep = delimiter,
                        index = False,
                        mode = saveTablesMode,
                        header = saveTablesHeader)
