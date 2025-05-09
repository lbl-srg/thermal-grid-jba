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
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1
    annotation (Placement(transformation(extent={{26,-70},{46,-50}})));
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

  Buildings.Controls.OBC.CDL.Reals.Hysteresis cha(uLow=hysTop, uHigh=0)
    "Outputs true if tank should be charged"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  Buildings.Controls.OBC.CDL.Reals.Hysteresis cha1(uLow=hysBot, uHigh=0)
    "Outputs true if tank should be charged"
    annotation (Placement(transformation(extent={{-10,-70},{10,-50}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub1
    annotation (Placement(transformation(extent={{-40,-70},{-20,-50}})));
  Buildings.Controls.OBC.CDL.Logical.And chaTopBot
    "Outputs true if top and bottom test wants tank to be charged. Used to override latch if tank temperature drops without triggering latch"
    annotation (Placement(transformation(extent={{30,30},{50,50}})));
  Buildings.Controls.OBC.CDL.Logical.Or or1
    "Or block to enable charge if one of the inputs request charging"
    annotation (Placement(transformation(extent={{66,16},{86,36}})));
equation
  connect(sub.y, cha.u)
    annotation (Line(points={{-18,0},{-12,0}},color={0,0,127}));
  connect(sub1.y, cha1.u)
    annotation (Line(points={{-18,-60},{-12,-60}},color={0,0,127}));
  connect(cha.y, lat.u)
    annotation (Line(points={{12,0},{38,0}}, color={255,0,255}));
  connect(cha1.y, not1.u)
    annotation (Line(points={{12,-60},{24,-60}}, color={255,0,255}));
  connect(not1.y, lat.clr) annotation (Line(points={{48,-60},{48,-32},{32,-32},
          {32,-6},{38,-6}},          color={255,0,255}));
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
  connect(cha.y, chaTopBot.u1) annotation (Line(points={{12,0},{16,0},{16,40},{
          28,40}}, color={255,0,255}));
  connect(cha1.y, chaTopBot.u2) annotation (Line(points={{12,-60},{20,-60},{20,
          32},{28,32}}, color={255,0,255}));
  connect(or1.y, charge) annotation (Line(points={{88,26},{94,26},{94,0},{120,0}},
        color={255,0,255}));
  connect(lat.y, or1.u2)
    annotation (Line(points={{62,0},{64,0},{64,18}}, color={255,0,255}));
  connect(or1.u1, chaTopBot.y) annotation (Line(points={{64,26},{58,26},{58,40},
          {52,40}}, color={255,0,255}));
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
