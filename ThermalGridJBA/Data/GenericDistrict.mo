within ThermalGridJBA.Data;
record GenericDistrict "District network design parameters"
  extends Modelica.Icons.Record;
  parameter Integer nBui
    "Number of served buildings"
    annotation(Evaluate=true);
  parameter String filNam[nBui]
    "Library paths of the files with thermal loads as time series";
  parameter Modelica.Units.SI.MassFlowRate mPumDis_flow_nominal=
    sum(mCon_flow_nominal)
    "Nominal mass flow rate of main distribution pump";
  parameter Modelica.Units.SI.MassFlowRate mPipDis_flow_nominal=
      mPumDis_flow_nominal "Nominal mass flow rate for main pipe sizing";
  parameter Modelica.Units.SI.MassFlowRate mCon_flow_nominal[nBui]
    "Nominal mass flow rate in each connection line";
  parameter Modelica.Units.SI.Temperature TLooMin=273.15 + 10.5
    "Minimum loop temperature";
  parameter Modelica.Units.SI.Temperature TLooMax=273.15 + 24
    "Maximum loop temperature";
  parameter Real dp_length_nominal(final unit="Pa/m") = 250
    "Pressure drop per pipe length at nominal flow rate";
  parameter Modelica.Units.SI.Length lDis[nBui+1]=fill(100, nBui+1)
    "Length of distribution pipe, from plant to each building back to plant";
  parameter Modelica.Units.SI.Length lCon[nBui]=fill(10, nBui)
    "Length of each connection pipe (supply only, not counting return line)";
  annotation (
    defaultComponentName="datDis",
    defaultComponentPrefixes="inner",
    Documentation(info="<html>
<p>
This record contains parameter declarations of a district system.
</html>"));
end GenericDistrict;
