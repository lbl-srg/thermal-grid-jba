within ThermalGridJBA.CentralPlants.BaseClasses;
model BorefieldSection "Section for a core or an edge of the borefield"
  extends Modelica.Blocks.Icons.Block;
  replaceable package Medium = Buildings.Media.Water "Water";
  parameter Real nDumSec
    "Number of dummy borefield section to next to actual section (dummy sections are used to compute boundary temperatures). 2 for the edge, and 4 for the core.";

  parameter Modelica.Units.SI.Temperature T_start
    "Initial temperature of the soil";
  parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Borefield.Template borFieDat
    "Borefield data"
    annotation (Placement(transformation(extent={{-140,120},{-120,140}})));
  parameter Integer nBorSec
    "Number of borefield sectors. It includes 2 modules and the number should be divisible by 3";

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QPer_flow(
    final unit="W")
    "Heat flow rate for center elements" annotation (Placement(transformation(
          extent={{200,120},{240,160}}), iconTransformation(extent={{100,40},{140,
            80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QCor_flow(
    final unit="W") "Heat flow rate for core elements"       annotation (
      Placement(transformation(extent={{200,90},{240,130}}), iconTransformation(
          extent={{100,10},{140,50}})));

  Buildings.Fluid.Geothermal.ZonedBorefields.TwoUTubes borFie(
    redeclare each final package Medium = Medium,
    each allowFlowReversal=true,
    show_T=true,
    each energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    each TExt0_start=T_start,
    each borFieDat=borFieDat,
    each dT_dz=0) "Borefield"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Fluid.Sources.Boundary_ph sin[2](
    redeclare each package Medium = Medium,
    each nPorts=1) "Sink"
    annotation (Placement(transformation(extent={{130,40},{110,60}})));
  Buildings.Fluid.Sources.MassFlowSource_T sou[2](
    redeclare each package Medium = Medium,
    each use_m_flow_in=true,
    each use_T_in=true,
    each nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{-10,44},{10,64}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloPer(redeclare each package
      Medium = Medium, each allowFlowReversal=false)
    "Mass flow rate entering borefield"
    annotation (Placement(transformation(extent={{-90,-10},{-70,10}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter floGai[2](each k=nDumSec)
    "Flow rate to the adjacent modules"
    annotation (Placement(transformation(extent={{-50,52},{-30,72}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemEntPer(
    redeclare final package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=borFieDat.conDat.mZon_flow_nominal[1],
    tau=0)
    "Temperature of waterflow entering borefield perimeter" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-110,0})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAveBorWalPer(
    final unit="K",
    displayUnit="degC")
    "Average borehole wall temperatures perimeter elements" annotation (Placement(transformation(
          extent={{200,-120},{240,-80}}),iconTransformation(extent={{100,-50},{140,
            -10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAveBorWalCen(
    final unit="K",
    displayUnit="degC") "Average borehole wall temperatures center elements"
                                                         annotation (
      Placement(transformation(extent={{200,-150},{240,-110}}),
                                                             iconTransformation(
          extent={{100,-80},{140,-40}})));
  Modelica.Fluid.Interfaces.FluidPort_a portPer_a(redeclare final package
      Medium = Medium)
    "Fluid connector for perimeter of borefield"                                      annotation (
      Placement(transformation(extent={{-210,50},{-190,70}}),
        iconTransformation(extent={{-110,70},{-90,90}})));
  Modelica.Fluid.Interfaces.FluidPort_a portCen_a(redeclare final package
      Medium = Medium) "Fluid connector for center of borefield"
                                                               annotation (
      Placement(transformation(extent={{-210,-70},{-190,-50}}),
        iconTransformation(extent={{-110,-90},{-90,-70}})));
  Modelica.Fluid.Interfaces.FluidPort_b portPer_b(redeclare final package
      Medium = Medium) "Fluid connector outlet of perimeter borefield zones"
    annotation (Placement(transformation(extent={{190,50},{210,70}}),
        iconTransformation(extent={{90,70},{110,90}})));
  Modelica.Fluid.Interfaces.FluidPort_b portCen_b(redeclare final package
      Medium = Medium) "Fluid connector for center of the borefield"
                                                                   annotation
    (Placement(transformation(extent={{190,-70},{210,-50}}),iconTransformation(
          extent={{88,-90},{108,-70}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemEntCen(
    redeclare final package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=borFieDat.conDat.mZon_flow_nominal[2],
    tau=0) "Temperature of waterflow entering borefield center"
                                                       annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-110,-60})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloCen(redeclare each package
      Medium = Medium, each allowFlowReversal=false)
    "Mass flow rate entering borefield"
    annotation (Placement(transformation(extent={{-90,-70},{-70,-50}})));
  Buildings.Fluid.Sensors.HeatMeter senHeaFloPer(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=borFieDat.conDat.mZon_flow_nominal[1],
    tau=0) "Heat flow rate sensor"
    annotation (Placement(transformation(extent={{150,-10},{170,10}})));
  Buildings.Fluid.Sensors.HeatMeter senHeaFloCen(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=borFieDat.conDat.mZon_flow_nominal[2],
    tau=0) "Heat flow rate sensor"
    annotation (Placement(transformation(extent={{152,-70},{172,-50}})));
equation
  connect(sou[1].ports[1], borFie.port_a[3]) annotation (Line(
      points={{10,54},{30,54},{30,0},{40,0}},
      color={0,127,255}));
  connect(sou[2].ports[1], borFie.port_a[4]) annotation (Line(
      points={{10,54},{20,54},{20,0},{40,0}},
      color={0,127,255}));
  connect(sin[1].ports[1], borFie.port_b[3]) annotation (Line(
      points={{110,50},{88,50},{88,0},{60,0}},
      color={0,127,255}));
  connect(sin[2].ports[1], borFie.port_b[4]) annotation (Line(
      points={{110,50},{80,50},{80,0},{60,0}},
      color={0,127,255}));
  connect(floGai.y,sou. m_flow_in)
    annotation (Line(points={{-28,62},{-12,62}},color={0,0,127}));
  connect(TAveBorWalPer, borFie.TBorAve[1]) annotation (Line(points={{220,-100},
          {70,-100},{70,4.4},{61,4.4}},
                                    color={0,0,127}));
  connect(TAveBorWalCen, borFie.TBorAve[2]) annotation (Line(points={{220,-130},
          {180,-130},{180,-110},{70,-110},{70,4.4},{61,4.4}},
                                                     color={0,0,127}));
  connect(senMasFloPer.m_flow, floGai[1].u)
    annotation (Line(points={{-80,11},{-80,62},{-52,62}}, color={0,0,127}));
  connect(senMasFloCen.m_flow, floGai[2].u) annotation (Line(points={{-80,-49},{
          -80,-40},{-64,-40},{-64,62},{-52,62}}, color={0,0,127}));
  connect(senMasFloPer.port_b, borFie.port_a[1])
    annotation (Line(points={{-70,0},{40,0}}, color={0,127,255}));
  connect(senMasFloCen.port_b, borFie.port_a[2]) annotation (Line(points={{-70,-60},
          {12,-60},{12,0},{40,0}}, color={0,127,255}));
  connect(senTemEntPer.T, sou[1].T_in) annotation (Line(points={{-110,11},{-110,
          40},{-20,40},{-20,58},{-12,58}}, color={0,0,127}));
  connect(senTemEntCen.T, sou[2].T_in) annotation (Line(points={{-110,-49},{-110,
          -34},{-20,-34},{-20,58},{-12,58}}, color={0,0,127}));
  connect(senTemEntCen.port_b,senMasFloCen. port_a)
    annotation (Line(points={{-100,-60},{-90,-60}}, color={0,127,255}));
  connect(senTemEntPer.port_b, senMasFloPer.port_a)
    annotation (Line(points={{-100,0},{-90,0}}, color={0,127,255}));
  connect(senHeaFloPer.port_b, portPer_b) annotation (Line(points={{170,0},{180,
          0},{180,60},{200,60}}, color={0,127,255}));
  connect(senHeaFloCen.port_b,portCen_b)
    annotation (Line(points={{172,-60},{200,-60}}, color={0,127,255}));
  connect(senHeaFloPer.TExt, senTemEntPer.T) annotation (Line(points={{148,6},{
          144,6},{144,28},{-110,28},{-110,11}}, color={0,0,127}));
  connect(senHeaFloCen.TExt,senTemEntCen. T) annotation (Line(points={{150,-54},
          {144,-54},{144,-34},{-110,-34},{-110,-49}}, color={0,0,127}));
  connect(senTemEntPer.port_a, portPer_a) annotation (Line(points={{-120,0},{
          -160,0},{-160,60},{-200,60}}, color={0,127,255}));
  connect(senTemEntCen.port_a,portCen_a)
    annotation (Line(points={{-120,-60},{-200,-60}}, color={0,127,255}));
  connect(senHeaFloPer.port_a, borFie.port_b[1])
    annotation (Line(points={{150,0},{60,0}}, color={0,127,255}));
  connect(senHeaFloCen.port_a, borFie.port_b[2]) annotation (Line(points={{152,
          -60},{80,-60},{80,0},{60,0}}, color={0,127,255}));
  connect(senHeaFloPer.Q_flow, QPer_flow)
    annotation (Line(points={{160,11},{160,140},{220,140}}, color={0,0,127}));
  connect(senHeaFloCen.Q_flow, QCor_flow) annotation (Line(points={{162,-49},{
          162,-34},{186,-34},{186,110},{220,110}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(extent={{-200,-160},{200,160}})),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end BorefieldSection;
