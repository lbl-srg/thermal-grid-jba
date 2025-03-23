#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 18 13:42:35 2025

@author: casper

Todo:
    - Store specific warning & error messages.
    - Other misc cases.
"""

import json
import re

from collections import Counter

def extract_messages(filepath):
    """
    Extracts warning messages from dslog.txt.
    """
    messages = []
    msg = {}
    started = False
    buffer = ""
    patternmsg = r'^[A-Z].*:.*$' # pattern that starts a msg
    patterns = {
        'warning1' : re.compile(
                        r"Warning: Failed to solve nonlinear system using Newton solver\.\n"
                        r"\s*Time:\s*(\d+\.\d+)\n"
                        r"\s*Tag:\s*(\S+)"
                        ),
        'warning2' : re.compile(
                        r"Warning: Nonlinear solver accepted imprecise solution \(within integrator tolerance\) when solving\n"
                        r"\s*Tag:\s*(\S+)\s+during event iteration at time\s*(\d+)\."
                        ),
        'error'    : re.compile(
                        r"Error: The following error was detected at time:\s*(?P<time>\d+\.\d+).*?\n\s*In\s+(?P<var>\S+):",
                        re.DOTALL
                        ),
        'sundials' : re.compile(
                        r"SUNDIALS: CVODE CVode At t\s*=\s*([-+]?\d+(\.\d+)?([eE][-+]?\d+)?), mxstep steps taken before reaching tout."
                        )
            }
        
    try:
        with open(filepath, 'r') as f:
            for line in f:
                if (not started) and ("Integration started" in line):
                    started = True

                if started:
                        
                    match = re.match(patternmsg, line)
                    if match:
                        match = patterns['warning1'].search(buffer)
                        if match:
                            msg = {
                                'type' : 'Warning',
                                'time' : match.groups()[0],
                                'tag'  : match.groups()[1]
                                }
                        match = patterns['warning2'].search(buffer)
                        if match:
                            msg = {
                                'type' : 'Warning',
                                'time' : match.groups()[1],
                                'tag'  : match.groups()[0]
                                }
                        match = patterns['error'].search(buffer)
                        if match:
                            msg = {
                                'type' : 'Error',
                                'time' : match.group('time'),
                                'var'  : match.group('var')
                                }
                        match = patterns['sundials'].search(buffer)
                        if match:
                            msg = {
                                'type' : 'SUNDIALS',
                                'time' : match.group(1)
                                }
                        if not msg:
                            msg = {
                                'type' : 'Unaccounted',
                                'msg'  : buffer
                                }
                        if buffer and (not "Integration started" in buffer):
                            messages.append(msg)
                    
                        msg = {}
                        buffer = ""
                    buffer += line

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

#%% Main function
def main(file_dslog="whofailed/dslog.txt", 
         file_dsmodelc="whofailed/dsmodel.c", 
         output_warning_tags=True, 
         output_error_vars=True, 
         output_unaccounted=False, 
         output_warning_blocks=True):
    
    output = ""
    
    # process dslog.txt to find the nonlinear system tags
    messages = extract_messages(file_dslog)
    tag_counts = dict(Counter(item['tag'] for item in [item for item in messages if item.get('type') == 'Warning']))
    var_counts = dict(Counter(item['var'] for item in [item for item in messages if item.get('type') == 'Error']))
    
    if output_warning_tags:
        output = "\n".join([output, "*** Tags in warnings ***",
                            json.dumps(tag_counts, indent = 4)])
    if output_error_vars:
        output = "\n".join([output, "*** Vars in errors ***",
                            json.dumps(var_counts, indent = 4)])
    if output_unaccounted:
        output = "\n".join([output,
                            "*** The following messages are not accounted for ***",
                            ("="*10+"\n").join(m['msg'] for m in messages if m['type'] == 'Unaccounted')])
    
    # process dsmodel.c to find the variables involved in the nonlinear systems
    blocks = find_nonlinear(file_dsmodelc, list(tag_counts.keys()))
    blocks = [{**block, 'occurrence': tag_counts[block['tag']]} for block in blocks]
    if output_warning_blocks:
        output = "\n".join([output, "*** Blocks in warnings ***", json.dumps(blocks, indent = 4)])
    
    return output

#%% Main process
if __name__ == '__main__':
    output = main()
    print(output)