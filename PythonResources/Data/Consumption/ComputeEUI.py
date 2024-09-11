#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Computes energy consumption, intensity, and demands,
    and prints out tables.
Todo: generate latex tables.

Created on Fri Sep  6 14:57:24 2024

@author: casper
"""

from _config_estcp import * # This imports os and pandas as pd

import numpy as np
import xarray as xr

def stitch_cons(ip, si):
    row = np.array([ip[0], ip[1], si[1], ip[2], si[2], ip[3], si[3]])
    return row

def stitch_inte(ip, si):
    row = np.array([ip[0], si[0], ip[1], si[1], ip[2], si[2], ip[3], si[3]])
    return row

def print_table(tab):
    print('base: ' + ', '.join(['{:.1f}'.format(x) for x in tab['base']]))
    print('post: ' + ', '.join(['{:.1f}'.format(x) for x in tab['post']]))
    print('diff: ' + ', '.join(['{:+.1%}'.format(x) for x in tab['diff']]))

# areaTotM2 = 143213  # total floor area in m2
# areaTotSF = 1541515 # total floor area in sq. ft.

buils_all = buil_nos + ['all'] # building list plus 'all'

dfArea = pd.concat([
    dfBldg[['buil_no','sqft_gross','m2_gross']],
    pd.DataFrame(
    {'buil_no' : ['all'],
     'sqft_gross' : [sum(dfBldg['sqft_gross'].tolist())],
     'm2_gross' : [sum(dfBldg['m2_gross'].tolist())]
     })],
    ignore_index = True)

#%% Consumption tables

# Annual consumption
# unit coords:
#   kWh : kWh for all utilities
#   SI_u : "use", MWh for ele, GJ for others
#   IP_u : "use", MWh for ele, MMBtu for others
#   SI_i : "intensity", kWh/m2(/yr) regardless of utility type
#   IP_i : "intensity", kBtu/sf(/yr) regardless of utility type
consumption = xr.DataArray(
           0.0,
           coords = [
               ('stag', stags),
               ('util', utils),
               ('buil', buils_all),
               ('unit', ['kWh', 'SI_u', 'IP_u', 'SI_i', 'IP_i'])])

for stag, util in [(stag, util) for stag in stags for util in utils]:
    _df = pd.read_csv(os.path.join(dirTabl, f'Total_{util}_{stag}.csv'),
                      header = 0)
    _cons_list = np.array(_df.loc[_df['building'].isin(buils_all),'Annual'].tolist())
    # write annual consumption with kWh unit for all
    consumption.loc[dict(stag=stag,util=util,unit='kWh')] = _cons_list
    # convert units for other coords
    if util == 'ele':
        consumption.loc[dict(stag=stag,util=util,unit='SI_u')] = _cons_list/1000
        consumption.loc[dict(stag=stag,util=util,unit='IP_u')] = _cons_list/1000
    else:
        consumption.loc[dict(stag=stag,util=util,unit='SI_u')] = _cons_list*0.0036
        consumption.loc[dict(stag=stag,util=util,unit='IP_u')] = _cons_list*0.00341214
    consumption.loc[dict(stag=stag,util=util,unit='SI_i')] = \
        np.divide(_cons_list,np.array(dfArea['m2_gross'].tolist()))
    consumption.loc[dict(stag=stag,util=util,unit='IP_i')] = \
        np.divide(_cons_list*3.41214,np.array(dfArea['sqft_gross'].tolist()))
    
# Write output tables
    
print('== ANNUAL ENERGY CONSUMPTION ==')

print('== ele (MWh), coo (MMBtu), (GJ), hea (MMBtu), (GJ), dhw (MMBtu), (GJ) ==')
_row = {}
for stag in stags:    
    _row_ip = consumption.loc[dict(stag=stag,buil='all',unit='IP_u')].to_numpy()
    _row_si = consumption.loc[dict(stag=stag,buil='all',unit='SI_u')].to_numpy()
    _row[stag] = stitch_cons(_row_ip,_row_si)
_row['diff'] = np.divide(_row['post'],_row['base'])-1
print_table(_row)

print('== ANNUAL ENERGY USE INTENCITY ==')

print('== ele (kBtu/sf), (kWh/m2), coo (kBtu/sf), (kWh/m2), hea (kBtu/sf), (kWh/m2), dhw (kBtu/sf), (kWh/m2) ==')
_row = {}
for stag in stags:    
    _row_ip = consumption.loc[dict(stag=stag,buil='all',unit='IP_i')].to_numpy()
    _row_si = consumption.loc[dict(stag=stag,buil='all',unit='SI_i')].to_numpy()
    _row[stag] = stitch_inte(_row_ip,_row_si)
_row['diff'] = np.divide(_row['post'],_row['base'])-1
print_table(_row)

#%% Demand tables

# Annual Demand
# unit coords:
#   SI_d : "demand", kW for all utilities
#   IP_d : "demand", kW for ele, kBtu/hr for others
#   SI_i : "intensity", kW/m2 regardless of utility type
#   IP_i : "intensity", kBtu/hr/sf regardless of utility type
demand = xr.DataArray(
           0.0,
           coords = [
               ('stag', stags),
               ('util', utils),
               ('buil', buils_all),
               ('unit', ['SI_d', 'IP_d', 'SI_i', 'IP_i'])])

for stag, util in [(stag, util) for stag in stags for util in utils]:
    _df = pd.read_csv(os.path.join(dirTabl, f'Peak_{util}_{stag}.csv'),
                      header = 0)
    _cons_list = np.array(_df.loc[_df['building'].isin(buils_all),'Annual'].tolist())
    demand.loc[dict(stag=stag,util=util,unit='SI_d')] = _cons_list
    demand.loc[dict(stag=stag,util=util,unit='SI_i')] = \
        np.divide(_cons_list*1000,np.array(dfArea['m2_gross'].tolist()))
    demand.loc[dict(stag=stag,util=util,unit='IP_i')] = \
        np.divide(_cons_list*3412.142,np.array(dfArea['sqft_gross'].tolist()))
    if util == 'ele':
        demand.loc[dict(stag=stag,util=util,unit='IP_d')] = _cons_list
    else:
        demand.loc[dict(stag=stag,util=util,unit='IP_d')] = _cons_list*3.412142

print('== ANNUAL ENERGY DEMAND ==')

print('== ele (kW), coo (kBtu/hr), (kW), hea (kBtu/hr), (kW), dhw (kBtu/hr), (kW) ==')
_row = {}
for stag in stags:
    _row_ip = demand.loc[dict(stag=stag,buil='all',unit='IP_d')].to_numpy()
    _row_si = demand.loc[dict(stag=stag,buil='all',unit='SI_d')].to_numpy()
    _row[stag] = stitch_cons(_row_ip,_row_si)
_row['diff'] = np.divide(_row['post'],_row['base'])-1
print_table(_row)

print('== ANNUAL DEMAND INTENSITY ==')

print('== ele (Btu/hr/sf), (W/m2), coo (Btu/hr/sf), (W/m2), hea (Btu/hr/sf), (W/m2), dhw (Btu/hr/sf), (W/m2) ==')
_row = {}
for stag in stags:
    _row_ip = demand.loc[dict(stag=stag,buil='all',unit='IP_i')].to_numpy()
    _row_si = demand.loc[dict(stag=stag,buil='all',unit='SI_i')].to_numpy()
    _row[stag] = stitch_inte(_row_ip,_row_si)
_row['diff'] = np.divide(_row['post'],_row['base'])-1
print_table(_row)
