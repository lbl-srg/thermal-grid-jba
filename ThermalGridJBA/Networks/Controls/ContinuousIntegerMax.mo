within ThermalGridJBA.Networks.Controls;
block ContinuousIntegerMax
  "Find the maximum value of the integer input over time"
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput active
    "Set to true to find the continuous maximum of the integer input"
    annotation (Placement(transformation(extent={{-140,-100},{-100,-60}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput u "Integer input"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput y
    "Maximum over time"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),
        iconTransformation(extent={{100,-20},{140,20}})));
initial equation
  pre(y)=u;

equation
  if active then
    y=max(u, pre(y));
  else
    y=u;
  end if;


annotation (defaultComponentName="conIntMax",
  Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,0},
          lineThickness=5.0,
          fillColor={255,213,170},
          fillPattern=FillPattern.Solid,
          borderPattern=BorderPattern.Raised),
        Text(
          extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),                                Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end ContinuousIntegerMax;
