#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 18 13:42:35 2025

@author: casper
"""

import json
import re

from collections import Counter

def extract_warnings(filepath):
    """
    Extracts warning messages from dslog.txt.
    """
    
    def reset_dict():
        """
        Resets values of the warning dict
        """
        r = {'warning' : "",
             'time' : -99.0,
             'tag' : ""
             }
        return r
    
    warnings = []
    started = False # Flag to track if "Integration started" has been found

    try:
        with open(filepath, 'r') as f:
            for line in f:
                if (not started) and ("Integration started" in line):
                    started = True
                    block = reset_dict()

                if started:
                    # sequence of if blocks are reverse of how they would appear in the file
                    if block['time'] > -98.0: # if time already saved
                        block['tag'] = line.split(':',1)[1].strip()
                        warnings.append(block)
                        block = reset_dict()
                    if block['warning']: # if warning message already saved
                        block['time'] = float(line.split(':',1)[1].strip())
                    if "Warning: " in line: # detect the warning message
                        block['warning'] = line.split(':',1)[1].strip()

    except FileNotFoundError:
        print(f"Error: File not found at {filepath}")
        return []

    return warnings

def find_nonlinear(filepath, tags):
    """

    """
    # bracket = 0 # Counting bracket to find end of c block
    varline = ""
    started = False # Flag to track if "Integration started" has been found
    varfound = False # Flag to track if the varname line has been found
    blocks = [] # Variable blocks to return

    try:
        with open(filepath, 'r') as f:
            for line in f:
                if not started:
                    tag = [ext for ext in tags if(f"Tag: {ext}" in line)]
                    if tag:
                        started = True
                        tags.remove(tag[0])
                
                if started:
                    if "varnames_[]=" in line:
                        varfound = True
                        
                    if varfound:
                        varline += line
                        if ";" in line: # end of varname line
                            varfound = False
                            varnames = re.findall(r'"(.*?)"', varline)
                            blocks.append({
                                'tag' : tag[0],
                                'size' : len(varnames),
                                'varnames' : varnames
                                })
                            started = False
                            varfound = False
                            varline = ""
        return blocks
        
    except FileNotFoundError:
        print(f"Error: File not found at {filepath}")
        return []

#%% input
FILE_DSLOG = "whofailed/dslog.txt"
FILE_DSMODELC = "whofailed/dsmodel.c"

#%% process dslog.txt to find the nonlinear system tags
warnings = extract_warnings(FILE_DSLOG)
tag_counts = dict(Counter(item['tag'] for item in warnings))

#%% process dsmodel.c to find the variables involved in the nonlinear systems
blocks = find_nonlinear(FILE_DSMODELC, list(tag_counts.keys()))
blocks = [{**block, 'occurrence': tag_counts[block['tag']]} for block in blocks]
print(json.dumps(blocks, indent = 4))


