within ThermalGridJBA.Hubs.Controls;
block RealListParameters "List of real parameters"
  extends Modelica.Blocks.Icons.Block;
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput u annotation (Placement(
        transformation(extent={{-140,-20},{-100,20}}), iconTransformation(
          extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput y annotation (Placement(
        transformation(extent={{100,-20},{140,20}}), iconTransformation(extent={
            {100,-20},{140,20}})));
  parameter Integer n "Length of real parameters";
  parameter Real x[n] "List of real parameters";
equation
  y = x[u];
  annotation(defaultComponentName="reaLisPar");
end RealListParameters;
