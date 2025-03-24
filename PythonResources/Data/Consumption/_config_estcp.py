# Python script providing public variables
#   for dependent scripts.

import os

import pandas as pd

#%% shared attributes
stags = ['base', 'post', 'futu']
    # stages:
    #   baseline, post-ECM, future
weatherfile = {'base' : "USA_MD_Andrews.AFB.745940_TMY3.mos",
               'post' : "USA_MD_Andrews.AFB.745940_TMY3.mos",
               'futu' : "fTMY_Maryland_Prince_George's_NORESM2_2020_2039.mos"}
    # corresponding weather file names
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
                              'remark1' : str,
                              'chw_sup_f' : float,
                              'chw_dt_f' : float,
                              'hhw_sup_f' : float,
                              'hhw_dt_f' : float,
                              'dhw_sup_f' : float,
                              'have_dhw' : str})
buil_nos = dfBldg['buil_no'].tolist()
util_cols = [16, 30, 31, 32]
    # column numbers of the respective utilities
    #   from the input file (base 0)

#%% Directories
dirWritSymp = 'Sympheny' # Sympheny input xlsx files
dirWritMode = 'Modelica' # Modelica input xlsx files
dirFigu = 'Figures'
dirTabl = 'Tables'
dirTex = 'Latex'

#%% functions
def readMID(MID : str):
    df = pd.read_csv(os.path.join(dirExch, f'{MID}.csv'),
                     header = None,
                     dtype = float,
                     names = ['value'])
    return df['value'].tolist()

def f_to_c_T(f):
    """
    Converts temperature from F to C.
    
    Parameters
    ----------
    f : float
        farenheit

    """
    c = (f-32)*5/9
    return c

def f_to_c_dT(f):
    """
    Converts temperature difference from F to C (K).

    Parameters
    ----------
    f : float
        farenheit

    """
    c = f*5/9
    return c

def findMeta(buil_no, colname):
    """
    Short-hand for finding building metadata from dfBldg

    Parameters
    ----------
    buil_no : building number such as '1045'
    colname : column name such as 'hhw_dt_f'

    """
    return dfBldg.loc[dfBldg['buil_no']==buil_no,colname].tolist()[0]
