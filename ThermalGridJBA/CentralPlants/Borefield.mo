within ThermalGridJBA.CentralPlants;
model Borefield "Borefield model"
  extends Modelica.Blocks.Icons.Block;
  replaceable package Medium = Buildings.Media.Water "Water";

  parameter Boolean useDummy_borefield = false
    "Boolean flag to use dummy borefield for debugging only";
  /////////////////////////////////////////////////
  constant Medium.SpecificHeatCapacity cpFlu_nominal = Medium.cp_const
    "Constant specific heat capacity at constant pressure"
    annotation (Dialog(group="Borefield"));

  /////////////////////////////////////////////////
  // Borefield configuration and mass flow rate sizing
  constant Integer nBorSec = 33
    "Number of borefield sectors. Each section includes 2 modules with 2 zones each, and the number should be divisible by 3"
    annotation (Dialog(group="Borefield"));
  constant Integer iEdgZon[:] = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4}
    "Index of boreholes of edge zone (at the left short edge, with two dummy zones to the right)"
    annotation (Dialog(group="Borefield"));
  constant Integer iCorZon[:] = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4}
    "Index of boreholes of core zone (at the core with two dummy zones to the left and two dummy zones to the right)"
    annotation (Dialog(group="Borefield"));
  constant Integer nEdgZon=4
    "Total number of independent bore field zones in edge borefield"
    annotation (Dialog(group="Borefield"));
  constant Integer nCorZon=4
    "Total number of independent bore field zones in core borefield"
    annotation (Dialog(group="Borefield"));

  constant Integer nBorPerSeg = sum(if iCorZon[i] == 1 then 1 else 0 for i in 1:size(iCorZon, 1))
    "Number of bores in perimeter per segment. This counts the top and bottom edge"
    annotation (Dialog(group="Borefield"));
  constant Integer nBorCenSeg = sum(if iCorZon[i] == 2 then 1 else 0 for i in 1:size(iCorZon, 1))
    "Number of bores in center per segment. This counts the top and bottom edge"
    annotation (Dialog(group="Borefield"));
  constant Integer nDumSecEdg = 1
    "Number of dummy sections for core of borefield";
  constant Integer nDumSecCor = 2
    "Number of dummy sections for core of borefield";
  constant Integer nBorPerTot = nBorPerSeg * nBorSec
    "Number of bores in perimeter for whole borefield. This counts the top and bottom edge"
    annotation (Dialog(group="Borefield"));
  constant Integer nBorCenTot = nBorCenSeg * nBorSec
    "Number of bores in center for whole borefield. This counts the top and bottom edge"
    annotation (Dialog(group="Borefield"));

  parameter Modelica.Units.SI.Height hBor=91 "Total height of the borehole"
      annotation (Dialog(group="Borefield"));
  parameter Real qBorSpe_flow_nominal(
    final unit="W/m",
    min=30, max=50) = 40 "Specific heat flow rate per meter of borehole"
    annotation (Dialog(group="Borefield"));
  parameter Modelica.Units.SI.TemperatureDifference dTBor_nominal(min=4) = 4
    "Inlet minus outlet design temperature difference"
    annotation (Dialog(group="Borefield"));
  parameter Modelica.Units.SI.MassFlowRate mBor_flow_nominal = hBor*qBorSpe_flow_nominal/cpFlu_nominal/dTBor_nominal
    "Design mass flow rate per borehole, to be distributed to the double U-pipe"
    annotation (Dialog(group="Borefield"));

  final parameter Modelica.Units.SI.Radius rTub=0.016
    "Outer radius of the tubes"
    annotation (Dialog(group="Borefield"));
  final parameter Modelica.Units.SI.Length eTub=0.0029 "Thickness of a tube"
    annotation (Dialog(group="Borefield"));
  final parameter Modelica.Units.SI.Velocity vFlu = mBor_flow_nominal/Medium.d_const/(rTub-eTub)^2/Modelica.Constants.pi / 2
    "Flow velocity in tube at design conditions. Divided by 2 to account for double-U tube"
    annotation (Dialog(group="Borefield"));
  final parameter Medium.ThermodynamicState sta_nominal=Medium.setState_pTX(
      T=Medium.T_default, p=Medium.p_default, X=Medium.X_default);
  final parameter Modelica.Units.SI.ReynoldsNumber Re =
    Modelica.Fluid.Pipes.BaseClasses.CharacteristicNumbers.ReynoldsNumber(
      v = vFlu,
      rho = Medium.density(sta_nominal),
      D = 2*(rTub-eTub),
      mu = Medium.dynamicViscosity(sta_nominal)) "Reynolds number at design flow rate"
    annotation (Dialog(group="Borefield"));
  final parameter Modelica.Units.SI.PressureDifference dp_nominal(
    displayUnit="Pa") =
    Modelica.Fluid.Pipes.BaseClasses.WallFriction.QuadraticTurbulent.pressureLoss_m_flow(
      m_flow=mBor_flow_nominal,
      rho_a=Medium.density(sta_nominal),
      rho_b=Medium.density(sta_nominal),
      mu_a=Medium.dynamicViscosity(sta_nominal),
      mu_b=Medium.dynamicViscosity(sta_nominal),
      diameter=2*(rTub-eTub),
      length=2*hBor,
      roughness=0.0015e-3)
     "Pressure loss of pipe at design conditions, accounting for down-tube an up-tube length"
    annotation (Dialog(group="Borefield"));
  final parameter Real dpSpe(final unit="Pa/m") = dp_nominal/2/hBor
    "Specific pressure drop per meter"
    annotation (Dialog(group="Borefield"));

  parameter Modelica.Units.SI.MassFlowRate mPer_flow_nominal=mBor_flow_nominal * nBorPerTot
    "Nominal water mass flow rate for all bores in perimeter"
      annotation (Dialog(group="Borefield"));

  parameter Modelica.Units.SI.MassFlowRate mCen_flow_nominal=mBor_flow_nominal * nBorCenTot
    "Nominal water mass flow rate for all bores in center"
      annotation (Dialog(group="Borefield"));

  parameter Modelica.Units.SI.Temperature TSoi_start
    "Initial temperature of the soil of borefield";

  /////////////////////////////////////////////////
  // Connectors
  Modelica.Fluid.Interfaces.FluidPort_a portPer_a(
    redeclare final package Medium = Medium)
    "Fluid connector for perimeter of borefield"
    annotation (
      Placement(transformation(extent={{-110,30},{-90,50}}),
        iconTransformation(extent={{-110,70},{-90,90}})));

  Modelica.Fluid.Interfaces.FluidPort_b portPer_b(redeclare final package
      Medium = Medium) "Fluid connector outlet of perimeter borefield zones"
    annotation (Placement(transformation(extent={{90,40},{110,60}}),
        iconTransformation(extent={{90,70},{110,90}})));

  Modelica.Fluid.Interfaces.FluidPort_a portCen_a(redeclare final package
      Medium = Medium) "Fluid connector for center of borefield"
    annotation (
      Placement(transformation(extent={{-110,-50},{-90,-30}}),
        iconTransformation(extent={{-110,-90},{-90,-70}})));
  Modelica.Fluid.Interfaces.FluidPort_b portCen_b(redeclare final package
      Medium = Medium) "Fluid connector for center of the borefield"
                                                                   annotation
    (Placement(transformation(extent={{90,-70},{110,-50}}), iconTransformation(
          extent={{88,-90},{108,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QPer_flow(
    final unit="W")
    "Perimeter heat flow rate" annotation (Placement(transformation(extent={{100,10},
            {140,50}}),    iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QCen_flow(
    final unit="W") "Center heat flow rate"
                            annotation (Placement(transformation(extent={{100,-50},
            {140,-10}}),iconTransformation(extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput qBorSpe_flow(final unit="W/m")
    "Heat flow rate per meter of borehole" annotation (Placement(transformation(
          extent={{100,-20},{140,20}}), iconTransformation(extent={{100,-20},{
            140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput qBorSpeCen_flow(final unit="W/m")
    "Heat flow rate per meter of borehole for center of borefield" annotation (
      Placement(transformation(extent={{100,-100},{140,-60}}),
        iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput qBorSpePer_flow(final unit="W/m")
    "Heat flow rate per meter of borehole for perimeter of borefield"
    annotation (Placement(transformation(extent={{100,60},{140,100}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Modelica.Blocks.Math.Add sumQPer_flow(
    u1(final unit="W"),
    u2(final unit="W"),
    y(final unit="W"),
    k1=2,
    k2=nBorSec - 2) "Perimeter borefield heat flow rates"
    annotation (Placement(transformation(extent={{10,20},{30,40}})));
  Modelica.Blocks.Math.Add sumQCen_flow(
    u1(final unit="W"),
    u2(final unit="W"),
    y(final unit="W"),
    k1=2,
    k2=nBorSec - 2)    "Center borefield heat flow rates"
    annotation (Placement(transformation(extent={{10,-40},{30,-20}})));

  BaseClasses.BorefieldSection edgSec(
    redeclare package Medium = Medium,
    final nDumSec=nDumSecEdg,
    final borFieDat=edgBorFieDat,
    final TSoi_start=TSoi_start,
    final dp_nominal=dp_nominal,
    final mPer_flow_nominal=mPer_flow_nominal/nBorSec,
    final mCen_flow_nominal=mCen_flow_nominal/nBorSec)
    if not useDummy_borefield
    "Edge section of borefield" annotation (Placement(transformation(rotation=0,
          extent={{-50,30},{-30,50}})));

  BaseClasses.BorefieldSection corSec(
    redeclare package Medium = Medium,
    final nDumSec=nDumSecCor,
    final borFieDat=corBorFieDat,
    final TSoi_start=TSoi_start,
    final dp_nominal=dp_nominal,
    final mPer_flow_nominal=mPer_flow_nominal/nBorSec,
    final mCen_flow_nominal=mCen_flow_nominal/nBorSec)
    if not useDummy_borefield
    "Core section of borefield" annotation (Placement(transformation(rotation=0,
          extent={{-50,-50},{-30,-30}})));

  final parameter ThermalGridJBA.Data.SoilData soiDat "Soil data"
    annotation (Placement(transformation(extent={{-40,82},{-20,102}})));
  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Filling.Bentonite filDat(kFil=1.0)
    "Borehole filling data"
    annotation (Placement(transformation(extent={{-90,82},{-70,102}})));

  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Configuration.Template corConDat(
    borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.DoubleUTubeParallel,
    final mBor_flow_nominal=mBor_flow_nominal*ones(4) "per borehole in each zone",
    final dp_nominal=dp_nominal*ones(4),
    final hBor=hBor,
    rBor=0.075,
    dBor=0.5,
    nZon=nCorZon,
    iZon=iCorZon,
    cooBor=[15,0; 20.4,0; 25.8,0; 17.7,6; 23.1,6; 28.5,6; 15,51; 20.4,51; 25.8,51;
        17.7,57; 23.1,57; 28.5,57; 15,12; 18,12; 21,12; 24,12; 27,12; 16.5,15; 19.5,
        15; 22.5,15; 25.5,15; 28.5,15; 15,18; 18,18; 21,18; 24,18; 27,18; 16.5,21;
        19.5,21; 22.5,21; 25.5,21; 28.5,21; 15,24; 18,24; 21,24; 24,24; 27,24; 16.5,
        27; 19.5,27; 22.5,27; 25.5,27; 28.5,27; 15,30; 18,30; 21,30; 24,30; 27,30;
        16.5,33; 19.5,33; 22.5,33; 25.5,33; 28.5,33; 15,36; 18,36; 21,36; 24,36;
        27,36; 16.5,39; 19.5,39; 22.5,39; 25.5,39; 28.5,39; 15,42; 18,42; 21,42;
        24,42; 27,42; 16.5,45; 19.5,45; 22.5,45; 25.5,45; 28.5,45; 0,0; 5.4,0; 10.8,
        0; 2.7,6; 8.1,6; 13.5,6; 0,51; 5.4,51; 10.8,51; 2.7,57; 8.1,57; 13.5,57;
        30,0; 35.4,0; 40.8,0; 32.7,6; 38.1,6; 43.5,6; 30,51; 35.4,51; 40.8,51; 32.7,
        57; 38.1,57; 43.5,57; 0,12; 3,12; 6,12; 9,12; 12,12; 1.5,15; 4.5,15; 7.5,
        15; 10.5,15; 13.5,15; 0,18; 3,18; 6,18; 9,18; 12,18; 1.5,21; 4.5,21; 7.5,
        21; 10.5,21; 13.5,21; 0,24; 3,24; 6,24; 9,24; 12,24; 1.5,27; 4.5,27; 7.5,
        27; 10.5,27; 13.5,27; 0,30; 3,30; 6,30; 9,30; 12,30; 1.5,33; 4.5,33; 7.5,
        33; 10.5,33; 13.5,33; 0,36; 3,36; 6,36; 9,36; 12,36; 1.5,39; 4.5,39; 7.5,
        39; 10.5,39; 13.5,39; 0,42; 3,42; 6,42; 9,42; 12,42; 1.5,45; 4.5,45; 7.5,
        45; 10.5,45; 13.5,45; 30,12; 33,12; 36,12; 39,12; 42,12; 31.5,15; 34.5,15;
        37.5,15; 40.5,15; 43.5,15; 30,18; 33,18; 36,18; 39,18; 42,18; 31.5,21; 34.5,
        21; 37.5,21; 40.5,21; 43.5,21; 30,24; 33,24; 36,24; 39,24; 42,24; 31.5,27;
        34.5,27; 37.5,27; 40.5,27; 43.5,27; 30,30; 33,30; 36,30; 39,30; 42,30; 31.5,
        33; 34.5,33; 37.5,33; 40.5,33; 43.5,33; 30,36; 33,36; 36,36; 39,36; 42,36;
        31.5,39; 34.5,39; 37.5,39; 40.5,39; 43.5,39; 30,42; 33,42; 36,42; 39,42;
        42,42; 31.5,45; 34.5,45; 37.5,45; 40.5,45; 43.5,45],
    final rTub=rTub,
    kTub=0.42,
    final eTub=eTub,
    xC=(2*((0.04/2)^2))^(1/2))
    "Construction data for the core: the borehole height, boreholes coordinate should be updated"
    annotation (Placement(transformation(extent={{-40,-20},{-20,0}})));

  final parameter
    Buildings.Fluid.Geothermal.ZonedBorefields.Data.Borefield.Template edgBorFieDat(
    filDat=filDat,
    soiDat=soiDat,
    conDat=edgConDat)
    "Edge borefield data"
    annotation (Placement(transformation(extent={{-90,60},{-70,80}})));

  final parameter
    Buildings.Fluid.Geothermal.ZonedBorefields.Data.Borefield.Template corBorFieDat(
    filDat=filDat,
    soiDat=soiDat,
    conDat=corConDat) "Core borefield data"
    annotation (Placement(transformation(extent={{-90,-20},{-70,0}})));

  final parameter
    Buildings.Fluid.Geothermal.ZonedBorefields.Data.Configuration.Template edgConDat(
    borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.DoubleUTubeParallel,
    final mBor_flow_nominal=mBor_flow_nominal*ones(4),
    final dp_nominal=dp_nominal*ones(4),
    final hBor=hBor,
    rBor=0.075,
    dBor=0.5,
    nZon=nEdgZon,
    iZon=iEdgZon,
    cooBor=[0,0; 5.4,0; 10.8,0; 2.7,6; 8.1,6; 13.5,6; 0,51; 5.4,51; 10.8,51; 2.7,
        57; 8.1,57; 13.5,57; 0,12; 3,12; 6,12; 9,12; 12,12; 1.5,15; 4.5,15; 7.5,
        15; 10.5,15; 13.5,15; 0,18; 3,18; 6,18; 9,18; 12,18; 1.5,21; 4.5,21; 7.5,
        21; 10.5,21; 13.5,21; 0,24; 3,24; 6,24; 9,24; 12,24; 1.5,27; 4.5,27; 7.5,
        27; 10.5,27; 13.5,27; 0,30; 3,30; 6,30; 9,30; 12,30; 1.5,33; 4.5,33; 7.5,
        33; 10.5,33; 13.5,33; 0,36; 3,36; 6,36; 9,36; 12,36; 1.5,39; 4.5,39; 7.5,
        39; 10.5,39; 13.5,39; 0,42; 3,42; 6,42; 9,42; 12,42; 1.5,45; 4.5,45; 7.5,
        45; 10.5,45; 13.5,45; 15,0; 20.4,0; 25.8,0; 17.7,6; 23.1,6; 28.5,6; 15,51;
        20.4,51; 25.8,51; 17.7,57; 23.1,57; 28.5,57; 15,12; 18,12; 21,12; 24,12;
        27,12; 16.5,15; 19.5,15; 22.5,15; 25.5,15; 28.5,15; 15,18; 18,18; 21,18;
        24,18; 27,18; 16.5,21; 19.5,21; 22.5,21; 25.5,21; 28.5,21; 15,24; 18,24;
        21,24; 24,24; 27,24; 16.5,27; 19.5,27; 22.5,27; 25.5,27; 28.5,27; 15,30;
        18,30; 21,30; 24,30; 27,30; 16.5,33; 19.5,33; 22.5,33; 25.5,33; 28.5,33;
        15,36; 18,36; 21,36; 24,36; 27,36; 16.5,39; 19.5,39; 22.5,39; 25.5,39; 28.5,
        39; 15,42; 18,42; 21,42; 24,42; 27,42; 16.5,45; 19.5,45; 22.5,45; 25.5,45;
        28.5,45],
    final rTub=rTub,
    kTub=0.42,
    final eTub=eTub,
    xC=(2*((0.04/2)^2))^(1/2))
    "Construction data for the edge: the borehole height, boreholes coordinate should be updated"
    annotation (Placement(transformation(extent={{-40,60},{-20,80}})));

  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMulEntPer(
    redeclare final package Medium = Medium,
    allowFlowReversal=false,
    k=2/nBorSec)
    "Split total flow to each segment along the long length of the borefield. Factor 2 because the flow is split into two different models."
    annotation (Placement(transformation(extent={{-88,30},{-68,50}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMulLeaEdgPer(
    redeclare each final package Medium = Medium,
    each allowFlowReversal=false,
    k=2) "Mass flow rate multiplier at outlet of edge perimeter"
    annotation (Placement(transformation(extent={{40,70},{60,90}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMulEntCen(
    redeclare final package Medium = Medium,
    allowFlowReversal=false,
    k=2/nBorSec)
    "Split total flow to each segment along the long length of the borefield. Factor 2 because the flow is split into two different models."
    annotation (Placement(transformation(extent={{-90,-50},{-70,-30}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMulLeaCorPer(
    redeclare each final package Medium = Medium,
    each allowFlowReversal=false,
    k=nBorSec - 2) "Mass flow rate multiplier at outlet of core perimeter"
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMulLeaEdgCen(
    redeclare each final package Medium = Medium,
    each allowFlowReversal=false,
    k=2) "Mass flow rate multiplier at outlet of edge center"
    annotation (Placement(transformation(extent={{40,-60},{60,-40}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMulLeaCorCen(
    redeclare each final package Medium = Medium,
    each allowFlowReversal=false,
    k=nBorSec - 2) "Mass flow rate multiplier at outlet of core perimeter"
    annotation (Placement(transformation(extent={{40,-90},{60,-70}})));

  BaseClasses.DummyBorefield edgDummy(redeclare package Medium = Medium, final
      m_flow_nominal=mPer_flow_nominal) if useDummy_borefield
    "Dummy borefield for edge (for development only)"
    annotation (Placement(transformation(extent={{-50,0},{-30,20}})));
  BaseClasses.DummyBorefield corDummy(redeclare package Medium = Medium, final
      m_flow_nominal=mPer_flow_nominal) if useDummy_borefield
    "Dummy borefield for core (for development only)"
    annotation (Placement(transformation(extent={{-50,-80},{-30,-60}})));
protected
  Buildings.Controls.OBC.CDL.Reals.Add addQBor_flow
    "Add borefield section heat flow rates"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiTot(
    final k=1/((nBorPerTot + nBorCenTot)*hBor))
    "Unit heat transfer between boreholes and ground"
    annotation (Placement(transformation(extent={{72,-10},{92,10}})));

  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiCen(
    final k=1/(nBorCenTot*hBor)) "Unit heat transfer between boreholes and ground"
    annotation (Placement(transformation(extent={{72,-90},{92,-70}})));

  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiPer(final k=1/(nBorPerTot*hBor))
  "Unit heat transfer between boreholes and ground"
    annotation (Placement(transformation(extent={{72,70},{92,90}})));

equation
  // Added test on time so translation does not stop because the condition is always violated
  if useDummy_borefield and time >= -10*365*24*3600 then
  assert(not useDummy_borefield, "*** Warning. Borefield is not realistic, for debugging purposes only.",
    level = AssertionLevel.warning);
  end if;

  connect(edgSec.QPer_flow, sumQPer_flow.u1)
    annotation (Line(points={{-28,46},{4,46},{4,36},{8,36}}, color={0,0,127}));
  connect(corSec.QPer_flow, sumQPer_flow.u2) annotation (Line(points={{-28,-34},
          {4,-34},{4,24},{8,24}}, color={0,0,127}));
  connect(edgSec.QCor_flow, sumQCen_flow.u1) annotation (Line(points={{-28,43},{
          0,43},{0,-24},{8,-24}},
                                color={0,0,127}));
  connect(corSec.QCor_flow, sumQCen_flow.u2) annotation (Line(points={{-28,-37},
          {0,-37},{0,-36},{8,-36}},   color={0,0,127}));
  connect(sumQCen_flow.y, QCen_flow)
    annotation (Line(points={{31,-30},{120,-30}}, color={0,0,127}));
  connect(portCen_a,masFloMulEntCen. port_a)
    annotation (Line(points={{-100,-40},{-90,-40}}, color={0,127,255}));
  connect(portPer_a, masFloMulEntPer.port_a)
    annotation (Line(points={{-100,40},{-88,40}}, color={0,127,255}));
  connect(edgSec.portPer_a, masFloMulEntPer.port_b) annotation (Line(points={{-50,
          48},{-60,48},{-60,40},{-68,40}}, color={0,127,255}));
  connect(corSec.portPer_a, masFloMulEntPer.port_b) annotation (Line(points={{-50,
          -32},{-60,-32},{-60,40},{-68,40}}, color={0,127,255}));
  connect(masFloMulEntCen.port_b,edgSec.portCen_a)  annotation (Line(points={{-70,
          -40},{-56,-40},{-56,32},{-50,32}}, color={0,127,255}));
  connect(masFloMulEntCen.port_b,corSec.portCen_a)  annotation (Line(points={{-70,
          -40},{-56,-40},{-56,-48},{-50,-48}}, color={0,127,255}));
  connect(sumQPer_flow.y, QPer_flow)
    annotation (Line(points={{31,30},{120,30}}, color={0,0,127}));
  connect(edgSec.portPer_b, masFloMulLeaEdgPer.port_a) annotation (Line(points={{-30,48},
          {-10,48},{-10,80},{40,80}},       color={0,127,255}));
  connect(corSec.portPer_b, masFloMulLeaCorPer.port_a) annotation (Line(points={{-30,-32},
          {-4,-32},{-4,50},{40,50}},            color={0,127,255}));
  connect(edgSec.portCen_b, masFloMulLeaEdgCen.port_a) annotation (Line(points={{-30.2,
          32},{-6,32},{-6,-50},{40,-50}},         color={0,127,255}));
  connect(corSec.portCen_b, masFloMulLeaCorCen.port_a) annotation (Line(points={{-30.2,
          -48},{-10,-48},{-10,-80},{40,-80}},       color={0,127,255}));
  connect(masFloMulLeaEdgCen.port_b, portCen_b) annotation (Line(points={{60,-50},
          {64,-50},{64,-60},{100,-60}},      color={0,127,255}));
  connect(masFloMulLeaCorCen.port_b, portCen_b) annotation (Line(points={{60,-80},
          {72,-80},{72,-60},{100,-60}},      color={0,127,255}));
  connect(masFloMulLeaEdgPer.port_b, portPer_b) annotation (Line(points={{60,80},
          {66,80},{66,50},{100,50}}, color={0,127,255}));
  connect(masFloMulLeaCorPer.port_b, portPer_b)
    annotation (Line(points={{60,50},{100,50}}, color={0,127,255}));
  connect(corDummy.portPer_a, masFloMulEntPer.port_b) annotation (Line(points={{
          -50,-62},{-60,-62},{-60,40},{-68,40}}, color={0,127,255}));
  connect(corDummy.portCor_a, masFloMulEntCen.port_b) annotation (Line(points={{
          -50,-78},{-64,-78},{-64,-40},{-70,-40}}, color={0,127,255}));
  connect(edgDummy.portPer_a, masFloMulEntPer.port_b) annotation (Line(points={{-50,18},
          {-64,18},{-64,40},{-68,40}},         color={0,127,255}));
  connect(edgDummy.portCor_a, masFloMulEntCen.port_b) annotation (Line(points={{-50,2},
          {-64,2},{-64,-40},{-70,-40}},        color={0,127,255}));
  connect(edgDummy.portPer_b, masFloMulLeaEdgPer.port_a) annotation (Line(
        points={{-30,18},{-10,18},{-10,80},{40,80}}, color={0,127,255}));
  connect(edgDummy.portCor_b, masFloMulLeaEdgCen.port_a) annotation (Line(
        points={{-30.2,2},{-6,2},{-6,-50},{40,-50}}, color={0,127,255}));
  connect(corDummy.portPer_b, masFloMulLeaCorPer.port_a) annotation (Line(
        points={{-30,-62},{-4,-62},{-4,50},{40,50}}, color={0,127,255}));
  connect(corDummy.portCor_b, masFloMulLeaCorCen.port_a) annotation (Line(
        points={{-30.2,-78},{-10,-78},{-10,-80},{40,-80}},
                                                         color={0,127,255}));
  connect(sumQPer_flow.u1, edgDummy.QPer_flow) annotation (Line(points={{8,36},{
          -18,36},{-18,16},{-28,16}}, color={0,0,127}));
  connect(sumQPer_flow.u2, corDummy.QPer_flow) annotation (Line(points={{8,24},{
          4,24},{4,-64},{-28,-64}}, color={0,0,127}));
  connect(sumQCen_flow.u1, edgDummy.QCor_flow)
    annotation (Line(points={{8,-24},{0,-24},{0,13},{-28,13}},
                                                             color={0,0,127}));
  connect(corDummy.QCor_flow, sumQCen_flow.u2) annotation (Line(points={{-28,-67},
          {0,-67},{0,-36},{8,-36}}, color={0,0,127}));
  connect(sumQPer_flow.y, addQBor_flow.u1)
    annotation (Line(points={{31,30},{34,30},{34,6},{38,6}}, color={0,0,127}));
  connect(sumQCen_flow.y, addQBor_flow.u2) annotation (Line(points={{31,-30},{34,
          -30},{34,-6},{38,-6}}, color={0,0,127}));
  connect(addQBor_flow.y, gaiTot.u)
    annotation (Line(points={{62,0},{70,0}}, color={0,0,127}));
  connect(gaiTot.y, qBorSpe_flow)
    annotation (Line(points={{94,0},{120,0}}, color={0,0,127}));
  connect(gaiCen.y, qBorSpeCen_flow)
    annotation (Line(points={{94,-80},{120,-80}},  color={0,0,127}));
  connect(gaiPer.y, qBorSpePer_flow)
    annotation (Line(points={{94,80},{120,80}},  color={0,0,127}));
  connect(gaiCen.u, sumQCen_flow.y) annotation (Line(points={{70,-80},{68,-80},
          {68,-30},{31,-30}},color={0,0,127}));
  connect(gaiPer.u, sumQPer_flow.y) annotation (Line(points={{70,80},{68,80},{
          68,30},{31,30}},
                        color={0,0,127}));
  annotation (defaultComponentName="borFie",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={
        Rectangle(
          extent={{-86,94},{86,-88}},
          lineColor={0,0,0},
          fillColor={234,210,210},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-72,82},{-44,54}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-34,82},{-6,54}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{4,82},{32,54}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{42,82},{70,54}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-34,-50},{-6,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{4,-50},{32,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{42,-50},{70,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-72,-50},{-44,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-34,-18},{-6,-46}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{4,-18},{32,-46}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{40,-18},{68,-46}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-72,-18},{-44,-46}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-34,14},{-6,-14}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{4,14},{32,-14}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{42,14},{70,-14}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-72,14},{-44,-14}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-70,48},{-42,20}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-32,48},{-4,20}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{6,48},{34,20}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{42,48},{70,20}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid)}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-100,-100},{100,100}})));
end Borefield;
