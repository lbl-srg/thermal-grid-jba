This directory contains scripts to send data to the MILP platform (Sympheny) and to post-process the results.

## Sending data to the MILP platform

The file `sympheny_connect.py` allows to connect to the MILP platform, duplicate and populate the single hub models (gas, a2w, w2w, ets) providing for each hub:
- The hourly electricity consumption for non HVAC purposes
- The hourly space heating consumption
- The hourly domestic hot water consumption
- The hourly cooling consumption
- The hourly cost of electricity (`electricity_price.xlsx`)

The PV production (`pv_unit.xlsx`) is manually sent to the MILP platform.

## Running optimization on the MILP platform

The optimization is run on the MILP platform manually. The result files (in `xlsx` format) are downloaded locally.

## Post Processing

The ipython notebook (`post_processing.ipynb`) reads the result files and writew all figures to the directory `img` as pdf files. Those files are used in the report.

Windows 11 Pro (24H2) and the following packages were used:
```
Python 3.12.7
json 2.0.9
matplotlib 3.9.2
numpy 1.26.4
pandas 2.2.3
requests 2.32.3
seaborn 0.13.2
xlsxwriter 3.1.9
```