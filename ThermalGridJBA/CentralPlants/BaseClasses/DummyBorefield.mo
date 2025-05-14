within ThermalGridJBA.CentralPlants.BaseClasses;
model DummyBorefield
  "Dummy model to replace borefield for developing plant"
  extends Modelica.Blocks.Icons.Block;
  replaceable package Medium = Buildings.Media.Water "Water";

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal
    "Nominal mass flow rate";

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QPer_flow(
    final unit="W")
    "Heat flow rate for center elements" annotation (Placement(transformation(
          extent={{200,120},{240,160}}), iconTransformation(extent={{100,40},{140,
            80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QCor_flow(
    final unit="W") "Heat flow rate for core elements"       annotation (
      Placement(transformation(extent={{200,90},{240,130}}), iconTransformation(
          extent={{100,10},{140,50}})));

  Modelica.Fluid.Interfaces.FluidPort_a portPer_a(redeclare final package
      Medium = Medium)
    "Fluid connector for perimeter of borefield"                                      annotation (
      Placement(transformation(extent={{-210,50},{-190,70}}),
        iconTransformation(extent={{-110,70},{-90,90}})));
  Modelica.Fluid.Interfaces.FluidPort_a portCor_a(redeclare final package
      Medium = Medium) "Fluid connector for core of borefield" annotation (
      Placement(transformation(extent={{-210,-70},{-190,-50}}),
        iconTransformation(extent={{-110,-90},{-90,-70}})));
  Modelica.Fluid.Interfaces.FluidPort_b portPer_b(redeclare final package
      Medium = Medium) "Fluid connector outlet of perimeter borefield zones"
    annotation (Placement(transformation(extent={{190,50},{210,70}}),
        iconTransformation(extent={{90,70},{110,90}})));
  Modelica.Fluid.Interfaces.FluidPort_b portCor_b(redeclare final package
      Medium = Medium) "Fluid connector for core of the borefield" annotation
    (Placement(transformation(extent={{190,-70},{210,-50}}),iconTransformation(
          extent={{88,-90},{108,-70}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(k=0)
    annotation (Placement(transformation(extent={{120,120},{140,140}})));
  Buildings.Fluid.FixedResistances.PressureDrop res1(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=100,
    dp_nominal=1E4)  "Flow resistance"
    annotation (Placement(transformation(extent={{-10,70},{10,90}})));
  Buildings.Fluid.FixedResistances.PressureDrop res2(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=100,
    dp_nominal=1E4)  "Flow resistance"
    annotation (Placement(transformation(extent={{-10,30},{10,50}})));
  Buildings.Fluid.FixedResistances.PressureDrop res3(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=100,
    dp_nominal=1E4)  "Flow resistance"
    annotation (Placement(transformation(extent={{-10,-50},{10,-30}})));
  Buildings.Fluid.FixedResistances.PressureDrop res4(
    redeclare package Medium = Medium,
    allowFlowReversal=false,
    m_flow_nominal=100,
    dp_nominal=1E4)  "Flow resistance"
    annotation (Placement(transformation(extent={{-10,-90},{10,-70}})));

equation
  connect(con.y, QPer_flow) annotation (Line(points={{142,130},{174,130},{174,140},
          {220,140}}, color={0,0,127}));
  connect(con.y, QCor_flow) annotation (Line(points={{142,130},{174,130},{174,110},
          {220,110}}, color={0,0,127}));
  connect(res1.port_b, portPer_b) annotation (Line(points={{10,80},{100,80},{100,
          60},{200,60}}, color={0,127,255}));
  connect(res2.port_b, portPer_b) annotation (Line(points={{10,40},{100,40},{100,
          60},{200,60}}, color={0,127,255}));
  connect(res3.port_b, portCor_b) annotation (Line(points={{10,-40},{100,-40},{100,
          -60},{200,-60}}, color={0,127,255}));
  connect(res4.port_b, portCor_b) annotation (Line(points={{10,-80},{100,-80},{100,
          -60},{200,-60}}, color={0,127,255}));
  connect(portPer_a, res1.port_a) annotation (Line(points={{-200,60},{-100,60},
          {-100,80},{-10,80}}, color={0,127,255}));
  connect(portPer_a, res2.port_a) annotation (Line(points={{-200,60},{-100,60},
          {-100,40},{-10,40}}, color={0,127,255}));
  connect(portCor_a, res3.port_a) annotation (Line(points={{-200,-60},{-100,-60},
          {-100,-40},{-10,-40}}, color={0,127,255}));
  connect(portCor_a, res4.port_a) annotation (Line(points={{-200,-60},{-100,-60},
          {-100,-80},{-10,-80}}, color={0,127,255}));
  annotation (Diagram(coordinateSystem(extent={{-200,-160},{200,160}})),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}}), graphics={Rectangle(
          extent={{-88,0},{82,-82}},
          lineColor={255,255,255},
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid), Text(
          extent={{38,88},{-50,10}},
          textColor={0,0,0},
          textString="Dummy")}));
end DummyBorefield;
