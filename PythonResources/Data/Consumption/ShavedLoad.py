#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep  3 16:08:54 2024

@author: casper
"""

from _config_estcp import *

import numpy as np

for bui in buil_nos:

    hea = np.array(readMID(f'post_{bui}_hea'))
    
    heaSor = np.sort(hea)[::-1] # sorted in descending order
    heaSum = np.cumsum(heaSor)
    ind = np.searchsorted(heaSum, 0.2*np.sum(heaSor)) # find 20% percentile
    thr = heaSor[ind] # value at 20% percentile
    heaTip = hea - thr 
    heaTip[heaTip<0] = 0 # tip, part above threshold
    heaSha = hea - heaTip # shaved, part below threshold
    
    dfTip = pd.DataFrame({'row' : np.linspace(1,8760,8760,dtype = int),
                          'value' : heaTip})
    dfSha = pd.DataFrame({'row' : np.linspace(1,8760,8760,dtype = int),
                          'value' : heaSha})
    
    fnTip = f'post_{bui}_heatip.xlsx'
    dfTip.to_excel(os.path.join('SymphenyShaved',fnTip),
                   engine = 'xlsxwriter',
                   header = False,
                   index = False)
    print(f'Output file generated: {fnTip}')
    
    fnSha = f'post_{bui}_heasha.xlsx'
    dfSha.to_excel(os.path.join('SymphenyShaved',fnSha),
                   engine = 'xlsxwriter',
                   header = False,
                   index = False)
    print(f'Output file generated: {fnSha}')
