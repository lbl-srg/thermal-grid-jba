within ThermalGridJBA.CentralPlants.Validation;
model CentralPlant "Validation model for central plant"
  extends Modelica.Icons.Example;
  package MediumW = Buildings.Media.Water "Water";
  parameter Modelica.Units.SI.MassFlowRate mPumDis_flow_nominal=600
    "Nominal mass flow rate of main distribution pump";
  //parameter Integer nGenMod=4 "Number of generation modules";
  parameter Real mPlaWat_flow_nominal(unit="kg/s")=mPumDis_flow_nominal
    "Nominal water mass flow rate to each module";
  final parameter Modelica.Units.SI.TemperatureDifference dT_nominal = 4
    "Design temperature difference for central plant";

  ThermalGridJBA.CentralPlants.CentralPlant cenPla(
    mWat_flow_nominal=mPlaWat_flow_nominal,
    mHexGly_flow_nominal=mPlaWat_flow_nominal,
    mWat_flow_min=0.105*mPlaWat_flow_nominal,
    mHpGly_flow_nominal=mPlaWat_flow_nominal,
    QHeaPumHea_flow_nominal=mPlaWat_flow_nominal*4186*dT_nominal,
    QHeaPumCoo_flow_nominal=-mPlaWat_flow_nominal*4186*dT_nominal,
    TConInMin=291.15,
    TEvaInMax=289.65)
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));
  Buildings.Fluid.Sources.Boundary_pT sou(
    redeclare package Medium = MediumW,
    use_T_in=true,
    nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{-30,-10},{-10,10}})));
  Buildings.Fluid.Sources.Boundary_ph sin(redeclare package Medium =
        MediumW, nPorts=1) "Sink"
    annotation (Placement(transformation(extent={{80,-10},{60,10}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(final k=mPumDis_flow_nominal)
    "District pump speed"
    annotation (Placement(transformation(extent={{20,60},{40,80}})));

  Buildings.Controls.OBC.CDL.Reals.Sources.Sin disPum(freqHz=1/(24*365*3600))
    "District pump speed"
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.CivilTime civTim
    annotation (Placement(transformation(extent={{-80,20},{-60,40}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Sin mixWatTem(
    amplitude=6,
    freqHz=1/(24*365*3600),
    offset=273.15 + 18) "Mixed water temperature"
    annotation (Placement(transformation(extent={{-80,-50},{-60,-30}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Sin dryBul(
    amplitude=20,
    freqHz=1/(24*365*3600),
    offset=273.15 + 10) "Dry bulb temperature"
    annotation (Placement(transformation(extent={{-80,-80},{-60,-60}})));
equation
  connect(sou.ports[1], cenPla.port_a)
    annotation (Line(points={{-10,0},{20,0}},  color={0,127,255}));
  connect(cenPla.port_b, sin.ports[1])
    annotation (Line(points={{40,0},{60,0}}, color={0,127,255}));
  connect(disPum.y, gai.u)
    annotation (Line(points={{-58,70},{18,70}}, color={0,0,127}));
  connect(disPum.y, cenPla.uDisPum) annotation (Line(points={{-58,70},{10,70},{10,
          9},{18,9}},      color={0,0,127}));
  connect(civTim.y, cenPla.uSolTim) annotation (Line(points={{-58,30},{4,30},{4,
          7},{18,7}},       color={0,0,127}));
  connect(mixWatTem.y, sou.T_in) annotation (Line(points={{-58,-40},{-40,-40},{-40,
          4},{-32,4}},                     color={0,0,127}));
  connect(mixWatTem.y, cenPla.TMixAve) annotation (Line(points={{-58,-40},{6,-40},
          {6,3},{18,3}},    color={0,0,127}));
  connect(dryBul.y, cenPla.TDryBul) annotation (Line(points={{-58,-70},{10,-70},
          {10,-7},{18,-7}},                  color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=31536000,
      Interval=3600,
      Tolerance=1e-05,
      __Dymola_Algorithm="Cvode"));
end CentralPlant;
