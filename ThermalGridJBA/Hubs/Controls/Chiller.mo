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
  parameter Real PLRMax(min=0) "Maximum part load ratio";
  parameter Real PLRMin(min=0) "Minimum part load ratio";

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uCoo
    "Cooling enable signal"
    annotation (Placement(transformation(extent={{-200,60},{-160,100}}),
    iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uHea
    "Heating enable signal"
    annotation (Placement(transformation(extent={{-200,90},{-160,130}}),
    iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaWatSupSet(final unit="K",
      displayUnit="degC") "Set point temperature for heating water" annotation
    (Placement(transformation(extent={{-200,30},{-160,70}}), iconTransformation(
          extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TConWatLvg(final unit="K",
      displayUnit="degC") "Condenser water leaving temperature" annotation (
      Placement(transformation(extent={{-200,0},{-160,40}}), iconTransformation(
          extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TConWatEnt(
    final unit="K",
    displayUnit="degC") "Condenser water entering temperature"
    annotation (Placement(transformation(extent={{-200,-130},{-160,-90}}),
    iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TEvaWatEnt(
    final unit="K",
    displayUnit="degC") "Evaporator water entering temperature"
    annotation (Placement(transformation(extent={{-200,-100},{-160,-60}}),
    iconTransformation(extent={{-140,-90},{-100,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TEvaWatLvg(final unit="K",
      displayUnit="degC") "Evaporator water leaving temperature" annotation (
      Placement(transformation(extent={{-200,-60},{-160,-20}}),
        iconTransformation(extent={{-140,-50},{-100,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TChiWatSupSet(final unit="K",
      displayUnit="degC") "Set point temperature for chilled water" annotation
    (Placement(transformation(extent={{-200,-30},{-160,10}}),
    iconTransformation(extent={{-140,-30},{-100,10}})));

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
    annotation (Placement(transformation(extent={{-120,90},{-100,110}})));
  Buildings.DHC.ETS.Combined.Controls.PIDWithEnable conValEva(
    final controllerType=Modelica.Blocks.Types.SimpleController.PI,
    final yMax=1,
    final yMin=0,
    y_reset=0,
    k=0.1,
    Ti=60,
    final reverseActing=true) "Evaporator three-way valve control"
    annotation (Placement(transformation(extent={{120,-28},{140,-8}})));
  Buildings.DHC.ETS.Combined.Controls.PIDWithEnable conValCon(
    final controllerType=Modelica.Blocks.Types.SimpleController.PI,
    final yMax=1,
    final yMin=0,
    y_reset=0,
    k=0.1,
    Ti=60,
    final reverseActing=false)
    "Condenser three-way valve control"
    annotation (Placement(transformation(extent={{120,-88},{140,-68}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant maxTEvaWatEnt(
    y(final unit="K",
      displayUnit="degC"),
    final k=TEvaWatEntMax)
    "Maximum value of evaporator water entering temperature"
    annotation (Placement(transformation(extent={{60,-28},{80,-8}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minTConWatEnt(
    y(final unit="K",
      displayUnit="degC"),
    final k=TConWatEntMin)
    "Minimum value of condenser water entering temperature"
    annotation (Placement(transformation(extent={{60,-88},{80,-68}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yChi
    "Chiller compressor speed control signal" annotation (Placement(
        transformation(extent={{160,20},{200,60}}), iconTransformation(extent={
            {100,0},{140,40}})));
  Buildings.DHC.ETS.Combined.Controls.PIDWithEnable conCoo(
    final controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    final yMax=1,
    final yMin=PLRMin,
    k=2,
    y_reset=PLRMin,
    Ti(displayUnit="s") = 300,
    final reverseActing=false,
    final y_neutral=0,
    u_s(final unit="K", displayUnit="degC"),
    u_m(final unit="K", displayUnit="degC"))
    "Chiller compressor speed control during cooling mode"
    annotation (Placement(transformation(extent={{-20,30},{0,50}})));
  Buildings.DHC.ETS.Combined.Controls.PIDWithEnable conHea(
    final controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    final yMax=1,
    final yMin=PLRMin,
    k=2,
    y_reset=PLRMin,
    Ti(displayUnit="s") = 300,
    final reverseActing=true,
    final y_neutral=0,
    u_s(final unit="K", displayUnit="degC"),
    u_m(final unit="K", displayUnit="degC"))
    "Chiller compressor speed control during heating mode"
    annotation (Placement(transformation(extent={{-20,66},{0,86}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi
    "Switch to select heating or cooling control signal"
    annotation (Placement(transformation(extent={{26,46},{46,66}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minTEvaWatLvg(
    y(final unit="K", displayUnit="degC"),
    final k(final unit="K", displayUnit="degC")=278.65)
    "Minimum evaporator water leaving temperature. Used to avoid freezing if control for heating"
    annotation (Placement(transformation(extent={{-120,-50},{-100,-30}})));
  Buildings.Controls.OBC.CDL.Reals.PID conFrePro(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.P,
    k=2,
    reverseActing=false,
    u_s(final unit="K", displayUnit="degC"),
    u_m(final unit="K", displayUnit="degC"))
    "Controller for freeze protection if heat pump is controlled in heating mode"
    annotation (Placement(transformation(extent={{-80,-50},{-60,-30}})));
  Buildings.Controls.OBC.CDL.Reals.Min frePro
    "Take smaller of the control signals for freeze protection"
    annotation (Placement(transformation(extent={{120,30},{140,50}})));
  Buildings.Controls.OBC.CDL.Reals.LimitSlewRate ramLimHea(
    raisingSlewRate=1/(15*60), Td=1)
          "Ramp limiter to avoid sudden load increase from chiller"
    annotation (Placement(transformation(extent={{-52,66},{-32,86}})));
  Buildings.Controls.OBC.CDL.Reals.LimitSlewRate ramLimCoo(raisingSlewRate=1/(
        15*60), Td=1)
          "Ramp limiter to avoid sudden load increase from chiller"
    annotation (Placement(transformation(extent={{-52,30},{-32,50}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swiTCooSet(
    u1(final unit="K", displayUnit="degC"),
    u3(final unit="K", displayUnit="degC"),
    y(final unit="K", displayUnit="degC"))
    "During heating mode, set cooling set point to evaporator leaving temp. This way, there is no sudden set point change when cooling gets activated"
    annotation (Placement(transformation(extent={{-100,30},{-80,50}})));
equation
  connect(TEvaWatEnt,conValEva.u_m)
    annotation (Line(points={{-180,-80},{40,-80},{40,-58},{130,-58},{130,-30}},
                                                           color={0,0,127}));
  connect(TConWatEnt,conValCon.u_m)
    annotation (Line(points={{-180,-110},{130,-110},{130,-90}},
                                                           color={0,0,127}));
  connect(heaOrCoo.y,yPum)
    annotation (Line(points={{-98,100},{140,100},{140,80},{180,80}},
                                                color={255,0,255}));
  connect(uHea,heaOrCoo.u1)
    annotation (Line(points={{-180,110},{-140,110},{-140,100},{-122,100}},
                                                                      color={255,0,255}));
  connect(uCoo,heaOrCoo.u2)
    annotation (Line(points={{-180,80},{-134,80},{-134,92},{-122,92}},color={255,0,255}));
  connect(maxTEvaWatEnt.y,conValEva.u_s)
    annotation (Line(points={{82,-18},{118,-18}},
                                            color={0,0,127}));
  connect(minTConWatEnt.y,conValCon.u_s)
    annotation (Line(points={{82,-78},{118,-78}},
                                                color={0,0,127}));
  connect(conValEva.y,yValEva)
    annotation (Line(points={{142,-18},{180,-18},{180,-20}},
                                             color={0,0,127}));
  connect(heaOrCoo.y,conValEva.uEna)
    annotation (Line(points={{-98,100},{50,100},{50,-38},{126,-38},{126,-30}},
                                                                            color={255,0,255}));
  connect(heaOrCoo.y,conValCon.uEna)
    annotation (Line(points={{-98,100},{50,100},{50,-98},{126,-98},{126,-90}},
                                                                            color={255,0,255}));
  connect(conValCon.y,yValCon)
    annotation (Line(points={{142,-78},{180,-78},{180,-80}},
                                                 color={0,0,127}));
  connect(TEvaWatLvg,conCoo. u_m) annotation (Line(points={{-180,-40},{-130,-40},
          {-130,-20},{-10,-20},{-10,28}},
                                     color={0,0,127}));
  connect(TConWatLvg, conHea.u_m) annotation (Line(points={{-180,20},{-146,20},{
          -146,60},{-10,60},{-10,64}},
                              color={0,0,127}));
  connect(uHea, conHea.uEna) annotation (Line(points={{-180,110},{-140,110},{-140,
          56},{-14,56},{-14,64}},
                                color={255,0,255}));
  connect(conCoo.y, swi.u3) annotation (Line(points={{2,40},{20,40},{20,48},{24,
          48}}, color={0,0,127}));
  connect(swi.u2, uHea) annotation (Line(points={{24,56},{-140,56},{-140,110},{
          -180,110}},            color={255,0,255}));
  connect(conFrePro.u_s, minTEvaWatLvg.y)
    annotation (Line(points={{-82,-40},{-98,-40}}, color={0,0,127}));
  connect(conFrePro.u_m, TEvaWatLvg) annotation (Line(points={{-70,-52},{-70,-70},
          {-130,-70},{-130,-40},{-180,-40}},
                       color={0,0,127}));
  connect(conFrePro.y, frePro.u2) annotation (Line(points={{-58,-40},{40,-40},{40,
          34},{118,34}},     color={0,0,127}));
  connect(THeaWatSupSet, ramLimHea.u) annotation (Line(points={{-180,50},{-150,50},
          {-150,76},{-54,76}},      color={0,0,127}));
  connect(ramLimHea.y, conHea.u_s)
    annotation (Line(points={{-30,76},{-22,76}}, color={0,0,127}));
  connect(ramLimCoo.y, conCoo.u_s)
    annotation (Line(points={{-30,40},{-22,40}}, color={0,0,127}));
  connect(conHea.y, swi.u1) annotation (Line(points={{2,76},{20,76},{20,64},{24,
          64}},     color={0,0,127}));
  connect(frePro.y, yChi)
    annotation (Line(points={{142,40},{180,40}}, color={0,0,127}));
  connect(conCoo.uEna, uCoo) annotation (Line(points={{-14,28},{-14,24},{-134,24},
          {-134,80},{-180,80}}, color={255,0,255}));
  connect(swiTCooSet.u2, uHea) annotation (Line(points={{-102,40},{-140,40},{-140,
          110},{-180,110}}, color={255,0,255}));
  connect(swiTCooSet.u1, TEvaWatLvg) annotation (Line(points={{-102,48},{-130,48},
          {-130,-40},{-180,-40}}, color={0,0,127}));
  connect(TChiWatSupSet, swiTCooSet.u3) annotation (Line(points={{-180,-10},{-126,
          -10},{-126,32},{-102,32}}, color={0,0,127}));
  connect(swiTCooSet.y, ramLimCoo.u)
    annotation (Line(points={{-78,40},{-54,40}}, color={0,0,127}));
  connect(swi.y, frePro.u1) annotation (Line(points={{48,56},{90,56},{90,46},{
          120,46}}, color={0,0,127}));
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
<p>
An additional input has been added for the heating water supply temperature,
and a PI controller has been added.
</p>
<p>
A rate limiter has been added to avoid a sharp change in cooling load.
This was done before the heating water supply temperature controller was
added, and may no longer be needed.
</p>
</html>"));
end Chiller;
