# Model repository for Thermal Energy Network feasibility study at Joint Base Andrews

This repository contains the models and the post-processing scripts that were used for the Thermal Energy Network (TEN) feasibility study conducted for Joint Base Andrews.

The repository is organized as follows:

- `MILPResources`: Directory with input files for the techno-economic optimization (MILP optimization). See [README.md](https://github.com/lbl-srg/thermal-grid-jba/blob/main/MILPResources/README.md) for instructions.
- `PythonResources/RunCases`: Directory with scripts used for the energy and control system design and verification. These scripts automate the Modelica simulations and post-processing. See its [README.md](https://github.com/lbl-srg/thermal-grid-jba/blob/main/PythonResources/RunCases/README.md) file for instructions.
- `ThermalGridJBA`: Directory with Modelica models. See the above [README.md](https://github.com/lbl-srg/thermal-grid-jba/blob/main/PythonResources/RunCases/README.md) for how to run the models.
   The main system model is [ThermalGridJBA.Networks.Validation.DetailedPlantFiveHubs](https://github.com/lbl-srg/thermal-grid-jba/blob/main/ThermalGridJBA/Networks/Validation/DetailedPlantFiveHubs.mo)

A detailed report that documents the case study is currently being developed and expected to be released in fall 2025.

The files in this repository are released under the license posted at [license.txt](https://github.com/lbl-srg/thermal-grid-jba/blob/main/license.txt) and provided to allow others to reproduce the work or produce derivative work, such as for design of other TEN installations.
