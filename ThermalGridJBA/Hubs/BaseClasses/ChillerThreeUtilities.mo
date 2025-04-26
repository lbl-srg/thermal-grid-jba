within ThermalGridJBA.Hubs.BaseClasses;
model ChillerThreeUtilities
  "An ETS model with an HRC producing CHW, HHW, and DHW"
  extends ThermalGridJBA.Hubs.BaseClasses.PartialParallel   (
    final have_eleCoo=true,
    final have_fan=false,
    redeclare Buildings.DHC.ETS.Combined.Controls.Supervisory conSup(
        final controllerType=controllerType,
        final kHot=kHot,
        final kCol=kCol,
        final TiHot=TiHot,
        final TiCol=TiCol,
        final THeaWatSupSetMin=THeaWatSupSetMin,
        final TChiWatSupSetMin=TChiWatSupSetMin,
        final TChiWatSupSetMax=TChiWatSupSetMax),
    nSysHea=1,
    nSouAmb=1,
    VTanHeaWat=datChi.PLRMin*datChi.mCon_flow_nominal*5*60/1000,
    VTanChiWat=datChi.PLRMin*datChi.mEva_flow_nominal*5*60/1000,
    colChiWat(
      mCon_flow_nominal={colAmbWat.mDis_flow_nominal,datChi.mEva_flow_nominal}),
    colHeaWat(
      mCon_flow_nominal={colAmbWat.mDis_flow_nominal,datChi.mCon_flow_nominal}),
    colAmbWat(
      mCon_flow_nominal={hex.m2_flow_nominal}),
    nPorts_bChiWat=1,
    nPorts_aChiWat=1,
    nPorts_aHeaWat=1,
    nPorts_bHeaWat=1,
    totPHea(nin=1),
    totPCoo(nin=1),
    totPPum(nin=if have_hotWat then 3 else 2),
    tanHeaWat(final T_start=TCon_start),
    tanChiWat(final T_start=TEva_start));

  parameter ThermalGridJBA.Data.Chiller datChi
    "Chiller performance data" annotation (
    Dialog(group="Chiller"),
    choicesAllMatching=true,
    Placement(transformation(extent={{20,222},{40,242}})));
  parameter
    Buildings.DHC.Loads.HotWater.Data.GenericDomesticHotWaterWithHeatExchanger datDhw
    "Performance data of the domestic hot water component"
    annotation (Placement(transformation(extent={{-40,220},{-20,240}})));
  parameter Modelica.Units.SI.PressureDifference dpCon_nominal(displayUnit="Pa")
    "Nominal pressure drop accross condenser"
    annotation (Dialog(group="Chiller"));
  parameter Modelica.Units.SI.PressureDifference dpEva_nominal(displayUnit="Pa")
    "Nominal pressure drop accross evaporator"
    annotation (Dialog(group="Chiller"));
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController controllerType=
    Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Type of controller"
    annotation (Dialog(group="Supervisory controller"));
  parameter Real kHot(
    min=0)=0.05
    "Gain of controller on hot side"
    annotation (Dialog(group="Supervisory controller"));
  parameter Real kCol(
    min=0)=0.1
    "Gain of controller on cold side"
    annotation (Dialog(group="Supervisory controller"));
  parameter Modelica.Units.SI.Time TiHot(min=Buildings.Controls.OBC.CDL.Constants.small)
     = 300 "Time constant of integrator block on hot side" annotation (Dialog(
        group="Supervisory controller", enable=controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
           or controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Modelica.Units.SI.Time TiCol(min=Buildings.Controls.OBC.CDL.Constants.small)
     = 120 "Time constant of integrator block on cold side" annotation (Dialog(
        group="Supervisory controller", enable=controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
           or controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Modelica.Units.SI.Temperature THeaWatSupSetMin(displayUnit="degC")
     = datChi.TConEntMin + 5
    "Minimum value of heating water supply temperature set point"
    annotation (Dialog(group="Supervisory controller"));
  parameter Modelica.Units.SI.Temperature TChiWatSupSetMin(displayUnit="degC")
     = datChi.TEvaLvgMin
    "Minimum value of chilled water supply temperature set point"
    annotation (Dialog(group="Supervisory controller"));
  parameter Modelica.Units.SI.Temperature TChiWatSupSetMax(displayUnit="degC")
     = datChi.TEvaLvgMax
    "Minimum value of chilled water supply temperature set point"
    annotation (Dialog(group="Supervisory controller"));
  parameter MediumBui.Temperature TCon_start = MediumBui.T_default
    "Temperature start value on the condenser side"
    annotation(Dialog(tab = "Initialization"));
  parameter MediumBui.Temperature TEva_start = MediumBui.T_default
    "Temperature start value on the evaporator side"
    annotation(Dialog(tab = "Initialization"));


  replaceable
    ThermalGridJBA.Hubs.BaseClasses.Chiller
    chi(
    redeclare final package Medium = MediumBui,
    final dpCon_nominal=dpCon_nominal,
    final dpEva_nominal=dpEva_nominal,
    final dat=datChi) "Chiller" annotation (Dialog(group="Chiller"), Placement(
        transformation(extent={{-10,-16},{10,4}})));
  Buildings.DHC.Networks.BaseClasses.DifferenceEnthalpyFlowRate dHFloHeaWat(
    redeclare final package Medium1 = MediumBui,
    final m_flow_nominal=colHeaWat.mDis_flow_nominal)
    "Variation of enthalpy flow rate"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={-274,130})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput dHHeaWat_flow(final unit="W")
    "Heating water distributed energy flow rate"
    annotation (Placement(transformation(extent={{300,140},{340,180}}),
      iconTransformation(extent={{-40,-40},{40,40}},
        rotation=-90,
        origin={240,-340})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput dHChiWat_flow(final unit="W")
    "Chilled water distributed energy flow rate"
    annotation (Placement(transformation(extent={{300,100},{340,140}}),
      iconTransformation(extent={{-40,-40},{40,40}},
        rotation=-90,
        origin={280,-340})));
  Buildings.DHC.Networks.BaseClasses.DifferenceEnthalpyFlowRate dHFloChiWat(
    redeclare final package Medium1 = MediumBui,
    final m_flow_nominal=colChiWat.mDis_flow_nominal)
    "Variation of enthalpy flow rate"
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=90,
        origin={274,130})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zerPHea(
    final k=0)
    "Zero power"
    annotation (Placement(transformation(extent={{220,50},{240,70}})));

  ThermalGridJBA.Hubs.BaseClasses.DHWConsumption dhw(
    redeclare final package Medium = MediumBui,
    final dat = datDhw,
    final QHotWat_flow_nominal=datDhw.QHex_flow_nominal,
    dT_nominal=6,
    final T_start=TCon_start)     if have_hotWat
    annotation (Placement(transformation(extent={{-200,220},{-180,240}})));
  Buildings.Fluid.Actuators.Valves.ThreeWayLinear valMixHea(
    redeclare package Medium = MediumBui,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=datChi.mCon_flow_nominal,
    dpValve_nominal=dpCon_nominal*0.05,
    dpFixed_nominal=dpCon_nominal*0.05*{1,1},
    linearized={true,true}) if have_hotWat
    "Three way valve selecting condenser flow from HHW or DHW return"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={-80,76})));
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare final package Medium = MediumBui,
    final dp_nominal={0,0,0},
    final energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    final tau=1,
    final m_flow_nominal=datChi.mCon_flow_nominal*{1,-1,-1}) if have_hotWat
    "Junction"                            annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-116,60})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THotWatSupSet(final unit="K",
      displayUnit="degC") if have_hotWat
    "Domestic hot water temperature set point for supply to fixtures"
    annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-320,-100}),
        iconTransformation(
        extent={{-380,-140},{-300,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TColWat(final unit="K",
      displayUnit="degC") if have_hotWat
    "Cold water temperature" annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-320,-140}),iconTransformation(
        extent={{-40,-40},{40,40}},
        rotation=0,
        origin={-340,-140})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput QReqHotWat_flow(final unit="W")
    if have_hotWat          "Service hot water load"
    annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-320,-180}),iconTransformation(
        extent={{-40,-40},{40,40}},
        rotation=0,
        origin={-340,-180})));

  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TConLvgHotSet(k=50 + 273.15)
                if have_hotWat
    "Condenser leaving temperature set point for DHW"
    annotation (Placement(transformation(extent={{-220,270},{-200,290}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput dHHotWat_flow(final unit="W")
    if have_hotWat
    "Domestic hot water distributed energy flow rate" annotation (Placement(
        transformation(extent={{298,280},{338,320}}), iconTransformation(
        extent={{-40,-40},{40,40}},
        rotation=-90,
        origin={200,-340})));
  Buildings.DHC.Plants.Cooling.BaseClasses.ParallelPipes parPip(
    redeclare final package Medium = MediumBui,
    m_flow_nominal=datChi.mCon_flow_nominal,
    dp_nominal=0) if not have_hotWat "Parallel pipes for routing purposes"
                                     annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-150,60})));
  Modelica.Blocks.Routing.RealPassThrough reaPasDhwPum if have_hotWat
    "Routing block"
    annotation (Placement(transformation(extent={{-80,230},{-60,250}})));
  ThermalGridJBA.Hubs.Controls.TwoTankCoordination twoTanCoo(final have_hotWat=
        have_hotWat)
    "Controller to coordinate heat rejection vs use in space or DHW tank"
    annotation (Placement(transformation(extent={{-140,170},{-120,190}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal conDivVal(realTrue=1,
      realFalse=0)
    "Control for diversion valve to avoid that tank is flushed when changing to district heat exchanger"
    annotation (Placement(transformation(extent={{100,80},{120,100}})));
  Buildings.Fluid.Actuators.Valves.ThreeWayLinear valDivCon(
    redeclare package Medium = MediumBui,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=datChi.mCon_flow_nominal,
    dpValve_nominal=dpCon_nominal*0.05,
    dpFixed_nominal=dpCon_nominal*0.05*{1,1},
    linearized={true,true})
    "Diversion valve used to reject heat and not flow through the whole tank"
    annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=90,
        origin={-144,90})));
  Buildings.Fluid.Actuators.Valves.ThreeWayLinear valDivEva(
    redeclare package Medium = MediumBui,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=datChi.mEva_flow_nominal,
    dpValve_nominal=dpEva_nominal*0.05,
    dpFixed_nominal=dpEva_nominal*0.05*{1,1},
    linearized={true,true})
    "Diversion valve used to reject cold and not flow through the whole tank"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={146,90})));
