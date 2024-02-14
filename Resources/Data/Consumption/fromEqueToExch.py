# Python script converting
#   eQuest output csv files provided by Southland
#   to a standardised csv exchange file.
# The exchange file will subsequently be used
#   to generate input files for Sympheny or Modelica
#   by other scripts

import os
import csv
import glob

import numpy as np

from _config_estcp import *

# Deletes the folder of the previous written exchange files
#   and remake the directory
os.system('rm -rf ' + dirExch)
os.makedirs(dirExch)

for sBui in sBuis:
    with open(glob.glob(os.path.join(dirRead, sBui + '*.csv'))[0],
              newline='') as fr:
        reader = csv.reader(fr, delimiter=',')
        rows = list(reader)

    # For each utility type
    for idxU in range(0,4):
        sUti = sUtis[idxU]
        iCol = iCols[idxU]

        if len(rows[10]) <= iCol:
            # if column doesn't exist
            continue
            
        if rows[10][iCol] == '':
            # if column is empty
            continue

        with open(os.path.join(dirExch, sBui + '_' + sUti + '.csv'),
                  'w',
                  newline='') as fw:
            writer = csv.DictWriter(fw,
                                    fieldnames = ['value'],
                                    delimiter = delimiter)
                # Fields:
                #   value           - float non-negative
            
            for idxR in range(10,8770):
                fUti = abs(float(rows[idxR][iCol]))
                if sUti != 'ele':
                    # if ele, do nothing
                    # all others, convert from Btu to kWh
                    fUti = fUti / 3412.142
                
                writer.writerow({'value' : fUti})

fw.close
