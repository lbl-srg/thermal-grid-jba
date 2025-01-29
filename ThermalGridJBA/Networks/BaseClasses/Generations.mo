within ThermalGridJBA.Networks.BaseClasses;
model Generations
  "Cooling and heating generation from the heat pump and heat exchanger"
  package MediumW = Buildings.Media.Water "Water";
  package MediumG = Modelica.Media.Incompressible.Examples.Glycol47 "Glycol";
  parameter Modelica.Units.SI.MassFlowRate mWat_flow_nominal
    "Nominal water mass flow rate";
  parameter Modelica.Units.SI.MassFlowRate mGly_flow_nominal
    "Nominal glycol mass flow rate";
  parameter Modelica.Units.SI.PressureDifference dpHex_nominal
    "Pressure difference across heat exchanger";

  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow from the district"
    annotation (Placement(transformation(extent={{-310,-10},{-290,10}}),
      iconTransformation(extent={{-310,-210},{-290,-190}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow to the district"
    annotation (Placement(transformation(extent={{290,-10},{310,10}}),
      iconTransformation(extent={{290,-290},{310,-270}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumCenPla(
    redeclare final package Medium = MediumW,
    addPowerToMedium=false,
    use_inputFilter=false,
    m_flow_nominal=mWat_flow_nominal) "Pump for the whole central plant"
    annotation (Placement(transformation(extent={{-160,-170},{-140,-150}})));
  Buildings.Fluid.MixingVolumes.MixingVolume vol(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mWat_flow_nominal,
    nPorts=3)
    annotation (Placement(transformation(extent={{-110,-160},{-90,-180}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHexByp(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_inputFilter=false) "Bypass heat exchanger valve"
    annotation (Placement(transformation(extent={{-70,-170},{-50,-150}})));
  Buildings.Fluid.MixingVolumes.MixingVolume vol1(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mWat_flow_nominal,
    nPorts=5)
    annotation (Placement(transformation(extent={{-30,-160},{-10,-180}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHex(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_inputFilter=false) "Heat exchanger valve" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-100,-100})));
  Buildings.Fluid.HeatExchangers.ConstantEffectiveness hex(
    redeclare final package Medium1 = MediumG,
    redeclare final package Medium2 = MediumW,
    final m1_flow_nominal=mGly_flow_nominal,
    final m2_flow_nominal=mWat_flow_nominal,
    final dp1_nominal=dpHex_nominal,
    final dp2_nominal=dpHex_nominal)
    annotation (Placement(transformation(extent={{-60,-40},{-80,-20}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHeaPum(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_inputFilter=false) "Heat pump water loop valve" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={120,-120})));
  Buildings.Fluid.HeatPumps.EquationFitReversible heaPum(
    redeclare final package Medium1 = MediumG,
    redeclare final package Medium2 = MediumW)
    annotation (Placement(transformation(extent={{180,-40},{160,-20}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumHeaPumWat(
    redeclare final package Medium = MediumW,
    final addPowerToMedium=false,
    use_inputFilter=false,
    final m_flow_nominal=mWat_flow_nominal) "Pump for heat pump waterside loop"
     annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90, origin={120,-80})));
  Buildings.Fluid.HeatExchangers.CoolingTowers.FixedApproach dryCoo(
    redeclare final package Medium = MediumG,
    final m_flow_nominal=mGly_flow_nominal)
    "Dry cooler"
    annotation (Placement(transformation(extent={{40,110},{60,130}})));
  Buildings.Fluid.MixingVolumes.MixingVolume vol2(
    redeclare final package Medium = MediumG,
    final m_flow_nominal=mGly_flow_nominal,
    nPorts=4)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=-90, origin={-110,100})));
  Buildings.Fluid.MixingVolumes.MixingVolume vol3(
    redeclare final package Medium = MediumG,
    final m_flow_nominal=mGly_flow_nominal,
    nPorts=3)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=90, origin={210,100})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumDryCoo(
    redeclare final package Medium = MediumG,
    final addPowerToMedium=false,
    final use_inputFilter=false,
    final m_flow_nominal=mGly_flow_nominal) "Dry cooler pump"
    annotation (Placement(transformation(extent={{-58,110},{-38,130}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumHeaPumGly(
    redeclare final package Medium = MediumG,
    final addPowerToMedium=false,
    final use_inputFilter=false,
    final m_flow_nominal=mGly_flow_nominal) "Pump for heat pump glycol loop"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={200,0})));
  Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear valHeaPumByp(
      redeclare final package Medium = MediumG, final use_inputFilter=false)
    "Heat pump bypass valve" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={200,60})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTem(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow from district"
    annotation (Placement(transformation(extent={{-270,-170},{-250,-150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort heaPumLea(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mWat_flow_nominal)
    "Temperature of waterflow leave heat pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={200,-100})));
  Buildings.Fluid.Sensors.TemperatureTwoPort heaPumGlyIn(
    redeclare final package Medium = MediumG,
    final m_flow_nominal=mGly_flow_nominal)
    "Temperature of glycol entering heat pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={200,30})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium = MediumG,
    nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=180, origin={-124,-24})));
  parameter Modelica.Units.SI.PressureDifference dpValve_nominal=6000
    "Nominal pressure drop of fully open 2-way valve";
equation
  connect(pumCenPla.port_b, vol.ports[1]) annotation (Line(
      points={{-140,-160},{-101.333,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(vol.ports[2], valHexByp.port_a) annotation (Line(
      points={{-100,-160},{-70,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(valHexByp.port_b, vol1.ports[1]) annotation (Line(
      points={{-50,-160},{-21.6,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(vol.ports[3], valHex.port_a) annotation (Line(
      points={{-98.6667,-160},{-100,-156},{-100,-110}},
      color={0,127,255},
      thickness=0.5));
  connect(valHex.port_b, hex.port_a2) annotation (Line(
      points={{-100,-90},{-100,-36},{-80,-36}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_b2, vol1.ports[2]) annotation (Line(
      points={{-60,-36},{-20.8,-36},{-20.8,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(vol1.ports[3], port_b) annotation (Line(
      points={{-20,-160},{280,-160},{280,0},{300,0}},
      color={0,127,255},
      thickness=0.5));
  connect(vol1.ports[4], valHeaPum.port_a) annotation (Line(
      points={{-19.2,-160},{120,-160},{120,-130}},
      color={0,127,255},
      thickness=0.5));
  connect(valHeaPum.port_b, pumHeaPumWat.port_a) annotation (Line(
      points={{120,-110},{120,-90}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumWat.port_b, heaPum.port_a2) annotation (Line(
      points={{120,-70},{120,-36},{160,-36}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_b1, vol2.ports[1]) annotation (Line(
      points={{-80,-24},{-100,-24},{-100,101.5}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPum.port_b1, vol2.ports[2]) annotation (Line(
      points={{160,-24},{120,-24},{120,0},{-100,0},{-100,100.5}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_a1, vol3.ports[1]) annotation (Line(
      points={{-60,-24},{-20,-24},{-20,80},{200,80},{200,98.6667}},
      color={0,127,255},
      thickness=0.5));
  connect(vol2.ports[3], pumDryCoo.port_a) annotation (Line(
      points={{-100,99.5},{-100,120},{-58,120}},
      color={0,127,255},
      thickness=0.5));
  connect(pumDryCoo.port_b, dryCoo.port_a) annotation (Line(
      points={{-38,120},{40,120}},
      color={0,127,255},
      thickness=0.5));
  connect(dryCoo.port_b, vol3.ports[2]) annotation (Line(
      points={{60,120},{200,120},{200,100}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPum.port_a1,pumHeaPumGly. port_b) annotation (Line(
      points={{180,-24},{200,-24},{200,-10}},
      color={0,127,255},
      thickness=0.5));
  connect(valHeaPumByp.port_1, vol3.ports[3]) annotation (Line(
      points={{200,70},{200,101.333}},
      color={0,127,255},
      thickness=0.5));
  connect(vol2.ports[4], valHeaPumByp.port_3) annotation (Line(
      points={{-100,98.5},{-100,0},{120,0},{120,60},{190,60}},
      color={0,127,255},
      thickness=0.5));
  connect(port_a, senTem.port_a) annotation (Line(
      points={{-300,0},{-280,0},{-280,-160},{-270,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(senTem.port_b, pumCenPla.port_a) annotation (Line(
      points={{-250,-160},{-160,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPum.port_b2, heaPumLea.port_a) annotation (Line(
      points={{180,-36},{200,-36},{200,-90}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPumLea.port_b, vol1.ports[5]) annotation (Line(
      points={{200,-110},{200,-160},{-18.4,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumGly.port_a, heaPumGlyIn.port_b) annotation (Line(
      points={{200,10},{200,20}},
      color={0,127,255},
      thickness=0.5));
  connect(heaPumGlyIn.port_a, valHeaPumByp.port_2) annotation (Line(
      points={{200,40},{200,50}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_b1, bou.ports[1]) annotation (Line(
      points={{-80,-24},{-114,-24}},
      color={0,127,255},
      thickness=0.5));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-300,-280},
            {300,280}})), Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-300,-280},{300,280}})));
end Generations;
