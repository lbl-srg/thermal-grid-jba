within ThermalGridJBA.Networks;
model IdealHeatingCoolingPlant
  "Ideal plant that can produce either heating and cooling"
  extends Buildings.DHC.Plants.BaseClasses.PartialPlant(
    final have_fan=false,
    final have_pum=true,
    final have_eleHea=false,
    final have_eleCoo=false,
    final have_weaBus=false,
    final typ=Buildings.DHC.Types.DistrictSystemType.CombinedGeneration5);

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal
    "Nominal mass flow rate"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.Units.SI.PressureDifference dp_nominal
    "Pressure drop at nominal mass flow rate"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.Units.SI.Temperature TLooMin
    "Minimum loop temperature"
    annotation (Dialog(group="Temperatures"));
  parameter Modelica.Units.SI.Temperature TLooMax
    "Maximum loop temperature"
    annotation (Dialog(group="Temperatures"));
  parameter Modelica.Units.SI.TemperatureDifference dTOff
    "Offset temperature"
    annotation (Dialog(group="Temperatures"));


  Buildings.Fluid.Interfaces.PrescribedOutlet heaCoo(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    final use_X_wSet=false)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Buildings.DHC.ETS.BaseClasses.Pump_m_flow pum(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal,
    final dp_nominal=dp_nominal,
    final allowFlowReversal=allowFlowReversal) "Water pump" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={90,0})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mPum_flow(final unit="kg/s")
    "Pumps mass flow rate"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-400,180}),iconTransformation(
        extent={{-40,-40},{40,40}},
        rotation=0,
        origin={-340,140})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTIn(
    redeclare final package Medium = Medium,
    final allowFlowReversal=allowFlowReversal,
    final m_flow_nominal=m_flow_nominal,
    tau=0) "Incoming temperature" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-110,0})));
  Buildings.Controls.OBC.CDL.Reals.Limiter lim(uMax=TLooMax - dTOff, uMin=
        TLooMin + dTOff)
    annotation (Placement(transformation(extent={{-60,20},{-40,40}})));
  Buildings.Controls.OBC.CDL.Reals.Abs abs1
    annotation (Placement(transformation(extent={{300,270},{320,290}})));
  Buildings.Controls.OBC.CDL.Reals.Abs abs2
    annotation (Placement(transformation(extent={{300,230},{320,250}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(k=-1)
    annotation (Placement(transformation(extent={{260,230},{280,250}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(k=-1)
    annotation (Placement(transformation(extent={{340,230},{360,250}})));
equation
  connect(heaCoo.port_b, pum.port_a)
    annotation (Line(points={{10,0},{80,0}}, color={0,127,255}));
  connect(pum.port_b, port_bSerAmb) annotation (Line(points={{100,0},{340,0},{340,
          40},{380,40}}, color={0,127,255}));
  connect(pum.P, PPum) annotation (Line(points={{101,9},{320,9},{320,160},{400,160}},
        color={0,0,127}));
  connect(pum.m_flow_in, mPum_flow)
    annotation (Line(points={{90,12},{90,180},{-400,180}}, color={0,0,127}));
  connect(heaCoo.port_a, senTIn.port_b)
    annotation (Line(points={{-10,0},{-100,0}}, color={0,127,255}));
  connect(senTIn.port_a, port_aSerAmb) annotation (Line(points={{-120,0},{-340,0},
          {-340,40},{-380,40}}, color={0,127,255}));
  connect(senTIn.T, lim.u)
    annotation (Line(points={{-110,11},{-110,30},{-62,30}}, color={0,0,127}));
  connect(lim.y, heaCoo.TSet) annotation (Line(points={{-38,30},{-24,30},{-24,8},
          {-11,8}}, color={0,0,127}));
  connect(abs1.y, PHea)
    annotation (Line(points={{322,280},{400,280}}, color={0,0,127}));
  connect(abs2.y, gai2.u)
    annotation (Line(points={{322,240},{338,240}}, color={0,0,127}));
  connect(gai2.y, PCoo)
    annotation (Line(points={{362,240},{400,240}}, color={0,0,127}));
  connect(gai1.y, abs2.u)
    annotation (Line(points={{282,240},{298,240}}, color={0,0,127}));
  connect(heaCoo.Q_flow, gai1.u) annotation (Line(points={{11,8},{40,8},{40,240},
          {258,240}}, color={0,0,127}));
  connect(heaCoo.Q_flow, abs1.u) annotation (Line(points={{11,8},{40,8},{40,280},
          {298,280}}, color={0,0,127}));
end IdealHeatingCoolingPlant;
