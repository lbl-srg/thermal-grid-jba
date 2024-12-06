within ThermalGridJBA.Networks.Validation;
model SinglePlantReduced
  "Different implementation of SinglePlant to work around Dymola bug"
  extends Modelica.Icons.Example;

  parameter String filNam[nBui]={
    "modelica://Buildings/Resources/Data/DHC/Loads/Examples/SwissOffice_20190916.mos",
    "modelica://Buildings/Resources/Data/DHC/Loads/Examples/SwissResidential_20190916.mos",
    "modelica://Buildings/Resources/Data/DHC/Loads/Examples/SwissHospital_20190916.mos"}
    "Library paths of the files with thermal loads as time series";
  parameter Modelica.Units.SI.Length diameter=sqrt(4*datDes.mPipDis_flow_nominal/1000/1.5/Modelica.Constants.pi)
    "Pipe diameter (without insulation)";
  parameter Modelica.Units.SI.Height lDisPip=200 "Distribution pipes length";
  parameter Modelica.Units.SI.Radius rPip=diameter/2 "Pipe external radius";
  parameter Modelica.Units.SI.Radius thiGroLay=0.5
    "Dynamic ground layer thickness";
  package Medium = Buildings.Media.Water "Medium model";
  constant Real facMul = 10
    "Building loads multiplier factor";
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
  parameter Integer nBui = datDes.nBui
    "Number of buildings connected to DHC system"
    annotation (Evaluate=true);
  inner parameter
    Buildings.DHC.Examples.Combined.BaseClasses.DesignDataSeries datDes(
    mCon_flow_nominal=fill(datDes.mPipDis_flow_nominal,nBui),
    lEnd=100,
    mPumDis_flow_nominal=97.3,
    mPipDis_flow_nominal=69.5,
    mSto_flow_nominal=75,
    dpPla_nominal(displayUnit="bar") = 50000,
    TLooMin=279.15,
    dp_length_nominal=250,
    epsPla=0.91) "Design data"
    annotation (Placement(transformation(extent={{-360,220},{-340,240}})));

  Modelica.Blocks.Sources.Constant masFloDisPla(
    k=datDes.mPla_flow_nominal)
    "District water flow rate to plant"
    annotation (Placement(transformation(extent={{-250,10},{-230,30}})));
  Buildings.DHC.Networks.Controls.MainPump1Pipe conPum(
    nMix=nBui,
    nSou=1,
    nBui=nBui,
    TMin=279.15,
    TMax=290.15,
    dTSlo=1.5) "Main pump controller"
    annotation (Placement(transformation(extent={{-52,-198},{-28,-162}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(k=datDes.mPumDis_flow_nominal)
    "Scale with nominal mass flow rate"
    annotation (Placement(transformation(extent={{24,-190},{44,-170}})));
  Modelica.Blocks.Sources.CombiTimeTable HXtemperature(table=[0,14 + 273.15; 60
        *86400,12 + 273.15; 210*86400,20 + 273.15; 365*86400,14 + 273.15],
                                     extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic)
    annotation (Placement(transformation(extent={{-288,30},{-268,50}})));
  Modelica.Blocks.Math.Product product1
    annotation (Placement(transformation(extent={{-216,4},{-196,24}})));

  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatSup1(redeclare final
      package Medium = Medium, final m_flow_nominal=datDes.mPumDis_flow_nominal)
    "District water supply temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,128})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatRet1(redeclare final
      package Medium = Medium, final m_flow_nominal=datDes.mPumDis_flow_nominal)
    "District water return temperature" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={80,128})));
  Buildings.Fluid.FixedResistances.BuriedPipes.PipeGroundCoupling pipeGroundCouplingMulti[nBui + 3](
    each lPip=lDisPip,
    each rPip=rPip,
    each thiGroLay=thiGroLay,
    each nSeg=1,
    redeclare parameter Buildings.HeatTransfer.Data.Soil.Generic soiDat(
      each k=2.3,
      each c=1000,
      each d=2600))
    annotation (Placement(transformation(extent={{-10,100},{12,80}})));
  Buildings.DHC.Networks.Controls.AgentPump1Pipe pumPlantControlNsew(
    yPumMin=0,
    dToff=0.5,
    k=0.8,
    Ti=600,
    uLowHea=0.75,
    uHighHea=1.5,
    h=0.5) annotation (Placement(transformation(extent={{-280,-10},{-260,10}})));

  Buildings.DHC.Networks.Distribution1PipePlugFlow_v dis(
    nCon=nBui,
    allowFlowReversal=allowFlowReversalSer,
    redeclare package Medium = Medium,
    show_TOut=true,
    mDis_flow_nominal=datDes.mPipDis_flow_nominal,
    mCon_flow_nominal=datDes.mCon_flow_nominal,
    lDis=datDes.lDis,
    lEnd=datDes.lEnd,
    dIns=0.02,
    kIns=0.2)
    annotation (Placement(transformation(extent={{-20,132},{20,152}})));
  Buildings.Fluid.FixedResistances.PlugFlowPipe supDisPluFlo(
    redeclare package Medium = Medium,
    allowFlowReversal=allowFlowReversalSer,
    m_flow_nominal=datDes.mPipDis_flow_nominal,
    length=lDisPip,
    dIns=0.02,
    kIns=0.2) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={-80,92})));
  Buildings.Fluid.FixedResistances.PlugFlowPipe retDisPluFlo(
    redeclare package Medium = Medium,
    allowFlowReversal=allowFlowReversalSer,
    m_flow_nominal=datDes.mPipDis_flow_nominal,
    length=lDisPip,
    dIns=0.02,
    kIns=0.2) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={80,92})));
  Buildings.DHC.ETS.BaseClasses.Pump_m_flow pumDis(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDes.mPumDis_flow_nominal,
    final allowFlowReversal=allowFlowReversalSer,
    dp_nominal=150E3)
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
        origin={112,-100})));
  Buildings.DHC.Networks.Connections.Connection1Pipe_R conPla(
    redeclare final package Medium = Medium,
    final mDis_flow_nominal=datDes.mPipDis_flow_nominal,
    final mCon_flow_nominal=datDes.mPla_flow_nominal,
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
    final m_flow_nominal=datDes.mPla_flow_nominal,
    final dp_nominal=datDes.dpPla_nominal,
    final TLooMin=datDes.TLooMin,
    final TLooMax=datDes.TLooMax,
    dTOff=2) "Ideal heating and cooling plant"
    annotation (Placement(transformation(extent={{-160,-10},{-140,10}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatSup(redeclare final package
      Medium = Medium, final m_flow_nominal=datDes.mPumDis_flow_nominal)
    "District water supply temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,20})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatBorLvg(redeclare final
      package Medium = Medium, final m_flow_nominal=datDes.mPumDis_flow_nominal)
    "District water borefield leaving temperature" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-40})));
  ThermalGridJBA.Hubs.ConnectedETS
    bui[nBui](
    final filNam = filNam,
    bui(each final facMul=facMul),
    redeclare each final package MediumBui = Medium,
    redeclare each final package MediumSer = Medium,
    each final allowFlowReversalBui=allowFlowReversalBui,
    each final allowFlowReversalSer=allowFlowReversalSer,
    each final TDisWatMin=datDes.TLooMin,
    each final TDisWatMax=datDes.TLooMax) "Building and ETS"
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
    final uMin(final unit="K", displayUnit="degC")=datDes.TLooMin,
    final uMax(final unit="K", displayUnit="degC")=datDes.TLooMax,
    final nu=2,
    u(each final unit="K", each displayUnit="degC"))
    "Check if loop temperatures are within given range"
    annotation (Placement(transformation(extent={{320,10},{340,30}})));
