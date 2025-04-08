within ThermalGridJBA.CentralPlants.BaseClasses;
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
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4}
    "Index of boreholes of edge zone (at the left short edge, with two dummy zones to the right)"
    annotation (Dialog(group="Borefield"));
  constant Integer iCorZon[:] = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4}
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

  final parameter Modelica.Units.SI.Temperature T_start=289.65
    "Initial temperature of the soil";

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
    annotation (Placement(transformation(extent={{90,30},{110,50}}),
        iconTransformation(extent={{90,70},{110,90}})));

  Modelica.Fluid.Interfaces.FluidPort_a portCen_a(redeclare final package
      Medium = Medium) "Fluid connector for center of borefield"
                                                               annotation (
      Placement(transformation(extent={{-110,-50},{-90,-30}}),
        iconTransformation(extent={{-110,-90},{-90,-70}})));
  Modelica.Fluid.Interfaces.FluidPort_b portCen_b(redeclare final package
      Medium = Medium) "Fluid connector for center of the borefield"
                                                                   annotation
    (Placement(transformation(extent={{90,-50},{110,-30}}), iconTransformation(
          extent={{88,-90},{108,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QPer_flow(
    final unit="W")
    "Perimeter heat flow rate" annotation (Placement(transformation(extent={{100,
            0},{140,40}}), iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QCen_flow(
    final unit="W")
    "Center heat flow rate" annotation (Placement(transformation(extent={{100,-30},
            {140,10}}), iconTransformation(extent={{100,-10},{140,30}})));

  Modelica.Blocks.Math.Add sumQPer_flow(
    u1(final unit="W"),
    u2(final unit="W"),
    y(final unit="W"),
    k1=2,
    k2=nBorSec - 2) "Perimeter borefield heat flow rates"
    annotation (Placement(transformation(extent={{10,10},{30,30}})));
  Modelica.Blocks.Math.Add sumQCen_flow(
    u1(final unit="W"),
    u2(final unit="W"),
    y(final unit="W"),
    k1=2,
    k2=nBorSec - 2)    "Center borefield heat flow rates"
    annotation (Placement(transformation(extent={{10,-20},{30,0}})));

  BorefieldSection edgSec(
    redeclare package Medium = Medium,
    final nDumSec=2,
    final borFieDat=edgBorFieDat,
    final nBorSec=nBorSec,
    final T_start=T_start)
    if not useDummy_borefield
    "Edge section of borefield"
    annotation (Placement(
        transformation(rotation=0, extent={{-50,30},{-30,50}})));

  BorefieldSection corSec(
    redeclare package Medium = Medium,
    final nDumSec=4,
    final borFieDat=corBorFieDat,
    final nBorSec=nBorSec,
    final T_start=T_start)
    if not useDummy_borefield
    "Core section of borefield" annotation (Placement(
        transformation(rotation=0, extent={{-50,-50},{-30,-30}})));

  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Soil.SandStone soiDat(
    kSoi=1.1,
    cSoi=1.4E6/1800,
    dSoi=1800) "Soil data"
    annotation (Placement(transformation(extent={{-40,82},{-20,102}})));
  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Filling.Bentonite filDat(kFil=1.0)
    "Borehole filling data"
    annotation (Placement(transformation(extent={{-88,84},{-68,104}})));

  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Configuration.Template corConDat(
    borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.DoubleUTubeParallel,
    final mBor_flow_nominal=mBor_flow_nominal*ones(4),
    final dp_nominal=dp_nominal*ones(4),
    final hBor=hBor,
    rBor=0.075,
    dBor=0.5,
    nZon=nCorZon,
    iZon=iCorZon,
    cooBor=[30,0; 35.4,0; 40.8,0; 32.7,6; 38.1,6; 43.5,6; 30,51; 35.4,51; 40.8,51;
        32.7,57; 38.1,57; 43.5,57; 30,12; 33,12; 36,12; 39,12; 42,12; 31.5,15; 34.5,
        15; 37.5,15; 40.5,15; 43.5,15; 30,18; 33,18; 36,18; 39,18; 42,18; 31.5,21;
        34.5,21; 37.5,21; 40.5,21; 43.5,21; 30,24; 33,24; 36,24; 39,24; 42,24; 31.5,
        27; 34.5,27; 37.5,27; 40.5,27; 43.5,27; 30,30; 33,30; 36,30; 39,30; 42,30;
        31.5,33; 34.5,33; 37.5,33; 40.5,33; 43.5,33; 30,36; 33,36; 36,36; 39,36;
        42,36; 31.5,39; 34.5,39; 37.5,39; 40.5,39; 43.5,39; 30,42; 33,42; 36,42;
        39,42; 42,42; 31.5,45; 34.5,45; 37.5,45; 40.5,45; 43.5,45; 0,0; 5.4,0; 10.8,
        0; 2.7,6; 8.1,6; 13.5,6; 0,51; 5.4,51; 10.8,51; 2.7,57; 8.1,57; 13.5,57;
        15,0; 45,0; 60,0; 20.4,0; 50.4,0; 65.4,0; 25.8,0; 55.8,0; 70.8,0; 17.7,6;
        47.7,6; 62.7,6; 23.1,6; 53.1,6; 68.1,6; 28.5,6; 58.5,6; 73.5,6; 15,51; 45,
        51; 60,51; 20.4,51; 50.4,51; 65.4,51; 25.8,51; 55.8,51; 70.8,51; 17.7,57;
        47.7,57; 62.7,57; 23.1,57; 53.1,57; 68.1,57; 28.5,57; 58.5,57; 73.5,57;
        0,12; 3,12; 6,12; 9,12; 12,12; 1.5,15; 4.5,15; 7.5,15; 10.5,15; 13.5,15;
        0,18; 3,18; 6,18; 9,18; 12,18; 1.5,21; 4.5,21; 7.5,21; 10.5,21; 13.5,21;
        0,24; 3,24; 6,24; 9,24; 12,24; 1.5,27; 4.5,27; 7.5,27; 10.5,27; 13.5,27;
        0,30; 3,30; 6,30; 9,30; 12,30; 1.5,33; 4.5,33; 7.5,33; 10.5,33; 13.5,33;
        0,36; 3,36; 6,36; 9,36; 12,36; 1.5,39; 4.5,39; 7.5,39; 10.5,39; 13.5,39;
        0,42; 3,42; 6,42; 9,42; 12,42; 1.5,45; 4.5,45; 7.5,45; 10.5,45; 13.5,45;
        15,12; 45,12; 60,12; 18,12; 48,12; 63,12; 21,12; 51,12; 66,12; 24,12; 54,
        12; 69,12; 27,12; 57,12; 72,12; 16.5,15; 46.5,15; 61.5,15; 19.5,15; 49.5,
        15; 64.5,15; 22.5,15; 52.5,15; 67.5,15; 25.5,15; 55.5,15; 70.5,15; 28.5,
        15; 58.5,15; 73.5,15; 15,18; 45,18; 60,18; 18,18; 48,18; 63,18; 21,18; 51,
        18; 66,18; 24,18; 54,18; 69,18; 27,18; 57,18; 72,18; 16.5,21; 46.5,21; 61.5,
        21; 19.5,21; 49.5,21; 64.5,21; 22.5,21; 52.5,21; 67.5,21; 25.5,21; 55.5,
        21; 70.5,21; 28.5,21; 58.5,21; 73.5,21; 15,24; 45,24; 60,24; 18,24; 48,24;
        63,24; 21,24; 51,24; 66,24; 24,24; 54,24; 69,24; 27,24; 57,24; 72,24; 16.5,
        27; 46.5,27; 61.5,27; 19.5,27; 49.5,27; 64.5,27; 22.5,27; 52.5,27; 67.5,
        27; 25.5,27; 55.5,27; 70.5,27; 28.5,27; 58.5,27; 73.5,27; 15,30; 45,30;
        60,30; 18,30; 48,30; 63,30; 21,30; 51,30; 66,30; 24,30; 54,30; 69,30; 27,
        30; 57,30; 72,30; 16.5,33; 46.5,33; 61.5,33; 19.5,33; 49.5,33; 64.5,33;
        22.5,33; 52.5,33; 67.5,33; 25.5,33; 55.5,33; 70.5,33; 28.5,33; 58.5,33;
        73.5,33; 15,36; 45,36; 60,36; 18,36; 48,36; 63,36; 21,36; 51,36; 66,36;
        24,36; 54,36; 69,36; 27,36; 57,36; 72,36; 16.5,39; 46.5,39; 61.5,39; 19.5,
        39; 49.5,39; 64.5,39; 22.5,39; 52.5,39; 67.5,39; 25.5,39; 55.5,39; 70.5,
        39; 28.5,39; 58.5,39; 73.5,39; 15,42; 45,42; 60,42; 18,42; 48,42; 63,42;
        21,42; 51,42; 66,42; 24,42; 54,42; 69,42; 27,42; 57,42; 72,42; 16.5,45;
        46.5,45; 61.5,45; 19.5,45; 49.5,45; 64.5,45; 22.5,45; 52.5,45; 67.5,45;
        25.5,45; 55.5,45; 70.5,45; 28.5,45; 58.5,45; 73.5,45],
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
        45; 10.5,45; 13.5,45; 15,0; 30,0; 20.4,0; 35.4,0; 25.8,0; 40.8,0; 17.7,6;
        32.7,6; 23.1,6; 38.1,6; 28.5,6; 43.5,6; 15,51; 30,51; 20.4,51; 35.4,51;
        25.8,51; 40.8,51; 17.7,57; 32.7,57; 23.1,57; 38.1,57; 28.5,57; 43.5,57;
        15,12; 30,12; 18,12; 33,12; 21,12; 36,12; 24,12; 39,12; 27,12; 42,12; 16.5,
        15; 31.5,15; 19.5,15; 34.5,15; 22.5,15; 37.5,15; 25.5,15; 40.5,15; 28.5,
        15; 43.5,15; 15,18; 30,18; 18,18; 33,18; 21,18; 36,18; 24,18; 39,18; 27,
        18; 42,18; 16.5,21; 31.5,21; 19.5,21; 34.5,21; 22.5,21; 37.5,21; 25.5,21;
        40.5,21; 28.5,21; 43.5,21; 15,24; 30,24; 18,24; 33,24; 21,24; 36,24; 24,
        24; 39,24; 27,24; 42,24; 16.5,27; 31.5,27; 19.5,27; 34.5,27; 22.5,27; 37.5,
        27; 25.5,27; 40.5,27; 28.5,27; 43.5,27; 15,30; 30,30; 18,30; 33,30; 21,30;
        36,30; 24,30; 39,30; 27,30; 42,30; 16.5,33; 31.5,33; 19.5,33; 34.5,33; 22.5,
        33; 37.5,33; 25.5,33; 40.5,33; 28.5,33; 43.5,33; 15,36; 30,36; 18,36; 33,
        36; 21,36; 36,36; 24,36; 39,36; 27,36; 42,36; 16.5,39; 31.5,39; 19.5,39;
        34.5,39; 22.5,39; 37.5,39; 25.5,39; 40.5,39; 28.5,39; 43.5,39; 15,42; 30,
        42; 18,42; 33,42; 21,42; 36,42; 24,42; 39,42; 27,42; 42,42; 16.5,45; 31.5,
        45; 19.5,45; 34.5,45; 22.5,45; 37.5,45; 25.5,45; 40.5,45; 28.5,45; 43.5,
        45],
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
    annotation (Placement(transformation(extent={{40,60},{60,80}})));
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
    annotation (Placement(transformation(extent={{40,30},{60,50}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMulLeaEdgCen(
    redeclare each final package Medium = Medium,
    each allowFlowReversal=false,
    k=2) "Mass flow rate multiplier at outlet of edge center"
    annotation (Placement(transformation(extent={{40,-40},{60,-20}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMulLeaCorCen(
    redeclare each final package Medium = Medium,
    each allowFlowReversal=false,
    k=nBorSec - 2) "Mass flow rate multiplier at outlet of core perimeter"
    annotation (Placement(transformation(extent={{40,-70},{60,-50}})));

  DummyBorefield edgDummy(redeclare package Medium = Medium, final
      m_flow_nominal=mPer_flow_nominal)
    if useDummy_borefield
    "Dummy borefield for edge (for development only)"
    annotation (Placement(transformation(extent={{-50,0},{-30,20}})));
  DummyBorefield corDummy(redeclare package Medium = Medium, final
      m_flow_nominal=mPer_flow_nominal)
    if useDummy_borefield
    "Dummy borefield for core (for development only)"
    annotation (Placement(transformation(extent={{-50,-80},{-30,-60}})));
equation
  // Added test on time so translation does not stop because the condition is always violated
  if useDummy_borefield and time >= -10*365*24*3600 then
  assert(not useDummy_borefield, "*** Warning. Borefield is not realistic, for debugging purposes only.",
    level = AssertionLevel.warning);
  end if;



  connect(edgSec.QPer_flow, sumQPer_flow.u1)
    annotation (Line(points={{-28,46},{4,46},{4,26},{8,26}}, color={0,0,127}));
  connect(corSec.QPer_flow, sumQPer_flow.u2) annotation (Line(points={{-28,-34},
          {4,-34},{4,14},{8,14}}, color={0,0,127}));
  connect(edgSec.QCor_flow, sumQCen_flow.u1) annotation (Line(points={{-28,43},{
          0,43},{0,-4},{8,-4}}, color={0,0,127}));
  connect(corSec.QCor_flow, sumQCen_flow.u2) annotation (Line(points={{-28,-37},
          {0,-37},{0,-16},{8,-16}},   color={0,0,127}));
  connect(sumQCen_flow.y, QCen_flow)
    annotation (Line(points={{31,-10},{120,-10}}, color={0,0,127}));
  connect(portCen_a,masFloMulEntCen. port_a)
    annotation (Line(points={{-100,-40},{-90,-40}}, color={0,127,255}));
  connect(portPer_a, masFloMulEntPer.port_a)
    annotation (Line(points={{-100,40},{-88,40}}, color={0,127,255}));
  connect(edgSec.portPer_a, masFloMulEntPer.port_b) annotation (Line(points={{-50,
          48},{-60,48},{-60,40},{-68,40}}, color={0,127,255}));
  connect(corSec.portPer_a, masFloMulEntPer.port_b) annotation (Line(points={{-50,
          -32},{-60,-32},{-60,40},{-68,40}}, color={0,127,255}));
  connect(masFloMulEntCen.port_b, edgSec.portCor_a) annotation (Line(points={{-70,
          -40},{-56,-40},{-56,32},{-50,32}}, color={0,127,255}));
  connect(masFloMulEntCen.port_b, corSec.portCor_a) annotation (Line(points={{-70,
          -40},{-56,-40},{-56,-48},{-50,-48}}, color={0,127,255}));
  connect(sumQPer_flow.y, QPer_flow)
    annotation (Line(points={{31,20},{120,20}}, color={0,0,127}));
  connect(edgSec.portPer_b, masFloMulLeaEdgPer.port_a) annotation (Line(points={{-30,48},
          {-10,48},{-10,70},{40,70}},       color={0,127,255}));
  connect(corSec.portPer_b, masFloMulLeaCorPer.port_a) annotation (Line(points=
          {{-30,-32},{-4,-32},{-4,40},{40,40}}, color={0,127,255}));
  connect(edgSec.portCor_b, masFloMulLeaEdgCen.port_a) annotation (Line(points=
          {{-30.2,32},{-6,32},{-6,-30},{40,-30}}, color={0,127,255}));
  connect(corSec.portCor_b, masFloMulLeaCorCen.port_a) annotation (Line(points={{-30.2,
          -48},{20,-48},{20,-60},{40,-60}},         color={0,127,255}));
  connect(masFloMulLeaEdgCen.port_b, portCen_b) annotation (Line(points={{60,
          -30},{80,-30},{80,-40},{100,-40}}, color={0,127,255}));
  connect(masFloMulLeaCorCen.port_b, portCen_b) annotation (Line(points={{60,
          -60},{80,-60},{80,-40},{100,-40}}, color={0,127,255}));
  connect(masFloMulLeaEdgPer.port_b, portPer_b) annotation (Line(points={{60,70},
          {80,70},{80,40},{100,40}}, color={0,127,255}));
  connect(masFloMulLeaCorPer.port_b, portPer_b)
    annotation (Line(points={{60,40},{100,40}}, color={0,127,255}));
  connect(corDummy.portPer_a, masFloMulEntPer.port_b) annotation (Line(points={{
          -50,-62},{-60,-62},{-60,40},{-68,40}}, color={0,127,255}));
  connect(corDummy.portCor_a, masFloMulEntCen.port_b) annotation (Line(points={{
          -50,-78},{-64,-78},{-64,-40},{-70,-40}}, color={0,127,255}));
  connect(edgDummy.portPer_a, masFloMulEntPer.port_b) annotation (Line(points={{-50,18},
          {-64,18},{-64,40},{-68,40}},         color={0,127,255}));
  connect(edgDummy.portCor_a, masFloMulEntCen.port_b) annotation (Line(points={{-50,2},
          {-64,2},{-64,-40},{-70,-40}},        color={0,127,255}));
  connect(edgDummy.portPer_b, masFloMulLeaEdgPer.port_a) annotation (Line(
        points={{-30,18},{-10,18},{-10,70},{40,70}}, color={0,127,255}));
  connect(edgDummy.portCor_b, masFloMulLeaEdgCen.port_a) annotation (Line(
        points={{-30.2,2},{-6,2},{-6,-30},{40,-30}}, color={0,127,255}));
  connect(corDummy.portPer_b, masFloMulLeaCorPer.port_a) annotation (Line(
        points={{-30,-62},{-4,-62},{-4,40},{40,40}}, color={0,127,255}));
  connect(corDummy.portCor_b, masFloMulLeaCorCen.port_a) annotation (Line(
        points={{-30.2,-78},{20,-78},{20,-60},{40,-60}}, color={0,127,255}));
  connect(sumQPer_flow.u1, edgDummy.QPer_flow) annotation (Line(points={{8,26},{
          -18,26},{-18,16},{-28,16}}, color={0,0,127}));
  connect(sumQPer_flow.u2, corDummy.QPer_flow) annotation (Line(points={{8,14},{
          4,14},{4,-64},{-28,-64}}, color={0,0,127}));
  connect(sumQCen_flow.u1, edgDummy.QCor_flow)
    annotation (Line(points={{8,-4},{0,-4},{0,13},{-28,13}}, color={0,0,127}));
  connect(corDummy.QCor_flow, sumQCen_flow.u2) annotation (Line(points={{-28,-67},
          {0,-67},{0,-16},{8,-16}}, color={0,0,127}));
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
