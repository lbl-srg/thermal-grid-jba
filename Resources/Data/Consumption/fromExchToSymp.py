# Python script converting
#   the exchange csv file
#   to Sympheny input xlsx files.
# It is interfaced with the shell using argparse.

import os
import argparse

import numpy as np
import pandas as pd

from _config_estcp import *

def main(sUti: str, sBuis):

    df = pd.DataFrame({'row' : np.linspace(1,8760,8760,dtype = int),
                       'value' : np.zeros(8760)})
    fno = sUti  # output file name

    flag = False
    for sBui in sBuis:
        MID = sBui + '_' + sUti # meter ID
        fni = os.path.join(dirExch, MID + '.csv')
        if os.path.isfile(fni):
            dfr = pd.read_csv(os.path.join(dirExch, MID + '.csv'),
                              header = None)
            df['value'] = df['value'] + dfr
            fno = fno + '_' + sBui
            flag = True
        else:
            print('Not found: ' + MID)

    if flag:
        fno = fno + '.xlsx'
        df.to_excel(fno,
                    engine = 'xlsxwriter',
                    header = False,
                    index = False)
        print('Output file generated: ' + fno)
    else:
        print('No meter found. No output file generated.')

#main('ele', ['1380','1045'])

parser = argparse.ArgumentParser()
parser.add_argument('u',
                    type = str,
                    choices = sUtis,
                    help = 'type of utility, {ele, coo, hea, dhw}')
parser.add_argument('b',
                    nargs='+',
                    type = str,
                    choices = sBuis,
                    help = '4-digit building number')
args = parser.parse_args()

main(args.u, args.b)
