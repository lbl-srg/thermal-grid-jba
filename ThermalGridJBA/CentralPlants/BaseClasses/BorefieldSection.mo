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
    annotation (Placement(transformation(extent={{-140,80},{-120,100}})));
  parameter Integer nBorSec
    "Number of borefield sectors. It includes 2 modules and the number should be divisible by 3";

  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = Medium)
    "Fluid inlet"
    annotation (Placement(transformation(rotation=0, extent={{-219,-17},{-184,18}}),
                              iconTransformation(extent={{-109,-9},{-90,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = Medium)
    "Fluid outlet"
    annotation (Placement(transformation(rotation=0, extent={{183,-17},{216,18}}),
                        iconTransformation(extent={{90,-10},{110,10}})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QPer_flow(
    final unit="W")
    "Heat flow rate for center elements" annotation (Placement(transformation(
          extent={{200,120},{240,160}}), iconTransformation(extent={{100,60},{140,
            100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QCen_flow(
    final unit="W")
    "Heat flow rate for perimeter elements (top and bottom)" annotation (
      Placement(transformation(extent={{200,90},{240,130}}), iconTransformation(
          extent={{100,20},{140,60}})));

  Buildings.Fluid.Geothermal.ZonedBorefields.TwoUTubes borFie(
    redeclare each final package Medium = Medium,
    each allowFlowReversal=false,
    show_T=true,
    each energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    each TExt0_start=T_start,
    each borFieDat=borFieDat,
    each dT_dz=0) "Borefield"
    annotation (Placement(transformation(extent={{40,10},{60,30}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMulLea(
    redeclare each final package Medium = Medium,
    each allowFlowReversal=false,
    k=nBorSec/2) "Mass flow rate multiplier at outlet"
    annotation (Placement(transformation(extent={{148,-10},{168,10}})));
  Buildings.Fluid.Sources.Boundary_ph sin[2](
    redeclare each package Medium = Medium,
    each nPorts=1) "Sink"
    annotation (Placement(transformation(extent={{130,40},{110,60}})));
  Buildings.Fluid.Sources.MassFlowSource_T sou[2](
    redeclare each package Medium = Medium,
    each use_m_flow_in=true,
    each use_T_in=true,
    each nPorts=1) "Mass flow source"
    annotation (Placement(transformation(extent={{-22,44},{-2,64}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFlo[2](redeclare each package
      Medium = Medium, each allowFlowReversal=false)
    "Mass flow rate entering borefield"
    annotation (Placement(transformation(extent={{-90,0},{-70,20}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter floGai[2](each k=nDumSec)
    "Flow rate to the adjacent modules"
    annotation (Placement(transformation(extent={{-70,52},{-50,72}})));
  Buildings.Fluid.BaseClasses.MassFlowRateMultiplier masFloMulEnt(
    redeclare final package Medium = Medium,
    allowFlowReversal=false,
    k=2/nBorSec) "Split total flow by 2 because of center line symmetry"
    annotation (Placement(transformation(extent={{-128,-10},{-108,10}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemEnt(
    redeclare final package Medium = Medium,
    allowFlowReversal=false,
    final m_flow_nominal=sum(borFie.m_flow_nominal))
    "Temperature of waterflow entering borefield" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-150,0})));

  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter QBor1_flow(each k=
        nBorSec) "Heat flow rate of borehole top and bottom perimeter elements"
    annotation (Placement(transformation(extent={{80,130},{100,150}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter QBor2_flow2(each k=
        nBorSec) "Heat flow rate of borehole center elements"
    annotation (Placement(transformation(extent={{80,100},{100,120}})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAveBorWalPer(
    final unit="K",
    displayUnit="degC")
    "Average borehole wall temperatures perimeter elements" annotation (Placement(transformation(
          extent={{200,60},{240,100}}),  iconTransformation(extent={{100,60},{140,
            100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAveBorWalCen(
    final unit="K",
    displayUnit="degC")
    "Average borehole wall temperatures center elements" annotation (
      Placement(transformation(extent={{200,30},{240,70}}),  iconTransformation(
          extent={{100,20},{140,60}})));
equation
  connect(sou[1].ports[1], borFie.port_a[3]) annotation (Line(
      points={{-2,54},{28,54},{28,20},{40,20}},
      color={0,127,255},
      thickness=0.5));
  connect(sou[2].ports[1], borFie.port_a[4]) annotation (Line(
      points={{-2,54},{20,54},{20,20},{40,20}},
      color={0,127,255},
      thickness=0.5));
  connect(sin[1].ports[1], borFie.port_b[3]) annotation (Line(
      points={{110,50},{88,50},{88,20},{60,20}},
      color={0,127,255},
      thickness=0.5));
  connect(sin[2].ports[1], borFie.port_b[4]) annotation (Line(
      points={{110,50},{80,50},{80,20},{60,20}},
      color={0,127,255},
      thickness=0.5));
  connect(senMasFlo.m_flow, floGai.u)
    annotation (Line(points={{-80,21},{-80,62},{-72,62}}, color={0,0,127}));
  connect(floGai.y,sou. m_flow_in)
    annotation (Line(points={{-48,62},{-24,62}},color={0,0,127}));
  connect(senMasFlo[1].port_a, masFloMulEnt.port_b)
    annotation (Line(points={{-90,10},{-102,10},{-102,0},{-108,0}},
                                                 color={0,127,255}));
  connect(masFloMulEnt.port_b, senMasFlo[2].port_a)
    annotation (Line(points={{-108,0},{-100,0},{-100,10},{-90,10}},
                                                 color={0,127,255}));
  connect(senTemEnt.T, sou[1].T_in) annotation (Line(points={{-150,11},{-150,26},
          {-36,26},{-36,58},{-24,58}}, color={0,0,127}));
  connect(senTemEnt.T, sou[2].T_in) annotation (Line(points={{-150,11},{-150,26},
          {-40,26},{-40,58},{-24,58}}, color={0,0,127}));
  connect(senMasFlo[1].port_b, borFie.port_a[1]) annotation (Line(points={{-70,10},
          {-8,10},{-8,20},{40,20}},color={0,127,255}));
  connect(senMasFlo[2].port_b, borFie.port_a[2]) annotation (Line(points={{-70,10},
          {0,10},{0,20},{40,20}},color={0,127,255}));
  connect(borFie.port_b[1], masFloMulLea.port_a) annotation (Line(points={{60,20},
          {140,20},{140,0},{148,0}}, color={0,127,255}));
  connect(borFie.port_b[2], masFloMulLea.port_a) annotation (Line(points={{60,20},
          {128,20},{128,0},{148,0}}, color={0,127,255}));
  connect(port_b, masFloMulLea.port_b) annotation (Line(points={{199.5,0.5},{178,
          0.5},{178,0},{168,0}}, color={0,127,255}));
  connect(port_a, senTemEnt.port_a) annotation (Line(points={{-201.5,0.5},{-201.5,
          0},{-160,0}}, color={0,127,255}));
  connect(borFie.QBorAve[1], QBor1_flow.u) annotation (Line(points={{61,28},{66,
          28},{66,140},{78,140}}, color={0,0,127}));
  connect(borFie.QBorAve[2], QBor2_flow2.u) annotation (Line(points={{61,28},{66,
          28},{66,110},{78,110}}, color={0,0,127}));
  connect(QBor1_flow.y, QPer_flow)
    annotation (Line(points={{102,140},{220,140}}, color={0,0,127}));
  connect(QBor2_flow2.y, QCen_flow)
    annotation (Line(points={{102,110},{220,110}}, color={0,0,127}));
  connect(TAveBorWalPer, borFie.TBorAve[1]) annotation (Line(points={{220,80},{70,
          80},{70,24.4},{61,24.4}}, color={0,0,127}));
  connect(TAveBorWalCen, borFie.TBorAve[2]) annotation (Line(points={{220,50},{180,
          50},{180,70},{70,70},{70,24.4},{61,24.4}}, color={0,0,127}));
  connect(senTemEnt.port_b, masFloMulEnt.port_a)
    annotation (Line(points={{-140,0},{-128,0}}, color={0,127,255}));
  annotation (Diagram(coordinateSystem(extent={{-200,-40},{200,160}})),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end BorefieldSection;
