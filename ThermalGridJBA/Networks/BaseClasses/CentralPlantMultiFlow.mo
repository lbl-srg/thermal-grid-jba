within ThermalGridJBA.Networks.BaseClasses;
model CentralPlantMultiFlow
  "Central plant model with flow multiplier to simplify the simulation"

  package MediumW = Buildings.Media.Water "Water";
  parameter Integer nGenMod=4
    "Number of generation modules";
  parameter Integer nBorSec = 33
    "Number of borefield sectors. It includes 2 modules and the number should be divisible by 3";
  parameter Real TLooMin(
    unit="K",
    displayUnit="degC")=283.65
    "Design minimum district loop temperature";
  parameter Real TLooMax(
    unit="K",
    displayUnit="degC")=297.15
    "Design maximum district loop temperature";
  parameter Real mWat_flow_nominal(unit="kg/s")
    "Nominal water mass flow rate to each generation module";
  parameter Real dpValve_nominal(unit="Pa")=6000
    "Nominal pressure drop of fully open 2-way valve";

  // Heat exchanger parameters
  parameter Real dpHex_nominal(unit="Pa")=10000
    "Pressure difference across heat exchanger"
    annotation (Dialog(group="Heat exchanger"));
  parameter Real mHexGly_flow_nominal(unit="kg/s")
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
  parameter Real mWat_flow_min(unit="kg/s")
    "Heat pump minimum water mass flow rate"
    annotation (Dialog(group="Heat pump"));
  parameter Real mHpGly_flow_nominal(unit="kg/s")
    "Nominal glycol mass flow rate for heat pump"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumHea_flow_nominal(unit="W")
    "Nominal heating capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConHea_nominal(unit="K")=TLooMin + TApp
    "Nominal temperature of the heated fluid in heating mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaHea_nominal(unit="K")=TLooMin
    "Nominal temperature of the cooled fluid in heating mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumCoo_flow_nominal(unit="W")
    "Nominal cooling capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConCoo_nominal(unit="K")=TLooMax
    "Nominal temperature of the cooled fluid in cooling mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaCoo_nominal(unit="K")=TLooMax + TApp
    "Nominal temperature of the heated fluid in cooling mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real mBorMod_flow_nominual(unit="kg/s")=mWat_flow_nominal*nGenMod/
    (nBorSec*2)
    "Nominal mass flow rate to each borefield module"
    annotation (Dialog(group="Borefield"));
  parameter Real mBorHol_flow_nominal[nZon](unit=fill("kg/s", nZon))=fill(
    mBorMod_flow_nominual/nBor, nZon)
    "Nominal mass flow rate per borehole in each zone of borefield module"
    annotation (Dialog(group="Borefield"));
  parameter Real dp_nominal[nZon](unit=fill("Pa", nZon))={5e4,2e4}
    "Pressure losses for each zone of borefield module"
    annotation (Dialog(group="Borefield"));

  parameter Real samplePeriod(unit="s")=7200
                         "Sample period of district loop pump speed"
    annotation (Dialog(tab="Controls", group="Indicators"));
  parameter Real TAppSet(unit="K")=2
                      "Dry cooler approch setpoint"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real TApp(unit="K")=4
    "Approach temperature for checking if the dry cooler should be enabled"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real minFanSpe(unit="1")=0.1
    "Minimum dry cooler fan speed"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real TCooSet(unit="K")=TLooMin
    "Heat pump tracking temperature setpoint in cooling mode"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real THeaSet(unit="K")=TLooMax
    "Heat pump tracking temperature setpoint in heating mode"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TConInMin(unit="K", displayUnit="degC")
                        "Minimum condenser inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TEvaInMax(unit="K", displayUnit="degC")
                        "Maximum evaporator inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real offTim(unit="s")=12*3600
     "Heat pump off time due to the low compressor speed"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real holOnTim(unit="s")=1800
    "Heat pump hold on time"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real holOffTim(unit="s")=1800
    "Heat pump hold off time"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real minComSpe(unit="1")=0.2
    "Minimum heat pump compressor speed"
    annotation (Dialog(tab="Controls", group="Heat pump"));

  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Soil.SandStone soiDat(
    kSoi=1.1,
    cSoi=1.4E6/1800,
    dSoi=1800) "Soil data"
    annotation (Placement(transformation(extent={{-160,-160},{-140,-140}})));
  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Filling.Bentonite filDat(kFil=1.0)
    "Borehole filling data"
    annotation (Placement(transformation(extent={{-160,-120},{-140,-100}})));
  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Configuration.Template conDat(
    borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.DoubleUTubeParallel,
    mBor_flow_nominal=mBorHol_flow_nominal,
    dp_nominal=dp_nominal,
    hBor=91,
    rBor=0.075,
    dBor=0.5,
    nZon=2,
    iZon={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2},
    cooBor={{0,1.5},{3,1.5},{6,1.5},{9,1.5},{12,1.5},{1.5,4.5},{4.5,4.5},{7.5,4.5},
        {10.5,4.5},{13.5,4.5},{0,7.5},{3,7.5},{6,7.5},{9,7.5},{12,7.5},{1.5,10.5},
        {4.5,10.5},{7.5,10.5},{10.5,10.5},{13.5,10.5},{0,13.5},{3,13.5},{6,13.5},
        {9,13.5},{12,13.5},{1.5,16.5},{4.5,16.5},{7.5,16.5},{10.5,16.5},{13.5,16.5},
        {0,22.5},{5.4,22.5},{10.8,22.5},{2.7,28.5},{8.1,28.5},{13.5,28.5}},
    rTub=0.016,
    kTub=0.42,
    eTub=0.0029,
    xC=(2*((0.04/2)^2))^(1/2))
    "Construction data: the borehole height, boreholes coordinate should be updated"
    annotation (Placement(transformation(extent={{-160,-80},{-140,-60}})));
  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Borefield.Template borFieDat(
    filDat=filDat,
    soiDat=soiDat,
    conDat=conDat) "Borefield data"
    annotation (Placement(transformation(extent={{-160,-40},{-140,-20}})));
  final parameter Modelica.Units.SI.Temperature T_start=289.65
    "Initial temperature of the soil";
  final parameter Integer nZon=borFieDat.conDat.nZon
    "Total number of independent bore field zones in each borefield module";
  final parameter Integer nBor=size(borFieDat.conDat.iZon, 1)
    "Total number of boreholes in each borefield module";

  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow from the district"
    annotation (Placement(transformation(extent={{-250,-10},{-230,10}}),
      iconTransformation(extent={{-110,-10},{-90,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum
    "District loop pump speed"
    annotation (Placement(transformation(extent={{-280,100},{-240,140}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uSolTim
    "Solar time. An output from weather data"
    annotation (Placement(transformation(extent={{-280,60},{-240,100}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixAve(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Average temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-280,20},{-240,60}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-280,-60},{-240,-20}}),
        iconTransformation(extent={{-140,-90},{-100,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWetBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient wet bulb temperature"
    annotation (Placement(transformation(extent={{-280,-100},{-240,-60}}),
        iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumCirPum(quantity="Power",
      final unit="W")
    "Electrical power consumed by circulation pump"
    annotation (Placement(transformation(extent={{240,-190},{280,-150}}),
        iconTransformation(extent={{100,-100},{140,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumWat(quantity="Power",
      final unit="W")
    "Electrical power consumed by heat pump waterside pump"
    annotation (Placement(transformation(extent={{240,-160},{280,-120}}),
        iconTransformation(extent={{100,-80},{140,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QBorOut_flow(unit="W")
    "Heat flow from borefield to water"
    annotation (Placement(transformation(extent={{240,-60},{280,-20}}),
        iconTransformation(extent={{100,-120},{140,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PCom(quantity="Power",
      final unit="W")
    "Electric power consumed by compressor"
    annotation (Placement(transformation(extent={{240,-130},{280,-90}}),
        iconTransformation(extent={{100,-60},{140,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumGly(quantity="Power",
      final unit="W")
    "Electrical power consumed by glycol pump of heat pump"
    annotation (Placement(transformation(extent={{240,-100},{280,-60}}),
        iconTransformation(extent={{100,-40},{140,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHexGly(quantity="Power",
      final unit="W")
    "Electrical power consumed by the glycol pump of HEX"
    annotation (Placement(transformation(extent={{240,60},{280,100}}),
        iconTransformation(extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumDryCoo(quantity="Power",
      final unit="W")
    "Electrical power consumed by dry cool pump"
    annotation (Placement(transformation(extent={{240,90},{280,130}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PFanDryCoo(quantity="Power",
      final unit="W")
    "Electric power consumed by fan"
    annotation (Placement(transformation(extent={{240,120},{280,160}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, cent per kWh"
    annotation (Placement(transformation(extent={{240,150},{280,190}}),
        iconTransformation(extent={{100,70},{140,110}})));

  ThermalGridJBA.Networks.BaseClasses.Generations gen(
    final TLooMin=TLooMin,
    final TLooMax=TLooMax,
    final mWat_flow_nominal=mWat_flow_nominal,
    final mWat_flow_min=mWat_flow_min,
    final mHexGly_flow_nominal=mHexGly_flow_nominal,
    final mHpGly_flow_nominal=mHpGly_flow_nominal,
    final mDryCoo_flow_nominal=mDryCoo_flow_nominal,
    final dpHex_nominal=dpHex_nominal,
    final dpValve_nominal=dpValve_nominal,
    final dpDryCoo_nominal=dpDryCoo_nominal,
    final QHeaPumHea_flow_nominal=QHeaPumHea_flow_nominal,
    final TConHea_nominal=TConHea_nominal,
    final TEvaHea_nominal=TEvaHea_nominal,
    final QHeaPumCoo_flow_nominal=QHeaPumCoo_flow_nominal,
    final TConCoo_nominal=TConCoo_nominal,
    final TEvaCoo_nominal=TEvaCoo_nominal,
    final samplePeriod=samplePeriod,
    final TAppSet=TAppSet,
    final TApp=TApp,
    final minFanSpe=minFanSpe,
    kFan=0.1,
    TiFan=200,
    final TCooSet=TCooSet,
    final THeaSet=THeaSet,
    final TConInMin=TConInMin,
    final TEvaInMax=TEvaInMax,
    final offTim=offTim,
    holOnTim=holOnTim,
    holOffTim=holOffTim,
    final minComSpe=minComSpe,
    kHeaPum=0.1,
    TiHeaPum=200,
    kVal=0.1,
    TiVal=200)
    "Cooling and heating generation devices"
    annotation (Placement(transformation(extent={{-160,-10},{-140,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow to the district"
    annotation (Placement(transformation(extent={{232,-10},{252,10}}),
      iconTransformation(extent={{90,-10},{110,10}})));
  Buildings.Fluid.Geothermal.ZonedBorefields.TwoUTubes lefBorFie[2](
    redeclare each final package Medium = MediumW,
    each allowFlowReversal=false,
    each energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    each TExt0_start=T_start,
    each borFieDat=borFieDat,
    each dT_dz=0) "Borefield modules on the left edge"
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMul(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    k=1/nGenMod)
    "Split mass flow to single generation module"
    annotation (Placement(transformation(extent={{-220,-10},{-200,10}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMul1(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    k=nGenMod)
    "Sum the mass flow from single generation module to total flow"
    annotation (Placement(transformation(extent={{-100,-10},{-80,10}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMul2(
    redeclare final package Medium = MediumW,
    allowFlowReversal=false,
    k=3/nBorSec)
    "Split total flow"
    annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  Buildings.Fluid.Delays.DelayFirstOrder del3(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final m_flow_nominal=nGenMod*mWat_flow_nominal,
    nPorts=2*nZon*3+1)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=180, origin={0,10})));
  Buildings.Fluid.Geothermal.ZonedBorefields.TwoUTubes cenBorFie1[2](
    redeclare each final package Medium = MediumW,
    each allowFlowReversal=false,
    each energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    each TExt0_start=T_start,
    each borFieDat=borFieDat,
    each dT_dz=0) "Central borefield modules"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Fluid.Geothermal.ZonedBorefields.TwoUTubes rigBorFie2[2](
    redeclare each final package Medium = MediumW,
    each allowFlowReversal=false,
    each energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    each TExt0_start=T_start,
    each borFieDat=borFieDat,
    each dT_dz=0) "Borefield modules on the right edge"
    annotation (Placement(transformation(extent={{40,-60},{60,-40}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier massFlowRateMultiplier3[2*nZon](
    redeclare each final package Medium = MediumW,
    each allowFlowReversal=false,
    k=fill(nBorSec - 2, 2*nZon))
    annotation (Placement(transformation(extent={{80,-10},{100,10}})));
  Buildings.Fluid.Delays.DelayFirstOrder del1(
    redeclare final package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final m_flow_nominal=nGenMod*mWat_flow_nominal,
    nPorts=2*nZon*3+1)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=180, origin={130,10})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(k=nGenMod)
    annotation (Placement(transformation(extent={{-60,130},{-40,150}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(k=nGenMod)
    annotation (Placement(transformation(extent={{-20,100},{0,120}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(k=nGenMod)
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai3(k=nGenMod)
    annotation (Placement(transformation(extent={{20,-90},{40,-70}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai4(k=nGenMod)
    annotation (Placement(transformation(extent={{-20,-120},{0,-100}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai5(k=nGenMod)
    annotation (Placement(transformation(extent={{-60,-150},{-40,-130}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai6(k=nGenMod)
    annotation (Placement(transformation(extent={{-100,-180},{-80,-160}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort leaBorTem(redeclare final package
      Medium = MediumW,
    allowFlowReversal=false,
                        final m_flow_nominal=nGenMod*mWat_flow_nominal)
    "Temperature of waterflow leaving borefield"           annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={160,0})));
  Buildings.Fluid.Sensors.TemperatureTwoPort entBorTem(redeclare final package
      Medium = MediumW,
    allowFlowReversal=false,
                        final m_flow_nominal=nGenMod*mWat_flow_nominal)
    "Temperature of waterflow entering borefield" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-60,0})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFlo(
    redeclare final package Medium = MediumW)
    "Water flow rate into borefield"
    annotation (Placement(transformation(extent={{190,-10},{210,10}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Water flow temperature difference"
    annotation (Placement(transformation(extent={{180,30},{200,50}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul
    annotation (Placement(transformation(extent={{160,-50},{180,-30}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter heaCap(final k=4184)
    "Water specific heat capacity"
    annotation (Placement(transformation(extent={{200,-50},{220,-30}})));

equation
  connect(port_a, masFloMul.port_a) annotation (Line(
      points={{-240,0},{-220,0}},
      color={0,127,255},
      thickness=0.5));
  connect(masFloMul.port_b, gen.port_a) annotation (Line(
      points={{-200,0},{-160,0}},
      color={0,127,255},
      thickness=0.5));
  connect(gen.port_b, masFloMul1.port_a) annotation (Line(
      points={{-140,0},{-100,0}},
      color={0,127,255},
      thickness=0.5));

  connect(masFloMul2.port_b, del3.ports[2*nZon*3 + 1]) annotation (Line(
      points={{-20,0},{0,0}},
      color={0,127,255},
      thickness=0.5));
  for j in 1:2 loop
    for i in 1:nZon loop
      connect(del3.ports[(j - 1)*nZon + i], lefBorFie[j].port_a[i]) annotation
        (Line(
          points={{0,0},{20,0},{20,50},{40,50}},
          color={0,127,255},
          thickness=0.5));
      connect(lefBorFie[j].port_b[i], del1.ports[(j - 1)*nZon + i]) annotation
        (Line(
          points={{60,50},{110,50},{110,0},{130,0}},
          color={0,127,255},
          thickness=0.5));
    end for;
  end for;

  for j in 1:2 loop
    for i in 1:nZon loop
      connect(del3.ports[(j - 1 + 2)*nZon + i], cenBorFie1[j].port_a[i])
        annotation (Line(
          points={{0,0},{40,0}},
          color={0,127,255},
          thickness=0.5));
      connect(cenBorFie1[j].port_b[i], massFlowRateMultiplier3[(j - 1)*nZon + i].port_a)
        annotation (Line(
          points={{60,0},{80,0}},
          color={0,127,255},
          thickness=0.5));
      connect(massFlowRateMultiplier3[(j-1)*nZon+i].port_b, del1.ports[(j-1+2)*nZon+i])
        annotation (Line(points={{100,0},{130,0}}, color={0,127,255}, thickness=0.5));
    end for;
  end for;

  for j in 1:2 loop
    for i in 1:nZon loop
      connect(del3.ports[(j - 1 + 4)*nZon + i], rigBorFie2[j].port_a[i])
        annotation (Line(
          points={{0,0},{20,0},{20,-50},{40,-50}},
          color={0,127,255},
          thickness=0.5));
      connect(rigBorFie2[j].port_b[i], del1.ports[(j - 1 + 4)*nZon + i])
        annotation (Line(
          points={{60,-50},{110,-50},{110,0},{130,0}},
          color={0,127,255},
          thickness=0.5));
    end for;
  end for;

  connect(del1.ports[2*nZon*3+1], leaBorTem.port_a)
    annotation (Line(points={{130,0},{150,0}}, color={0,127,255},
      thickness=0.5));

  connect(uDisPum, gen.uDisPum) annotation (Line(points={{-260,120},{-170,120},{
          -170,9},{-162,9}}, color={0,0,127}));
  connect(uSolTim, gen.uSolTim) annotation (Line(points={{-260,80},{-180,80},{-180,
          7},{-162,7}}, color={0,0,127}));
  connect(TMixAve, gen.TMixAve) annotation (Line(points={{-260,40},{-190,40},{-190,
          3},{-162,3}}, color={0,0,127}));
  connect(TDryBul, gen.TDryBul) annotation (Line(points={{-260,-40},{-180,-40},{
          -180,-7},{-162,-7}}, color={0,0,127}));
  connect(TWetBul, gen.TWetBul) annotation (Line(points={{-260,-80},{-170,-80},{
          -170,-9},{-162,-9}}, color={0,0,127}));
  connect(gen.yEleRat, yEleRat) annotation (Line(points={{-138,9},{-130,9},{-130,
          170},{260,170}}, color={0,0,127}));
  connect(gai.y, PFanDryCoo)
    annotation (Line(points={{-38,140},{260,140}}, color={0,0,127}));
  connect(gai1.y, PPumDryCoo)
    annotation (Line(points={{2,110},{260,110}},  color={0,0,127}));
  connect(gai2.y, PPumHexGly)
    annotation (Line(points={{42,80},{260,80}}, color={0,0,127}));
  connect(gen.PFanDryCoo, gai.u) annotation (Line(points={{-138,7},{-122,7},{-122,
          140},{-62,140}}, color={0,0,127}));
  connect(gen.PPumDryCoo, gai1.u) annotation (Line(points={{-138,5},{-114,5},{-114,
          110},{-22,110}},color={0,0,127}));
  connect(gen.PPumHexGly, gai2.u) annotation (Line(points={{-138,3},{-106,3},{-106,
          80},{18,80}}, color={0,0,127}));
  connect(gen.PPumCirPum, gai6.u) annotation (Line(points={{-138,-9},{-130,-9},{
          -130,-170},{-102,-170}},color={0,0,127}));
  connect(gai6.y, PPumCirPum)
    annotation (Line(points={{-78,-170},{260,-170}}, color={0,0,127}));
  connect(gen.PPumHeaPumWat, gai5.u) annotation (Line(points={{-138,-7},{-122,-7},
          {-122,-140},{-62,-140}}, color={0,0,127}));
  connect(gai5.y, PPumHeaPumWat)
    annotation (Line(points={{-38,-140},{260,-140}}, color={0,0,127}));
  connect(gen.PCom, gai4.u) annotation (Line(points={{-138,-5},{-114,-5},{-114,-110},
          {-22,-110}},color={0,0,127}));
  connect(gai4.y, PCom)
    annotation (Line(points={{2,-110},{260,-110}},  color={0,0,127}));
  connect(gen.PPumHeaPumGly, gai3.u) annotation (Line(points={{-138,-3},{-106,-3},
          {-106,-80},{18,-80}},color={0,0,127}));
  connect(gai3.y, PPumHeaPumGly)
    annotation (Line(points={{42,-80},{260,-80}}, color={0,0,127}));
  connect(masFloMul1.port_b, entBorTem.port_a)
    annotation (Line(points={{-80,0},{-70,0}}, color={0,127,255},
      thickness=0.5));
  connect(entBorTem.port_b, masFloMul2.port_a)
    annotation (Line(points={{-50,0},{-40,0}}, color={0,127,255},
      thickness=0.5));
  connect(entBorTem.T, sub.u2)
    annotation (Line(points={{-60,11},{-60,34},{178,34}}, color={0,0,127}));
  connect(leaBorTem.T, sub.u1)
    annotation (Line(points={{160,11},{160,46},{178,46}}, color={0,0,127}));
  connect(leaBorTem.port_b, senMasFlo.port_a)
    annotation (Line(points={{170,0},{190,0}}, color={0,127,255}));
  connect(senMasFlo.port_b, port_b)
    annotation (Line(points={{210,0},{242,0}}, color={0,127,255}));
  connect(sub.y, mul.u2) annotation (Line(points={{202,40},{208,40},{208,60},{144,
          60},{144,-46},{158,-46}}, color={0,0,127}));
  connect(senMasFlo.m_flow, mul.u1) annotation (Line(points={{200,11},{200,20},{
          148,20},{148,-34},{158,-34}}, color={0,0,127}));
  connect(mul.y, heaCap.u)
    annotation (Line(points={{182,-40},{198,-40}}, color={0,0,127}));
  connect(heaCap.y, QBorOut_flow)
    annotation (Line(points={{222,-40},{260,-40}}, color={0,0,127}));
  annotation (defaultComponentName="cenPla",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={
                                Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
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
          fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-240,-180},{240,180}})));
end CentralPlantMultiFlow;
