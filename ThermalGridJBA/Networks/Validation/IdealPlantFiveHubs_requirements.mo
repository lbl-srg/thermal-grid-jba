within ThermalGridJBA.Networks.Validation;
model IdealPlantFiveHubs_requirements
  extends IdealPlantFiveHubs;

  Real fracPL[nBui + 2] "The pressure drop per length unti (Pa/m)";
  Real y_value[19] "Valves actuator values";

  Modelica.Blocks.Sources.RealExpression senTemDhwSup[nBui](y={45 + 273.15,bui[2].ets.dhw.domHotWatTan.senTemHot.T,
        bui[3].ets.dhw.domHotWatTan.senTemHot.T,bui[4].ets.dhw.domHotWatTan.senTemHot.T,
        bui[5].ets.dhw.domHotWatTan.senTemHot.T})
    annotation (Placement(transformation(extent={{460,222},{480,242}})));
  Buildings_Requirements.WithinBand reqTDhwSup[nBui](
    name="DHW",
    text="O-301: The domestic hot water supply temperature must be 45°C ± 1 K.",
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
    annotation (Placement(transformation(extent={{500,220},{520,240}})));
  Buildings_Requirements.WithinBand reqTDhwTan[nBui](
    name="DHW",
    text="O-302: The heating water temperature that serves the domestic hot water tank must be 50°C ± 1 K once the tank charging is on for 5 minutes.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="degC") = 324.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 322.15,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for The heating water temperature that serves the domestic hot water tank"
    annotation (Placement(transformation(extent={{500,160},{520,180}})));
  Modelica.Blocks.Sources.RealExpression TTanTop[nBui](y={50 + 273.15,bui[2].ets.dhw.domHotWatTan.TTanTop.T,
        bui[3].ets.dhw.domHotWatTan.TTanTop.T,bui[4].ets.dhw.domHotWatTan.TTanTop.T,
        bui[5].ets.dhw.domHotWatTan.TTanTop.T})
    annotation (Placement(transformation(extent={{460,170},{480,190}})));
  Modelica.Blocks.Sources.BooleanExpression DhwTanCha[nBui](y={false,bui[2].ets.dhw.charge,
        bui[3].ets.dhw.charge,bui[4].ets.dhw.charge,bui[5].ets.dhw.charge})
    annotation (Placement(transformation(extent={{460,150},{480,170}})));
  Modelica.Blocks.Sources.RealExpression THexSecLvg[nBui](y=bui.ets.hex.senT2WatLvg.T)
    annotation (Placement(transformation(extent={{460,120},{480,140}})));
  Buildings_Requirements.WithinBand_old reqTHexEtsPriLvg[nBui](
    name="ETS",
    text=
        "O-306: At the district heat exchanger in the ETS, the primary side leaving water temperature that is fed back to the district loop must be between 6.5°C and 28°C.",
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="degC") = 301.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 279.65,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for  leaving water temperature on the primary side of the heat exchanger in the ETS "
    annotation (Placement(transformation(extent={{500,80},{520,100}})));
  Modelica.Blocks.Sources.RealExpression THexWatEnt[nBui](y=bui.ets.hex.senT2WatEnt.T)
    annotation (Placement(transformation(extent={{460,-400},{480,-380}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumEvaLvg[nBui](
    name="ETS",
    text="O-308: The heat pump evaporator leaving water temperature must be at least 15°C (preferably higher) once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump evaporator leaving water temperature"
    annotation (Placement(transformation(extent={{500,20},{520,40}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumConLvg[nBui](
    name="ETS",
    text=" O-309: The heat pump condenser leaving water temperature must not exceed 31°C once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump condenser leaving water temperature"
    annotation (Placement(transformation(extent={{500,-60},{520,-40}})));
  Buildings_Requirements.WithinBand reqTWatSer[nBui](
    name="Network",
    text=
        "O-401: The water that is served to each service line must be between 10.5°C and 24°C.",
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="degC") = 297.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 283.65,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for heat pump evaporator temperature difference"
    annotation (Placement(transformation(extent={{500,-400},{520,-380}})));
  Modelica.Blocks.Sources.RealExpression THeaPumEvaLvg[nBui](y=bui.ets.chi.senTEvaLvg.T)
    annotation (Placement(transformation(extent={{460,40},{480,60}})));
  Modelica.Blocks.Sources.RealExpression THeaPumCon[nBui](y=bui.ets.chi.senTConLvg.T)
    annotation (Placement(transformation(extent={{460,-60},{480,-40}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valEvaOpen[nBui](h=0.01)
    annotation (Placement(transformation(extent={{460,-10},{480,10}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valConOpen[nBui](h=0.01)
    annotation (Placement(transformation(extent={{460,-90},{480,-70}})));
  Modelica.Blocks.Sources.RealExpression valIsoEvaPos[nBui](y=bui.ets.valIsoEva.y_actual)
    annotation (Placement(transformation(extent={{420,-10},{440,10}})));
  Modelica.Blocks.Sources.RealExpression valIsoConPos[nBui](y=bui.ets.valIsoCon.y_actual)
    annotation (Placement(transformation(extent={{420,-90},{440,-70}})));
  Modelica.Blocks.Sources.Constant TmaxHeaPumConLvg[nBui](k=31 + 273.15)
    annotation (Placement(transformation(extent={{460,-40},{480,-20}})));
  Modelica.Blocks.Sources.Constant TminHeaPumEva[nBui](k=15 + 273.15)
    annotation (Placement(transformation(extent={{460,20},{480,40}})));
  Buildings_Requirements.WithinBand reqTPlaMix(
    name="Central plant",
    text="O-503: The mixing water temperature in the district loop after the central plant must be between 10.5°C and 24°C.",
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="degC") = 297.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 283.65,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for mixing water temperature in the district loop after the central plant"
    annotation (Placement(transformation(extent={{500,-600},{520,-580}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOn[nBui](
    name="Heat pump",
    text="O-201_0: The heat pump must operate at least 30 min when activated.",
    durationMin(displayUnit="min") = 1800) "Requirement for heat pump on"
    annotation (Placement(transformation(extent={{500,300},{520,320}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOff[nBui](
    name="Heat pump",
    text="O-201_1: The heat pump must remain off for at least 10 minutes.",
    durationMin(displayUnit="min") = 600) "Requirement for heat pump off"
    annotation (Placement(transformation(extent={{500,260},{520,280}})));
  Modelica.Blocks.Logical.Not HeaPumOff[nBui]
    annotation (Placement(transformation(extent={{460,260},{480,280}})));
  Modelica.Blocks.Sources.BooleanExpression HeaPumOn[nBui](y=bui.ets.chi.con.yPum)
    annotation (Placement(transformation(extent={{420,300},{440,320}})));
  Buildings_Requirements.GreaterEqual reqPDis[nBui + 2](name="District loop",
      text="O-402: The pressure drop in the district loop and the service line must be no bigger than 125 Pa/m at full load.")
    "Requirement for pressure drop in the district loop"
    annotation (Placement(transformation(extent={{500,-460},{520,-440}})));
  Modelica.Blocks.Sources.RealExpression PDis[nBui + 2](y=fracPL)
    annotation (Placement(transformation(extent={{460,-480},{480,-460}})));
  Modelica.Blocks.Sources.Constant fracPLMax[nBui + 2](k=125)
    annotation (Placement(transformation(extent={{460,-440},{480,-420}})));
  Buildings_Requirements.WithinBand reqTHea[nBui](
    name="ETS",
    text="O-303: The space heating water supply temperature set point must be tracked within ± 1 K once the system is on for 5 minutes.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="K") = 1,
    u_min(
      final unit="K",
      each displayUnit="K") = 1,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for tracking the space heating water supply temperature set point"
    annotation (Placement(transformation(extent={{500,-520},{520,-500}})));
  Buildings_Requirements.WithinBand reqTCoo[nBui](
    name="ETS",
    text="O-304: The space cooling water supply temperature set point must be tracked within ± 1 K once the system is on for 5 minutes.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="K") = 1,
    u_min(
      final unit="K",
      each displayUnit="K") = 1,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for tracking the space cooling water supply temperature set point"
    annotation (Placement(transformation(extent={{500,-570},{520,-550}})));
  Modelica.Blocks.Math.Add THeaDiff[nBui](k2=-1)
    annotation (Placement(transformation(extent={{460,-510},{480,-490}})));
  Modelica.Blocks.Math.Add TCooDiff[nBui](k2=-1)
    annotation (Placement(transformation(extent={{460,-560},{480,-540}})));
  Modelica.Blocks.Sources.RealExpression THeaSup[nBui](y=bui.bui.disFloHea.senTSup.T)
    annotation (Placement(transformation(extent={{420,-504},{440,-484}})));
  Modelica.Blocks.Sources.RealExpression THeaSupSet[nBui](y=bui.THeaWatSupSet.y)
    annotation (Placement(transformation(extent={{420,-516},{440,-496}})));
  Modelica.Blocks.Sources.BooleanExpression BooOn[nBui](y=true)
    annotation (Placement(transformation(extent={{360,-540},{380,-520}})));
  Modelica.Blocks.Sources.RealExpression TCooSup[nBui](y=bui.bui.disFloCoo.senTSup.T)
    annotation (Placement(transformation(extent={{420,-554},{440,-534}})));
  Modelica.Blocks.Sources.RealExpression TCooSupSet[nBui](y=bui.TChiWatSupSet.y)
    annotation (Placement(transformation(extent={{420,-566},{440,-546}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage TRooHeaAvg60min[nBui](delta(
        each displayUnit="min") = 3600)
    annotation (Placement(transformation(extent={{460,-160},{480,-140}})));
  Modelica.Blocks.Sources.RealExpression TRooHea[nBui](y=bui.bui.terUniHea.TLoaODE.TAir)
    annotation (Placement(transformation(extent={{380,-190},{400,-170}})));
  Modelica.Blocks.Sources.RealExpression TRooHeaSet[nBui](y=bui.bui.terUniHea.TLoaODE.TSet)
    annotation (Placement(transformation(extent={{380,-150},{400,-130}})));
  Modelica.Blocks.Math.Add TRooHeaDif[nBui](k2=-1)
    annotation (Placement(transformation(extent={{420,-170},{440,-150}})));
  Modelica.Blocks.Continuous.Integrator TRooHeaAvgYea[nBui]
    annotation (Placement(transformation(extent={{460,-220},{480,-200}})));
  Modelica.Blocks.Sources.BooleanExpression last_value[nBui](y=terminal())
    annotation (Placement(transformation(extent={{380,-240},{400,-220}})));
  Buildings_Requirements.WithinBand reqTHexEtsSecLvg[nBui](
    name="ETS",
    text="O-305: At the district heat exchanger in the ETS, the secondary side leaving water temperature that serves the heat pumps must be between 9.5°C and 25°C.",
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="degC") = 298.15,
    u_min(
      final unit="K",
      each displayUnit="degC") = 282.65,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for leaving water temperature on the secondary side of the heat exchanger in the ETS "
    annotation (Placement(transformation(extent={{500,120},{520,140}})));
  Modelica.Blocks.Sources.RealExpression THexPriLvg[nBui](y=dis.con.senTOut.T)
    annotation (Placement(transformation(extent={{460,80},{480,100}})));
  Buildings_Requirements.GreaterEqual reqTRooHea[nBui](
    name="Room",
    text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for heating"
    annotation (Placement(transformation(extent={{500,-160},{520,-140}})));
  Modelica.Blocks.Sources.Constant TRooHeaDifMax[nBui](k=0.5)
    annotation (Placement(transformation(extent={{460,-130},{480,-110}})));
  Buildings_Requirements.GreaterEqual reqTRooHeaAvg[nBui](
    name="Room",
    text="O-353_0: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    use_activeInput=true,
    delayTime(each displayUnit="s") = 0)
    "Requirement for the room temperature for heating (yearly average)"
    annotation (Placement(transformation(extent={{500,-208},{520,-188}})));
  Modelica.Blocks.Sources.Constant TRooHeaDifYea[nBui](k=0.05)
    annotation (Placement(transformation(extent={{460,-190},{480,-170}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage TRooCooAvg60min[nBui](delta(
        each displayUnit="min") = 3600)
    annotation (Placement(transformation(extent={{460,-300},{480,-280}})));
  Modelica.Blocks.Sources.RealExpression TRooCoo[nBui](y=bui.bui.terUniCoo.TLoaODE.TAir)
    annotation (Placement(transformation(extent={{380,-330},{400,-310}})));
  Modelica.Blocks.Sources.RealExpression TRooCooSet[nBui](y=bui.bui.terUniCoo.TLoaODE.TSet)
    annotation (Placement(transformation(extent={{380,-290},{400,-270}})));
  Modelica.Blocks.Math.Add TRooCooDif[nBui](k1=-1)
    annotation (Placement(transformation(extent={{420,-310},{440,-290}})));
  Modelica.Blocks.Continuous.Integrator TRooCooAvgYea[nBui]
    annotation (Placement(transformation(extent={{460,-360},{480,-340}})));
  Buildings_Requirements.GreaterEqual reqTRooCoo[nBui](
    name="Room",
    text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for cooling"
    annotation (Placement(transformation(extent={{500,-300},{520,-280}})));
  Modelica.Blocks.Sources.Constant TRooCooDifMax[nBui](k=0.5)
    annotation (Placement(transformation(extent={{460,-270},{480,-250}})));
  Buildings_Requirements.GreaterEqual reqTRooCooAvg[nBui](
    name="Room",
    text="O-353: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    use_activeInput=true,
    delayTime(each displayUnit="s") = 0)
    "Requirement for the room temperature for cooling (yearly average)"
    annotation (Placement(transformation(extent={{500,-348},{520,-328}})));
  Modelica.Blocks.Sources.Constant TRooCooDifYea[nBui](k=0.05)
    annotation (Placement(transformation(extent={{460,-330},{480,-310}})));
  Buildings_Requirements.StableContinuousSignal reqStaVal[19](name="Valves",
      text="O-202: All control valves must show stable operation.")
    "Requirements to verify stability of control valves"
    annotation (Placement(transformation(extent={{500,340},{520,360}})));
  Modelica.Blocks.Sources.RealExpression Valy[19](y=y_value)
    annotation (Placement(transformation(extent={{460,344},{480,364}})));
equation
  for i in 1:5 loop
    fracPL[i] = dis.con[i].pipDis.dp / dis.con[i].pipDis.length;

    y_value[i] = bui[i].ets.hex.val2.y_actual;
    y_value[i+5] = bui[i].ets.chi.valEva.y_actual;
    y_value[i+10] = bui[i].ets.chi.valCon.y_actual;

  end for;

  fracPL[6] = dis.pipEnd.dp / dis.pipEnd.length;
  fracPL[7] = conPla.pipDis.dp / conPla.pipDis.length;

  y_value[16] = bui[2].ets.dhw.domHotWatTan.divVal.y_actual;
  y_value[17] = bui[3].ets.dhw.domHotWatTan.divVal.y_actual;
  y_value[18] = bui[4].ets.dhw.domHotWatTan.divVal.y_actual;
  y_value[19] = bui[5].ets.dhw.domHotWatTan.divVal.y_actual;

  connect(senTemDhwSup.y, reqTDhwSup.u) annotation (Line(points={{481,232},{488,
          232},{488,234},{499,234}}, color={0,0,127}));
  connect(valEvaOpen.y, reqTHeaPumEvaLvg.active) annotation (Line(points={{482,0},
          {490,0},{490,26},{498,26}}, color={255,0,255}));
  connect(valConOpen.y, reqTHeaPumConLvg.active) annotation (Line(points={{482,-80},
          {492,-80},{492,-54},{498,-54}}, color={255,0,255}));
  connect(valIsoConPos.y, valConOpen.u)
    annotation (Line(points={{441,-80},{458,-80}},   color={0,0,127}));
  connect(valIsoEvaPos.y, valEvaOpen.u)
    annotation (Line(points={{441,0},{458,0}},     color={0,0,127}));
  connect(THeaPumEvaLvg.y, reqTHeaPumEvaLvg.u_max) annotation (Line(points={{481,
          50},{490,50},{490,36},{499,36}}, color={0,0,127}));
  connect(TmaxHeaPumConLvg.y, reqTHeaPumConLvg.u_max) annotation (Line(points={{
          481,-30},{492,-30},{492,-44},{499,-44}}, color={0,0,127}));
  connect(THeaPumCon.y, reqTHeaPumConLvg.u_min) annotation (Line(points={{481,-50},
          {492,-50},{492,-48},{499,-48}}, color={0,0,127}));
  connect(THexWatEnt.y, reqTWatSer.u) annotation (Line(points={{481,-390},{490,-390},
          {490,-386},{499,-386}}, color={0,0,127}));
  connect(TDisWatSup.T, reqTPlaMix.u) annotation (Line(points={{-91,20},{-104,20},
          {-104,-586},{499,-586}}, color={0,0,127}));
  connect(TTanTop.y, reqTDhwTan.u) annotation (Line(points={{481,180},{490,180},
          {490,174},{499,174}}, color={0,0,127}));
  connect(DhwTanCha.y, reqTDhwTan.active) annotation (Line(points={{481,160},{492,
          160},{492,166},{498,166}}, color={255,0,255}));
  connect(TminHeaPumEva.y, reqTHeaPumEvaLvg.u_min) annotation (Line(points={{481,
          30},{490,30},{490,32},{499,32}}, color={0,0,127}));
  connect(HeaPumOn.y, reqHeaPumOn.u)
    annotation (Line(points={{441,310},{498,310}}, color={255,0,255}));
  connect(HeaPumOff.y, reqHeaPumOff.u)
    annotation (Line(points={{481,270},{498,270}}, color={255,0,255}));
  connect(HeaPumOn.y, HeaPumOff.u) annotation (Line(points={{441,310},{450,310},
          {450,270},{458,270}}, color={255,0,255}));
  connect(fracPLMax.y, reqPDis.u_max) annotation (Line(points={{481,-430},{490,-430},
          {490,-444},{499,-444}}, color={0,0,127}));
  connect(PDis.y, reqPDis.u_min) annotation (Line(points={{481,-470},{490,-470},
          {490,-448},{499,-448}}, color={0,0,127}));
  connect(THeaDiff.y, reqTHea.u) annotation (Line(points={{481,-500},{490,-500},
          {490,-506},{499,-506}}, color={0,0,127}));
  connect(TCooDiff.y, reqTCoo.u) annotation (Line(points={{481,-550},{490,-550},
          {490,-556},{499,-556}}, color={0,0,127}));
  connect(BooOn.y, reqTHea.active) annotation (Line(points={{381,-530},{408,-530},
          {408,-514},{498,-514}}, color={255,0,255}));
  connect(BooOn.y, reqTCoo.active) annotation (Line(points={{381,-530},{408,-530},
          {408,-564},{498,-564}}, color={255,0,255}));
  connect(TCooSup.y, TCooDiff.u1)
    annotation (Line(points={{441,-544},{458,-544}}, color={0,0,127}));
  connect(TCooSupSet.y, TCooDiff.u2)
    annotation (Line(points={{441,-556},{458,-556}}, color={0,0,127}));
  connect(THeaSup.y, THeaDiff.u1)
    annotation (Line(points={{441,-494},{458,-494}}, color={0,0,127}));
  connect(THeaSupSet.y, THeaDiff.u2)
    annotation (Line(points={{441,-506},{458,-506}}, color={0,0,127}));
  connect(TRooHeaSet.y, TRooHeaDif.u1) annotation (Line(points={{401,-140},{408,
          -140},{408,-154},{418,-154}}, color={0,0,127}));
  connect(TRooHea.y, TRooHeaDif.u2) annotation (Line(points={{401,-180},{408,-180},
          {408,-166},{418,-166}}, color={0,0,127}));
  connect(TRooHeaDif.y, TRooHeaAvg60min.u) annotation (Line(points={{441,-160},{
          450,-160},{450,-150},{458,-150}}, color={0,0,127}));
  connect(TRooHeaDif.y, TRooHeaAvgYea.u) annotation (Line(points={{441,-160},{450,
          -160},{450,-210},{458,-210}}, color={0,0,127}));
  connect(THexSecLvg.y, reqTHexEtsSecLvg.u) annotation (Line(points={{481,130},{
          492,130},{492,134},{499,134}}, color={0,0,127}));
  connect(THexPriLvg.y, reqTHexEtsPriLvg.u) annotation (Line(points={{481,90},{490,
          90},{490,94},{499,94}}, color={0,0,127}));
  connect(TRooHeaAvg60min.y, reqTRooHea.u_min) annotation (Line(points={{482,-150},
          {490,-150},{490,-148},{499,-148}}, color={0,0,127}));
  connect(TRooHeaDifMax.y, reqTRooHea.u_max) annotation (Line(points={{481,-120},
          {490,-120},{490,-144},{499,-144}}, color={0,0,127}));
  connect(TRooHeaDifYea.y, reqTRooHeaAvg.u_max) annotation (Line(points={{481,-180},
          {490,-180},{490,-192},{499,-192}}, color={0,0,127}));
  connect(TRooHeaAvgYea.y, reqTRooHeaAvg.u_min) annotation (Line(points={{481,-210},
          {490,-210},{490,-196},{499,-196}}, color={0,0,127}));
  connect(last_value.y, reqTRooHeaAvg.active) annotation (Line(points={{401,-230},
          {494,-230},{494,-202},{498,-202}}, color={255,0,255}));
  connect(TRooCooSet.y, TRooCooDif.u1) annotation (Line(points={{401,-280},{410,
          -280},{410,-294},{418,-294}}, color={0,0,127}));
  connect(TRooCoo.y, TRooCooDif.u2) annotation (Line(points={{401,-320},{410,-320},
          {410,-306},{418,-306}}, color={0,0,127}));
  connect(TRooCooDif.y, TRooCooAvg60min.u) annotation (Line(points={{441,-300},{
          450,-300},{450,-290},{458,-290}}, color={0,0,127}));
  connect(TRooCooDif.y, TRooCooAvgYea.u) annotation (Line(points={{441,-300},{450,
          -300},{450,-350},{458,-350}}, color={0,0,127}));
  connect(TRooCooAvg60min.y, reqTRooCoo.u_min) annotation (Line(points={{482,-290},
          {490,-290},{490,-288},{499,-288}}, color={0,0,127}));
  connect(TRooCooDifMax.y, reqTRooCoo.u_max) annotation (Line(points={{481,-260},
          {490,-260},{490,-284},{499,-284}}, color={0,0,127}));
  connect(TRooCooDifYea.y, reqTRooCooAvg.u_max) annotation (Line(points={{481,-320},
          {490,-320},{490,-332},{499,-332}}, color={0,0,127}));
  connect(TRooCooAvgYea.y, reqTRooCooAvg.u_min) annotation (Line(points={{481,-350},
          {490,-350},{490,-336},{499,-336}}, color={0,0,127}));
  connect(last_value.y, reqTRooCooAvg.active) annotation (Line(points={{401,-230},
          {494,-230},{494,-342},{498,-342}}, color={255,0,255}));
  connect(BooOn.y, reqTRooCoo.active) annotation (Line(points={{381,-530},{408,-530},
          {408,-610},{540,-610},{540,-310},{490,-310},{490,-294},{498,-294}},
        color={255,0,255}));
  connect(BooOn.y, reqTRooHea.active) annotation (Line(points={{381,-530},{408,-530},
          {408,-610},{540,-610},{540,-170},{490,-170},{490,-154},{498,-154}},
        color={255,0,255}));
  connect(Valy.y,reqStaVal. u)
    annotation (Line(points={{481,354},{499,354}}, color={0,0,127}));
end IdealPlantFiveHubs_requirements;
