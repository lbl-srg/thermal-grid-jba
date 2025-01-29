within ThermalGridJBA.Hubs.Controls;
block TankChargingController
  "Controller to enable or disable storage tank charging"

  parameter Real hysTop = -5 "Hysteresis for tank top";
  parameter Real hysBot = -5 "Hysteresis for tank bottom";
  parameter Boolean isHotWat
    "True if the tank supplies hot water, False for chilled water";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TTanTop(
    final unit="K",
    displayUnit="degC") "Measured temperature at top of tank"
                                          annotation (Placement(transformation(
          extent={{-140,-20},{-100,20}}),  iconTransformation(extent={{-140,-20},
            {-100,20}})));
  Modelica.Blocks.Interfaces.RealInput TTanSet(
    final unit="K",
    displayUnit="degC")
    "Tank temperature set point, top for hot tank and bottom for cold tank"
    annotation (Placement(transformation(extent={{-140,50},{-100,90}}),
        iconTransformation(extent={{-120,70},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput charge
    "Outputs true if tank should be charged" annotation (Placement(
        transformation(extent={{100,-20},{140,20}}), iconTransformation(extent=
            {{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TTanBot(final unit="K", displayUnit=
        "degC") "Measured temperature at bottom of tank" annotation (Placement(
        transformation(extent={{-140,-120},{-100,-80}}), iconTransformation(
          extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Logical.Latch lat
    annotation (Placement(transformation(extent={{50,-10},{70,10}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1
    annotation (Placement(transformation(extent={{30,-70},{50,-50}})));
block Routing
  extends Modelica.Blocks.Icons.Block;

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TTop_in(
    final unit="K",
    displayUnit="degC") "Tank top temperature" annotation (Placement(
        transformation(extent={{-140,-20},{-100,20}}), iconTransformation(
          extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TBot_in(
    final unit="K",
    displayUnit="degC") "Tank bottom temperature" annotation (Placement(
        transformation(extent={{-140,-80},{-100,-40}}), iconTransformation(
          extent={{-140,-80},{-100,-40}})));
  Modelica.Blocks.Interfaces.RealOutput TTop_out(
    final unit="K",
    displayUnit="degC")
    "Tank top temperature" annotation (Placement(transformation(extent={{100,-20},
            {140,20}}), iconTransformation(extent={{100,-10},{120,10}})));
  Modelica.Blocks.Interfaces.RealOutput TBot_out(
    final unit="K",
    displayUnit="degC")
    "Tank bottom temperature" annotation (Placement(transformation(extent={{100,
            -80},{140,-40}}), iconTransformation(extent={{100,-70},{120,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSet_in(
    final unit="K",
    displayUnit="degC") "Tank temperature set point" annotation (Placement(
        transformation(extent={{-140,40},{-100,80}}), iconTransformation(extent={{-140,40},
              {-100,80}})));
  Modelica.Blocks.Interfaces.RealOutput TSet_out(
    final unit="K",
    displayUnit="degC")
    "Tank temperature set point" annotation (Placement(transformation(extent={{100,
            40},{140,80}}), iconTransformation(extent={{100,50},{120,70}})));
equation

  connect(TSet_in, TSet_out)
    annotation (Line(points={{-120,60},{120,60}}, color={0,0,127}));
  connect(TTop_in, TTop_out)
    annotation (Line(points={{-120,0},{120,0}}, color={0,0,127}));
  connect(TBot_in, TBot_out)
    annotation (Line(points={{-120,-60},{120,-60}}, color={0,0,127}));
end Routing;
  Routing rouHot if isHotWat "Routing block for hot tank"
    annotation (Placement(transformation(extent={{-80,20},{-60,40}})));
  Routing rouCol if not isHotWat "Routing block for cold tank"
    annotation (Placement(transformation(extent={{-80,-60},{-60,-40}})));
protected
  Buildings.Controls.OBC.CDL.Reals.Hysteresis cha(uLow=hysTop, uHigh=0)
    "Outputs true if tank should be charged"
    annotation (Placement(transformation(extent={{0,-10},{20,10}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  Buildings.Controls.OBC.CDL.Reals.Hysteresis cha1(uLow=hysBot, uHigh=0)
    "Outputs true if tank should be charged"
    annotation (Placement(transformation(extent={{0,-70},{20,-50}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub1
    annotation (Placement(transformation(extent={{-40,-70},{-20,-50}})));
equation
  connect(sub.y, cha.u)
    annotation (Line(points={{-18,0},{-2,0}}, color={0,0,127}));
  connect(sub1.y, cha1.u)
    annotation (Line(points={{-18,-60},{-2,-60}}, color={0,0,127}));
  connect(cha.y, lat.u)
    annotation (Line(points={{22,0},{48,0}}, color={255,0,255}));
  connect(lat.y, charge)
    annotation (Line(points={{72,0},{120,0}}, color={255,0,255}));
  connect(cha1.y, not1.u)
    annotation (Line(points={{22,-60},{28,-60}}, color={255,0,255}));
  connect(not1.y, lat.clr) annotation (Line(points={{52,-60},{60,-60},{60,-34},
          {40,-34},{40,-6},{48,-6}}, color={255,0,255}));
  connect(TTanSet, rouHot.TSet_in) annotation (Line(points={{-120,70},{-90,70},
          {-90,36},{-82,36}}, color={0,0,127}));
  connect(TTanSet, rouCol.TSet_in) annotation (Line(points={{-120,70},{-90,70},
          {-90,-44},{-82,-44}}, color={0,0,127}));
  connect(TTanTop, rouHot.TTop_in) annotation (Line(points={{-120,0},{-92,0},{
          -92,30},{-82,30}}, color={0,0,127}));
  connect(TTanTop, rouCol.TTop_in) annotation (Line(points={{-120,0},{-92,0},{
          -92,-50},{-82,-50}}, color={0,0,127}));
  connect(TTanBot, rouHot.TBot_in) annotation (Line(points={{-120,-100},{-94,
          -100},{-94,24},{-82,24}}, color={0,0,127}));
  connect(TTanBot, rouCol.TBot_in) annotation (Line(points={{-120,-100},{-94,
          -100},{-94,-56},{-82,-56}}, color={0,0,127}));
  connect(rouHot.TSet_out, sub.u1) annotation (Line(points={{-59,36},{-48,36},{
          -48,6},{-42,6}}, color={0,0,127}));
  connect(rouHot.TTop_out, sub.u2) annotation (Line(points={{-59,30},{-52,30},{
          -52,-6},{-42,-6}}, color={0,0,127}));
  connect(rouHot.TSet_out, sub1.u1) annotation (Line(points={{-59,36},{-48,36},
          {-48,-54},{-42,-54}}, color={0,0,127}));
  connect(rouHot.TBot_out, sub1.u2) annotation (Line(points={{-59,24},{-54,24},
          {-54,-66},{-42,-66}}, color={0,0,127}));
  connect(rouCol.TBot_out, sub.u1) annotation (Line(points={{-59,-56},{-46,-56},
          {-46,6},{-42,6}}, color={0,0,127}));
  connect(rouCol.TSet_out, sub.u2) annotation (Line(points={{-59,-44},{-52,-44},
          {-52,-6},{-42,-6}}, color={0,0,127}));
  connect(rouCol.TTop_out, sub1.u1) annotation (Line(points={{-59,-50},{-48,-50},
          {-48,-54},{-42,-54}}, color={0,0,127}));
  connect(rouCol.TSet_out, sub1.u2) annotation (Line(points={{-59,-44},{-54,-44},
          {-54,-66},{-42,-66}}, color={0,0,127}));
  annotation (
  defaultComponentName="tanCha",
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
          extent={{-96,98},{-46,62}},
          textColor={0,0,127},
          textString="TTanTopSet"),
        Text(
          extent={{-96,18},{-46,-18}},
          textColor={0,0,127},
          textString="TTanTop"),
        Text(
          extent={{42,20},{92,-16}},
          textColor={0,0,127},
          textString="charge"),
        Text(
          extent={{-96,-62},{-46,-98}},
          textColor={0,0,127},
          textString="TTanBot")}),
     Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
November 15, 2023, by David Blum:<br/>
Add that charging is stopped when bottom temperature reaches set point.
</li>
<li>
October 4, 2023, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
Adapted fromBuildings.DHC.Loads.HotWater.BaseClasses.TankChargingController.

</p>
<ul>
<li>
The hysteresis parameters are exposed.
</li>
<li>
Added a routing block so that it could be applied to both
hot and cold tanks, i.e. either the top or bottom of the tank
could be the supply side or the return side.
</li>
</ul>
</html>"));
end TankChargingController;