equation
  connect(port_aSerAmb, hex.port_a1) annotation (Line(points={{-300,-200},{-280,
          -200},{-280,-260},{-10,-260}}, color={0,127,255}));
  connect(hex.port_b1, port_bSerAmb) annotation (Line(points={{10,-260},{280,-260},
          {280,-200},{300,-200}}, color={0,127,255}));
  connect(dHFloChiWat.port_b1, ports_bChiWat[1]) annotation (Line(points={{280,140},
          {280,200},{300,200}}, color={0,127,255}));
  connect(dHFloChiWat.port_a2, ports_aChiWat[1]) annotation (Line(points={{268,140},
          {268,200},{-300,200}}, color={0,127,255}));
  connect(dHFloHeaWat.port_a2, ports_aHeaWat[1]) annotation (Line(points={{-280,
          140},{-280,260},{-300,260}}, color={0,127,255}));
  connect(dHFloHeaWat.port_b1, ports_bHeaWat[1]) annotation (Line(points={{-268,
          140},{-268,260},{300,260}}, color={0,127,255}));
  connect(dHFloHeaWat.dH_flow, dHHeaWat_flow) annotation (Line(points={{-271,142},
          {-271,160},{320,160}}, color={0,0,127}));
  connect(dHFloChiWat.dH_flow, dHChiWat_flow) annotation (Line(points={{277,142},
          {277,148},{292,148},{292,120},{320,120}}, color={0,0,127}));
  connect(totPHea.u[1], zerPHea.y)
    annotation (Line(points={{258,60},{242,60}}, color={0,0,127}));
  connect(chi.port_aChiWat, colChiWat.ports_bCon[2]) annotation (Line(points={{10,
          -12},{132,-12},{132,-24}}, color={0,127,255}));
  connect(chi.port_bChiWat, colChiWat.ports_aCon[2]) annotation (Line(points={{-10,
          -12},{-20,-12},{-20,-24},{108,-24}}, color={0,127,255}));
  connect(chi.port_aHeaWat, colHeaWat.ports_bCon[2])
    annotation (Line(points={{-10,0},{-132,0},{-132,-24}}, color={0,127,255}));
  connect(colHeaWat.ports_aCon[2], chi.port_bHeaWat) annotation (Line(points={{-108,
          -24},{-108,12},{20,12},{20,0},{10,0}}, color={0,127,255}));
  connect(chi.PChi, totPCoo.u[1]) annotation (Line(points={{12,-4},{30,-4},{30,20},
          {258,20}}, color={0,0,127}));
  connect(chi.PPum, totPPum.u[2]) annotation (Line(points={{12,-8},{30,-8},{30,-60},
          {258,-60}}, color={0,0,127}));
  connect(conSup.TChiWatSupSet, chi.TChiWatSupSet) annotation (Line(points={{-238,
          17},{-26,17},{-26,-8},{-12,-8}}, color={0,0,127}));
  connect(conSup.yHea, chi.uHea) annotation (Line(points={{-238,31},{-20,31},{-20,
          -2},{-12,-2}}, color={255,0,255}));
  connect(conSup.yCoo, chi.uCoo) annotation (Line(points={{-238,29},{-22,29},{-22,
          -4},{-12,-4}}, color={255,0,255}));
  connect(valIsoCon.y_actual,conSup.yValIsoCon_actual)
    annotation (Line(points={{-55,-113},{-40,-113},{-40,-60},{-266,-60},{-266,15},
          {-262,15}},                                                                        color={0,0,127}));
  connect(valIsoEva.y_actual,conSup.yValIsoEva_actual)
    annotation (Line(points={{55,-113},{40,-113},{40,-64},{-270,-64},{-270,13},{
          -262,13}},                                                                      color={0,0,127}));
  connect(dhw.THotWatSupSet, THotWatSupSet) annotation (Line(points={{-202,238},
          {-228,238},{-228,68},{-286,68},{-286,-100},{-320,-100}}, color={0,0,127}));
  connect(TColWat, dhw.TColWat) annotation (Line(points={{-320,-140},{-282,-140},
          {-282,64},{-224,64},{-224,234},{-202,234}}, color={0,0,127}));
  connect(QReqHotWat_flow, dhw.QReqHotWat_flow) annotation (Line(points={{-320,
          -180},{-278,-180},{-278,60},{-220,60},{-220,226},{-202,226}},
                                                                  color={0,0,127}));
  connect(dHFloHeaWat.port_a1, tanHeaWat.port_bTop) annotation (Line(points={{-268,
          120},{-268,116},{-200,116}}, color={0,127,255}));
  connect(tanHeaWat.port_aBot, dHFloHeaWat.port_b2) annotation (Line(points={{-200,
          104},{-280,104},{-280,120}},
                                     color={0,127,255}));
  connect(reaPasDhwPum.y, totPPum.u[3]) annotation (Line(points={{-59,240},{-48,
          240},{-48,252},{210,252},{210,-60},{258,-60}}, color={0,0,127}));
  connect(THeaWatSupSet, tanHeaWat.TTanSet) annotation (Line(points={{-320,-20},
          {-208,-20},{-208,120},{-201,120},{-201,119}}, color={0,0,127}));
  connect(dhw.charge, twoTanCoo.uHot) annotation (Line(points={{-178,222},{-152,
          222},{-152,190},{-142,190}}, color={255,0,255}));
  connect(TConLvgHotSet.y, twoTanCoo.TSetHot) annotation (Line(points={{-198,
          280},{-160,280},{-160,182},{-142,182}}, color={0,0,127}));
  connect(dhw.TTanTop, twoTanCoo.TTopHot) annotation (Line(points={{-178,238},{
          -156,238},{-156,186},{-142,186}}, color={0,0,127}));
  connect(dhw.PEle, reaPasDhwPum.u) annotation (Line(points={{-179,226},{-152,
          226},{-152,240},{-82,240}}, color={0,0,127}));
  connect(tanHeaWat.TTop, twoTanCoo.TTopHea) annotation (Line(points={{-179,119},
          {-156,119},{-156,174},{-142,174}}, color={0,0,127}));
  connect(tanHeaWat.charge, twoTanCoo.uHea) annotation (Line(points={{-178,107},
          {-160,107},{-160,178},{-142,178}}, color={255,0,255}));
  connect(THeaWatSupSet, twoTanCoo.TSetHea) annotation (Line(points={{-320,-20},
          {-208,-20},{-208,170},{-142,170}}, color={0,0,127}));
  connect(twoTanCoo.yMix, valMixHea.y) annotation (Line(points={{-118,188},{-96,
          188},{-96,60},{-80,60},{-80,64}}, color={0,0,127}));
  connect(twoTanCoo.TTop, conSup.THeaWatTop) annotation (Line(points={{-119,176},
          {-52,176},{-52,44},{-268,44},{-268,24},{-262,24},{-262,25}}, color={0,
          0,127}));
  connect(conSup.THeaWatSupPreSet, twoTanCoo.TSet) annotation (Line(points={{-262,
          27},{-266,27},{-266,40},{-48,40},{-48,172},{-119,172}}, color={0,0,
          127}));
  connect(twoTanCoo.y, conSup.uHea) annotation (Line(points={{-118,180},{-44,
          180},{-44,38},{-262,38},{-262,31}}, color={255,0,255}));
  connect(dhw.dHFlo, dHHotWat_flow) annotation (Line(points={{-179,234},{-170,
          234},{-170,300},{318,300}}, color={0,0,127}));
  connect(dhw.port_b, valMixHea.port_3) annotation (Line(points={{-180,230},{-130,
          230},{-130,220},{-80,220},{-80,86}},
                               color={0,127,255}));
  connect(dhw.port_a, jun.port_3) annotation (Line(points={{-200,230},{-208,230},
          {-208,176},{-200,176},{-200,164},{-100,164},{-100,60},{-106,60}},
                                             color={0,127,255}));
  connect(tanChiWat.charge, conDivVal.u) annotation (Line(points={{178,107},{
          172,107},{172,126},{90,126},{90,90},{98,90}}, color={255,0,255}));
  connect(valMixHea.port_2, colHeaWat.port_aDisSup) annotation (Line(points={{-70,76},
          {-60,76},{-60,24},{-144,24},{-144,-34},{-140,-34}},           color={
          0,127,255}));
  connect(jun.port_1, colHeaWat.port_bDisRet) annotation (Line(points={{-116,50},
          {-116,26},{-156,26},{-156,-40},{-140,-40}},         color={0,127,255}));
  connect(parPip.port_b2, colHeaWat.port_aDisSup) annotation (Line(points={{
          -144,50},{-144,-34},{-140,-34}}, color={0,127,255}));
  connect(parPip.port_a1, colHeaWat.port_bDisRet) annotation (Line(points={{
          -156,50},{-156,-40},{-140,-40}}, color={0,127,255}));
  connect(twoTanCoo.yDiv, valDivCon.y) annotation (Line(points={{-118,184},{-108,
          184},{-108,90},{-132,90}}, color={0,0,127}));
  connect(parPip.port_a2, valDivCon.port_2)
    annotation (Line(points={{-144,70},{-144,80}}, color={0,127,255}));
  connect(valDivCon.port_1, tanHeaWat.port_bBot) annotation (Line(points={{-144,
          100},{-144,104},{-180,104}}, color={0,127,255}));
  connect(valDivCon.port_3, tanHeaWat.port_med) annotation (Line(points={{-154,
          90},{-162,90},{-162,110},{-180,110}}, color={0,127,255}));
  connect(conDivVal.y, valDivEva.y)
    annotation (Line(points={{122,90},{134,90}}, color={0,0,127}));
  connect(tanChiWat.port_bTop, dHFloChiWat.port_b2) annotation (Line(points={{
          200,116},{268,116},{268,120}}, color={0,127,255}));
  connect(tanChiWat.port_aBot, dHFloChiWat.port_a1) annotation (Line(points={{
          200,104},{280,104},{280,120}}, color={0,127,255}));
  connect(colChiWat.port_bDisRet, tanChiWat.port_bBot) annotation (Line(points=
          {{140,-40},{168,-40},{168,104},{180,104}}, color={0,127,255}));
  connect(colChiWat.port_aDisSup, valDivEva.port_2) annotation (Line(points={{
          140,-34},{146,-34},{146,80}}, color={0,127,255}));
  connect(valDivEva.port_1, tanChiWat.port_aTop) annotation (Line(points={{146,
          100},{146,116},{180,116}}, color={0,127,255}));
  connect(valDivEva.port_3, tanChiWat.port_med) annotation (Line(points={{156,
          90},{160,90},{160,110},{180,110}}, color={0,127,255}));
  connect(jun.port_2, tanHeaWat.port_aTop) annotation (Line(points={{-116,70},{-116,
          116},{-180,116}}, color={0,127,255}));
  connect(parPip.port_b1, tanHeaWat.port_aTop) annotation (Line(points={{-156,70},
          {-156,116},{-180,116}}, color={0,127,255}));
  connect(valDivCon.port_2, valMixHea.port_1) annotation (Line(points={{-144,80},
          {-144,76},{-90,76}}, color={0,127,255}));
  annotation (Icon(graphics={
        Rectangle(
          extent={{12,-40},{40,-12}},
          lineColor={255,255,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{18,-44},{46,-16}},
          lineColor={255,255,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-70,30},{-68,20}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={175,175,175},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-1.5,5.5},{1.5,-5.5}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={175,175,175},
          fillPattern=FillPattern.Solid,
          origin={-13.5,20.5},
          rotation=90),
        Rectangle(
          extent={{-74,76},{66,-84}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-48,48},{-44,8}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,66},{54,48}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-46,-2},{-56,8},{-36,8},{-46,-2}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-46,-2},{-56,-14},{-36,-14},{-46,-2}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-48,-14},{-44,-54}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{34,48},{38,-54}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,-54},{54,-72}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{14,20},{58,-22}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{36,20},{18,-12},{54,-12},{36,20}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-48,48},{-44,8}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,66},{54,48}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-46,-2},{-56,8},{-36,8},{-46,-2}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-46,-2},{-56,-14},{-36,-14},{-46,-2}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-48,-14},{-44,-54}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{34,48},{38,-54}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,-54},{54,-72}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{14,20},{58,-22}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{36,20},{18,-12},{54,-12},{36,20}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(extent={{-262,140},{258,-142}}, lineColor={95,95,95})}),
Documentation(info="
<html>
<p>
Adapted from Buildings.DHC.ETS.Combined.ChillerBorefield with the following
modifications, with some at the parent level:
</p>
<ul>
<li>
Added a domestic hot water component and related hydraulic components
and controls blocks. The DHW consumption is computed within this model
instead of via external connectors.
</li>
<li>
Replaced the water tank components with a component that includes a charge
command Boolean signal. This is currently done only with the HHW side.
The same modification is planned for the CHW side.
</li>
<li>
The supervisory controller heating input signal <code>uHea</code> and
cooling input signal <code>uCoo</code> now come from the tank(s) instead of
coming externally. This change was made because the synthetic
hourly DHW load profile from calibrated simulation is always positive,
effectively keeping the heating enabled at all times.
</li>
</ul>
</html>"));
end ChillerThreeUtilities;
