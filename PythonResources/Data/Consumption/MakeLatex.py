#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 26 16:11:54 2024

@author: casper

This script reads the Figures folder and generates Latex code.
"""

from _config_estcp import * # This imports os and pandas as pd

import glob

fns_full = [s for s in sorted(glob.glob(os.path.join(dirFigu,f"*.pdf")))]

with open(os.path.join(dirTex, f'appendix_energy-profiles.tex'), 'w') as f:
    # preceding comments
    f.write(r"""%%% This file is generated from
%%%   thermal-grid-jba/Resources/Data/Consumption/MakeLatex.py
""")
    
    # appendix section title
    f.write(r"""
\newpage
\section{Energy Consumption Profiles}
\label{sec:app_energy-profiles}
""")
    
    # figure set up
    f.write(r"""
\renewcommand\thefigure{\Alph{section}.\arabic{figure}}
\setcounter{figure}{0}
""")
    
    # include figures
    for idx, fn_full in enumerate(fns_full):
        fn_base = os.path.basename(fns_full[idx])
        buil_no = fn_base.replace('.','_').split(sep = '_')[1]
        if buil_no in dfBldg['buil_no'].tolist():
            caption = buil_no.replace('x','&') + ' ' \
                    + dfBldg.loc[dfBldg['buil_no'] == buil_no,'name'].tolist()[0]
        else:
            caption = 'CAPTION'
        label = 'fig:appendix_' + fn_base.split(sep = '.')[0]
        
        f.write(r"""
\begin{figure}[H]
\includegraphics[width=1\textwidth]{resources/figures/%s}
\caption{%s}
\label{%s}
\end{figure}
"""%(fn_base,caption,label))
