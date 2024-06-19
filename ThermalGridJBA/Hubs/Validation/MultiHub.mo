within ThermalGridJBA.Hubs.Validation;
model MultiHub "Multiple prosumer hubs in a district loop"
  extends Modelica.Icons.Example;
  package Medium=Buildings.Media.Water
    "Medium model";

  parameter Integer nBui=3 "Number of buildings";
  parameter String filNam[nBui]={
    "modelica://ThermalGridJBA/Resources/Data/Hubs/1569.mos",
    "modelica://ThermalGridJBA/Resources/Data/Hubs/1676.mos",
    "modelica://ThermalGridJBA/Resources/Data/Hubs/1560.mos"}
    "Library paths of the files with thermal loads as time series";
  parameter Modelica.Units.SI.MassFlowRate mDis_flow_nominal=50 "Nominal mass flow rate of district";
  parameter Modelica.Units.SI.Temperature TDis_nominal=273.15+15 "Nominal temperature of district supply";

  ThermalGridJBA.Hubs.ConnectedETS bui[nBui](
    redeclare final package MediumSer = Medium,
    redeclare final package MediumBui = Medium,
    each allowFlowReversalSer=true,
    each THotWatSup_nominal=322.15,
    final filNam=filNam)
    annotation (Placement(transformation(extent={{10,40},{30,60}})));

  Buildings.DHC.Networks.Distribution1Pipe_R dis(
    redeclare final package Medium = Medium,
    nCon=nBui,
    show_TOut=true,
    mDis_flow_nominal=mDis_flow_nominal,
    mCon_flow_nominal=fill(mDis_flow_nominal, nBui),
    lDis=fill(1, nBui),
    lEnd=1) annotation (Placement(transformation(extent={{0,0},{40,20}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow mov(
    redeclare final package Medium = Medium,
    addPowerToMedium=false,
    m_flow_nominal=mDis_flow_nominal)
    annotation (Placement(transformation(extent={{30,-90},{10,-70}})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium = Medium,
    nPorts=1)
    annotation (Placement(transformation(extent={{100,-90},{80,-70}})));
  Buildings.DHC.ETS.BaseClasses.Junction jun1(
    redeclare final package Medium = Medium,
    m_flow_nominal={-mDis_flow_nominal,mDis_flow_nominal,mDis_flow_nominal})
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-20,-10})));
  Buildings.DHC.ETS.BaseClasses.Junction jun2(
    redeclare final package Medium = Medium,
    m_flow_nominal={-mDis_flow_nominal,-mDis_flow_nominal,mDis_flow_nominal})
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-20,-50})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow mov1(
    redeclare final package Medium = Medium,
    addPowerToMedium=false,
    m_flow_nominal=mDis_flow_nominal)
    annotation (Placement(transformation(extent={{-50,-60},{-70,-40}})));
  Buildings.Fluid.HeatExchangers.Heater_T hea(
    redeclare final package Medium = Medium,
    m_flow_nominal=mDis_flow_nominal,
    dp_nominal=0)
    annotation (Placement(transformation(extent={{-70,-20},{-50,0}})));
  Modelica.Blocks.Sources.Constant TDis(k=TDis_nominal)
    annotation (Placement(transformation(extent={{-120,0},{-100,20}})));
  Modelica.Blocks.Sources.Constant mDis(k=mDis_flow_nominal)
    annotation (Placement(transformation(extent={{-120,-40},{-100,-20}})));
equation
  connect(dis.ports_bCon, bui.port_aSerAmb) annotation (Line(points={{8,20},{4,20},
          {4,50},{10,50}}, color={0,127,255}));
  connect(bui.port_bSerAmb, dis.ports_aCon) annotation (Line(points={{30,50},{36,
          50},{36,20},{32,20}}, color={0,127,255}));
  connect(dis.port_bDisSup, mov.port_a) annotation (Line(points={{40,10},{50,10},
          {50,-80},{30,-80}}, color={0,127,255}));
  connect(mov.port_a, bou.ports[1])
    annotation (Line(points={{30,-80},{80,-80}}, color={0,127,255}));
  connect(jun1.port_1, dis.port_aDisSup)
    annotation (Line(points={{-20,0},{-20,10},{0,10}}, color={0,127,255}));
  connect(jun2.port_2, mov.port_b) annotation (Line(points={{-20,-60},{-20,-80},
          {10,-80}}, color={0,127,255}));
  connect(jun2.port_1, jun1.port_2)
    annotation (Line(points={{-20,-40},{-20,-20}}, color={0,127,255}));
  connect(mov1.port_a, jun2.port_3)
    annotation (Line(points={{-50,-50},{-30,-50}}, color={0,127,255}));
  connect(hea.port_b, jun1.port_3)
    annotation (Line(points={{-50,-10},{-30,-10}}, color={0,127,255}));
  connect(mov1.port_b, hea.port_a) annotation (Line(points={{-70,-50},{-80,-50},
          {-80,-10},{-70,-10}}, color={0,127,255}));
  connect(TDis.y, hea.TSet) annotation (Line(points={{-99,10},{-80,10},{-80,-2},
          {-72,-2}}, color={0,0,127}));
  connect(mDis.y, mov.m_flow_in)
    annotation (Line(points={{-99,-30},{20,-30},{20,-68}}, color={0,0,127}));
  connect(mDis.y, mov1.m_flow_in)
    annotation (Line(points={{-99,-30},{-60,-30},{-60,-38}}, color={0,0,127}));
annotation(experiment(
      StopTime=864000,
      Interval=60,
      Tolerance=1e-06));
end MultiHub;
