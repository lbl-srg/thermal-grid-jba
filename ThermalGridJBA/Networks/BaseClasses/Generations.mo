within ThermalGridJBA.Networks.BaseClasses;
model Generations
  "Cooling and heating generation from the heat pump and heat exchanger"
  package MediumW = Buildings.Media.Water "Water";
  package MediumG = Modelica.Media.Incompressible.Examples.Glycol47 "Glycol";
  parameter Real TDisLooMin(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=283.65
    "Design minimum district loop temperature";
  parameter Real TDisLooMax(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=297.15
    "Design maximum district loop temperature";
  parameter Modelica.Units.SI.MassFlowRate mWat_flow_nominal
    "Nominal water mass flow rate";
  parameter Modelica.Units.SI.MassFlowRate mHexGly_flow_nominal
    "Nominal glycol mass flow rate for heat exchanger";
  parameter Modelica.Units.SI.MassFlowRate mHpGly_flow_nominal
    "Nominal glycol mass flow rate for heat pump";
  parameter Modelica.Units.SI.MassFlowRate mDryCoo_flow_nominal=mHexGly_flow_nominal+mHpGly_flow_nominal
    "Nominal glycol mass flow rate for dry cooler";
  parameter Modelica.Units.SI.PressureDifference dpHex_nominal(
    displayUnit="Pa")
    "Pressure difference across heat exchanger";
  parameter Modelica.Units.SI.PressureDifference dpValve_nominal(
    displayUnit="Pa")=6000
    "Nominal pressure drop of fully open 2-way valve";

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
    annotation (Placement(transformation(extent={{-170,-170},{-150,-150}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valHexByp(
    redeclare final package Medium = MediumW,
    final m_flow_nominal=mWat_flow_nominal,
    final dpValve_nominal=dpValve_nominal,
    use_inputFilter=false) "Bypass heat exchanger valve"
    annotation (Placement(transformation(extent={{-70,-170},{-50,-150}})));
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
    final m1_flow_nominal=mHexGly_flow_nominal,
    final m2_flow_nominal=mWat_flow_nominal,
    final dp1_nominal=dpHex_nominal,
    final dp2_nominal=dpHex_nominal) "Economizer"
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
  Buildings.Fluid.HeatPumps.ModularReversible.Modular
                                                  modular(
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
  Buildings.Fluid.HeatExchangers.CoolingTowers.YorkCalc      dryCoo(
    redeclare final package Medium = MediumG, final m_flow_nominal=
        mDryCoo_flow_nominal)
    "Dry cooler"
    annotation (Placement(transformation(extent={{40,120},{60,140}})));
  Buildings.Fluid.MixingVolumes.MixingVolume vol3(
    redeclare final package Medium = MediumG,
    final m_flow_nominal=mDryCoo_flow_nominal,
    nPorts=3)
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=90, origin={210,100})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumDryCoo(
    redeclare final package Medium = MediumG,
    final addPowerToMedium=false,
    final use_inputFilter=false,
    final m_flow_nominal=mDryCoo_flow_nominal)
                                            "Dry cooler pump"
    annotation (Placement(transformation(extent={{-60,120},{-40,140}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumHeaPumGly(
    redeclare final package Medium = MediumG,
    final addPowerToMedium=false,
    final use_inputFilter=false,
    final m_flow_nominal=mHpGly_flow_nominal)
                                            "Pump for heat pump glycol loop"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={200,0})));
  Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear valHeaPumByp(
      redeclare final package Medium = MediumG, final use_inputFilter=false,
    final m_flow_nominal=mHpGly_flow_nominal,
    final dpValve_nominal=dpValve_nominal)
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
    redeclare final package Medium = MediumG, final m_flow_nominal=
        mHpGly_flow_nominal)
    "Temperature of glycol entering heat pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90, origin={200,30})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare final package Medium = MediumG,
    nPorts=1)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=180, origin={-124,-24})));
  Controls.Indicators ind
    annotation (Placement(transformation(extent={{-260,250},{-240,270}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum
    "District loop pump speed"
    annotation (Placement(transformation(extent={{-340,240},{-300,280}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uSolTim
    "Solar time. An output from weather data"
    annotation (Placement(transformation(extent={{-340,210},{-300,250}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Controls.DryCoolerHex dryCooHexCon(final mHexGly_flow_nominal=
        mHexGly_flow_nominal, final mDryCoo_flow_nominal=mDryCoo_flow_nominal)
    annotation (Placement(transformation(extent={{-80,200},{-60,220}})));
  Controls.HeatPump heaPumCon(
    final mWat_flow_nominal=mWat_flow_nominal,
    final mHpGly_flow_nominal=mHpGly_flow_nominal,
    TDisLooMin=TDisLooMin,
    TDisLooMax=TDisLooMax)
    annotation (Placement(transformation(extent={{-180,160},{-160,180}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixAve(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Average temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-340,120},{-300,160}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-340,170},{-300,210}}),
        iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort dryCooOut(redeclare final package
      Medium = MediumG, final m_flow_nominal=mDryCoo_flow_nominal)
    "Temperature of dry cooler outlet" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={130,130})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumDryCoo1(
    redeclare final package Medium = MediumG,
    final addPowerToMedium=false,
    final use_inputFilter=false,
    final m_flow_nominal=mHexGly_flow_nominal)
                                            "Dry cooler pump"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-20,40})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWetBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Ambient wet bulb temperature" annotation (Placement(
        transformation(extent={{-340,90},{-300,130}}), iconTransformation(
          extent={{-140,-40},{-100,0}})));

  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(final k=
        mWat_flow_nominal)
    "Convert mass flow rate"
    annotation (Placement(transformation(extent={{-200,10},{-180,30}})));
  Buildings.Fluid.Delays.DelayFirstOrder del
    annotation (Placement(transformation(extent={{-384,40},{-364,60}})));
  Buildings.Fluid.Delays.DelayFirstOrder del1(m_flow_nominal=mWat_flow_nominal,
      nPorts=3)
    annotation (Placement(transformation(extent={{-110,-160},{-90,-180}})));
  Buildings.Fluid.Delays.DelayFirstOrder del2(m_flow_nominal=mWat_flow_nominal,
      nPorts=5)
    annotation (Placement(transformation(extent={{-30,-160},{-10,-180}})));
  Buildings.Fluid.Delays.DelayFirstOrder del3(m_flow_nominal=mWat_flow_nominal,
      nPorts=3) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={-110,60})));
equation
  connect(valHex.port_b, hex.port_a2) annotation (Line(
      points={{-100,-90},{-100,-36},{-80,-36}},
      color={0,127,255},
      thickness=0.5));
  connect(valHeaPum.port_b, pumHeaPumWat.port_a) annotation (Line(
      points={{120,-110},{120,-90}},
      color={0,127,255},
      thickness=0.5));
  connect(pumHeaPumWat.port_b, modular.port_a2) annotation (Line(
      points={{120,-70},{120,-36},{160,-36}},
      color={0,127,255},
      thickness=0.5));
  connect(pumDryCoo.port_b, dryCoo.port_a) annotation (Line(
      points={{-40,130},{40,130}},
      color={0,127,255},
      thickness=0.5));
  connect(modular.port_a1, pumHeaPumGly.port_b) annotation (Line(
      points={{180,-24},{200,-24},{200,-10}},
      color={0,127,255},
      thickness=0.5));
  connect(valHeaPumByp.port_1, vol3.ports[1]) annotation (Line(
      points={{200,70},{200,98.6667}},
      color={0,127,255},
      thickness=0.5));
  connect(port_a, senTem.port_a) annotation (Line(
      points={{-300,0},{-280,0},{-280,-160},{-270,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(senTem.port_b, pumCenPla.port_a) annotation (Line(
      points={{-250,-160},{-170,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(modular.port_b2, heaPumLea.port_a) annotation (Line(
      points={{180,-36},{200,-36},{200,-90}},
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
  connect(uDisPum, ind.uDisPum) annotation (Line(points={{-320,260},{-290,260},
          {-290,264},{-262,264}}, color={0,0,127}));
  connect(uSolTim, ind.uSolTim) annotation (Line(points={{-320,230},{-270,230},
          {-270,256},{-262,256}}, color={0,0,127}));
  connect(ind.yEleRat, heaPumCon.uEleRat) annotation (Line(points={{-238,260},{
          -220,260},{-220,179},{-182,179}}, color={255,127,0}));
  connect(ind.yEleRat, dryCooHexCon.uEleRat) annotation (Line(points={{-238,260},
          {-220,260},{-220,219},{-82,219}}, color={255,127,0}));
  connect(ind.ySt, dryCooHexCon.uSt) annotation (Line(points={{-238,266},{-212,266},
          {-212,217},{-82,217}},      color={255,127,0}));
  connect(ind.ySt, heaPumCon.uSt) annotation (Line(points={{-238,266},{-212,266},
          {-212,177},{-182,177}}, color={255,127,0}));
  connect(ind.yGen, dryCooHexCon.uGen) annotation (Line(points={{-238,254},{-228,
          254},{-228,215},{-82,215}},      color={255,127,0}));
  connect(ind.yGen, heaPumCon.uGen) annotation (Line(points={{-238,254},{-228,
          254},{-228,168},{-182,168}}, color={255,127,0}));
  connect(heaPumCon.y1On, dryCooHexCon.u1HeaPum) annotation (Line(points={{-158,
          171},{-120,171},{-120,204},{-82,204}}, color={255,0,255}));
  connect(TMixAve, heaPumCon.TMixAve) annotation (Line(points={{-320,140},{-280,
          140},{-280,174},{-182,174}}, color={0,0,127}));
  connect(heaPumLea.T, heaPumCon.TWatOut) annotation (Line(points={{211,-100},{
          220,-100},{220,-200},{-220,-200},{-220,171},{-182,171}}, color={0,0,
          127}));
  connect(uDisPum, heaPumCon.uDisPum) annotation (Line(points={{-320,260},{-290,
          260},{-290,164},{-182,164}}, color={0,0,127}));
  connect(heaPumGlyIn.T, heaPumCon.TGlyIn) annotation (Line(points={{211,30},{
          226,30},{226,-206},{-226,-206},{-226,161},{-182,161}}, color={0,0,127}));
  connect(TDryBul, dryCooHexCon.TDryBul) annotation (Line(points={{-320,190},{-160,
          190},{-160,208},{-82,208}},      color={0,0,127}));
  connect(senTem.T, dryCooHexCon.TGenIn) annotation (Line(points={{-260,-149},{-260,
          211},{-82,211}},      color={0,0,127}));
  connect(dryCoo.port_b, dryCooOut.port_a)
    annotation (Line(points={{60,130},{120,130}}, color={0,127,255},
      thickness=0.5));
  connect(dryCooOut.port_b, vol3.ports[2]) annotation (Line(points={{140,130},{
          200,130},{200,100}},     color={0,127,255},
      thickness=0.5));
  connect(dryCooOut.T, dryCooHexCon.TDryCooOut) annotation (Line(points={{130,141},
          {130,180},{-100,180},{-100,201},{-82,201}},      color={0,0,127}));
  connect(dryCooHexCon.yValHex, valHex.y) annotation (Line(points={{-58,217},{-40,
          217},{-40,150},{-140,150},{-140,-100},{-112,-100}},     color={0,0,
          127}));
  connect(dryCooHexCon.yValHexByp, valHexByp.y) annotation (Line(points={{-58,219},
          {-34,219},{-34,-140},{-60,-140},{-60,-148}},      color={0,0,127}));
  connect(hex.port_a1, pumDryCoo1.port_b) annotation (Line(
      points={{-60,-24},{-20,-24},{-20,30}},
      color={0,127,255},
      thickness=0.5));
  connect(pumDryCoo1.port_a, vol3.ports[3]) annotation (Line(
      points={{-20,50},{-20,80},{200,80},{200,101.333}},
      color={0,127,255},
      thickness=0.5));
  connect(dryCooHexCon.yDryCoo, dryCoo.y) annotation (Line(points={{-58,202},{20,
          202},{20,138},{38,138}}, color={0,0,127}));
  connect(TWetBul, dryCoo.TAir) annotation (Line(points={{-320,110},{20,110},{20,
          134},{38,134}}, color={0,0,127}));
  connect(heaPumCon.ySet, modular.ySet) annotation (Line(points={{-158,174},{240,
          174},{240,-28.1},{181.1,-28.1}}, color={0,0,127}));
  connect(heaPumCon.yVal, valHeaPum.y) annotation (Line(points={{-158,165},{80,165},
          {80,-120},{108,-120}}, color={0,0,127}));
  connect(heaPumCon.yValByp, valHeaPumByp.y) annotation (Line(points={{-158,161},
          {234,161},{234,60},{212,60}}, color={0,0,127}));
  connect(dryCooHexCon.yPumHex, pumDryCoo1.m_flow_in) annotation (Line(points={
          {-58,214},{0,214},{0,40},{-8,40}}, color={0,0,127}));
  connect(dryCooHexCon.yPumDryCoo, pumDryCoo.m_flow_in)
    annotation (Line(points={{-58,206},{-50,206},{-50,142}}, color={0,0,127}));
  connect(heaPumCon.yPumGly, pumHeaPumGly.m_flow_in) annotation (Line(points={{
          -158,168},{246,168},{246,0},{212,0}}, color={0,0,127}));
  connect(heaPumCon.yPum, pumHeaPumWat.m_flow_in) annotation (Line(points={{
          -158,163},{86,163},{86,-80},{108,-80}}, color={0,0,127}));
  connect(gai2.y, pumCenPla.m_flow_in) annotation (Line(points={{-178,20},{-160,
          20},{-160,-148}}, color={0,0,127}));
  connect(uDisPum, gai2.u) annotation (Line(points={{-320,260},{-290,260},{-290,
          20},{-202,20}}, color={0,0,127}));
  connect(pumCenPla.port_b, del1.ports[1]) annotation (Line(
      points={{-150,-160},{-101.333,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(del1.ports[2], valHexByp.port_a) annotation (Line(
      points={{-100,-160},{-70,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(del1.ports[3], valHex.port_a) annotation (Line(
      points={{-98.6667,-160},{-100,-156},{-100,-110}},
      color={0,127,255},
      thickness=0.5));
  connect(valHexByp.port_b, del2.ports[1]) annotation (Line(
      points={{-50,-160},{-21.6,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(hex.port_b2, del2.ports[2]) annotation (Line(
      points={{-60,-36},{-20.8,-36},{-20.8,-160}},
      color={0,127,255},
      thickness=0.5));
  connect(del2.ports[3], valHeaPum.port_a) annotation (Line(
      points={{-20,-160},{120,-160},{120,-130}},
      color={0,127,255},
      thickness=0.5));
  connect(del2.ports[4], heaPumLea.port_b) annotation (Line(
      points={{-19.2,-160},{200,-160},{200,-110}},
      color={0,127,255},
      thickness=0.5));
  connect(del2.ports[5], port_b) annotation (Line(
      points={{-18.4,-160},{280,-160},{280,0},{300,0}},
      color={0,127,255},
      thickness=0.5));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-300,-280},
            {300,280}})), Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-300,-280},{300,280}})));
end Generations;
