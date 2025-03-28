#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 14 15:26:43 2025

@author: casper

Generates files for extreme weather scenarios.
    A day is picked whose hourly numbers are to be pasted to a range of days.
        Two functions are implemented for epw and for mos.
"""

import glob
import os
from datetime import datetime, timedelta

y = 2025 # dummy year, has no effect

#%% Make epw weather file

def make_epw(weather_from,
             weather_to,
             date_to_copy,
             date_to_paste_from,
             date_to_paste_to):
    
    # Dictionary to store reference lines
    lines_to_copy = {}
    with open(weather_from, 'r') as file:
        for line in file:
            if line[0].isdigit(): # skip lines until a digit is found
                _, m, d, h, rest = line.split(',',4)
                if f'{m},{d}' == date_to_copy.strftime("%-m,%-d"):
                    lines_to_copy[h] = rest # hour as key
    
    # Generate list of days to be replaced as 'm,d'
    dates_to_paste = [date_to_paste_from + timedelta(days=x) for x in range((date_to_paste_to - date_to_paste_from).days + 1)]
    formatted_dates = [f"{date.month},{date.day}" for date in dates_to_paste]
    
    # Generate new file
    with open(weather_from, 'r') as infile, open(weather_to, 'w') as outfile:
        for line in infile:
            if line[0].isdigit(): # skip lines until a digit is found
                y, m, d, h, rest = line.split(',',4)
                if f'{m},{d}' in formatted_dates:
                    new_line = ','.join([y,m,d,h,lines_to_copy[h]])
                else:
                    new_line = line  # If the day is not in the specified range, keep the original line
            else:
                new_line = line  # If the line does not start with a digit, keep the original line
            outfile.write(new_line)

#%% Make mos weather or load file

def make_mos(load_from,
                  load_to,
                  date_to_copy,
                  date_to_paste_from,
                  date_to_paste_to,
                  delimiter,
                  weather_file_name = ""):
    """ Generates a new mos data file
            `delimiter` : '\t' for a weather file
                        : ',' for a load file
            `weather_file_name` will not have effect on a weather file
                because it will not have the string that is meant to be replaced.
    """
    
    def soy(dt):
        # Second of year
        start_of_year = datetime(dt.year, 1, 1)
        return int((dt - start_of_year).total_seconds())
    
    # Dictionary to store reference lines
    lines_to_copy = list()
    soy_copy_from   = soy(date_to_copy)             # inclusive
    soy_copy_before = soy(date_to_copy) + 24*3600   # exclusive
    with open(load_from, 'r') as file:
        for line in file:
            if line[0].isdigit(): # skip lines until a digit is found
                sec, rest = line.split(delimiter,1)
                #sec, rest = re.split(r'[\t,]', line, maxsplit = 1)
                iSec = int(float(sec))
                if (iSec >= soy_copy_from) and (iSec < soy_copy_before):
                    lines_to_copy.append(rest)

    # Generate new file
    soy_paste_from   = soy(date_to_paste_from)          # inclusive
    soy_paste_before = soy(date_to_paste_to) + 24*3600  # exclusive
    index = 0
    with open(load_from, 'r') as infile, open(load_to, 'w') as outfile:
        for line in infile:
            if "#Weather file name" in line:
                new_line = f'#Weather file name = "{weather_file_name}"\n'
            elif line[0].isdigit(): # skip lines until a digit is found
                sec, rest = line.split(delimiter,1)
                iSec = int(float(sec))
                if (iSec >= soy_paste_from) and (iSec < soy_paste_before):
                    new_line = delimiter.join([sec, lines_to_copy[index]])
                    index = (index + 1) % 24
                else:
                    new_line = line  # If the day is not in the specified range, keep the original line
            else:
                new_line = line  # If the line does not start with a digit, keep the original line
            outfile.write(new_line)

#%% Main process

weather_eps_from = os.path.join("/home/casper/gitRepo/thermal-grid-jba/PythonResources/Data/Weather/fTMY_Maryland_Prince_George's_NORESM2_2020_2039.epw")
weather_mos_from = os.path.join("/home/casper/gitRepo/thermal-grid-jba/PythonResources/Data/Weather/fTMY_Maryland_Prince_George's_NORESM2_2020_2039.mos")
hotday = datetime(y, 8, 2)
heat_wave_from = datetime(y, 7, 27)
heat_wave_to = datetime(y, 8, 9)
coldday = datetime(y, 3, 1)
cold_snap_from = datetime(y, 2, 23)
cold_snap_to = datetime(y, 3, 8)

#%% Make weather files

# heat wave
weather_epw_to = os.path.join('/home/casper/gitRepo/thermal-grid-jba/PythonResources/Data/Weather/USA_MD_Andrews.AFB.fTMY.HeatWave.epw')
weather_mos_to = os.path.join('/home/casper/gitRepo/thermal-grid-jba/PythonResources/Data/Weather/USA_MD_Andrews.AFB.fTMY.HeatWave.mos')
make_epw(weather_eps_from,
         weather_epw_to,
         hotday,
         heat_wave_from,
         heat_wave_to)
make_mos(weather_mos_from,
         weather_mos_to,
         hotday,
         heat_wave_from,
         heat_wave_to,
         '\t')

# cold snap
weather_epw_to = os.path.join('/home/casper/gitRepo/thermal-grid-jba/PythonResources/Data/Weather/USA_MD_Andrews.AFB.fTMY.ColdSnap.epw')
weather_mos_to = os.path.join('/home/casper/gitRepo/thermal-grid-jba/PythonResources/Data/Weather/USA_MD_Andrews.AFB.fTMY.ColdSnap.mos')
make_epw(weather_eps_from,
         weather_epw_to,
         coldday,
         cold_snap_from,
         cold_snap_to)
make_mos(weather_mos_from,
         weather_mos_to,
         coldday,
         cold_snap_from,
         cold_snap_to,
         '\t')

#%% Make load files

load_from_directory = os.path.join("/home/casper/gitRepo/thermal-grid-jba/PythonResources/Data/Consumption/Modelica/")
load_from_files = glob.glob(os.path.join(load_from_directory, "*_futu.mos"))

for infile in load_from_files:
    outfile = infile.replace("_futu", "_heat")
    make_mos(infile,
             outfile,
             hotday,
             heat_wave_from,
             heat_wave_to,
             ',',
             "USA_MD_Andrews.AFB.fTMY.HeatWave.mos")

for infile in load_from_files:
    outfile = infile.replace("_futu", "_cold")
    make_mos(infile,
             outfile,
             coldday,
             cold_snap_from,
             cold_snap_to,
             ',',
             "USA_MD_Andrews.AFB.fTMY.ColdSnap.mos")