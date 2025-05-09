within ThermalGridJBA.Networks.Controls;
block FalseDelay "Delay a falling edge of the input, but do not delay a rising edge"

  parameter Real delayTime(
    final quantity="Time",
    final unit="s")
    "Delay time";
  parameter Boolean delayOnInit=false
    "Set to true to delay initial true input";

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u
    "Input signal to be delayed when it switches to false"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y
    "Output with delayed input signal after it switched to false"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),
        iconTransformation(extent={{100,-20},{140,20}})));

  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel(
    final delayTime=delayTime,
    final delayOnInit=delayOnInit)
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  Buildings.Controls.OBC.CDL.Logical.Not not2
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));

equation
  connect(u, not1.u)
    annotation (Line(points={{-120,0},{-82,0}}, color={255,0,255}));
  connect(not1.y, truDel.u)
    annotation (Line(points={{-58,0},{-22,0}}, color={255,0,255}));
  connect(truDel.y, not2.u)
    annotation (Line(points={{2,0},{38,0}}, color={255,0,255}));
  connect(not2.y, y) annotation (Line(points={{62,0},{80,0},{80,0},{120,0}},
        color={255,0,255}));

annotation (defaultComponentName="falDel",
Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          fillColor={210,210,210},
          lineThickness=5.0,
          fillPattern=FillPattern.Solid,
          borderPattern=BorderPattern.Raised),
        Text(
          extent={{-250,-120},{250,-150}},
          textColor={0,0,0},
          textString="%delayTime"),
        Line(
          points={{-80,-66},{-60,-66},{-60,-22},{20,-22},{20,-66},{66,-66}}),
        Line(
          points={{-80,32},{-60,32},{-60,78},{40,78},{40,32},{66,32}},
          color={255,0,255}),
        Ellipse(
          extent={{-71,7},{-85,-7}},
          lineColor=DynamicSelect({235,235,235},
            if u then
              {0,255,0}
            else
              {235,235,235}),
          fillColor=DynamicSelect({235,235,235},
            if u then
              {0,255,0}
            else
              {235,235,235}),
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{71,7},{85,-7}},
          lineColor=DynamicSelect({235,235,235},
            if y then
              {0,255,0}
            else
              {235,235,235}),
          fillColor=DynamicSelect({235,235,235},
            if y then
              {0,255,0}
            else
              {235,235,235}),
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-150,150},{150,110}},
          textColor={0,0,255},
          textString="%name")}),                   Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end FalseDelay;
