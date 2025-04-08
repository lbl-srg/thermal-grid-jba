within ThermalGridJBA.Networks.Validation;
model SinglePlantSingleHub
  "District network with a single plant and a single combined hub"
  extends Modelica.Icons.Example;

  parameter Modelica.Units.SI.Length diameter=sqrt(4*datDis.mPipDis_flow_nominal/1000/1.5/Modelica.Constants.pi)
    "Pipe diameter (without insulation)";
  parameter Modelica.Units.SI.Radius rPip=diameter/2 "Pipe external radius";
  parameter Modelica.Units.SI.Radius thiGroLay=0.5
    "Dynamic ground layer thickness";
  package Medium = Buildings.Media.Water "Medium model";
  parameter Real dpDis_length_nominal(final unit="Pa/m") = 250
    "Pressure drop per pipe length at nominal flow rate - Distribution line";
  parameter Real dpCon_length_nominal(final unit="Pa/m") = 250
    "Pressure drop per pipe length at nominal flow rate - Connection line";
  parameter Boolean allowFlowReversalSer = true
    "Set to true to allow flow reversal in the service lines"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Boolean allowFlowReversalBui = false
    "Set to true to allow flow reversal for in-building systems"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Modelica.Units.SI.Length dhPla(fixed=false,start=0.05,min=0.01)
    "Hydraulic diameter of the distribution pipe before each connection";
  final parameter Integer nBui=datDis.nBui
    "Number of buildings connected to DHC system"
    annotation (Evaluate=true);
  inner replaceable parameter ThermalGridJBA.Data.Districts.SingleHub datDis(
    mCon_flow_nominal=bui.ets.hex.m1_flow_nominal)
    "Parameters for the district network"
    annotation (Placement(transformation(extent={{-360,220},{-340,240}})));

  ThermalGridJBA.BoundaryConditions.WeatherData wea[nBui](
    final weaFil = bui.weaFil)
                              "fTMY weather data reader"
    annotation (Placement(transformation(extent={{-40,220},{-20,240}})));

  Buildings.DHC.Networks.Controls.MainPump1Pipe conPum(
    nMix=nBui,
    nSou=1,
    nBui=nBui,
    TMin=279.15,
    TMax=290.15,
    dTSlo=1.5) "Main pump controller"
    annotation (Placement(transformation(extent={{-52,-198},{-28,-162}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(k=datDis.mPumDis_flow_nominal)
    "Scale with nominal mass flow rate"
    annotation (Placement(transformation(extent={{24,-190},{44,-170}})));

  Buildings.Fluid.FixedResistances.BuriedPipes.PipeGroundCoupling pipeGroundCouplingMulti[nBui + 1](
    lPip=datDis.lDis,
    each rPip=rPip,
    each thiGroLay=thiGroLay,
    each nSeg=1,
    redeclare parameter Buildings.HeatTransfer.Data.Soil.Generic soiDat(
      each k=2.3,
      each c=1000,
      each d=2600))
    annotation (Placement(transformation(extent={{-10,100},{12,80}})));

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
    annotation (Placement(transformation(extent={{-20,132},{20,152}})));
  Buildings.DHC.ETS.BaseClasses.Pump_m_flow pumDis(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDis.mPumDis_flow_nominal,
    final allowFlowReversal=allowFlowReversalSer,
    final dp_nominal=sum(dis.con.pipDis.res.dp_nominal) + dis.pipEnd.res.dp_nominal)
    "Distribution pump"
    annotation (Placement(transformation(
      extent={{10,-10},{-10,10}},
      rotation=90,
      origin={80,-60})));
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
    final mCon_flow_nominal=pla.m_flow_nominal,
    lDis=50,
    final allowFlowReversal=allowFlowReversalSer,
    dhDis=dhPla)
    "Connection to the plant (pressure drop lumped in plant and network model)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-10})));
  ThermalGridJBA.Networks.IdealHeatingCoolingPlant
    pla(
    redeclare final package Medium = Medium,
    final m_flow_nominal=sum(datDis.mCon_flow_nominal),
    final dp_nominal=5000000,
    final TLooMin=datDis.TLooMin,
    final TLooMax=datDis.TLooMax,
    dTOff=2) "Ideal heating and cooling plant"
    annotation (Placement(transformation(extent={{-160,-12},{-140,8}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatSup(redeclare final package
      Medium = Medium, final m_flow_nominal=datDis.mPumDis_flow_nominal)
    "District water supply temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,20})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatRet(redeclare final package
      Medium = Medium, final m_flow_nominal=datDis.mPumDis_flow_nominal)
    "District water return temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-40})));
  ThermalGridJBA.Hubs.ConnectedETS
    bui[nBui](
    final filNam = datDis.filNam,
    bui(each final facMul=1),
    redeclare each final package MediumBui = Medium,
    redeclare each final package MediumSer = Medium,
    each final allowFlowReversalBui=allowFlowReversalBui,
    each final allowFlowReversalSer=allowFlowReversalSer,
    each final TDisWatMin=datDis.TLooMin,
    each final TDisWatMax=datDis.TLooMax,
    ets(chi(pumEva(each use_riseTime=true)))) "Building and ETS"
    annotation (Placement(transformation(extent={{-10,170},{10,190}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PPumETS(nin=nBui)
    "ETS pump power"
    annotation (Placement(transformation(extent={{140,190},{160,210}})));
  Modelica.Blocks.Continuous.Integrator EPumETS(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "ETS pump electric energy"
    annotation (Placement(transformation(extent={{220,190},{240,210}})));
  Modelica.Blocks.Continuous.Integrator EPumDis(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "Distribution pump electric energy"
    annotation (Placement(transformation(extent={{220,-90},{240,-70}})));
  Modelica.Blocks.Continuous.Integrator EPumPla(initType=Modelica.Blocks.Types.Init.InitialState)
    "Plant pump electric energy"
    annotation (Placement(transformation(extent={{220,30},{240,50}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum EPum(nin=3)
    "Total pump electric energy"
    annotation (Placement(transformation(extent={{280,110},{300,130}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum PHeaPump(nin=nBui)
    "Heat pump power"
    annotation (Placement(transformation(extent={{140,150},{160,170}})));
  Modelica.Blocks.Continuous.Integrator EHeaPum(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "Heat pump electric energy"
    annotation (Placement(transformation(extent={{220,150},{240,170}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum ETot(nin=2) "Total electric energy"
    annotation (Placement(transformation(extent={{320,150},{340,170}})));
  Buildings.DHC.Loads.BaseClasses.ConstraintViolation conVio(
    final uMin(final unit="K", displayUnit="degC")=datDis.TLooMin,
    final uMax(final unit="K", displayUnit="degC")=datDis.TLooMax,
    final nu=2,
    u(each final unit="K", each displayUnit="degC"))
    "Check if loop temperatures are within given range"
    annotation (Placement(transformation(extent={{320,10},{340,30}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant mPumPla_flow_set(
    final k=pla.m_flow_nominal,
    y(quantity="MassFlowRate"))
    "Plant pump flow rate"
    annotation (Placement(transformation(extent={{-240,20},{-220,40}})));
equation
  connect(pumDis.m_flow_in, gai.y)
    annotation (Line(points={{68,-60},{60,-60},{60,-180},{46,-180}},
                                                 color={0,0,127}));
  connect(conPum.y, gai.u)
    annotation (Line(points={{-25.6,-180},{22,-180}},
                                                 color={0,0,127}));
  connect(TDisWatRet.T, conPum.TSouIn[1]) annotation (Line(points={{-91,-40},{-100,
          -40},{-100,-172.8},{-54.4,-172.8}},    color={0,0,127}));
  connect(TDisWatSup.T, conPum.TSouOut[1]) annotation (Line(points={{-91,20},{-102,
          20},{-102,-187.2},{-54.4,-187.2}},       color={0,0,127}));
  connect(dis.ports_bCon, bui.port_aSerAmb) annotation (Line(points={{-12,152},
          {-14,152},{-14,180},{-10,180}},color={0,127,255}));
  connect(dis.ports_aCon, bui.port_bSerAmb) annotation (Line(points={{12,152},{
          16,152},{16,180},{10,180}},
                                   color={0,127,255}));
  connect(dis.TOut, conPum.TMix) annotation (Line(points={{22,136},{34,136},{34,
          156},{-380,156},{-380,-168},{-54.4,-168},{-54.4,-165.6}},
                                                    color={0,0,127}));
  connect(pipeGroundCouplingMulti[1:(nBui+1)].heatPorts[1], dis.heatPorts)
    annotation (Line(points={{1,95},{1,96},{0.4,96},{0.4,139.8}},
        color={127,0,0}));
  connect(bui.QCoo_flow, conPum.QCoo_flow) annotation (Line(points={{7,168},{7,160},
          {-388,160},{-388,-194.4},{-54.4,-194.4}},
        color={0,0,127}));
  connect(conPla.port_bDis, TDisWatSup.port_a)
    annotation (Line(points={{-80,0},{-80,10}}, color={0,127,255}));
  connect(TDisWatRet.port_b, conPla.port_aDis)
    annotation (Line(points={{-80,-30},{-80,-20}}, color={0,127,255}));
  connect(pla.port_bSerAmb, conPla.port_aCon) annotation (Line(points={{-140,-0.666667},
          {-100,-0.666667},{-100,-4},{-90,-4}},
                                              color={0,127,255}));
  connect(conPla.port_bCon, pla.port_aSerAmb) annotation (Line(points={{-90,-10},
          {-100,-10},{-100,-20},{-200,-20},{-200,-0.666667},{-160,-0.666667}},
        color={0,127,255}));
  connect(PPumETS.y, EPumETS.u)
    annotation (Line(points={{162,200},{218,200}}, color={0,0,127}));
  connect(pumDis.P, EPumDis.u)
    annotation (Line(points={{71,-71},{71,-80},{218,-80}}, color={0,0,127}));
  connect(pla.PPum, EPumPla.u) annotation (Line(points={{-138.667,3.33333},{
          -120,3.33333},{-120,40},{218,40}}, color={0,0,127}));
  connect(EPumETS.y, EPum.u[1]) annotation (Line(points={{241,200},{260,200},{
          260,119.333},{278,119.333}},
                               color={0,0,127}));
  connect(EPumPla.y, EPum.u[2]) annotation (Line(points={{241,40},{260,40},{260,
          120},{278,120}},     color={0,0,127}));
  connect(EPumDis.y, EPum.u[3]) annotation (Line(points={{241,-80},{262,-80},{
          262,120.667},{278,120.667}},
                               color={0,0,127}));
  connect(PHeaPump.y, EHeaPum.u)
    annotation (Line(points={{162,160},{218,160}}, color={0,0,127}));
  connect(EHeaPum.y, ETot.u[1]) annotation (Line(points={{241,160},{300,160},{
          300,159.5},{318,159.5}},
                               color={0,0,127}));
  connect(EPum.y, ETot.u[2]) annotation (Line(points={{302,120},{310,120},{310,
          160.5},{318,160.5}},
                           color={0,0,127}));
  connect(TDisWatSup.T, conVio.u[1]) annotation (Line(points={{-91,20},{-100,20},
          {-100,12},{-60,12},{-60,19.5},{318,19.5}},       color={0,0,127}));
  connect(TDisWatRet.T, conVio.u[2]) annotation (Line(points={{-91,-40},{-100,-40},
          {-100,-30},{-60,-30},{-60,-40},{300,-40},{300,20.5},{318,20.5}},
        color={0,0,127}));
  connect(TDisWatRet.port_a, pumDis.port_b) annotation (Line(points={{-80,-50},{
          -80,-100},{80,-100},{80,-70}}, color={0,127,255}));
  connect(bui.PPum, PPumETS.u) annotation (Line(points={{12,183},{128,183},{128,
          200},{138,200}}, color={0,0,127}));
  connect(bui.PCoo, PHeaPump.u) annotation (Line(points={{12,187},{120,187},{120,
          160},{138,160}}, color={0,0,127}));
  connect(mPumPla_flow_set.y, pla.mPum_flow) annotation (Line(points={{-218,30},
          {-200,30},{-200,4},{-161.333,4},{-161.333,2.66667}}, color={0,0,127}));
  connect(dis.port_aDisSup, TDisWatSup.port_b) annotation (Line(points={{-20,142},
          {-80,142},{-80,30}}, color={0,127,255}));
  connect(dis.port_bDisSup, pumDis.port_a)
    annotation (Line(points={{20,142},{80,142},{80,-50}}, color={0,127,255}));
  connect(pumDis.port_a, bou.ports[1]) annotation (Line(points={{80,-50},{80,
          -44},{128,-44},{128,-60},{140,-60}}, color={0,127,255}));
  connect(wea.weaBus, bui.weaBus) annotation (Line(
      points={{-20,230},{0,230},{0,190}},
      color={255,204,51},
      thickness=0.5));
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
end SinglePlantSingleHub;
