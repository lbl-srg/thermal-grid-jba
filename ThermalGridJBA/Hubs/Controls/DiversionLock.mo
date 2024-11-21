within ThermalGridJBA.Hubs.Controls;
block DiversionLock
  "Locks diversion valve at closed position until incoming temperature gets close to set point"

  Modelica.Blocks.Interfaces.RealInput T(final unit="K", displayUnit="degC")
    "Incoming fluid temperature" annotation (Placement(transformation(extent={{-140,
            -20},{-100,20}}), iconTransformation(extent={{-120,-10},{-100,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput y "Valve position" annotation (
      Placement(transformation(extent={{100,-20},{140,20}}), iconTransformation(
          extent={{100,-20},{140,20}})));
  Modelica.Blocks.Interfaces.RealInput u(final unit="1")
    "Diversion valve position signal" annotation (Placement(transformation(
          extent={{-140,40},{-100,80}}), iconTransformation(extent={{-120,50},{
            -100,70}})));
  Modelica.Blocks.Interfaces.RealInput TSet(final unit="K", displayUnit="degC")
    "Set point temperature" annotation (Placement(transformation(extent={{-140,-80},
            {-100,-40}}), iconTransformation(extent={{-120,-70},{-100,-50}})));

  Buildings.Controls.OBC.CDL.Reals.Hysteresis hys(
    uLow=-5,
    uHigh=-2,
    y(start=false))
    annotation (Placement(transformation(extent={{-40,-40},{-20,-20}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(final k=0) "Zero"
    annotation (Placement(transformation(extent={{-40,-100},{-20,-80}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    annotation (Placement(transformation(extent={{-80,-40},{-60,-20}})));
equation
  connect(swi.u1, u) annotation (Line(points={{58,8},{50,8},{50,60},{-120,60}},
        color={0,0,127}));
  connect(swi.y, y) annotation (Line(points={{82,0},{120,0}}, color={0,0,127}));
  connect(T, sub.u1) annotation (Line(points={{-120,0},{-90,0},{-90,-24},{-82,-24}},
        color={0,0,127}));
  connect(TSet, sub.u2) annotation (Line(points={{-120,-60},{-90,-60},{-90,-36},
          {-82,-36}}, color={0,0,127}));
  connect(sub.y, hys.u)
    annotation (Line(points={{-58,-30},{-42,-30}}, color={0,0,127}));
  connect(hys.y, swi.u2) annotation (Line(points={{-18,-30},{0,-30},{0,0},{58,0}},
        color={255,0,255}));
  connect(zer.y, swi.u3) annotation (Line(points={{-18,-90},{50,-90},{50,-8},{
          58,-8}},
                color={0,0,127}));
  annotation (
  defaultComponentName="locDiv",
  Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Text(
          textColor={0,0,255},
          extent={{-150,110},{150,150}},
          textString="%name"),
        Text(
          extent={{-108,18},{-58,-18}},
          textColor={0,0,127},
          textString="T"),
        Text(
          extent={{52,22},{102,-14}},
          textColor={0,0,127},
          textString="set"),
        Text(
          extent={{-98,80},{-48,44}},
          textColor={0,0,127},
          textString="pre"),
        Text(
          extent={{-92,-42},{-42,-78}},
          textColor={0,0,127},
          textString="TSet")}),
          Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p>
The block resets the diversion valve control signal to zero unless
the incoming temperature is close enough to the set point.
</p>
</html>"));
end DiversionLock;
