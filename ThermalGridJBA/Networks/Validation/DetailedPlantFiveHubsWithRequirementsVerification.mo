within ThermalGridJBA.Networks.Validation;
model DetailedPlantFiveHubsWithRequirementsVerification
  extends DetailedPlantFiveHubs;
  Real fracPL[nBui + 2] "The pressure drop per length unti (Pa/m)";
  Real y_value[19] "Valves actuator values";
  Modelica.Blocks.Sources.RealExpression senTemDhwSup[nBui](y={45 + 273.15,bui[2].ets.dhw.domHotWatTan.senTemHot.T,
        bui[3].ets.dhw.domHotWatTan.senTemHot.T,bui[4].ets.dhw.domHotWatTan.senTemHot.T,
        bui[5].ets.dhw.domHotWatTan.senTemHot.T})
    annotation (Placement(transformation(extent={{500,362},{520,382}})));
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
    annotation (Placement(transformation(extent={{540,360},{560,380}})));
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
    annotation (Placement(transformation(extent={{540,300},{560,320}})));
  Modelica.Blocks.Sources.RealExpression TTanTop[nBui](y={50 + 273.15,bui[2].ets.dhw.domHotWatTan.TTanTop.T,
        bui[3].ets.dhw.domHotWatTan.TTanTop.T,bui[4].ets.dhw.domHotWatTan.TTanTop.T,
        bui[5].ets.dhw.domHotWatTan.TTanTop.T})
    annotation (Placement(transformation(extent={{500,310},{520,330}})));
  Modelica.Blocks.Sources.BooleanExpression DhwTanCha[nBui](y={false,bui[2].ets.dhw.charge,
        bui[3].ets.dhw.charge,bui[4].ets.dhw.charge,bui[5].ets.dhw.charge})
    annotation (Placement(transformation(extent={{500,290},{520,310}})));
  Modelica.Blocks.Sources.RealExpression THexSecLvg[nBui](y=bui.ets.hex.senT2WatLvg.T)
    annotation (Placement(transformation(extent={{500,260},{520,280}})));
  Buildings_Requirements.WithinBand     reqTHexEtsPriLvg[nBui](
    name="ETS",
    text="O-306: At the district heat exchanger in the ETS, the primary side leaving water temperature that is fed back to the district loop must be between 6.5°C and 28°C.",
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
    annotation (Placement(transformation(extent={{540,220},{560,240}})));
  Modelica.Blocks.Sources.RealExpression THexWatEnt[nBui](y=bui.ets.hex.senT2WatEnt.T)
    annotation (Placement(transformation(extent={{500,-260},{520,-240}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumEvaLvg[nBui](
    name="ETS",
    text="O-308: The heat pump evaporator leaving water temperature must be at least 15°C (preferably higher) once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump evaporator leaving water temperature"
    annotation (Placement(transformation(extent={{540,160},{560,180}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumConLvg[nBui](
    name="ETS",
    text=" O-309: The heat pump condenser leaving water temperature must not exceed 31°C once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump condenser leaving water temperature"
    annotation (Placement(transformation(extent={{540,80},{560,100}})));
  Buildings_Requirements.WithinBand reqTWatSer[nBui](
    name="Network",
    text="O-401: The water that is served to each service line must be between 10.5°C and 24°C.",
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
    annotation (Placement(transformation(extent={{540,-260},{560,-240}})));
  Modelica.Blocks.Sources.RealExpression THeaPumEvaLvg[nBui](y=bui.ets.chi.senTEvaLvg.T)
    annotation (Placement(transformation(extent={{500,180},{520,200}})));
  Modelica.Blocks.Sources.RealExpression THeaPumCon[nBui](y=bui.ets.chi.senTConLvg.T)
    annotation (Placement(transformation(extent={{500,80},{520,100}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valEvaOpen[nBui](h=0.01)
    annotation (Placement(transformation(extent={{500,130},{520,150}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valConOpen[nBui](h=0.01)
    annotation (Placement(transformation(extent={{500,50},{520,70}})));
  Modelica.Blocks.Sources.RealExpression valIsoEvaPos[nBui](y=bui.ets.valIsoEva.y_actual)
    annotation (Placement(transformation(extent={{460,130},{480,150}})));
  Modelica.Blocks.Sources.RealExpression valIsoConPos[nBui](y=bui.ets.valIsoCon.y_actual)
    annotation (Placement(transformation(extent={{460,50},{480,70}})));
  Modelica.Blocks.Sources.Constant TmaxHeaPumConLvg[nBui](k=31 + 273.15)
    annotation (Placement(transformation(extent={{500,100},{520,120}})));
  Modelica.Blocks.Sources.Constant TminHeaPumEva[nBui](k=15 + 273.15)
    annotation (Placement(transformation(extent={{500,160},{520,180}})));
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
    annotation (Placement(transformation(extent={{540,-460},{560,-440}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOn[nBui](
    name="Heat pump",
    text="O-201_0: The heat pump must operate at least 30 min when activated.",
    durationMin(displayUnit="min") = 1800) "Requirement for heat pump on"
    annotation (Placement(transformation(extent={{540,440},{560,460}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOff[nBui](
    name="Heat pump",
    text="O-201_1: The heat pump must remain off for at least 10 minutes.",
    durationMin(displayUnit="min") = 600) "Requirement for heat pump off"
    annotation (Placement(transformation(extent={{540,400},{560,420}})));
  Modelica.Blocks.Logical.Not HeaPumOff[nBui]
    annotation (Placement(transformation(extent={{500,400},{520,420}})));
  Modelica.Blocks.Sources.BooleanExpression HeaPumOn[nBui](y=bui.ets.chi.con.yPum)
    annotation (Placement(transformation(extent={{460,440},{480,460}})));
  Buildings_Requirements.GreaterEqual reqPDis[nBui + 2](name="District loop",
      text="O-402: The pressure drop in the district loop and the service line must be no bigger than 125 Pa/m at full load.")
    "Requirement for pressure drop in the district loop"
    annotation (Placement(transformation(extent={{540,-320},{560,-300}})));
  Modelica.Blocks.Sources.RealExpression PDis[nBui + 2](y=fracPL)
    annotation (Placement(transformation(extent={{500,-340},{520,-320}})));
  Modelica.Blocks.Sources.Constant fracPLMax[nBui + 2](k=125)
    annotation (Placement(transformation(extent={{500,-300},{520,-280}})));
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
    annotation (Placement(transformation(extent={{540,-380},{560,-360}})));
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
    annotation (Placement(transformation(extent={{540,-430},{560,-410}})));
  Modelica.Blocks.Math.Add THeaDiff[nBui](k2=-1)
    annotation (Placement(transformation(extent={{500,-370},{520,-350}})));
  Modelica.Blocks.Math.Add TCooDiff[nBui](k2=-1)
    annotation (Placement(transformation(extent={{500,-420},{520,-400}})));
  Modelica.Blocks.Sources.RealExpression THeaSup[nBui](y=bui.bui.disFloHea.senTSup.T)
    annotation (Placement(transformation(extent={{460,-364},{480,-344}})));
  Modelica.Blocks.Sources.RealExpression THeaSupSet[nBui](y=bui.THeaWatSupSet.y)
    annotation (Placement(transformation(extent={{460,-376},{480,-356}})));
  Modelica.Blocks.Sources.BooleanExpression BooOn[nBui](y=true)
    annotation (Placement(transformation(extent={{400,-400},{420,-380}})));
  Modelica.Blocks.Sources.RealExpression TCooSup[nBui](y=bui.bui.disFloCoo.senTSup.T)
    annotation (Placement(transformation(extent={{460,-414},{480,-394}})));
  Modelica.Blocks.Sources.RealExpression TCooSupSet[nBui](y=bui.TChiWatSupSet.y)
    annotation (Placement(transformation(extent={{460,-426},{480,-406}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage TRooHeaAvg60min[nBui](delta(
        each displayUnit="min") = 3600)
    annotation (Placement(transformation(extent={{500,-20},{520,0}})));
  Modelica.Blocks.Sources.RealExpression TRooHea[nBui](y=bui.bui.terUniHea.TLoaODE.TAir)
    annotation (Placement(transformation(extent={{420,-50},{440,-30}})));
  Modelica.Blocks.Sources.RealExpression TRooHeaSet[nBui](y=bui.bui.terUniHea.TLoaODE.TSet)
    annotation (Placement(transformation(extent={{420,-10},{440,10}})));
  Modelica.Blocks.Math.Add TRooHeaDif[nBui](k2=-1)
    annotation (Placement(transformation(extent={{460,-30},{480,-10}})));
  Modelica.Blocks.Continuous.Integrator TRooHeaAvgYea[nBui]
    annotation (Placement(transformation(extent={{500,-80},{520,-60}})));
  Modelica.Blocks.Sources.BooleanExpression last_value[nBui](y=terminal())
    annotation (Placement(transformation(extent={{420,-100},{440,-80}})));
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
    annotation (Placement(transformation(extent={{540,260},{560,280}})));
  Modelica.Blocks.Sources.RealExpression THexPriLvg[nBui](y=dis.con.senTOut.T)
    annotation (Placement(transformation(extent={{500,220},{520,240}})));
  Buildings_Requirements.GreaterEqual reqTRooHea[nBui](
    name="Room",
    text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for heating"
    annotation (Placement(transformation(extent={{540,-20},{560,0}})));
  Modelica.Blocks.Sources.Constant TRooHeaDifMax[nBui](k=0.5)
    annotation (Placement(transformation(extent={{500,10},{520,30}})));
  Buildings_Requirements.GreaterEqual reqTRooHeaAvg[nBui](
    name="Room",
    text="O-353_0: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    use_activeInput=true,
    delayTime(each displayUnit="s") = 0)
    "Requirement for the room temperature for heating (yearly average)"
    annotation (Placement(transformation(extent={{540,-68},{560,-48}})));
  Modelica.Blocks.Sources.Constant TRooHeaDifYea[nBui](k=0.05)
    annotation (Placement(transformation(extent={{500,-50},{520,-30}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage TRooCooAvg60min[nBui](delta(
        each displayUnit="min") = 3600)
    annotation (Placement(transformation(extent={{500,-160},{520,-140}})));
  Modelica.Blocks.Sources.RealExpression TRooCoo[nBui](y=bui.bui.terUniCoo.TLoaODE.TAir)
    annotation (Placement(transformation(extent={{420,-190},{440,-170}})));
  Modelica.Blocks.Sources.RealExpression TRooCooSet[nBui](y=bui.bui.terUniCoo.TLoaODE.TSet)
    annotation (Placement(transformation(extent={{420,-150},{440,-130}})));
  Modelica.Blocks.Math.Add TRooCooDif[nBui](k1=-1)
    annotation (Placement(transformation(extent={{460,-170},{480,-150}})));
  Modelica.Blocks.Continuous.Integrator TRooCooAvgYea[nBui]
    annotation (Placement(transformation(extent={{500,-220},{520,-200}})));
  Buildings_Requirements.GreaterEqual reqTRooCoo[nBui](
    name="Room",
    text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for cooling"
    annotation (Placement(transformation(extent={{540,-160},{560,-140}})));
  Modelica.Blocks.Sources.Constant TRooCooDifMax[nBui](k=0.5)
    annotation (Placement(transformation(extent={{500,-130},{520,-110}})));
  Buildings_Requirements.GreaterEqual reqTRooCooAvg[nBui](
    name="Room",
    text="O-353: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    use_activeInput=true,
    delayTime(each displayUnit="s") = 0)
    "Requirement for the room temperature for cooling (yearly average)"
    annotation (Placement(transformation(extent={{540,-208},{560,-188}})));
  Modelica.Blocks.Sources.Constant TRooCooDifYea[nBui](k=0.05)
    annotation (Placement(transformation(extent={{500,-190},{520,-170}})));
  Buildings_Requirements.StableContinuousSignal reqStaVal[19](name="Valves",
      text="O-202: All control valves must show stable operation.")
    "Requirements to verify stability of control valves"
    annotation (Placement(transformation(extent={{540,480},{560,500}})));
  Modelica.Blocks.Sources.RealExpression Valy[19](y=y_value)
    annotation (Placement(transformation(extent={{500,484},{520,504}})));
equation
  for i in 1:nBui loop
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

  connect(senTemDhwSup.y,reqTDhwSup. u) annotation (Line(points={{521,372},{528,
          372},{528,374},{539,374}}, color={0,0,127}));
  connect(valEvaOpen.y,reqTHeaPumEvaLvg. active) annotation (Line(points={{522,140},
          {530,140},{530,166},{538,166}},
                                      color={255,0,255}));
  connect(valConOpen.y,reqTHeaPumConLvg. active) annotation (Line(points={{522,60},
          {532,60},{532,86},{538,86}},    color={255,0,255}));
  connect(valIsoConPos.y,valConOpen. u)
    annotation (Line(points={{481,60},{498,60}},     color={0,0,127}));
  connect(valIsoEvaPos.y,valEvaOpen. u)
    annotation (Line(points={{481,140},{498,140}}, color={0,0,127}));
  connect(THeaPumEvaLvg.y,reqTHeaPumEvaLvg. u_max) annotation (Line(points={{521,190},
          {530,190},{530,176},{539,176}},  color={0,0,127}));
  connect(TmaxHeaPumConLvg.y,reqTHeaPumConLvg. u_max) annotation (Line(points={{521,110},
          {532,110},{532,96},{539,96}},            color={0,0,127}));
  connect(THeaPumCon.y,reqTHeaPumConLvg. u_min) annotation (Line(points={{521,90},
          {532,90},{532,92},{539,92}},    color={0,0,127}));
  connect(THexWatEnt.y,reqTWatSer. u) annotation (Line(points={{521,-250},{530,-250},
          {530,-246},{539,-246}}, color={0,0,127}));
  connect(TDisWatSup.T,reqTPlaMix. u) annotation (Line(points={{-91,170},{-220,170},
          {-220,-172},{60,-172},{60,-432},{452,-432},{452,-446},{539,-446}},
                                   color={0,0,127}));
  connect(TTanTop.y,reqTDhwTan. u) annotation (Line(points={{521,320},{530,320},
          {530,314},{539,314}}, color={0,0,127}));
  connect(DhwTanCha.y,reqTDhwTan. active) annotation (Line(points={{521,300},{532,
          300},{532,306},{538,306}}, color={255,0,255}));
  connect(TminHeaPumEva.y,reqTHeaPumEvaLvg. u_min) annotation (Line(points={{521,170},
          {530,170},{530,172},{539,172}},  color={0,0,127}));
  connect(HeaPumOn.y,reqHeaPumOn. u)
    annotation (Line(points={{481,450},{538,450}}, color={255,0,255}));
  connect(HeaPumOff.y,reqHeaPumOff. u)
    annotation (Line(points={{521,410},{538,410}}, color={255,0,255}));
  connect(HeaPumOn.y,HeaPumOff. u) annotation (Line(points={{481,450},{490,450},
          {490,410},{498,410}}, color={255,0,255}));
  connect(fracPLMax.y,reqPDis. u_max) annotation (Line(points={{521,-290},{530,-290},
          {530,-304},{539,-304}}, color={0,0,127}));
  connect(PDis.y,reqPDis. u_min) annotation (Line(points={{521,-330},{530,-330},
          {530,-308},{539,-308}}, color={0,0,127}));
  connect(THeaDiff.y,reqTHea. u) annotation (Line(points={{521,-360},{530,-360},
          {530,-366},{539,-366}}, color={0,0,127}));
  connect(TCooDiff.y,reqTCoo. u) annotation (Line(points={{521,-410},{530,-410},
          {530,-416},{539,-416}}, color={0,0,127}));
  connect(BooOn.y,reqTHea. active) annotation (Line(points={{421,-390},{448,-390},
          {448,-374},{538,-374}}, color={255,0,255}));
  connect(BooOn.y,reqTCoo. active) annotation (Line(points={{421,-390},{448,-390},
          {448,-424},{538,-424}}, color={255,0,255}));
  connect(TCooSup.y,TCooDiff. u1)
    annotation (Line(points={{481,-404},{498,-404}}, color={0,0,127}));
  connect(TCooSupSet.y,TCooDiff. u2)
    annotation (Line(points={{481,-416},{498,-416}}, color={0,0,127}));
  connect(THeaSup.y,THeaDiff. u1)
    annotation (Line(points={{481,-354},{498,-354}}, color={0,0,127}));
  connect(THeaSupSet.y,THeaDiff. u2)
    annotation (Line(points={{481,-366},{498,-366}}, color={0,0,127}));
  connect(TRooHeaSet.y,TRooHeaDif. u1) annotation (Line(points={{441,0},{448,0},
          {448,-14},{458,-14}},         color={0,0,127}));
  connect(TRooHea.y,TRooHeaDif. u2) annotation (Line(points={{441,-40},{448,-40},
          {448,-26},{458,-26}},   color={0,0,127}));
  connect(TRooHeaDif.y,TRooHeaAvg60min. u) annotation (Line(points={{481,-20},{490,
          -20},{490,-10},{498,-10}},        color={0,0,127}));
  connect(TRooHeaDif.y,TRooHeaAvgYea. u) annotation (Line(points={{481,-20},{490,
          -20},{490,-70},{498,-70}},    color={0,0,127}));
  connect(THexSecLvg.y,reqTHexEtsSecLvg. u) annotation (Line(points={{521,270},{
          532,270},{532,274},{539,274}}, color={0,0,127}));
  connect(THexPriLvg.y,reqTHexEtsPriLvg. u) annotation (Line(points={{521,230},{
          530,230},{530,234},{539,234}},
                                  color={0,0,127}));
  connect(TRooHeaAvg60min.y,reqTRooHea. u_min) annotation (Line(points={{522,-10},
          {530,-10},{530,-8},{539,-8}},      color={0,0,127}));
  connect(TRooHeaDifMax.y,reqTRooHea. u_max) annotation (Line(points={{521,20},{
          530,20},{530,-4},{539,-4}},        color={0,0,127}));
  connect(TRooHeaDifYea.y,reqTRooHeaAvg. u_max) annotation (Line(points={{521,-40},
          {530,-40},{530,-52},{539,-52}},    color={0,0,127}));
  connect(TRooHeaAvgYea.y,reqTRooHeaAvg. u_min) annotation (Line(points={{521,-70},
          {530,-70},{530,-56},{539,-56}},    color={0,0,127}));
  connect(last_value.y,reqTRooHeaAvg. active) annotation (Line(points={{441,-90},
          {534,-90},{534,-62},{538,-62}},    color={255,0,255}));
  connect(TRooCooSet.y,TRooCooDif. u1) annotation (Line(points={{441,-140},{450,
          -140},{450,-154},{458,-154}}, color={0,0,127}));
  connect(TRooCoo.y,TRooCooDif. u2) annotation (Line(points={{441,-180},{450,-180},
          {450,-166},{458,-166}}, color={0,0,127}));
  connect(TRooCooDif.y,TRooCooAvg60min. u) annotation (Line(points={{481,-160},{
          490,-160},{490,-150},{498,-150}}, color={0,0,127}));
  connect(TRooCooDif.y,TRooCooAvgYea. u) annotation (Line(points={{481,-160},{490,
          -160},{490,-210},{498,-210}}, color={0,0,127}));
  connect(TRooCooAvg60min.y,reqTRooCoo. u_min) annotation (Line(points={{522,-150},
          {530,-150},{530,-148},{539,-148}}, color={0,0,127}));
  connect(TRooCooDifMax.y,reqTRooCoo. u_max) annotation (Line(points={{521,-120},
          {530,-120},{530,-144},{539,-144}}, color={0,0,127}));
  connect(TRooCooDifYea.y,reqTRooCooAvg. u_max) annotation (Line(points={{521,-180},
          {530,-180},{530,-192},{539,-192}}, color={0,0,127}));
  connect(TRooCooAvgYea.y,reqTRooCooAvg. u_min) annotation (Line(points={{521,-210},
          {530,-210},{530,-196},{539,-196}}, color={0,0,127}));
  connect(last_value.y,reqTRooCooAvg. active) annotation (Line(points={{441,-90},
          {534,-90},{534,-202},{538,-202}},  color={255,0,255}));
  connect(BooOn.y,reqTRooCoo. active) annotation (Line(points={{421,-390},{448,-390},
          {448,-470},{580,-470},{580,-170},{530,-170},{530,-154},{538,-154}},
        color={255,0,255}));
  connect(BooOn.y,reqTRooHea. active) annotation (Line(points={{421,-390},{448,-390},
          {448,-470},{580,-470},{580,-30},{530,-30},{530,-14},{538,-14}},
        color={255,0,255}));
  connect(Valy.y,reqStaVal. u)
    annotation (Line(points={{521,494},{539,494}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(extent={{-400,-520},{600,520}})), Icon(
        coordinateSystem(extent={{-100,-100},{100,100}})));
end DetailedPlantFiveHubsWithRequirementsVerification;
