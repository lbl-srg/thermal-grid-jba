# -*- coding: utf-8 -*-
"""
Created on Wed May 28 23:46:31 2025

@author: remi
"""

import numpy as np

def calc_finance(If, Iv, C, l, alpha, duration = 20, i = 0.05, g = 0.03):
    r"""
    Calculation of the financial indicators: 
        - Annualized life cycle cost (ALCC)
        - Life cycle cost (LCC)
        - Investement cost (I)
        - Operation and maintenance (O&M)
        - Replacement cost (RC)
        - Salvage revenue (SR)
        - Capital Recovery Factor (CRF)
        
    Parameters
    ----------
    If    : Fixed part of the investment cost
    Iv    : Variable part of the investment cost, cost per unit
    C     : Capacity of the equipment
    l     : Lifetime of the equipment
    alpha : percentage of the investment cost associated with operation and maintenance expenses

    Returns
    -------
    y : TYPE
        DESCRIPTION.

    """
    
    r = (i - g) / (1 + g)
    crf = (r * ( 1 + r) ** duration) / (( 1 + r) ** duration - 1)
    
    # Investment cost
    I = If + Iv * C
    
    # Replacement cost
    RC = 0
    l_new = l
    while l_new < duration:
        RC = RC + I / (1 + r) ** l_new
        l_new = l_new + l
    
    # Salvage revenue
    SR = I * ((l_new - duration) / l) / (1 + r) ** duration
    
    # O&M
    OM = 0
    for k in np.arange(1, duration + 1):
        OM = OM + alpha * I / (1 + r) ** k
    
    # Life-cycle cost
    LCC = I + RC - SR + OM
    
    ALCC = LCC * crf
    
    return [ALCC, LCC, I, OM, RC, SR, crf]


#aa = calc_finance(0, 757, 4168.553, 15, 0)

