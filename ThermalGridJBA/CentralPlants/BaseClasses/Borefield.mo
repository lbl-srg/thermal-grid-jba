within ThermalGridJBA.CentralPlants.BaseClasses;
model Borefield "Borefield model"
  extends Modelica.Blocks.Icons.Block;
  replaceable package Medium = Buildings.Media.Water "Water";
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
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,
        2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
        4}
     "Index of boreholes of edge zone (at the left short edge, with two dummy zones to the right)"
    annotation (Dialog(group="Borefield"));
  constant Integer iCorZon[:] = {
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,
        2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,
        4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
        4} "Index of boreholes of core zone (at the core with two dummy zones to the left and two dummy zones to the right)"
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
    final T_start=T_start) "Edge section of borefield" annotation (Placement(
        transformation(rotation=0, extent={{-50,30},{-30,50}})));

  BorefieldSection corSec(
    redeclare package Medium = Medium,
    final nDumSec=4,
    final borFieDat=corBorFieDat,
    final nBorSec=nBorSec,
    final T_start=T_start) "Core section of borefield" annotation (Placement(
        transformation(rotation=0, extent={{-50,-50},{-30,-30}})));

  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Soil.SandStone soiDat(
    kSoi=1.1,
    cSoi=1.4E6/1800,
    dSoi=1800) "Soil data"
    annotation (Placement(transformation(extent={{-40,-88},{-20,-68}})));
  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Filling.Bentonite filDat(kFil=1.0)
    "Borehole filling data"
    annotation (Placement(transformation(extent={{-90,-88},{-70,-68}})));

  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Configuration.Template corConDat(
    borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.DoubleUTubeParallel,
    final mBor_flow_nominal=mBor_flow_nominal*ones(4),
    final dp_nominal=dp_nominal*ones(4),
    final hBor=hBor,
    rBor=0.075,
    dBor=0.5,
    nZon=nCorZon,
    iZon=iCorZon,
    cooBor=[30,1.5; 33,1.5; 36,1.5; 39,1.5; 42,1.5; 31.5,4.5; 34.5,4.5; 37.5,
        4.5; 40.5,4.5; 43.5,4.5; 30,7.5; 33,7.5; 36,7.5; 39,7.5; 42,7.5; 31.5,
        10.5; 34.5,10.5; 37.5,10.5; 40.5,10.5; 43.5,10.5; 30,13.5; 33,13.5; 36,
        13.5; 39,13.5; 42,13.5; 31.5,16.5; 34.5,16.5; 37.5,16.5; 40.5,16.5;
        43.5,16.5; 31.5,46.5; 34.5,46.5; 37.5,46.5; 40.5,46.5; 43.5,46.5; 30,
        49.5; 33,49.5; 36,49.5; 39,49.5; 42,49.5; 31.5,52.5; 34.5,52.5; 37.5,
        52.5; 40.5,52.5; 43.5,52.5; 30,55.5; 33,55.5; 36,55.5; 39,55.5; 42,55.5;
        31.5,58.5; 34.5,58.5; 37.5,58.5; 40.5,58.5; 43.5,58.5; 30,61.5; 33,61.5;
        36,61.5; 39,61.5; 42,61.5; 30,22.5; 35.4,22.5; 40.8,22.5; 32.7,28.5;
        38.1,28.5; 43.5,28.5; 30,34.5; 35.4,34.5; 40.8,34.5; 32.7,40.5; 38.1,
        40.5; 43.5,40.5; 0,1.5; 3,1.5; 6,1.5; 9,1.5; 12,1.5; 1.5,4.5; 4.5,4.5;
        7.5,4.5; 10.5,4.5; 13.5,4.5; 0,7.5; 3,7.5; 6,7.5; 9,7.5; 12,7.5; 1.5,
        10.5; 4.5,10.5; 7.5,10.5; 10.5,10.5; 13.5,10.5; 0,13.5; 3,13.5; 6,13.5;
        9,13.5; 12,13.5; 1.5,16.5; 4.5,16.5; 7.5,16.5; 10.5,16.5; 13.5,16.5;
        1.5,46.5; 4.5,46.5; 7.5,46.5; 10.5,46.5; 13.5,46.5; 0,49.5; 3,49.5; 6,
        49.5; 9,49.5; 12,49.5; 1.5,52.5; 4.5,52.5; 7.5,52.5; 10.5,52.5; 13.5,
        52.5; 0,55.5; 3,55.5; 6,55.5; 9,55.5; 12,55.5; 1.5,58.5; 4.5,58.5; 7.5,
        58.5; 10.5,58.5; 13.5,58.5; 0,61.5; 3,61.5; 6,61.5; 9,61.5; 12,61.5; 15,
        1.5; 45,1.5; 60,1.5; 18,1.5; 48,1.5; 63,1.5; 21,1.5; 51,1.5; 66,1.5; 24,
        1.5; 54,1.5; 69,1.5; 27,1.5; 57,1.5; 72,1.5; 16.5,4.5; 46.5,4.5; 61.5,
        4.5; 19.5,4.5; 49.5,4.5; 64.5,4.5; 22.5,4.5; 52.5,4.5; 67.5,4.5; 25.5,
        4.5; 55.5,4.5; 70.5,4.5; 28.5,4.5; 58.5,4.5; 73.5,4.5; 15,7.5; 45,7.5;
        60,7.5; 18,7.5; 48,7.5; 63,7.5; 21,7.5; 51,7.5; 66,7.5; 24,7.5; 54,7.5;
        69,7.5; 27,7.5; 57,7.5; 72,7.5; 16.5,10.5; 46.5,10.5; 61.5,10.5; 19.5,
        10.5; 49.5,10.5; 64.5,10.5; 22.5,10.5; 52.5,10.5; 67.5,10.5; 25.5,10.5;
        55.5,10.5; 70.5,10.5; 28.5,10.5; 58.5,10.5; 73.5,10.5; 15,13.5; 45,13.5;
        60,13.5; 18,13.5; 48,13.5; 63,13.5; 21,13.5; 51,13.5; 66,13.5; 24,13.5;
        54,13.5; 69,13.5; 27,13.5; 57,13.5; 72,13.5; 16.5,16.5; 46.5,16.5; 61.5,
        16.5; 19.5,16.5; 49.5,16.5; 64.5,16.5; 22.5,16.5; 52.5,16.5; 67.5,16.5;
        25.5,16.5; 55.5,16.5; 70.5,16.5; 28.5,16.5; 58.5,16.5; 73.5,16.5; 16.5,
        46.5; 46.5,46.5; 61.5,46.5; 19.5,46.5; 49.5,46.5; 64.5,46.5; 22.5,46.5;
        52.5,46.5; 67.5,46.5; 25.5,46.5; 55.5,46.5; 70.5,46.5; 28.5,46.5; 58.5,
        46.5; 73.5,46.5; 15,49.5; 45,49.5; 60,49.5; 18,49.5; 48,49.5; 63,49.5;
        21,49.5; 51,49.5; 66,49.5; 24,49.5; 54,49.5; 69,49.5; 27,49.5; 57,49.5;
        72,49.5; 16.5,52.5; 46.5,52.5; 61.5,52.5; 19.5,52.5; 49.5,52.5; 64.5,
        52.5; 22.5,52.5; 52.5,52.5; 67.5,52.5; 25.5,52.5; 55.5,52.5; 70.5,52.5;
        28.5,52.5; 58.5,52.5; 73.5,52.5; 15,55.5; 45,55.5; 60,55.5; 18,55.5; 48,
        55.5; 63,55.5; 21,55.5; 51,55.5; 66,55.5; 24,55.5; 54,55.5; 69,55.5; 27,
        55.5; 57,55.5; 72,55.5; 16.5,58.5; 46.5,58.5; 61.5,58.5; 19.5,58.5;
        49.5,58.5; 64.5,58.5; 22.5,58.5; 52.5,58.5; 67.5,58.5; 25.5,58.5; 55.5,
        58.5; 70.5,58.5; 28.5,58.5; 58.5,58.5; 73.5,58.5; 15,61.5; 45,61.5; 60,
        61.5; 18,61.5; 48,61.5; 63,61.5; 21,61.5; 51,61.5; 66,61.5; 24,61.5; 54,
        61.5; 69,61.5; 27,61.5; 57,61.5; 72,61.5; 0,22.5; 5.4,22.5; 10.8,22.5;
        2.7,28.5; 8.1,28.5; 13.5,28.5; 0,34.5; 5.4,34.5; 10.8,34.5; 2.7,40.5;
        8.1,40.5; 13.5,40.5; 15,22.5; 45,22.5; 60,22.5; 20.4,22.5; 50.4,22.5;
        65.4,22.5; 25.8,22.5; 55.8,22.5; 70.8,22.5; 17.7,28.5; 47.7,28.5; 62.7,
        28.5; 23.1,28.5; 53.1,28.5; 68.1,28.5; 28.5,28.5; 58.5,28.5; 73.5,28.5;
        15,34.5; 45,34.5; 60,34.5; 20.4,34.5; 50.4,34.5; 65.4,34.5; 25.8,34.5;
        55.8,34.5; 70.8,34.5; 17.7,40.5; 47.7,40.5; 62.7,40.5; 23.1,40.5; 53.1,
        40.5; 68.1,40.5; 28.5,40.5; 58.5,40.5; 73.5,40.5],
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
    cooBor=[0,1.5; 3,1.5; 6,1.5; 9,1.5; 12,1.5; 1.5,4.5; 4.5,4.5; 7.5,4.5; 10.5,
        4.5; 13.5,4.5; 0,7.5; 3,7.5; 6,7.5; 9,7.5; 12,7.5; 1.5,10.5; 4.5,10.5; 7.5,
        10.5; 10.5,10.5; 13.5,10.5; 0,13.5; 3,13.5; 6,13.5; 9,13.5; 12,13.5; 1.5,
        16.5; 4.5,16.5; 7.5,16.5; 10.5,16.5; 13.5,16.5; 1.5,46.5; 4.5,46.5; 7.5,
        46.5; 10.5,46.5; 13.5,46.5; 0,49.5; 3,49.5; 6,49.5; 9,49.5; 12,49.5; 1.5,
        52.5; 4.5,52.5; 7.5,52.5; 10.5,52.5; 13.5,52.5; 0,55.5; 3,55.5; 6,55.5;
        9,55.5; 12,55.5; 1.5,58.5; 4.5,58.5; 7.5,58.5; 10.5,58.5; 13.5,58.5; 0,61.5;
        3,61.5; 6,61.5; 9,61.5; 12,61.5; 0,22.5; 5.4,22.5; 10.8,22.5; 2.7,28.5;
        8.1,28.5; 13.5,28.5; 0,34.5; 5.4,34.5; 10.8,34.5; 2.7,40.5; 8.1,40.5; 13.5,
        40.5; 15,1.5; 30,1.5; 18,1.5; 33,1.5; 21,1.5; 36,1.5; 24,1.5; 39,1.5; 27,
        1.5; 42,1.5; 16.5,4.5; 31.5,4.5; 19.5,4.5; 34.5,4.5; 22.5,4.5; 37.5,4.5;
        25.5,4.5; 40.5,4.5; 28.5,4.5; 43.5,4.5; 15,7.5; 30,7.5; 18,7.5; 33,7.5;
        21,7.5; 36,7.5; 24,7.5; 39,7.5; 27,7.5; 42,7.5; 16.5,10.5; 31.5,10.5; 19.5,
        10.5; 34.5,10.5; 22.5,10.5; 37.5,10.5; 25.5,10.5; 40.5,10.5; 28.5,10.5;
        43.5,10.5; 15,13.5; 30,13.5; 18,13.5; 33,13.5; 21,13.5; 36,13.5; 24,13.5;
        39,13.5; 27,13.5; 42,13.5; 16.5,16.5; 31.5,16.5; 19.5,16.5; 34.5,16.5; 22.5,
        16.5; 37.5,16.5; 25.5,16.5; 40.5,16.5; 28.5,16.5; 43.5,16.5; 16.5,46.5;
        31.5,46.5; 19.5,46.5; 34.5,46.5; 22.5,46.5; 37.5,46.5; 25.5,46.5; 40.5,46.5;
        28.5,46.5; 43.5,46.5; 15,49.5; 30,49.5; 18,49.5; 33,49.5; 21,49.5; 36,49.5;
        24,49.5; 39,49.5; 27,49.5; 42,49.5; 16.5,52.5; 31.5,52.5; 19.5,52.5; 34.5,
        52.5; 22.5,52.5; 37.5,52.5; 25.5,52.5; 40.5,52.5; 28.5,52.5; 43.5,52.5;
        15,55.5; 30,55.5; 18,55.5; 33,55.5; 21,55.5; 36,55.5; 24,55.5; 39,55.5;
        27,55.5; 42,55.5; 16.5,58.5; 31.5,58.5; 19.5,58.5; 34.5,58.5; 22.5,58.5;
        37.5,58.5; 25.5,58.5; 40.5,58.5; 28.5,58.5; 43.5,58.5; 15,61.5; 30,61.5;
        18,61.5; 33,61.5; 21,61.5; 36,61.5; 24,61.5; 39,61.5; 27,61.5; 42,61.5;
        15,22.5; 30,22.5; 20.4,22.5; 35.4,22.5; 25.8,22.5; 40.8,22.5; 17.7,28.5;
        32.7,28.5; 23.1,28.5; 38.1,28.5; 28.5,28.5; 43.5,28.5; 15,34.5; 30,34.5;
        20.4,34.5; 35.4,34.5; 25.8,34.5; 40.8,34.5; 17.7,40.5; 32.7,40.5; 23.1,40.5;
        38.1,40.5; 28.5,40.5; 43.5,40.5],
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
equation

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
  connect(edgSec.portPer_b, masFloMulLeaEdgPer.port_a) annotation (Line(points=
          {{-30,48},{0,48},{0,70},{40,70}}, color={0,127,255}));
  connect(corSec.portPer_b, masFloMulLeaCorPer.port_a) annotation (Line(points=
          {{-30,-32},{-4,-32},{-4,40},{40,40}}, color={0,127,255}));
  connect(edgSec.portCor_b, masFloMulLeaEdgCen.port_a) annotation (Line(points=
          {{-30.2,32},{-6,32},{-6,-30},{40,-30}}, color={0,127,255}));
  connect(corSec.portCor_b, masFloMulLeaCorCen.port_a) annotation (Line(points=
          {{-30.2,-48},{-6,-48},{-6,-60},{40,-60}}, color={0,127,255}));
  connect(masFloMulLeaEdgCen.port_b, portCen_b) annotation (Line(points={{60,
          -30},{80,-30},{80,-40},{100,-40}}, color={0,127,255}));
  connect(masFloMulLeaCorCen.port_b, portCen_b) annotation (Line(points={{60,
          -60},{80,-60},{80,-40},{100,-40}}, color={0,127,255}));
  connect(masFloMulLeaEdgPer.port_b, portPer_b) annotation (Line(points={{60,70},
          {80,70},{80,40},{100,40}}, color={0,127,255}));
  connect(masFloMulLeaCorPer.port_b, portPer_b)
    annotation (Line(points={{60,40},{100,40}}, color={0,127,255}));
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
