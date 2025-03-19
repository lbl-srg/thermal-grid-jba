#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 18 13:42:35 2025

@author: casper
"""

import json
import re

from collections import Counter

def extract_messages(filepath):
    """
    Extracts warning messages from dslog.txt.
    """
    messages = []
    block = {}
    started = False
    iswarning = False
    iserror = False
    patternerror = r'  In (.*?):'
    
    def closeoff():
        """
        Closes off 

        """
        
    
    try:
        with open(filepath, 'r') as f:
            for line in f:
                if (not started) and ("Integration started" in line):
                    started = True

                if started:
                    if "Warning:" in line: # detect the warning message
                        block['type'] = 'warning'
                        iswarning = True
                        # warning messages have the sequence:
                        #   type, message; time; tag
                        block['message'] = line.split(':')[1].strip()
                    if "Error:" in line: # detect the error message
                        block['type'] = 'error'
                        iserror = True
                        # error messages have the sequence:
                        #   type, time; var; message (multiline); condition
                        block['time'] = block['time'] = float(line.split(':')[2].strip())
                    
                    if iswarning:
                        if 'Time:' in line:
                            block['time'] = float(line.split(':')[1].strip())
                        if 'Tag:' in line:
                            block['tag'] = line.split(':')[1].strip()
                            messages.append(block)
                            block = {}
                            iswarning = False
                    if iserror:
                        match = re.search(patternerror, line)
                        if match:
                            block['var'] = match.group(1)
                        if 'Failed condition:' in line:
                            block['failed condition'] = line.split(':')[1].strip()
                            messages.append(block)
                            block = {}
                            iserror = False

    except FileNotFoundError:
        print(f"Error: File not found at {filepath}")
        return []

    return messages

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
messages = extract_messages(FILE_DSLOG)
tag_counts = dict(Counter(item['tag'] for item in [item for item in messages if item.get('type') == 'warning']))
var_counts = dict(Counter(item['var'] for item in [item for item in messages if item.get('type') == 'error']))
print(var_counts)

#%% process dsmodel.c to find the variables involved in the nonlinear systems
blocks = find_nonlinear(FILE_DSMODELC, list(tag_counts.keys()))
blocks = [{**block, 'occurrence': tag_counts[block['tag']]} for block in blocks]
#print(json.dumps(blocks, indent = 4))


