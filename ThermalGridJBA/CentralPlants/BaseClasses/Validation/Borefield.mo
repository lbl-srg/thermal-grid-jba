within ThermalGridJBA.CentralPlants.BaseClasses.Validation;
model Borefield "Validation model for borefield"
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Water";
  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal=600
    "Nominal mass flow rate";


  Buildings.Fluid.Sources.MassFlowSource_T souEdg(
    redeclare package Medium = Medium,
    m_flow=m_flow_nominal/2,
    use_T_in=false,
    nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{-60,10},{-40,30}})));
  Buildings.Fluid.Sources.Boundary_ph sin(
    redeclare package Medium = Medium,
    nPorts=2) "Sink"
    annotation (Placement(transformation(extent={{80,-10},{60,10}})));

  Buildings.Fluid.Sources.MassFlowSource_T souCor(
    redeclare package Medium = Medium,
    m_flow=m_flow_nominal/2,
    use_T_in=false,
    nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{-60,-30},{-40,-10}})));
  ThermalGridJBA.CentralPlants.BaseClasses.Borefield borFie(
    m_flow_nominal=m_flow_nominal) "Borefield"
    annotation (Placement(transformation(extent={{-8,-10},{12,10}})));
equation
  connect(borFie.portEdg_a, souEdg.ports[1]) annotation (Line(points={{-8,8},{-20,
          8},{-20,20},{-40,20}}, color={0,127,255}));
  connect(borFie.portCor_a, souCor.ports[1]) annotation (Line(points={{-8,-8},{-20,
          -8},{-20,-20},{-40,-20}}, color={0,127,255}));
  connect(borFie.portEdg_b, sin.ports[1]) annotation (Line(points={{12,8},{42,8},
          {42,-1},{60,-1}}, color={0,127,255}));
  connect(borFie.portCor_b, sin.ports[2]) annotation (Line(points={{11.8,-8},{
          36,-8},{36,0},{60,0},{60,1}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=8640000,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"));
end Borefield;
