within ThermalGridJBA.Hubs.BaseClasses;
model StratifiedTank "Stratified buffer tank model"
  replaceable package Medium=Modelica.Media.Interfaces.PartialMedium
    "Medium model"
    annotation (choices(
      choice(redeclare package Medium=Buildings.Media.Water "Water"),
      choice(redeclare package Medium = Buildings.Media.Antifreeze.PropyleneGlycolWater (property_T=293.15,X_a=0.40)
        "Propylene glycol water, 40% mass fraction")));
  final parameter Boolean allowFlowReversal=true
    "= true to allow flow reversal, false restricts to design direction (port_a -> port_b)"
    annotation (Dialog(tab="Assumptions"),Evaluate=true);
  parameter Modelica.Units.SI.Volume VTan "Tank volume";
  parameter Modelica.Units.SI.Length hTan "Height of tank (without insulation)";
  parameter Modelica.Units.SI.Length dIns "Thickness of insulation";
  parameter Modelica.Units.SI.ThermalConductivity kIns=0.04
    "Specific heat conductivity of insulation";
  parameter Integer nSeg(
    min=3)=3
    "Number of volume segments";
  parameter Integer iMid(
    min=2)=2
    "Index of the middle volume";
  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal
    "Nominal mass flow rate" annotation (Dialog(group="Nominal condition"));
  // IO CONNECTORS
  Modelica.Fluid.Interfaces.FluidPort_a port_aTop(
    redeclare final package Medium=Medium,
    m_flow(
      min=
        if allowFlowReversal then
          -Modelica.Constants.inf
        else
          0),
    h_outflow(
      start=Medium.h_default,
      nominal=Medium.h_default))
    "Inlet fluid port at tank top"
    annotation (Placement(transformation(extent={{90,50},{110,70}}),iconTransformation(extent={{90,50},{110,70}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_bBot(
    redeclare final package Medium=Medium,
    m_flow(
      max=
        if allowFlowReversal then
          +Modelica.Constants.inf
        else
          0),
    h_outflow(
      start=Medium.h_default,
      nominal=Medium.h_default))
    "Outlet fluid port at tank bottom"
    annotation (Placement(transformation(extent={{90,-70},{110,-50}}),iconTransformation(extent={{90,-70},{110,-50}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_aBot(
    redeclare final package Medium=Medium,
    m_flow(
      min=
        if allowFlowReversal then
          -Modelica.Constants.inf
        else
          0),
    h_outflow(
      start=Medium.h_default,
      nominal=Medium.h_default))
    "Inlet fluid port at tank bottom"
    annotation (Placement(transformation(extent={{-110,-70},{-90,-50}}),iconTransformation(extent={{-110,-70},{-90,-50}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_bTop(
    redeclare final package Medium=Medium,
    m_flow(
      max=
        if allowFlowReversal then
          +Modelica.Constants.inf
        else
          0),
    h_outflow(
      start=Medium.h_default,
      nominal=Medium.h_default))
    "Outlet fluid port at tank top"
    annotation (Placement(transformation(extent={{-110,50},{-90,70}}),iconTransformation(extent={{-110,50},{-90,70}})));
  Modelica.Blocks.Interfaces.RealOutput Ql_flow(
    final unit="W")
    "Heat loss of tank (positive if heat flows from tank to ambient)"
    annotation (Placement(transformation(extent={{-20,-20},{20,20}},
        rotation=0,
        origin={120,20}),                                             iconTransformation(extent={{-10,-10},
            {10,10}},
        rotation=0,
        origin={110,20})));
  Modelica.Blocks.Interfaces.RealOutput T[3](
    each final unit="K",
    each displayUnit="degC")
    "Fluid temperature: 1 = top; 2 = middle; 3 = bottom" annotation (Placement(
        transformation(extent={{100,-40},{140,0}}), iconTransformation(extent={{
            100,-30},{120,-10}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorAmb
    "Heat port at interface with ambient (outside insulation)"
    annotation (Placement(transformation(extent={{-106,-6},{-94,6}})));
  // COMPONENTS
  Buildings.Fluid.Storage.Stratified tan(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    final VTan=VTan,
    final hTan=hTan,
    final dIns=dIns,
    final kIns=kIns,
    final nSeg=nSeg) "Stratified tank"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senT[3]
    "Tank fluid temperature sensors: 1 = top; 2 = middle; 3 = bottom"
    annotation (Placement(transformation(extent={{60,-30},{80,-10}})));
protected
  Modelica.Thermal.HeatTransfer.Components.ThermalCollector theCol(
    m=3)
    "Connector to assign multiple heat ports to one heat port"
    annotation (Placement(transformation(extent={{-6,-6},{6,6}},rotation=-90,origin={-60,0})));
equation
  connect(port_aTop,tan.port_a)
    annotation (Line(points={{100,60},{-20,60},{-20,10},{0,10}},color={0,127,255}));
  connect(port_bTop,tan.fluPorVol[1])
    annotation (Line(points={{-100,60},{-40,60},{-40,20},{0,20},{0,-1.33333},{-5,
          -1.33333}},                                                                           color={0,127,255}));
  connect(tan.port_b,port_bBot)
    annotation (Line(points={{0,-10},{20,-10},{20,-60},{100,-60}},
                                                               color={0,127,255}));
  connect(port_aBot,tan.fluPorVol[nSeg])
    annotation (Line(points={{-100,-60},{0,-60},{0,0},{-5,0}},  color={0,127,255}));
  connect(tan.Ql_flow,Ql_flow)
    annotation (Line(points={{11,7.2},{40,7.2},{40,20},{120,20}},  color={0,0,127}));
  connect(senT.T, T)
    annotation (Line(points={{81,-20},{120,-20}}, color={0,0,127}));
  connect(heaPorAmb,theCol.port_b)
    annotation (Line(points={{-100,0},{-66,0}},color={191,0,0}));
  connect(theCol.port_a[1],tan.heaPorTop)
    annotation (Line(points={{-54.2,0},{-26,0},{-26,7.4},{2,7.4}},color={191,0,0}));
  connect(theCol.port_a[2],tan.heaPorSid)
    annotation (Line(points={{-54,0},{5.6,0}},color={191,0,0}));
  connect(theCol.port_a[3],tan.heaPorBot)
    annotation (Line(points={{-53.8,0},{-26,0},{-26,-7.4},{2,-7.4}},color={191,0,0}));
  connect(tan.heaPorVol[1], senT[1].port) annotation (Line(points={{0,-0.2},{0,0},
          {40,0},{40,-20},{60,-20}}, color={191,0,0}));
  connect(tan.heaPorVol[iMid], senT[2].port) annotation (Line(points={{0,0},{40,
          0},{40,-20},{60,-20}}, color={191,0,0}));
  connect(tan.heaPorVol[nSeg], senT[3].port) annotation (Line(points={{0,0},{40,
          0},{40,-20},{60,-20}}, color={191,0,0}));
  annotation (
    Icon(
      coordinateSystem(
        extent={{-100,-100},{100,100}}),
      graphics={
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-40,64},{40,20}},
          lineColor={255,0,0},
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-40,-20},{40,-64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-40,20},{40,-20}},
          lineColor={255,0,0},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.CrossDiag),
        Rectangle(
          extent={{50,68},{40,-66}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-40,66},{-50,-68}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-50,72},{50,64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-50,-64},{50,-72}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-50,64},{-100,56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{100,64},{50,56}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{100,-56},{50,-64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-50,-56},{-100,-64}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,127},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-139,-106},{161,-146}},
          textColor={0,0,255},
          textString="%name")}),
    defaultComponentName="tan",
    Diagram(
      coordinateSystem(
        extent={{-100,-100},{100,100}})),
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
Modified from
<a href=\"modelica://Buildings.DHC.ETS.BaseClasses.StratifiedTank\">
Buildings.DHC.ETS.BaseClasses.StratifiedTank</a>
to have a third temperature output to the \"middle\" of the tank.
The \"middle\" volume has the index <code>iMid</code>.
</p>
</html>"));
end StratifiedTank;
