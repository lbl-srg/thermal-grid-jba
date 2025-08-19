This directory contains scripts to run Modelica simulations
and post-process results.

## Running simulations
The command

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


The file `run_simulationsAndPostprocess.sh` runs all simulations and
(some) of the post-proceesing.
Note that not all post-processing is run as we skip some simulations that
were done for equipment sizing.

Which version of the repository is used is determined at the
to of the file `run_simulations.py`, and
which cases are run is determined in the file `cases.py`.


## Post Processing

The ipython notebooks (files `*.ipynb`)
write all figures to the directory `img` as pdf and png files.
They also write LaTeX snippets for the project report.

Ubuntu, the following version of matplotlib was used
```
pip freeze | grep matplotlib
matplotlib==3.5.1
```
Some older versions return an error because they do not support some plot configurations.
