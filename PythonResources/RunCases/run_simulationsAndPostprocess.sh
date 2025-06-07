#!/bin/bash
#
# Bash file to run simulations and postprocess results.
#
########################################
# Set path to Modelica libraries
set -e
export MODELICAPATH=/usr/local/modelica
# Run simulations.
# See top lines of this file for what version is run.
python run_simulations.py
# Create summary of log files
for ff in `find . -name dslog.txt`; do echo "========================"; echo "===== $ff"; tail -n 50 $ff; done > summary.txt
# Postprocess results
# This will also create plots and tables in the img folder
rm -rf img
posProFil="post_process_system post_process_borefield_histogram"
for pos in $posProFil; do
    echo "Post processing ${pos}"
    jupyter nbconvert --execute --to notebook --inplace ${pos}.ipynb
done
