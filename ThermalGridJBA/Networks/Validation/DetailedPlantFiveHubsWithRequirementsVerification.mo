within ThermalGridJBA.Networks.Validation;
model DetailedPlantFiveHubsWithRequirementsVerification
  extends DetailedPlantFiveHubs(dis(roughness=datDis.roughness));
  Real fracPL[nBui + 1](each unit="Pa/m") = {
    dis.con[1].pipDis.dp / dis.con[1].pipDis.length,
    dis.con[2].pipDis.dp / dis.con[2].pipDis.length,
    dis.con[3].pipDis.dp / dis.con[3].pipDis.length,
    dis.con[4].pipDis.dp / dis.con[4].pipDis.length,
    dis.con[5].pipDis.dp / dis.con[5].pipDis.length,
    dis.pipEnd.dp / dis.pipEnd.length}
 "Pressure drop per length unit for each pipe (Pa/m)";
  Real y_value[5*3 + 4]={bui[1].ets.hex.val2.y_actual,bui[2].ets.hex.val2.y_actual,
      bui[3].ets.hex.val2.y_actual,bui[4].ets.hex.val2.y_actual,bui[5].ets.hex.val2.y_actual,
      bui[1].ets.heaPum.valEva.y_actual,bui[2].ets.heaPum.valEva.y_actual,bui[3].ets.heaPum.valEva.y_actual,
      bui[4].ets.heaPum.valEva.y_actual,bui[5].ets.heaPum.valEva.y_actual,bui[1].ets.heaPum.valCon.y_actual,
      bui[2].ets.heaPum.valCon.y_actual,bui[3].ets.heaPum.valCon.y_actual,bui[4].ets.heaPum.valCon.y_actual,
      bui[5].ets.heaPum.valCon.y_actual,bui[2].ets.tanDhw.domHotWatTan.divVal.y_actual,
      bui[3].ets.tanDhw.domHotWatTan.divVal.y_actual,bui[4].ets.tanDhw.domHotWatTan.divVal.y_actual,
      bui[5].ets.tanDhw.domHotWatTan.divVal.y_actual}
    "Valves actuator values for the control valves of each ETS (heat exchanger, condenser loop of the chiller, evaporator loop of the chiller, domestichot water when present)";
  Modelica.Blocks.Sources.RealExpression TDhwSup[nBui](y=if time < tStart + 3600
         then datBuiSet.THotWatSupFix_nominal*ones(nBui) else {datBuiSet.THotWatSupFix_nominal,
        bui[2].ets.tanDhw.theMixVal.senTMix.T,bui[3].ets.tanDhw.theMixVal.senTMix.T,
        bui[4].ets.tanDhw.theMixVal.senTMix.T,bui[5].ets.tanDhw.theMixVal.senTMix.T})
    "Domestic hot water supply temperature for each hub, except hub[1] that does not provide domestic hot water."
    annotation (Placement(transformation(extent={{580,344},{600,364}})));
  Buildings_Requirements.WithinBand reqTDhwSup[nBui](
    each name="DHW",
    each text="O-301: The domestic hot water supply temperature must be 45°C ± 1 K.",
    each delayTime=30,
    each u_max(
      final unit="K",
      displayUnit="degC") = 319.15,
    each u_min(
      final unit="K",
      displayUnit="degC") = 317.15,
    each u(
      final unit="K",
      displayUnit="K"),
    each witBan(u(
      final unit="K",
      displayUnit="K")))
    "Requirement for domestic hot water supply temperature"
    annotation (Placement(transformation(extent={{620,340},{640,360}})));
  Buildings_Requirements.WithinBand reqTDhwTan[nBui](
    each name="DHW",
    each text=
        "O-302: The heating water temperature that serves the domestic hot water tank must be no less than 1 K below and 5 K above the heating water temperature set point once the tank charging is on for 10 minutes.",
    each use_activeInput=true,
    each delayTime(each displayUnit="min") = 1200,
    each u_max(final unit="K") = 1,
    each u_min(final unit="K") = -5,
    each u(final unit="K", each displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for the heating water temperature that serves the domestic hot water tank"
    annotation (Placement(transformation(extent={{620,180},{640,200}})));
  Modelica.Blocks.Sources.RealExpression TTanDhwSet[nBui](y(
      each final unit="K",
      each displayUnit="degC") = {50 + 273.15,bui[5].ets.heaPum.con.conHea.u_s,
      bui[5].ets.heaPum.con.conHea.u_s,bui[5].ets.heaPum.con.conHea.u_s,bui[5].ets.heaPum.con.conHea.u_s})
    "Temperature set point for heating water to be supplied to DHW tank, except hub[1] that does not provide DHW."
    annotation (Placement(transformation(extent={{540,190},{560,210}})));

  Modelica.Blocks.Sources.RealExpression TTanHeaSup[nBui](
    y(each final unit="K", each displayUnit="degC")={
      50 + 273.15,
      bui[2].ets.tanDhw.domHotWatTan.senTemHeaSup.T,
      bui[3].ets.tanDhw.domHotWatTan.senTemHeaSup.T,
      bui[4].ets.tanDhw.domHotWatTan.senTemHeaSup.T,
      bui[5].ets.tanDhw.domHotWatTan.senTemHeaSup.T})
    "Temperature of heating water supplied to the DHW tank, except hub[1] that does not provide DHW."
    annotation (Placement(transformation(extent={{540,174},{560,194}})));
  Modelica.Blocks.Sources.BooleanExpression dhwTanCha[nBui](y={false,bui[2].ets.tanDhw.charge,
        bui[3].ets.tanDhw.charge,bui[4].ets.tanDhw.charge,bui[5].ets.tanDhw.charge})
    "True when the domestic hot water tank is charging for each hub with domestic hot water, false for hub[1] that does not provide domestic hot water."
    annotation (Placement(transformation(extent={{420,156},{440,176}})));
  Modelica.Blocks.Sources.RealExpression THexSecLvg[nBui](y=bui.ets.hex.senT2WatLvg.T)
    "Temperature leaving the ETS heat exchanger on the secondary side."
    annotation (Placement(transformation(extent={{580,140},{600,160}})));
  Buildings_Requirements.WithinBand reqTHexEtsPriLvg[nBui](
    each name="ETS",
    each text="O-306: At the district heat exchanger in the ETS, the primary side leaving water temperature that is fed back to the district loop must be between 6.5°C and 28°C.",
    each delayTime(each displayUnit="min") = 300,
    each u_max(
      final unit="K",
      displayUnit="degC") = 301.15,
    each u_min(
      final unit="K",
      displayUnit="degC") = 279.65,
    each u(
      final unit="K",
      displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for  leaving water temperature on the primary side of the heat exchanger in the ETS "
    annotation (Placement(transformation(extent={{620,100},{640,120}})));
  Modelica.Blocks.Sources.RealExpression TWatSer[nBui](
    y=dis.con.junConSup.vol.T)
    "Water temperature serving each service line"
    annotation (Placement(transformation(extent={{580,-460},{600,-440}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumEvaLvg[nBui](
    each name="ETS",
    each text="O-308: The heat pump evaporator leaving water temperature must be at least 3.5°C, and be preferably higher, once the system draws heat from the district for at least 5 minutes.",
    each use_activeInput=true,
    each u_max(final unit="K", each displayUnit="degC"),
    each u_min(final unit="K", each displayUnit="degC"),
    each delayTime(each displayUnit="min") = 300)
    "Requirement for heat pump evaporator leaving water temperature"
    annotation (Placement(transformation(extent={{620,40},{640,60}})));
  Buildings_Requirements.GreaterEqual reqTHeaPumConLvg[nBui](
    each name="ETS",
    each text=" O-309: The heat pump condenser leaving water temperature must not exceed 31°C once the system rejects heat to the district for at least 5 minutes.",
    each use_activeInput=true,
    each u_max(
      final unit="K",
      displayUnit="degC"),
    each u_min(
      final unit="K",
      displayUnit="degC"),
    each delayTime(displayUnit="min") = 300)
    "Requirement for heat pump condenser leaving water temperature"
    annotation (Placement(transformation(extent={{620,-40},{640,-20}})));
  Buildings_Requirements.WithinBand reqTWatSer[nBui](
    each name="Network",
    each text="O-401: The water that is served to each service line must be between 10.5°C and 24°C.",
    each delayTime(each displayUnit="min") = 300,
    each u_max(
      final unit="K",
      displayUnit="degC") = 297.15,
    each u_min(
      final unit="K",
      displayUnit="degC") = 283.65,
    each u(
      final unit="K",
      displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for water temperature serving each service line"
    annotation (Placement(transformation(extent={{620,-460},{640,-440}})));
  Modelica.Blocks.Sources.RealExpression THeaPumEvaLvg[nBui](y=bui.ets.heaPum.senTEvaLvg.T)
    "Temperature of the water leaving the heat pump on the evaporator side."
    annotation (Placement(transformation(extent={{580,60},{600,80}})));
  Modelica.Blocks.Sources.RealExpression THeaPumCon[nBui](y=bui.ets.heaPum.senTConLvg.T)
    "Heat pump condenser leaving water temperature "
    annotation (Placement(transformation(extent={{500,-38},{520,-18}})));
  Modelica.Blocks.Sources.BooleanExpression valIsoEvaCom[nBui](y=not bui.ets.conAmbEva.u)
    "Evaporator to ambient loop isolation valve command"
    annotation (Placement(transformation(extent={{580,10},{600,30}})));
  Modelica.Blocks.Sources.BooleanExpression valIsoConCom[nBui](y=not bui.ets.conAmbCon.u)
    "Condenser to ambient loop isolation valve command"
    annotation (Placement(transformation(extent={{580,-50},{600,-30}})));
  Modelica.Blocks.Sources.Constant TMaxHeaPumConLvg[nBui](each k(
      each final unit="K",
      each displayUnit="degC") = 304.15)
    "Maximum heat pump condenser leaving water temperature during heat rejection"
    annotation (Placement(transformation(extent={{580,-20},{600,0}})));
  Modelica.Blocks.Sources.Constant TMinHeaPumEva[nBui](each k(
      final unit="K",
      each displayUnit="degC") = 276.65)
    "Minimum heat pump evaporator leaving water temperature"
    annotation (Placement(transformation(extent={{580,40},{600,60}})));
  Buildings_Requirements.WithinBand reqTPlaMix(
    each name="Central plant",
    each text="O-503: The mixing water temperature in the district loop after the central plant must be between 10.5°C and 24°C.",
    each delayTime(displayUnit="min") = 300,
    each u_max(
      final unit="K",
      displayUnit="degC") = 297.15,
    each u_min(
      final unit="K",
      displayUnit="degC") = 283.65,
    each u(
      final unit="K",
      displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for mixing water temperature in the district loop after the central plant"
    annotation (Placement(transformation(extent={{620,-580},{640,-560}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOn[nBui](
    each name="Heat pump",
    each text="O-201_0: The heat pump must operate at least 30 min when activated.",
    each durationMin(displayUnit="min") = 1800) "Requirement for heat pump on"
    annotation (Placement(transformation(extent={{620,460},{640,480}})));
  Buildings_Requirements.MinimumDuration reqHeaPumOff[nBui](
    each name="Heat pump",
    each text="O-201_1: The heat pump must remain off for at least 10 minutes.",
    each durationMin(displayUnit="min") = 600) "Requirement for heat pump off"
    annotation (Placement(transformation(extent={{620,420},{640,440}})));
  Modelica.Blocks.Logical.Not heaPumOff[nBui] "ETS Heat pump off"
    annotation (Placement(transformation(extent={{580,420},{600,440}})));
  Modelica.Blocks.Sources.BooleanExpression heaPumOn[nBui](y=bui.ets.heaPum.con.yPum)
    "ETS Heat pump signal on in each hub"
    annotation (Placement(transformation(extent={{540,460},{560,480}})));
  Buildings_Requirements.GreaterEqual reqRDis[nBui + 1](
    each name="District loop",
    each text="O-402: The pressure drop in the district loop and the service line must be no bigger than 125 Pa/m at full load.",
    each u_max(final unit="Pa/m"),
    each u_min(final unit="Pa/m"))
    "Requirement for pressure drop for each pipe of the district loop"
    annotation (Placement(transformation(extent={{620,-520},{640,-500}})));
  Modelica.Blocks.Sources.RealExpression RDisLoo[nBui + 1](y(each unit="Pa/m")
       = fracPL)
    "Pressure drop per meter of pipe for each pipe of the district loop"
    annotation (Placement(transformation(extent={{580,-540},{600,-520}})));
  Modelica.Blocks.Sources.Constant RMaxDisLoo[nBui + 1](each k(unit="Pa/m") = 125.01)
              "Maximum pressure drop per meter of pipe of the district loop"
    annotation (Placement(transformation(extent={{580,-500},{600,-480}})));
  Buildings_Requirements.WithinBand reqTSpaHeaSup[nBui](
    each name="ETS",
    each text="O-303: The space heating water supply temperature set point must be tracked within ± 1 K once the system is once the system is in space heating mode for 10 minutes.",
    each use_activeInput=true,
    each delayTime(each displayUnit="min") = 600,
    each u_max(
      final unit="K",
      each displayUnit="K") = 1,
    each u_min(
      final unit="K",
      each displayUnit="K") = -1,
    each u(final unit="K", each displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for tracking the space heating water supply temperature"
    annotation (Placement(transformation(extent={{620,300},{640,320}})));
  Buildings_Requirements.WithinBand reqTCoo[nBui](
    each name="ETS",
    each text=
        "O-304: The space cooling water supply temperature set point must be tracked within ± 1 K once the system is in space cooling mode for 10 minutes.",
    each use_activeInput=true,
    each delayTime(each displayUnit="min") = 600,
    each u_max(
      final unit="K",
      each displayUnit="K") = 1,
    each u_min(
      final unit="K",
      each displayUnit="K") = -1,
    each u(final unit="K", each displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for tracking the space cooling water supply temperature"
    annotation (Placement(transformation(extent={{620,240},{640,260}})));
  Modelica.Blocks.Math.Add dTHea[nBui](each k2=-1)
    "Space heating water supply temperature difference"
    annotation (Placement(transformation(extent={{580,310},{600,330}})));
  Modelica.Blocks.Math.Add dTCoo[nBui](each k2=-1)
    "Space cooling water supply temperature difference"
    annotation (Placement(transformation(extent={{580,250},{600,270}})));
  Modelica.Blocks.Sources.RealExpression THeaSup[nBui](y=bui.ets.senTSpaHeaSup.T)
    "Space heating water supply temperature"
    annotation (Placement(transformation(extent={{540,316},{560,336}})));
  Modelica.Blocks.Sources.RealExpression THeaSupSet[nBui](y=bui.THeaWatSupSet.y)
    "Space heating water supply temperature set point"
    annotation (Placement(transformation(extent={{540,304},{560,324}})));
  Modelica.Blocks.Sources.RealExpression TCooSup[nBui](y=bui.ets.senTSpaCooSup.T)
    "Space cooling water supply temperature"
    annotation (Placement(transformation(extent={{540,256},{560,276}})));
  Modelica.Blocks.Sources.RealExpression TCooSupSet[nBui](y=bui.TChiWatSupSet.y)
    "Space cooling water supply temperature set point"
    annotation (Placement(transformation(extent={{540,244},{560,264}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage dTRooHeaAvg60min[nBui](each
      delta(displayUnit="min") = 3600)
    "Room temperature difference for heating over 60 minutes"
    annotation (Placement(transformation(extent={{580,-140},{600,-120}})));
  Modelica.Blocks.Sources.RealExpression TRooHea[nBui](y=bui.bui.terUniHea.TLoaODE.TAir)
    "Room heating temperature"
    annotation (Placement(transformation(extent={{420,-170},{440,-150}})));
  Modelica.Blocks.Sources.RealExpression TRooHeaSet[nBui](y=bui.bui.terUniHea.TLoaODE.TSet)
    "Room heating temperature setpoint"
    annotation (Placement(transformation(extent={{420,-130},{440,-110}})));
  Modelica.Blocks.Math.Add dTRooHea[nBui](each k2=-1)
    "Room heating temperature difference from setpoint"
    annotation (Placement(transformation(extent={{460,-150},{480,-130}})));
  Modelica.Blocks.Sources.BooleanExpression simEnd[nBui](each y=terminal())
    "End of the simulation"
    annotation (Placement(transformation(extent={{420,-200},{440,-180}})));
  Buildings_Requirements.WithinBand reqTHexEtsSecLvg[nBui](
    each name="ETS",
    each text="O-305: At the district heat exchanger in the ETS, the secondary side leaving water temperature that serves the heat pumps must be between 9.5°C and 25°C.",
    each delayTime(each displayUnit="min") = 300,
    each u_max(
      final unit="K",
      displayUnit="degC") = 298.15,
    each u_min(
      final unit="K",
      displayUnit="degC") = 282.65,
    each u(
      final unit="K",
      displayUnit="K"),
    each witBan(u(final unit="K")))
    "Requirement for leaving water temperature on the secondary side of the heat exchanger in the ETS "
    annotation (Placement(transformation(extent={{620,140},{640,160}})));
  Modelica.Blocks.Sources.RealExpression THexPriLvg[nBui](y=dis.con.senTOut.T)
    "Temperature leaving the ETS heat exchanger on the primary side."
    annotation (Placement(transformation(extent={{580,100},{600,120}})));
  Buildings_Requirements.GreaterEqual reqTRooHea[nBui](
    each name="Room",
    each text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    each use_activeInput=true,
    each u_max(
      final unit="K"),
    each u_min(
      final unit="K"),
    each delayTime(displayUnit="min") = 3600)
    "Requirement for the room temperature for heating"
    annotation (Placement(transformation(extent={{620,-140},{640,-120}})));
  Modelica.Blocks.Sources.Constant dTMaxRooHea60min[nBui](each k=0.5)
    "Maximum room temperature difference for heating over 60 minutes"
    annotation (Placement(transformation(extent={{580,-110},{600,-90}})));
  Buildings_Requirements.GreaterEqual reqTRooHeaAvg[nBui](
    each name="Room",
    each text="O-353_0: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    each use_activeInput=true,
    each u_max(
      final unit="K"),
    each u_min(
      final unit="K"),
    each delayTime(displayUnit="s") = 0)
    "Requirement for the room temperature for heating (yearly average)"
    annotation (Placement(transformation(extent={{620,-200},{640,-180}})));
  Modelica.Blocks.Sources.Constant dTMaxRooHeaYea[nBui](each k=0.05)
    "Maximum room temperature difference for heating over the all simulation"
    annotation (Placement(transformation(extent={{580,-180},{600,-160}})));
  Buildings.Controls.OBC.CDL.Reals.MovingAverage dTRooCooAvg60min[nBui](each
      delta(displayUnit="min") = 3600)
    "Room temperature difference for cooling over 60 minutes"
    annotation (Placement(transformation(extent={{580,-320},{600,-300}})));
  Modelica.Blocks.Sources.RealExpression TRooCoo[nBui](y=bui.bui.terUniCoo.TLoaODE.TAir)
    "Room cooling temperature"
    annotation (Placement(transformation(extent={{420,-350},{440,-330}})));
  Modelica.Blocks.Sources.RealExpression TRooCooSet[nBui](y=bui.bui.terUniCoo.TLoaODE.TSet)
    "Room cooling temperature setpoint"
    annotation (Placement(transformation(extent={{420,-310},{440,-290}})));
  Modelica.Blocks.Math.Add TRooCooDif[nBui](each k1=-1)
    "Room cooling temperature difference from setpoint"
    annotation (Placement(transformation(extent={{460,-330},{480,-310}})));
  Modelica.Blocks.Continuous.Integrator intdTRooCoo[nBui]
    "Integration of the difference in temperature when flow rate is not null"
    annotation (Placement(transformation(extent={{540,-380},{560,-360}})));
  Buildings_Requirements.GreaterEqual reqTRooCoo[nBui](
    each name="Room",
    each text="O-351: The room temperature set point must be tracked within ± 0.5 K during any 60 min window.",
    each use_activeInput=true,
    each u_max(
      final unit="K"),
    each u_min(
      final unit="K"),
    each delayTime(each displayUnit="min") = 3600)
    "Requirement for the room temperature for cooling"
    annotation (Placement(transformation(extent={{620,-320},{640,-300}})));
  Modelica.Blocks.Sources.Constant dTMaxRooCoo60min[nBui](each k=0.5)
    "Maximum room temperature difference for cooling over 60 min"
    annotation (Placement(transformation(extent={{580,-290},{600,-270}})));
  Buildings_Requirements.GreaterEqual reqTRooCooAvg[nBui](
    each name="Room",
    each text="O-353: The room temperature set point must be tracked within ± 0.05 K averaged over the year",
    each use_activeInput=true,
    each u_max(
      final unit="K"),
    each u_min(
      final unit="K"),
    each delayTime(displayUnit="s") = 0)
    "Requirement for the room temperature for cooling (yearly average)"
    annotation (Placement(transformation(extent={{620,-372},{640,-352}})));
  Modelica.Blocks.Sources.Constant dTMaxRooCooYea[nBui](each k=0.05)
    "Maximum room temperature difference for cooling over the all simulation"
    annotation (Placement(transformation(extent={{580,-350},{600,-330}})));
  Buildings_Requirements.StableContinuousSignal reqStaVal[19](each name="Valves",
      each text="O-202: All control valves must show stable operation.")
    "Requirement to verify stability of control valves"
    annotation (Placement(transformation(extent={{620,380},{640,400}})));
  Modelica.Blocks.Sources.RealExpression yVal[19](y=y_value)
    "Control valves position"
    annotation (Placement(transformation(extent={{580,384},{600,404}})));
  ThermalGridJBA.Data.MilpData milpData
    annotation (Placement(transformation(extent={{-380,500},{-360,520}})));
 Buildings_Requirements.GreaterEqual reqEneCos(name="system", text="O-1-102: Energy cost must not be higher than 10% of cost computed in the architectural optimization.")
    "Requirement for energy cost"
    annotation (Placement(transformation(extent={{620,540},{640,560}})));
 Buildings_Requirements.GreaterEqual reqEneImp(name="system",
   text="O-2-103: Imported annual energy must not be higher than 10% of the imported energy computed in the architectural optimization.",
      u_min(final unit="J", displayUnit="kWh"),
      u_max(final unit="kW.h", displayUnit="kWh"))
    "Requirement for energy import"
    annotation (Placement(transformation(extent={{620,500},{640,520}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiMilCos(k=1.1)
    "10% increase of the energy cost form the MILP simulation"
    annotation (Placement(transformation(extent={{580,550},{600,570}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiMilImp(k=1.1)
    "10% increase of the energy import from the MILP simulation"
    annotation (Placement(transformation(extent={{580,510},{600,530}})));
  Modelica.Blocks.Sources.RealExpression milCos(y=milpData.ECos)
    "Cost from MILP simulation"
    annotation (Placement(transformation(extent={{540,550},{560,570}})));
  Modelica.Blocks.Sources.RealExpression milImp(y=milpData.EImp)
    "Energy import from the MILP simulation"
    annotation (Placement(transformation(extent={{540,510},{560,530}})));
  inner Modelica_Requirements.Verify.PrintViolations printViolations
    annotation (Placement(transformation(extent={{660,560},{680,580}})));
  Modelica.Blocks.Sources.RealExpression QRooCoo[nBui](y=bui.bui.QReqCoo_flow)
    "Room cooling flow rate"
    annotation (Placement(transformation(extent={{420,-290},{440,-270}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold thrRooCoo[nBui](
    each t=-100,
    each h=50)
    "Room cooling flow rate not null"
    annotation (Placement(transformation(extent={{460,-290},{480,-270}})));
  Modelica.Blocks.Sources.RealExpression QRooHea[nBui](y=bui.bui.QReqHea_flow)
    "Room heating flow rate"
    annotation (Placement(transformation(extent={{420,-110},{440,-90}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold thrRooHea[nBui](
    each t=100,
    each h=50)
    "Room heating flow rate not null"
    annotation (Placement(transformation(extent={{460,-110},{480,-90}})));
  Modelica.Blocks.Logical.Switch swiRooCoo[nBui]
    "Difference in room temperature with the setpoint when cooling flow rate is not null"
    annotation (Placement(transformation(extent={{500,-380},{520,-360}})));
  Modelica.Blocks.Continuous.Integrator intQRooCooOn[nBui](each y_start=0.00001)
    "Total time with room cooling flow rate on (start not 0 to avoid dividing by 0)"
    annotation (Placement(transformation(extent={{540,-420},{560,-400}})));
  Modelica.Blocks.Math.Division dTRooCooYea[nBui]
    "Room temperature difference for cooling over the all simulation when cooling is active"
    annotation (Placement(transformation(extent={{580,-400},{600,-380}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal QRooCooOn[nBui]
    "1 when Room cooling flow rate is not null, 0 otherwise"
    annotation (Placement(transformation(extent={{500,-420},{520,-400}})));
  Modelica.Blocks.Sources.Constant zero[nBui](each k=0) "Signal with value 0"
    annotation (Placement(transformation(extent={{420,-260},{440,-240}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal QRooHeaOn[nBui]
    "1 when Room heating flow rate is not null, 0 otherwise"
    annotation (Placement(transformation(extent={{500,-240},{520,-220}})));
  Modelica.Blocks.Continuous.Integrator intQRooHeaOn[nBui](each y_start=0.00001)
    "Total time with room heating flow rate on"
    annotation (Placement(transformation(extent={{540,-240},{560,-220}})));
  Modelica.Blocks.Logical.Switch swiRooHea[nBui]
    "Difference in room temperature with the setpoint when heating flow rate is not null"
    annotation (Placement(transformation(extent={{500,-200},{520,-180}})));
  Modelica.Blocks.Continuous.Integrator intdTRooHea[nBui]
    "Integration of the difference in temperature when heating flow rate is not null"
    annotation (Placement(transformation(extent={{540,-200},{560,-180}})));
  Modelica.Blocks.Math.Division dTRooHeaAvgYea[nBui]
    "Average Temperature difference between Room heating and setpoint since the beginning of the simulation"
    annotation (Placement(transformation(extent={{580,-220},{600,-200}})));
  Modelica.Blocks.Sources.BooleanExpression heaPumCooOn[nBui](y=bui.ets.heaPum.con.yPum)
    "ETS heat pump cooling signal on in each hub"
    annotation (Placement(transformation(extent={{540,220},{560,240}})));
  Modelica.Blocks.Sources.BooleanExpression staVer[nBui](
    each y=time >= tStart + 3600) "Outputs true if system is ready for verification"
    annotation (Placement(transformation(extent={{480,550},{500,570}})));
  Modelica.Blocks.Logical.Not dhWChaOff[nBui]
    "Output true if DHW tank is not charging"
    annotation (Placement(transformation(extent={{462,260},{482,280}})));
  Buildings.Controls.OBC.CDL.Logical.MultiAnd verTHeaSup[nBui](each nin=3)
    "Output true if heating supply temperature should be verified"
    annotation (Placement(transformation(extent={{540,280},{560,300}})));
protected
  parameter Modelica.Units.SI.Time tStart(fixed=false)
    "Start of the simulation";
  Buildings.Controls.OBC.CDL.Reals.Subtract conErrTSupDhwTan[nBui](
    u1(each final unit="K", each displayUnit="degC"),
    u2(each final unit="K", each displayUnit="degC"),
    y(each final unit="K"))
    "Control error for supply water temperature for domestic hot water tank"
    annotation (Placement(transformation(extent={{580,180},{600,200}})));
initial equation
  tStart = time;
equation

  connect(TDhwSup.y, reqTDhwSup.u)
    annotation (Line(points={{601,354},{619,354}}, color={0,0,127}));
  connect(THeaPumEvaLvg.y,reqTHeaPumEvaLvg. u_max) annotation (Line(points={{601,70},
          {610,70},{610,56},{619,56}},     color={0,0,127}));
  connect(TMaxHeaPumConLvg.y,reqTHeaPumConLvg. u_max) annotation (Line(points={{601,-10},
          {612,-10},{612,-24},{619,-24}},          color={0,0,127}));
  connect(THeaPumCon.y,reqTHeaPumConLvg. u_min) annotation (Line(points={{521,-28},
          {619,-28}},                     color={0,0,127}));
  connect(TWatSer.y, reqTWatSer.u) annotation (Line(points={{601,-450},{610,-450},
          {610,-446},{619,-446}}, color={0,0,127}));
  connect(TDisWatSup.T,reqTPlaMix. u) annotation (Line(points={{-91,170},{-224,170},
          {-224,-168},{-160,-168},{-160,-566},{619,-566}},
                                   color={0,0,127}));
  connect(dhwTanCha.y,reqTDhwTan. active) annotation (Line(points={{441,166},{612,
          166},{612,186},{618,186}}, color={255,0,255}));
  connect(TMinHeaPumEva.y,reqTHeaPumEvaLvg. u_min) annotation (Line(points={{601,50},
          {610,50},{610,52},{619,52}},     color={0,0,127}));
  connect(heaPumOn.y,reqHeaPumOn. u)
    annotation (Line(points={{561,470},{618,470}}, color={255,0,255}));
  connect(heaPumOff.y,reqHeaPumOff. u)
    annotation (Line(points={{601,430},{618,430}}, color={255,0,255}));
  connect(heaPumOn.y,heaPumOff. u) annotation (Line(points={{561,470},{570,470},
          {570,430},{578,430}}, color={255,0,255}));
  connect(RMaxDisLoo.y, reqRDis.u_max) annotation (Line(points={{601,-490},{610,
          -490},{610,-504},{619,-504}}, color={0,0,127}));
  connect(RDisLoo.y, reqRDis.u_min) annotation (Line(points={{601,-530},{610,-530},
          {610,-508},{619,-508}}, color={0,0,127}));
  connect(dTHea.y, reqTSpaHeaSup.u) annotation (Line(points={{601,320},{610,320},
          {610,314},{619,314}}, color={0,0,127}));
  connect(dTCoo.y, reqTCoo.u) annotation (Line(points={{601,260},{610,260},{610,
          254},{619,254}}, color={0,0,127}));
  connect(TCooSup.y, dTCoo.u1)
    annotation (Line(points={{561,266},{578,266}}, color={0,0,127}));
  connect(TCooSupSet.y, dTCoo.u2)
    annotation (Line(points={{561,254},{578,254}}, color={0,0,127}));
  connect(THeaSup.y, dTHea.u1)
    annotation (Line(points={{561,326},{578,326}}, color={0,0,127}));
  connect(THeaSupSet.y, dTHea.u2)
    annotation (Line(points={{561,314},{578,314}}, color={0,0,127}));
  connect(TRooHeaSet.y, dTRooHea.u1) annotation (Line(points={{441,-120},{448,-120},
          {448,-134},{458,-134}}, color={0,0,127}));
  connect(TRooHea.y, dTRooHea.u2) annotation (Line(points={{441,-160},{448,-160},
          {448,-146},{458,-146}}, color={0,0,127}));
  connect(dTRooHea.y, dTRooHeaAvg60min.u) annotation (Line(points={{481,-140},{
          560,-140},{560,-130},{578,-130}}, color={0,0,127}));
  connect(THexSecLvg.y,reqTHexEtsSecLvg. u) annotation (Line(points={{601,150},{
          612,150},{612,154},{619,154}}, color={0,0,127}));
  connect(THexPriLvg.y,reqTHexEtsPriLvg. u) annotation (Line(points={{601,110},{
          610,110},{610,114},{619,114}},
                                  color={0,0,127}));
  connect(dTRooHeaAvg60min.y, reqTRooHea.u_min) annotation (Line(points={{602,-130},
          {610,-130},{610,-128},{619,-128}}, color={0,0,127}));
  connect(dTMaxRooHea60min.y, reqTRooHea.u_max) annotation (Line(points={{601,-100},
          {610,-100},{610,-124},{619,-124}}, color={0,0,127}));
  connect(dTMaxRooHeaYea.y, reqTRooHeaAvg.u_max) annotation (Line(points={{601,
          -170},{610,-170},{610,-184},{619,-184}}, color={0,0,127}));
  connect(simEnd.y, reqTRooHeaAvg.active) annotation (Line(points={{441,-190},{
          460,-190},{460,-168},{576,-168},{576,-194},{618,-194}}, color={255,0,
          255}));
  connect(TRooCooSet.y,TRooCooDif. u1) annotation (Line(points={{441,-300},{450,
          -300},{450,-314},{458,-314}}, color={0,0,127}));
  connect(TRooCoo.y,TRooCooDif. u2) annotation (Line(points={{441,-340},{450,-340},
          {450,-326},{458,-326}}, color={0,0,127}));
  connect(TRooCooDif.y, dTRooCooAvg60min.u) annotation (Line(points={{481,-320},
          {560,-320},{560,-310},{578,-310}}, color={0,0,127}));
  connect(dTRooCooAvg60min.y, reqTRooCoo.u_min) annotation (Line(points={{602,-310},
          {610,-310},{610,-308},{619,-308}}, color={0,0,127}));
  connect(dTMaxRooCoo60min.y, reqTRooCoo.u_max) annotation (Line(points={{601,-280},
          {610,-280},{610,-304},{619,-304}}, color={0,0,127}));
  connect(dTMaxRooCooYea.y, reqTRooCooAvg.u_max) annotation (Line(points={{601,
          -340},{610,-340},{610,-356},{619,-356}}, color={0,0,127}));
  connect(simEnd.y, reqTRooCooAvg.active) annotation (Line(points={{441,-190},{
          460,-190},{460,-248},{520,-248},{520,-292},{570,-292},{570,-366},{618,
          -366}}, color={255,0,255}));
  connect(yVal.y,reqStaVal. u)
    annotation (Line(points={{601,394},{619,394}}, color={0,0,127}));
  connect(gaiMilCos.y, reqEneCos.u_max) annotation (Line(points={{602,560},{610,
          560},{610,556},{619,556}},   color={0,0,127}));
  connect(gaiMilImp.y, reqEneImp.u_max) annotation (Line(points={{602,520},{610,
          520},{610,516},{619,516}},   color={0,0,127}));
  connect(ETot.y, reqEneImp.u_min) annotation (Line(points={{382,100},{400,100},
          {400,500},{610,500},{610,512},{619,512}},   color={0,0,127}));
  connect(totEleCos.y, reqEneCos.u_min) annotation (Line(points={{361,-130},{
          390,-130},{390,540},{610,540},{610,552},{619,552}},          color={0,
          0,127}));
  connect(milCos.y, gaiMilCos.u)
    annotation (Line(points={{561,560},{578,560}}, color={0,0,127}));
  connect(milImp.y, gaiMilImp.u)
    annotation (Line(points={{561,520},{578,520}}, color={0,0,127}));
  connect(QRooCoo.y, thrRooCoo.u)
    annotation (Line(points={{441,-280},{458,-280}}, color={0,0,127}));
  connect(thrRooCoo.y, reqTRooCoo.active) annotation (Line(points={{482,-280},{486,
          -280},{486,-324},{610,-324},{610,-314},{618,-314}}, color={255,0,255}));
  connect(QRooHea.y, thrRooHea.u)
    annotation (Line(points={{441,-100},{458,-100}}, color={0,0,127}));
  connect(swiRooCoo.y, intdTRooCoo.u)
    annotation (Line(points={{521,-370},{538,-370}}, color={0,0,127}));
  connect(QRooCooOn.y,intQRooCooOn. u)
    annotation (Line(points={{522,-410},{538,-410}}, color={0,0,127}));
  connect(dTRooCooYea.y, reqTRooCooAvg.u_min) annotation (Line(points={{601,
          -390},{610,-390},{610,-360},{619,-360}},
                                             color={0,0,127}));
  connect(intQRooCooOn.y, dTRooCooYea.u2) annotation (Line(points={{561,-410},{
          570,-410},{570,-396},{578,-396}}, color={0,0,127}));
  connect(intdTRooCoo.y, dTRooCooYea.u1) annotation (Line(points={{561,-370},{
          570,-370},{570,-384},{578,-384}}, color={0,0,127}));
  connect(thrRooCoo.y, swiRooCoo.u2) annotation (Line(points={{482,-280},{486,-280},
          {486,-370},{498,-370}}, color={255,0,255}));
  connect(TRooCooDif.y, swiRooCoo.u1) annotation (Line(points={{481,-320},{492,
          -320},{492,-362},{498,-362}}, color={0,0,127}));
  connect(zero.y, swiRooCoo.u3) annotation (Line(points={{441,-250},{446,-250},
          {446,-378},{498,-378}}, color={0,0,127}));
  connect(thrRooCoo.y, QRooCooOn.u) annotation (Line(points={{482,-280},{486,-280},
          {486,-410},{498,-410}}, color={255,0,255}));
  connect(thrRooHea.y, swiRooHea.u2) annotation (Line(points={{482,-100},{486,-100},
          {486,-190},{498,-190}}, color={255,0,255}));
  connect(thrRooHea.y, QRooHeaOn.u) annotation (Line(points={{482,-100},{486,-100},
          {486,-230},{498,-230}}, color={255,0,255}));
  connect(dTRooHea.y, swiRooHea.u1) annotation (Line(points={{481,-140},{492,-140},
          {492,-182},{498,-182}}, color={0,0,127}));
  connect(zero.y, swiRooHea.u3) annotation (Line(points={{441,-250},{446,-250},
          {446,-198},{498,-198}}, color={0,0,127}));
  connect(swiRooHea.y, intdTRooHea.u)
    annotation (Line(points={{521,-190},{538,-190}}, color={0,0,127}));
  connect(QRooHeaOn.y,intQRooHeaOn. u)
    annotation (Line(points={{522,-230},{538,-230}}, color={0,0,127}));
  connect(intdTRooHea.y, dTRooHeaAvgYea.u1) annotation (Line(points={{561,-190},
          {570,-190},{570,-204},{578,-204}}, color={0,0,127}));
  connect(intQRooHeaOn.y, dTRooHeaAvgYea.u2) annotation (Line(points={{561,-230},
          {570,-230},{570,-216},{578,-216}}, color={0,0,127}));
  connect(dTRooHeaAvgYea.y, reqTRooHeaAvg.u_min) annotation (Line(points={{601,
          -210},{610,-210},{610,-188},{619,-188}}, color={0,0,127}));
  connect(thrRooHea.y, reqTRooHea.active) annotation (Line(points={{482,-100},{486,
          -100},{486,-146},{610,-146},{610,-134},{618,-134}}, color={255,0,255}));
  connect(heaPumCooOn.y, reqTCoo.active) annotation (Line(points={{561,230},{
          610,230},{610,246},{618,246}}, color={255,0,255}));
  connect(reqTHeaPumConLvg.active, valIsoConCom.y) annotation (Line(points={{618,
          -34},{610,-34},{610,-40},{601,-40}}, color={255,0,255}));
  connect(valIsoEvaCom.y, reqTHeaPumEvaLvg.active) annotation (Line(points={{601,
          20},{610,20},{610,46},{618,46}}, color={255,0,255}));
  connect(TTanHeaSup.y, conErrTSupDhwTan.u2)
    annotation (Line(points={{561,184},{578,184}}, color={0,0,127}));
  connect(conErrTSupDhwTan.y, reqTDhwTan.u) annotation (Line(points={{602,190},{
          610,190},{610,194},{619,194}}, color={0,0,127}));
  connect(TTanDhwSet.y, conErrTSupDhwTan.u1) annotation (Line(points={{561,200},
          {570,200},{570,196},{578,196}}, color={0,0,127}));
  connect(dhwTanCha.y, dhWChaOff.u) annotation (Line(points={{441,166},{450,166},
          {450,270},{460,270}}, color={255,0,255}));
  connect(verTHeaSup.y, reqTSpaHeaSup.active) annotation (Line(points={{562,290},
          {608,290},{608,306},{618,306}}, color={255,0,255}));
  for i in 1:nBui loop
  connect(staVer[i].y, verTHeaSup[i].u[1]) annotation (Line(points={{501,560},{
            514,560},{514,287.667},{538,287.667}},
                                color={255,0,255}));
    connect(thrRooHea[i].y, verTHeaSup[i].u[2]) annotation (Line(points={{482,-100},
            {491.5,-100},{491.5,290},{538,290}},color={255,0,255}));
  connect(dhWChaOff[i].y, verTHeaSup[i].u[3]) annotation (Line(points={{483,270},
            {509.5,270},{509.5,292.333},{538,292.333}},
                                  color={255,0,255}));
  end for;
  annotation (Diagram(coordinateSystem(extent={{-400,-580},{680,580}})), Icon(
        coordinateSystem(extent={{-100,-100},{100,100}})),
    experiment(
      StopTime=86400,
      Interval=3600,
      Tolerance=1e-07,
      __Dymola_Algorithm="Cvode"));
end DetailedPlantFiveHubsWithRequirementsVerification;
