# Python script providing public variables
#   for dependent scripts.

import os

import pandas as pd

#%% shared attributes
stags = ['base', 'post']
    # stages:
    #   baseline, post-ECM
utils = ['ele', 'coo', 'hea', 'dhw']
    # utility types:
    #   electricity, cooling, heating, domestic hot water
delimiter = ','

#%% exchange csv files
dirExch = 'exchange'

#%% eQuest csv files
dirRead = 'eQuest'
dfBldg = pd.read_csv('buildings.csv',
                     header = 0,
                     thousands = ',',
                     dtype = {'buil_no' : str,
                              'name' : str,
                              'gross_area_sf' : float,
                              'gross_area_m2' : float,
                              'remark1' : str})
buil_nos = dfBldg['buil_no'].tolist()
util_cols = [16, 30, 31, 32]
    # column numbers of the respective utilities
    #   from the input file (base 0)

#%% Directories
dirWritSymp = 'Sympheny' # Sympheny input xlsx files
dirFigu = 'Figures'
dirTabl = 'Tables'
dirTex = 'Latex'

#%% building groups
west = [elem for elem in buil_nos if elem not in {'5300', '5301'}]
    # west campus, excludes the two buildings east of runway

#%% functions
def readMID(MID : str):
    df = pd.read_csv(os.path.join(dirExch, f'{MID}.csv'),
                     header = None,
                     dtype = float,
                     names = ['value'])
    return df['value'].tolist()
