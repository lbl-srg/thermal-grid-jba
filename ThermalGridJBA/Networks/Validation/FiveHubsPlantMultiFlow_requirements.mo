within ThermalGridJBA.Networks.Validation;
model FiveHubsPlantMultiFlow_requirements
  extends FiveHubsPlantMultiFlow;
  Buildings_Requirements.WithinBand reqTDomHotWatSupply[nBui](
    name="Domestic hot water supply temperature",
    text=
        "O-301: The domestic hot water supply temperature must be 45°C ± 1 K.",
    delayTime=30,
    u_max(
      final unit="K",
      displayUnit="degC") = 319.15,
    u_min(
      final unit="K",
      displayUnit="degC") = 317.15,
    u(final unit="K", displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirment for heat pump evaporator temperature difference"
    annotation (Placement(transformation(extent={{520,160},{540,180}})));
  Buildings_Requirements.WithinBand reqTDomHotWatSupply1(
    name=
        "The heating water temperature that serves the domestic hot water tank",
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
    "Requirment for heat pump evaporator temperature difference"
    annotation (Placement(transformation(extent={{520,110},{540,130}})));
  Buildings_Requirements.WithinBand reqTDomHotWatSupply2(
    name="Space heating water supply temperature set point tracking ",
    text=
        "O-303_0: The space heating water supply temperature set point must be tracked within ± 1 K once the system is on for 5 minutes.",
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
    "Requirment for heat pump evaporator temperature difference"
    annotation (Placement(transformation(extent={{520,60},{540,80}})));
  Buildings_Requirements.WithinBand reqTDomHotWatSupply3(
    name="Space cooling water supply temperature set point tracking ",
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
    "Requirment for heat pump evaporator temperature difference"
    annotation (Placement(transformation(extent={{520,10},{540,30}})));
  Buildings_Requirements.WithinBand reqTDomHotWatSupply4(
    name="Space cooling water supply temperature set point tracking ",
    text="O-305: At the district heat exchanger in the ETS, the secondary side leaving water temperature that serves the heat pumps must be between 9.5°C and 25°C.",
    delayTime(displayUnit="min") = 300,
    u_max(
      final unit="K",
      displayUnit="degC") = 298.15,
    u_min(
      final unit="K",
      displayUnit="degC") = 282.65,
    u(final unit="K", displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirment for heat pump evaporator temperature difference"
    annotation (Placement(transformation(extent={{520,-40},{540,-20}})));
  Buildings_Requirements.WithinBand reqTDomHotWatSupply5(
    name="Space cooling water supply temperature set point tracking ",
    text="O-306: At the district heat exchanger in the ETS, the primary side leaving water temperature that is fed back to the district loop must be between 6.5°C and 28°C.",
    delayTime(displayUnit="min") = 300,
    u_max(
      final unit="K",
      displayUnit="degC") = 301.15,
    u_min(
      final unit="K",
      displayUnit="degC") = 279.65,
    u(final unit="K", displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirment for heat pump evaporator temperature difference"
    annotation (Placement(transformation(extent={{520,-90},{540,-70}})));
  Buildings_Requirements.WithinBand reqTDomHotWatSupply6(
    name="Space cooling water supply temperature set point tracking ",
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
    "Requirment for heat pump evaporator temperature difference"
    annotation (Placement(transformation(extent={{520,-200},{540,-180}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{440,-200},{460,-180}})));
  Modelica.Blocks.Math.Abs abs1
    annotation (Placement(transformation(extent={{480,-200},{500,-180}})));
  Buildings_Requirements.GreaterEqual
                            reqGasFurLea(
    name="Gas",
    text="O-308: The heat pump evaporator leaving water temperature must be at least 15°C (preferably higher) once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for gas furnace leaving water temperature"
    annotation (Placement(transformation(extent={{520,-240},{540,-220}})));
  Buildings_Requirements.GreaterEqual
                            reqGasFurLea1(
    name="Gas",
    text="O-309: The heat pump condenser leaving water temperature must not exceed 31°C once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for gas furnace leaving water temperature"
    annotation (Placement(transformation(extent={{520,-280},{540,-260}})));
  Buildings_Requirements.WithinBand                reqTDomHotWatSupply7(
    name="Space cooling water supply temperature set point tracking ",
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
  Buildings_Requirements.GreaterEqual reqGasFurLea2(name="Gas", text=
        "O-402: The pressure drop in the district loop and the service line must be no bigger than 125 Pa/m at full load.")
    "Requirement for gas furnace leaving water temperature"
    annotation (Placement(transformation(extent={{520,-380},{540,-360}})));
  Buildings_Requirements.StableContinuousSignal
                                      reqStaLoaVal(name="Supply temperature",
      text="T-O-2.10: All control valves must be stable")
    "Requirements to verify stability of control valve at load"
    annotation (Placement(transformation(extent={{520,300},{540,320}})));
  Buildings_Requirements.MinimumDuration
                               reqHeaPumOn(
    name="Heat pump",
    text="T-O-2.5: Heat pump must operate at least 30 min.",
    durationMin(displayUnit="min") = 1800) "Requirement for heat pump on"
    annotation (Placement(transformation(extent={{520,260},{540,280}})));
  Buildings_Requirements.MinimumDuration
                               reqHeaPumOff(
    name="Heat pump",
    text="T-O-2.5: Heat pump must be off for at least 10 min.",
    durationMin(displayUnit="min") = 600) "Requirement for heat pump off"
    annotation (Placement(transformation(extent={{520,220},{540,240}})));
  Modelica.Blocks.Sources.RealExpression senTemHot[nBui]
    annotation (Placement(transformation(extent={{480,164},{500,184}})));
  Modelica.Blocks.Sources.RealExpression TTanTop
    annotation (Placement(transformation(extent={{480,120},{500,140}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel1(delayTime(displayUnit=
          "min") = 300)
    annotation (Placement(transformation(extent={{480,100},{500,120}})));
  Modelica.Blocks.Sources.BooleanExpression booleanExpression
    annotation (Placement(transformation(extent={{440,100},{460,120}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel2(delayTime(displayUnit=
          "min") = 300)
    annotation (Placement(transformation(extent={{480,46},{500,66}})));
  Modelica.Blocks.Sources.BooleanExpression booleanExpression1
    annotation (Placement(transformation(extent={{440,50},{460,70}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel3(delayTime(displayUnit=
          "min") = 300)
    annotation (Placement(transformation(extent={{480,-4},{500,16}})));
  Modelica.Blocks.Sources.BooleanExpression booleanExpression2
    annotation (Placement(transformation(extent={{440,0},{460,20}})));
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
equation
  connect(add.y, abs1.u)
    annotation (Line(points={{461,-190},{478,-190}},
                                                 color={0,0,127}));
  connect(abs1.y, reqTDomHotWatSupply6.u) annotation (Line(points={{501,-190},{
          510,-190},{510,-186},{519,-186}},
                                  color={0,0,127}));
  connect(TTanTop.y, reqTDomHotWatSupply1.u) annotation (Line(points={{501,130},
          {510,130},{510,124},{519,124}}, color={0,0,127}));
  connect(truDel1.y, reqTDomHotWatSupply1.active) annotation (Line(points={{502,
          110},{512,110},{512,116},{518,116}}, color={255,0,255}));
  connect(booleanExpression.y, truDel1.u)
    annotation (Line(points={{461,110},{478,110}}, color={255,0,255}));
  connect(booleanExpression1.y, truDel2.u) annotation (Line(points={{461,60},{
          470,60},{470,56},{478,56}}, color={255,0,255}));
  connect(truDel2.y, reqTDomHotWatSupply2.active) annotation (Line(points={{502,
          56},{510,56},{510,66},{518,66}}, color={255,0,255}));
  connect(booleanExpression2.y, truDel3.u) annotation (Line(points={{461,10},{
          470,10},{470,6},{478,6}}, color={255,0,255}));
  connect(truDel3.y, reqTDomHotWatSupply3.active) annotation (Line(points={{502,
          6},{510,6},{510,16},{518,16}}, color={255,0,255}));
  connect(add1.y, reqTDomHotWatSupply2.u) annotation (Line(points={{501,80},{
          510,80},{510,74},{519,74}}, color={0,0,127}));
  connect(add2.y, reqTDomHotWatSupply3.u) annotation (Line(points={{501,30},{
          510,30},{510,24},{519,24}}, color={0,0,127}));
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
end FiveHubsPlantMultiFlow_requirements;
