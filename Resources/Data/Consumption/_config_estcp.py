# Python script providing public variables
#   for dependent scripts.

import os

import pandas as pd

## shared attributes
sUtis = ['ele', 'coo', 'hea', 'dhw']
    # utility types:
    #   electricity, cooling, heating, domestic hot water
delimiter = ','

## exchange csv files
dirExch = 'exchange'

## eQuest output csv files
dirRead = 'eQuest'
#sBuis = ['1045','1349','1380','1539','1560','1569']
dfBldg = pd.read_csv('buildings.csv',
                     header = 0,
                     thousands = ',',
                     dtype = {'bldg_no' : str,
                              'name' : str,
                              'gross_area_sf' : float,
                              'gross_area_m2' : float})
sBuis = dfBldg['bldg_no'].tolist()
iCols = [16, 30, 31, 32]
    # column numbers of the respective utilities
    #   from the input file (base 0)

## Sympheny input xlsx files
dirWritSymp = 'Sympheny'

## Figure outputs
dirFigu = 'Figures'

## functions
def readMID(MID : str):
    df = pd.read_csv(os.path.join(dirExch, MID + '.csv'),
                     header = None,
                     dtype = float,
                     names = ['value'])
    return df['value'].tolist()
