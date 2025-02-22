within ThermalGridJBA.Networks.Validation;
model MultiHub "Multiple prosumer hubs in a district loop"
  extends Modelica.Icons.Example;
  package Medium=Buildings.Media.Water
    "Medium model";

  parameter Integer nBui=3 "Number of buildings";
  parameter Modelica.Units.SI.MassFlowRate mDis_flow_nominal=
    sum(bui[:].ets.hex.m2_flow_nominal)*1.1
    "Nominal mass flow rate of district";
  parameter Modelica.Units.SI.Temperature TDis_nominal=273.15+15 "Nominal temperature of district supply";

  parameter String filNam[nBui] =
    {"modelica://ThermalGridJBA/Resources/Data/Consumptions/CA.mos",
     "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB.mos",
     "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD.mos"}
    "Array of building load profile file names";

  ThermalGridJBA.Hubs.ConnectedETS bui[nBui](
    redeclare final package MediumSer = Medium,
    redeclare final package MediumBui = Medium,
    final filNam = filNam,
    each allowFlowReversalSer=true)
    annotation (Placement(transformation(extent={{40,40},{60,60}})));

  Buildings.DHC.Networks.Distribution1Pipe_R dis(
    redeclare final package Medium = Medium,
    nCon=nBui,
    show_TOut=true,
    mDis_flow_nominal=mDis_flow_nominal,
    mCon_flow_nominal=fill(mDis_flow_nominal, nBui),
    lDis=fill(1, nBui),
    lEnd=1) annotation (Placement(transformation(extent={{30,0},{70,20}})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium = Medium, nPorts=1)
    annotation (Placement(transformation(extent={{-30,-80},{-50,-60}})));
  Modelica.Blocks.Sources.Constant mDis(k=mDis_flow_nominal)
    annotation (Placement(transformation(extent={{-90,40},{-70,60}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTPlaLvg(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mDis_flow_nominal) "Fluid temperature leaving plant"
                                      annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={0,10})));
  ThermalGridJBA.Networks.IdealHeatingCoolingPlant pla(
    redeclare final package Medium = Medium,
    m_flow_nominal=mDis_flow_nominal,
    dp_nominal=4000000,
    TLooMin=TDis_nominal - 1,
    TLooMax=TDis_nominal + 1,
    dTOff=0.5) annotation (Placement(transformation(extent={{-50,0},{-30,20}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTPlaEnt(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mDis_flow_nominal)
    "Fluid temperature entering plant" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-80,10})));
equation
  connect(dis.ports_bCon, bui.port_aSerAmb) annotation (Line(points={{38,20},{34,
          20},{34,50},{40,50}},
                           color={0,127,255}));
  connect(bui.port_bSerAmb, dis.ports_aCon) annotation (Line(points={{60,50},{66,
          50},{66,20},{62,20}}, color={0,127,255}));
  connect(senTPlaLvg.port_b, dis.port_aDisSup)
    annotation (Line(points={{10,10},{30,10}}, color={0,127,255}));
  connect(pla.port_bSerAmb, senTPlaLvg.port_a) annotation (Line(points={{-30,
          11.3333},{-18,11.3333},{-18,10},{-10,10}},
                                            color={0,127,255}));
  connect(senTPlaEnt.port_b, pla.port_aSerAmb) annotation (Line(points={{-70,10},
          {-54,10},{-54,11.3333},{-50,11.3333}}, color={0,127,255}));
  connect(dis.port_bDisSup, senTPlaEnt.port_a) annotation (Line(points={{70,10},
          {90,10},{90,-40},{-94,-40},{-94,10},{-90,10}}, color={0,127,255}));
  connect(mDis.y, pla.mPum_flow) annotation (Line(points={{-69,50},{-58,50},{
          -58,14.6667},{-51.3333,14.6667}},
                                        color={0,0,127}));
  connect(bou.ports[1], senTPlaEnt.port_a) annotation (Line(points={{-50,-70},{-94,
          -70},{-94,10},{-90,10}}, color={0,127,255}));
annotation(experiment(
      StartTime=7776000,
      StopTime=8640000,
      Interval=60,
      Tolerance=1e-06),
  __Dymola_Commands(
      file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Networks/Validation/MultiHub.mos" "Simulate and plot"),
  Documentation(info="
<html>
<p>
This model tests two things:
(a) parameterisation of an array of
<a href=\"modelica://ThermalGridJBA.Hubs.ConnectedETS\">
ThermalGridJBA.Hubs.ConnectedETS</a>,
(b) usage of
<a href=\"modelica://ThermalGridJBA.Networks.IdealHeatingCoolingPlant\">
ThermalGridJBA.Networks.IdealHeatingCoolingPlant</a>.
</p>
</html>"));
end MultiHub;
