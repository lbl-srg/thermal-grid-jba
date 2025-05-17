within ThermalGridJBA.Networks.Controls;
model ActualOvershot "Actual overshot temperature"
  parameter Real TLooMax(
    unit="K",
    displayUnit="degC")=273.15 + 24
    "Maximum design loop temperature";
  parameter Real TLooMin(
    unit="K",
    displayUnit="degC")=273.15 + 10.5
    "Minimum design loop temperature";
  parameter Real TDisPumUpp(
    unit="K",
    displayUnit="degC")=TLooMax-2
    "Upper bound temperature for district pump control";
  parameter Real TDisPumLow(
    unit="K",
    displayUnit="degC")=TLooMin+2
    "Lower bound temperature for district pump control";
  parameter Real dTOveShoMax(
    unit="K",
    displayUnit="K")=2
    "Maximum temperature difference to allow for control over or undershoot. dTOveShoMax >= 0";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixMax(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC")
    "Maximum measured mixing temperatures"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixMin(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC")
    "Minimum measured mixing temperatures"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput dTActOveSho(
    final unit="K",
    quantity="TemperatureDifference")
    "Actual overshot temperature"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Reals.Line incOve
    "Increase the overshot from the minium to the maximum"
    annotation (Placement(transformation(extent={{20,50},{40,70}})));
  Buildings.Controls.OBC.CDL.Reals.Max oveSho
    "Actual overshot"
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minOveSho(
    final k=0)
    "Minimum overshot"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant maxOveSho(
    final k=dTOveShoMax)
    "Maximum overshot"
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Buildings.Controls.OBC.CDL.Reals.Line decOve
    "Decrease the overshot from the maximum to the minimum"
    annotation (Placement(transformation(extent={{20,-70},{40,-50}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant uppSta(
    y(unit="K",displayUnit="degC"), final k=TDisPumUpp)
    "Start point to increase overshot when near upper bound temperature "
    annotation (Placement(transformation(extent={{-60,70},{-40,90}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant uppEnd(
    y(unit="K",displayUnit="degC"),
    final k=TLooMax)
    "End point to increase overshot when near loop maximum design temperature"
    annotation (Placement(transformation(extent={{-60,30},{-40,50}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant lowSta(
    y(unit="K",displayUnit="degC"),
    final k=TLooMin)
    "Start point to decrease overshot when near loop minimum design temperature"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant lowEnd(
    y(unit="K",displayUnit="degC"), final k=TDisPumLow)
    "End point when it is far away from the lower bound temperature"
    annotation (Placement(transformation(extent={{-60,-90},{-40,-70}})));

equation
  connect(minOveSho.y, incOve.f1) annotation (Line(points={{-38,0},{-30,0},{-30,
          64},{18,64}}, color={0,0,127}));
  connect(maxOveSho.y, incOve.f2)
    annotation (Line(points={{2,0},{10,0},{10,52},{18,52}}, color={0,0,127}));
  connect(minOveSho.y, decOve.f2) annotation (Line(points={{-38,0},{-30,0},{-30,
          -68},{18,-68}}, color={0,0,127}));
  connect(maxOveSho.y, decOve.f1) annotation (Line(points={{2,0},{10,0},{10,-56},
          {18,-56}}, color={0,0,127}));
  connect(TMixMin,decOve. u)
    annotation (Line(points={{-120,-60},{18,-60}}, color={0,0,127}));
  connect(TMixMax,incOve. u)
    annotation (Line(points={{-120,60},{18,60}}, color={0,0,127}));
  connect(incOve.y,oveSho. u1)
    annotation (Line(points={{42,60},{50,60},{50,6},{58,6}}, color={0,0,127}));
  connect(decOve.y,oveSho. u2) annotation (Line(points={{42,-60},{50,-60},{50,-6},
          {58,-6}}, color={0,0,127}));
  connect(uppSta.y,incOve. x1) annotation (Line(points={{-38,80},{0,80},{0,68},{
          18,68}}, color={0,0,127}));
  connect(uppEnd.y,incOve. x2) annotation (Line(points={{-38,40},{0,40},{0,56},{
          18,56}}, color={0,0,127}));
  connect(lowSta.y,decOve. x1) annotation (Line(points={{-38,-40},{0,-40},{0,-52},
          {18,-52}}, color={0,0,127}));
  connect(lowEnd.y,decOve. x2) annotation (Line(points={{-38,-80},{0,-80},{0,-64},
          {18,-64}}, color={0,0,127}));
  connect(oveSho.y, dTActOveSho)
    annotation (Line(points={{82,0},{120,0}}, color={0,0,127}));
annotation (defaultComponentName="actOveSho",
  Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                                Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}), Diagram(coordinateSystem(preserveAspectRatio=false)),
Documentation(info="
<html>
<p>
It resets the district loop pump speed as the plot below.
</p>
<p align=\"center\">
<img src=\"modelica://ThermalGridJBA/Resources/Images/Networks/Controls/districtPumpControl.png\"
     alt=\"districtPumpControl.png\" />
</p>
<p>
In the plot, the <code>TLow</code> and <code>TUpp</code> are the lower and upper
bound temperature setpoints. The <code>dTSlo</code> is the temperature difference
for lineary adjusting the pump speed.
</p>
</html>", revisions="<html>
<ul>
<li>
January 31, 2025, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"));
end ActualOvershot;
