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

stag = 'futu' # stage: 'base' baseline ,
              #        'post' post-ECM ,
              #        'futu' future .
util_cols = [[4,5,6], 30, 31, 32]
    # column numbers of the respective utilities
    #   from the input file (base 0)
    # ele needs to be summed up
row_start = 10
row_end = 8770

for buil_no in buil_nos:
    if stag == 'base':
        filename = f'{buil_no}*Baseline*.csv'
    elif stag == 'post':
        filename = f'{buil_no}*Post*.csv'
    elif stag == 'futu':
        filename = f'{buil_no}*Future*.csv'
    else:
        filename = ''
    
    with open(glob.glob(os.path.join(dirRead, filename))[0],
              newline='') as fr:
        reader = csv.reader(fr, delimiter=',')
        rows = list(reader)

    for idxU, util in enumerate(utils):
        
        util_col = util_cols[idxU]
        
        if util == 'dhw':
            if len(rows[row_start]) <= util_col:
                # if dhw column doesn't exist
                continue
            if rows[row_start][util_col] == '':
                # if dhw column is empty
                continue

        with open(os.path.join(dirExch, f'{stag}_{buil_no}_{util}.csv'),
                  'w',
                  newline='') as fw:
            writer = csv.DictWriter(fw,
                                    fieldnames = ['value'],
                                    delimiter = delimiter)
                # Fields:
                #   value           - float non-negative
            
            for idxR in range(row_start,row_end):
                if util == 'ele':
                    # ele: sum 3 columns
                    valu = 0
                    for c in util_col:
                        valu += float(rows[idxR][c])
                else:
                    # all others: convert from Btu to kWh
                    valu = abs(float(rows[idxR][util_col])) / 3412.142
                
                writer.writerow({'value' : valu})
