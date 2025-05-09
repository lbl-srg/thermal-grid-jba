within ThermalGridJBA.Networks.Validation;
model DetailedPlantFiveHubs_requirements
  "District network with five hubs and the detailed plant"
  extends Modelica.Icons.Example;
  Real fracPL[nBui + 2] "The pressure drop per length unti (Pa/m)";
  Real y_value[19] "Valves actuator values";
  package Medium = Buildings.Media.Water "Medium model";

  parameter Modelica.Units.SI.Length diameter=sqrt(4*datDis.mPipDis_flow_nominal/1000/1.5/Modelica.Constants.pi)
    "Pipe diameter (without insulation)";
  parameter Modelica.Units.SI.Radius rPip=diameter/2 "Pipe external radius";
  parameter Modelica.Units.SI.Radius thiGroLay=1.0
    "Dynamic ground layer thickness";
  parameter Real dpDis_length_nominal(unit="Pa/m")=250
    "Pressure drop per pipe length at nominal flow rate - Distribution line";
  parameter Real dpCon_length_nominal(unit="Pa/m")=250
    "Pressure drop per pipe length at nominal flow rate - Connection line";
  parameter Boolean allowFlowReversalSer = false
    "Set to true to allow flow reversal in the service lines"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Boolean allowFlowReversalBui = false
    "Set to true to allow flow reversal for in-building systems"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Modelica.Units.SI.Length dhPla(
    fixed=false,
    min=0.01,
    start=0.05)
    "Hydraulic diameter of the distribution pipe before each connection";
  // Central plant
  parameter Real staDowDel(unit="s")=datDis.staDowDel
    "Minimum stage down delay, to avoid quickly staging down"
   annotation (Dialog(tab="Central plant"));
  parameter Real TApp(unit="K")=4
    "Approach temperature for sizing heat pump and the operational condition for dry cooler"
    annotation (Dialog(tab="Central plant"));
  parameter Real TPlaHeaSet(unit="K")=datDis.TPlaHeaSet
    "Design plant heating setpoint temperature"
    annotation (Dialog(tab="Central plant"));
  parameter Real TPlaCooSet(unit="K")=datDis.TPlaCooSet
    "Design plant cooling setpoint temperature"
    annotation (Dialog(tab="Central plant"));

  parameter Real mPlaWat_flow_nominal(unit="kg/s")=datDis.mPlaWat_flow_nominal
    "Nominal water mass flow rate to each generation module"
    annotation (Dialog(tab="Central plant"));
  parameter Real dpPlaValve_nominal(unit="Pa")=datDis.dpPlaValve_nominal
    "Nominal pressure drop of fully open 2-way valve"
    annotation (Dialog(tab="Central plant"));
  // Central plant: heat exchangers
  parameter Real dpPlaHex_nominal(unit="Pa")=datDis.dpPlaHex_nominal
    "Pressure difference across heat exchanger"
    annotation (Dialog(tab="Central plant", group="Heat exchanger"));
  parameter Real mPlaHexGly_flow_nominal(unit="kg/s")=datDis.mPlaHexGly_flow_nominal
    "Nominal glycol mass flow rate for heat exchanger"
    annotation (Dialog(tab="Central plant", group="Heat exchanger"));
  // Central plant: dry coolers
  parameter Real dpDryCoo_nominal(unit="Pa")=datDis.dpDryCoo_nominal
    "Nominal pressure drop of dry cooler"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  parameter Real mDryCoo_flow_nominal(unit="kg/s")=datDis.mDryCoo_flow_nominal
    "Nominal glycol mass flow rate for dry cooler"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  parameter Real TDryAppSet(unit="K")=datDis.TDryAppSet
    "Dry cooler approach setpoint"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  parameter Real minFanSpe(unit="1")=datDis.minFanSpe
    "Minimum dry cooler fan speed"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  // Central plant: heat pumps
  parameter Real mPlaHeaPumWat_flow_nominal(unit="kg/s")=datDis.mPlaHeaPumWat_flow_nominal
    "Central Heat pump nominal water mass flow rate"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real mPlaHeaPumWat_flow_min(unit="kg/s")=datDis.mPlaHeaPumWat_flow_min
    "Heat pump minimum water mass flow rate"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real mHpGly_flow_nominal(unit="kg/s")=datDis.mHpGly_flow_nominal
    "Nominal glycol mass flow rate for heat pump"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real QPlaHeaPumHea_flow_nominal(unit="W")=datDis.QPlaHeaPumHea_flow_nominal
    "Nominal heating capacity"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaConHea_nominal(unit="K")=datDis.TPlaConHea_nominal
    "Nominal temperature of the heated fluid in heating mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaEvaHea_nominal(unit="K")=datDis.TPlaEvaHea_nominal
    "Nominal temperature of the cooled fluid in heating mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real QPlaHeaPumCoo_flow_nominal(unit="W")=datDis.QPlaHeaPumCoo_flow_nominal
    "Nominal cooling capacity"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaConCoo_nominal(unit="K")=datDis.TPlaConCoo_nominal
    "Nominal temperature of the cooled fluid in cooling mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaEvaCoo_nominal(unit="K")=datDis.TPlaEvaCoo_nominal
    "Nominal temperature of the heated fluid in cooling mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaConInMin(unit="K")=datDis.TPlaConInMin
    "Minimum condenser inlet temperature"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaEvaInMax(unit="K")=datDis.TPlaEvaInMax
    "Maximum evaporator inlet temperature"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real minPlaComSpe(unit="1")=datDis.minPlaComSpe
    "Minimum heat pump compressor speed"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real minHeaPumSpeHol=datDis.minHeaPumSpeHol
    "Threshold time for checking if the compressor has been in the minimum speed"
     annotation (Dialog(tab="Central plant", group="Heat pump"));
