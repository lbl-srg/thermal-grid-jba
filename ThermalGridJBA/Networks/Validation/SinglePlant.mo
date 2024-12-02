within ThermalGridJBA.Networks.Validation;
model SinglePlant "District network with a single plant"
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Medium model";
  constant Real facMul = 1
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
  parameter Modelica.Units.SI.Length dhSto(fixed=false,start=0.05,min=0.01)
    "Hydraulic diameter of the distribution pipe before each connection";
  parameter Modelica.Units.SI.Length dhPla(fixed=false,start=0.05,min=0.01)
    "Hydraulic diameter of the distribution pipe before each connection";
  parameter Integer nBui = datDis.nBui
    "Number of buildings connected to DHC system"
    annotation (Evaluate=true);
  parameter Modelica.Units.SI.Length diameter=
    sqrt(4*datDis.mPipDis_flow_nominal/1000/1.5/Modelica.Constants.pi)
    "Pipe diameter (without insulation)";
  parameter Modelica.Units.SI.Height lDisPip=200 "Distribution pipes length";
  parameter Modelica.Units.SI.Radius rPip=diameter/2 "Pipe external radius";
  parameter Modelica.Units.SI.Radius thiGroLay=0.5
    "Dynamic ground layer thickness";
  // COMPONENTS
  Buildings.DHC.ETS.BaseClasses.Pump_m_flow pumDis(
    redeclare final package Medium = Medium,
    final m_flow_nominal=datDis.mPumDis_flow_nominal,
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
        origin={112,-98})));
  Buildings.DHC.Networks.Connections.Connection1Pipe_R conPla(
    redeclare final package Medium = Medium,
    final mDis_flow_nominal=datDis.mPipDis_flow_nominal,
    final mCon_flow_nominal=datDis.mCon_flow_nominal,
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
    final m_flow_nominal=datDis.mPipDis_flow_nominal,
    final dp_nominal=1000000000)           "Sewage heat recovery plant"
    annotation (Placement(transformation(extent={{-160,-10},{-140,10}})));
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
  ThermalGridJBA.Hubs.ConnectedETS bui[nBui](
    redeclare final package MediumSer = Medium,
    redeclare final package MediumBui = Medium,
    final datBui={
      ThermalGridJBA.Data.Individual.B1569(),
      ThermalGridJBA.Data.Individual.B1380(),
      ThermalGridJBA.Data.Individual.B1560()},
    each allowFlowReversalSer=true,
    each THotWatSup_nominal=322.15) "Building and ETS"
    annotation (Placement(transformation(extent={{-10,170},{10,190}})));
 Buildings.Controls.OBC.CDL.Reals.MultiSum PPumETS(nin=nBui)
    "ETS pump power"
    annotation (Placement(transformation(extent={{140,160},{160,180}})));
  Modelica.Blocks.Continuous.Integrator EPumETS(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "ETS pump electric energy"
    annotation (Placement(transformation(extent={{220,160},{240,180}})));
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
    annotation (Placement(transformation(extent={{140,220},{160,240}})));
  Modelica.Blocks.Continuous.Integrator EHeaPum(
    initType=Modelica.Blocks.Types.Init.InitialState)
    "Heat pump electric energy"
    annotation (Placement(transformation(extent={{220,220},{240,240}})));
 Buildings.Controls.OBC.CDL.Reals.MultiSum ETot(nin=2) "Total electric energy"
    annotation (Placement(transformation(extent={{320,150},{340,170}})));
  Buildings.DHC.Loads.BaseClasses.ConstraintViolation conVio(
    final uMin(final unit="K", displayUnit="degC")=datDis.TLooMin,
    final uMax(final unit="K", displayUnit="degC")=datDis.TLooMax,
    final nu=2,
    u(each final unit="K", each displayUnit="degC"))
    "Check if loop temperatures are within given range"
    annotation (Placement(transformation(extent={{320,10},{340,30}})));
  Buildings.DHC.Networks.Controls.MainPump1Pipe conPum(
    nMix=nBui,
    nSou=2,
    nBui=nBui,
    TMin=279.15,
    TMax=290.15,
    dTSlo=1.5) "Main pump controller"
    annotation (Placement(transformation(extent={{-44,-198},{-20,-162}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(k=datDis.mPumDis_flow_nominal)
    "Scale with nominal mass flow rate"
    annotation (Placement(transformation(extent={{20,-190},{40,-170}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatSup1(redeclare final
      package Medium = Medium, final m_flow_nominal=datDis.mPumDis_flow_nominal)
    "District water supply temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,126})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TDisWatRet1(redeclare final
      package Medium = Medium, final m_flow_nominal=datDis.mPumDis_flow_nominal)
    "District water return temperature" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={80,126})));
  Buildings.Fluid.FixedResistances.BuriedPipes.PipeGroundCoupling pipeGroundCouplingMulti[nBui + 3](
    each lPip=lDisPip,
    each rPip=rPip,
    each thiGroLay=thiGroLay,
    each nSeg=1,
    redeclare parameter Buildings.HeatTransfer.Data.Soil.Generic soiDat(
      each k=2.3,
      each c=1000,
      each d=2600))
    annotation (Placement(transformation(extent={{-10,98},{12,78}})));
  Buildings.DHC.Networks.Distribution1PipePlugFlow_v dis(
    nCon=nBui,
    allowFlowReversal=allowFlowReversalSer,
    redeclare package Medium = Medium,
    show_TOut=true,
    mDis_flow_nominal=datDis.mPipDis_flow_nominal,
    mCon_flow_nominal=fill(datDis.mPipDis_flow_nominal, nBui),
    lDis=datDis.lDis,
    lEnd=datDis.lEnd,
    dIns=0.02,
    kIns=0.2)
    annotation (Placement(transformation(extent={{-20,130},{20,150}})));
  Buildings.Fluid.FixedResistances.PlugFlowPipe supDisPluFlo(
    redeclare package Medium = Medium,
    allowFlowReversal=allowFlowReversalSer,
    m_flow_nominal=datDis.mPipDis_flow_nominal,
    length=1138,
    dIns=0.02,
    kIns=0.2) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={-80,90})));
  Buildings.Fluid.FixedResistances.PlugFlowPipe retDisPluFlo(
    redeclare package Medium = Medium,
    allowFlowReversal=allowFlowReversalSer,
    m_flow_nominal=datDis.mPipDis_flow_nominal,
    length=4627,
    dIns=0.02,
    kIns=0.2) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={80,90})));
  inner Data.GenericDistrict datDis
    annotation (Placement(transformation(extent={{-340,220},{-320,240}})));
  Modelica.Blocks.Sources.Constant mPla(k=pla.m_flow_nominal)
    annotation (Placement(transformation(extent={{-240,20},{-220,40}})));
