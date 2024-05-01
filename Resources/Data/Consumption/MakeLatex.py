#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 26 16:11:54 2024

@author: casper

This script reads the Figures folder and generates Latex code.
"""

import glob
import os

from _config_estcp import *

retr = 'base' # 'base' - baseline
              # 'post' - post-ECM

if retr == 'base':
    retr_f = 'Baseline'
elif retr == 'post':
    retr_f = 'Post-ECM'

fns_full = [s for s in sorted(glob.glob(os.path.join(dirFigu,f"{retr}*.pdf")))]
#fns_base = os.path.basename(fns_full) # doesn't work with list


with open(os.path.join(dirTex, f'appendix_{retr}.tex'), 'w') as f:
    # appendix section title
    f.write(r"""\newpage
\section{Whole-Year Energy Consumption Profiles, %s}
"""%retr_f)
    
    # figure set up
    f.write(r"""
\renewcommand\thefigure{\Alph{section}.\arabic{figure}}
\setcounter{figure}{0}""")
    
    # include figures
    for idx, fn_full in enumerate(fns_full):
        fn_base = os.path.basename(fns_full[idx])
        bldg_no = fn_base.replace('.','_').split(sep = '_')[1]
        if bldg_no in dfBldg['bldg_no'].tolist():
            caption = bldg_no.replace('x','&') + ' ' \
                    + dfBldg.loc[dfBldg['bldg_no'] == bldg_no,'name'].tolist()[0] \
                    + f', {retr_f}'
        else:
            caption = 'CAPTION'
        label = 'fig:appendix_' + fn_base.split(sep = '.')[0]
        
        if idx % 2 == 0: # figure on the left
            f.write(r"""
\begin{figure}[h]
\centering
\begin{minipage}{0.49\textwidth}
  \centering
  \includegraphics[width=1\textwidth]{resources/figures/%s}
  \captionof{figure}{%s}
  \label{%s}
\end{minipage}"""%(fn_base,caption,label))
        else: # figure on the right
            f.write(r"""
\begin{minipage}{0.49\textwidth}
  \centering
  \includegraphics[width=1\textwidth]{resources/figures/%s}
  \captionof{figure}{%s}
  \label{%s}
\end{minipage}
\end{figure}"""%(fn_base,caption,label))
    
    if len(fns_full) % 2 != 0: # close off figure if odd
        f.write(r"""
\end{figure}""")
