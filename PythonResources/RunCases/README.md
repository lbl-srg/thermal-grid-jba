This directory contains scripts to run Modelica simulations
and post-process results.

## Running Modelica simulations and post-processing its results

To install the Python virtual environment that runs all simulations and post-processes the results,
use the file `requirements.txt` to set up a virtual environment as
```
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

The run all simulations and post-processes the results, use
```
export MODELICAPATH=/usr/local/modelica
nohub ./run_simulationsAndPostprocess.sh &
```
The `export MODELICAPATH` command sets the path to the Modelica libraries
and sets it to a directory that contains the libraries

- [Buildings](https://simulationresearch.lbl.gov/modelica), version 12.1.0
- [Modelica_Requirements](https://github.com/modelica-3rdparty/Modelica_Requirements), version 0.7
- [Buildings_Requirements](https://github.com/lbl-srg/modelica-buildings-requirements), commit [57eca51](https://github.com/lbl-srg/modelica-buildings-requirements/commit/57eca5186599c82c04a22e431e3b5dacb2cff933).

Also used is Modelica 4.0 which is distributed with Dymola 2025x.

The post-processing writes all figures to the directory `img` as pdf and png files.
It also also writes LaTeX snippets for the project report.

Which version of the repository is used is determined at the
top of the file `run_simulations.py`, and
which cases are run is determined in the file `cases.py`.

The results of the simulations will be stored in `simulations`,
with a directory for each case. For example,
`simulations/base` will contain the results of the base case.
These results are not version controlled as they full output files are too large.

The results of the post-processing will be stored in the `img`.
