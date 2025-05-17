within ThermalGridJBA.Data;
record MilpData "Parameters for the modular expandable chiller"
extends Modelica.Icons.Record;
  parameter Real ECos = 42661747
    "Energy cost, result from MILP";
  parameter Modelica.Units.SI.Energy EImp( displayUnit="kWh")= 17895619
    "Energy import, result from MILP";


end MilpData;
