within ThermalGridJBA.CentralPlants.Validation;
model CentralPlant "Validation model for central plant"
  extends Modelica.Icons.Example;
  package MediumW = Buildings.Media.Water "Water";
  parameter Modelica.Units.SI.MassFlowRate mPumDis_flow_nominal=600
    "Nominal mass flow rate of main distribution pump";
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
    TEvaHea_nominal=260.15,
    QHeaPumCoo_flow_nominal=-mPlaWat_flow_nominal*4186*dT_nominal,
    TConCoo_nominal=315.15,
    TConInMin=291.15,
    TEvaInMax=289.65)
    "Central plant"
    annotation (Placement(transformation(extent={{20,-50},{40,-30}})));
  Buildings.Fluid.Sources.MassFlowSource_T
                                      sou(
    redeclare package Medium = MediumW,
    m_flow=mPumDis_flow_nominal,
    use_T_in=true,
    nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{-48,-10},{-28,10}})));
  Buildings.Fluid.Sources.Boundary_ph sin(redeclare package Medium =
        MediumW, nPorts=1) "Sink"
    annotation (Placement(transformation(extent={{90,-10},{70,10}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(final k=mPumDis_flow_nominal)
    "District pump speed"
    annotation (Placement(transformation(extent={{20,60},{40,80}})));

  Buildings.Controls.OBC.CDL.Reals.Sources.Sin disPum(
    amplitude=0.4,                                    freqHz=1/(24*365*3600),
    offset=0.6)
    "District pump speed"
    annotation (Placement(transformation(extent={{-90,60},{-70,80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.CivilTime civTim
    annotation (Placement(transformation(extent={{-90,20},{-70,40}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Sin mixWatTem(
    amplitude=8,
    freqHz=1/(24*365*3600),
    phase=3.1415926535898,
    offset=273.15 + 17) "Mixed water temperature"
    annotation (Placement(transformation(extent={{-90,-30},{-70,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Sin dryBul(
    amplitude=20,
    freqHz=1/(24*365*3600),
    offset=273.15 + 10) "Dry bulb temperature"
    annotation (Placement(transformation(extent={{-90,-60},{-70,-40}})));
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    m_flow_nominal=mPlaWat_flow_nominal*{1,1,1},
    dp_nominal={1e4,0,0})
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Buildings.Fluid.FixedResistances.Junction jun1(
    redeclare package Medium = MediumW,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Entering,
    m_flow_nominal=mPlaWat_flow_nominal*{1,1,1},
    dp_nominal={0,0,1e4})
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(p=1)
    annotation (Placement(transformation(extent={{-52,-80},{-32,-60}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(p=-1)
    annotation (Placement(transformation(extent={{-52,-110},{-32,-90}})));
equation
  connect(disPum.y, gai.u)
    annotation (Line(points={{-68,70},{18,70}}, color={0,0,127}));
  connect(disPum.y, cenPla.uDisPum) annotation (Line(points={{-68,70},{10,70},{
          10,-31},{18,-31}},
                           color={0,0,127}));
  connect(civTim.y, cenPla.uSolTim) annotation (Line(points={{-68,30},{4,30},{4,
          -33},{18,-33}},   color={0,0,127}));
  connect(mixWatTem.y, sou.T_in) annotation (Line(points={{-68,-20},{-60,-20},{-60,
          4},{-50,4}},                     color={0,0,127}));
  connect(mixWatTem.y, cenPla.TMixAve) annotation (Line(points={{-68,-20},{6,-20},
          {6,-44},{18,-44}},color={0,0,127}));
  connect(dryBul.y, cenPla.TDryBul) annotation (Line(points={{-68,-50},{10,-50},
          {10,-29},{18,-29}},                color={0,0,127}));
  connect(sou.ports[1], jun.port_1)
    annotation (Line(points={{-28,0},{-20,0}}, color={0,127,255}));
  connect(jun.port_2, jun1.port_1)
    annotation (Line(points={{0,0},{40,0}}, color={0,127,255}));
  connect(jun1.port_2, sin.ports[1])
    annotation (Line(points={{60,0},{70,0}}, color={0,127,255}));
  connect(jun.port_3, cenPla.port_a) annotation (Line(points={{-10,-10},{-10,
          -40},{20,-40}}, color={0,127,255}));
  connect(cenPla.port_b, jun1.port_3)
    annotation (Line(points={{40,-40},{50,-40},{50,-10}}, color={0,127,255}));
  connect(cenPla.TLooMaxMea, addPar.y) annotation (Line(points={{18,-48},{-6,-48},
          {-6,-70},{-30,-70}}, color={0,0,127}));
  connect(addPar1.y, cenPla.TLooMinMea) annotation (Line(points={{-30,-100},{-4,
          -100},{-4,-52},{18,-52}}, color={0,0,127}));
  connect(mixWatTem.y, addPar.u) annotation (Line(points={{-68,-20},{-62,-20},{-62,
          -70},{-54,-70}}, color={0,0,127}));
  connect(mixWatTem.y, addPar1.u) annotation (Line(points={{-68,-20},{-62,-20},{
          -62,-100},{-54,-100}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-120},
            {100,100}})),                                        Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-100,-120},{100,100}})),
    experiment(
      StopTime=31536000,
      Interval=3600,
      Tolerance=1e-05,
      __Dymola_Algorithm="Cvode"));
end CentralPlant;
