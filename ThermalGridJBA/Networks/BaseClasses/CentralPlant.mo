within ThermalGridJBA.Networks.BaseClasses;
model CentralPlant "Central plant"

  package MediumW = Buildings.Media.Water "Water";
  parameter Integer nMod=2
    "Total number of modules";

  parameter Real TLooMin(
    unit="K",
    displayUnit="degC")=283.65
    "Design minimum district loop temperature";
  parameter Real TLooMax(
    unit="K",
    displayUnit="degC")=297.15
    "Design maximum district loop temperature";
  parameter Real mWat_flow_nominal(unit="kg/s")
    "Nominal water mass flow rate to each module";
  parameter Real dpValve_nominal(
    final quantity="PressureDifference",
    unit="Pa",
    displayUnit="Pa")=6000
    "Nominal pressure drop of fully open 2-way valve";

  // Heat exchanger parameters
  parameter Real dpHex_nominal(unit="Pa")=10000
    "Pressure difference across heat exchanger"
    annotation (Dialog(group="Heat exchanger"));
  parameter Real mHexGly_flow_nominal(unit="kg/s")=mWat_flow_nominal*0.6
    "Nominal glycol mass flow rate for heat exchanger"
    annotation (Dialog(group="Heat exchanger"));
  // Heat exchanger parameters
  parameter Real dpDryCoo_nominal(unit="Pa")=10000
    "Nominal pressure drop of dry cooler"
    annotation (Dialog(group="Dry cooler"));
  parameter Real mDryCoo_flow_nominal(unit="kg/s")=mHexGly_flow_nominal +
    mHpGly_flow_nominal
    "Nominal glycol mass flow rate for dry cooler"
    annotation (Dialog(group="Dry cooler"));
  // Heat pump parameters
  parameter Real mWat_flow_min(unit="kg/s")=0.2*mWat_flow_nominal
    "Heat pump minimum water mass flow rate"
    annotation (Dialog(group="Heat pump"));
  parameter Real mHpGly_flow_nominal(unit="kg/s")=mWat_flow_nominal*0.6
    "Nominal glycol mass flow rate for heat pump"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumHea_flow_nominal(
    final unit="W",
    final quantity="HeatFlowRate")
    "Nominal heating capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConHea_nominal(
    final unit="K",
    displayUnit="degC")=TLooMin
    "Nominal temperature of the heated fluid in heating mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaHea_nominal(
    final unit="K",
    displayUnit="degC")=TLooMin + TApp
    "Nominal temperature of the cooled fluid in heating mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumCoo_flow_nominal(
    final unit="W",
    final quantity="HeatFlowRate")
    "Nominal cooling capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConCoo_nominal(
    final unit="K",
    displayUnit="degC")=TLooMax
    "Nominal temperature of the cooled fluid in cooling mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaCoo_nominal(
    final unit="K",
    displayUnit="degC")=TLooMax - TApp
    "Nominal temperature of the heated fluid in cooling mode"
    annotation (Dialog(group="Heat pump"));

  parameter Real samplePeriod(unit="s")=7200
    "Sample period of district loop pump speed"
    annotation (Dialog(tab="Controls", group="Indicators"));
  parameter Real TAppSet(unit="K")=2
    "Dry cooler approch setpoint"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real TApp(unit="K")=4
    "Approach temperature for checking if the dry cooler should be enabled"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real minFanSpe(
    unit="1")=0.1
    "Minimum dry cooler fan speed"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real TCooSet(unit="K")=TLooMin
    "Heat pump tracking temperature setpoint in cooling mode"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real THeaSet(unit="K")=TLooMax
    "Heat pump tracking temperature setpoint in heating mode"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TConInMin(unit="K")=TLooMax - TApp - TAppSet
    "Minimum condenser inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TEvaInMax(unit="K")=TLooMin + TApp + TAppSet
    "Maximum evaporator inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real offTim(unit="s")=12*3600
    "Heat pump off time"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real minComSpe(unit="1")=0.2
    "Minimum heat pump compressor speed"
    annotation (Dialog(tab="Controls", group="Heat pump"));

  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum
    "District loop pump speed"
    annotation (Placement(transformation(extent={{-140,60},{-100,100}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uSolTim
    "Solar time. An output from weather data"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixAve(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Average temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-140,20},{-100,60}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-140,-60},{-100,-20}}),
        iconTransformation(extent={{-140,-90},{-100,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWetBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient wet bulb temperature"
    annotation (Placement(transformation(extent={{-140,-100},{-100,-60}}),
        iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat[nMod]
    "Current electricity rate, cent per kWh"
    annotation (Placement(transformation(extent={{100,70},{140,110}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PFanDryCoo[nMod](
    quantity=fill("Power", nMod),
    final unit=fill("W", nMod))
    "Electric power consumed by fan"
    annotation (Placement(transformation(extent={{100,50},{140,90}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumDryCoo[nMod](
    quantity=fill("Power", nMod),
    final unit=fill("W", nMod))
    "Electrical power consumed by dry cool pump"
    annotation (Placement(transformation(extent={{100,30},{140,70}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHexGly[nMod](
    quantity=fill("Power", nMod),
    final unit=fill("W", nMod))
    "Electrical power consumed by the glycol pump of HEX"
    annotation (Placement(transformation(extent={{100,10},{140,50}}),
        iconTransformation(extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumGly[nMod](
    quantity=fill("Power", nMod),
    final unit=fill("W", nMod))
    "Electrical power consumed by glycol pump of heat pump"
    annotation (Placement(transformation(extent={{100,-50},{140,-10}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PCom[nMod](
    quantity=fill("Power", nMod),
    final unit=fill("W", nMod))
    "Electric power consumed by compressor"
    annotation (Placement(transformation(extent={{100,-70},{140,-30}}),
        iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumWat[nMod](
    quantity=fill("Power", nMod),
    final unit=fill("W", nMod))
    "Electrical power consumed by heat pump waterside pump"
    annotation (Placement(transformation(extent={{100,-90},{140,-50}}),
        iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumCirPum[nMod](
    quantity=fill("Power", nMod),
    final unit=fill("W", nMod))
    "Electrical power consumed by circulation pump"
    annotation (Placement(transformation(extent={{100,-110},{140,-70}}),
        iconTransformation(extent={{100,-110},{140,-70}})));

  ThermalGridJBA.Networks.BaseClasses.CentralPlantModule plaMod[nMod](
    final TLooMin=fill(TLooMin, nMod),
    final TLooMax=fill(TLooMax, nMod),
    final mWat_flow_nominal=fill(mWat_flow_nominal, nMod),
    final mWat_flow_min=fill(mWat_flow_min, nMod),
    final mHexGly_flow_nominal=fill(mHexGly_flow_nominal, nMod),
    final mHpGly_flow_nominal=fill(mHpGly_flow_nominal, nMod),
    final mDryCoo_flow_nominal=fill(mDryCoo_flow_nominal, nMod),
    final dpHex_nominal=fill(dpHex_nominal, nMod),
    final dpValve_nominal=fill(dpValve_nominal, nMod),
    final dpDryCoo_nominal=fill(dpDryCoo_nominal, nMod),
    QHeaPumHea_flow_nominal=fill(QHeaPumHea_flow_nominal, nMod),
    final TConHea_nominal=fill(TConHea_nominal, nMod),
    TEvaHea_nominal=fill(TEvaHea_nominal, nMod),
    QHeaPumCoo_flow_nominal=fill(QHeaPumCoo_flow_nominal, nMod),
    TConCoo_nominal=fill(TConCoo_nominal, nMod),
    TEvaCoo_nominal=fill(TEvaCoo_nominal, nMod),
    final samplePeriod=fill(samplePeriod, nMod),
    final TAppSet=fill(TAppSet, nMod),
    final TApp=fill(TApp, nMod),
    final minFanSpe=fill(minFanSpe, nMod),
    final TCooSet=fill(TCooSet, nMod),
    final THeaSet=fill(THeaSet, nMod),
    final TConInMin=fill(TConInMin, nMod),
    final TEvaInMax=fill(TEvaInMax, nMod),
    final offTim=fill(offTim, nMod),
    final minComSpe=fill(minComSpe, nMod))
    "Central plant module"
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));
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
        rotation=180, origin={70,10})));
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
  Buildings.Controls.OBC.CDL.Routing.RealScalarReplicator reaScaRep(
    final nout=nMod)
    annotation (Placement(transformation(extent={{-80,70},{-60,90}})));
  Buildings.Controls.OBC.CDL.Routing.RealScalarReplicator reaScaRep1(
    final nout=nMod)
    annotation (Placement(transformation(extent={{-40,50},{-20,70}})));
  Buildings.Controls.OBC.CDL.Routing.RealScalarReplicator reaScaRep2(
    final nout=nMod)
    annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
  Buildings.Controls.OBC.CDL.Routing.RealScalarReplicator reaScaRep3(
    final nout=nMod)
    annotation (Placement(transformation(extent={{-80,-50},{-60,-30}})));
  Buildings.Controls.OBC.CDL.Routing.RealScalarReplicator reaScaRep4(
    final nout=nMod)
    annotation (Placement(transformation(extent={{-80,-90},{-60,-70}})));

equation
  for i in 1:nMod loop
    connect(del1.ports[i], plaMod[i].port_a) annotation (Line(
        points={{-60,0},{20,0}},
        color={0,127,255},
        thickness=0.5));
    connect(plaMod[i].port_b, del2.ports[i]) annotation (Line(
        points={{40,0},{70,0}},
        color={0,127,255},
        thickness=0.5));
  end for;
  connect(del1.ports[nMod+1], port_a)
    annotation (Line(points={{-60,0},{-100,0}}, color={0,127,255}, thickness=0.5));
  connect(del2.ports[nMod+1], port_b)
    annotation (Line(points={{70,0},{100,0}}, color={0,127,255}, thickness=0.5));
  connect(TWetBul, reaScaRep4.u)
    annotation (Line(points={{-120,-80},{-82,-80}}, color={0,0,127}));
  connect(TDryBul, reaScaRep3.u)
    annotation (Line(points={{-120,-40},{-82,-40}}, color={0,0,127}));
  connect(TMixAve, reaScaRep2.u)
    annotation (Line(points={{-120,40},{-82,40}}, color={0,0,127}));
  connect(uSolTim, reaScaRep1.u)
    annotation (Line(points={{-120,60},{-42,60}}, color={0,0,127}));
  connect(uDisPum, reaScaRep.u)
    annotation (Line(points={{-120,80},{-82,80}}, color={0,0,127}));
  connect(reaScaRep.y, plaMod.uDisPum)
    annotation (Line(points={{-58,80},{0,80},{0,9},{18,9}}, color={0,0,127}));
  connect(reaScaRep1.y, plaMod.uSolTim) annotation (Line(points={{-18,60},{-10,60},
          {-10,7},{18,7}}, color={0,0,127}));
  connect(reaScaRep2.y, plaMod.TMixAve) annotation (Line(points={{-58,40},{-20,40},
          {-20,3},{18,3}}, color={0,0,127}));
  connect(reaScaRep3.y, plaMod.TDryBul) annotation (Line(points={{-58,-40},{-20,
          -40},{-20,-7},{18,-7}}, color={0,0,127}));
  connect(reaScaRep4.y, plaMod.TWetBul) annotation (Line(points={{-58,-80},{-10,
          -80},{-10,-9},{18,-9}}, color={0,0,127}));
  connect(plaMod.PPumHeaPumGly, PPumHeaPumGly) annotation (Line(points={{42,-3},
          {60,-3},{60,-30},{120,-30}}, color={0,0,127}));
  connect(plaMod.PCom, PCom) annotation (Line(points={{42,-5},{56,-5},{56,-50},{
          120,-50}}, color={0,0,127}));
  connect(plaMod.PPumHeaPumWat, PPumHeaPumWat) annotation (Line(points={{42,-7},
          {52,-7},{52,-70},{120,-70}}, color={0,0,127}));
  connect(plaMod.PPumCirPum, PPumCirPum) annotation (Line(points={{42,-9},{48,-9},
          {48,-90},{120,-90}}, color={0,0,127}));
  connect(plaMod.PPumHexGly, PPumHexGly) annotation (Line(points={{42,3},{56,3},
          {56,30},{120,30}}, color={0,0,127}));
  connect(plaMod.PPumDryCoo, PPumDryCoo) annotation (Line(points={{42,5},{52,5},
          {52,50},{120,50}}, color={0,0,127}));
  connect(plaMod.PFanDryCoo, PFanDryCoo) annotation (Line(points={{42,7},{48,7},
          {48,70},{120,70}}, color={0,0,127}));
  connect(plaMod.yEleRat, yEleRat) annotation (Line(points={{42,9},{44,9},{44,90},
          {120,90}}, color={0,0,127}));
  annotation (defaultComponentName="cenPla",
  Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                                Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255}),
        Rectangle(
          extent={{-100,-8},{0,8}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{0,-8},{100,8}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-40,-40},{40,40}},
          lineColor={27,0,55},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid)}),                      Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end CentralPlant;
