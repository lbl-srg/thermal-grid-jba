within ThermalGridJBA.Networks.BaseClasses;
model CentralPlant

  package MediumW = Buildings.Media.Water "Water";
  parameter Integer nMod=2
    "Total number of modules";

  parameter Real TDisLooMin(
    unit="K",
    displayUnit="degC")=283.65
    "Design minimum district loop temperature";
  parameter Real TDisLooMax(
    unit="K",
    displayUnit="degC")=297.15
    "Design maximum district loop temperature";
  parameter Real mWat_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal water mass flow rate to each module";
  parameter Real mWat_flow_min(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat pump minimum water mass flow rate";
  parameter Real mHexGly_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal glycol mass flow rate for heat exchanger";
  parameter Real mHpGly_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal glycol mass flow rate for heat pump";
  parameter Real mDryCoo_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")=mHexGly_flow_nominal+mHpGly_flow_nominal
    "Nominal glycol mass flow rate for dry cooler";
  parameter Real dpHex_nominal(
    final quantity="PressureDifference",
    displayUnit="Pa")=10000
    "Pressure difference across heat exchanger";
  parameter Real dpValve_nominal(
    final quantity="PressureDifference",
    displayUnit="Pa")=6000
    "Nominal pressure drop of fully open 2-way valve";
  parameter Real dpDryCoo_nominal(
    final quantity="PressureDifference",
    displayUnit="Pa")=10000
    "Nominal pressure drop of fully open 2-way valve";

  parameter Modelica.Units.SI.MassFlowRate mBor_flow_nominal[nZon]={0.5,0.3}
    "Nominal mass flow rate per borehole in each zone";
  parameter Modelica.Units.SI.Pressure dp_nominal[nZon]={5e4,2e4}
    "Pressure losses for each zone of the borefield";

  parameter Real TCooSet(
    unit="K",
    displayUnit="degC")=TDisLooMin
    "Heat pump tracking temperature setpoint in cooling mode"
    annotation (Dialog(tab="Heat Pump"));
  parameter Real THeaSet(
    unit="K",
    displayUnit="degC")=TDisLooMax
    "Heat pump tracking temperature setpoint in heating mode"
    annotation (Dialog(tab="Heat Pump"));
  parameter Real TConInMin(
    unit="K",
    displayUnit="degC") "Minimum condenser inlet temperature"
    annotation (Dialog(tab="Heat Pump"));
  parameter Real TEvaInMax(
    unit="K",
    displayUnit="degC") "Maximum evaporator inlet temperature"
    annotation (Dialog(tab="Heat Pump"));

  ThermalGridJBA.Networks.BaseClasses.CentralPlantModule centralPlantModule[nMod](
    final TDisLooMin=fill(TDisLooMin, nMod),
    final TDisLooMax=fill(TDisLooMax, nMod),
    final mWat_flow_nominal=fill(mWat_flow_nominal, nMod),
    final mWat_flow_min=fill(nWat_flow_min, nMod),
    final mHexGly_flow_nominal=fill(mHexGly_flow_nominal, nMod),
    final mHpGly_flow_nominal=fill(mHpGly_flow_nominal, nMod),
    final mDryCoo_flow_nominal=fill(mDryCoo_flow_nominal, nMod),
    final dpHex_nominal=fill(dpHex_nominal, nMod),
    final dpValve_nominal=fill(dpValve_nominal, nMod),
    final dpDryCoo_nominal=fill(dpDryCoo_nominal, nMod),
    final TCooSet=fill(TCooSet, nMod),
    final THeaSet=fill(THeaSet, nMod),
    final TConInMin=fill(TConInMin, nMod),
    final TEvaInMax=fill(TEvaInMax, nMod))
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Buildings.Fluid.Delays.DelayFirstOrder del1(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=nMod*mWat_flow_nominal,
    nPorts=nMod+1)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=180, origin={-60,10})));
  Buildings.Fluid.Delays.DelayFirstOrder del2(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=nMod*mWat_flow_nominal,
    nPorts=nMod+1)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=180, origin={60,10})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow from the district"
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}}),
      iconTransformation(extent={{-110,-10},{-90,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow to the district"
    annotation (Placement(transformation(extent={{90,-10},{110,10}}),
      iconTransformation(extent={{90,-10},{110,10}})));

equation
  for i in 1:nMod loop
    connect(del1.ports[i], centralPlantModule[i].port_a)
      annotation (Line(points={{-60,0},{-10,0}}, color={0,127,255}, thickness=0.5));
    connect(centralPlantModule[i].port_b, del2.ports[i])
      annotation (Line(points={{10,0},{60,0}}, color={0,127,255}, thickness=0.5));
  end for;
  connect(del1.ports[nMod+1], port_a)
    annotation (Line(points={{-60,0},{-100,0}}, color={0,127,255}, thickness=0.5));
  connect(del2.ports[nMod+1], port_b)
    annotation (Line(points={{60,0},{100,0}}, color={0,127,255}, thickness=0.5));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                                Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),                                Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end CentralPlant;
