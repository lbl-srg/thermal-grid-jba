# Python script converting
#   eQuest output csv files provided by Southland
#   to a standardised csv exchange file.
# The exchange file will subsequently be used
#   to generate input files for Sympheny or Modelica
#   by other scripts

from _config_estcp import * # This imports os and pandas as pd

import csv
import glob
import shutil

import numpy as np

# Deletes the folder of the previous written exchange files
#   and remake the directory
flag_deleteOldDirectory = False
if flag_deleteOldDirectory:
    shutil.rmtree(dirExch)
    os.makedirs(dirExch, exist_ok = True)

retr = 'post' # retrofit: 'base' baseline ,
              #           'post' post-ECM

for buil_no in buil_nos:
    if retr == 'base':
        filename = f'{buil_no}*Baseline*.csv'
    elif retr == 'post':
        filename = f'{buil_no}*Post*.csv'
    else:
        filename = ''
    
    with open(glob.glob(os.path.join(dirRead, filename))[0],
              newline='') as fr:
        reader = csv.reader(fr, delimiter=',')
        rows = list(reader)

    # For each utility type
    for idxU in range(0,4):
        util = utils[idxU]
        util_col = util_cols[idxU]

        if len(rows[10]) <= util_col:
            # if column doesn't exist
            continue
            
        if rows[10][util_col] == '':
            # if column is empty
            continue

        with open(os.path.join(dirExch, f'{retr}_{buil_no}_{util}.csv'),
                  'w',
                  newline='') as fw:
            writer = csv.DictWriter(fw,
                                    fieldnames = ['value'],
                                    delimiter = delimiter)
                # Fields:
                #   value           - float non-negative
            
            for idxR in range(10,8770):
                valu = abs(float(rows[idxR][util_col]))
                if util != 'ele':
                    # if ele, do nothing
                    # all others, convert from Btu to kWh
                    valu = valu / 3412.142
                
                writer.writerow({'value' : valu})

fw.close
