within ThermalGridJBA.Networks.Validation;
model IdealPlantFiveHubsWithRequirementsVerification
  extends IdealPlantFiveHubs;

  Real fracPL[nBui + 2] "The pressure drop per length unti (Pa/m)";
  Real y_value[19] "Valves actuator values";

  Modelica.Blocks.Sources.RealExpression senTemDhwSup[nBui](y={45 + 273.15,bui[2].ets.dhw.domHotWatTan.senTemHot.T,
        bui[3].ets.dhw.domHotWatTan.senTemHot.T,bui[4].ets.dhw.domHotWatTan.senTemHot.T,
        bui[5].ets.dhw.domHotWatTan.senTemHot.T})
    annotation (Placement(transformation(extent={{460,342},{480,362}})));
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
    annotation (Placement(transformation(extent={{500,340},{520,360}})));
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
    annotation (Placement(transformation(extent={{500,280},{520,300}})));
  Modelica.Blocks.Sources.RealExpression TTanTop[nBui](y={50 + 273.15,bui[2].ets.dhw.domHotWatTan.TTanTop.T,
        bui[3].ets.dhw.domHotWatTan.TTanTop.T,bui[4].ets.dhw.domHotWatTan.TTanTop.T,
        bui[5].ets.dhw.domHotWatTan.TTanTop.T})
    annotation (Placement(transformation(extent={{460,290},{480,310}})));
  Modelica.Blocks.Sources.BooleanExpression DhwTanCha[nBui](y={false,bui[2].ets.dhw.charge,
        bui[3].ets.dhw.charge,bui[4].ets.dhw.charge,bui[5].ets.dhw.charge})
    annotation (Placement(transformation(extent={{460,270},{480,290}})));
  Modelica.Blocks.Sources.RealExpression THexSecLvg[nBui](y=bui.ets.hex.senT2WatLvg.T)
    annotation (Placement(transformation(extent={{460,240},{480,260}})));
  Buildings_Requirements.WithinBand     reqTHexEtsPriLvg[nBui](
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
    annotation (Placement(transformation(extent={{500,200},{520,220}})));
  Modelica.Blocks.Sources.RealExpression THexWatEnt[nBui](y=bui.ets.hex.senT2WatEnt.T)
    annotation (Placement(transformation(extent={{460,-280},{480,-260}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumEvaLvg[nBui](
    name="ETS",
    text="O-308: The heat pump evaporator leaving water temperature must be at least 15°C (preferably higher) once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump evaporator leaving water temperature"
    annotation (Placement(transformation(extent={{500,140},{520,160}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumConLvg[nBui](
    name="ETS",
    text=" O-309: The heat pump condenser leaving water temperature must not exceed 31°C once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump condenser leaving water temperature"
    annotation (Placement(transformation(extent={{500,60},{520,80}})));
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
    annotation (Placement(transformation(extent={{500,-280},{520,-260}})));
  Modelica.Blocks.Sources.RealExpression THeaPumEvaLvg[nBui](y=bui.ets.chi.senTEvaLvg.T)
    annotation (Placement(transformation(extent={{460,160},{480,180}})));
  Modelica.Blocks.Sources.RealExpression THeaPumCon[nBui](y=bui.ets.chi.senTConLvg.T)
    annotation (Placement(transformation(extent={{460,60},{480,80}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valEvaOpen[nBui](h=0.01)
    annotation (Placement(transformation(extent={{460,110},{480,130}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valConOpen[nBui](h=0.01)
    annotation (Placement(transformation(extent={{460,30},{480,50}})));
  Modelica.Blocks.Sources.RealExpression valIsoEvaPos[nBui](y=bui.ets.valIsoEva.y_actual)
    annotation (Placement(transformation(extent={{420,110},{440,130}})));
  Modelica.Blocks.Sources.RealExpression valIsoConPos[nBui](y=bui.ets.valIsoCon.y_actual)
    annotation (Placement(transformation(extent={{420,30},{440,50}})));
  Modelica.Blocks.Sources.Constant TmaxHeaPumConLvg[nBui](k=31 + 273.15)
    annotation (Placement(transformation(extent={{460,80},{480,100}})));
  Modelica.Blocks.Sources.Constant TminHeaPumEva[nBui](k=15 + 273.15)
    annotation (Placement(transformation(extent={{460,140},{480,160}})));
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
    annotation (Placement(transformation(extent={{500,-480},{520,-460}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOn[nBui](
    name="Heat pump",
    text="O-201_0: The heat pump must operate at least 30 min when activated.",
    durationMin(displayUnit="min") = 1800) "Requirement for heat pump on"
    annotation (Placement(transformation(extent={{500,420},{520,440}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOff[nBui](
    name="Heat pump",
    text="O-201_1: The heat pump must remain off for at least 10 minutes.",
    durationMin(displayUnit="min") = 600) "Requirement for heat pump off"
    annotation (Placement(transformation(extent={{500,380},{520,400}})));
  Modelica.Blocks.Logical.Not HeaPumOff[nBui]
    annotation (Placement(transformation(extent={{460,380},{480,400}})));
  Modelica.Blocks.Sources.BooleanExpression HeaPumOn[nBui](y=bui.ets.chi.con.yPum)
    annotation (Placement(transformation(extent={{420,420},{440,440}})));
  Buildings_Requirements.GreaterEqual reqPDis[nBui + 2](name="District loop",
      text="O-402: The pressure drop in the district loop and the service line must be no bigger than 125 Pa/m at full load.")
    "Requirement for pressure drop in the district loop"
    annotation (Placement(transformation(extent={{500,-340},{520,-320}})));
  Modelica.Blocks.Sources.RealExpression PDis[nBui + 2](y=fracPL)
    annotation (Placement(transformation(extent={{460,-360},{480,-340}})));
  Modelica.Blocks.Sources.Constant fracPLMax[nBui + 2](k=125)
    annotation (Placement(transformation(extent={{460,-320},{480,-300}})));
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
    annotation (Placement(transformation(extent={{500,-400},{520,-380}})));
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
    annotation (Placement(transformation(extent={{500,-450},{520,-430}})));
  Modelica.Blocks.Math.Add THeaDiff[nBui](k2=-1)
    annotation (Placement(transformation(extent={{460,-390},{480,-370}})));
  Modelica.Blocks.Math.Add TCooDiff[nBui](k2=-1)
    annotation (Placement(transformation(extent={{460,-440},{480,-420}})));
  Modelica.Blocks.Sources.RealExpression THeaSup[nBui](y=bui.bui.disFloHea.senTSup.T)
    annotation (Placement(transformation(extent={{420,-384},{440,-364}})));
  Modelica.Blocks.Sources.RealExpression THeaSupSet[nBui](y=bui.THeaWatSupSet.y)
    annotation (Placement(transformation(extent={{420,-396},{440,-376}})));
  Modelica.Blocks.Sources.BooleanExpression BooOn[nBui](y=true)
    annotation (Placement(transformation(extent={{360,-420},{380,-400}})));
  Modelica.Blocks.Sources.RealExpression TCooSup[nBui](y=bui.bui.disFloCoo.senTSup.T)
    annotation (Placement(transformation(extent={{420,-434},{440,-414}})));
  Modelica.Blocks.Sources.RealExpression TCooSupSet[nBui](y=bui.TChiWatSupSet.y)
    annotation (Placement(transformation(extent={{420,-446},{440,-426}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage TRooHeaAvg60min[nBui](delta(
        each displayUnit="min") = 3600)
    annotation (Placement(transformation(extent={{460,-40},{480,-20}})));
  Modelica.Blocks.Sources.RealExpression TRooHea[nBui](y=bui.bui.terUniHea.TLoaODE.TAir)
    annotation (Placement(transformation(extent={{380,-70},{400,-50}})));
  Modelica.Blocks.Sources.RealExpression TRooHeaSet[nBui](y=bui.bui.terUniHea.TLoaODE.TSet)
    annotation (Placement(transformation(extent={{380,-30},{400,-10}})));
  Modelica.Blocks.Math.Add TRooHeaDif[nBui](k2=-1)
    annotation (Placement(transformation(extent={{420,-50},{440,-30}})));
  Modelica.Blocks.Continuous.Integrator TRooHeaAvgYea[nBui]
    annotation (Placement(transformation(extent={{460,-100},{480,-80}})));
  Modelica.Blocks.Sources.BooleanExpression last_value[nBui](y=terminal())
    annotation (Placement(transformation(extent={{380,-120},{400,-100}})));
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
    annotation (Placement(transformation(extent={{500,240},{520,260}})));
  Modelica.Blocks.Sources.RealExpression THexPriLvg[nBui](y=dis.con.senTOut.T)
    annotation (Placement(transformation(extent={{460,200},{480,220}})));
  Buildings_Requirements.GreaterEqual reqTRooHea[nBui](
    name="Room",
    text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for heating"
    annotation (Placement(transformation(extent={{500,-40},{520,-20}})));
  Modelica.Blocks.Sources.Constant TRooHeaDifMax[nBui](k=0.5)
    annotation (Placement(transformation(extent={{460,-10},{480,10}})));
  Buildings_Requirements.GreaterEqual reqTRooHeaAvg[nBui](
    name="Room",
    text="O-353_0: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    use_activeInput=true,
    delayTime(each displayUnit="s") = 0)
    "Requirement for the room temperature for heating (yearly average)"
    annotation (Placement(transformation(extent={{500,-88},{520,-68}})));
  Modelica.Blocks.Sources.Constant TRooHeaDifYea[nBui](k=0.05)
    annotation (Placement(transformation(extent={{460,-70},{480,-50}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage TRooCooAvg60min[nBui](delta(
        each displayUnit="min") = 3600)
    annotation (Placement(transformation(extent={{460,-180},{480,-160}})));
  Modelica.Blocks.Sources.RealExpression TRooCoo[nBui](y=bui.bui.terUniCoo.TLoaODE.TAir)
    annotation (Placement(transformation(extent={{380,-210},{400,-190}})));
  Modelica.Blocks.Sources.RealExpression TRooCooSet[nBui](y=bui.bui.terUniCoo.TLoaODE.TSet)
    annotation (Placement(transformation(extent={{380,-170},{400,-150}})));
  Modelica.Blocks.Math.Add TRooCooDif[nBui](k1=-1)
    annotation (Placement(transformation(extent={{420,-190},{440,-170}})));
  Modelica.Blocks.Continuous.Integrator TRooCooAvgYea[nBui]
    annotation (Placement(transformation(extent={{460,-240},{480,-220}})));
  Buildings_Requirements.GreaterEqual reqTRooCoo[nBui](
    name="Room",
    text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for cooling"
    annotation (Placement(transformation(extent={{500,-180},{520,-160}})));
  Modelica.Blocks.Sources.Constant TRooCooDifMax[nBui](k=0.5)
    annotation (Placement(transformation(extent={{460,-150},{480,-130}})));
  Buildings_Requirements.GreaterEqual reqTRooCooAvg[nBui](
    name="Room",
    text="O-353: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    use_activeInput=true,
    delayTime(each displayUnit="s") = 0)
    "Requirement for the room temperature for cooling (yearly average)"
    annotation (Placement(transformation(extent={{500,-228},{520,-208}})));
  Modelica.Blocks.Sources.Constant TRooCooDifYea[nBui](k=0.05)
    annotation (Placement(transformation(extent={{460,-210},{480,-190}})));
  Buildings_Requirements.StableContinuousSignal reqStaVal[19](name="Valves",
      text="O-202: All control valves must show stable operation.")
    "Requirements to verify stability of control valves"
    annotation (Placement(transformation(extent={{500,460},{520,480}})));
  Modelica.Blocks.Sources.RealExpression Valy[19](y=y_value)
    annotation (Placement(transformation(extent={{460,464},{480,484}})));
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

  connect(senTemDhwSup.y, reqTDhwSup.u) annotation (Line(points={{481,352},{488,
          352},{488,354},{499,354}}, color={0,0,127}));
  connect(valEvaOpen.y, reqTHeaPumEvaLvg.active) annotation (Line(points={{482,120},
          {490,120},{490,146},{498,146}},
                                      color={255,0,255}));
  connect(valConOpen.y, reqTHeaPumConLvg.active) annotation (Line(points={{482,40},
          {492,40},{492,66},{498,66}},    color={255,0,255}));
  connect(valIsoConPos.y, valConOpen.u)
    annotation (Line(points={{441,40},{458,40}},     color={0,0,127}));
  connect(valIsoEvaPos.y, valEvaOpen.u)
    annotation (Line(points={{441,120},{458,120}}, color={0,0,127}));
  connect(THeaPumEvaLvg.y, reqTHeaPumEvaLvg.u_max) annotation (Line(points={{481,170},
          {490,170},{490,156},{499,156}},  color={0,0,127}));
  connect(TmaxHeaPumConLvg.y, reqTHeaPumConLvg.u_max) annotation (Line(points={{481,90},
          {492,90},{492,76},{499,76}},             color={0,0,127}));
  connect(THeaPumCon.y, reqTHeaPumConLvg.u_min) annotation (Line(points={{481,70},
          {492,70},{492,72},{499,72}},    color={0,0,127}));
  connect(THexWatEnt.y, reqTWatSer.u) annotation (Line(points={{481,-270},{490,
          -270},{490,-266},{499,-266}},
                                  color={0,0,127}));
  connect(TDisWatSup.T, reqTPlaMix.u) annotation (Line(points={{-91,20},{-104,
          20},{-104,-466},{499,-466}},
                                   color={0,0,127}));
  connect(TTanTop.y, reqTDhwTan.u) annotation (Line(points={{481,300},{490,300},
          {490,294},{499,294}}, color={0,0,127}));
  connect(DhwTanCha.y, reqTDhwTan.active) annotation (Line(points={{481,280},{
          492,280},{492,286},{498,286}},
                                     color={255,0,255}));
  connect(TminHeaPumEva.y, reqTHeaPumEvaLvg.u_min) annotation (Line(points={{481,150},
          {490,150},{490,152},{499,152}},  color={0,0,127}));
  connect(HeaPumOn.y, reqHeaPumOn.u)
    annotation (Line(points={{441,430},{498,430}}, color={255,0,255}));
  connect(HeaPumOff.y, reqHeaPumOff.u)
    annotation (Line(points={{481,390},{498,390}}, color={255,0,255}));
  connect(HeaPumOn.y, HeaPumOff.u) annotation (Line(points={{441,430},{450,430},
          {450,390},{458,390}}, color={255,0,255}));
  connect(fracPLMax.y, reqPDis.u_max) annotation (Line(points={{481,-310},{490,
          -310},{490,-324},{499,-324}},
                                  color={0,0,127}));
  connect(PDis.y, reqPDis.u_min) annotation (Line(points={{481,-350},{490,-350},
          {490,-328},{499,-328}}, color={0,0,127}));
  connect(THeaDiff.y, reqTHea.u) annotation (Line(points={{481,-380},{490,-380},
          {490,-386},{499,-386}}, color={0,0,127}));
  connect(TCooDiff.y, reqTCoo.u) annotation (Line(points={{481,-430},{490,-430},
          {490,-436},{499,-436}}, color={0,0,127}));
  connect(BooOn.y, reqTHea.active) annotation (Line(points={{381,-410},{408,
          -410},{408,-394},{498,-394}},
                                  color={255,0,255}));
  connect(BooOn.y, reqTCoo.active) annotation (Line(points={{381,-410},{408,
          -410},{408,-444},{498,-444}},
                                  color={255,0,255}));
  connect(TCooSup.y, TCooDiff.u1)
    annotation (Line(points={{441,-424},{458,-424}}, color={0,0,127}));
  connect(TCooSupSet.y, TCooDiff.u2)
    annotation (Line(points={{441,-436},{458,-436}}, color={0,0,127}));
  connect(THeaSup.y, THeaDiff.u1)
    annotation (Line(points={{441,-374},{458,-374}}, color={0,0,127}));
  connect(THeaSupSet.y, THeaDiff.u2)
    annotation (Line(points={{441,-386},{458,-386}}, color={0,0,127}));
  connect(TRooHeaSet.y, TRooHeaDif.u1) annotation (Line(points={{401,-20},{408,
          -20},{408,-34},{418,-34}},    color={0,0,127}));
  connect(TRooHea.y, TRooHeaDif.u2) annotation (Line(points={{401,-60},{408,-60},
          {408,-46},{418,-46}},   color={0,0,127}));
  connect(TRooHeaDif.y, TRooHeaAvg60min.u) annotation (Line(points={{441,-40},{
          450,-40},{450,-30},{458,-30}},    color={0,0,127}));
  connect(TRooHeaDif.y, TRooHeaAvgYea.u) annotation (Line(points={{441,-40},{
          450,-40},{450,-90},{458,-90}},color={0,0,127}));
  connect(THexSecLvg.y, reqTHexEtsSecLvg.u) annotation (Line(points={{481,250},
          {492,250},{492,254},{499,254}},color={0,0,127}));
  connect(THexPriLvg.y, reqTHexEtsPriLvg.u) annotation (Line(points={{481,210},
          {490,210},{490,214},{499,214}},
                                  color={0,0,127}));
  connect(TRooHeaAvg60min.y, reqTRooHea.u_min) annotation (Line(points={{482,-30},
          {490,-30},{490,-28},{499,-28}},    color={0,0,127}));
  connect(TRooHeaDifMax.y, reqTRooHea.u_max) annotation (Line(points={{481,0},{
          490,0},{490,-24},{499,-24}},       color={0,0,127}));
  connect(TRooHeaDifYea.y, reqTRooHeaAvg.u_max) annotation (Line(points={{481,-60},
          {490,-60},{490,-72},{499,-72}},    color={0,0,127}));
  connect(TRooHeaAvgYea.y, reqTRooHeaAvg.u_min) annotation (Line(points={{481,-90},
          {490,-90},{490,-76},{499,-76}},    color={0,0,127}));
  connect(last_value.y, reqTRooHeaAvg.active) annotation (Line(points={{401,
          -110},{494,-110},{494,-82},{498,-82}},
                                             color={255,0,255}));
  connect(TRooCooSet.y, TRooCooDif.u1) annotation (Line(points={{401,-160},{410,
          -160},{410,-174},{418,-174}}, color={0,0,127}));
  connect(TRooCoo.y, TRooCooDif.u2) annotation (Line(points={{401,-200},{410,
          -200},{410,-186},{418,-186}},
                                  color={0,0,127}));
  connect(TRooCooDif.y, TRooCooAvg60min.u) annotation (Line(points={{441,-180},
          {450,-180},{450,-170},{458,-170}},color={0,0,127}));
  connect(TRooCooDif.y, TRooCooAvgYea.u) annotation (Line(points={{441,-180},{
          450,-180},{450,-230},{458,-230}},
                                        color={0,0,127}));
  connect(TRooCooAvg60min.y, reqTRooCoo.u_min) annotation (Line(points={{482,
          -170},{490,-170},{490,-168},{499,-168}},
                                             color={0,0,127}));
  connect(TRooCooDifMax.y, reqTRooCoo.u_max) annotation (Line(points={{481,-140},
          {490,-140},{490,-164},{499,-164}}, color={0,0,127}));
  connect(TRooCooDifYea.y, reqTRooCooAvg.u_max) annotation (Line(points={{481,
          -200},{490,-200},{490,-212},{499,-212}},
                                             color={0,0,127}));
  connect(TRooCooAvgYea.y, reqTRooCooAvg.u_min) annotation (Line(points={{481,
          -230},{490,-230},{490,-216},{499,-216}},
                                             color={0,0,127}));
  connect(last_value.y, reqTRooCooAvg.active) annotation (Line(points={{401,
          -110},{494,-110},{494,-222},{498,-222}},
                                             color={255,0,255}));
  connect(BooOn.y, reqTRooCoo.active) annotation (Line(points={{381,-410},{408,
          -410},{408,-490},{540,-490},{540,-190},{490,-190},{490,-174},{498,
          -174}},
        color={255,0,255}));
  connect(BooOn.y, reqTRooHea.active) annotation (Line(points={{381,-410},{408,
          -410},{408,-490},{540,-490},{540,-50},{490,-50},{490,-34},{498,-34}},
        color={255,0,255}));
  connect(Valy.y,reqStaVal. u)
    annotation (Line(points={{481,474},{499,474}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(extent={{-380,-520},{560,500}})), Icon(
        coordinateSystem(extent={{-380,-520},{560,500}})));
end IdealPlantFiveHubsWithRequirementsVerification;
