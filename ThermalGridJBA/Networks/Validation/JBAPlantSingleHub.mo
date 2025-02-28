within ThermalGridJBA.Networks.Validation;
model JBAPlantSingleHub
  "District network with the JBA plant and a single combined hub"
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Medium model";

  parameter Modelica.Units.SI.Length diameter=sqrt(4*datDis.mPipDis_flow_nominal/1000/1.5/Modelica.Constants.pi)
    "Pipe diameter (without insulation)";
  parameter Modelica.Units.SI.Radius rPip=diameter/2 "Pipe external radius";
  parameter Modelica.Units.SI.Radius thiGroLay=0.5
    "Dynamic ground layer thickness";
  parameter Real dpDis_length_nominal(unit="Pa/m")=250
    "Pressure drop per pipe length at nominal flow rate - Distribution line";
  parameter Real dpCon_length_nominal(unit="Pa/m")=250
    "Pressure drop per pipe length at nominal flow rate - Connection line";
  parameter Boolean allowFlowReversalSer = true
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
  parameter Integer nMod=1 "Total number of central plant modules"
    annotation (Dialog(tab="Central plant"));
  parameter Real samplePeriod(unit="s")=7200
    "Sample period of district loop pump speed"
    annotation (Dialog(tab="Central plant"));
  parameter Real mPlaWat_flow_nominal(unit="kg/s")=sum(datDis.mCon_flow_nominal)
    /nMod
    "Nominal water mass flow rate to each module"
    annotation (Dialog(tab="Central plant"));
  parameter Real dpPlaValve_nominal(unit="Pa")=6000
    "Nominal pressure drop of fully open 2-way valve"
    annotation (Dialog(tab="Central plant"));
  // Central plant: heat exchangers
  parameter Real dpPlaHex_nominal(unit="Pa")=10000
    "Pressure difference across heat exchanger"
    annotation (Dialog(tab="Central plant", group="Heat exchanger"));
  parameter Real mPlaHexGly_flow_nominal(unit="kg/s")=mPlaWat_flow_nominal*0.3
    "Nominal glycol mass flow rate for heat exchanger"
    annotation (Dialog(tab="Central plant", group="Heat exchanger"));
  // Central plant: dry coolers
  parameter Real dpDryCoo_nominal(unit="Pa")=10000
                     "Nominal pressure drop of dry cooler"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  parameter Real mDryCoo_flow_nominal(unit="kg/s")=mPlaHexGly_flow_nominal +
    mHpGly_flow_nominal
    "Nominal glycol mass flow rate for dry cooler"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  parameter Real TAppSet(unit="K")=2
    "Dry cooler approch setpoint"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  parameter Real TApp(unit="K")=4
    "Approach temperature for checking if the dry cooler should be enabled"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  parameter Real minFanSpe(unit="1")=0.1
    "Minimum dry cooler fan speed"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  // Central plant: heat pumps
  parameter Real mPlaHeaPumWat_flow_min(unit="kg/s")=0.05*mPlaWat_flow_nominal
    "Heat pump minimum water mass flow rate"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real mHpGly_flow_nominal(unit="kg/s")=mPlaWat_flow_nominal*0.3
    "Nominal glycol mass flow rate for heat pump"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real QPlaHeaPumHea_flow_nominal(unit="W")=0.5*mPlaWat_flow_nominal*
    4186*TApp
    "Nominal heating capacity"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaConHea_nominal(unit="K")=datDis.TLooMin
    "Nominal temperature of the heated fluid in heating mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaEvaHea_nominal(unit="K")=datDis.TLooMin + TApp
    "Nominal temperature of the cooled fluid in heating mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real QPlaHeaPumCoo_flow_nominal(unit="W")=-0.6*
    QPlaHeaPumHea_flow_nominal
    "Nominal cooling capacity"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaConCoo_nominal(unit="K")=datDis.TLooMax
    "Nominal temperature of the cooled fluid in cooling mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaEvaCoo_nominal(unit="K")=datDis.TLooMax - TApp
    "Nominal temperature of the heated fluid in cooling mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaConInMin(unit="K")=datDis.TLooMax - TApp - TAppSet
    "Minimum condenser inlet temperature"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaEvaInMax(unit="K")=datDis.TLooMin + TApp + TAppSet
    "Maximum evaporator inlet temperature"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real minPlaComSpe(unit="1")=0.2
    "Minimum heat pump compressor speed"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TCooSet(unit="K")=datDis.TLooMin
    "Heat pump tracking temperature setpoint in cooling mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real THeaSet(unit="K")=datDis.TLooMin
    "Heat pump tracking temperature setpoint in heating mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real offTim(unit="s")=12*3600
    "Heat pump off time"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  // District pump
  parameter Real TUpp(unit="K")=datDis.TLooMax
    "Upper bound temperature"
    annotation (Dialog(tab="District pump"));
  parameter Real TLow(unit="K")=datDis.TLooMin
    "Lower bound temperature"
    annotation (Dialog(tab="District pump"));
  parameter Real dTSlo(unit="K")=2
    "Temperature deadband for changing pump speed"
    annotation (Dialog(tab="District pump"));
  parameter Real yDisPumMin(unit="1")=0.1
    "District loop pump minimum speed"
    annotation (Dialog(tab="District pump"));

  final parameter Integer nBui=datDis.nBui
    "Number of buildings connected to DHC system"
    annotation (Evaluate=true);
  inner replaceable parameter ThermalGridJBA.Data.Districts.SingleHub datDis(
    mCon_flow_nominal=bui.ets.hex.m1_flow_nominal)
    "Parameters for the district network"
    annotation (Placement(transformation(extent={{-360,220},{-340,240}})));

  Buildings.Fluid.FixedResistances.BuriedPipes.PipeGroundCoupling pipeGroundCouplingMulti[nBui + 1](
    lPip=datDis.lDis,
    each rPip=rPip,
    each thiGroLay=thiGroLay,
    each nSeg=1,
    redeclare parameter Buildings.HeatTransfer.Data.Soil.Generic soiDat(
      each k=2.3,
      each c=1000,
      each d=2600))
    annotation (Placement(transformation(extent={{-10,160},{12,140}})));

  Buildings.DHC.Networks.Distribution1PipePlugFlow_v dis(
    nCon=nBui,
    allowFlowReversal=allowFlowReversalSer,
    redeclare package Medium = Medium,
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
    final allowFlowReversal=allowFlowReversalSer,
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
        origin={150,-60})));
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
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatSup(redeclare final package
      Medium = Medium, final m_flow_nominal=datDis.mPumDis_flow_nominal)
    "District water supply temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,150})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatRet(redeclare final package
      Medium = Medium, final m_flow_nominal=datDis.mPumDis_flow_nominal)
    "District water return temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-80})));
  ThermalGridJBA.Hubs.ConnectedETS
    bui[nBui](
    final filNam = datDis.filNam,
    bui(each final facMul=1),
    redeclare each final package MediumBui = Medium,
    redeclare each final package MediumSer = Medium,
    each final allowFlowReversalBui=allowFlowReversalBui,
    each final allowFlowReversalSer=allowFlowReversalSer,
    each final TDisWatMin=datDis.TLooMin,
    each final TDisWatMax=datDis.TLooMax) "Building and ETS"
    annotation (Placement(transformation(extent={{-10,230},{10,250}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PPumETS(nin=nBui)
    "ETS pump power"
    annotation (Placement(transformation(extent={{180,230},{200,250}})));
  Modelica.Blocks.Continuous.Integrator EPumETS(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "ETS pump electric energy"
    annotation (Placement(transformation(extent={{240,230},{260,250}})));
  Modelica.Blocks.Continuous.Integrator EPumDis(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "Distribution pump electric energy"
    annotation (Placement(transformation(extent={{220,-90},{240,-70}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum EPum(nin=3)
    "Total pump electric energy"
    annotation (Placement(transformation(extent={{300,150},{320,170}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PHeaPump(nin=nBui)
    "Heat pump power"
    annotation (Placement(transformation(extent={{180,190},{200,210}})));
  Modelica.Blocks.Continuous.Integrator EHeaPum(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "Heat pump electric energy"
    annotation (Placement(transformation(extent={{240,190},{260,210}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum ETot(nin=4) "Total electric energy"
    annotation (Placement(transformation(extent={{362,90},{382,110}})));
  Buildings.DHC.Loads.BaseClasses.ConstraintViolation conVio(
    final uMin(final unit="K", displayUnit="degC")=datDis.TLooMin,
    final uMax(final unit="K", displayUnit="degC")=datDis.TLooMax,
    final nu=2,
    u(each final unit="K", each displayUnit="degC"))
    "Check if loop temperatures are within given range"
    annotation (Placement(transformation(extent={{320,-130},{340,-110}})));
  BaseClasses.CentralPlant cenPla(
    final nMod=nMod,
    final TLooMin=datDis.TLooMin,
    final TLooMax=datDis.TLooMax,
    final mWat_flow_nominal=mPlaWat_flow_nominal,
    final dpValve_nominal=dpPlaValve_nominal,
    final dpHex_nominal=dpPlaHex_nominal,
    final mHexGly_flow_nominal=mPlaHexGly_flow_nominal,
    final dpDryCoo_nominal=dpDryCoo_nominal,
    final mDryCoo_flow_nominal=mDryCoo_flow_nominal,
    final mWat_flow_min=mPlaHeaPumWat_flow_min,
    final mHpGly_flow_nominal=mHpGly_flow_nominal,
    final QHeaPumHea_flow_nominal=QPlaHeaPumHea_flow_nominal,
    final TConHea_nominal=TPlaConHea_nominal,
    final TEvaHea_nominal=TPlaEvaHea_nominal,
    final QHeaPumCoo_flow_nominal=QPlaHeaPumCoo_flow_nominal,
    final TConCoo_nominal=TPlaConCoo_nominal,
    final TEvaCoo_nominal=TPlaEvaCoo_nominal,
    final samplePeriod=samplePeriod,
    final TAppSet=TAppSet,
    final TApp=TApp,
    final minFanSpe=minFanSpe,
    final TCooSet=TCooSet,
    final THeaSet=THeaSet,
    final TConInMin=TPlaConInMin,
    final TEvaInMax=TPlaEvaInMax,
    final offTim=offTim,
    final minComSpe=minPlaComSpe)
     "Central plant"
    annotation (Placement(transformation(extent={{-160,-10},{-140,10}})));
  Controls.DistrictLoopPump looPumSpe(
    final TUpp=TUpp,
    final TLow=TLow,
    final dTSlo=dTSlo,
    final yMin=yDisPumMin) "District loop pump control"
    annotation (Placement(transformation(extent={{-60,-160},{-40,-140}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(final k=datDis.mPumDis_flow_nominal)
    "District pump speed"
    annotation (Placement(transformation(extent={{0,-160},{20,-140}})));
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        ModelicaServices.ExternalReferences.loadResource("modelica://ThermalGridJBA/Resources/Data/BoundaryConditions/USA_MD_Andrews.AFB.745940_TMY3.mos"),
      computeWetBulbTemperature=true)  "Weather data reader"
    annotation (Placement(transformation(extent={{-380,-30},{-360,-10}})));
  Buildings.BoundaryConditions.WeatherData.Bus weaBus annotation (Placement(
        transformation(extent={{-320,-40},{-280,0}}), iconTransformation(extent
          ={{-364,-80},{-344,-60}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PFanDryCoo(nin=nMod)
    "Dry cooler fan power"
    annotation (Placement(transformation(extent={{-60,110},{-40,130}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PPumDryCoo(nin=nMod)
    "Dry cooler pump power"
    annotation (Placement(transformation(extent={{-20,90},{0,110}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PPumHeaPumGly(nin=nMod)
    "Heat pump glycol side pump power"
    annotation (Placement(transformation(extent={{60,50},{80,70}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PPumHexGly(nin=nMod)
    "Heat exchanger glycol side pump power"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PPumCirPum(nin=nMod)
    "Circulation pump power"
    annotation (Placement(transformation(extent={{140,-40},{160,-20}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PPumHeaPumWat(nin=nMod)
    "Heat pump water side pump power"
    annotation (Placement(transformation(extent={{140,0},{160,20}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PCom(nin=nMod)
    "Heat pump compressor power"
    annotation (Placement(transformation(extent={{100,20},{120,40}})));
  Modelica.Blocks.Continuous.Integrator EFunDryCoo(initType=Modelica.Blocks.Types.Init.InitialState)
    "Dry cooler fan electric energy"
    annotation (Placement(transformation(extent={{240,110},{260,130}})));
  Modelica.Blocks.Continuous.Integrator EPumDryCoo(initType=Modelica.Blocks.Types.Init.InitialState)
    "Dry cooler pump electric energy"
    annotation (Placement(transformation(extent={{100,90},{120,110}})));
  Modelica.Blocks.Continuous.Integrator EPumHeaPumGly(initType=Modelica.Blocks.Types.Init.InitialState)
    "Heat pump glycol side pump electric energy"
    annotation (Placement(transformation(extent={{180,50},{200,70}})));
  Modelica.Blocks.Continuous.Integrator EPumHexGly(initType=Modelica.Blocks.Types.Init.InitialState)
    "Heat exchanger glycol side pump electric energy"
    annotation (Placement(transformation(extent={{140,70},{160,90}})));
  Modelica.Blocks.Continuous.Integrator EComPla(initType=Modelica.Blocks.Types.Init.InitialState)
    "Plant heat pumps compressor electric energy"
    annotation (Placement(transformation(extent={{240,20},{260,40}})));
  Modelica.Blocks.Continuous.Integrator EPumHeaPumWat(initType=Modelica.Blocks.Types.Init.InitialState)
    "Heat pump water side pump electric energy"
    annotation (Placement(transformation(extent={{180,0},{200,20}})));
  Modelica.Blocks.Continuous.Integrator EPumCirPum(initType=Modelica.Blocks.Types.Init.InitialState)
    "Circulation pump electric energy"
    annotation (Placement(transformation(extent={{180,-40},{200,-20}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum EPumPla(nin=5)
    "Plant pumps electricity energy"
    annotation (Placement(transformation(extent={{240,60},{260,80}})));


equation
  connect(dis.ports_bCon, bui.port_aSerAmb) annotation (Line(points={{-12,210},
          {-14,210},{-14,240},{-10,240}},color={0,127,255}));
  connect(dis.ports_aCon, bui.port_bSerAmb) annotation (Line(points={{12,210},{
          16,210},{16,240},{10,240}},
                                   color={0,127,255}));
  connect(pipeGroundCouplingMulti[1:(nBui+1)].heatPorts[1], dis.heatPorts)
    annotation (Line(points={{1,155},{1,156},{0.4,156},{0.4,197.8}},
        color={127,0,0}));
  connect(conPla.port_bDis, TDisWatSup.port_a)
    annotation (Line(points={{-80,0},{-80,140}},color={0,127,255},
      thickness=0.5));
  connect(TDisWatRet.port_b, conPla.port_aDis)
    annotation (Line(points={{-80,-70},{-80,-20}}, color={0,127,255},
      thickness=0.5));
  connect(PPumETS.y, EPumETS.u)
    annotation (Line(points={{202,240},{238,240}}, color={0,0,127}));
  connect(pumDis.P, EPumDis.u)
    annotation (Line(points={{81,-71},{81,-80},{218,-80}}, color={0,0,127}));
  connect(EPumETS.y, EPum.u[1]) annotation (Line(points={{261,240},{286,240},{
          286,159.333},{298,159.333}},
                               color={0,0,127}));
  connect(EPumDis.y, EPum.u[2]) annotation (Line(points={{241,-80},{286,-80},{
          286,160},{298,160}}, color={0,0,127}));
  connect(PHeaPump.y, EHeaPum.u)
    annotation (Line(points={{202,200},{238,200}}, color={0,0,127}));
  connect(EHeaPum.y, ETot.u[1]) annotation (Line(points={{261,200},{350,200},{
          350,99.25},{360,99.25}},
                               color={0,0,127}));
  connect(EPum.y, ETot.u[2]) annotation (Line(points={{322,160},{340,160},{340,
          99.75},{360,99.75}},
                           color={0,0,127}));
  connect(TDisWatSup.T, conVio.u[1]) annotation (Line(points={{-91,150},{-220,
          150},{-220,-122},{50,-122},{50,-120.5},{318,-120.5}},
                                                           color={0,0,127}));
  connect(TDisWatRet.T, conVio.u[2]) annotation (Line(points={{-91,-80},{-100,
          -80},{-100,-119.5},{318,-119.5}},
        color={0,0,127}));
  connect(TDisWatRet.port_a, pumDis.port_b) annotation (Line(points={{-80,-90},
          {-80,-100},{90,-100},{90,-70}},color={0,127,255},
      thickness=0.5));
  connect(bui.PPum, PPumETS.u) annotation (Line(points={{12,243},{128,243},{128,
          240},{178,240}}, color={0,0,127}));
  connect(bui.PCoo, PHeaPump.u) annotation (Line(points={{12,247},{120,247},{
          120,200},{178,200}},
                           color={0,0,127}));
  connect(dis.port_aDisSup, TDisWatSup.port_b) annotation (Line(points={{-20,200},
          {-80,200},{-80,160}},color={0,127,255},
      thickness=0.5));
  connect(dis.port_bDisSup, pumDis.port_a)
    annotation (Line(points={{20,200},{90,200},{90,-50}}, color={0,127,255},
      thickness=0.5));
  connect(pumDis.port_a, bou.ports[1]) annotation (Line(points={{90,-50},{90,
          -44},{128,-44},{128,-60},{140,-60}}, color={0,127,255},
      thickness=0.5));
  connect(conPla.port_bCon, cenPla.port_a) annotation (Line(points={{-90,-10},{-100,
          -10},{-100,-20},{-200,-20},{-200,0},{-160,0}}, color={0,127,255}));
  connect(conPla.port_aCon, cenPla.port_b) annotation (Line(points={{-90,-4},{-100,
          -4},{-100,0},{-140,0}}, color={0,127,255}));
  connect(looPumSpe.yDisPum, gai.u)
    annotation (Line(points={{-38,-150},{-2,-150}}, color={0,0,127}));
  connect(gai.y, pumDis.m_flow_in) annotation (Line(points={{22,-150},{40,-150},
          {40,-60},{78,-60}}, color={0,0,127}));
  connect(TDisWatRet.T, looPumSpe.TMixMax) annotation (Line(points={{-91,-80},{
          -100,-80},{-100,-144},{-62,-144}}, color={0,0,127}));
  connect(TDisWatRet.T, looPumSpe.TMixMin) annotation (Line(points={{-91,-80},{
          -100,-80},{-100,-156},{-62,-156}}, color={0,0,127}));
  connect(looPumSpe.yDisPum, cenPla.uDisPum) annotation (Line(points={{-38,-150},
          {-20,-150},{-20,-180},{-180,-180},{-180,9},{-162,9}}, color={0,0,127}));
  connect(TDisWatRet.T, cenPla.TMixAve) annotation (Line(points={{-91,-80},{-174,
          -80},{-174,3},{-162,3}}, color={0,0,127}));
  connect(weaBus.solTim, cenPla.uSolTim) annotation (Line(
      points={{-299.9,-19.9},{-260,-19.9},{-260,7},{-162,7}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(weaBus.TDryBul, cenPla.TDryBul) annotation (Line(
      points={{-299.9,-19.9},{-260,-19.9},{-260,-7},{-162,-7}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus.TWetBul, cenPla.TWetBul) annotation (Line(
      points={{-299.9,-19.9},{-260,-19.9},{-260,-9},{-162,-9}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(weaDat.weaBus, weaBus) annotation (Line(
      points={{-360,-20},{-300,-20}},
      color={255,204,51},
      thickness=0.5));
  connect(cenPla.PFanDryCoo, PFanDryCoo.u) annotation (Line(points={{-138,7},
          {-132,7},{-132,120},{-62,120}},     color={0,0,127}));
  connect(cenPla.PPumDryCoo, PPumDryCoo.u) annotation (Line(points={{-138,5},
          {-128,5},{-128,100},{-22,100}},     color={0,0,127}));
  connect(cenPla.PPumHexGly, PPumHexGly.u) annotation (Line(points={{-138,3},
          {-124,3},{-124,80},{18,80}},     color={0,0,127}));
  connect(cenPla.PPumHeaPumGly, PPumHeaPumGly.u) annotation (Line(points={{-138,-3},
          {-120,-3},{-120,60},{58,60}},              color={0,0,127}));
  connect(cenPla.PCom, PCom.u) annotation (Line(points={{-138,-5},{-116,-5},
          {-116,30},{98,30}},     color={0,0,127}));
  connect(cenPla.PPumHeaPumWat, PPumHeaPumWat.u) annotation (Line(points={{-138,-7},
          {-112,-7},{-112,10},{138,10}},              color={0,0,127}));
  connect(cenPla.PPumCirPum, PPumCirPum.u) annotation (Line(points={{-138,-9},
          {-124,-9},{-124,-30},{138,-30},{138,-30}},   color={0,0,127}));
  connect(PFanDryCoo.y, EFunDryCoo.u)
    annotation (Line(points={{-38,120},{238,120}}, color={0,0,127}));
  connect(PPumDryCoo.y, EPumDryCoo.u)
    annotation (Line(points={{2,100},{98,100}}, color={0,0,127}));
  connect(PPumHexGly.y, EPumHexGly.u)
    annotation (Line(points={{42,80},{138,80}}, color={0,0,127}));
  connect(PPumHeaPumGly.y, EPumHeaPumGly.u)
    annotation (Line(points={{82,60},{178,60}}, color={0,0,127}));
  connect(PCom.y, EComPla.u)
    annotation (Line(points={{122,30},{238,30}}, color={0,0,127}));
  connect(PPumHeaPumWat.y, EPumHeaPumWat.u)
    annotation (Line(points={{162,10},{178,10}}, color={0,0,127}));
  connect(PPumCirPum.y, EPumCirPum.u)
    annotation (Line(points={{162,-30},{178,-30}}, color={0,0,127}));
  connect(EPumDryCoo.y, EPumPla.u[1]) annotation (Line(points={{121,100},{230,
          100},{230,69.2},{238,69.2}}, color={0,0,127}));
  connect(EPumHexGly.y, EPumPla.u[2]) annotation (Line(points={{161,80},{220,80},
          {220,69.6},{238,69.6}}, color={0,0,127}));
  connect(EPumHeaPumGly.y, EPumPla.u[3]) annotation (Line(points={{201,60},{220,
          60},{220,70},{238,70}}, color={0,0,127}));
  connect(EPumHeaPumWat.y, EPumPla.u[4]) annotation (Line(points={{201,10},{228,
          10},{228,70},{238,70},{238,70.4}}, color={0,0,127}));
  connect(EPumCirPum.y, EPumPla.u[5]) annotation (Line(points={{201,-30},{226,
          -30},{226,70.8},{238,70.8}}, color={0,0,127}));
  connect(EPumPla.y, EPum.u[3]) annotation (Line(points={{262,70},{282,70},{282,
          160.667},{298,160.667}}, color={0,0,127}));
  connect(EFunDryCoo.y, ETot.u[3]) annotation (Line(points={{261,120},{332,120},
          {332,100.25},{360,100.25}}, color={0,0,127}));
  connect(EComPla.y, ETot.u[4]) annotation (Line(points={{261,30},{320,30},{320,
          100.75},{360,100.75}}, color={0,0,127}));
  annotation (
  Diagram(
  coordinateSystem(preserveAspectRatio=false, extent={{-400,-260},{400,260}})),
    __Dymola_Commands(
  file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Networks/Validation/SinglePlantSingleHub.mos"
  "Simulate and plot"),
  experiment(
      StartTime=7776000,
      StopTime=8640000,
      Tolerance=1e-06),
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
The plant is replaced with an idealised component.
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
The pressurisation point of the loop is moved to upstream the main pump.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end JBAPlantSingleHub;
