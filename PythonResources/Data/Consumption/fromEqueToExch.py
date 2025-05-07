# Python script converting
#   eQuest output csv files provided by Southland
#   to a standardised csv exchange file.
# The exchange file will subsequently be used
#   to generate input files for Sympheny or Modelica
#   by other scripts

from _config_estcp import * # This imports os and pandas as pd

import glob
import shutil

import numpy as np
import pandas as pd

# Deletes the folder of the previous written exchange files
#   and remake the directory
flag_deleteOldDirectory = False
if flag_deleteOldDirectory:
    shutil.rmtree(dirExch)
    os.makedirs(dirExch, exist_ok = True)

def safe_read_csv(fr):
    """ Special handling of the dhw column:
           When dhw is not in the file, it can be either out of bound or empty.
           The csv is therefore first test-read to see how many columns exist.
    """
    header = pd.read_csv(fr, nrows=0)
    num_columns = len(header.columns)
    
    if num_columns >= 33:  # Check if column 32 exists (index 32 means 33 columns)
        usecols = [4, 5, 6, 30, 31, 32]
        names = ['ele1', 'ele2', 'ele3', 'coo', 'hea', 'dhw']
        have_dhw = True
    else:
        usecols = [4, 5, 6, 30, 31]
        names = ['ele1', 'ele2', 'ele3', 'coo', 'hea']
        have_dhw = False
    
    df = pd.read_csv(fr,
                     dtype=float,
                     header=0,
                     skiprows=9,
                     nrows=8760,
                     usecols=usecols,
                     names=names)
    
    # if column exists but empty, have_dhw := false
    have_dhw = have_dhw and not np.isnan(df['dhw'][0])
    
    return df, have_dhw

def compute_ele_ahu(QCoo, QHea):
    """ Adapted from PythonResources/ahuFan/fanEnergyUse.py
          for series computation and inclusion of Q_Hea.
        Temperature: design dT0 = 10 K.
        Flow rate:
          For cooling,
            VCoo is at ratVMin = 20% when QCoo is at 70%,
            above this point V increases linearly towards 100% QCoo,
            below this point V is flat until 1% QCoo then V = 0 (turned off).
          For heating,
            VHea is at ratVMin = 20% whenever QHea above 1% (on).
          V takes the max of the above.
        Pressure:
          dpMaxFan = 2000 at V0
          dpStaPre = 400  at VMin
          Scaled based on the affinity laws.
    """
   
    QCoo_nominal = max(QCoo)
    QHea_nominal = max(QHea)
    dT0 = 10
    
    # flow
    V0 = QCoo_nominal / 1006. / dT0
    ratVMin = 0.2
    
    ratQCoo = QCoo / QCoo_nominal
    VCoo = pd.Series(index=ratQCoo.index, dtype=float)
    VCoo[ratQCoo < 0.01] = 0
    VCoo[(ratQCoo >= 0.01) & (ratQCoo < 0.7)] = ratVMin * V0
    VCoo[ratQCoo >= 0.7] = (ratVMin + (ratQCoo[ratQCoo >= 0.7] - 0.7) / (1 - 0.7) * (1 - ratVMin)) * V0
    
    ratQHea = QHea / QHea_nominal
    VHea = pd.Series(index=ratQHea.index, dtype=float)
    VHea[ratQHea < 0.01] = 0
    VHea[ratQHea >= 0.01] = ratVMin * V0
    
    V = VCoo.combine(VHea, max)
    
    # pressure
    dpFanMax = 2000
    dpStaPre = 400
    dp = dpStaPre + (dpFanMax-dpStaPre)* (V/V0)**2

    # Fan power use
    etaFan = 0.7
    P = V*dp/etaFan
    
    return P

def write_csv(stag,buil_no):
    if stag == 'base':
        filename = f'{buil_no}*Baseline*.csv'
    elif stag == 'post':
        filename = f'{buil_no}*Post*.csv'
    elif stag == 'futu':
        filename = f'{buil_no}*Future*.csv'
    else:
        print(f'`stag = "{stag}"` is invalid.')
        return
    fr = glob.glob(os.path.join(dirRead, filename))[0]
    df, have_dhw = safe_read_csv(fr)
    
    btu_to_kwh = 1/3412.142
    for util in utils:
        if util == 'ele':
            # ele: sum the ele colomns
            series = df['ele1'] + df['ele2'] + df['ele3'] \
                + compute_ele_ahu(df['coo']*btu_to_kwh,df['hea']*btu_to_kwh)
        else:
            # all others: convert from Btu to kWh
            if util == 'dhw' and not have_dhw:
                continue
            series = abs(df[util]) * btu_to_kwh
        
        fw = os.path.join(dirExch, f'{stag}_{buil_no}_{util}.csv')
        series.to_csv(fw,
                      sep=',',
                      header=False,
                      index=False)

#%% Main process
for stag, buil_no in [(stag, buil_no) for stag in stags for buil_no in buil_nos]:
    write_csv(stag,buil_no)

#%%
write_csv('futu','1500')
