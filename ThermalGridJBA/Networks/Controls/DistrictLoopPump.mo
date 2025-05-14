within ThermalGridJBA.Networks.Controls;
model DistrictLoopPump
  "Sequence for the control of district loop pump"
  parameter Real TUpp(
    unit="K",
    displayUnit="degC")=273.15 + 24
    "Upper bound temperature";
  parameter Real TLow(
    unit="K",
    displayUnit="degC")=273.15 + 10.5
    "Lower bound temperature";
  parameter Real dTSlo(
    unit="K",
    displayUnit="K")=2
    "Temperature deadband for changing pump speed";
  parameter Real yMin(unit="1")=0.1
    "Minimum pump speed";

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
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDisPum(
    final unit="1",
    final max=1,
    final min=0)
    "District pump speed"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),
      iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Reals.Line incSpe
    "Increase the pump speed from the minium to the maximum"
    annotation (Placement(transformation(extent={{20,50},{40,70}})));
  Buildings.Controls.OBC.CDL.Reals.Max pumSpe
    "Pump speed"
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minSpe(
    final k=yMin)
    "Minimum pump speed"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant maxSpe(
    final k=1)
    "Maximum pump speed"
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Buildings.Controls.OBC.CDL.Reals.Line decSpe
    "Decrease pump speed from the maximum to the minimum"
    annotation (Placement(transformation(extent={{20,-70},{40,-50}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant uppSta(
    y(unit="K",displayUnit="degC"),
    final k=TUpp - dTSlo)
    "Start point to increase pump speed when near upper bound temperature "
    annotation (Placement(transformation(extent={{-60,70},{-40,90}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant uppEnd(
    y(unit="K",displayUnit="degC"),
    final k=TUpp)
    "Upper bound temperature. The pump speed should be maximum"
    annotation (Placement(transformation(extent={{-60,30},{-40,50}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant lowSta(
    y(unit="K",displayUnit="degC"),
    final k=TLow)
    "Lower bound temperature. The pump speed should be maximum"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant lowEnd(
    y(unit="K",displayUnit="degC"),
    final k=TLow + dTSlo)
    "End point when it is far away from the lower bound temperature"
    annotation (Placement(transformation(extent={{-60,-90},{-40,-70}})));

equation
  connect(minSpe.y, incSpe.f1) annotation (Line(points={{-38,0},{-30,0},{-30,64},
          {18,64}}, color={0,0,127}));
  connect(maxSpe.y, incSpe.f2)
    annotation (Line(points={{2,0},{10,0},{10,52},{18,52}}, color={0,0,127}));
  connect(minSpe.y,decSpe. f2) annotation (Line(points={{-38,0},{-30,0},{-30,-68},
          {18,-68}}, color={0,0,127}));
  connect(maxSpe.y,decSpe. f1) annotation (Line(points={{2,0},{10,0},{10,-56},{18,
          -56}}, color={0,0,127}));
  connect(TMixMin,decSpe. u)
    annotation (Line(points={{-120,-60},{18,-60}}, color={0,0,127}));
  connect(TMixMax, incSpe.u)
    annotation (Line(points={{-120,60},{18,60}}, color={0,0,127}));
  connect(incSpe.y, pumSpe.u1)
    annotation (Line(points={{42,60},{50,60},{50,6},{58,6}}, color={0,0,127}));
  connect(decSpe.y, pumSpe.u2) annotation (Line(points={{42,-60},{50,-60},{50,-6},
          {58,-6}}, color={0,0,127}));
  connect(uppSta.y, incSpe.x1) annotation (Line(points={{-38,80},{0,80},{0,68},{
          18,68}}, color={0,0,127}));
  connect(uppEnd.y, incSpe.x2) annotation (Line(points={{-38,40},{0,40},{0,56},{
          18,56}}, color={0,0,127}));
  connect(lowSta.y,decSpe. x1) annotation (Line(points={{-38,-40},{0,-40},{0,-52},
          {18,-52}}, color={0,0,127}));
  connect(lowEnd.y,decSpe. x2) annotation (Line(points={{-38,-80},{0,-80},{0,-64},
          {18,-64}}, color={0,0,127}));
  connect(pumSpe.y, yDisPum)
    annotation (Line(points={{82,0},{120,0}}, color={0,0,127}));
annotation (defaultComponentName="looPumSpe",
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
end DistrictLoopPump;