equation
  connect(pumDis.m_flow_in, gai.y)
    annotation (Line(points={{68,-60},{60,-60},{60,-180},{46,-180}},
                                                 color={0,0,127}));
  connect(conPum.y, gai.u)
    annotation (Line(points={{-26.1538,-180},{22,-180}},
                                                 color={0,0,127}));
  connect(TDisWatBorLvg.T, conPum.TSouIn[1]) annotation (Line(points={{-91,-40},
          {-100,-40},{-100,-174.6},{-54.0308,-174.6}},
                                                  color={0,0,127}));
  connect(TDisWatSup.T, conPum.TSouOut[1]) annotation (Line(points={{-91,20},{
          -102,20},{-102,-183.6},{-54.0308,-183.6}},
                                                   color={0,0,127}));
  connect(masFloDisPla.y, product1.u1)
    annotation (Line(points={{-229,20},{-218,20}},           color={0,0,127}));
  connect(product1.y, pla.mPum_flow) annotation (Line(points={{-195,14},{-195,
          4.66667},{-161.333,4.66667}}, color={0,0,127}));
  connect(TDisWatBorLvg.T, pumPlantControlNsew.TSouIn) annotation (Line(points={{-91,-40},
          {-286,-40},{-286,7},{-281.538,7}},
        color={0,0,127}));
  connect(TDisWatSup.T,pumPlantControlNsew.TSouOut)  annotation (Line(points={{-91,20},
          {-100,20},{-100,60},{-296,60},{-296,-1},{-281.538,-1}},     color={0,0,
          127}));
  connect(TDisWatSup1.T,pumPlantControlNsew.TSupDis)  annotation (Line(points={{-91,128},
          {-312,128},{-312,-8},{-281.538,-8}},          color={0,0,127}));
  connect(TDisWatRet1.T,pumPlantControlNsew.TRetDis)  annotation (Line(points={{69,128},
          {40,128},{40,112},{-308,112},{-308,-5},{-281.538,-5}},
        color={0,0,127}));
  connect(pumPlantControlNsew.y, product1.u2) annotation (Line(points={{
          -258.462,0},{-220,0},{-220,8},{-218,8}},
                                 color={0,0,127}));
  connect(TDisWatSup1.port_b, dis.port_aDisSup) annotation (Line(points={{-80,138},
          {-80,142},{-20,142}}, color={0,127,255}));
  connect(dis.port_bDisSup, TDisWatRet1.port_a)
    annotation (Line(points={{20,142},{80,142},{80,138}}, color={0,127,255}));
  connect(dis.ports_bCon, bui.port_aSerAmb) annotation (Line(points={{-12,152},
          {-14,152},{-14,180},{-10,180}},color={0,127,255}));
  connect(dis.ports_aCon, bui.port_bSerAmb) annotation (Line(points={{12,152},{
          16,152},{16,180},{10,180}},
                                   color={0,127,255}));
  connect(dis.TOut, conPum.TMix) annotation (Line(points={{22,136},{34,136},{34,
          156},{-380,156},{-380,-168},{-54.0308,-168},{-54.0308,-167.4}},
                                                    color={0,0,127}));
  connect(TDisWatSup.port_b, supDisPluFlo.port_a)
    annotation (Line(points={{-80,30},{-80,82}}, color={0,127,255}));
  connect(supDisPluFlo.port_b, TDisWatSup1.port_a) annotation (Line(points={{-80,102},
          {-80,118}},                color={0,127,255}));
  connect(TDisWatRet1.port_b, retDisPluFlo.port_a)
    annotation (Line(points={{80,118},{80,102}}, color={0,127,255}));
  connect(pipeGroundCouplingMulti[1:(nBui+1)].heatPorts[1], dis.heatPorts)
    annotation (Line(points={{1,95},{1,96},{0.4,96},{0.4,139.8}},
        color={127,0,0}));
  connect(supDisPluFlo.heatPort, pipeGroundCouplingMulti[nBui + 2].heatPorts[1])
    annotation (Line(points={{-70,92},{1,92},{1,95}},
        color={191,0,0}));
  connect(retDisPluFlo.heatPort, pipeGroundCouplingMulti[nBui + 3].heatPorts[1])
    annotation (Line(points={{70,92},{1,92},{1,95}},                     color={
          191,0,0}));
  connect(HXtemperature.y[1], pumPlantControlNsew.TSou) annotation (Line(points={{-267,40},
          {-260,40},{-260,20},{-288,20},{-288,3},{-281.538,3}},
                     color={0,0,127}));
  connect(bui.QCoo_flow, conPum.QCoo_flow) annotation (Line(points={{7,168},{7,
          160},{-388,160},{-388,-190.8},{-54.0308,-190.8}},
        color={0,0,127}));
  connect(conPla.port_bDis, TDisWatSup.port_a)
    annotation (Line(points={{-80,0},{-80,10}}, color={0,127,255}));
  connect(TDisWatBorLvg.port_b, conPla.port_aDis)
    annotation (Line(points={{-80,-30},{-80,-20}}, color={0,127,255}));
  connect(pla.port_bSerAmb, conPla.port_aCon) annotation (Line(points={{-140,1.33333},
          {-100,1.33333},{-100,-4},{-90,-4}}, color={0,127,255}));
  connect(conPla.port_bCon, pla.port_aSerAmb) annotation (Line(points={{-90,-10},
          {-100,-10},{-100,-20},{-200,-20},{-200,1.33333},{-160,1.33333}},
        color={0,127,255}));
  connect(PPumETS.y, EPumETS.u)
    annotation (Line(points={{162,200},{218,200}}, color={0,0,127}));
  connect(pumDis.P, EPumDis.u)
    annotation (Line(points={{71,-71},{71,-80},{218,-80}}, color={0,0,127}));
  connect(pla.PPum, EPumPla.u) annotation (Line(points={{-138.667,5.33333},{
          -120,5.33333},{-120,40},{218,40}}, color={0,0,127}));
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
  connect(TDisWatBorLvg.T, conVio.u[2]) annotation (Line(points={{-91,-40},{-100,
          -40},{-100,-30},{-60,-30},{-60,-40},{300,-40},{300,20.5},{318,20.5}},
                                                        color={0,0,127}));
  connect(bou.ports[1], pumDis.port_b)
    annotation (Line(points={{102,-100},{80,-100},{80,-70}},
                                                           color={0,127,255}));
  connect(TDisWatBorLvg.port_a, pumDis.port_b) annotation (Line(points={{-80,-50},
          {-80,-100},{80,-100},{80,-70}}, color={0,127,255}));
  connect(bui.PPum, PPumETS.u) annotation (Line(points={{12,183},{128,183},{128,
          200},{138,200}}, color={0,0,127}));
  connect(bui.PCoo, PHeaPump.u) annotation (Line(points={{12,187},{120,187},{120,
          160},{138,160}}, color={0,0,127}));
  connect(retDisPluFlo.port_b, pumDis.port_a)
    annotation (Line(points={{80,82},{80,-50}}, color={0,127,255}));
  annotation (
  Diagram(
  coordinateSystem(preserveAspectRatio=false, extent={{-400,-260},{400,260}})),
    __Dymola_Commands(
  file="modelica://Buildings/Resources/Scripts/Dymola/DHC/Examples/Combined/SeriesVariableFlowAgentControl.mos"
  "Simulate and plot"),
  experiment(
      StopTime=604800,
      Tolerance=1e-06),
    Documentation(revisions="<html>
<ul>
<li>
January 20, 2023, by Ettore Zanetti:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
This model is an updated version of
<a href=\"modelica://Buildings.DHC.Examples.Combined.SeriesVariableFlow\">
Buildings.DHC.Examples.Combined.SeriesVariableFlow</a>.
In particular the following have been updated:
</p>
<ul>
<li>
The sewage water temperature, mass flow rate and ground temperature are not constant and instead have a seasonal yearly profile.
</li>
<li>
The distribution network pripes now use the plug-flow model to add transport delay and ground coupling to the distribution network.
</li>
<li>
The borefield and sewagre heat exchanger circulation pumps are controlled by an agent specific controller <a href=\"modelica://Buildings.DHC.Networks.Controls.AgentPump1Pipe\">
Buildings.DHC.Networks.Controls.AgentPump1Pipe</a>.
</li>
</ul>


<h4>References</h4>

<p>
Ettore Zanetti, David Blum, Michael Wetter (2023) <a href=\"https://https://2023.international.conference.modelica.org/proceedings.html\">
Control development and sizing analysis for a 5th generation district heating and cooling network using Modelica</a>,
In Proceedings of the 15th International Modelica Conference. Aachen, Germany, Oct 9-11, 2023.
</p>

</html>"),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end SinglePlantReduced;
