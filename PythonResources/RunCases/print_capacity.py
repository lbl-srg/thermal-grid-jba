#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun  3 15:34:04 2025

@author: casper
"""

import os

from buildingspy.io.outputfile import Reader

import unyt as uy
# There appears to be no way to remove a user-defined unit from the
#   UnitRegistry once defined. The console must be restarted.
uy.define_unit("kBTU", 1000 * uy.BTU)
uy.define_unit("RT", 12000 * uy.Unit("BTU/hr")) # refrigeration ton
#uy.define_unit("inH2O", 249.089 * uy.Unit("Pa"))
uy.define_unit("GPM_H2O", 1/15.85 * uy.Unit("kg/s"))
uy.define_unit("GPM_Glycol", 1/15.85/1.11 * uy.Unit("kg/s"))
# glycol density = 1.11e3 kg/m3
uy.define_unit("CFM_Air", 1/1.293*3.28**3*60 * uy.Unit("kg/s"))
# 1 kg/s / 1.293 kg/m3 * 3.28^3 (ft3/m3) * 60 min/s = 1637 cfm

# CWD = os.getcwd()
CWD = os.path.dirname(os.path.abspath(__file__))
mat_file_path = os.path.join(CWD, "simulations", "2025-05-25", "DetailedPlantFiveHubs.mat")

r=Reader(mat_file_path, 'dymola')
nBui = 5
# nBui = int(read_parameter('nBui'))

def read_parameter(varName):
    """ Returns the first value of a series read from mat file.
    """
    (t, y) = r.values(varName)
    return y[0]

def read_max_abs(varName):
    """ Returns the max of abs of a series read from the mat file.
    """
    return max(r.max(varName), abs(r.min(varName)))

#%% write to latex
def write_row(val,
              desc,
              unit_mat,
              unit_si,
              unit_ip,
              format_si = ',.0f',
              format_ip = ',.0f',
              display_si = None,
              display_ip = None):
    
    """ Returns one row for the latex table.
        `val`           the value to be put in the table,
        `desc`          description of the value,
        `unit_mat`      the unit from the mat file,
        `unit_si`       the si unit to be printed,
        `unit_ip`       the ip unit to be printed,
        `format_si`     format control string of the si number,
        `format_ip`     format control string of the ip number,
        `display_si`    how the unit is printed, leave as None if same as `unit_si`
        `display_ip`    same as above. 
    """
    
    tab = ""
    
    val_si = float((val * uy.Unit(unit_mat)).in_units(uy.Unit(unit_si)).value)
    val_ip = float((val * uy.Unit(unit_mat)).in_units(uy.Unit(unit_ip)).value)
    if display_si is None:
        display_si = unit_si
    if display_ip is None:
        display_ip = unit_ip
    tab += f" & {desc} & {val_si:{format_si}} & {display_si} & {val_ip:{format_ip}} & {display_ip} \\\\\n"
    
    return tab
    
tab = ""
tab += "\\begin{tabular}{llrlrl}\n"
tab += "\\toprule\n"
tab += " & System capacity & \\multicolumn{2}{c}{SI unit} & \\multicolumn{2}{c}{IP unit} \\\\\n"
tab += "\\hline\n"

## ETS
for i in range(1,nBui+1):
    
    # chiller
    tab += f"ETS {i}" # This will go bofore the `&` of the first row
    
    tab += write_row(val = read_parameter(f'bui[{i}].ets.chi.chi.QHea_flow_nominal'),
                     desc = "Heat recovery chiller - heating",
                     unit_mat = "W",
                     unit_si = "kW",
                     unit_ip = "kBTU/hr",
                     display_ip = "kBtu/hr")
    
    tab += write_row(val = abs(read_parameter(f'bui[{i}].ets.chi.chi.QCoo_flow_nominal')),
                     desc = "Heat recovery chiller - cooling",
                     unit_mat = "W",
                     unit_si = "kW",
                     unit_ip = "RT",
                     display_ip = "ton")
    
    # hex
    tab += write_row(val = read_parameter(f'bui[{i}].hexSiz.Q_flow_nominal'),
                     desc = "District heat exchanger",
                     unit_mat = "W",
                     unit_si = "kW",
                     unit_ip = "kBTU/hr",
                     display_ip = "kBtu/hr")

    # dhw
    if i != 1: # Bui[1] doesn't have dhw.
        tab += write_row(val = read_parameter(f'bui[{i}].datDhw.VTan'),
                         desc = "Domestic hot water tank",
                         unit_mat = "m**3",
                         unit_si = "m**3",
                         unit_ip = "gal_US",
                         display_si = "m$^3$",
                         display_ip = "gal")
    
    tab += "\\hline\n"

## central plant
tab += "Central plant"

tab += write_row(val = read_parameter('cenPla.gen.heaPum.QHea_flow_nominal'),
                 desc = "Heat pump - heating",
                 unit_mat = "W",
                 unit_si = "kW",
                 unit_ip = "kBTU/hr",
                 display_ip = "kBtu/hr")

tab += write_row(val = abs(read_parameter('cenPla.gen.heaPum.QCoo_flow_nominal')),
                 desc = "Heat pump - cooling",
                 unit_mat = "W",
                 unit_si = "kW",
                 unit_ip = "RT",
                 display_ip = "ton")

# dry cooler
tab += write_row(val = read_parameter('cenPla.gen.fanDryCoo.m_flow_nominal')/1.293,
                 desc = "Dry cooler - air side",
                 unit_mat = "m**3/s",
                 unit_si = "m**3/hr",
                 unit_ip = "ft**3/min",
                 display_si = "m3/h",
                 display_ip = "cfm")

tab += write_row(val = read_parameter('cenPla.gen.pumDryCoo.m_flow_nominal'),
                 desc = "Dry cooler - glycol side",
                 unit_mat = "kg/s",
                 unit_si = "kg/s",
                 unit_ip = "GPM_Glycol",
                 display_ip = "gpm")

# borefield
tab += write_row(val = read_max_abs('EBorPer.y'),
                 desc = "Borefield perimeter zone",
                 unit_mat = "J",
                 unit_si = "MWh",
                 unit_ip = "MMBTU",
                 display_ip = "MMBtu")

tab += write_row(val = read_max_abs('EBorCen.y'),
                 desc = "Borefield center zone",
                 unit_mat = "J",
                 unit_si = "MWh",
                 unit_ip = "MMBTU",
                 display_ip = "MMBtu")

tab += "\\hline\n"

## district
tab += "District network"

tab += write_row(val = read_parameter('datDis.mPumDis_flow_nominal'),
                 desc = "Distribution pump flow rate",
                 unit_mat = "kg/s",
                 unit_si = "kg/s",
                 unit_ip = "GPM_H2O",
                 display_ip = "gpm")

tab += write_row(val = read_parameter('pumDis.dp_nominal'),
                 desc = "Distribution pump pressure rise",
                 unit_mat = "Pa",
                 unit_si = "kPa",
                 unit_ip = "psi")

# length of pipes
l = 0
for i in range(1,nBui+2):
    l += read_parameter(f'datDis.lDis[{i}]')
tab += write_row(val = l,
                 desc = "District piping",
                 unit_mat = "m",
                 unit_si = "m",
                 unit_ip = "ft")

l = 0
for i in range(1,nBui+1):
    l += read_parameter(f'datDis.lCon[{i}]') * 2
tab += write_row(val = l,
                 desc = "Connection piping",
                 unit_mat = "m",
                 unit_si = "m",
                 unit_ip = "ft")

tab += "\\bottomrule\n"

tab += "\\end{tabular}"

with open(os.path.join(CWD,"capacities-modelica.tex"), 'w') as f:
        f.write(tab)