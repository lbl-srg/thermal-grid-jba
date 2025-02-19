within ThermalGridJBA.Hubs.Controls;
model Chiller "Chiller controller"

  parameter Real TConWatEntMin(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Minimum value of condenser water entering temperature";
  parameter Real TEvaWatEntMax(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Maximum value of evaporator water entering temperature";
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uCoo
    "Cooling enable signal"
    annotation (Placement(transformation(extent={{-200,40},{-160,80}}),
    iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uHea
    "Heating enable signal"
    annotation (Placement(transformation(extent={{-200,80},{-160,120}}),
    iconTransformation(extent={{-140,80},{-100,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TConWatEnt(
    final unit="K",
    displayUnit="degC") "Condenser water entering temperature"
    annotation (Placement(transformation(extent={{-200,-120},{-160,-80}}),
    iconTransformation(extent={{-140,-120},{-100,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TEvaWatEnt(
    final unit="K",
    displayUnit="degC") "Evaporator water entering temperature"
    annotation (Placement(transformation(extent={{-200,-80},{-160,-40}}),
    iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValCon
    "Condenser mixing valve control signal"
    annotation (Placement(transformation(extent={{160,-100},{200,-60}}),
    iconTransformation(extent={{100,-80},{140,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValEva
    "Evaporator mixing valve control signal"
    annotation (Placement(transformation(extent={{160,-40},{200,0}}),
    iconTransformation(extent={{100,-40},{140,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput yPum
    "Primary pump enable signal"
    annotation (Placement(transformation(extent={{160,60},{200,100}}),
    iconTransformation(extent={{100,40},{140,80}})));
  Buildings.Controls.OBC.CDL.Logical.Or heaOrCoo
    "Heating or cooling enabled"
    annotation (Placement(transformation(extent={{-120,70},{-100,90}})));
  Buildings.DHC.ETS.Combined.Controls.PIDWithEnable conValEva(
    final controllerType=Modelica.Blocks.Types.SimpleController.PI,
    final yMax=1,
    final yMin=0,
    y_reset=0,
    k=0.1,
    Ti(
      displayUnit="s")=60,
    final reverseActing=true) "Evaporator three-way valve control"
    annotation (Placement(transformation(extent={{50,-30},{70,-10}})));
  Buildings.DHC.ETS.Combined.Controls.PIDWithEnable conValCon(
    final controllerType=Modelica.Blocks.Types.SimpleController.PI,
    final yMax=1,
    final yMin=0,
    y_reset=0,
    k=0.1,
    Ti(
      displayUnit="s")=60,
    final reverseActing=false)
    "Condenser three-way valve control"
    annotation (Placement(transformation(extent={{50,-90},{70,-70}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant maxTEvaWatEnt(
    y(final unit="K",
      displayUnit="degC"),
    final k=TEvaWatEntMax)
    "Maximum value of evaporator water entering temperature"
    annotation (Placement(transformation(extent={{-10,-30},{10,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minTConWatEnt(
    y(final unit="K",
      displayUnit="degC"),
    final k=TConWatEntMin)
    "Minimum value of condenser water entering temperature"
    annotation (Placement(transformation(extent={{-10,-90},{10,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TEvaWatLvg(final unit="K",
      displayUnit="degC") "Evaporator water leaving temperature" annotation (
      Placement(transformation(extent={{-200,-40},{-160,0}}),
        iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TChiWatSupSet(final unit="K",
      displayUnit="degC") "Set point temperature for chilled water" annotation
    (Placement(transformation(extent={{-200,0},{-160,40}}), iconTransformation(
          extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yChi
    "Chiller compressor speed control signal" annotation (Placement(
        transformation(extent={{160,20},{200,60}}), iconTransformation(extent={
            {100,0},{140,40}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(y(final unit="K",
        displayUnit="degC"), final k=0) "Zero"
    annotation (Placement(transformation(extent={{-10,30},{10,50}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    annotation (Placement(transformation(extent={{-120,-10},{-100,10}})));
  Buildings.DHC.ETS.Combined.Controls.PIDWithEnable conChi(
    final controllerType=Modelica.Blocks.Types.SimpleController.PI,
    final yMax=1,
    final yMin=0,
    y_reset=0,
    Ti(displayUnit="s"),
    final reverseActing=true) "Chiller compressor speed control"
    annotation (Placement(transformation(extent={{50,30},{70,50}})));
equation
  connect(TEvaWatEnt,conValEva.u_m)
    annotation (Line(points={{-180,-60},{60,-60},{60,-32}},color={0,0,127}));
  connect(TConWatEnt,conValCon.u_m)
    annotation (Line(points={{-180,-100},{-60,-100},{-60,-110},{60,-110},{60,
          -92}},                                           color={0,0,127}));
  connect(heaOrCoo.y,yPum)
    annotation (Line(points={{-98,80},{180,80}},color={255,0,255}));
  connect(uHea,heaOrCoo.u1)
    annotation (Line(points={{-180,100},{-140,100},{-140,80},{-122,80}},
                                                                      color={255,0,255}));
  connect(uCoo,heaOrCoo.u2)
    annotation (Line(points={{-180,60},{-140,60},{-140,72},{-122,72}},color={255,0,255}));
  connect(maxTEvaWatEnt.y,conValEva.u_s)
    annotation (Line(points={{12,-20},{48,-20}},
                                            color={0,0,127}));
  connect(minTConWatEnt.y,conValCon.u_s)
    annotation (Line(points={{12,-80},{48,-80}},color={0,0,127}));
  connect(conValEva.y,yValEva)
    annotation (Line(points={{72,-20},{180,-20}},
                                             color={0,0,127}));
  connect(heaOrCoo.y,conValEva.uEna)
    annotation (Line(points={{-98,80},{-40,80},{-40,-40},{56,-40},{56,-32}},color={255,0,255}));
  connect(heaOrCoo.y,conValCon.uEna)
    annotation (Line(points={{-98,80},{-40,80},{-40,-100},{56,-100},{56,-92}},
                                                                            color={255,0,255}));
  connect(conValCon.y,yValCon)
    annotation (Line(points={{72,-80},{180,-80}},color={0,0,127}));
  connect(TChiWatSupSet, sub.u1) annotation (Line(points={{-180,20},{-140,20},{
          -140,6},{-122,6}}, color={0,0,127}));
  connect(sub.u2, TEvaWatLvg) annotation (Line(points={{-122,-6},{-140,-6},{
          -140,-20},{-180,-20}}, color={0,0,127}));
  connect(conChi.y, yChi)
    annotation (Line(points={{72,40},{180,40}}, color={0,0,127}));
  connect(zer.y, conChi.u_s)
    annotation (Line(points={{12,40},{48,40}}, color={0,0,127}));
  connect(sub.y, conChi.u_m)
    annotation (Line(points={{-98,0},{60,0},{60,28}}, color={0,0,127}));
  connect(heaOrCoo.y, conChi.uEna) annotation (Line(points={{-98,80},{-40,80},{
          -40,18},{56,18},{56,28}}, color={255,0,255}));
  annotation (
    Icon(
      coordinateSystem(
        preserveAspectRatio=false,
        extent={{-100,-100},{100,100}}), graphics={
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Text(
          textColor={0,0,255},
          extent={{-100,100},{102,140}},
          textString="%name")}),
    Diagram(
      coordinateSystem(
        preserveAspectRatio=false,
        extent={{-160,-120},{160,120}})),
    defaultComponentName="con",
    Documentation(
      revisions="<html>
<ul>
<li>
July 31, 2020, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>",
      info="<html>
<p>
This is a controller for the chiller system, which includes the dedicated
condenser and evaporator pumps.
</p>
<p>
The system is enabled if any of the input control signals <code>uHea</code>
or <code>uCoo</code> is <code>true</code>.
When enabled,
</p>
<ul>
<li>
the condenser and evaporator pumps are operated at constant speed,
</li>
<li>
the condenser (resp. evaporator) mixing valve is modulated with a PI
loop controlling the minimum (resp. maximum) inlet temperature.
</li>
</ul>
<h4>ESTCP adaptation</h4>
<p>
Adapted from Buildings.DHC.ETS.Combined.Controls.Chiller.
A PI controller for compressor speed is added in order to use
the ModularReversible component to replace the original EIR model.
</p>
</html>"));
end Chiller;
