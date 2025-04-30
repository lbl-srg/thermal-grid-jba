within ThermalGridJBA.Networks.Controls;
block TrueFalseDelay "Delay the rising and falling edge of the input"

  parameter Real delayTrueTime(
    final quantity="Time",
    final unit="s")
    "Delay true time";
  parameter Real delayFalseTime(
    final quantity="Time",
    final unit="s")
    "Delay false time";
  parameter Boolean delayOnInit=false
    "Set to true to delay initial true input";

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u
    "Input signal to be delayed when it switches to false"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y
    "Output with delayed input signal after it switched to false"
    annotation (Placement(transformation(extent={{100,40},{140,80}}),
        iconTransformation(extent={{100,-20},{140,20}})));

  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel(final delayTime=
        delayTrueTime,
    final delayOnInit=delayOnInit) "True delay"
    annotation (Placement(transformation(extent={{0,50},{20,70}})));
  FalseDelay falDel(delayTime=delayFalseTime,
                    final delayOnInit=delayOnInit) "False daley"
    annotation (Placement(transformation(extent={{-80,-70},{-60,-50}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger booToInt
    "Boolean to integer"
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  Buildings.Controls.OBC.CDL.Integers.Equal intEqu "Equal integer inputs"
    annotation (Placement(transformation(extent={{0,-10},{20,10}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1 "Logical not"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger booToInt1
    "Boolean to integer"
    annotation (Placement(transformation(extent={{-40,-70},{-20,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Or delTruFal "True and false delay"
    annotation (Placement(transformation(extent={{60,50},{80,70}})));

equation
  connect(delTruFal.y, y)
    annotation (Line(points={{82,60},{120,60}}, color={255,0,255}));
  connect(u, booToInt.u)
    annotation (Line(points={{-120,0},{-82,0}}, color={255,0,255}));
  connect(u, truDel.u) annotation (Line(points={{-120,0},{-90,0},{-90,60},{-2,60}},
        color={255,0,255}));
  connect(u, falDel.u) annotation (Line(points={{-120,0},{-90,0},{-90,-60},{-82,
          -60}}, color={255,0,255}));
  connect(falDel.y, booToInt1.u)
    annotation (Line(points={{-58,-60},{-42,-60}}, color={255,0,255}));
  connect(booToInt.y, intEqu.u1)
    annotation (Line(points={{-58,0},{-2,0}}, color={255,127,0}));
  connect(booToInt1.y, intEqu.u2) annotation (Line(points={{-18,-60},{-10,-60},{
          -10,-8},{-2,-8}}, color={255,127,0}));
  connect(intEqu.y, not1.u)
    annotation (Line(points={{22,0},{38,0}}, color={255,0,255}));
  connect(truDel.y, delTruFal.u1)
    annotation (Line(points={{22,60},{58,60}}, color={255,0,255}));
  connect(not1.y, delTruFal.u2) annotation (Line(points={{62,0},{70,0},{70,40},
          {50,40},{50,52},{58,52}}, color={255,0,255}));
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
          textString="%delayFalseTime"),
        Line(
          points={{-80,-66},{-60,-66},{-60,-22},{20,-22},{20,-66},{66,-66}}),
        Line(
          points={{-80,32},{-40,32},{-40,78},{40,78},{40,32},{66,32}},
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
end TrueFalseDelay;
