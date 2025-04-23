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
# list of hubs
dict_hub = {'H01' : ['1500'],
            'H02' : ['1560'],
            'H03' : ['1569'],
            'H04' : ['1690', '1691', '1692'],
            'H05' : ['1800'],
            'H06' : ['1676'],
            'H07' : ['1657'],
            'H08' : ['1631'],
            'H09' : ['1359', '1380'],
            'H10' : ['1045'],
            'H11' : ['1065'],
            'H12' : ['1058x1060'],
            'H13' : ['1349'],
            'H14' : ['1345']}

# list of clusters
dict_clu = {'CA' : ['1345', '1500'],
            'CB' : ['1349', '1058x1060'],
            'CC' : ['1045', '1065'],
            'CD' : ['1359', '1380'],
            'CE' : ['1560', '1569', '1631', '1657', '1676', '1690', '1691', '1692', '1800']}

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
