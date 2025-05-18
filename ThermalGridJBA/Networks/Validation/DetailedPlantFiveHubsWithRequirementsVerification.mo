within ThermalGridJBA.Networks.Validation;
model DetailedPlantFiveHubsWithRequirementsVerification
  extends DetailedPlantFiveHubs;
  Real fracPL[nBui + 2] = {dis.con[1].pipDis.dp / dis.con[1].pipDis.length,
dis.con[2].pipDis.dp / dis.con[2].pipDis.length,
dis.con[3].pipDis.dp / dis.con[3].pipDis.length,
dis.con[4].pipDis.dp / dis.con[4].pipDis.length,
dis.con[5].pipDis.dp / dis.con[5].pipDis.length,
dis.pipEnd.dp / dis.pipEnd.length,
conPla.pipDis.dp / conPla.pipDis.length}
 "Pressure drop per length unit for each pipe (Pa/m)";
  Real y_value[5*3+4] = {bui[1].ets.hex.val2.y_actual,
bui[2].ets.hex.val2.y_actual,
bui[3].ets.hex.val2.y_actual,
bui[4].ets.hex.val2.y_actual,
bui[5].ets.hex.val2.y_actual,
bui[1].ets.chi.valEva.y_actual,
bui[2].ets.chi.valEva.y_actual,
bui[3].ets.chi.valEva.y_actual,
bui[4].ets.chi.valEva.y_actual,
bui[5].ets.chi.valEva.y_actual,
bui[1].ets.chi.valCon.y_actual,
bui[2].ets.chi.valCon.y_actual,
bui[3].ets.chi.valCon.y_actual,
bui[4].ets.chi.valCon.y_actual,
bui[5].ets.chi.valCon.y_actual,
bui[2].ets.dhw.domHotWatTan.divVal.y_actual,
bui[3].ets.dhw.domHotWatTan.divVal.y_actual,
bui[4].ets.dhw.domHotWatTan.divVal.y_actual,
bui[5].ets.dhw.domHotWatTan.divVal.y_actual}
 "Valves actuator values for the control valves of each ETS (heat exchanger, condenser loop of the chiller, evaporator loop of the chiller, domestichot water when present)";
  Modelica.Blocks.Sources.RealExpression senTemDhwSup[nBui](y={45 + 273.15,bui[2].ets.dhw.domHotWatTan.senTemHot.T,
        bui[3].ets.dhw.domHotWatTan.senTemHot.T,bui[4].ets.dhw.domHotWatTan.senTemHot.T,
        bui[5].ets.dhw.domHotWatTan.senTemHot.T})
    "Domestic hot water supply temperature for each hub, except hub[1] that does not provide domestic hot water."
    annotation (Placement(transformation(extent={{500,302},{520,322}})));
  Buildings_Requirements.WithinBand reqTDhwSup[nBui](
    each name="DHW",
    each text="O-301: The domestic hot water supply temperature must be 45°C ± 1 K.",
    each delayTime=30,
    each u_max(
      each unit="K",
      each displayUnit="degC") = 319.15,
    each u_min(
      each unit="K",
      each displayUnit="degC") = 317.15,
    each u(each unit="K", each displayUnit="K"),
    each witBan(u(each unit="K", each displayUnit="K")))
    "Requirement for domestic hot water supply temperature"
    annotation (Placement(transformation(extent={{540,300},{560,320}})));
  Buildings_Requirements.WithinBand reqTDhwTan[nBui](
    each name="DHW",
    each text="O-302: The heating water temperature that serves the domestic hot water tank must be 50°C ± 1 K once the tank charging is on for 5 minutes.",
    each use_activeInput=true,
    each delayTime(each displayUnit="min") = 300,
    each u_max(
      each unit="K",
      each displayUnit="degC") = 324.15,
    each u_min(
      each unit="K",
      each displayUnit="degC") = 322.15,
    each u(each unit="K", each displayUnit="K"),
    each witBan(u(each unit="K")))
    "Requirement for The heating water temperature that serves the domestic hot water tank"
    annotation (Placement(transformation(extent={{540,240},{560,260}})));
  Modelica.Blocks.Sources.RealExpression TTanTop[nBui](y={50 + 273.15,bui[2].ets.dhw.domHotWatTan.TTanTop.T,
        bui[3].ets.dhw.domHotWatTan.TTanTop.T,bui[4].ets.dhw.domHotWatTan.TTanTop.T,
        bui[5].ets.dhw.domHotWatTan.TTanTop.T})
    "T at the top of the tank for DHW for each hub, except hub[1] that does not provide DHW."
    annotation (Placement(transformation(extent={{500,250},{520,270}})));
  Modelica.Blocks.Sources.BooleanExpression DhwTanCha[nBui](y={false,bui[2].ets.dhw.charge,
        bui[3].ets.dhw.charge,bui[4].ets.dhw.charge,bui[5].ets.dhw.charge})
    "True when the domestic hot water tank is charging for each hub with domestic hot water, false for hub[1] that does not provide domestic hot water."
    annotation (Placement(transformation(extent={{500,230},{520,250}})));
  Modelica.Blocks.Sources.RealExpression THexSecLvg[nBui](y=bui.ets.hex.senT2WatLvg.T)
    "Temperature leaving the ETS heat exchanger on the secondary side."
    annotation (Placement(transformation(extent={{500,200},{520,220}})));
  Buildings_Requirements.WithinBand    reqTHexEtsPriLvg[nBui](
    each name="ETS",
    each text="O-306: At the district heat exchanger in the ETS, the primary side leaving water temperature that is fed back to the district loop must be between 6.5°C and 28°C.",
    each delayTime(each displayUnit="min") = 300,
    each u_max(
      final unit="K",
      each displayUnit="degC") = 301.15,
    each u_min(
      final unit="K",
      each displayUnit="degC") = 279.65,
    each u(final unit="K", each displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for  leaving water temperature on the primary side of the heat exchanger in the ETS "
    annotation (Placement(transformation(extent={{540,160},{560,180}})));
  Modelica.Blocks.Sources.RealExpression THexWatEnt[nBui](y=bui.ets.hex.senT2WatEnt.T)
    annotation (Placement(transformation(extent={{500,-320},{520,-300}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumEvaLvg[nBui](
    each name="ETS",
    each text="O-308: The heat pump evaporator leaving water temperature must be at least 15°C (preferably higher) once the system rejects heat to the district for at least 5 minutes.",
    each use_activeInput=true)
    "Requirement for heat pump evaporator leaving water temperature"
    annotation (Placement(transformation(extent={{540,100},{560,120}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumConLvg[nBui](
    each name="ETS",
    each text=" O-309: The heat pump condenser leaving water temperature must not exceed 31°C once the system rejects heat to the district for at least 5 minutes.",
    each use_activeInput=true)
    "Requirement for heat pump condenser leaving water temperature"
    annotation (Placement(transformation(extent={{540,20},{560,40}})));
  Buildings_Requirements.WithinBand reqTWatSer[nBui](
    each name="Network",
    each text="O-401: The water that is served to each service line must be between 10.5°C and 24°C.",
    each delayTime(each displayUnit="min") = 300,
    each u_max(
      final unit="K",
      each displayUnit="degC") = 297.15,
    each u_min(
      final unit="K",
      each displayUnit="degC") = 283.65,
    each u(final unit="K", each displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for water serving each service line"
    annotation (Placement(transformation(extent={{540,-320},{560,-300}})));
  Modelica.Blocks.Sources.RealExpression THeaPumEvaLvg[nBui](y=bui.ets.chi.senTEvaLvg.T)
    "Temperature of the water leaving the heat pump on the evaporator side."
    annotation (Placement(transformation(extent={{500,120},{520,140}})));
  Modelica.Blocks.Sources.RealExpression THeaPumCon[nBui](y=bui.ets.chi.senTConLvg.T)
    "Heat pump condenser leaving water temperature "
    annotation (Placement(transformation(extent={{500,20},{520,40}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valEvaOpen[nBui](each h=0.01)
    "Evaporator to ambient loop isolation valve open"
    annotation (Placement(transformation(extent={{500,70},{520,90}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold valConOpen[nBui](each h=0.01)
    "Condenser to ambient loop isolation valve open"
    annotation (Placement(transformation(extent={{500,-10},{520,10}})));
  Modelica.Blocks.Sources.RealExpression valIsoEvaPos[nBui](y=bui.ets.valIsoEva.y_actual)
    "Evaporator to ambient loop isolation valve position"
    annotation (Placement(transformation(extent={{460,70},{480,90}})));
  Modelica.Blocks.Sources.RealExpression valIsoConPos[nBui](y=bui.ets.valIsoCon.y_actual)
    "Condenser to ambient loop isolation valve position"
    annotation (Placement(transformation(extent={{460,-10},{480,10}})));
  Modelica.Blocks.Sources.Constant TmaxHeaPumConLvg[nBui](each k=31 + 273.15)
    "Maximum heat pump condenser leaving water temperature setpoint"
    annotation (Placement(transformation(extent={{500,40},{520,60}})));
  Modelica.Blocks.Sources.Constant TminHeaPumEva[nBui](each k=15 + 273.15)
    "Minimum heat pump evaporator leaving water temperature setpoint"
    annotation (Placement(transformation(extent={{500,100},{520,120}})));
  Buildings_Requirements.WithinBand reqTPlaMix(
    each name="Central plant",
    each text="O-503: The mixing water temperature in the district loop after the central plant must be between 10.5°C and 24°C.",
    each delayTime(each displayUnit="min") = 300,
    each u_max(
      final unit="K",
      each displayUnit="degC") = 297.15,
    each u_min(
      final unit="K",
      each displayUnit="degC") = 283.65,
    each u(final unit="K", each displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for mixing water temperature in the district loop after the central plant"
    annotation (Placement(transformation(extent={{540,-520},{560,-500}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOn[nBui](
    each name="Heat pump",
    each text="O-201_0: The heat pump must operate at least 30 min when activated.",
    each durationMin(displayUnit="min") = 1800) "Requirement for heat pump on"
    annotation (Placement(transformation(extent={{540,420},{560,440}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOff[nBui](
    each name="Heat pump",
    each text="O-201_1: The heat pump must remain off for at least 10 minutes.",
    each durationMin(displayUnit="min") = 600) "Requirement for heat pump off"
    annotation (Placement(transformation(extent={{540,380},{560,400}})));
  Modelica.Blocks.Logical.Not HeaPumOff[nBui] "ETS Heat pump off"
    annotation (Placement(transformation(extent={{500,380},{520,400}})));
  Modelica.Blocks.Sources.BooleanExpression HeaPumOn[nBui](y=bui.ets.chi.con.yPum)
    "ETS Heat pump signal on in each hub."
    annotation (Placement(transformation(extent={{460,420},{480,440}})));
  Buildings_Requirements.GreaterEqual reqPDis[nBui + 2](
    each name="District loop",
    each text="O-402: The pressure drop in the district loop and the service line must be no bigger than 125 Pa/m at full load.")
    "Requirement for pressure drop in the district loop"
    annotation (Placement(transformation(extent={{540,-380},{560,-360}})));
  Modelica.Blocks.Sources.RealExpression PDis[nBui + 2](y=fracPL)
    "Pressure drop in the district loop"
    annotation (Placement(transformation(extent={{500,-400},{520,-380}})));
  Modelica.Blocks.Sources.Constant fracPLMax[nBui + 2](each k=125)
    "Maximum pressure drop in the district loop setpoint"
    annotation (Placement(transformation(extent={{500,-360},{520,-340}})));
  Buildings_Requirements.WithinBand reqTHea[nBui](
    each name="ETS",
    each text="O-303: The space heating water supply temperature set point must be tracked within ± 1 K once the system is on for 5 minutes.",
    each use_activeInput=true,
    each delayTime(each displayUnit="min") = 300,
    each u_max(
      final unit="K",
      each displayUnit="K") = 1,
    each u_min(
      final unit="K",
      each displayUnit="K") = 1,
    each u(final unit="K", each displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for tracking the space heating water supply temperature set point"
    annotation (Placement(transformation(extent={{540,-440},{560,-420}})));
  Buildings_Requirements.WithinBand reqTCoo[nBui](
    each name="ETS",
    each text="O-304: The space cooling water supply temperature set point must be tracked within ± 1 K once the system is on for 5 minutes.",
    each use_activeInput=true,
    each delayTime(each displayUnit="min") = 300,
    each u_max(
      final unit="K",
      each displayUnit="K") = 1,
    each u_min(
      final unit="K",
      each displayUnit="K") = 1,
    each u(final unit="K", each displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for tracking the space cooling water supply temperature set point"
    annotation (Placement(transformation(extent={{540,-490},{560,-470}})));
  Modelica.Blocks.Math.Add THeaDiff[nBui](each k2=-1)
    "Space heating water supply temperature difference"
    annotation (Placement(transformation(extent={{500,-430},{520,-410}})));
  Modelica.Blocks.Math.Add TCooDiff[nBui](each k2=-1)
    "Space cooling water supply temperature difference"
    annotation (Placement(transformation(extent={{500,-480},{520,-460}})));
  Modelica.Blocks.Sources.RealExpression THeaSup[nBui](y=bui.bui.disFloHea.senTSup.T)
    "Space heating water supply temperature"
    annotation (Placement(transformation(extent={{460,-424},{480,-404}})));
  Modelica.Blocks.Sources.RealExpression THeaSupSet[nBui](y=bui.THeaWatSupSet.y)
    "Space heating water supply temperature set point"
    annotation (Placement(transformation(extent={{460,-436},{480,-416}})));
  Modelica.Blocks.Sources.BooleanExpression BooOn[nBui](each y=true)
    "True when the simulation starts"
    annotation (Placement(transformation(extent={{400,-460},{420,-440}})));
  Modelica.Blocks.Sources.RealExpression TCooSup[nBui](y=bui.bui.disFloCoo.senTSup.T)
    "Space cooling water supply temperature"
    annotation (Placement(transformation(extent={{460,-474},{480,-454}})));
  Modelica.Blocks.Sources.RealExpression TCooSupSet[nBui](y=bui.TChiWatSupSet.y)
    "Space cooling water supply temperature set point"
    annotation (Placement(transformation(extent={{460,-486},{480,-466}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage TRooHeaAvg60min[nBui](each delta(
        each displayUnit="min") = 3600) "Room heating difference over 60min"
    annotation (Placement(transformation(extent={{500,-80},{520,-60}})));
  Modelica.Blocks.Sources.RealExpression TRooHea[nBui](y=bui.bui.terUniHea.TLoaODE.TAir)
    "Room heating temperature"
    annotation (Placement(transformation(extent={{420,-110},{440,-90}})));
  Modelica.Blocks.Sources.RealExpression TRooHeaSet[nBui](y=bui.bui.terUniHea.TLoaODE.TSet)
    "Room heating temperature setpoint"
    annotation (Placement(transformation(extent={{420,-70},{440,-50}})));
  Modelica.Blocks.Math.Add TRooHeaDif[nBui](each k2=-1)
    "Room heating temperature difference from setpoint"
    annotation (Placement(transformation(extent={{460,-90},{480,-70}})));
  Modelica.Blocks.Continuous.Integrator TRooHeaAvgYea[nBui]
    "Room heating difference over the all simulation"
    annotation (Placement(transformation(extent={{500,-140},{520,-120}})));
  Modelica.Blocks.Sources.BooleanExpression last_value[nBui](each y=terminal())
    "End of the simulation"
    annotation (Placement(transformation(extent={{420,-160},{440,-140}})));
  Buildings_Requirements.WithinBand reqTHexEtsSecLvg[nBui](
    each name="ETS",
    each text="O-305: At the district heat exchanger in the ETS, the secondary side leaving water temperature that serves the heat pumps must be between 9.5°C and 25°C.",
    each delayTime(each displayUnit="min") = 300,
    each u_max(
      final unit="K",
      each displayUnit="degC") = 298.15,
    each u_min(
      final unit="K",
      each displayUnit="degC") = 282.65,
    each u(final unit="K", each displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for leaving water temperature on the secondary side of the heat exchanger in the ETS "
    annotation (Placement(transformation(extent={{540,200},{560,220}})));
  Modelica.Blocks.Sources.RealExpression THexPriLvg[nBui](y=dis.con.senTOut.T)
    "Temperature leaving the ETS heat exchanger on the primary side."
    annotation (Placement(transformation(extent={{500,160},{520,180}})));
  Buildings_Requirements.GreaterEqual reqTRooHea[nBui](
    each name="Room",
    each text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    each use_activeInput=true,
    each delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for heating"
    annotation (Placement(transformation(extent={{540,-80},{560,-60}})));
  Modelica.Blocks.Sources.Constant TRooHeaDifMax[nBui](each k=0.5)
    "Maximum room heating difference over 60min set point"
    annotation (Placement(transformation(extent={{500,-50},{520,-30}})));
  Buildings_Requirements.GreaterEqual reqTRooHeaAvg[nBui](
    each name="Room",
    each text="O-353_0: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    each use_activeInput=true,
    each delayTime(each displayUnit="s") = 0)
    "Requirement for the room temperature for heating (yearly average)"
    annotation (Placement(transformation(extent={{540,-128},{560,-108}})));
  Modelica.Blocks.Sources.Constant TRooHeaDifYea[nBui](each k=0.05)
    "Maximum room heating difference over the all simulation set point"
    annotation (Placement(transformation(extent={{500,-110},{520,-90}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage TRooCooAvg60min[nBui](each delta(
        each displayUnit="min") = 3600) "Room cooling difference over 60min"
    annotation (Placement(transformation(extent={{500,-220},{520,-200}})));
  Modelica.Blocks.Sources.RealExpression TRooCoo[nBui](y=bui.bui.terUniCoo.TLoaODE.TAir)
    "Room cooling temperature"
    annotation (Placement(transformation(extent={{420,-250},{440,-230}})));
  Modelica.Blocks.Sources.RealExpression TRooCooSet[nBui](y=bui.bui.terUniCoo.TLoaODE.TSet)
    "Room cooling temperature setpoint"
    annotation (Placement(transformation(extent={{420,-210},{440,-190}})));
  Modelica.Blocks.Math.Add TRooCooDif[nBui](each k1=-1)
    "Room cooling temperature difference from setpoint"
    annotation (Placement(transformation(extent={{460,-230},{480,-210}})));
  Modelica.Blocks.Continuous.Integrator TRooCooAvgYea[nBui]
    "Room cooling difference over the all simulation"
    annotation (Placement(transformation(extent={{500,-280},{520,-260}})));
  Buildings_Requirements.GreaterEqual reqTRooCoo[nBui](
    each name="Room",
    each text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    each use_activeInput=true,
    each delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for cooling"
    annotation (Placement(transformation(extent={{540,-220},{560,-200}})));
  Modelica.Blocks.Sources.Constant TRooCooDifMax[nBui](each k=0.5)
    "Maximum room cooling difference over 60min set point"
    annotation (Placement(transformation(extent={{500,-190},{520,-170}})));
  Buildings_Requirements.GreaterEqual reqTRooCooAvg[nBui](
    each name="Room",
    each text="O-353: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    each use_activeInput=true,
    each delayTime(each displayUnit="s") = 0)
    "Requirement for the room temperature for cooling (yearly average)"
    annotation (Placement(transformation(extent={{540,-268},{560,-248}})));
  Modelica.Blocks.Sources.Constant TRooCooDifYea[nBui](each k=0.05)
    "Maximum room cooling difference over the all simulation set point"
    annotation (Placement(transformation(extent={{500,-250},{520,-230}})));
  Buildings_Requirements.StableContinuousSignal reqStaVal[19](each name="Valves",
      each text="O-202: All control valves must show stable operation.")
    "Requirements to verify stability of control valves"
    annotation (Placement(transformation(extent={{540,340},{560,360}})));
  Modelica.Blocks.Sources.RealExpression Valy[19](y=y_value)
    annotation (Placement(transformation(extent={{500,344},{520,364}})));
  ThermalGridJBA.Data.MilpData milpData
    annotation (Placement(transformation(extent={{-380,500},{-360,520}})));
 Buildings_Requirements.GreaterEqual reqEneCos(name="system", text="O-1-102: Energy cost must not be higher than 10% of cost computed in the architectural optimization.")
    "Requirement for energy cost"
    annotation (Placement(transformation(extent={{540,500},{562,520}})));
 Buildings_Requirements.GreaterEqual reqEneImp(name="system", text="O-2-103: Imported annual energy must not be higher than 10% of the imported energy computed in the architectural optimization.")
    "Requirement for energy import"
    annotation (Placement(transformation(extent={{540,460},{562,480}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiMilCos(k=1.1)
    "10% increase of the energy cost form the MILP simulation"
    annotation (Placement(transformation(extent={{498,510},{518,530}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiMilImp(k=1.1)
    "10% increase of the energy import form the MILP simulation"
    annotation (Placement(transformation(extent={{500,470},{520,490}})));
  Modelica.Blocks.Sources.RealExpression MilCos(y=milpData.ECos)
    "Cost form MILP simulation."
    annotation (Placement(transformation(extent={{460,510},{480,530}})));
  Modelica.Blocks.Sources.RealExpression MilImp(y=milpData.ECos)
    "Energy import from the MILP simulation."
    annotation (Placement(transformation(extent={{460,470},{480,490}})));
  inner Modelica_Requirements.Verify.PrintViolations printViolations
    annotation (Placement(transformation(extent={{580,520},{600,540}})));
equation


  connect(senTemDhwSup.y,reqTDhwSup. u) annotation (Line(points={{521,312},{528,
          312},{528,314},{539,314}}, color={0,0,127}));
  connect(valEvaOpen.y,reqTHeaPumEvaLvg. active) annotation (Line(points={{522,80},
          {530,80},{530,106},{538,106}},
                                      color={255,0,255}));
  connect(valConOpen.y,reqTHeaPumConLvg. active) annotation (Line(points={{522,0},
          {532,0},{532,26},{538,26}},     color={255,0,255}));
  connect(valIsoConPos.y,valConOpen. u)
    annotation (Line(points={{481,0},{498,0}},       color={0,0,127}));
  connect(valIsoEvaPos.y,valEvaOpen. u)
    annotation (Line(points={{481,80},{498,80}},   color={0,0,127}));
  connect(THeaPumEvaLvg.y,reqTHeaPumEvaLvg. u_max) annotation (Line(points={{521,130},
          {530,130},{530,116},{539,116}},  color={0,0,127}));
  connect(TmaxHeaPumConLvg.y,reqTHeaPumConLvg. u_max) annotation (Line(points={{521,50},
          {532,50},{532,36},{539,36}},             color={0,0,127}));
  connect(THeaPumCon.y,reqTHeaPumConLvg. u_min) annotation (Line(points={{521,30},
          {532,30},{532,32},{539,32}},    color={0,0,127}));
  connect(THexWatEnt.y,reqTWatSer. u) annotation (Line(points={{521,-310},{530,-310},
          {530,-306},{539,-306}}, color={0,0,127}));
  connect(TDisWatSup.T,reqTPlaMix. u) annotation (Line(points={{-91,170},{-218,170},
          {-218,-172},{62,-172},{62,-332},{570,-332},{570,-528},{526,-528},{526,
          -506},{539,-506}},       color={0,0,127}));
  connect(TTanTop.y,reqTDhwTan. u) annotation (Line(points={{521,260},{530,260},
          {530,254},{539,254}}, color={0,0,127}));
  connect(DhwTanCha.y,reqTDhwTan. active) annotation (Line(points={{521,240},{532,
          240},{532,246},{538,246}}, color={255,0,255}));
  connect(TminHeaPumEva.y,reqTHeaPumEvaLvg. u_min) annotation (Line(points={{521,110},
          {530,110},{530,112},{539,112}},  color={0,0,127}));
  connect(HeaPumOn.y,reqHeaPumOn. u)
    annotation (Line(points={{481,430},{538,430}}, color={255,0,255}));
  connect(HeaPumOff.y,reqHeaPumOff. u)
    annotation (Line(points={{521,390},{538,390}}, color={255,0,255}));
  connect(HeaPumOn.y,HeaPumOff. u) annotation (Line(points={{481,430},{490,430},
          {490,390},{498,390}}, color={255,0,255}));
  connect(fracPLMax.y,reqPDis. u_max) annotation (Line(points={{521,-350},{530,-350},
          {530,-364},{539,-364}}, color={0,0,127}));
  connect(PDis.y,reqPDis. u_min) annotation (Line(points={{521,-390},{530,-390},
          {530,-368},{539,-368}}, color={0,0,127}));
  connect(THeaDiff.y,reqTHea. u) annotation (Line(points={{521,-420},{530,-420},
          {530,-426},{539,-426}}, color={0,0,127}));
  connect(TCooDiff.y,reqTCoo. u) annotation (Line(points={{521,-470},{530,-470},
          {530,-476},{539,-476}}, color={0,0,127}));
  connect(BooOn.y,reqTHea. active) annotation (Line(points={{421,-450},{448,-450},
          {448,-434},{538,-434}}, color={255,0,255}));
  connect(BooOn.y,reqTCoo. active) annotation (Line(points={{421,-450},{448,-450},
          {448,-484},{538,-484}}, color={255,0,255}));
  connect(TCooSup.y,TCooDiff. u1)
    annotation (Line(points={{481,-464},{498,-464}}, color={0,0,127}));
  connect(TCooSupSet.y,TCooDiff. u2)
    annotation (Line(points={{481,-476},{498,-476}}, color={0,0,127}));
  connect(THeaSup.y,THeaDiff. u1)
    annotation (Line(points={{481,-414},{498,-414}}, color={0,0,127}));
  connect(THeaSupSet.y,THeaDiff. u2)
    annotation (Line(points={{481,-426},{498,-426}}, color={0,0,127}));
  connect(TRooHeaSet.y,TRooHeaDif. u1) annotation (Line(points={{441,-60},{448,-60},
          {448,-74},{458,-74}},         color={0,0,127}));
  connect(TRooHea.y,TRooHeaDif. u2) annotation (Line(points={{441,-100},{448,-100},
          {448,-86},{458,-86}},   color={0,0,127}));
  connect(TRooHeaDif.y,TRooHeaAvg60min. u) annotation (Line(points={{481,-80},{490,
          -80},{490,-70},{498,-70}},        color={0,0,127}));
  connect(TRooHeaDif.y,TRooHeaAvgYea. u) annotation (Line(points={{481,-80},{490,
          -80},{490,-130},{498,-130}},  color={0,0,127}));
  connect(THexSecLvg.y,reqTHexEtsSecLvg. u) annotation (Line(points={{521,210},{
          532,210},{532,214},{539,214}}, color={0,0,127}));
  connect(THexPriLvg.y,reqTHexEtsPriLvg. u) annotation (Line(points={{521,170},{
          530,170},{530,174},{539,174}},
                                  color={0,0,127}));
  connect(TRooHeaAvg60min.y,reqTRooHea. u_min) annotation (Line(points={{522,-70},
          {530,-70},{530,-68},{539,-68}},    color={0,0,127}));
  connect(TRooHeaDifMax.y,reqTRooHea. u_max) annotation (Line(points={{521,-40},
          {530,-40},{530,-64},{539,-64}},    color={0,0,127}));
  connect(TRooHeaDifYea.y,reqTRooHeaAvg. u_max) annotation (Line(points={{521,-100},
          {530,-100},{530,-112},{539,-112}}, color={0,0,127}));
  connect(TRooHeaAvgYea.y,reqTRooHeaAvg. u_min) annotation (Line(points={{521,-130},
          {530,-130},{530,-116},{539,-116}}, color={0,0,127}));
  connect(last_value.y,reqTRooHeaAvg. active) annotation (Line(points={{441,-150},
          {534,-150},{534,-122},{538,-122}}, color={255,0,255}));
  connect(TRooCooSet.y,TRooCooDif. u1) annotation (Line(points={{441,-200},{450,
          -200},{450,-214},{458,-214}}, color={0,0,127}));
  connect(TRooCoo.y,TRooCooDif. u2) annotation (Line(points={{441,-240},{450,-240},
          {450,-226},{458,-226}}, color={0,0,127}));
  connect(TRooCooDif.y,TRooCooAvg60min. u) annotation (Line(points={{481,-220},{
          490,-220},{490,-210},{498,-210}}, color={0,0,127}));
  connect(TRooCooDif.y,TRooCooAvgYea. u) annotation (Line(points={{481,-220},{490,
          -220},{490,-270},{498,-270}}, color={0,0,127}));
  connect(TRooCooAvg60min.y,reqTRooCoo. u_min) annotation (Line(points={{522,-210},
          {530,-210},{530,-208},{539,-208}}, color={0,0,127}));
  connect(TRooCooDifMax.y,reqTRooCoo. u_max) annotation (Line(points={{521,-180},
          {530,-180},{530,-204},{539,-204}}, color={0,0,127}));
  connect(TRooCooDifYea.y,reqTRooCooAvg. u_max) annotation (Line(points={{521,-240},
          {530,-240},{530,-252},{539,-252}}, color={0,0,127}));
  connect(TRooCooAvgYea.y,reqTRooCooAvg. u_min) annotation (Line(points={{521,-270},
          {530,-270},{530,-256},{539,-256}}, color={0,0,127}));
  connect(last_value.y,reqTRooCooAvg. active) annotation (Line(points={{441,-150},
          {534,-150},{534,-262},{538,-262}}, color={255,0,255}));
  connect(BooOn.y,reqTRooCoo. active) annotation (Line(points={{421,-450},{448,-450},
          {448,-530},{580,-530},{580,-230},{530,-230},{530,-214},{538,-214}},
        color={255,0,255}));
  connect(BooOn.y,reqTRooHea. active) annotation (Line(points={{421,-450},{448,-450},
          {448,-530},{580,-530},{580,-90},{530,-90},{530,-74},{538,-74}},
        color={255,0,255}));
  connect(Valy.y,reqStaVal. u)
    annotation (Line(points={{521,354},{539,354}}, color={0,0,127}));
  connect(gaiMilCos.y, reqEneCos.u_max) annotation (Line(points={{520,520},{530,
          520},{530,516},{538.9,516}}, color={0,0,127}));
  connect(gaiMilImp.y, reqEneImp.u_max) annotation (Line(points={{522,480},{530,
          480},{530,476},{538.9,476}}, color={0,0,127}));
  connect(ETot.y, reqEneImp.u_min) annotation (Line(points={{382,100},{450,100},
          {450,460},{530,460},{530,472},{538.9,472}}, color={0,0,127}));
  connect(totEleCos.y, reqEneCos.u_min) annotation (Line(points={{361,-130},{361,
          -132},{410,-132},{410,500},{530,500},{530,512},{538.9,512}}, color={0,
          0,127}));
  connect(MilCos.y, gaiMilCos.u)
    annotation (Line(points={{481,520},{496,520}}, color={0,0,127}));
  connect(MilImp.y, gaiMilImp.u)
    annotation (Line(points={{481,480},{498,480}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(extent={{-400,-540},{600,540}})), Icon(
        coordinateSystem(extent={{-100,-100},{100,100}})));
end DetailedPlantFiveHubsWithRequirementsVerification;
