within ThermalGridJBA.CentralPlants.BaseClasses.Validation;
model Borefield "Validation model for borefield"
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Water";
  parameter Modelica.Units.SI.MassFlowRate mPer_flow_nominal=borFie.mPer_flow_nominal
    "Nominal mass flow rate for perimeter";
  parameter Modelica.Units.SI.MassFlowRate mCen_flow_nominal=borFie.mCen_flow_nominal
    "Nominal mass flow rate for center";

  Buildings.Fluid.Sources.MassFlowSource_T souPer(
    redeclare package Medium = Medium,
    m_flow=mPer_flow_nominal,
    use_T_in=false,
    nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{-80,10},{-60,30}})));
  Buildings.Fluid.Sources.Boundary_ph sin(
    redeclare package Medium = Medium, nPorts=2)
              "Sink"
    annotation (Placement(transformation(extent={{94,-10},{74,10}})));

  Buildings.Fluid.Sources.MassFlowSource_T souCen(
    redeclare package Medium = Medium,
    m_flow=mCen_flow_nominal,
    use_T_in=false,
    nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{-80,-30},{-60,-10}})));
  ThermalGridJBA.CentralPlants.BaseClasses.Borefield borFie "Borefield"
    annotation (Placement(transformation(extent={{-12,-10},{8,10}})));
  Buildings.Fluid.Sensors.HeatMeter senHeaFloPer(
    redeclare package Medium = Medium,
    m_flow_nominal=mPer_flow_nominal,
    tau=0) "Heat flow rate sensor"
    annotation (Placement(transformation(extent={{20,20},{40,40}})));
  Buildings.Fluid.Sensors.HeatMeter senHeaFloCen(
    redeclare package Medium = Medium,
    m_flow_nominal=mCen_flow_nominal,
    tau=0) "Heat flow rate sensor"
    annotation (Placement(transformation(extent={{20,-30},{40,-10}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemPer(
    redeclare package Medium = Medium,
    m_flow_nominal=mPer_flow_nominal,
    tau=0) "Temperature sensor"
    annotation (Placement(transformation(extent={{-50,10},{-30,30}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemCen(
    redeclare package Medium = Medium,
    m_flow_nominal=mCen_flow_nominal,
    tau=0) "Temperature sensor"
    annotation (Placement(transformation(extent={{-50,-30},{-30,-10}})));
equation
  connect(borFie.portPer_a, senTemPer.port_b) annotation (Line(points={{-12,8},{
          -20,8},{-20,20},{-30,20}}, color={0,127,255}));
  connect(senTemPer.port_a, souPer.ports[1])
    annotation (Line(points={{-50,20},{-60,20}}, color={0,127,255}));
  connect(borFie.portCen_a, senTemCen.port_b) annotation (Line(points={{-12,-8},
          {-20,-8},{-20,-20},{-30,-20}}, color={0,127,255}));
  connect(senTemCen.port_a, souCen.ports[1])
    annotation (Line(points={{-50,-20},{-60,-20}}, color={0,127,255}));
  connect(senTemPer.T, senHeaFloPer.TExt)
    annotation (Line(points={{-40,31},{-40,36},{18,36}}, color={0,0,127}));
  connect(borFie.portPer_b, senHeaFloPer.port_a) annotation (Line(points={{8,8},
          {12,8},{12,30},{20,30}}, color={0,127,255}));
  connect(senTemCen.T, senHeaFloCen.TExt) annotation (Line(points={{-40,-9},{-40,
          -4},{-16,-4},{-16,-14},{18,-14}}, color={0,0,127}));
  connect(borFie.portCen_b, senHeaFloCen.port_a) annotation (Line(points={{7.8,
          -8},{14,-8},{14,-20},{20,-20}}, color={0,127,255}));
  connect(senHeaFloPer.port_b, sin.ports[1]) annotation (Line(points={{40,30},{
          62,30},{62,-1},{74,-1}}, color={0,127,255}));
  connect(senHeaFloCen.port_b, sin.ports[2]) annotation (Line(points={{40,-20},
          {64,-20},{64,1},{74,1}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=8640000,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"));
end Borefield;