//   parameter Real TCooSet(unit="K")=datDis.TCooSet
//     "Heat pump tracking temperature setpoint in cooling mode"
//     annotation (Dialog(tab="Central plant", group="Heat pump"));
//   parameter Real THeaSet(unit="K")=datDis.THeaSet
//     "Heat pump tracking temperature setpoint in heating mode"
//     annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real offTim(unit="s")=datDis.offTim
    "Heat pump off time due to the low compressor speed"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real holOnTim(unit="s")=datDis.holOnTim
    "Heat pump hold on time"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real holOffTim(unit="s")=datDis.holOffTim
    "Heat pump hold off time"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  // District pump
  parameter Real TUpp(unit="K")=datDis.TUpp
    "Upper bound temperature"
    annotation (Dialog(tab="District pump"));
  parameter Real TLow(unit="K")=datDis.TLow
    "Lower bound temperature"
    annotation (Dialog(tab="District pump"));
  parameter Real dTSlo(unit="K")=datDis.dTSlo
    "Temperature deadband for changing pump speed"
    annotation (Dialog(tab="District pump"));
  parameter Real yDisPumMin(unit="1")=datDis.yDisPumMin
    "District loop pump minimum speed"
    annotation (Dialog(tab="District pump"));

  final parameter Integer nBui=datDis.nBui
    "Number of buildings connected to DHC system"
    annotation (Evaluate=true);
  parameter ThermalGridJBA.Data.Districts.FiveHubs datDis(
    mCon_flow_nominal=bui.ets.hex.m1_flow_nominal)
    "Parameters for the district network"
    annotation (Placement(transformation(extent={{-380,180},{-360,200}})));

  parameter ThermalGridJBA.Data.BuildingSetPoints datBuiSet
    "Parameter for the building set points"
    annotation (Placement(transformation(extent={{-380,142},{-360,162}})));

  Buildings.Fluid.FixedResistances.BuriedPipes.PipeGroundCoupling pipeGroundCouplingMulti[nBui + 1](
    lPip=datDis.lDis,
    each rPip=rPip,
    each thiGroLay=thiGroLay,
    each nSeg=1,
    each nSta=2,
    redeclare parameter ThermalGridJBA.Networks.Data.Andrew_AFB cliCon,
    redeclare parameter Buildings.HeatTransfer.Data.Soil.Generic soiDat(
      each k=2.3,
      each c=1000,
      each d=2600))
    annotation (Placement(transformation(extent={{-10,180},{12,160}})));

  Buildings.DHC.Networks.Distribution1PipePlugFlow_v dis(
    nCon=nBui,
    allowFlowReversal=allowFlowReversalSer,
    redeclare package Medium = Medium,
    show_entFlo=true,
    show_TOut=true,
    mDis_flow_nominal=datDis.mPipDis_flow_nominal,
    mCon_flow_nominal=datDis.mCon_flow_nominal,
    lDis=datDis.lDis[1:end - 1],
    lEnd=datDis.lDis[end],
    dIns=0.02,
    kIns=0.2)
    annotation (Placement(transformation(extent={{-20,190},{20,210}})));
  Buildings.DHC.ETS.BaseClasses.Pump_m_flow pumDis(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDis.mPumDis_flow_nominal,
    allowFlowReversal=false,
    final dp_nominal=sum(dis.con.pipDis.res.dp_nominal) + dis.pipEnd.res.dp_nominal)
    "Distribution pump"
    annotation (Placement(transformation(
      extent={{10,-10},{-10,10}},
      rotation=90,
      origin={90,-60})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium=Medium, nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={128,-40})));
  Buildings.DHC.Networks.Connections.Connection1Pipe_R conPla(
    redeclare final package Medium = Medium,
    final mDis_flow_nominal=datDis.mPipDis_flow_nominal,
    final mCon_flow_nominal=sum(datDis.mCon_flow_nominal),
    lDis=50,
    final allowFlowReversal=allowFlowReversalSer,
    dhDis=dhPla)
    "Connection to the plant (pressure drop lumped in plant and network model)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-10})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatSup(
    redeclare final package Medium = Medium,
    allowFlowReversal=false,
    final m_flow_nominal=datDis.mPumDis_flow_nominal)
    "District water supply temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,170})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatRet(
    redeclare final package Medium = Medium,
    allowFlowReversal=false,
   final m_flow_nominal=datDis.mPumDis_flow_nominal)
    "District water return temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-80})));
  ThermalGridJBA.Hubs.ConnectedETS bui[nBui](
    final facTerUniSizHea=datBuiSet.facTerUniSizHea,
    final filNam = datDis.filNamInd,
    bui(each final facMul=1),
    redeclare each final package MediumBui = Medium,
    redeclare each final package MediumSer = Medium,
    each final allowFlowReversalBui=allowFlowReversalBui,
    each final allowFlowReversalSer=allowFlowReversalSer,
    each final TDisWatMin=datDis.TLooMin,
    each final TDisWatMax=datDis.TLooMax,
    each have_eleNonHva=true)             "Building and ETS"
    annotation (Placement(transformation(extent={{-10,230},{10,250}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PPumETS(
    nin=nBui,
    u(each unit="W"),
    y(each unit="W"))
    "ETS pump power"
    annotation (Placement(transformation(extent={{120,190},{140,210}})));
  Modelica.Blocks.Continuous.Integrator EPumETS(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh")) "ETS pump electric energy"
    annotation (Placement(transformation(extent={{240,190},{260,210}})));
  Modelica.Blocks.Continuous.Integrator EPumDis(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Distribution pump electric energy"
    annotation (Placement(transformation(extent={{200,-90},{220,-70}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum EPum(
    nin=2,
    u(each unit="J",
     each displayUnit="Wh"),
    y(each unit="J",
      each displayUnit="Wh"))
    "Total pump electric energy"
    annotation (Placement(transformation(extent={{300,120},{320,140}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PHeaPump(nin=nBui)
    "Heat pump power"
    annotation (Placement(transformation(extent={{180,170},{200,190}})));
  Modelica.Blocks.Continuous.Integrator EHeaPum(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Heat pump electric energy"
    annotation (Placement(transformation(extent={{240,150},{260,170}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum ETot(
    nin=7,
    u(each unit="J",
      each displayUnit="Wh"),
    y(each unit="J",
      each displayUnit="Wh"))
    "Total electric energy"
    annotation (Placement(transformation(extent={{360,90},{380,110}})));
  Buildings.DHC.Loads.BaseClasses.ConstraintViolation conVio(
    final uMin(final unit="K", displayUnit="degC")=datDis.TLooMin,
    final uMax(final unit="K", displayUnit="degC")=datDis.TLooMax,
    u(each final unit="K", each displayUnit="degC"),
    nu=2)
    "Check if loop temperatures are within given range"
    annotation (Placement(transformation(extent={{-220,220},{-200,240}})));
  CentralPlants.CentralPlant cenPla(
    final TLooMin=datDis.TLooMin,
    final TLooMax=datDis.TLooMax,
    final TPlaHeaSet=TPlaHeaSet,
    final TPlaCooSet=TPlaCooSet,
    final mWat_flow_nominal=mPlaWat_flow_nominal,
    final dpValve_nominal=dpPlaValve_nominal,
    final dpHex_nominal=dpPlaHex_nominal,
    final mHexGly_flow_nominal=mPlaHexGly_flow_nominal,
    final dpDryCoo_nominal=dpDryCoo_nominal,
    final mDryCoo_flow_nominal=mDryCoo_flow_nominal,
    final mHeaPumWat_flow_nominal=mPlaHeaPumWat_flow_nominal,
    final mHeaPumWat_flow_min=mPlaHeaPumWat_flow_min,
    final mHpGly_flow_nominal=mHpGly_flow_nominal,
    final QHeaPumHea_flow_nominal=QPlaHeaPumHea_flow_nominal,
    final TConHea_nominal=TPlaConHea_nominal,
    final TEvaHea_nominal=TPlaEvaHea_nominal,
    final QHeaPumCoo_flow_nominal=QPlaHeaPumCoo_flow_nominal,
    final TConCoo_nominal=TPlaConCoo_nominal,
    final TEvaCoo_nominal=TPlaEvaCoo_nominal,
    final staDowDel=staDowDel,
    final TDryAppSet=TDryAppSet,
    final TApp=TApp,
    final minFanSpe=minFanSpe,
    final TConInMin=TPlaConInMin,
    final TEvaInMax=TPlaEvaInMax,
    final offTim=offTim,
    final holOnTim=holOnTim,
    final holOffTim=holOffTim,
    final minComSpe=minPlaComSpe,
    final TSoi_start=datDis.TSoi_start,
    final minHeaPumSpeHol=minHeaPumSpeHol)
                                  "Central plant"
    annotation (Placement(transformation(extent={{-180,-10},{-160,10}})));
  Controls.DistrictLoopPump looPumSpe(
    final TUpp=TUpp,
    final TLow=TLow,
    final dTSlo=dTSlo,
    final yMin=yDisPumMin) "District loop pump control"
    annotation (Placement(transformation(extent={{-218,180},{-198,200}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(final k=datDis.mPumDis_flow_nominal)
    "District pump speed"
    annotation (Placement(transformation(extent={{-180,180},{-160,200}})));
//   BoundaryConditions.WeatherDataFTMY weaDat[nBui](computeWetBulbTemperature=
//         fill(true, nBui)) "Weather data reader"
//     annotation (Placement(transformation(extent={{-380,-30},{-360,-10}})));
  Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
        transformation(extent={{-320,-40},{-280,0}}), iconTransformation(extent
          ={{-364,-80},{-344,-60}})));
  Modelica.Blocks.Continuous.Integrator EPumDryCoo(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh")) "Dry cooler pump electric energy"
    annotation (Placement(transformation(extent={{100,118},{120,138}})));
  Modelica.Blocks.Continuous.Integrator EPumHeaPumGly(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Heat pump glycol side pump electric energy"
    annotation (Placement(transformation(extent={{180,80},{200,100}})));
  Modelica.Blocks.Continuous.Integrator EPumHexGly(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Heat exchanger glycol side pump electric energy"
    annotation (Placement(transformation(extent={{140,100},{160,120}})));
  Modelica.Blocks.Continuous.Integrator EComPla(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Plant heat pumps compressor electric energy"
    annotation (Placement(transformation(extent={{240,20},{260,40}})));
  Modelica.Blocks.Continuous.Integrator EPumHeaPumWat(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Heat pump water side pump electric energy"
    annotation (Placement(transformation(extent={{140,0},{160,20}})));
  Modelica.Blocks.Continuous.Integrator EPumCirPum(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Circulation pump electric energy"
    annotation (Placement(transformation(extent={{180,-38},{200,-18}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum EPumPla(
    nin=7,
    u(each unit="J",
      each displayUnit="Wh"),
    y(each unit="J",
      each displayUnit="Wh"))
    "Plant pumps electricity energy"
    annotation (Placement(transformation(extent={{240,60},{260,80}})));
  Buildings.Controls.OBC.CDL.Reals.MultiMax TLooMaxMea(y(unit="K", displayUnit=
          "degC"), nin=4) "Maximum mixing temperature"
    annotation (Placement(transformation(extent={{-300,220},{-280,240}})));
  Buildings.Controls.OBC.CDL.Reals.MultiMin TLooMinMea(y(unit="K", displayUnit=
          "degC"), nin=4) "Minimum mixing temperature"
    annotation (Placement(transformation(extent={{-300,190},{-280,210}})));
  BoundaryConditions.WeatherData weaDat(final weaFil=datDis.weaFil)
    "Weather data reader"
    annotation (Placement(transformation(extent={{-380,-30},{-360,-10}})));

  Modelica.Blocks.Continuous.Integrator EBorPer(
    k=-1,
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Borefield energy for perimeter"
    annotation (Placement(transformation(extent={{-100,-250},{-80,-230}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Water flow temperature difference across central plant"
    annotation (Placement(transformation(extent={{80,-230},{100,-210}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul
    annotation (Placement(transformation(extent={{140,-180},{160,-160}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter plaHeaSup(final k=4184)
    "Heat flow rate supply from central plant"
    annotation (Placement(transformation(extent={{180,-180},{200,-160}})));
  Modelica.Blocks.Continuous.Integrator EPlaHea(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Energy supply from central plant"
    annotation (Placement(transformation(extent={{340,-190},{360,-170}})));
  Modelica.Blocks.Continuous.Integrator EEts[nBui](
    each initType=Modelica.Blocks.Types.Init.InitialState,
    u(each final unit="W"),
    y(each final unit="J",
      each displayUnit="Wh")) "Heat flow through each ETS"
    annotation (Placement(transformation(extent={{100,150},{120,170}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum ETotEts(nin=nBui)
    "Sum of all the ETS heat flow"
    annotation (Placement(transformation(extent={{140,150},{160,170}})));
  Modelica.Blocks.Continuous.Integrator EBorCen(
    k=-1,
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Borefield energy for center"
    annotation (Placement(transformation(extent={{-100,-286},{-80,-266}})));
  Modelica.Blocks.Continuous.Integrator EPumBorFiePer(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Pump electric energy for borefield perimeter"
    annotation (Placement(transformation(extent={{140,60},{160,80}})));
  Modelica.Blocks.Continuous.Integrator EPumBorFieCen(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J",
      displayUnit="Wh"))
    "Pump electric energy for borefield center"
    annotation (Placement(transformation(extent={{100,40},{120,60}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter eleRat(k=1/(3600*1000))
    "Electricity rate, in $/w"
    annotation (Placement(transformation(extent={{120,-130},{140,-110}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul1
    annotation (Placement(transformation(extent={{300,-140},{320,-120}})));
  Modelica.Blocks.Continuous.Integrator totEleCos(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "Total electricity cost, in dollar"
    annotation (Placement(transformation(extent={{340,-140},{360,-120}})));
  Modelica.Blocks.Math.MultiSum multiSum(nu=14)
    annotation (Placement(transformation(extent={{240,-160},{260,-140}})));
  CentralPlants.BaseClasses.BorefieldTemperatureChange dTSoiPer(
    T_start=datDis.TSoi_start,
    V=(63 - 39)*445.5*91) "Borefield temperature change for perimeter"
    annotation (Placement(transformation(extent={{260,-220},{280,-200}})));
  CentralPlants.BaseClasses.BorefieldTemperatureChange dTSoiCen(
    T_start=datDis.TSoi_start,
    V=39*445.5*91) "Borefield temperature change for center"
    annotation (Placement(transformation(extent={{260,-250},{280,-230}})));
  CentralPlants.BaseClasses.BorefieldTemperatureChange dTSoi(
    T_start=datDis.TSoi_start,
    V=63*445.5*91) "Borefield temperature change on average"
    annotation (Placement(transformation(extent={{260,-280},{280,-260}})));
  Buildings.Controls.OBC.CDL.Reals.Add EBor(
    u1(final unit="J", displayUnit="Wh"),
    u2(final unit="J", displayUnit="Wh"),
    y(final unit="J", displayUnit="Wh"))
    "Total energy exchange with borehole"
    annotation (Placement(transformation(extent={{220,-280},{240,-260}})));
  Buildings.Utilities.IO.Files.Printer priBorFie(
    samplePeriod(displayUnit="d") = 31536000,
    header="Average center perimeter",
    fileName="BorefieldTemperatureChanges.csv",
    nin=3,
    configuration=3) "Printer for borefield temperature changes"
    annotation (Placement(transformation(extent={{300,-280},{320,-260}})));
  Buildings.Controls.OBC.CDL.Routing.RealExtractSignal TLooMea(
    nin=5,
    nout=4,
    u(each final unit="K", each displayUnit="degC"),
    y(each final unit="K", each displayUnit="degC"))
    "Measured loop temperatures to be controlled. This does not include mixing after the last ETS"
    annotation (Placement(transformation(extent={{120,224},{140,244}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum QEtsHex_flow(
    u(each final unit="W"),
    y(final unit="W"),
    nin=nBui)
    "Sum of all heat exchanger heat flow rates"
    annotation (Placement(transformation(extent={{40,216},{60,236}})));
  Modelica.Blocks.Continuous.Integrator EFanDryCoo(
    initType=Modelica.Blocks.Types.Init.InitialState,
    u(final unit="W"),
    y(final unit="J", displayUnit="Wh")) "Dry cooler fan electric energy"
    annotation (Placement(transformation(extent={{40,140},{60,160}})));

  Modelica.Blocks.Continuous.Integrator EEleNonHvaETS(initType=Modelica.Blocks.Types.Init.InitialState)
    "Non-HVAC electric use in the ETS"
    annotation (Placement(transformation(extent={{240,230},{260,250}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PEleNonHva(final nin=nBui)
    "Non-HVAC electric power"
    annotation (Placement(transformation(extent={{180,230},{200,250}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PFanBuiSum(final nin=nBui)
    "Sum of fan electric power consumption of the buildings"
    annotation (Placement(transformation(extent={{180,270},{200,290}})));
  Modelica.Blocks.Continuous.Integrator EFanBui(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "Building fan electric energy"
    annotation (Placement(transformation(extent={{240,270},{260,290}})));
  Modelica.Blocks.Sources.RealExpression PFanBui[nBui](y=bui.bui.addPFan.y)
    "Fan electric power consumption of each building"
    annotation (Placement(transformation(extent={{120,270},{140,290}})));
  CentralPlants.BorefieldMILP borMil
    annotation (Placement(transformation(extent={{340,-280},{360,-260}})));
  Modelica.Blocks.Sources.RealExpression senTemDhwSup[nBui](y={45 + 273.15,bui[2].ets.dhw.domHotWatTan.senTemHot.T,
        bui[3].ets.dhw.domHotWatTan.senTemHot.T,bui[4].ets.dhw.domHotWatTan.senTemHot.T,
        bui[5].ets.dhw.domHotWatTan.senTemHot.T})
    annotation (Placement(transformation(extent={{500,340},{520,360}})));
  Buildings_Requirements.WithinBand reqTDhwSup[nBui](
    name="DHW",
    text="O-301: The domestic hot water supply temperature must be 45°C ± 1 K.",
    delayTime=30,
    u_max(
      final unit="K",
      each displayUnit="degC") = 319.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 317.15,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for domestic hot water supply temperature"
    annotation (Placement(transformation(extent={{540,340},{560,360}})));
  Buildings_Requirements.WithinBand reqTDhwTan[nBui](
    name="DHW",
    text="O-302: The heating water temperature that serves the domestic hot water tank must be 50°C ± 1 K once the tank charging is on for 5 minutes.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="degC") = 324.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 322.15,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for The heating water temperature that serves the domestic hot water tank"
    annotation (Placement(transformation(extent={{540,280},{560,300}})));
  Modelica.Blocks.Sources.RealExpression TTanTop[nBui](y={50 + 273.15,bui[2].ets.dhw.domHotWatTan.TTanTop.T,
        bui[3].ets.dhw.domHotWatTan.TTanTop.T,bui[4].ets.dhw.domHotWatTan.TTanTop.T,
        bui[5].ets.dhw.domHotWatTan.TTanTop.T})
    annotation (Placement(transformation(extent={{500,290},{520,310}})));
  Modelica.Blocks.Sources.BooleanExpression DhwTanCha[nBui](y={false,bui[2].ets.dhw.charge,
        bui[3].ets.dhw.charge,bui[4].ets.dhw.charge,bui[5].ets.dhw.charge})
    annotation (Placement(transformation(extent={{500,270},{520,290}})));
  Modelica.Blocks.Sources.RealExpression THexSecLvg[nBui](y=bui.ets.hex.senT2WatLvg.T)
    annotation (Placement(transformation(extent={{500,240},{520,260}})));
  Buildings_Requirements.WithinBand reqTHexEtsPriLvg[nBui](
    name="ETS",
    text="O-306: At the district heat exchanger in the ETS, the primary side leaving water temperature that is fed back to the district loop must be between 6.5°C and 28°C.",
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="degC") = 301.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 279.65,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for  leaving water temperature on the primary side of the heat exchanger in the ETS "
    annotation (Placement(transformation(extent={{540,200},{560,220}})));
  Modelica.Blocks.Sources.RealExpression THexWatEnt[nBui](y=bui.ets.hex.senT2WatEnt.T)
    annotation (Placement(transformation(extent={{500,-280},{520,-260}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumEvaLvg[nBui](
    name="ETS",
    text="O-308: The heat pump evaporator leaving water temperature must be at least 15°C (preferably higher) once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump evaporator leaving water temperature"
    annotation (Placement(transformation(extent={{540,140},{560,160}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumConLvg[nBui](
    name="ETS",
    text=" O-309: The heat pump condenser leaving water temperature must not exceed 31°C once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump condenser leaving water temperature"
    annotation (Placement(transformation(extent={{540,60},{560,80}})));
  Buildings_Requirements.WithinBand reqTWatSer[nBui](
    name="Network",
    text="O-401: The water that is served to each service line must be between 10.5°C and 24°C.",
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="degC") = 297.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 283.65,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for heat pump evaporator temperature difference"
    annotation (Placement(transformation(extent={{540,-280},{560,-260}})));
  Modelica.Blocks.Sources.RealExpression THeaPumEvaLvg[nBui](y=bui.ets.chi.senTEvaLvg.T)
    annotation (Placement(transformation(extent={{500,160},{520,180}})));
  Modelica.Blocks.Sources.RealExpression THeaPumCon[nBui](y=bui.ets.chi.senTConLvg.T)
    annotation (Placement(transformation(extent={{500,60},{520,80}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valEvaOpen[nBui](h=0.01)
    annotation (Placement(transformation(extent={{500,110},{520,130}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valConOpen[nBui](h=0.01)
    annotation (Placement(transformation(extent={{500,30},{520,50}})));
  Modelica.Blocks.Sources.RealExpression valIsoEvaPos[nBui](y=bui.ets.valIsoEva.y_actual)
    annotation (Placement(transformation(extent={{460,110},{480,130}})));
  Modelica.Blocks.Sources.RealExpression valIsoConPos[nBui](y=bui.ets.valIsoCon.y_actual)
    annotation (Placement(transformation(extent={{460,30},{480,50}})));
  Modelica.Blocks.Sources.Constant TmaxHeaPumConLvg[nBui](k=31 + 273.15)
    annotation (Placement(transformation(extent={{500,80},{520,100}})));
  Modelica.Blocks.Sources.Constant TminHeaPumEva[nBui](k=15 + 273.15)
    annotation (Placement(transformation(extent={{500,140},{520,160}})));
  Buildings_Requirements.WithinBand reqTPlaMix(
    name="Central plant",
    text="O-503: The mixing water temperature in the district loop after the central plant must be between 10.5°C and 24°C.",
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="degC") = 297.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 283.65,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for mixing water temperature in the district loop after the central plant"
    annotation (Placement(transformation(extent={{540,-480},{560,-460}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOn[nBui](
    name="Heat pump",
    text="O-201_0: The heat pump must operate at least 30 min when activated.",
    durationMin(displayUnit="min") = 1800) "Requirement for heat pump on"
    annotation (Placement(transformation(extent={{540,420},{560,440}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOff[nBui](
    name="Heat pump",
    text="O-201_1: The heat pump must remain off for at least 10 minutes.",
    durationMin(displayUnit="min") = 600) "Requirement for heat pump off"
    annotation (Placement(transformation(extent={{540,380},{560,400}})));
  Modelica.Blocks.Logical.Not HeaPumOff[nBui]
    annotation (Placement(transformation(extent={{500,380},{520,400}})));
  Modelica.Blocks.Sources.BooleanExpression HeaPumOn[nBui](y=bui.ets.chi.con.yPum)
    annotation (Placement(transformation(extent={{460,420},{480,440}})));
  Buildings_Requirements.GreaterEqual reqPDis[nBui + 2](name="District loop",
      text="O-402: The pressure drop in the district loop and the service line must be no bigger than 125 Pa/m at full load.")
    "Requirement for pressure drop in the district loop"
    annotation (Placement(transformation(extent={{540,-340},{560,-320}})));
  Modelica.Blocks.Sources.RealExpression PDis[nBui + 2](y=fracPL)
    annotation (Placement(transformation(extent={{500,-360},{520,-340}})));
  Modelica.Blocks.Sources.Constant fracPLMax[nBui + 2](k=125)
    annotation (Placement(transformation(extent={{500,-320},{520,-300}})));
  Buildings_Requirements.WithinBand reqTHea[nBui](
    name="ETS",
    text="O-303: The space heating water supply temperature set point must be tracked within ± 1 K once the system is on for 5 minutes.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="K") = 1,
    u_min(
      final unit="K",
      each displayUnit="K") = 1,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for tracking the space heating water supply temperature set point"
    annotation (Placement(transformation(extent={{540,-400},{560,-380}})));
  Buildings_Requirements.WithinBand reqTCoo[nBui](
    name="ETS",
    text="O-304: The space cooling water supply temperature set point must be tracked within ± 1 K once the system is on for 5 minutes.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="K") = 1,
    u_min(
      final unit="K",
      each displayUnit="K") = 1,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for tracking the space cooling water supply temperature set point"
    annotation (Placement(transformation(extent={{540,-450},{560,-430}})));
  Modelica.Blocks.Math.Add THeaDiff[nBui](k2=-1)
    annotation (Placement(transformation(extent={{500,-390},{520,-370}})));
  Modelica.Blocks.Math.Add TCooDiff[nBui](k2=-1)
    annotation (Placement(transformation(extent={{500,-440},{520,-420}})));
  Modelica.Blocks.Sources.RealExpression THeaSup[nBui](y=bui.bui.disFloHea.senTSup.T)
    annotation (Placement(transformation(extent={{460,-384},{480,-364}})));
  Modelica.Blocks.Sources.RealExpression THeaSupSet[nBui](y=bui.THeaWatSupSet.y)
    annotation (Placement(transformation(extent={{460,-396},{480,-376}})));
  Modelica.Blocks.Sources.BooleanExpression BooOn[nBui](y=true)
    annotation (Placement(transformation(extent={{400,-420},{420,-400}})));
  Modelica.Blocks.Sources.RealExpression TCooSup[nBui](y=bui.bui.disFloCoo.senTSup.T)
    annotation (Placement(transformation(extent={{460,-434},{480,-414}})));
  Modelica.Blocks.Sources.RealExpression TCooSupSet[nBui](y=bui.TChiWatSupSet.y)
    annotation (Placement(transformation(extent={{460,-446},{480,-426}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage TRooHeaAvg60min[nBui](delta(
        each displayUnit="min") = 3600)
    annotation (Placement(transformation(extent={{500,-40},{520,-20}})));
  Modelica.Blocks.Sources.RealExpression TRooHea[nBui](y=bui.bui.terUniHea.TLoaODE.TAir)
    annotation (Placement(transformation(extent={{420,-70},{440,-50}})));
  Modelica.Blocks.Sources.RealExpression TRooHeaSet[nBui](y=bui.bui.terUniHea.TLoaODE.TSet)
    annotation (Placement(transformation(extent={{420,-30},{440,-10}})));
  Modelica.Blocks.Math.Add TRooHeaDif[nBui](k2=-1)
    annotation (Placement(transformation(extent={{460,-50},{480,-30}})));
  Modelica.Blocks.Continuous.Integrator TRooHeaAvgYea[nBui]
    annotation (Placement(transformation(extent={{500,-100},{520,-80}})));
  Modelica.Blocks.Sources.BooleanExpression last_value[nBui](y=terminal())
    annotation (Placement(transformation(extent={{420,-120},{440,-100}})));
  Buildings_Requirements.WithinBand reqTHexEtsSecLvg[nBui](
    name="ETS",
    text="O-305: At the district heat exchanger in the ETS, the secondary side leaving water temperature that serves the heat pumps must be between 9.5°C and 25°C.",
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="degC") = 298.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 282.65,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for leaving water temperature on the secondary side of the heat exchanger in the ETS "
    annotation (Placement(transformation(extent={{540,240},{560,260}})));
  Modelica.Blocks.Sources.RealExpression THexPriLvg[nBui](y=dis.con.senTOut.T)
    annotation (Placement(transformation(extent={{500,200},{520,220}})));
  Buildings_Requirements.GreaterEqual reqTRooHea[nBui](
    name="Room",
    text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for heating"
    annotation (Placement(transformation(extent={{540,-40},{560,-20}})));
  Modelica.Blocks.Sources.Constant TRooHeaDifMax[nBui](k=0.5)
    annotation (Placement(transformation(extent={{500,-10},{520,10}})));
  Buildings_Requirements.GreaterEqual reqTRooHeaAvg[nBui](
    name="Room",
    text="O-353_0: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    use_activeInput=true,
    delayTime(each displayUnit="s") = 0)
    "Requirement for the room temperature for heating (yearly average)"
    annotation (Placement(transformation(extent={{540,-88},{560,-68}})));
  Modelica.Blocks.Sources.Constant TRooHeaDifYea[nBui](k=0.05)
    annotation (Placement(transformation(extent={{500,-70},{520,-50}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage TRooCooAvg60min[nBui](delta(
        each displayUnit="min") = 3600)
    annotation (Placement(transformation(extent={{500,-180},{520,-160}})));
  Modelica.Blocks.Sources.RealExpression TRooCoo[nBui](y=bui.bui.terUniCoo.TLoaODE.TAir)
    annotation (Placement(transformation(extent={{420,-210},{440,-190}})));
  Modelica.Blocks.Sources.RealExpression TRooCooSet[nBui](y=bui.bui.terUniCoo.TLoaODE.TSet)
    annotation (Placement(transformation(extent={{420,-170},{440,-150}})));
  Modelica.Blocks.Math.Add TRooCooDif[nBui](k1=-1)
    annotation (Placement(transformation(extent={{460,-190},{480,-170}})));
  Modelica.Blocks.Continuous.Integrator TRooCooAvgYea[nBui]
    annotation (Placement(transformation(extent={{500,-240},{520,-220}})));
  Buildings_Requirements.GreaterEqual reqTRooCoo[nBui](
    name="Room",
    text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for cooling"
    annotation (Placement(transformation(extent={{540,-180},{560,-160}})));
  Modelica.Blocks.Sources.Constant TRooCooDifMax[nBui](k=0.5)
    annotation (Placement(transformation(extent={{500,-150},{520,-130}})));
  Buildings_Requirements.GreaterEqual reqTRooCooAvg[nBui](
    name="Room",
    text="O-353: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    use_activeInput=true,
    delayTime(each displayUnit="s") = 0)
    "Requirement for the room temperature for cooling (yearly average)"
    annotation (Placement(transformation(extent={{540,-228},{560,-208}})));
  Modelica.Blocks.Sources.Constant TRooCooDifYea[nBui](k=0.05)
    annotation (Placement(transformation(extent={{500,-210},{520,-190}})));
  Buildings_Requirements.StableContinuousSignal reqStaVal[19](name="Valves",
      text="O-202: All control valves must show stable operation.")
    "Requirements to verify stability of control valves"
    annotation (Placement(transformation(extent={{540,460},{560,480}})));
  Modelica.Blocks.Sources.RealExpression Valy[19](y=y_value)
    annotation (Placement(transformation(extent={{500,464},{520,484}})));
equation


 for i in 1:nBui loop
   connect(weaDat.weaBus, bui[i].weaBus) annotation (Line(
       points={{-360,-20},{-350,-20},{-350,250},{0,250}},
       color={255,204,51},
       thickness=0.5));
   fracPL[i] = dis.con[i].pipDis.dp / dis.con[i].pipDis.length;

    y_value[i] = bui[i].ets.hex.val2.y_actual;
    y_value[i+5] = bui[i].ets.chi.valEva.y_actual;
    y_value[i+10] = bui[i].ets.chi.valCon.y_actual;
  end for;

  fracPL[6] = dis.pipEnd.dp / dis.pipEnd.length;
  fracPL[7] = conPla.pipDis.dp / conPla.pipDis.length;

  y_value[16] = bui[2].ets.dhw.domHotWatTan.divVal.y_actual;
  y_value[17] = bui[3].ets.dhw.domHotWatTan.divVal.y_actual;
  y_value[18] = bui[4].ets.dhw.domHotWatTan.divVal.y_actual;
  y_value[19] = bui[5].ets.dhw.domHotWatTan.divVal.y_actual;

  connect(dis.ports_bCon, bui.port_aSerAmb) annotation (Line(points={{-12,210},
          {-14,210},{-14,240},{-10,240}},color={0,127,255}));
  connect(dis.ports_aCon, bui.port_bSerAmb) annotation (Line(points={{12,210},{
          16,210},{16,240},{10,240}}, color={0,127,255}));
  connect(pipeGroundCouplingMulti[1:(nBui+1)].heatPorts[1], dis.heatPorts)
    annotation (Line(points={{1,175},{1,196},{0.4,196},{0.4,197.8}},
        color={127,0,0}));
  connect(conPla.port_bDis, TDisWatSup.port_a)
    annotation (Line(points={{-80,0},{-80,160}},color={0,127,255},
      thickness=0.5));
  connect(TDisWatRet.port_b, conPla.port_aDis)
    annotation (Line(points={{-80,-70},{-80,-20}}, color={0,127,255},
      thickness=0.5));
  connect(PPumETS.y, EPumETS.u)
    annotation (Line(points={{142,200},{238,200}}, color={0,0,127}));
  connect(pumDis.P, EPumDis.u)
    annotation (Line(points={{81,-71},{81,-80},{198,-80}}, color={0,0,127}));
  connect(EPumDis.y, EPum.u[1]) annotation (Line(points={{221,-80},{286,-80},{
          286,129.5},{298,129.5}},
                               color={0,0,127}));
  connect(PHeaPump.y, EHeaPum.u)
    annotation (Line(points={{202,180},{230,180},{230,160},{238,160}},
                                                   color={0,0,127}));
  connect(EHeaPum.y, ETot.u[1]) annotation (Line(points={{261,160},{350,160},{
          350,99.1429},{358,99.1429}},
                                   color={0,0,127}));
  connect(EPum.y, ETot.u[2]) annotation (Line(points={{322,130},{340,130},{340,
          99.4286},{358,99.4286}},
                               color={0,0,127}));
  connect(TDisWatRet.port_a, pumDis.port_b) annotation (Line(points={{-80,-90},
          {-80,-100},{90,-100},{90,-70}},color={0,127,255},
      thickness=0.5));
  connect(bui.PPum, PPumETS.u) annotation (Line(points={{12,243},{100,243},{100,
          200},{118,200}}, color={0,0,127}));
  connect(bui.PCoo, PHeaPump.u) annotation (Line(points={{12,247},{106,247},{
          106,180},{178,180}}, color={0,0,127}));
  connect(dis.port_aDisSup, TDisWatSup.port_b) annotation (Line(points={{-20,200},
          {-80,200},{-80,180}},color={0,127,255},
      thickness=0.5));
  connect(dis.port_bDisSup, pumDis.port_a)
    annotation (Line(points={{20,200},{90,200},{90,-50}}, color={0,127,255},
      thickness=0.5));
  connect(pumDis.port_a, bou.ports[1]) annotation (Line(points={{90,-50},{90,
          -40},{118,-40}},                     color={0,127,255},
      thickness=0.5));
  connect(conPla.port_bCon, cenPla.port_a) annotation (Line(points={{-90,-10},{-100,
          -10},{-100,-26},{-208,-26},{-208,0},{-180,0}}, color={0,127,255}));
  connect(conPla.port_aCon, cenPla.port_b) annotation (Line(points={{-90,-4},{-100,
          -4},{-100,0},{-160,0}}, color={0,127,255}));
  connect(looPumSpe.yDisPum, gai.u)
    annotation (Line(points={{-196,190},{-182,190}},color={0,0,127}));
  connect(gai.y, pumDis.m_flow_in) annotation (Line(points={{-158,190},{-146,
          190},{-146,-60},{78,-60}},
                              color={0,0,127}));
  connect(looPumSpe.yDisPum, cenPla.uDisPum) annotation (Line(points={{-196,190},
          {-190,190},{-190,6},{-182,6}},                        color={0,0,127}));
  connect(weaDat.weaBus, weaBus) annotation (Line(
      points={{-360,-20},{-300,-20}},
      color={255,204,51},
      thickness=0.5));
  connect(EPumDryCoo.y, EPumPla.u[1]) annotation (Line(points={{121,128},{226,
          128},{226,69.1429},{238,69.1429}},
                                       color={0,0,127}));
  connect(EPumHexGly.y, EPumPla.u[2]) annotation (Line(points={{161,110},{220,
          110},{220,69.4286},{238,69.4286}},
                                  color={0,0,127}));
  connect(EPumHeaPumGly.y, EPumPla.u[3]) annotation (Line(points={{201,90},{214,
          90},{214,69.7143},{238,69.7143}},
                                  color={0,0,127}));
  connect(EPumHeaPumWat.y, EPumPla.u[4]) annotation (Line(points={{161,10},{228,
          10},{228,70},{238,70}},            color={0,0,127}));
  connect(EPumCirPum.y, EPumPla.u[5]) annotation (Line(points={{201,-28},{226,
          -28},{226,70.2857},{238,70.2857}},
                                       color={0,0,127}));
  connect(EPumPla.y, EPum.u[2]) annotation (Line(points={{262,70},{280,70},{280,
          130.5},{298,130.5}},     color={0,0,127}));
  connect(EComPla.y, ETot.u[3]) annotation (Line(points={{261,30},{320,30},{320,
          99.7143},{358,99.7143}},
                                 color={0,0,127}));
  connect(TLooMaxMea.y, looPumSpe.TMixMax) annotation (Line(points={{-278,230},
          {-260,230},{-260,196},{-220,196}}, color={0,0,127}));
  connect(TLooMinMea.y, looPumSpe.TMixMin) annotation (Line(points={{-278,200},
          {-230,200},{-230,184},{-220,184}}, color={0,0,127}));
  connect(cenPla.PPumDryCoo, EPumDryCoo.u) annotation (Line(points={{-158,5},{-128,
          5},{-128,128},{98,128}}, color={0,0,127}));
  connect(cenPla.PPumHexGly, EPumHexGly.u) annotation (Line(points={{-158,3},{-124,
          3},{-124,110},{138,110}},
                                  color={0,0,127}));
  connect(cenPla.PPumHeaPumGly, EPumHeaPumGly.u) annotation (Line(points={{-158,-2},
          {-120,-2},{-120,90},{178,90}},     color={0,0,127}));
  connect(cenPla.PCom, EComPla.u) annotation (Line(points={{-158,-10},{-114,-10},
          {-114,30},{238,30}},color={0,0,127}));
  connect(cenPla.PPumHeaPumWat, EPumHeaPumWat.u) annotation (Line(points={{-158,
          -12},{-112,-12},{-112,10},{138,10}},
                                             color={0,0,127}));
  connect(cenPla.PPumCirPum, EPumCirPum.u) annotation (Line(points={{-158,-14},
          {-108,-14},{-108,-28},{178,-28}},
                                     color={0,0,127}));
//   connect(weaDat.weaBus, bui.weaBus) annotation (Line(
//       points={{-360,-20},{-340,-20},{-340,250},{0,250}},
//       color={255,204,51},
//       thickness=0.5));
  connect(TDisWatSup.T, sub.u1) annotation (Line(points={{-91,170},{-220,170},{
          -220,-170},{60,-170},{60,-214},{78,-214}},    color={0,0,127}));
  connect(TDisWatRet.T, sub.u2) annotation (Line(points={{-91,-80},{-100,-80},{-100,
          -180},{54,-180},{54,-226},{78,-226}},         color={0,0,127}));
  connect(sub.y, mul.u1) annotation (Line(points={{102,-220},{120,-220},{120,
          -164},{138,-164}}, color={0,0,127}));
  connect(gai.y, mul.u2) annotation (Line(points={{-158,190},{-146,190},{-146,
          -60},{68,-60},{68,-176},{138,-176}},
                       color={0,0,127}));
  connect(mul.y, plaHeaSup.u)
    annotation (Line(points={{162,-170},{178,-170}}, color={0,0,127}));
  connect(plaHeaSup.y, EPlaHea.u)
    annotation (Line(points={{202,-170},{260,-170},{260,-180},{338,-180}},
                                                     color={0,0,127}));
  connect(weaBus.TDryBul, cenPla.TDryBul) annotation (Line(
      points={{-299.9,-19.9},{-266,-19.9},{-266,4},{-182,4}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(dis.dH_flow,EEts. u) annotation (Line(points={{22,207},{84,207},{84,
          160},{98,160}},  color={0,0,127}));
  connect(EEts.y, ETotEts.u)
    annotation (Line(points={{121,160},{138,160}}, color={0,0,127}));
  connect(EPumBorFiePer.y, EPumPla.u[6]) annotation (Line(points={{161,70},{200,
          70},{200,70.5714},{238,70.5714}}, color={0,0,127}));
  connect(EPumBorFieCen.y, EPumPla.u[7]) annotation (Line(points={{121,50},{220,
          50},{220,70.8571},{238,70.8571}}, color={0,0,127}));
  connect(cenPla.PPumBorFiePer, EPumBorFiePer.u) annotation (Line(points={{-158,-4},
          {-118,-4},{-118,70},{138,70}},     color={0,0,127}));
  connect(cenPla.PPumBorFieCen, EPumBorFieCen.u) annotation (Line(points={{-158,-6},
          {-116,-6},{-116,50},{98,50}},     color={0,0,127}));
  connect(cenPla.QBorCen_flow, EBorCen.u) annotation (Line(points={{-158,-18},{
          -150,-18},{-150,-276},{-102,-276}},color={0,0,127}));
  connect(cenPla.TLooMaxMea, TLooMaxMea.y) annotation (Line(points={{-182,-8},{
          -260,-8},{-260,230},{-278,230}}, color={0,0,127}));
  connect(cenPla.TLooMinMea, TLooMinMea.y) annotation (Line(points={{-182,-12},
          {-230,-12},{-230,200},{-278,200}}, color={0,0,127}));
  connect(TDisWatSup.T, cenPla.TPlaOut) annotation (Line(points={{-91,170},{
          -220,170},{-220,8},{-182,8}}, color={0,0,127}));
  connect(pumDis.P, multiSum.u[1]) annotation (Line(points={{81,-71},{81,
          -153.25},{240,-153.25}},
                           color={0,0,127}));
  connect(cenPla.PPumCirPum, multiSum.u[2]) annotation (Line(points={{-158,-14},
          {-108,-14},{-108,-152.75},{240,-152.75}},   color={0,0,127}));
  connect(cenPla.PCom, multiSum.u[3]) annotation (Line(points={{-158,-10},{-114,
          -10},{-114,-152.25},{240,-152.25}},   color={0,0,127}));
  connect(cenPla.PPumHeaPumWat, multiSum.u[4]) annotation (Line(points={{-158,
          -12},{-112,-12},{-112,-151.75},{240,-151.75}},
                                                      color={0,0,127}));
  connect(cenPla.PPumBorFieCen, multiSum.u[5]) annotation (Line(points={{-158,-6},
          {-116,-6},{-116,-151.25},{240,-151.25}},   color={0,0,127}));
  connect(cenPla.PPumBorFiePer, multiSum.u[6]) annotation (Line(points={{-158,-4},
          {-118,-4},{-118,-150.75},{240,-150.75}},
                                             color={0,0,127}));
  connect(cenPla.PPumHeaPumGly, multiSum.u[7]) annotation (Line(points={{-158,-2},
          {-120,-2},{-120,-150.25},{240,-150.25}},   color={0,127,255}));
  connect(cenPla.PPumHexGly, multiSum.u[8]) annotation (Line(points={{-158,3},{
          -124,3},{-124,-149.75},{240,-149.75}},
                                              color={0,127,255}));
  connect(cenPla.PPumDryCoo, multiSum.u[9]) annotation (Line(points={{-158,5},{
          -128,5},{-128,-149.25},{240,-149.25}},
                                              color={0,0,127}));
  connect(cenPla.yEleRat, eleRat.u) annotation (Line(points={{-158,9},{-132,9},{
          -132,-120},{118,-120}}, color={0,0,127}));
  connect(PPumETS.y, multiSum.u[10]) annotation (Line(points={{142,200},{168,
          200},{168,-148.75},{240,-148.75}},
                                          color={0,0,127}));
  connect(PHeaPump.y, multiSum.u[11]) annotation (Line(points={{202,180},{230,
          180},{230,-148.25},{240,-148.25}},
                                          color={0,0,127}));
  connect(eleRat.y, mul1.u1) annotation (Line(points={{142,-120},{280,-120},{280,
          -124},{298,-124}}, color={0,0,127}));
  connect(multiSum.y, mul1.u2) annotation (Line(points={{261.7,-150},{280,-150},
          {280,-136},{298,-136}}, color={0,0,127}));
  connect(mul1.y, totEleCos.u)
    annotation (Line(points={{322,-130},{338,-130}}, color={0,0,127}));
  connect(cenPla.QBorPer_flow, EBorPer.u) annotation (Line(points={{-158,-16},{
          -124,-16},{-124,-240},{-102,-240}},color={0,0,127}));
  connect(EBor.y, dTSoi.E)
    annotation (Line(points={{242,-270},{258,-270}}, color={0,0,127}));
  connect(EBorPer.y, dTSoiPer.E)
    annotation (Line(points={{-79,-240},{190,-240},{190,-210},{258,-210}},
                                                     color={0,0,127}));
  connect(EBorCen.y, dTSoiCen.E)
    annotation (Line(points={{-79,-276},{200,-276},{200,-240},{258,-240}},
                                                     color={0,0,127}));
  connect(EBorPer.y, EBor.u1) annotation (Line(points={{-79,-240},{190,-240},{
          190,-264},{218,-264}},
                             color={0,0,127}));
  connect(EBor.u2, EBorCen.y) annotation (Line(points={{218,-276},{-79,-276}},
                             color={0,0,127}));
  connect(dTSoi.dTSoi, priBorFie.x[1]) annotation (Line(points={{281,-264},{290,
          -264},{290,-270.667},{298,-270.667}}, color={0,0,127}));
  connect(dTSoiCen.dTSoi, priBorFie.x[2]) annotation (Line(points={{281,-234},{
          290,-234},{290,-270},{298,-270}}, color={0,0,127}));
  connect(dTSoiPer.dTSoi, priBorFie.x[3]) annotation (Line(points={{281,-204},{
          290,-204},{290,-269.333},{298,-269.333}}, color={0,0,127}));
  connect(dis.TOut, TLooMea.u) annotation (Line(points={{22,194},{80,194},{80,
          234},{118,234}}, color={0,0,127}));
  connect(TLooMea.y, TLooMaxMea.u[1:4]) annotation (Line(points={{142,234},{148,
          234},{148,256},{-320,256},{-320,230.75},{-302,230.75}}, color={0,0,
          127}));
  connect(TLooMea.y, TLooMinMea.u[1:4]) annotation (Line(points={{142,234},{148,
          234},{148,256},{-320,256},{-320,200.75},{-302,200.75}}, color={0,0,
          127}));
  connect(TLooMaxMea.y, conVio.u[1]) annotation (Line(points={{-278,230},{-250,
          230},{-250,229.5},{-222,229.5}}, color={0,0,127}));
  connect(TLooMinMea.y, conVio.u[2]) annotation (Line(points={{-278,200},{-230,
          200},{-230,230.5},{-222,230.5}}, color={0,0,127}));
  connect(dis.dH_flow, QEtsHex_flow.u) annotation (Line(points={{22,207},{30,
          207},{30,226},{38,226}}, color={0,0,127}));
  connect(cenPla.PFanDryCoo, EFanDryCoo.u) annotation (Line(points={{-158,7},{
          -136,7},{-136,150},{38,150}}, color={0,0,127}));
  connect(cenPla.PFanDryCoo, multiSum.u[12]) annotation (Line(points={{-158,7},
          {-136,7},{-136,-147.75},{240,-147.75}},   color={0,0,127}));
  connect(EFanDryCoo.y, ETot.u[4]) annotation (Line(points={{61,150},{80,150},{80,
          144},{292,144},{292,100},{358,100}},          color={0,0,127}));
  connect(PEleNonHva.y, EEleNonHvaETS.u)
    annotation (Line(points={{202,240},{238,240}}, color={0,0,127}));
  connect(bui.PEleNonHva, PEleNonHva.u) annotation (Line(points={{12,238},{20,
          238},{20,252},{160,252},{160,240},{178,240}}, color={0,0,127}));
  connect(EPumETS.y, ETot.u[5]) annotation (Line(points={{261,200},{350,200},{
          350,100.286},{358,100.286}},
                                   color={0,0,127}));
  connect(EEleNonHvaETS.y, ETot.u[6]) annotation (Line(points={{261,240},{350,
          240},{350,100},{358,100},{358,100.571}},
                                              color={0,0,127}));
  connect(PEleNonHva.y, multiSum.u[13]) annotation (Line(points={{202,240},{228,
          240},{228,-148},{240,-148},{240,-147.25}},  color={0,0,127}));
  connect(PFanBuiSum.y, EFanBui.u)
    annotation (Line(points={{202,280},{238,280}}, color={0,0,127}));
  connect(EFanBui.y, ETot.u[7]) annotation (Line(points={{261,280},{348,280},{
          348,116},{352,116},{352,100.857},{358,100.857}},
                                                       color={0,0,127}));
  connect(PFanBui.y, PFanBuiSum.u)
    annotation (Line(points={{141,280},{178,280}}, color={0,0,127}));
  connect(PFanBuiSum.y, multiSum.u[14]) annotation (Line(points={{202,280},{224,
          280},{224,-148},{240,-148},{240,-146.75}}, color={0,0,127}));
  connect(senTemDhwSup.y, reqTDhwSup.u) annotation (Line(points={{521,350},{530,
          350},{530,354},{539,354}}, color={0,0,127}));
  connect(valEvaOpen.y, reqTHeaPumEvaLvg.active) annotation (Line(points={{522,120},
          {530,120},{530,146},{538,146}}, color={255,0,255}));
  connect(valConOpen.y, reqTHeaPumConLvg.active) annotation (Line(points={{522,40},
          {532,40},{532,66},{538,66}}, color={255,0,255}));
  connect(valIsoConPos.y,valConOpen. u)
    annotation (Line(points={{481,40},{498,40}},     color={0,0,127}));
  connect(valIsoEvaPos.y,valEvaOpen. u)
    annotation (Line(points={{481,120},{498,120}}, color={0,0,127}));
  connect(THeaPumEvaLvg.y, reqTHeaPumEvaLvg.u_max) annotation (Line(points={{521,
          170},{530,170},{530,156},{539,156}}, color={0,0,127}));
  connect(TmaxHeaPumConLvg.y, reqTHeaPumConLvg.u_max) annotation (Line(points={{
          521,90},{532,90},{532,76},{539,76}}, color={0,0,127}));
  connect(THeaPumCon.y, reqTHeaPumConLvg.u_min) annotation (Line(points={{521,70},
          {532,70},{532,72},{539,72}}, color={0,0,127}));
  connect(THexWatEnt.y,reqTWatSer. u) annotation (Line(points={{521,-270},{530,-270},
          {530,-266},{539,-266}}, color={0,0,127}));
  connect(TDisWatSup.T, reqTPlaMix.u) annotation (Line(points={{-91,170},{-216,
          170},{-216,-168},{64,-168},{64,-466},{539,-466}},
                             color={0,0,127}));
  connect(TTanTop.y, reqTDhwTan.u) annotation (Line(points={{521,300},{530,300},
          {530,294},{539,294}}, color={0,0,127}));
  connect(DhwTanCha.y, reqTDhwTan.active) annotation (Line(points={{521,280},{532,
          280},{532,286},{538,286}}, color={255,0,255}));
  connect(TminHeaPumEva.y, reqTHeaPumEvaLvg.u_min) annotation (Line(points={{521,
          150},{530,150},{530,152},{539,152}}, color={0,0,127}));
  connect(HeaPumOn.y,reqHeaPumOn. u)
    annotation (Line(points={{481,430},{538,430}}, color={255,0,255}));
  connect(HeaPumOff.y,reqHeaPumOff. u)
    annotation (Line(points={{521,390},{538,390}}, color={255,0,255}));
  connect(HeaPumOn.y,HeaPumOff. u) annotation (Line(points={{481,430},{490,430},
          {490,390},{498,390}}, color={255,0,255}));
  connect(fracPLMax.y,reqPDis. u_max) annotation (Line(points={{521,-310},{530,-310},
          {530,-324},{539,-324}}, color={0,0,127}));
  connect(PDis.y,reqPDis. u_min) annotation (Line(points={{521,-350},{530,-350},
          {530,-328},{539,-328}}, color={0,0,127}));
  connect(THeaDiff.y, reqTHea.u) annotation (Line(points={{521,-380},{530,-380},
          {530,-386},{539,-386}}, color={0,0,127}));
  connect(TCooDiff.y, reqTCoo.u) annotation (Line(points={{521,-430},{530,-430},
          {530,-436},{539,-436}}, color={0,0,127}));
  connect(BooOn.y, reqTHea.active) annotation (Line(points={{421,-410},{448,-410},
          {448,-394},{538,-394}}, color={255,0,255}));
  connect(BooOn.y, reqTCoo.active) annotation (Line(points={{421,-410},{448,-410},
          {448,-444},{538,-444}}, color={255,0,255}));
  connect(TCooSup.y, TCooDiff.u1)
    annotation (Line(points={{481,-424},{498,-424}}, color={0,0,127}));
  connect(TCooSupSet.y, TCooDiff.u2)
    annotation (Line(points={{481,-436},{498,-436}}, color={0,0,127}));
  connect(THeaSup.y, THeaDiff.u1)
    annotation (Line(points={{481,-374},{498,-374}}, color={0,0,127}));
  connect(THeaSupSet.y, THeaDiff.u2)
    annotation (Line(points={{481,-386},{498,-386}}, color={0,0,127}));
  connect(TRooHeaSet.y, TRooHeaDif.u1) annotation (Line(points={{441,-20},{448,-20},
          {448,-34},{458,-34}}, color={0,0,127}));
  connect(TRooHea.y, TRooHeaDif.u2) annotation (Line(points={{441,-60},{448,-60},
          {448,-46},{458,-46}}, color={0,0,127}));
  connect(TRooHeaDif.y, TRooHeaAvg60min.u) annotation (Line(points={{481,-40},{490,
          -40},{490,-30},{498,-30}}, color={0,0,127}));
  connect(TRooHeaDif.y, TRooHeaAvgYea.u) annotation (Line(points={{481,-40},{490,
          -40},{490,-90},{498,-90}}, color={0,0,127}));
  connect(THexSecLvg.y, reqTHexEtsSecLvg.u) annotation (Line(points={{521,250},{
          532,250},{532,254},{539,254}}, color={0,0,127}));
  connect(THexPriLvg.y, reqTHexEtsPriLvg.u) annotation (Line(points={{521,210},{
          530,210},{530,214},{539,214}}, color={0,0,127}));
  connect(TRooHeaAvg60min.y, reqTRooHea.u_min) annotation (Line(points={{522,-30},
          {530,-30},{530,-28},{539,-28}}, color={0,0,127}));
  connect(TRooHeaDifMax.y, reqTRooHea.u_max) annotation (Line(points={{521,0},{530,
          0},{530,-24},{539,-24}}, color={0,0,127}));
  connect(TRooHeaDifYea.y, reqTRooHeaAvg.u_max) annotation (Line(points={{521,-60},
          {530,-60},{530,-72},{539,-72}}, color={0,0,127}));
  connect(TRooHeaAvgYea.y, reqTRooHeaAvg.u_min) annotation (Line(points={{521,-90},
          {530,-90},{530,-76},{539,-76}}, color={0,0,127}));
  connect(last_value.y, reqTRooHeaAvg.active) annotation (Line(points={{441,-110},
          {534,-110},{534,-82},{538,-82}}, color={255,0,255}));
  connect(TRooCooSet.y, TRooCooDif.u1) annotation (Line(points={{441,-160},{450,
          -160},{450,-174},{458,-174}}, color={0,0,127}));
  connect(TRooCoo.y, TRooCooDif.u2) annotation (Line(points={{441,-200},{450,-200},
          {450,-186},{458,-186}}, color={0,0,127}));
  connect(TRooCooDif.y, TRooCooAvg60min.u) annotation (Line(points={{481,-180},{
          490,-180},{490,-170},{498,-170}}, color={0,0,127}));
  connect(TRooCooDif.y, TRooCooAvgYea.u) annotation (Line(points={{481,-180},{490,
          -180},{490,-230},{498,-230}}, color={0,0,127}));
  connect(TRooCooAvg60min.y, reqTRooCoo.u_min) annotation (Line(points={{522,-170},
          {530,-170},{530,-168},{539,-168}}, color={0,0,127}));
  connect(TRooCooDifMax.y, reqTRooCoo.u_max) annotation (Line(points={{521,-140},
          {530,-140},{530,-164},{539,-164}}, color={0,0,127}));
  connect(TRooCooDifYea.y, reqTRooCooAvg.u_max) annotation (Line(points={{521,-200},
          {530,-200},{530,-212},{539,-212}}, color={0,0,127}));
  connect(TRooCooAvgYea.y, reqTRooCooAvg.u_min) annotation (Line(points={{521,-230},
          {530,-230},{530,-216},{539,-216}}, color={0,0,127}));
  connect(last_value.y, reqTRooCooAvg.active) annotation (Line(points={{441,-110},
          {534,-110},{534,-222},{538,-222}}, color={255,0,255}));
  connect(BooOn.y, reqTRooCoo.active) annotation (Line(points={{421,-410},{448,-410},
          {448,-490},{580,-490},{580,-190},{530,-190},{530,-174},{538,-174}},
        color={255,0,255}));
  connect(BooOn.y, reqTRooHea.active) annotation (Line(points={{421,-410},{448,-410},
          {448,-490},{580,-490},{580,-50},{530,-50},{530,-34},{538,-34}}, color
        ={255,0,255}));
  connect(Valy.y,reqStaVal. u)
    annotation (Line(points={{521,474},{539,474}}, color={0,0,127}));
  annotation (
  Diagram(
  coordinateSystem(preserveAspectRatio=false, extent={{-400,-300},{400,300}})),
    __Dymola_Commands(
  file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Networks/Validation/DetailedPlantFiveHubs.mos"
  "Simulate and plot"),
  experiment(
      StopTime=1728000,
      Interval=3600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    Documentation(info="<html>
<p>
Adapted from
<a href=\"modelica://Buildings.DHC.Examples.Combined.BaseClasses.PartialSeries\">
Buildings.DHC.Examples.Combined.BaseClasses.PartialSeries</a>.
</p>
<ul>
<li>
This model has a configuration of one single central plant in the loop
instead of two.
</li>
<li>
The plant is replaced with an idealized component.
The plant pump control is replaced with a constant block.
Parameters in the record class related to the plant are also removed.
</li>
<li>
The two pipe segments in to and out of the connection component are removed.
</li>
<li>
The building array is replaced with the new component from the JBA library.
</li>
<li>
The main pump control block is copied here as is.
Note that, the same as in the original model, this control block only
regulates the outgoing temperature from each building connection,
and <code>use_temperatureShift==false</code>.
This means only the <code>TMix_in[]</code> input connectors are useful.
</li>
<li>
The pressurization point of the loop is moved to upstream the main pump.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end DetailedPlantFiveHubs_requirements;