equation
  connect(conPla.port_bDis, TDisWatSup.port_a)
    annotation (Line(points={{-80,0},{-80,10}}, color={0,127,255}));
  connect(TDisWatRet.port_b, conPla.port_aDis)
    annotation (Line(points={{-80,-30},{-80,-20}}, color={0,127,255}));
  connect(pla.port_bSerAmb, conPla.port_aCon) annotation (Line(points={{-140,1.33333},
          {-100,1.33333},{-100,-4},{-90,-4}}, color={0,127,255}));
  connect(conPla.port_bCon, pla.port_aSerAmb) annotation (Line(points={{-90,-10},
          {-100,-10},{-100,-20},{-200,-20},{-200,1.33333},{-160,1.33333}},
        color={0,127,255}));
  connect(PPumETS.y, EPumETS.u)
    annotation (Line(points={{162,170},{218,170}}, color={0,0,127}));
  connect(pumDis.P, EPumDis.u)
    annotation (Line(points={{71,-71},{71,-80},{218,-80}}, color={0,0,127}));
  connect(pla.PPum, EPumPla.u) annotation (Line(points={{-138.667,5.33333},{
          -120,5.33333},{-120,40},{218,40}}, color={0,0,127}));
  connect(EPumETS.y, EPum.u[1]) annotation (Line(points={{241,170},{260,170},{
          260,119.333},{278,119.333}},
                               color={0,0,127}));
  connect(EPumPla.y, EPum.u[2]) annotation (Line(points={{241,40},{260,40},{260,
          120},{278,120}},     color={0,0,127}));
  connect(EPumDis.y, EPum.u[3]) annotation (Line(points={{241,-80},{262,-80},{
          262,120.667},{278,120.667}},
                               color={0,0,127}));
  connect(PHeaPump.y, EHeaPum.u)
    annotation (Line(points={{162,230},{218,230}}, color={0,0,127}));
  connect(EHeaPum.y, ETot.u[1]) annotation (Line(points={{241,230},{308,230},{308,
          159.5},{318,159.5}}, color={0,0,127}));
  connect(EPum.y, ETot.u[2]) annotation (Line(points={{302,120},{310,120},{310,
          160.5},{318,160.5}},
                           color={0,0,127}));
  connect(TDisWatSup.T, conVio.u[1]) annotation (Line(points={{-91,20},{-100,20},
          {-100,12},{-60,12},{-60,19.5},{318,19.5}},       color={0,0,127}));
  connect(TDisWatRet.T, conVio.u[2]) annotation (Line(points={{-91,-40},{-100,-40},
          {-100,-30},{-60,-30},{-60,-40},{300,-40},{300,20.5},{318,20.5}},
        color={0,0,127}));
  connect(bou.ports[1], pumDis.port_b)
    annotation (Line(points={{102,-98},{80,-98},{80,-70}}, color={0,127,255}));
  connect(TDisWatRet.port_a, pumDis.port_b) annotation (Line(points={{-80,-50},{
          -80,-120},{80,-120},{80,-70}}, color={0,127,255}));
  connect(pumDis.m_flow_in,gai. y)
    annotation (Line(points={{68,-60},{60,-60},{60,-180},{42,-180}},
                                                 color={0,0,127}));
  connect(conPum.y,gai. u)
    annotation (Line(points={{-18.1538,-180},{18,-180}},
                                                 color={0,0,127}));
  connect(TDisWatRet.T,conPum. TSouIn[1]) annotation (Line(points={{-91,-40},{
          -100,-40},{-100,-175.05},{-46.0308,-175.05}},
                                            color={0,0,127}));
  connect(TDisWatSup.T,conPum. TSouOut[2]) annotation (Line(points={{-91,20},{
          -106,20},{-106,-183.15},{-46.0308,-183.15}},
                                                   color={0,0,127}));
  connect(dis.TOut,conPum. TMix) annotation (Line(points={{22,134},{30,134},{30,
          112},{-340,112},{-340,-166},{-46.0308,-166},{-46.0308,-167.4}},
                                                    color={0,0,127}));
  connect(bui.QCoo_flow,conPum. QCoo_flow) annotation (Line(points={{7,168},{8,
          168},{8,160},{-350,160},{-350,-190.8},{-46.0308,-190.8}},
        color={0,0,127}));
  connect(TDisWatSup1.port_b,dis. port_aDisSup) annotation (Line(points={{-80,136},
          {-80,140},{-20,140}}, color={0,127,255}));
  connect(dis.port_bDisSup,TDisWatRet1. port_a)
    annotation (Line(points={{20,140},{80,140},{80,136}}, color={0,127,255}));
  connect(TDisWatSup.port_b,supDisPluFlo. port_a)
    annotation (Line(points={{-80,30},{-80,80}}, color={0,127,255}));
  connect(supDisPluFlo.port_b,TDisWatSup1. port_a) annotation (Line(points={{-80,100},
          {-80,116}},                color={0,127,255}));
  connect(TDisWatRet1.port_b,retDisPluFlo. port_a)
    annotation (Line(points={{80,116},{80,100}}, color={0,127,255}));
  connect(pipeGroundCouplingMulti[1:(nBui+1)].heatPorts[1],dis. heatPorts)
    annotation (Line(points={{1,93},{1,94},{0.4,94},{0.4,137.8}},
        color={127,0,0}));
  connect(supDisPluFlo.heatPort,pipeGroundCouplingMulti [nBui + 2].heatPorts[1])
    annotation (Line(points={{-70,90},{1,90},{1,93}},
        color={191,0,0}));
  connect(retDisPluFlo.heatPort,pipeGroundCouplingMulti [nBui + 3].heatPorts[1])
    annotation (Line(points={{70,90},{1,90},{1,93}},                     color={
          191,0,0}));
  connect(bui.PCoo, PHeaPump.u) annotation (Line(points={{12,187},{120,187},{120,
          230},{138,230}}, color={0,0,127}));
  connect(bui.PPum, PPumETS.u) annotation (Line(points={{12,183},{120,183},{120,
          170},{138,170}}, color={0,0,127}));
  connect(retDisPluFlo.port_b, pumDis.port_a)
    annotation (Line(points={{80,80},{80,-50}}, color={0,127,255}));
  connect(bui.port_bSerAmb, dis.ports_aCon) annotation (Line(points={{10,180},{12,
          180},{12,150},{12,150}}, color={0,127,255}));
  connect(bui.port_aSerAmb, dis.ports_bCon) annotation (Line(points={{-10,180},{
          -12,180},{-12,150}}, color={0,127,255}));
  connect(mPla.y, pla.mPum_flow) annotation (Line(points={{-219,30},{-180,30},{
          -180,4.66667},{-161.333,4.66667}}, color={0,0,127}));
  annotation (Diagram(
    coordinateSystem(preserveAspectRatio=false, extent={{-360,-260},{360,260}})),
      Documentation(revisions="<html>
<ul>
<li>
March 18, 2024, by David Blum:<br/>
Updated use of <code>datDis</code> for min and max loop temperatures.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/3697\">issue 3697</a>.
</li>
<li>
December 12, 2023, by Ettore Zanetti:<br/>
Changed to preconfigured pump model,
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/3431\">issue 3431</a>.
</li>
<li>
June 2, 2023, by Michael Wetter:<br/>
Added units to <code>conVio</code>.
</li>
<li>
November 16, 2022, by Michael Wetter:<br/>
Set correct nominal pressure for distribution pump.
</li>
<li>
February 23, 2021, by Antoine Gautier:<br/>
Refactored with base classes from the <code>DHC</code> package.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1769\">
issue 1769</a>.
</li>
<li>
January 16, 2020, by Michael Wetter:<br/>
Added documentation.
</li>
</ul>
</html>", info="<html>
<p>
Partial model that is used by the reservoir network models.
The reservoir network models extend this model, add controls,
and configure some component sizes.
</p>
</html>"));
end SinglePlant;
