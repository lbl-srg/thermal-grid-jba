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

  final parameter Real mBorMod_flow_nominual(
    unit="kg/s")=mWat_flow_nominal*nGenMod/nBorSec
    "Nominal mass flow rate to each borefield sectors (each section have 2 of the 36-holes modules)"
    annotation (Dialog(group="Borefield"));
  parameter Real mEdgBorHol_flow_nominal[nEdgZon](
    unit=fill("kg/s", nEdgZon))=fill(mBorMod_flow_nominual/72, nEdgZon)
    "Nominal mass flow rate per borehole in each zone of edge borefield"
    annotation (Dialog(group="Borefield"));
  parameter Real mCorBorHol_flow_nominal[nCorZon](
    unit=fill("kg/s", nCorZon))=fill(mBorMod_flow_nominual/72, nCorZon)
    "Nominal mass flow rate per borehole in each zone of core borefield"
    annotation (Dialog(group="Borefield"));
  parameter Real dpEdg_nominal[nEdgZon](
    unit=fill("Pa", nEdgZon))={2e4,5e4,2e4,2e4}
    "Pressure losses for each zone of borefield module"
    annotation (Dialog(group="Borefield"));
  parameter Real dpCor_nominal[nCorZon](
    unit=fill("Pa", nCorZon))={2e4,5e4,2e4,2e4}
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
    annotation (Placement(transformation(extent={{-180,-230},{-160,-210}})));
  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Filling.Bentonite filDat(kFil=1.0)
    "Borehole filling data"
    annotation (Placement(transformation(extent={{-220,-230},{-200,-210}})));

  final parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Configuration.Template corConDat(
    borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.DoubleUTubeParallel,
    mBor_flow_nominal=mCorBorHol_flow_nominal,
    dp_nominal=dpCor_nominal,
    hBor=91,
    rBor=0.075,
    dBor=0.5,
    nZon=4,
    iZon={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,
        2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,
        4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
        4},
    cooBor={{15,1.5},{18,1.5},{21,1.5},{24,1.5},{27,1.5},{16.5,4.5},{19.5,4.5},{
        22.5,4.5},{25.5,4.5},{28.5,4.5},{15,7.5},{18,7.5},{21,7.5},{24,7.5},{27,
        7.5},{16.5,10.5},{19.5,10.5},{22.5,10.5},{25.5,10.5},{28.5,10.5},{15,13.5},
        {18,13.5},{21,13.5},{24,13.5},{27,13.5},{16.5,16.5},{19.5,16.5},{22.5,16.5},
        {25.5,16.5},{28.5,16.5},{16.5,46.5},{19.5,46.5},{22.5,46.5},{25.5,46.5},
        {28.5,46.5},{15,49.5},{18,49.5},{21,49.5},{24,49.5},{27,49.5},{16.5,52.5},
        {19.5,52.5},{22.5,52.5},{25.5,52.5},{28.5,52.5},{15,55.5},{18,55.5},{21,
        55.5},{24,55.5},{27,55.5},{16.5,58.5},{19.5,58.5},{22.5,58.5},{25.5,58.5},
        {28.5,58.5},{15,61.5},{18,61.5},{21,61.5},{24,61.5},{27,61.5},{15,22.5},
        {20.4,22.5},{25.8,22.5},{17.7,28.5},{23.1,28.5},{28.5,28.5},{15,34.5},{20.4,
        34.5},{25.8,34.5},{17.7,40.5},{23.1,40.5},{28.5,40.5},{0,1.5},{3,1.5},{6,
        1.5},{9,1.5},{12,1.5},{1.5,4.5},{4.5,4.5},{7.5,4.5},{10.5,4.5},{13.5,4.5},
        {0,7.5},{3,7.5},{6,7.5},{9,7.5},{12,7.5},{1.5,10.5},{4.5,10.5},{7.5,10.5},
        {10.5,10.5},{13.5,10.5},{0,13.5},{3,13.5},{6,13.5},{9,13.5},{12,13.5},{1.5,
        16.5},{4.5,16.5},{7.5,16.5},{10.5,16.5},{13.5,16.5},{1.5,46.5},{4.5,46.5},
        {7.5,46.5},{10.5,46.5},{13.5,46.5},{0,49.5},{3,49.5},{6,49.5},{9,49.5},{
        12,49.5},{1.5,52.5},{4.5,52.5},{7.5,52.5},{10.5,52.5},{13.5,52.5},{0,55.5},
        {3,55.5},{6,55.5},{9,55.5},{12,55.5},{1.5,58.5},{4.5,58.5},{7.5,58.5},{10.5,
        58.5},{13.5,58.5},{0,61.5},{3,61.5},{6,61.5},{9,61.5},{12,61.5},{15,1.5},
        {15,1.5},{15,1.5},{18,1.5},{18,1.5},{18,1.5},{21,1.5},{21,1.5},{21,1.5},
        {24,1.5},{24,1.5},{24,1.5},{27,1.5},{27,1.5},{27,1.5},{16.5,4.5},{16.5,4.5},
        {16.5,4.5},{19.5,4.5},{19.5,4.5},{19.5,4.5},{22.5,4.5},{22.5,4.5},{22.5,
        4.5},{25.5,4.5},{25.5,4.5},{25.5,4.5},{28.5,4.5},{28.5,4.5},{28.5,4.5},{
        15,7.5},{15,7.5},{15,7.5},{18,7.5},{18,7.5},{18,7.5},{21,7.5},{21,7.5},{
        21,7.5},{24,7.5},{24,7.5},{24,7.5},{27,7.5},{27,7.5},{27,7.5},{16.5,10.5},
        {16.5,10.5},{16.5,10.5},{19.5,10.5},{19.5,10.5},{19.5,10.5},{22.5,10.5},
        {22.5,10.5},{22.5,10.5},{25.5,10.5},{25.5,10.5},{25.5,10.5},{28.5,10.5},
        {28.5,10.5},{28.5,10.5},{15,13.5},{15,13.5},{15,13.5},{18,13.5},{18,13.5},
        {18,13.5},{21,13.5},{21,13.5},{21,13.5},{24,13.5},{24,13.5},{24,13.5},{27,
        13.5},{27,13.5},{27,13.5},{16.5,16.5},{16.5,16.5},{16.5,16.5},{19.5,16.5},
        {19.5,16.5},{19.5,16.5},{22.5,16.5},{22.5,16.5},{22.5,16.5},{25.5,16.5},
        {25.5,16.5},{25.5,16.5},{28.5,16.5},{28.5,16.5},{28.5,16.5},{16.5,46.5},
        {16.5,46.5},{16.5,46.5},{19.5,46.5},{19.5,46.5},{19.5,46.5},{22.5,46.5},
        {22.5,46.5},{22.5,46.5},{25.5,46.5},{25.5,46.5},{25.5,46.5},{28.5,46.5},
        {28.5,46.5},{28.5,46.5},{15,49.5},{15,49.5},{15,49.5},{18,49.5},{18,49.5},
        {18,49.5},{21,49.5},{21,49.5},{21,49.5},{24,49.5},{24,49.5},{24,49.5},{27,
        49.5},{27,49.5},{27,49.5},{16.5,52.5},{16.5,52.5},{16.5,52.5},{19.5,52.5},
        {19.5,52.5},{19.5,52.5},{22.5,52.5},{22.5,52.5},{22.5,52.5},{25.5,52.5},
        {25.5,52.5},{25.5,52.5},{28.5,52.5},{28.5,52.5},{28.5,52.5},{15,55.5},{15,
        55.5},{15,55.5},{18,55.5},{18,55.5},{18,55.5},{21,55.5},{21,55.5},{21,55.5},
        {24,55.5},{24,55.5},{24,55.5},{27,55.5},{27,55.5},{27,55.5},{16.5,58.5},
        {16.5,58.5},{16.5,58.5},{19.5,58.5},{19.5,58.5},{19.5,58.5},{22.5,58.5},
        {22.5,58.5},{22.5,58.5},{25.5,58.5},{25.5,58.5},{25.5,58.5},{28.5,58.5},
        {28.5,58.5},{28.5,58.5},{15,61.5},{15,61.5},{15,61.5},{18,61.5},{18,61.5},
        {18,61.5},{21,61.5},{21,61.5},{21,61.5},{24,61.5},{24,61.5},{24,61.5},{27,
        61.5},{27,61.5},{27,61.5},{0,22.5},{5.4,22.5},{10.8,22.5},{2.7,28.5},{8.1,
        28.5},{13.5,28.5},{0,34.5},{5.4,34.5},{10.8,34.5},{2.7,40.5},{8.1,40.5},
        {13.5,40.5},{15,22.5},{15,22.5},{15,22.5},{20.4,22.5},{20.4,22.5},{20.4,
        22.5},{25.8,22.5},{25.8,22.5},{25.8,22.5},{17.7,28.5},{17.7,28.5},{17.7,
        28.5},{23.1,28.5},{23.1,28.5},{23.1,28.5},{28.5,28.5},{28.5,28.5},{28.5,
        28.5},{15,34.5},{15,34.5},{15,34.5},{20.4,34.5},{20.4,34.5},{20.4,34.5},
        {25.8,34.5},{25.8,34.5},{25.8,34.5},{17.7,40.5},{17.7,40.5},{17.7,40.5},
        {23.1,40.5},{23.1,40.5},{23.1,40.5},{28.5,40.5},{28.5,40.5},{28.5,40.5}},
    rTub=0.016,
    kTub=0.42,
    eTub=0.0029,
    xC=(2*((0.04/2)^2))^(1/2))
    "Construction data for the core: the borehole height, boreholes coordinate should be updated"
    annotation (Placement(transformation(extent={{-180,-190},{-160,-170}})));
  final parameter
    Buildings.Fluid.Geothermal.ZonedBorefields.Data.Borefield.Template
    corBorFieDat(
    filDat=filDat,
    soiDat=soiDat,
    conDat=corConDat) "Core borefield data"
    annotation (Placement(transformation(extent={{-180,-150},{-160,-130}})));

  final parameter
    Buildings.Fluid.Geothermal.ZonedBorefields.Data.Configuration.Template edgConDat(
    borCon=Buildings.Fluid.Geothermal.Borefields.Types.BoreholeConfiguration.DoubleUTubeParallel,
    mBor_flow_nominal=mEdgBorHol_flow_nominal,
    dp_nominal=dpEdg_nominal,
    hBor=91,
    rBor=0.075,
    dBor=0.5,
    nZon=4,
    iZon={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,
        2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
        3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
        4},
    cooBor={{0,1.5},{3,1.5},{6,1.5},{9,1.5},{12,1.5},{1.5,4.5},{4.5,4.5},{7.5,4.5},
        {10.5,4.5},{13.5,4.5},{0,7.5},{3,7.5},{6,7.5},{9,7.5},{12,7.5},{1.5,10.5},
        {4.5,10.5},{7.5,10.5},{10.5,10.5},{13.5,10.5},{0,13.5},{3,13.5},{6,13.5},
        {9,13.5},{12,13.5},{1.5,16.5},{4.5,16.5},{7.5,16.5},{10.5,16.5},{13.5,16.5},
        {1.5,46.5},{4.5,46.5},{7.5,46.5},{10.5,46.5},{13.5,46.5},{0,49.5},{3,49.5},
        {6,49.5},{9,49.5},{12,49.5},{1.5,52.5},{4.5,52.5},{7.5,52.5},{10.5,52.5},
        {13.5,52.5},{0,55.5},{3,55.5},{6,55.5},{9,55.5},{12,55.5},{1.5,58.5},{4.5,
        58.5},{7.5,58.5},{10.5,58.5},{13.5,58.5},{0,61.5},{3,61.5},{6,61.5},{9,61.5},
        {12,61.5},{0,22.5},{5.4,22.5},{10.8,22.5},{2.7,28.5},{8.1,28.5},{13.5,28.5},
        {0,34.5},{5.4,34.5},{10.8,34.5},{2.7,40.5},{8.1,40.5},{13.5,40.5},{15,1.5},
        {15,1.5},{18,1.5},{18,1.5},{21,1.5},{21,1.5},{24,1.5},{24,1.5},{27,1.5},
        {27,1.5},{16.5,4.5},{16.5,4.5},{19.5,4.5},{19.5,4.5},{22.5,4.5},{22.5,4.5},
        {25.5,4.5},{25.5,4.5},{28.5,4.5},{28.5,4.5},{15,7.5},{15,7.5},{18,7.5},{
        18,7.5},{21,7.5},{21,7.5},{24,7.5},{24,7.5},{27,7.5},{27,7.5},{16.5,10.5},
        {16.5,10.5},{19.5,10.5},{19.5,10.5},{22.5,10.5},{22.5,10.5},{25.5,10.5},
        {25.5,10.5},{28.5,10.5},{28.5,10.5},{15,13.5},{15,13.5},{18,13.5},{18,13.5},
        {21,13.5},{21,13.5},{24,13.5},{24,13.5},{27,13.5},{27,13.5},{16.5,16.5},
        {16.5,16.5},{19.5,16.5},{19.5,16.5},{22.5,16.5},{22.5,16.5},{25.5,16.5},
        {25.5,16.5},{28.5,16.5},{28.5,16.5},{16.5,46.5},{16.5,46.5},{19.5,46.5},
        {19.5,46.5},{22.5,46.5},{22.5,46.5},{25.5,46.5},{25.5,46.5},{28.5,46.5},
        {28.5,46.5},{15,49.5},{15,49.5},{18,49.5},{18,49.5},{21,49.5},{21,49.5},
        {24,49.5},{24,49.5},{27,49.5},{27,49.5},{16.5,52.5},{16.5,52.5},{19.5,52.5},
        {19.5,52.5},{22.5,52.5},{22.5,52.5},{25.5,52.5},{25.5,52.5},{28.5,52.5},
        {28.5,52.5},{15,55.5},{15,55.5},{18,55.5},{18,55.5},{21,55.5},{21,55.5},
        {24,55.5},{24,55.5},{27,55.5},{27,55.5},{16.5,58.5},{16.5,58.5},{19.5,58.5},
        {19.5,58.5},{22.5,58.5},{22.5,58.5},{25.5,58.5},{25.5,58.5},{28.5,58.5},
        {28.5,58.5},{15,61.5},{15,61.5},{18,61.5},{18,61.5},{21,61.5},{21,61.5},
        {24,61.5},{24,61.5},{27,61.5},{27,61.5},{15,22.5},{15,22.5},{20.4,22.5},
        {20.4,22.5},{25.8,22.5},{25.8,22.5},{17.7,28.5},{17.7,28.5},{23.1,28.5},
        {23.1,28.5},{28.5,28.5},{28.5,28.5},{15,34.5},{15,34.5},{20.4,34.5},{20.4,
        34.5},{25.8,34.5},{25.8,34.5},{17.7,40.5},{17.7,40.5},{23.1,40.5},{23.1,
        40.5},{28.5,40.5},{28.5,40.5}},
    rTub=0.016,
    kTub=0.42,
    eTub=0.0029,
    xC=(2*((0.04/2)^2))^(1/2))
    "Construction data for the edge: the borehole height, boreholes coordinate should be updated"
    annotation (Placement(transformation(extent={{-220,-190},{-200,-170}})));
  final parameter
    Buildings.Fluid.Geothermal.ZonedBorefields.Data.Borefield.Template edgBorFieDat(
    filDat=filDat,
    soiDat=soiDat,
    conDat=edgConDat) "Edge borefield data"
    annotation (Placement(transformation(extent={{-220,-150},{-200,-130}})));

  final parameter Modelica.Units.SI.Temperature T_start=289.65
    "Initial temperature of the soil";
  final parameter Integer nEdgZon=edgBorFieDat.conDat.nZon
    "Total number of independent bore field zones in edge borefield";
  final parameter Integer nCorZon=corBorFieDat.conDat.nZon
    "Total number of independent bore field zones in core borefield";











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
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumCirPum(quantity="Power",
      final unit="W")
    "Electrical power consumed by circulation pump"
    annotation (Placement(transformation(extent={{320,-260},{360,-220}}),
        iconTransformation(extent={{100,-100},{140,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumWat(quantity="Power",
      final unit="W")
    "Electrical power consumed by heat pump waterside pump"
    annotation (Placement(transformation(extent={{320,-230},{360,-190}}),
        iconTransformation(extent={{100,-80},{140,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QBorOut_flow(unit="W")
    "Heat flow from borefield to water"
    annotation (Placement(transformation(extent={{320,-60},{360,-20}}),
        iconTransformation(extent={{100,-120},{140,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PCom(quantity="Power",
      final unit="W")
    "Electric power consumed by compressor"
    annotation (Placement(transformation(extent={{320,-200},{360,-160}}),
        iconTransformation(extent={{100,-60},{140,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumGly(quantity="Power",
      final unit="W")
    "Electrical power consumed by glycol pump of heat pump"
    annotation (Placement(transformation(extent={{320,-170},{360,-130}}),
        iconTransformation(extent={{100,-40},{140,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHexGly(quantity="Power",
      final unit="W")
    "Electrical power consumed by the glycol pump of HEX"
    annotation (Placement(transformation(extent={{320,130},{360,170}}),
        iconTransformation(extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumDryCoo(quantity="Power",
      final unit="W")
    "Electrical power consumed by dry cool pump"
    annotation (Placement(transformation(extent={{320,160},{360,200}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, cent per kWh"
    annotation (Placement(transformation(extent={{320,220},{360,260}}),
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
    annotation (Placement(transformation(extent={{312,-10},{332,10}}),
      iconTransformation(extent={{90,-10},{110,10}})));
  Buildings.Fluid.Geothermal.ZonedBorefields.TwoUTubes edgBorFie(
    redeclare each final package Medium = MediumW,
    each allowFlowReversal=false,
    each energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    each TExt0_start=T_start,
    each borFieDat=edgBorFieDat,
    each dT_dz=0) "Edge borefield"
    annotation (Placement(transformation(extent={{100,40},{120,60}})));
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
    k=2/nBorSec)
    "Split total flow"
    annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  Buildings.Fluid.Delays.DelayFirstOrder del3(
    redeclare final package Medium = MediumW,
    nPorts=5,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final m_flow_nominal=nGenMod*mWat_flow_nominal)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=180, origin={0,10})));
  Buildings.Fluid.Geothermal.ZonedBorefields.TwoUTubes corBorFie(
    redeclare each final package Medium = MediumW,
    each allowFlowReversal=false,
    each energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    each TExt0_start=T_start,
    each borFieDat=corBorFieDat,
    each dT_dz=0) "Core borefield"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMul4[2](
    redeclare each final package Medium = MediumW,
    each allowFlowReversal=false,
    k=fill(nBorSec - 2, 2))
    annotation (Placement(transformation(extent={{160,-10},{180,10}})));
  Buildings.Fluid.Delays.DelayFirstOrder del1(
    redeclare final package Medium = MediumW,
    nPorts=5,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final m_flow_nominal=nGenMod*mWat_flow_nominal)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=180, origin={210,10})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(k=nGenMod)
    annotation (Placement(transformation(extent={{-20,170},{0,190}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(k=nGenMod)
    annotation (Placement(transformation(extent={{20,140},{40,160}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai3(k=nGenMod)
    annotation (Placement(transformation(extent={{20,-160},{40,-140}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai4(k=nGenMod)
    annotation (Placement(transformation(extent={{-20,-190},{0,-170}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai5(k=nGenMod)
    annotation (Placement(transformation(extent={{-60,-220},{-40,-200}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai6(k=nGenMod)
    annotation (Placement(transformation(extent={{-100,-250},{-80,-230}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort leaBorTem(redeclare final package
      Medium = MediumW,
    allowFlowReversal=false,
                        final m_flow_nominal=nGenMod*mWat_flow_nominal)
    "Temperature of waterflow leaving borefield"           annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={240,0})));
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
    annotation (Placement(transformation(extent={{270,-10},{290,10}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Water flow temperature difference"
    annotation (Placement(transformation(extent={{260,30},{280,50}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul
    annotation (Placement(transformation(extent={{240,-50},{260,-30}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter heaCap(final k=4184)
    "Water specific heat capacity"
    annotation (Placement(transformation(extent={{280,-50},{300,-30}})));

  Modelica.Blocks.Sources.RealExpression heaPumHea(y=gen.heaPum.Q1_flow)
    "Heat pump heat flow"
    annotation (Placement(transformation(extent={{-100,210},{-80,230}})));
  Modelica.Blocks.Sources.RealExpression hexHea(y=gen.hex.Q2_flow)
    "Heat exchanger heat flow"
    annotation (Placement(transformation(extent={{-100,190},{-80,210}})));
  Modelica.Blocks.Continuous.Integrator EHeaPumEne(initType=Modelica.Blocks.Types.Init.InitialState)
    "Heat pump energy"
    annotation (Placement(transformation(extent={{-60,210},{-40,230}})));
  Modelica.Blocks.Continuous.Integrator EHexEne(initType=Modelica.Blocks.Types.Init.InitialState)
    "Heat exchanger energy"
    annotation (Placement(transformation(extent={{20,190},{40,210}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter heaPumEne(k=nGenMod)
    "Heat pump energy"
    annotation (Placement(transformation(extent={{80,210},{100,230}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter hexEne(k=nGenMod)
    "Heat exchanger energy"
    annotation (Placement(transformation(extent={{120,190},{140,210}})));

  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMul3[2](
    redeclare each final package Medium = MediumW,
    each allowFlowReversal=false,
    k=fill(2, 2))
    annotation (Placement(transformation(extent={{160,40},{180,60}})));
  Buildings.Fluid.Sources.Boundary_ph sin[2](redeclare each package Medium =
        MediumW,
      nPorts=1) "Sink"
    annotation (Placement(transformation(extent={{180,100},{160,120}})));
  Buildings.Fluid.Sources.Boundary_ph sin1[2](redeclare each package Medium =
        MediumW,
      nPorts=1) "Sink"
    annotation (Placement(transformation(extent={{180,-80},{160,-60}})));
  Buildings.Fluid.Sources.MassFlowSource_T sou[2](
    redeclare each package Medium = MediumW,
    each use_m_flow_in=true,
    each use_T_in=true,
    each nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{40,100},{60,120}})));
  Buildings.Fluid.Sensors.MassFlowRate entEdgBorMasFlo[2](redeclare each
      package Medium = MediumW,             each allowFlowReversal=false)
    "Mass flow rate entering edge borefield"
    annotation (Placement(transformation(extent={{30,40},{50,60}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort entEdgBorTem[2](
    redeclare each package Medium = MediumW,each allowFlowReversal=false,
    each m_flow_nominal=mBorMod_flow_nominual/2)
    "Water flow temperature to the edge borefield"
    annotation (Placement(transformation(extent={{60,40},{80,60}})));
  Buildings.Fluid.Sensors.MassFlowRate entCorBorMasFlo[2](redeclare each
      package Medium = MediumW,             each allowFlowReversal=false)
    "Mass flow rate entering core borefield"
    annotation (Placement(transformation(extent={{30,10},{50,-10}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort entCorBorTem[2](
    redeclare each package Medium = MediumW,each allowFlowReversal=false,
    each m_flow_nominal=mBorMod_flow_nominual/2)
    "Water flow temperature to the core borefield"
    annotation (Placement(transformation(extent={{60,10},{80,-10}})));
  Buildings.Fluid.Sources.MassFlowSource_T sou1[2](
    redeclare each package Medium = MediumW,
    each use_m_flow_in=true,
    each use_T_in=true,
    each nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{40,-80},{60,-60}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter floGai[2](each k=2)
    "Flow rate to the adjacent modules"
    annotation (Placement(transformation(extent={{-20,108},{0,128}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter floGai1[2](each k=4)
    "Flow rate to the adjacent modules"
    annotation (Placement(transformation(extent={{-20,-72},{0,-52}})));

equation
  connect(del3.ports[1], entEdgBorMasFlo[1].port_a) annotation (Line(points={{1.6,0},
          {20,0},{20,50},{30,50}}, color={0,127,255},
      thickness=0.5));
  connect(del3.ports[2], entEdgBorMasFlo[2].port_a) annotation (Line(points={{0.8,0},
          {20,0},{20,50},{30,50}}, color={0,127,255},
      thickness=0.5));
  connect(del3.ports[3], entCorBorMasFlo[1].port_a) annotation (Line(points={{0,0},{
          18,0},{18,0},{30,0}},    color={0,127,255}));
  connect(del3.ports[4], entCorBorMasFlo[2].port_a) annotation (Line(points={{-0.8,0},
          {18,0},{18,0},{30,0}},   color={0,127,255},
      thickness=0.5));
  connect(del3.ports[5], masFloMul2.port_b) annotation (Line(points={{-1.6,0},{-20,
          0}},                     color={0,127,255},
      thickness=0.5));
  connect(entEdgBorTem[1].port_b, edgBorFie.port_a[1])
    annotation (Line(points={{80,50},{100,50}}, color={0,127,255},
      thickness=0.5));
  connect(entEdgBorTem[2].port_b, edgBorFie.port_a[2])
    annotation (Line(points={{80,50},{100,50}}, color={0,127,255},
      thickness=0.5));
  connect(entCorBorTem[1].port_b, corBorFie.port_a[1])
    annotation (Line(points={{80,0},{90,0},{90,0},{100,0}}, color={0,127,255},
      thickness=0.5));
  connect(entCorBorTem[2].port_b, corBorFie.port_a[2])
    annotation (Line(points={{80,0},{90,0},{90,0},{100,0}}, color={0,127,255},
      thickness=0.5));
  connect(edgBorFie.port_b[1], masFloMul3[1].port_a) annotation (Line(
      points={{120,50},{160,50}},
      color={0,127,255},
      thickness=0.5));
  connect(edgBorFie.port_b[2], masFloMul3[2].port_a) annotation (Line(
      points={{120,50},{160,50}},
      color={0,127,255},
      thickness=0.5));
  connect(corBorFie.port_b[1], masFloMul4[1].port_a)
    annotation (Line(points={{120,0},{160,0}},   color={0,127,255},
      thickness=0.5));
  connect(corBorFie.port_b[2], masFloMul4[2].port_a)
    annotation (Line(points={{120,0},{160,0}},   color={0,127,255},
      thickness=0.5));
  connect(masFloMul3.port_b, del1.ports[1:2]) annotation (Line(
      points={{180,50},{190,50},{190,0},{210.8,0}},
      color={0,127,255},
      thickness=0.5));
  connect(masFloMul4.port_b, del1.ports[3:4]) annotation (Line(points={{180,0},{
          209.2,0}},color={0,127,255},
      thickness=0.5));
  connect(del1.ports[5], leaBorTem.port_a)
    annotation (Line(points={{208.4,0},{230,0}}, color={0,127,255},
      thickness=0.5));


  connect(sou[1].ports[1], edgBorFie.port_a[3]) annotation (Line(
      points={{60,110},{90,110},{90,50},{100,50}},
      color={0,127,255},
      thickness=0.5));
  connect(sou[2].ports[1], edgBorFie.port_a[4]) annotation (Line(
      points={{60,110},{90,110},{90,50},{100,50}},
      color={0,127,255},
      thickness=0.5));
  connect(sou1[1].ports[1], corBorFie.port_a[3]) annotation (Line(
      points={{60,-70},{90,-70},{90,0},{100,0}},
      color={0,127,255},
      thickness=0.5));
  connect(sou1[2].ports[1], corBorFie.port_a[4]) annotation (Line(
      points={{60,-70},{90,-70},{90,0},{100,0}},
      color={0,127,255},
      thickness=0.5));
  connect(sin[1].ports[1], edgBorFie.port_b[3]) annotation (Line(
      points={{160,110},{140,110},{140,50},{120,50}},
      color={0,127,255},
      thickness=0.5));
  connect(sin[2].ports[1], edgBorFie.port_b[4]) annotation (Line(
      points={{160,110},{140,110},{140,50},{120,50}},
      color={0,127,255},
      thickness=0.5));
  connect(sin1[1].ports[1], corBorFie.port_b[3]) annotation (Line(
      points={{160,-70},{140,-70},{140,0},{120,0}},
      color={0,127,255},
      thickness=0.5));
  connect(sin1[2].ports[1], corBorFie.port_b[4]) annotation (Line(
      points={{160,-70},{140,-70},{140,0},{120,0}},
      color={0,127,255},
      thickness=0.5));


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





  connect(uDisPum, gen.uDisPum) annotation (Line(points={{-260,120},{-170,120},{
          -170,9},{-162,9}}, color={0,0,127}));
  connect(uSolTim, gen.uSolTim) annotation (Line(points={{-260,80},{-180,80},{-180,
          7},{-162,7}}, color={0,0,127}));
  connect(TMixAve, gen.TMixAve) annotation (Line(points={{-260,40},{-190,40},{-190,
          3},{-162,3}}, color={0,0,127}));
  connect(TDryBul, gen.TDryBul) annotation (Line(points={{-260,-40},{-180,-40},{
          -180,-7},{-162,-7}}, color={0,0,127}));
  connect(gen.yEleRat, yEleRat) annotation (Line(points={{-138,9},{-130,9},{-130,
          240},{340,240}}, color={0,0,127}));
  connect(gai1.y, PPumDryCoo)
    annotation (Line(points={{2,180},{340,180}},  color={0,0,127}));
  connect(gai2.y, PPumHexGly)
    annotation (Line(points={{42,150},{340,150}},
                                                color={0,0,127}));
  connect(gen.PPumDryCoo, gai1.u) annotation (Line(points={{-138,5},{-114,5},{-114,
          180},{-22,180}},color={0,0,127}));
  connect(gen.PPumHexGly, gai2.u) annotation (Line(points={{-138,3},{-106,3},{-106,
          150},{18,150}},
                        color={0,0,127}));
  connect(gen.PPumCirPum, gai6.u) annotation (Line(points={{-138,-9},{-130,-9},{
          -130,-240},{-102,-240}},color={0,0,127}));
  connect(gai6.y, PPumCirPum)
    annotation (Line(points={{-78,-240},{340,-240}}, color={0,0,127}));
  connect(gen.PPumHeaPumWat, gai5.u) annotation (Line(points={{-138,-7},{-122,-7},
          {-122,-210},{-62,-210}}, color={0,0,127}));
  connect(gai5.y, PPumHeaPumWat)
    annotation (Line(points={{-38,-210},{340,-210}}, color={0,0,127}));
  connect(gen.PCom, gai4.u) annotation (Line(points={{-138,-5},{-114,-5},{-114,-180},
          {-22,-180}},color={0,0,127}));
  connect(gai4.y, PCom)
    annotation (Line(points={{2,-180},{340,-180}},  color={0,0,127}));
  connect(gen.PPumHeaPumGly, gai3.u) annotation (Line(points={{-138,-3},{-106,-3},
          {-106,-150},{18,-150}},
                               color={0,0,127}));
  connect(gai3.y, PPumHeaPumGly)
    annotation (Line(points={{42,-150},{340,-150}},
                                                  color={0,0,127}));
  connect(masFloMul1.port_b, entBorTem.port_a)
    annotation (Line(points={{-80,0},{-70,0}}, color={0,127,255},
      thickness=0.5));
  connect(entBorTem.port_b, masFloMul2.port_a)
    annotation (Line(points={{-50,0},{-40,0}}, color={0,127,255},
      thickness=0.5));
  connect(entBorTem.T, sub.u2)
    annotation (Line(points={{-60,11},{-60,34},{258,34}}, color={0,0,127}));
  connect(leaBorTem.T, sub.u1)
    annotation (Line(points={{240,11},{240,46},{258,46}}, color={0,0,127}));
  connect(leaBorTem.port_b, senMasFlo.port_a)
    annotation (Line(points={{250,0},{270,0}}, color={0,127,255}));
  connect(senMasFlo.port_b, port_b)
    annotation (Line(points={{290,0},{322,0}}, color={0,127,255}));
  connect(sub.y, mul.u2) annotation (Line(points={{282,40},{288,40},{288,60},{224,
          60},{224,-46},{238,-46}}, color={0,0,127}));
  connect(senMasFlo.m_flow, mul.u1) annotation (Line(points={{280,11},{280,20},{
          228,20},{228,-34},{238,-34}}, color={0,0,127}));
  connect(mul.y, heaCap.u)
    annotation (Line(points={{262,-40},{278,-40}}, color={0,0,127}));
  connect(heaCap.y, QBorOut_flow)
    annotation (Line(points={{302,-40},{340,-40}}, color={0,0,127}));
  connect(heaPumHea.y, EHeaPumEne.u)
    annotation (Line(points={{-79,220},{-62,220}}, color={0,0,127}));
  connect(hexHea.y, EHexEne.u)
    annotation (Line(points={{-79,200},{18,200}}, color={0,0,127}));
  connect(EHeaPumEne.y, heaPumEne.u)
    annotation (Line(points={{-39,220},{78,220}}, color={0,0,127}));
  connect(EHexEne.y, hexEne.u)
    annotation (Line(points={{41,200},{118,200}}, color={0,0,127}));
  connect(entEdgBorMasFlo.port_b, entEdgBorTem.port_a)
    annotation (Line(points={{50,50},{60,50}}, color={0,127,255},
      thickness=0.5));


  connect(entCorBorMasFlo.port_b, entCorBorTem.port_a)
    annotation (Line(points={{50,0},{60,0}}, color={0,127,255},
      thickness=0.5));

  connect(entEdgBorMasFlo.m_flow, floGai.u) annotation (Line(points={{40,61},{40,
          80},{-40,80},{-40,118},{-22,118}}, color={0,0,127}));
  connect(floGai.y, sou.m_flow_in)
    annotation (Line(points={{2,118},{38,118}}, color={0,0,127}));
  connect(entEdgBorTem.T, sou.T_in) annotation (Line(points={{70,61},{70,90},{20,
          90},{20,114},{38,114}}, color={0,0,127}));
  connect(entCorBorMasFlo.m_flow, floGai1.u) annotation (Line(points={{40,-11},{
          40,-20},{-40,-20},{-40,-62},{-22,-62}}, color={0,0,127}));
  connect(floGai1.y, sou1.m_flow_in)
    annotation (Line(points={{2,-62},{38,-62}}, color={0,0,127}));
  connect(entCorBorTem.T, sou1.T_in) annotation (Line(points={{70,-11},{70,-30},
          {20,-30},{20,-66},{38,-66}}, color={0,0,127}));
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
          extent={{-240,-280},{320,280}})));
end CentralPlantMultiFlow;
