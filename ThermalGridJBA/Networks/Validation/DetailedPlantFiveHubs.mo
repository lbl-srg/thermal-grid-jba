within ThermalGridJBA.Networks.Validation;
model DetailedPlantFiveHubs
  "District network with five hubs and the detailed plant"
  extends Modelica.Icons.Example;
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
  inner replaceable parameter ThermalGridJBA.Data.Districts.FiveHubs datDis(
    mCon_flow_nominal=bui.ets.hex.m1_flow_nominal)
    "Parameters for the district network"
    annotation (Placement(transformation(extent={{-380,180},{-360,200}})));

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
    final filNam = datDis.filNamInd,
    bui(each final facMul=1),
    redeclare each final package MediumBui = Medium,
    redeclare each final package MediumSer = Medium,
    each final allowFlowReversalBui=allowFlowReversalBui,
    each final allowFlowReversalSer=allowFlowReversalSer,
    each final TDisWatMin=datDis.TLooMin,
    each final TDisWatMax=datDis.TLooMax) "Building and ETS"
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
    nin=3,
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
    nin=4,
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
  Modelica.Blocks.Math.MultiSum multiSum(nu=12)
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
    u(each final unit="K", displayUnit="degC"),
    y(each final unit="K", displayUnit="degC"))
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
equation
 for i in 1:nBui loop
   connect(weaDat.weaBus, bui[i].weaBus) annotation (Line(
       points={{-360,-20},{-350,-20},{-350,250},{0,250}},
       color={255,204,51},
       thickness=0.5));
 end for;
  connect(dis.ports_bCon, bui.port_aSerAmb) annotation (Line(points={{-12,210},
          {-14,210},{-14,240},{-10,240}},color={0,127,255}));
  connect(dis.ports_aCon, bui.port_bSerAmb) annotation (Line(points={{12,210},{
          16,210},{16,240},{10,240}}, color={0,127,255}));
  connect(pipeGroundCouplingMulti[1:(nBui+1)].heatPorts[1], dis.heatPorts)
    annotation (Line(points={{1,175},{1,156},{0.4,156},{0.4,197.8}},
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
  connect(EPumETS.y, EPum.u[1]) annotation (Line(points={{261,200},{286,200},{
          286,129.333},{298,129.333}},
                                   color={0,0,127}));
  connect(EPumDis.y, EPum.u[2]) annotation (Line(points={{221,-80},{286,-80},{286,
          130},{298,130}},     color={0,0,127}));
  connect(PHeaPump.y, EHeaPum.u)
    annotation (Line(points={{202,180},{230,180},{230,160},{238,160}},
                                                   color={0,0,127}));
  connect(EHeaPum.y, ETot.u[1]) annotation (Line(points={{261,160},{350,160},{
          350,99.25},{358,99.25}}, color={0,0,127}));
  connect(EPum.y, ETot.u[2]) annotation (Line(points={{322,130},{340,130},{340,
          99.75},{358,99.75}}, color={0,0,127}));
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
  connect(EPumPla.y, EPum.u[3]) annotation (Line(points={{262,70},{280,70},{280,
          130.667},{298,130.667}}, color={0,0,127}));
  connect(EComPla.y, ETot.u[3]) annotation (Line(points={{261,30},{320,30},{320,
          100.25},{358,100.25}}, color={0,0,127}));
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
  connect(dis.dH_flow, EEts.u) annotation (Line(points={{22,207},{84,207},{84,
          160},{98,160}},  color={0,0,127}));
  connect(EEts.y, ETotEts.u)
    annotation (Line(points={{121,160},{138,160}}, color={0,0,127}));
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
  connect(cenPla.QBorPer_flow, EBorPer.u) annotation (Line(points={{-158,-16},{
          -148,-16},{-148,-240},{-102,-240}},color={0,0,127}));
  connect(cenPla.QBorCen_flow, EBorCen.u) annotation (Line(points={{-158,-18},{
          -150,-18},{-150,-276},{-102,-276}},color={0,0,127}));
  connect(cenPla.TLooMaxMea, TLooMaxMea.y) annotation (Line(points={{-182,-8},{
          -260,-8},{-260,230},{-278,230}}, color={0,0,127}));
  connect(cenPla.TLooMinMea, TLooMinMea.y) annotation (Line(points={{-182,-12},
          {-230,-12},{-230,200},{-278,200}}, color={0,0,127}));
  connect(TDisWatSup.T, cenPla.TPlaOut) annotation (Line(points={{-91,170},{
          -220,170},{-220,8},{-182,8}}, color={0,0,127}));
  connect(pumDis.P, multiSum.u[1]) annotation (Line(points={{81,-71},{81,
          -153.208},{240,-153.208}},
                           color={0,0,127}));
  connect(cenPla.PPumCirPum, multiSum.u[2]) annotation (Line(points={{-158,-14},
          {-108,-14},{-108,-152.625},{240,-152.625}}, color={0,0,127}));
  connect(cenPla.PCom, multiSum.u[3]) annotation (Line(points={{-158,-10},{-114,
          -10},{-114,-152.042},{240,-152.042}}, color={0,0,127}));
  connect(cenPla.PPumHeaPumWat, multiSum.u[4]) annotation (Line(points={{-158,
          -12},{-112,-12},{-112,-151.458},{240,-151.458}},
                                                      color={0,0,127}));
  connect(cenPla.PPumBorFieCen, multiSum.u[5]) annotation (Line(points={{-158,-6},
          {-116,-6},{-116,-150.875},{240,-150.875}}, color={0,0,127}));
  connect(cenPla.PPumBorFiePer, multiSum.u[6]) annotation (Line(points={{-158,-4},
          {-118,-4},{-118,-150.292},{240,-150.292}},
                                             color={0,0,127}));
  connect(cenPla.PPumHeaPumGly, multiSum.u[7]) annotation (Line(points={{-158,-2},
          {-120,-2},{-120,-149.708},{240,-149.708}}, color={0,127,255}));
  connect(cenPla.PPumHexGly, multiSum.u[8]) annotation (Line(points={{-158,3},{
          -124,3},{-124,-149.125},{240,-149.125}},
                                              color={0,127,255}));
  connect(cenPla.PPumDryCoo, multiSum.u[9]) annotation (Line(points={{-158,5},{
          -128,5},{-128,-148.542},{240,-148.542}},
                                              color={0,0,127}));
  connect(cenPla.yEleRat, eleRat.u) annotation (Line(points={{-158,9},{-132,9},{
          -132,-120},{118,-120}}, color={0,0,127}));
  connect(PPumETS.y, multiSum.u[10]) annotation (Line(points={{142,200},{168,
          200},{168,-147.958},{240,-147.958}},
                                          color={0,0,127}));
  connect(PHeaPump.y, multiSum.u[11]) annotation (Line(points={{202,180},{230,
          180},{230,-147.375},{240,-147.375}},
                                          color={0,0,127}));
  connect(eleRat.y, mul1.u1) annotation (Line(points={{142,-120},{280,-120},{280,
          -124},{298,-124}}, color={0,0,127}));
  connect(multiSum.y, mul1.u2) annotation (Line(points={{261.7,-150},{280,-150},
          {280,-136},{298,-136}}, color={0,0,127}));
  connect(mul1.y, totEleCos.u)
    annotation (Line(points={{322,-130},{338,-130}}, color={0,0,127}));
  connect(cenPla.PPumBorFiePer, EPumBorFiePer.u) annotation (Line(points={{-158,-4},
          {-118,-4},{-118,70},{138,70}},     color={0,0,127}));
  connect(cenPla.PPumBorFieCen, EPumBorFieCen.u) annotation (Line(points={{-158,-6},
          {-116,-6},{-116,50},{98,50}},     color={0,0,127}));
  connect(cenPla.QBorPer_flow, EBorPer.u) annotation (Line(points={{-158,-16},{
          -124,-16},{-124,-240},{-102,-240}},color={0,0,127}));
  connect(cenPla.QBorCen_flow, EBorCen.u) annotation (Line(points={{-158,-18},{
          -126,-18},{-126,-276},{-102,-276}},color={0,0,127}));
  connect(cenPla.TLooMaxMea, TLooMaxMea.y) annotation (Line(points={{-182,-8},{
          -260,-8},{-260,230},{-278,230}}, color={0,0,127}));
  connect(cenPla.TLooMinMea, TLooMinMea.y) annotation (Line(points={{-182,-12},
          {-230,-12},{-230,200},{-278,200}}, color={0,0,127}));
  connect(TDisWatSup.T, cenPla.TPlaOut) annotation (Line(points={{-91,170},{
          -220,170},{-220,8},{-182,8}}, color={0,0,127}));
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
          {-136,7},{-136,-146.792},{240,-146.792}}, color={0,0,127}));
  connect(EFanDryCoo.y, ETot.u[4]) annotation (Line(points={{61,150},{80,150},{
          80,144},{292,144},{292,100.75},{358,100.75}}, color={0,0,127}));
  annotation (
  Diagram(
  coordinateSystem(preserveAspectRatio=false, extent={{-400,-300},{400,260}})),
    __Dymola_Commands(
  file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Networks/Validation/DetailedPlantFiveHubs.mos"
  "Simulate and plot"),
  experiment(
      StopTime=864000,
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
end DetailedPlantFiveHubs;
