within ThermalGridJBA.CentralPlants.BaseClasses;
model BorefieldSection "Section for a core or an edge of the borefield"
  extends Modelica.Blocks.Icons.Block;
  replaceable package Medium = Buildings.Media.Water "Water";
  parameter Real nDumSec
    "Number of dummy borefield sections next to actual section (dummy sections are used to compute boundary temperatures). 1 for the edge, and 2 for the core.";

  parameter Modelica.Units.SI.Temperature TSoi_start
    "Initial temperature of the soil";
  parameter Buildings.Fluid.Geothermal.ZonedBorefields.Data.Borefield.Template borFieDat
    "Borefield data"
    annotation (Placement(transformation(extent={{-140,120},{-120,140}})));
//  parameter Integer nBorSec
//    "Number of borefield sectors. It includes 2 modules and the number should be divisible by 3";

  parameter Modelica.Units.SI.PressureDifference dp_nominal(
    displayUnit="Pa") "Design pressure drop";
  parameter Modelica.Units.SI.MassFlowRate mPer_flow_nominal
    "Design mass flow rate for perimeter";
  parameter Modelica.Units.SI.MassFlowRate mCen_flow_nominal
    "Design mass flow rate for center";
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QPer_flow(
    final unit="W")
    "Heat flow rate for center elements" annotation (Placement(transformation(
          extent={{200,120},{240,160}}), iconTransformation(extent={{100,40},{140,
            80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QCor_flow(
    final unit="W") "Heat flow rate for core elements"
    annotation (
      Placement(transformation(extent={{200,90},{240,130}}), iconTransformation(
          extent={{100,10},{140,50}})));

  Buildings.Fluid.Geothermal.ZonedBorefields.TwoUTubes borFie(
    redeclare each final package Medium = Medium,
    each allowFlowReversal=true,
    show_T=true,
    each energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    each TExt0_start=TSoi_start,
    each borFieDat=borFieDat,
    each dT_dz=0) "Borefield"
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Buildings.Fluid.Sources.Boundary_ph sin[2](
    redeclare each package Medium = Medium,
    each nPorts=1) "Sink"
    annotation (Placement(transformation(extent={{124,40},{104,60}})));
  Buildings.Fluid.Sources.MassFlowSource_T sou[2](
    redeclare each package Medium = Medium,
    each use_m_flow_in=true,
    each use_T_in=true,
    each nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{-70,44},{-50,64}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloPer(redeclare each package
      Medium = Medium, each allowFlowReversal=false)
    "Mass flow rate entering borefield"
    annotation (Placement(transformation(extent={{-150,-10},{-130,10}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter floGai[2](each k=nDumSec)
    "Flow rate to the adjacent modules"
    annotation (Placement(transformation(extent={{-110,52},{-90,72}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemEntPer(
    redeclare final package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=borFieDat.conDat.mZon_flow_nominal[1],
    tau=0)
    "Temperature of waterflow entering borefield perimeter" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,0})));

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
  Modelica.Fluid.Interfaces.FluidPort_a portPer_a(
    redeclare final package Medium = Medium)
    "Fluid connector for perimeter of borefield"                                      annotation (
      Placement(transformation(extent={{-210,50},{-190,70}}),
        iconTransformation(extent={{-110,70},{-90,90}})));
  Modelica.Fluid.Interfaces.FluidPort_a portCen_a(
    redeclare final package Medium = Medium)
    "Fluid connector for center of borefield"                  annotation (
      Placement(transformation(extent={{-210,-70},{-190,-50}}),
        iconTransformation(extent={{-110,-90},{-90,-70}})));
  Modelica.Fluid.Interfaces.FluidPort_b portPer_b(
    redeclare final package Medium = Medium)
    "Fluid connector outlet of perimeter borefield zones"
    annotation (Placement(transformation(extent={{190,50},{210,70}}),
        iconTransformation(extent={{90,70},{110,90}})));
  Modelica.Fluid.Interfaces.FluidPort_b portCen_b(
    redeclare final package Medium = Medium)
    "Fluid connector for center of the borefield"                  annotation
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
        origin={-170,-60})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloCen(
    redeclare each package Medium = Medium,
    each allowFlowReversal=false)
    "Mass flow rate entering borefield"
    annotation (Placement(transformation(extent={{-150,-70},{-130,-50}})));
  Buildings.Fluid.Sensors.HeatMeter senHeaFloPer(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=borFieDat.conDat.mZon_flow_nominal[1],
    tau=0) "Heat flow rate sensor"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Fluid.Sensors.HeatMeter senHeaFloCen(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=borFieDat.conDat.mZon_flow_nominal[2],
    tau=0) "Heat flow rate sensor"
    annotation (Placement(transformation(extent={{40,-70},{60,-50}})));
  Buildings.Fluid.Sensors.RelativePressure senRelPrePer(
    redeclare package Medium = Medium)
    "Pressure difference for perimeter loop (used due to MBL, issue 4199 that shows that pressure drops are wrongly calculated)"
    annotation (Placement(transformation(extent={{0,110},{-20,130}})));
  Buildings.Fluid.Sensors.RelativePressure senRelPreCen(
    redeclare package Medium = Medium)
    "Pressure difference for center loop (used due to MBL, issue 4199 that shows that pressure drops are wrongly calculated)"
    annotation (Placement(transformation(extent={{-2,70},{-22,90}})));
  Buildings.Fluid.Movers.BaseClasses.IdealSource ideSouPer(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_small=1E-4*mPer_flow_nominal,
    show_T=false,
    show_V_flow=false,
    control_m_flow=false,
    control_dp=true)
    "Ideal pressure source to set dp of borefield to zero (see MBL, issue 4199)"
    annotation (Placement(transformation(extent={{80,-10},{100,10}})));
  Buildings.Fluid.Movers.BaseClasses.IdealSource ideSouCen(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_small=1E-4*mCen_flow_nominal,
    show_T=false,
    show_V_flow=false,
    control_m_flow=false,
    control_dp=true)
    "Ideal pressure source to set dp of borefield to zero (see MBL, issue 4199)"
    annotation (Placement(transformation(extent={{80,-70},{100,-50}})));
  Buildings.Fluid.FixedResistances.PressureDrop resPer(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    show_T=false,
    m_flow_nominal=mPer_flow_nominal,
    dp_nominal=dp_nominal)
    "Flow resistance of perimeter borefield (modeled here because of MBL, issue 4199)"
    annotation (Placement(transformation(extent={{122,-10},{142,10}})));
  Buildings.Fluid.FixedResistances.PressureDrop resCen(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    show_T=false,
    m_flow_nominal=mCen_flow_nominal,
    dp_nominal=dp_nominal)
    "Flow resistance of center borefield (modeled here because of MBL, issue 4199)"
    annotation (Placement(transformation(extent={{120,-70},{140,-50}})));
equation
  connect(sou[1].ports[1], borFie.port_a[3]) annotation (Line(
      points={{-50,54},{-44,54},{-44,0},{-20,0}},
      color={0,127,255}));
  connect(sou[2].ports[1], borFie.port_a[4]) annotation (Line(
      points={{-50,54},{-40,54},{-40,0},{-20,0}},
      color={0,127,255}));
  connect(sin[1].ports[1], borFie.port_b[3]) annotation (Line(
      points={{104,50},{28,50},{28,0},{0,0}},
      color={0,127,255}));
  connect(sin[2].ports[1], borFie.port_b[4]) annotation (Line(
      points={{104,50},{20,50},{20,0},{0,0}},
      color={0,127,255}));
  connect(floGai.y,sou. m_flow_in)
    annotation (Line(points={{-88,62},{-72,62}},color={0,0,127}));
  connect(TAveBorWalPer, borFie.TBorAve[1]) annotation (Line(points={{220,-100},
          {10,-100},{10,4.4},{1,4.4}},
                                    color={0,0,127}));
  connect(TAveBorWalCen, borFie.TBorAve[2]) annotation (Line(points={{220,-130},
          {10,-130},{10,4.4},{1,4.4}},               color={0,0,127}));
  connect(senMasFloPer.m_flow, floGai[1].u)
    annotation (Line(points={{-140,11},{-140,62},{-112,62}},
                                                          color={0,0,127}));
  connect(senMasFloCen.m_flow, floGai[2].u) annotation (Line(points={{-140,-49},
          {-140,-40},{-124,-40},{-124,62},{-112,62}},
                                                 color={0,0,127}));
  connect(senMasFloPer.port_b, borFie.port_a[1])
    annotation (Line(points={{-130,0},{-20,0}},
                                              color={0,127,255}));
  connect(senMasFloCen.port_b, borFie.port_a[2]) annotation (Line(points={{-130,
          -60},{-48,-60},{-48,0},{-20,0}},
                                   color={0,127,255}));
  connect(senTemEntPer.T, sou[1].T_in) annotation (Line(points={{-170,11},{-170,
          40},{-80,40},{-80,58},{-72,58}}, color={0,0,127}));
  connect(senTemEntCen.T, sou[2].T_in) annotation (Line(points={{-170,-49},{-170,
          -34},{-80,-34},{-80,58},{-72,58}}, color={0,0,127}));
  connect(senTemEntCen.port_b,senMasFloCen. port_a)
    annotation (Line(points={{-160,-60},{-150,-60}},color={0,127,255}));
  connect(senTemEntPer.port_b, senMasFloPer.port_a)
    annotation (Line(points={{-160,0},{-150,0}},color={0,127,255}));
  connect(senHeaFloPer.TExt, senTemEntPer.T) annotation (Line(points={{38,6},{32,
          6},{32,28},{-170,28},{-170,11}},      color={0,0,127}));
  connect(senHeaFloCen.TExt,senTemEntCen. T) annotation (Line(points={{38,-54},{
          30,-54},{30,-34},{-170,-34},{-170,-49}},    color={0,0,127}));
  connect(senTemEntPer.port_a, portPer_a) annotation (Line(points={{-180,0},{-188,
          0},{-188,60},{-200,60}},      color={0,127,255}));
  connect(senTemEntCen.port_a,portCen_a)
    annotation (Line(points={{-180,-60},{-200,-60}}, color={0,127,255}));
  connect(senHeaFloPer.port_a, borFie.port_b[1])
    annotation (Line(points={{40,0},{0,0}},   color={0,127,255}));
  connect(senHeaFloCen.port_a, borFie.port_b[2]) annotation (Line(points={{40,-60},
          {20,-60},{20,0},{0,0}},       color={0,127,255}));
  connect(senHeaFloPer.Q_flow, QPer_flow)
    annotation (Line(points={{50,11},{50,140},{220,140}},   color={0,0,127}));
  connect(senHeaFloCen.Q_flow, QCor_flow) annotation (Line(points={{50,-49},{50,
          -34},{186,-34},{186,110},{220,110}},     color={0,0,127}));
  connect(senHeaFloPer.port_b, ideSouPer.port_a)
    annotation (Line(points={{60,0},{80,0}},   color={0,127,255}));
  connect(senHeaFloCen.port_b, ideSouCen.port_a)
    annotation (Line(points={{60,-60},{80,-60}},   color={0,127,255}));
  connect(ideSouPer.dp_in, senRelPrePer.p_rel) annotation (Line(points={{96,8},{
          96,106},{-10,106},{-10,111}}, color={0,0,127}));
  connect(ideSouCen.dp_in, senRelPreCen.p_rel) annotation (Line(points={{96,-52},
          {96,-20},{166,-20},{166,66},{-12,66},{-12,71}},color={0,0,127}));
  connect(senRelPrePer.port_a, borFie.port_b[1]) annotation (Line(points={{0,120},
          {14,120},{14,0},{0,0}},  color={0,127,255}));
  connect(senRelPreCen.port_a, borFie.port_b[2]) annotation (Line(points={{-2,80},
          {14,80},{14,0},{0,0}},  color={0,127,255}));
  connect(senRelPrePer.port_b, borFie.port_a[1]) annotation (Line(points={{-20,120},
          {-30,120},{-30,0},{-20,0}},
                                   color={0,127,255}));
  connect(senRelPreCen.port_b, borFie.port_a[2]) annotation (Line(points={{-22,80},
          {-36,80},{-36,0},{-20,0}},
                                  color={0,127,255}));
  connect(ideSouPer.port_b, resPer.port_a)
    annotation (Line(points={{100,0},{122,0}}, color={0,127,255}));
  connect(resPer.port_b, portPer_b) annotation (Line(points={{142,0},{180,0},{180,
          60},{200,60}}, color={0,127,255}));
  connect(ideSouCen.port_b, resCen.port_a)
    annotation (Line(points={{100,-60},{120,-60}}, color={0,127,255}));
  connect(resCen.port_b, portCen_b)
    annotation (Line(points={{140,-60},{200,-60}}, color={0,127,255}));
  annotation (Diagram(coordinateSystem(extent={{-200,-160},{200,160}})),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end BorefieldSection;
