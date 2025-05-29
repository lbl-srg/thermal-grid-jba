#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May 21 10:25:20 2025

@author: casper
"""

import os
import numpy as np
import unyt as uy
from scipy.integrate import trapz

#from GetVariables import get_vars, index_var_list
# python file under same folder

#CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))

# mat_file_name = os.path.join(CWD, "simulations", "ETS_All_futu", "ConnectedETSWithDHW.mat")

# var_list = ['dHChiWat.u', 'dHChiWat.y']
# results = get_vars(var_list,
#                    mat_file_name,
#                    'dymola')

#%%
# def hourly_sample_sum(t, u):
    
#     u_h = u[np.isclose(t % 3600, 0)]
#     return u_h.sum()
#     #results = results[np.isclose(results['Time'] % 3600, 0)] # only keep hourly sampled values

# t = np.array(results['Time'])
# u = np.array(results['dHChiWat.u'])
# y = np.array(results['dHChiWat.y'])
# I_u = trapz(u, t)
# sum_u = hourly_sample_sum(t, u)

# J_to_kWh = 2.7777777777777776e-07

# print(f'Integral of u =\n  {I_u[-1]*J_to_kWh}')
# print(f'Modelica y[-1] =\n  {y[-1]*J_to_kWh}')
# print(f'Hourly sample sum of u =\n  {sum_u*J_to_kWh}')

#%%
def integrate_with_condition(u, t, condition = None):
    """ Integrates u along t
        All input arrays should be numpy arrays.
        `condition` can be the following:
            'positive' - Only integrates positive values of u,
                           zero crossing points are found linearly and inserted
                           to the series.
            'negative' - Similar to above but negative.
            Boolean array - Only integrates u where condition is True,
                           when `condition` flips from True at t1 to False at t2,
                           a point (t2, 0) is inserted after (t2, u2) to create a step down;
                           when `condition` flips from False at t3 to True at t4,
                           a point (t4, 0) is inserted before (t4, u4) to create a step up;
                           set u = 0 for all points between t2 and t3.
                           
    """
    
    if isinstance(condition, str):
        if condition in ['positive', 'negative']:
            sign_changes = np.where(np.diff(np.sign(u)))[0]
            
            # Initialize lists to store zero crossing times and values
            t_crossing = []
            u_crossing = []
        
            for i in sign_changes:
                # Perform linear interpolation to find the exact zero crossing time
                t1, t2 = t[i], t[i + 1]
                u1, u2 = u[i], u[i + 1]
                
                # Calculate the zero crossing time
                t_zero = t1 - u1 * (t2 - t1) / (u2 - u1)
                u_zero = 0.0
                
                # Append the zero crossing time and value to the lists
                t_crossing.append(t_zero)
                u_crossing.append(u_zero)
            
            # Insert zero crossings into the original time series
            for t_zero, u_zero in zip(t_crossing, u_crossing):
                idx = np.searchsorted(t, t_zero)
                t = np.insert(t, idx, t_zero)
                u = np.insert(u, idx, u_zero)
            
            # Assign zeros
            if condition == 'positive':
                u[u<0] = 0
            if condition == 'negative':
                u[u>0] = 0
    
    elif not condition is None:
        
        _t = []
        _u = []
        i = 0
        while i < len(t):
            _t.append(t[i])
            
            if i < len(t) - 1 and (condition[i] and not condition[i + 1]):
                # creates a step down at True to False
                _t.append(t[i+1])
                _u.append(u[i])
                _u.append(0.)
            
            elif i < len(t) - 1 and (not condition[i] and condition[i + 1]):
                # creates a step up at False to True
                _t.append(t[i+1])
                _u.append(0.)
                _u.append(u[i+1])
            
            else:
                if condition[i]:
                    _u.append(u[i])
                else:
                    _u.append(0.)
            
            i += 1
            
        t = _t
        u = _u
        
        print(f'  t = {t}')
        print(f'  u = {u}')
        
    I = trapz(u, t)
    return I

t = np.array([0,1,2,3,4])
u = np.array([1,1,-1,1,1])
c = [True, False, False, False, True]

print(f't = {t}')
print(f'u = {u}')
print('no option')
print(f'  I = {integrate_with_condition(u,t)}')
print('positive')
print(f'  I = {integrate_with_condition(u,t,"positive")}')
print('u > 0')
print(f'  I = {integrate_with_condition(u,t,c)}')