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

_y = 2025 # dummy year, has no effect
CWD = os.getcwd()

weather_eps_from = os.path.realpath(os.path.join(CWD,"../Weather/fTMY_Maryland_Prince_George's_NORESM2_2020_2039.epw"))
weather_mos_from = os.path.realpath(os.path.join(CWD,"../Weather/fTMY_Maryland_Prince_George's_NORESM2_2020_2039.mos"))

hotday = datetime(_y, 8, 2)
coldday = datetime(_y, 3, 1)

heat_wave_from = datetime(_y, 7, 27)
heat_wave_to = datetime(_y, 8, 9)

cold_snap_from = datetime(_y, 2, 23)
cold_snap_to = datetime(_y, 3, 8)

#%% function definitions

def soy(dt):
    # Second of year
    start_of_year = datetime(dt.year, 1, 1)
    return int((dt - start_of_year).total_seconds())

def make_epw(weather_from,
             weather_to,
             date_to_copy,
             date_to_paste_from,
             date_to_paste_to):
    """ Generates a new epw data file
    """
    
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

def make_mos_weather(load_from,
                     load_to,
                     date_to_copy,
                     date_to_paste_from,
                     date_to_paste_to,
                     delimiter,
                     weather_file_name = ""):
    """ Generates a new mos data file
        `delimiter` : '\t' for a weather file
                    : ',' for a load file
        `weather_file_name` marks the weather file that corresponds to
            the load mos file and will be read in Modelica.
            It has no effect when generating a weather mos file.
    """
    
    lines_to_copy = list() # stores reference lines
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

def make_mos_critial(load_from,
                     load_to,
                     dates,
                     delimiter = ','):
    """ Generates a new mos load file.
        `dates` : A list of datetime dates.
                  All load values are halved for 7 days starting from
                      each date in the list.
    """
    
    def get_seconds(idx):
        
        sec_from = int(soy(dates[idx]))     # inclusive
        sec_to = int(sec_from + 7 * 24 * 3600)  # exclusive
        
        return sec_from, sec_to
    
    dates.sort()
    idx = 0
    sec_from, sec_to = get_seconds(idx)
    with open(load_from, 'r') as infile, open(load_to, 'w') as outfile:
        for line in infile:
            if line[0].isdigit(): # skip lines until a digit is found
                sec, rest = line.split(delimiter,1)
                iSec = int(float(sec))
                if iSec >= sec_from and iSec < sec_to:
                    fields = line.split(delimiter)
                    new_fields = [fields[0]] # keep the first column
                    for field in fields[1:]: # multiply all other columns with 50%
                        new_fields.append(str(float(field) * 0.5))
                    new_line = delimiter.join(new_fields) + '\n'
                else:
                    new_line = line
                if iSec == sec_to:
                    idx += 1
                    if idx < len(dates):
                        sec_from, sec_to = get_seconds(idx)
            else:
                new_line = line
            outfile.write(new_line)

#%% Make weather files

# heat wave
weather_epw_to = os.path.realpath(os.path.join(CWD,"../Weather/USA_MD_Andrews.AFB.fTMY.HeatWave.epw"))
weather_mos_to = os.path.realpath(os.path.join(CWD,"../Weather/USA_MD_Andrews.AFB.fTMY.HeatWave.mos"))
make_epw(weather_eps_from,
         weather_epw_to,
         hotday,
         heat_wave_from,
         heat_wave_to)
make_mos_weather(weather_mos_from,
                 weather_mos_to,
                 hotday,
                 heat_wave_from,
                 heat_wave_to,
                 '\t')

# cold snap
weather_epw_to = os.path.realpath(os.path.join(CWD,"../Weather/USA_MD_Andrews.AFB.fTMY.ColdSnap.epw"))
weather_mos_to = os.path.realpath(os.path.join(CWD,"../Weather/USA_MD_Andrews.AFB.fTMY.ColdSnap.mos"))
make_epw(weather_eps_from,
         weather_epw_to,
         coldday,
         cold_snap_from,
         cold_snap_to)
make_mos_weather(weather_mos_from,
                 weather_mos_to,
                 coldday,
                 cold_snap_from,
                 cold_snap_to,
                 '\t')

#%% Make load files for extreme weather scenarios

load_from_directory = os.path.realpath(os.path.join(CWD,"Modelica/"))
load_from_files = glob.glob(os.path.join(load_from_directory, "*_futu.mos"))

for infile in load_from_files:
    outfile = infile.replace("_futu", "_heat")
    make_mos_weather(infile,
                     outfile,
                     hotday,
                     heat_wave_from,
                     heat_wave_to,
                     ',',
                     "USA_MD_Andrews.AFB.fTMY.HeatWave.mos")

for infile in load_from_files:
    outfile = infile.replace("_futu", "_cold")
    make_mos_weather(infile,
                     outfile,
                     coldday,
                     cold_snap_from,
                     cold_snap_to,
                     ',',
                     "USA_MD_Andrews.AFB.fTMY.ColdSnap.mos")
    
#%% Make load files for critical load scenario

load_from_directory = os.path.realpath(os.path.join(CWD,"Modelica/"))
load_from_files = glob.glob(os.path.join(load_from_directory, "*_futu.mos"))

for infile in load_from_files:
    outfile = infile.replace("_futu", "_crit")
    make_mos_critial(infile,
                     outfile,
                     [coldday, hotday])
    
