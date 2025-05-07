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

for stag, buil_no in [(stag, buil_no) for stag in stags for buil_no in buil_nos]:
    if stag == 'base':
        filename = f'{buil_no}*Baseline*.csv'
    elif stag == 'post':
        filename = f'{buil_no}*Post*.csv'
    elif stag == 'futu':
        filename = f'{buil_no}*Future*.csv'
    else:
        print(f'`stag = "{stag}"` is invalid.')
        continue
    fr = glob.glob(os.path.join(dirRead, filename))[0]
    df, have_dhw = safe_read_csv(fr)
    
    for util in utils:
        if util == 'ele':
            # ele: sum the ele colomns
            series = df['ele1'] + df['ele2'] + df['ele3']
        else:
            # all others: convert from Btu to kWh
            if util == 'dhw' and not have_dhw:
                continue
            series = abs(df[util]) / 3412.142
        
        fw = os.path.join(dirExch, f'{stag}_{buil_no}_{util}.csv')
        series.to_csv(fw,
                      sep=',',
                      header=False,
                      index=False)
