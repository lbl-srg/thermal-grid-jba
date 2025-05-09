within ThermalGridJBA.Networks.Validation;
model SinglePlantFiveHubs_requirements
  extends SinglePlantFiveHubs;
  Real y_value[8*nBui];
  Real fracPL[nBui + 2];

  Modelica.Blocks.Sources.RealExpression senTemHot[nBui](y={0,bui[2].ets.dhw.domHotWatTan.senTemHot.T,
        bui[3].ets.dhw.domHotWatTan.senTemHot.T,bui[4].ets.dhw.domHotWatTan.senTemHot.T,
        bui[5].ets.dhw.domHotWatTan.senTemHot.T})
    annotation (Placement(transformation(extent={{460,222},{480,242}})));
  Buildings_Requirements.WithinBand_old reqTDomHotWatSupply[nBui](
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
    annotation (Placement(transformation(extent={{500,220},{520,240}})));
  Buildings_Requirements.WithinBand_old reqTDomHotWatTan[nBui](
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
    "Requirement for The heating water temperature that serves the domestic hot water tank"
    annotation (Placement(transformation(extent={{500,160},{520,180}})));
  Modelica.Blocks.Sources.RealExpression TTanTop[nBui](y={0,bui[2].ets.dhw.domHotWatTan.TTanTop.T,
        bui[3].ets.dhw.domHotWatTan.TTanTop.T,bui[4].ets.dhw.domHotWatTan.TTanTop.T,
        bui[5].ets.dhw.domHotWatTan.TTanTop.T})
    annotation (Placement(transformation(extent={{460,170},{480,190}})));
  Modelica.Blocks.Sources.BooleanExpression DHWTanCha[nBui](y={false,bui[2].ets.dhw.charge,
        bui[3].ets.dhw.charge,bui[4].ets.dhw.charge,bui[5].ets.dhw.charge})
    annotation (Placement(transformation(extent={{460,150},{480,170}})));
  Modelica.Blocks.Sources.RealExpression THEXWatLvg[nBui](y=bui.ets.hex.senT2WatLvg.T)
    annotation (Placement(transformation(extent={{380,80},{400,100}})));
  Buildings_Requirements.WithinBand_old reqTHEXETSLeaPri[nBui](
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
    annotation (Placement(transformation(extent={{500,100},{520,120}})));
  Buildings_Requirements.WithinBand_old reqTdiffHEX[nBui](
    name="ETS",
    text=
        "O-307: At the district heat exchanger in the ETS, the primary side water temperature difference must be ± 4 K, with a tolerance of ± 1 K.",
    delayTime(each displayUnit="min") = 300,
    u_max(
      final unit="K",
      each displayUnit="K") = 5,
    u_min(
      final unit="K",
      each displayUnit="K") = 3,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirement for temperature difference on the primary side of theheat exchanger in the ETS"
    annotation (Placement(transformation(extent={{500,40},{520,60}})));
  Modelica.Blocks.Math.Add calc_diff[nBui](k1=-1)
    annotation (Placement(transformation(extent={{420,40},{440,60}})));
  Modelica.Blocks.Math.Abs abs[nBui]
    annotation (Placement(transformation(extent={{460,40},{480,60}})));
  Modelica.Blocks.Sources.RealExpression THEXWatEnt[nBui](y=bui.ets.hex.senT2WatEnt.T)
    annotation (Placement(transformation(extent={{380,30},{400,50}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumEva[nBui](
    name="ETS",
    text=
        "O-308: The heat pump evaporator leaving water temperature must be at least 15°C (preferably higher) once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump evaporator leaving water temperature"
    annotation (Placement(transformation(extent={{500,-60},{520,-40}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumCon[nBui](
    name="ETS",
    text=
        " O-309: The heat pump condenser leaving water temperature must not exceed 31°C once the system rejects heat to the district for at least 5 minutes.",
    use_activeInput=true)
    "Requirement for heat pump condenser leaving water temperature"
    annotation (Placement(transformation(extent={{500,-160},{520,-140}})));
  Buildings_Requirements.WithinBand_old reqTWatSer[nBui](
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
    annotation (Placement(transformation(extent={{500,-240},{520,-220}})));
  Modelica.Blocks.Sources.RealExpression THeaPumEvaLea[nBui](y=bui.ets.chi.senTEvaLvg.T)
    annotation (Placement(transformation(extent={{460,-40},{480,-20}})));
  Modelica.Blocks.Sources.RealExpression THeaPumCon[nBui](y=bui.ets.chi.senTConLvg.T)
    annotation (Placement(transformation(extent={{460,-160},{480,-140}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valEvaOpen[nBui](h=0.01)
    annotation (Placement(transformation(extent={{460,-90},{480,-70}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valConOpen[nBui](h=0.01)
    annotation (Placement(transformation(extent={{460,-190},{480,-170}})));
  Modelica.Blocks.Sources.RealExpression valIsoEvaPos[nBui](y=bui.ets.valIsoEva.y_actual)
    annotation (Placement(transformation(extent={{420,-90},{440,-70}})));
  Modelica.Blocks.Sources.RealExpression valIsoConPos[nBui](y=bui.ets.valIsoCon.y_actual)
    annotation (Placement(transformation(extent={{420,-190},{440,-170}})));
  Modelica.Blocks.Sources.Constant TmaxHeaPumCon[nBui](k=31 + 273.15)
    annotation (Placement(transformation(extent={{460,-140},{480,-120}})));
  Modelica.Blocks.Sources.Constant TminHeaPumEva[nBui](k=15 + 273.15)
    annotation (Placement(transformation(extent={{460,-60},{480,-40}})));
  Buildings_Requirements.WithinBand_old reqTWatPlaMix(
    name="Central plant",
    text=
        "O-503: The mixing water temperature in the district loop after the central plant must be between 10.5°C and 24°C.",
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
    annotation (Placement(transformation(extent={{500,-280},{520,-260}})));
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
  Buildings_Requirements.StableContinuousSignal reqStaVal[nBui*8](name="Valves",
      text="O-202: All control valves must show stable operation.")
    "Requirements to verify stability of control valves"
    annotation (Placement(transformation(extent={{500,340},{520,360}})));
  Modelica.Blocks.Sources.RealExpression Valy[nBui*8](y=y_value)
    annotation (Placement(transformation(extent={{460,344},{480,364}})));
  Buildings_Requirements.GreaterEqual reqPDis[nBui + 2](name="District loop",
      text="O-402: The pressure drop in the district loop and the service line must be no bigger than 125 Pa/m at full load.")
    "Requirement for pressure drop in the district loop"
    annotation (Placement(transformation(extent={{500,-340},{520,-320}})));
  Modelica.Blocks.Sources.RealExpression PDis[nBui + 2](y=fracPL)
    annotation (Placement(transformation(extent={{460,-360},{480,-340}})));
  Modelica.Blocks.Sources.Constant fracPLMax[nBui + 2](k=125)
    annotation (Placement(transformation(extent={{460,-320},{480,-300}})));
  Buildings_Requirements.WithinBand_old reqTSHSet[nBui](
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
    annotation (Placement(transformation(extent={{500,-400},{520,-380}})));
  Buildings_Requirements.WithinBand_old reqTSCSet[nBui](
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
    annotation (Placement(transformation(extent={{500,-450},{520,-430}})));
  Modelica.Blocks.Math.Add TSHcompare[nBui](k2=-1)
    annotation (Placement(transformation(extent={{460,-390},{480,-370}})));
  Modelica.Blocks.Math.Add TSCCompare[nBui](k2=-1)
    annotation (Placement(transformation(extent={{460,-440},{480,-420}})));
  Modelica.Blocks.Sources.RealExpression TSHSupply[nBui](y=bui.bui.disFloHea.senTSup.T)
    annotation (Placement(transformation(extent={{420,-384},{440,-364}})));
  Modelica.Blocks.Sources.RealExpression TSHSupplySet[nBui](y=bui.THeaWatSupSet.y)
    annotation (Placement(transformation(extent={{420,-396},{440,-376}})));
  Modelica.Blocks.Sources.BooleanExpression BooOn[nBui](y=true)
    annotation (Placement(transformation(extent={{360,-420},{380,-400}})));
  Modelica.Blocks.Sources.RealExpression TSCSupply[nBui](y=bui.bui.disFloCoo.senTSup.T)
    annotation (Placement(transformation(extent={{420,-434},{440,-414}})));
  Modelica.Blocks.Sources.RealExpression TSCSupplySet[nBui](y=bui.TChiWatSupSet.y)
    annotation (Placement(transformation(extent={{420,-446},{440,-426}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage movAve[nBui](delta(each
        displayUnit="min") = 3600)
    annotation (Placement(transformation(extent={{460,-490},{480,-470}})));
  Buildings_Requirements.WithinBand_old reqTSHSet1[nBui](
    name="Load tracking",
    text=
        "O-351/2: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    use_activeInput=true,
    delayTime(each displayUnit="min") = 3600,
    u_max(
      final unit="K",
      each displayUnit="K") = 0.5,
    u_min(
      final unit="K",
      each displayUnit="K") = -0.5,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirment for tracking the space heating water supply temperature set point"
    annotation (Placement(transformation(extent={{500,-500},{520,-480}})));
  Modelica.Blocks.Sources.RealExpression TSHSupply1
                                                  [nBui](y=bui.bui.disFloHea.senTSup.T)
    annotation (Placement(transformation(extent={{380,-506},{400,-486}})));
  Modelica.Blocks.Sources.RealExpression TSHSupply2
                                                  [nBui](y=bui.bui.disFloHea.senTSup.T)
    annotation (Placement(transformation(extent={{380,-494},{400,-474}})));
  Modelica.Blocks.Math.Add TSCCompare1
                                     [nBui](k2=-1)
    annotation (Placement(transformation(extent={{420,-500},{440,-480}})));
  Modelica.Blocks.Continuous.Integrator integrator[nBui]
    annotation (Placement(transformation(extent={{460,-530},{480,-510}})));
  Buildings_Requirements.WithinBand_old reqTSHSet2[nBui](
    name="ETS",
    text=
        "O-353: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    use_activeInput=true,
    delayTime(each displayUnit="s") = 0,
    u_max(
      final unit="K",
      each displayUnit="K") = 0.05,
    u_min(
      final unit="K",
      each displayUnit="K") = -0.05,
    u(final unit="K", each displayUnit="K"),
    witBan(u(final unit="K")))
    "Requirment for tracking the space heating water supply temperature set point"
    annotation (Placement(transformation(extent={{500,-540},{520,-520}})));
  Modelica.Blocks.Sources.BooleanExpression last_value[nBui](y=terminal())
    annotation (Placement(transformation(extent={{460,-560},{480,-540}})));
equation
  for i in 1:5 loop
    y_value[i] = bui[i].ets.valIsoEva.y_actual;
    y_value[i+5] = bui[i].ets.valIsoCon.y_actual;
    y_value[i+10] = bui[i].ets.valDivCon.val.y_actual;
    y_value[i+15] = bui[i].ets.valDivEva.val.y_actual;
    y_value[i+20] = bui[i].ets.hex.val2.y_actual;
    y_value[i+25] = bui[i].ets.chi.valEva.y_actual;
    y_value[i+30] = bui[i].ets.chi.valCon.y_actual;
    fracPL[i] = dis.con[i].pipDis.dp / dis.con[i].pipDis.length;
    if i == 1 then
      y_value[i+35] = 0;
    end if;
  end for;

  y_value[37] = bui[2].ets.dhw.domHotWatTan.divVal.y_actual;
  y_value[38] = bui[3].ets.dhw.domHotWatTan.divVal.y_actual;
  y_value[39] = bui[4].ets.dhw.domHotWatTan.divVal.y_actual;
  y_value[40] = bui[5].ets.dhw.domHotWatTan.divVal.y_actual;
  fracPL[6] = dis.pipEnd.dp / dis.pipEnd.length;
  fracPL[7] = conPla.pipDis.dp / conPla.pipDis.length;



  connect(senTemHot.y, reqTDomHotWatSupply.u) annotation (Line(points={{481,232},
          {488,232},{488,234},{499,234}}, color={0,0,127}));
  connect(THEXWatLvg.y, reqTHEXETSLeaPri.u) annotation (Line(points={{401,90},{
          488,90},{488,114},{499,114}}, color={0,0,127}));
  connect(THEXWatEnt.y, calc_diff.u2) annotation (Line(points={{401,40},{410,40},
          {410,44},{418,44}}, color={0,0,127}));
  connect(calc_diff.y, abs.u)
    annotation (Line(points={{441,50},{458,50}}, color={0,0,127}));
  connect(abs.y, reqTdiffHEX.u) annotation (Line(points={{481,50},{490,50},{490,
          54},{499,54}}, color={0,0,127}));
  connect(THEXWatLvg.y, calc_diff.u1) annotation (Line(points={{401,90},{410,90},
          {410,56},{418,56}}, color={0,0,127}));
  connect(valEvaOpen.y, reqTHeaPumEva.active) annotation (Line(points={{482,-80},
          {490,-80},{490,-54},{498,-54}}, color={255,0,255}));
  connect(valConOpen.y, reqTHeaPumCon.active) annotation (Line(points={{482,
          -180},{492,-180},{492,-154},{498,-154}}, color={255,0,255}));
  connect(valIsoConPos.y, valConOpen.u)
    annotation (Line(points={{441,-180},{458,-180}}, color={0,0,127}));
  connect(valIsoEvaPos.y, valEvaOpen.u)
    annotation (Line(points={{441,-80},{458,-80}}, color={0,0,127}));
  connect(THeaPumEvaLea.y, reqTHeaPumEva.u_max) annotation (Line(points={{481,
          -30},{490,-30},{490,-44},{499,-44}}, color={0,0,127}));
  connect(TmaxHeaPumCon.y, reqTHeaPumCon.u_max) annotation (Line(points={{481,
          -130},{492,-130},{492,-144},{499,-144}}, color={0,0,127}));
  connect(THeaPumCon.y, reqTHeaPumCon.u_min) annotation (Line(points={{481,-150},
          {492,-150},{492,-148},{499,-148}}, color={0,0,127}));
  connect(THEXWatEnt.y, reqTWatSer.u) annotation (Line(points={{401,40},{410,40},
          {410,-226},{499,-226}}, color={0,0,127}));
  connect(TDisWatSup.T, reqTWatPlaMix.u) annotation (Line(points={{-91,20},{
          -114,20},{-114,-266},{499,-266}}, color={0,0,127}));
  connect(TTanTop.y, reqTDomHotWatTan.u) annotation (Line(points={{481,180},{
          490,180},{490,174},{499,174}}, color={0,0,127}));
  connect(DHWTanCha.y, reqTDomHotWatTan.active) annotation (Line(points={{481,
          160},{492,160},{492,166},{498,166}}, color={255,0,255}));
  connect(TminHeaPumEva.y, reqTHeaPumEva.u_min) annotation (Line(points={{481,
          -50},{490,-50},{490,-48},{499,-48}}, color={0,0,127}));
  connect(HeaPumOn.y, reqHeaPumOn.u)
    annotation (Line(points={{441,310},{498,310}}, color={255,0,255}));
  connect(HeaPumOff.y, reqHeaPumOff.u)
    annotation (Line(points={{481,270},{498,270}}, color={255,0,255}));
  connect(HeaPumOn.y, HeaPumOff.u) annotation (Line(points={{441,310},{450,310},
          {450,270},{458,270}}, color={255,0,255}));
  connect(Valy.y, reqStaVal.u)
    annotation (Line(points={{481,354},{499,354}}, color={0,0,127}));
  connect(fracPLMax.y, reqPDis.u_max) annotation (Line(points={{481,-310},{490,-310},
          {490,-324},{499,-324}}, color={0,0,127}));
  connect(PDis.y, reqPDis.u_min) annotation (Line(points={{481,-350},{490,-350},
          {490,-328},{499,-328}}, color={0,0,127}));
  connect(TSHcompare.y, reqTSHSet.u) annotation (Line(points={{481,-380},{490,
          -380},{490,-386},{499,-386}}, color={0,0,127}));
  connect(TSCCompare.y, reqTSCSet.u) annotation (Line(points={{481,-430},{490,
          -430},{490,-436},{499,-436}}, color={0,0,127}));
  connect(BooOn.y, reqTSHSet.active) annotation (Line(points={{381,-410},{400,
          -410},{400,-394},{498,-394}}, color={255,0,255}));
  connect(BooOn.y, reqTSCSet.active) annotation (Line(points={{381,-410},{400,
          -410},{400,-444},{498,-444}}, color={255,0,255}));
  connect(TSCSupply.y, TSCCompare.u1)
    annotation (Line(points={{441,-424},{458,-424}}, color={0,0,127}));
  connect(TSCSupplySet.y, TSCCompare.u2)
    annotation (Line(points={{441,-436},{458,-436}}, color={0,0,127}));
  connect(TSHSupply.y, TSHcompare.u1)
    annotation (Line(points={{441,-374},{458,-374}}, color={0,0,127}));
  connect(TSHSupplySet.y, TSHcompare.u2)
    annotation (Line(points={{441,-386},{458,-386}}, color={0,0,127}));
  connect(movAve.y, reqTSHSet1.u) annotation (Line(points={{482,-480},{490,-480},
          {490,-486},{499,-486}}, color={0,0,127}));
  connect(TSHSupply2.y, TSCCompare1.u1)
    annotation (Line(points={{401,-484},{418,-484}}, color={0,0,127}));
  connect(TSHSupply1.y, TSCCompare1.u2)
    annotation (Line(points={{401,-496},{418,-496}}, color={0,0,127}));
  connect(TSCCompare1.y, movAve.u) annotation (Line(points={{441,-490},{450,
          -490},{450,-480},{458,-480}}, color={0,0,127}));
  connect(TSCCompare1.y, integrator.u) annotation (Line(points={{441,-490},{450,
          -490},{450,-520},{458,-520}}, color={0,0,127}));
  connect(integrator.y, reqTSHSet2.u) annotation (Line(points={{481,-520},{490,
          -520},{490,-526},{499,-526}}, color={0,0,127}));
  connect(BooOn.y, reqTSHSet1.active) annotation (Line(points={{381,-410},{400,
          -410},{400,-460},{486,-460},{486,-494},{498,-494}}, color={255,0,255}));
  connect(last_value.y, reqTSHSet2.active) annotation (Line(points={{481,-550},
          {490,-550},{490,-534},{498,-534}}, color={255,0,255}));
end SinglePlantFiveHubs_requirements;
