within ThermalGridJBA.Hubs.Validation;
model MultiHub "Multiple prosumer hubs in a district loop"
  extends Modelica.Icons.Example;
  package Medium=Buildings.Media.Water
    "Medium model";

  parameter Integer nBui=3 "Number of buildings";
  parameter Modelica.Units.SI.MassFlowRate mDis_flow_nominal=
    sum(bui[:].ets.hex.m2_flow_nominal)*2
    "Nominal mass flow rate of district";
  parameter Modelica.Units.SI.Temperature TDis_nominal=273.15+15 "Nominal temperature of district supply";

  ThermalGridJBA.Hubs.ConnectedETS bui[nBui](
    redeclare final package MediumSer = Medium,
    redeclare final package MediumBui = Medium,
    final datBui={
      ThermalGridJBA.Data.Individual.B1569(),
      ThermalGridJBA.Data.Individual.B1380(),
      ThermalGridJBA.Data.Individual.B1560()},
    each allowFlowReversalSer=true,
    each THotWatSup_nominal=322.15)
    annotation (Placement(transformation(extent={{10,40},{30,60}})));

  Buildings.DHC.Networks.Distribution1Pipe_R dis(
    redeclare final package Medium = Medium,
    nCon=nBui,
    show_TOut=true,
    mDis_flow_nominal=mDis_flow_nominal,
    mCon_flow_nominal=fill(mDis_flow_nominal, nBui),
    lDis=fill(1, nBui),
    lEnd=1) annotation (Placement(transformation(extent={{0,0},{40,20}})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium = Medium, nPorts=1)
    annotation (Placement(transformation(extent={{100,-80},{80,-60}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow mov1(
    redeclare final package Medium = Medium,
    addPowerToMedium=false,
    m_flow_nominal=mDis_flow_nominal)
    annotation (Placement(transformation(extent={{20,-80},{0,-60}})));
  Modelica.Blocks.Sources.Constant TDis(k=TDis_nominal)
    annotation (Placement(transformation(extent={{-150,0},{-130,20}})));
  Modelica.Blocks.Sources.Constant mDis(k=mDis_flow_nominal)
    annotation (Placement(transformation(extent={{-150,-40},{-130,-20}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTPlaLvg(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mDis_flow_nominal)
    "Fluid temperature leaving plant" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-30,10})));
  Buildings.Fluid.Interfaces.PrescribedOutlet outCon(
    redeclare final package Medium = Medium,
    final mWatMax_flow=0,
    final mWatMin_flow=0,
    final T_start=TDis_nominal,
    final use_TSet=true,
    final use_X_wSet=false,
    final X_start=Medium.X_default,
    final m_flow_nominal=mDis_flow_nominal)
                   "Model to set outlet conditions"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
equation
  connect(dis.ports_bCon, bui.port_aSerAmb) annotation (Line(points={{8,20},{4,20},
          {4,50},{10,50}}, color={0,127,255}));
  connect(bui.port_bSerAmb, dis.ports_aCon) annotation (Line(points={{30,50},{36,
          50},{36,20},{32,20}}, color={0,127,255}));
  connect(mDis.y, mov1.m_flow_in)
    annotation (Line(points={{-129,-30},{10,-30},{10,-58}},  color={0,0,127}));
  connect(senTPlaLvg.port_b, dis.port_aDisSup)
    annotation (Line(points={{-20,10},{0,10}}, color={0,127,255}));
  connect(mov1.port_a, bou.ports[1])
    annotation (Line(points={{20,-70},{80,-70}}, color={0,127,255}));
  connect(dis.port_bDisSup, mov1.port_a) annotation (Line(points={{40,10},{50,10},
          {50,-70},{20,-70}}, color={0,127,255}));
  connect(outCon.port_b, senTPlaLvg.port_a)
    annotation (Line(points={{-60,10},{-40,10}}, color={0,127,255}));
  connect(outCon.TSet, TDis.y) annotation (Line(points={{-81,18},{-124,18},{-124,
          10},{-129,10}}, color={0,0,127}));
  connect(outCon.port_a, mov1.port_b) annotation (Line(points={{-80,10},{-90,10},
          {-90,-70},{0,-70}}, color={0,127,255}));
annotation(experiment(
      StartTime=7776000,
      StopTime=8640000,
      Interval=60,
      Tolerance=1e-06),
  __Dymola_Commands(
      file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Hubs/Validation/MultiHub.mos" "Simulate and plot"));
end MultiHub;
