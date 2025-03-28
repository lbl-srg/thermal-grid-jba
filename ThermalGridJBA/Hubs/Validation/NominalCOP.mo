within ThermalGridJBA.Hubs.Validation;
model NominalCOP
  "Model computing nominal COP from the heat recovery chiller"
  extends Modelica.Icons.Example;
  package Medium=Buildings.Media.Water
    "Medium model";
  parameter ThermalGridJBA.Data.BuildingSetPoints datBuiSet
    annotation (Placement(transformation(extent={{-20,80},{0,100}})));
  parameter Modelica.Units.SI.ThermodynamicTemperature THexEntCon_nominal =
    273.15+25
    "Nominal hex entering temperature when condenser connected to district";
  parameter Modelica.Units.SI.ThermodynamicTemperature THexEntEva_nominal =
    273.15+9.5
    "Nominal hex entering temperature when evaporator connected to district";

  Buildings.Fluid.HeatPumps.ModularReversible.LargeScaleWaterToWater chi(
    allowDifferentDeviceIdentifiers=true,
    use_intSafCtr=false,
    final dTCon_nominal=datBuiSet.dTHeaWat_nominal,
    final dTEva_nominal=datBuiSet.dTChiWat_nominal,
    final QHea_flow_nominal=93.2e3,
    TConHea_nominal=datBuiSet.THeaWatSup_nominal,
    TEvaHea_nominal=datBuiSet.TChiWatSup_nominal,
    redeclare
      Buildings.Fluid.HeatPumps.ModularReversible.Data.TableData2D.EN14511.WAMAK_WaterToWater_220kW
      datTabHea,
    redeclare
      Buildings.Fluid.Chillers.ModularReversible.Data.TableData2D.EN14511.Carrier30XWP1012_1MW
      datTabCoo,
    redeclare package MediumCon = Medium,
    redeclare package MediumEva = Medium,
    final QCoo_flow_nominal=-62.1e3,
    TConCoo_nominal=datBuiSet.THeaWatSup_nominal,
    final dpCon_nominal(displayUnit="Pa") = 0,
    TEvaCoo_nominal=datBuiSet.TChiWatSup_nominal,
    final dpEva_nominal(displayUnit="Pa") = 0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState)
    "Heat recovery chiller"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Buildings.Fluid.Sources.MassFlowSource_T souCon(
    redeclare final package Medium = Medium,
    final m_flow=chi.mCon_flow_nominal,
    use_T_in=true,
    nPorts=1) "Source for condenser"
    annotation (Placement(transformation(extent={{-80,40},{-60,60}})));
  Buildings.Fluid.Sources.MassFlowSource_T souEva(
    redeclare final package Medium = Medium,
    final m_flow=chi.mEva_flow_nominal,
    use_T_in=true,
    nPorts=1) "Source for evaporator"
    annotation (Placement(transformation(extent={{80,-80},{60,-60}})));
  Buildings.Fluid.Sources.Boundary_pT sinEva(
    redeclare package Medium = Medium,
    p(displayUnit="bar"),
    nPorts=1) "Sink for evaporator" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-70,-70})));
  Buildings.Fluid.Sources.Boundary_pT sinCon(
    redeclare package Medium = Medium,
    p(displayUnit="bar"),
    nPorts=1) "Sink for condenser" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={70,50})));
  Modelica.Blocks.Sources.Constant y(k=1)
    annotation (Placement(transformation(extent={{-80,10},{-60,30}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TConEnt(
    redeclare final package Medium = Medium,
    m_flow_nominal=chi.mCon_flow_nominal,
    tau=0) "Sensor at the condenser inlet"
    annotation (Placement(transformation(extent={{-50,40},{-30,60}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TConLvg(
    redeclare final package Medium = Medium,
    m_flow_nominal=chi.mCon_flow_nominal,
    tau=0) "Temperature sensor at the condenser outlet"
    annotation (Placement(transformation(extent={{30,40},{50,60}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TEvaEnt(
    redeclare final package Medium = Medium,
    m_flow_nominal=chi.mEva_flow_nominal,
    tau=0) "Sensor at the evaporator inlet"
    annotation (Placement(transformation(extent={{50,-80},{30,-60}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort TEvaLvg(
    redeclare final package Medium = Medium,
    m_flow_nominal=chi.mEva_flow_nominal,
    tau=0) "Sensor at the evaporator inlet"
    annotation (Placement(transformation(extent={{-30,-80},{-50,-60}})));
  Modelica.Blocks.Sources.TimeTable setTConEnt(table=[0,datBuiSet.THeaWatRet_nominal;
        1,datBuiSet.THeaWatRet_nominal; 1,datBuiSet.THeaWatRet_nominal; 2,
        datBuiSet.THeaWatRet_nominal; 2,THexEntCon_nominal; 3,
        THexEntCon_nominal])
    "Set the temperature for the fluid entering the condenser"
    annotation (Placement(transformation(extent={{-120,40},{-100,60}})));
  Modelica.Blocks.Sources.BooleanConstant hea(final k=true)
    "Use the heating mode to use the heat pump performance map"
    annotation (Placement(transformation(extent={{-80,-30},{-60,-10}})));
  Modelica.Blocks.Sources.TimeTable setTEvaEnt(table=[0,THexEntEva_nominal; 1,
        THexEntEva_nominal; 1,datBuiSet.TChiWatRet_nominal; 2,datBuiSet.TChiWatRet_nominal;
        2,datBuiSet.TChiWatRet_nominal; 3,datBuiSet.TChiWatRet_nominal])
    "Set the temperature for the fluid entering the evaporator"
    annotation (Placement(transformation(extent={{60,-40},{80,-20}})));
equation
  connect(hea.y, chi.hea) annotation (Line(points={{-59,-20},{-40,-20},{-40,-2.1},
          {-11.1,-2.1}}, color={255,0,255}));
  connect(y.y, chi.ySet) annotation (Line(points={{-59,20},{-40,20},{-40,2},{-26,
          2},{-26,1.9},{-11.1,1.9}}, color={0,0,127}));
  connect(souCon.ports[1], TConEnt.port_a)
    annotation (Line(points={{-60,50},{-50,50}}, color={0,127,255}));
  connect(TConEnt.port_b, chi.port_a1) annotation (Line(points={{-30,50},{-20,50},
          {-20,6},{-10,6}}, color={0,127,255}));
  connect(chi.port_b1, TConLvg.port_a) annotation (Line(points={{10,6},{20,6},{20,
          50},{30,50}}, color={0,127,255}));
  connect(TConLvg.port_b, sinCon.ports[1])
    annotation (Line(points={{50,50},{60,50}}, color={0,127,255}));
  connect(souEva.ports[1], TEvaEnt.port_a)
    annotation (Line(points={{60,-70},{50,-70}}, color={0,127,255}));
  connect(TEvaEnt.port_b, chi.port_a2) annotation (Line(points={{30,-70},{20,-70},
          {20,-6},{10,-6}}, color={0,127,255}));
  connect(chi.port_b2, TEvaLvg.port_a) annotation (Line(points={{-10,-6},{-20,-6},
          {-20,-70},{-30,-70}}, color={0,127,255}));
  connect(TEvaLvg.port_b, sinEva.ports[1])
    annotation (Line(points={{-50,-70},{-60,-70}}, color={0,127,255}));
  connect(setTConEnt.y, souCon.T_in) annotation (Line(points={{-99,50},{-92,50},
          {-92,54},{-82,54}}, color={0,0,127}));
  connect(setTEvaEnt.y, souEva.T_in) annotation (Line(points={{81,-30},{90,-30},
          {90,-66},{82,-66}}, color={0,0,127}));
  annotation(experiment(
StartTime=0,
StopTime=3,
Tolerance=1e-06),
Documentation(info="<html>
<p>
This model finds the COP of the specified heat pump under the following
operational modes:
</p>
<ul>
<li>
From 0 - 1 s, cooling rejection;
</li>
<li>
From 1 - 2 s, simultaneous heating and cooling;
</li>
<li>
From 2 - 3 s, heat rejection.
</li>
</ul>
</html>"));
end NominalCOP;
