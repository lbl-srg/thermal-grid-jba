#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 22 15:25:44 2024

@author: casper

This script merges pdf figures to a single file.
"""

from _config_estcp import * # This imports os and pandas as pd

import glob

from PyPDF2 import PdfMerger

m = PdfMerger()
pdfs = [a for a in sorted(glob.glob(os.path.join(dirFigu,"*.pdf")))]
[m.append(pdf) for pdf in pdfs]
with open("figures_merged.pdf", "wb") as f:
    m.write(f)
