within ThermalGridJBA.Networks.Validation;
model FiveHubsPlantMultiFlow_requirements_all
  extends FiveHubsPlantMultiFlow;
  Buildings_Requirements.WithinBand reqTDomHotWatSupply[nBui](
    name="ETS",
    text=
        "O-301: The domestic hot water supply temperature must be 45°C ± 1 K.",
    delayTime=30,
    u_max(
      final unit="K",
      each displayUnit="degC") = 319.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 317.15,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for domestic hot water supply temperature"
    annotation (Placement(transformation(extent={{520,160},{540,180}})));
  Buildings_Requirements.WithinBand reqTDomHotWatTan(
    name="ETS",
    text=
        "O-302: The heating water temperature that serves the domestic hot water tank must be 50°C ± 1 K once the tank charging is on for 5 minutes.",
    use_activeInput=true,
    delayTime(displayUnit="min") = 300,
    u_max(
      final unit="K",
      displayUnit="degC") = 324.15,
    u_min(
      final unit="K",
      displayUnit="degC") = 322.15,
    u(final unit="K", displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirment for The heating water temperature that serves the domestic hot water tank"
    annotation (Placement(transformation(extent={{520,110},{540,130}})));
  Buildings_Requirements.WithinBand reqTSHSet(
    name="ETS",
    text=
        "O-303: The space heating water supply temperature set point must be tracked within ± 1 K once the system is on for 5 minutes.",
    use_activeInput=true,
    delayTime(displayUnit="min") = 300,
    u_max(
      final unit="K",
      displayUnit="K") = 1,
    u_min(
      final unit="K",
      displayUnit="K") = 1,
    u(final unit="K", displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirment for tracking the space heating water supply temperature set point"
    annotation (Placement(transformation(extent={{520,60},{540,80}})));
  Buildings_Requirements.WithinBand reqTSCSet(
    name="ETS",
    text=
        "O-304: The space cooling water supply temperature set point must be tracked within ± 1 K once the system is on for 5 minutes.",
    use_activeInput=true,
    delayTime(displayUnit="min") = 300,
    u_max(
      final unit="K",
      displayUnit="K") = 1,
    u_min(
      final unit="K",
      displayUnit="K") = 1,
    u(final unit="K", displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirment for tracking the space cooling water supply temperature set point"
    annotation (Placement(transformation(extent={{520,10},{540,30}})));
  Buildings_Requirements.WithinBand reqTHEXETSLeaSec(
    name="ETS",
    text=
        "O-305: At the district heat exchanger in the ETS, the secondary side leaving water temperature that serves the heat pumps must be between 9.5°C and 25°C.",
    delayTime(displayUnit="min") = 300,
    u_max(
      final unit="K",
      displayUnit="degC") = 298.15,
    u_min(
      final unit="K",
      displayUnit="degC") = 282.65,
    u(final unit="K", displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for  leaving water temperture on the secondary side of the heat exchanger in the ETS"
    annotation (Placement(transformation(extent={{520,-40},{540,-20}})));
  Buildings_Requirements.WithinBand reqTHEXETSLeaPri(
    name="ETS",
    text=
        "O-306: At the district heat exchanger in the ETS, the primary side leaving water temperature that is fed back to the district loop must be between 6.5°C and 28°C.",
    delayTime(displayUnit="min") = 300,
    u_max(
      final unit="K",
      displayUnit="degC") = 301.15,
    u_min(
      final unit="K",
      displayUnit="degC") = 279.65,
    u(final unit="K", displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for  leaving water temperature on the primary side of the heat exchanger in the ETS "
    annotation (Placement(transformation(extent={{520,-90},{540,-70}})));
  Buildings_Requirements.WithinBand reqTDomHotWatSupply6(
    name="ETS",
    text="O-307: At the district heat exchanger in the ETS, the primary side water temperature difference must be ± 4 K, with a tolerance of ± 1 K.",
    delayTime(displayUnit="min") = 300,
    u_max(
      final unit="K",
      displayUnit="K") = 5,
    u_min(
      final unit="K",
      displayUnit="K") = 3,
    u(final unit="K", displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirment for temperature difference on the primary side of theheat exchanger in the ETS"
    annotation (Placement(transformation(extent={{520,-200},{540,-180}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{440,-200},{460,-180}})));
  Modelica.Blocks.Math.Abs abs1
    annotation (Placement(transformation(extent={{480,-200},{500,-180}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumEva(
    name="ETS",
    text=
        "O-308: The heat pump evaporator leaving water temperature must be at least 15°C (preferably higher) once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump evaporator leaving water temperature"
    annotation (Placement(transformation(extent={{520,-240},{540,-220}})));
  Buildings_Requirements.GreaterEqual
                            reqTHeaPumCon(
    name="ETS",
    text=
        " O-309: The heat pump condenser leaving water temperature must not exceed 31°C once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump condenser leaving water temperature"
    annotation (Placement(transformation(extent={{520,-280},{540,-260}})));
  Buildings_Requirements.WithinBand reqTWatSer(
    name="Network",
    text=
        "O-401: The water that is served to each service line must be between 10.5°C and 24°C.",
    delayTime(displayUnit="min") = 300,
    u_max(
      final unit="K",
      displayUnit="degC") = 297.15,
    u_min(
      final unit="K",
      displayUnit="degC") = 283.65,
    u(final unit="K", displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirment for heat pump evaporator temperature difference"
    annotation (Placement(transformation(extent={{520,-340},{540,-320}})));
  Buildings_Requirements.GreaterEqual reqPDis(name="Network", text=
        "O-402: The pressure drop in the district loop and the service line must be no bigger than 125 Pa/m at full load.")
    "Requirement for pressure drop in the district loop and the service line"
    annotation (Placement(transformation(extent={{520,-380},{540,-360}})));
  Buildings_Requirements.StableContinuousSignal
                                      reqStaLoaVal(name="Valves",             text=
        "O-202: All control valves must show stable operation.")
    "Requirements to verify stability of control valve at load"
    annotation (Placement(transformation(extent={{520,220},{540,240}})));
  Buildings_Requirements.MinimumDuration
                               reqHeaPumOn(
    name="Heat pump",
    text="O-201_0: The heat pump must operate at least 30 min when activated.",
    durationMin(displayUnit="min") = 1800) "Requirement for heat pump on"
    annotation (Placement(transformation(extent={{520,300},{540,320}})));
  Buildings_Requirements.MinimumDuration
                               reqHeaPumOff(
    name="Heat pump",
    text="O-201_1: The heat pump must remain off for at least 10 minutes.",
    durationMin(displayUnit="min") = 600) "Requirement for heat pump off"
    annotation (Placement(transformation(extent={{520,260},{540,280}})));
  Modelica.Blocks.Sources.RealExpression senTemHot[nBui]
    annotation (Placement(transformation(extent={{480,164},{500,184}})));
  Modelica.Blocks.Sources.RealExpression TTanTop
    annotation (Placement(transformation(extent={{480,120},{500,140}})));
  Modelica.Blocks.Math.Add add1
    annotation (Placement(transformation(extent={{480,70},{500,90}})));
  Modelica.Blocks.Math.Add add2
    annotation (Placement(transformation(extent={{480,20},{500,40}})));
  Modelica.Blocks.Sources.RealExpression realExpression
    annotation (Placement(transformation(extent={{440,76},{460,96}})));
  Modelica.Blocks.Sources.RealExpression realExpression1
    annotation (Placement(transformation(extent={{440,64},{460,84}})));
  Modelica.Blocks.Sources.RealExpression realExpression2
    annotation (Placement(transformation(extent={{440,26},{460,46}})));
  Modelica.Blocks.Sources.RealExpression realExpression3
    annotation (Placement(transformation(extent={{440,14},{460,34}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(h=0.01)
    annotation (Placement(transformation(extent={{480,-260},{500,-240}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr1(h=0.01)
    annotation (Placement(transformation(extent={{480,-300},{500,-280}})));
equation
  connect(add.y, abs1.u)
    annotation (Line(points={{461,-190},{478,-190}},
                                                 color={0,0,127}));
  connect(abs1.y, reqTDomHotWatSupply6.u) annotation (Line(points={{501,-190},{
          510,-190},{510,-186},{519,-186}},
                                  color={0,0,127}));
  connect(TTanTop.y, reqTDomHotWatTan.u) annotation (Line(points={{501,130},{
          510,130},{510,124},{519,124}}, color={0,0,127}));
  connect(add1.y, reqTSHSet.u) annotation (Line(points={{501,80},{510,80},{510,
          74},{519,74}}, color={0,0,127}));
  connect(add2.y, reqTSCSet.u) annotation (Line(points={{501,30},{510,30},{510,
          24},{519,24}}, color={0,0,127}));
  connect(realExpression.y, add1.u1)
    annotation (Line(points={{461,86},{478,86}}, color={0,0,127}));
  connect(realExpression1.y, add1.u2)
    annotation (Line(points={{461,74},{478,74}}, color={0,0,127}));
  connect(realExpression2.y, add2.u1)
    annotation (Line(points={{461,36},{478,36}}, color={0,0,127}));
  connect(realExpression3.y, add2.u2)
    annotation (Line(points={{461,24},{478,24}}, color={0,0,127}));
  connect(senTemHot.y, reqTDomHotWatSupply.u)
    annotation (Line(points={{501,174},{519,174}}, color={0,0,127}));
  connect(greThr.y, reqTHeaPumEva.active) annotation (Line(points={{502,-250},{
          510,-250},{510,-234},{518,-234}}, color={255,0,255}));
  connect(greThr1.y, reqTHeaPumCon.active) annotation (Line(points={{502,-290},
          {510,-290},{510,-274},{518,-274}}, color={255,0,255}));
end FiveHubsPlantMultiFlow_requirements_all;
