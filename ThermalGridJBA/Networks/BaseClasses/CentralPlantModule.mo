within ThermalGridJBA.Networks.BaseClasses;
model CentralPlantModule "Central plant module, each includes the generation equipments and one borefield module"

  package MediumW = Buildings.Media.Water "Water";
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
    "Nominal water mass flow rate";
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
    unit="Pa")=10000
    "Pressure difference across heat exchanger";
  parameter Real dpValve_nominal(
    final quantity="PressureDifference",
    unit="Pa")=6000
    "Nominal pressure drop of fully open 2-way valve";
  parameter Real dpDryCoo_nominal(
    final quantity="PressureDifference",
    unit="Pa")=10000
    "Nominal pressure drop of fully open 2-way valve";
  parameter Real mBor_flow_nominal[nZon](
    final quantity=fill("MassFlowRate",nZon),
    final unit=fill("kg/s",nZon))=fill(mWat_flow_nominal/nBor, nZon)
    "Nominal mass flow rate per borehole in each zone";
  parameter Real dp_nominal[nZon](
    final quantity=fill("Pressure", nZon),
    final unit=fill("Pa", nZon))={5e4,2e4}
    "Pressure losses for each zone of the borefield";
  parameter Real samplePeriod(
    final quantity="Time",
    final unit="s")=7200 "Sample period of district loop pump speed"
    annotation (Dialog(tab="Controls", group="Indicators"));
  parameter Real TAppSet(
    final quantity="TemperatureDifference",
    final unit="K")=2 "Dry cooler approch setpoint"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real TApp(
    final quantity="TemperatureDifference",
    final unit="K")=4
    "Approach temperature for checking if the dry cooler should be enabled"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real minFanSpe=0.1
    "Minimum dry cooler fan speed"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real TCooSet(
    unit="K",
    displayUnit="degC")=TDisLooMin
    "Heat pump tracking temperature setpoint in cooling mode"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real THeaSet(
    unit="K",
    displayUnit="degC")=TDisLooMax
    "Heat pump tracking temperature setpoint in heating mode"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TConInMin(
    unit="K",
    displayUnit="degC") "Minimum condenser inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TEvaInMax(
    unit="K",
    displayUnit="degC") "Maximum evaporator inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real offTim(
    final quantity="Time",
    final unit="s")=12*3600 "Heat pump off time"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real minComSpe=0.2
    "Minimum heat pump compressor speed"
    annotation (Dialog(tab="Controls", group="Heat pump"));

  final parameter ThermalGridJBA.Networks.Data.Borefield.Validation borFieDat(
    filDat=filDat,
    soiDat=soiDat,
    conDat=conDat)
    "Borefield data"
    annotation (Placement(transformation(extent={{-60,60},{-40,80}})));
  final parameter ThermalGridJBA.Networks.Data.Configuration.Validation conDat(
    final mBor_flow_nominal=mBor_flow_nominal,
    final dp_nominal=dp_nominal)
    "Borefield configuration data"
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
  final parameter ThermalGridJBA.Networks.Data.Filling.Bentonite filDat
    "Borehole filling data"
    annotation (Placement(transformation(extent={{-60,-60},{-40,-40}})));
  final parameter ThermalGridJBA.Networks.Data.Soil.SandStone soiDat
    "Soil data"
    annotation (Placement(transformation(extent={{-60,-80},{-40,-60}})));
  final parameter Integer nZon=conDat.nZon
    "Total number of independent bore field zones";
  final parameter Integer nBor=size(conDat.iZon, 1)
    "Total number of boreholes";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWetBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient wet bulb temperature"
    annotation (Placement(transformation(extent={{-140,-100},{-100,-60}}),
        iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixAve(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Average temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-140,10},{-100,50}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-140,-70},{-100,-30}}),
        iconTransformation(extent={{-140,-90},{-100,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uSolTim
    "Solar time. An output from weather data"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum
    "District loop pump speed"
    annotation (Placement(transformation(extent={{-140,70},{-100,110}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PFan_dryCoo(
    quantity="Power",
    final unit="W")
    "Electric power consumed by fan"
    annotation (Placement(transformation(extent={{100,50},{140,90}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPum_dryCoo(
    quantity="Power",
    final unit="W")
    "Electrical power consumed by dry cool pump"
    annotation (Placement(transformation(extent={{100,30},{140,70}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPum_hexGly(
    quantity="Power",
    final unit="W")
    "Electrical power consumed by the glycol pump of HEX"
    annotation (Placement(transformation(extent={{100,10},{140,50}}),
        iconTransformation(extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPum_heaPumGly(
    quantity="Power",
    final unit="W")
    "Electrical power consumed by glycol pump of heat pump"
    annotation (Placement(transformation(extent={{100,-50},{140,-10}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PCom(
    quantity="Power",
    final unit="W")
    "Electric power consumed by compressor"
    annotation (Placement(transformation(extent={{100,-70},{140,-30}}),
        iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPum_heaPumWat(
    quantity="Power",
    final unit="W")
    "Electrical power consumed by heat pump waterside pump"
    annotation (Placement(transformation(extent={{100,-90},{140,-50}}),
        iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPum_cirPum(
    quantity="Power",
    final unit="W")
    "Electrical power consumed by circulation pump"
    annotation (Placement(transformation(extent={{100,-110},{140,-70}}),
        iconTransformation(extent={{100,-110},{140,-70}})));

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

  ThermalGridJBA.Networks.BaseClasses.Generations gen(
    final TDisLooMin=TDisLooMin,
    final TDisLooMax=TDisLooMax,
    final mWat_flow_nominal=mWat_flow_nominal,
    final mWat_flow_min=mWat_flow_min,
    final mHexGly_flow_nominal=mHexGly_flow_nominal,
    final mHpGly_flow_nominal=mHpGly_flow_nominal,
    final mDryCoo_flow_nominal=mDryCoo_flow_nominal,
    final dpHex_nominal=dpHex_nominal,
    final dpValve_nominal=dpValve_nominal,
    final dpDryCoo_nominal=dpDryCoo_nominal,
    final samplePeriod=samplePeriod,
    final TAppSet=TAppSet,
    final TApp=TApp,
    final minFanSpe=minFanSpe,
    final TCooSet=TCooSet,
    final THeaSet=THeaSet,
    final TConInMin=TConInMin,
    final TEvaInMax=TEvaInMax,
    final offTim=offTim,
    final minComSpe=minComSpe)
    "Cooling and heating generation devices"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.Fluid.Geothermal.ZonedBorefields.TwoUTubes borFie(
    redeclare final package Medium = MediumW)
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));
  Buildings.Fluid.Delays.DelayFirstOrder del3(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mWat_flow_nominal,
    nPorts=nZon+1)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=180, origin={0,10})));
  Buildings.Fluid.Delays.DelayFirstOrder del1(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mWat_flow_nominal,
    nPorts=nZon+1)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=180, origin={70,10})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, cent per kWh"
    annotation (Placement(transformation(extent={{100,70},{140,110}}),
        iconTransformation(extent={{100,70},{140,110}})));

equation
  for i in 1:nZon loop
    connect(del3.ports[i], borFie.port_a[i])
      annotation (Line(points={{0,0},{20,0}},   color={0,127,255},
        thickness=0.5));
    connect(borFie.port_b[i], del1.ports[i])
      annotation (Line(points={{40,0},{70,0}}, color={0,127,255},
        thickness=0.5));
  end for;
  connect(gen.port_b, del3.ports[nZon + 1]) annotation (Line(
      points={{-40,0},{0,0}},
      color={0,127,255},
      thickness=0.5));
  connect(del1.ports[nZon+1], port_b)
    annotation (Line(points={{70,0},{100,0}}, color={0,127,255},
      thickness=0.5));
  connect(port_a, gen.port_a) annotation (Line(
      points={{-100,0},{-60,0}},
      color={0,127,255},
      thickness=0.5));
  connect(uDisPum, gen.uDisPum) annotation (Line(points={{-120,90},{-68,90},{-68,
          9},{-62,9}}, color={0,0,127}));
  connect(uSolTim, gen.uSolTim) annotation (Line(points={{-120,60},{-74,60},{-74,
          7},{-62,7}}, color={0,0,127}));
  connect(TWetBul, gen.TWetBul) annotation (Line(points={{-120,-80},{-74,-80},{-74,
          -9},{-62,-9}}, color={0,0,127}));
  connect(TMixAve, gen.TMixAve) annotation (Line(points={{-120,30},{-80,30},{-80,
          3},{-62,3}}, color={0,0,127}));
  connect(TDryBul, gen.TDryBul) annotation (Line(points={{-120,-50},{-80,-50},{-80,
          -7},{-62,-7}}, color={0,0,127}));
  connect(gen.PFan_dryCoo, PFan_dryCoo) annotation (Line(points={{-38,7},{-24,7},
          {-24,70},{120,70}}, color={0,0,127}));
  connect(gen.PPum_dryCoo, PPum_dryCoo) annotation (Line(points={{-38,5},{-20,5},
          {-20,50},{120,50}}, color={0,0,127}));
  connect(gen.PPum_hexGly, PPum_hexGly) annotation (Line(points={{-38,3},{-16,3},
          {-16,30},{120,30}}, color={0,0,127}));
  connect(gen.PPum_heaPumGly, PPum_heaPumGly) annotation (Line(points={{-38,-3},
          {-16,-3},{-16,-30},{120,-30}}, color={0,0,127}));
  connect(gen.PCom, PCom) annotation (Line(points={{-38,-5},{-20,-5},{-20,-50},
          {120,-50}}, color={0,0,127}));
  connect(gen.PPum_heaPumWat, PPum_heaPumWat) annotation (Line(points={{-38,-7},
          {-24,-7},{-24,-70},{120,-70}}, color={0,0,127}));
  connect(gen.PPum_cirPum, PPum_cirPum) annotation (Line(points={{-38,-9},{-28,
          -9},{-28,-90},{120,-90}}, color={0,0,127}));
  connect(gen.yEleRat, yEleRat) annotation (Line(points={{-38,9},{-28,9},{-28,
          90},{120,90}}, color={0,0,127}));
  annotation (defaultComponentName="plaMod",
  Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                                Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),                                Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end CentralPlantModule;
