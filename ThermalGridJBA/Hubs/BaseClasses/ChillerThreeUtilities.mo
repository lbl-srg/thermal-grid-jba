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
        final TChiWatSupSetMin=TChiWatSupSetMin),
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
    totPPum(nin=if have_hotWat then 3 else 2));

  replaceable parameter Buildings.Fluid.Chillers.Data.ElectricEIR.Generic datChi
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

  replaceable
    Buildings.DHC.ETS.Combined.Subsystems.Chiller
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
    final QHotWat_flow_nominal=QHotWat_flow_nominal,
    dT_nominal=22.22222222222222) if have_hotWat
    annotation (Placement(transformation(extent={{-200,220},{-180,240}})));
  Buildings.Fluid.Actuators.Valves.ThreeWayLinear valMixHea(
    redeclare package Medium = MediumBui,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    use_strokeTime=false,
    m_flow_nominal=datChi.mCon_flow_nominal,
    dpValve_nominal=dpCon_nominal*0.05,
    dpFixed_nominal=dpCon_nominal*0.05*{1,1},
    linearized={true,true}) if have_hotWat
    "Three way valve selecting condenser flow from HHW or DHW return"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={-90,110})));
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare final package Medium = MediumBui,
    final portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    final portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    final portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    final dp_nominal={0,0,0},
    final energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    final tau=1,
    final m_flow_nominal=datChi.mCon_flow_nominal*{1,-1,-1}) if have_hotWat
    "Junction"                            annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-130,130})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uDHW if have_hotWat
    "DHW production enable signal"
    annotation (Placement(transformation(extent={{-340,0},{-300,40}}),
                                     iconTransformation(extent={{-380,-20},{-300,
            60}})));
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

  Buildings.DHC.Networks.BaseClasses.DifferenceEnthalpyFlowRate dHFloHotWat(
      redeclare final package Medium1 = MediumBui, final m_flow_nominal=
        colHeaWat.mDis_flow_nominal) if have_hotWat
                                     "Variation of enthalpy flow rate"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={-90,214})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TConLvgHotSet(final k=50 +
        273.15) if have_hotWat
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
    dp_nominal=0) if not have_hotWat annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-170,60})));
  Modelica.Blocks.Routing.RealPassThrough reaPasDhwPum if have_hotWat
    annotation (Placement(transformation(extent={{-80,230},{-60,250}})));
  Buildings.Fluid.HydronicConfigurations.ActiveNetworks.Diversion valDivEva(
    redeclare final package Medium = MediumBui,
    m2_flow_nominal=datChi.mEva_flow_nominal,
    dp2_nominal=0.05*dpEva_nominal,
    typCha=Buildings.Fluid.HydronicConfigurations.Types.ValveCharacteristic.Linear,
    dpBal1_nominal=0.05*dpEva_nominal,
    dpBal3_nominal=0.05*dpEva_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState)
                                       "Diversion valve on evaporator side"
    annotation (Placement(transformation(extent={{150,40},{170,60}})));
  ThermalGridJBA.Hubs.Controls.Invert invEva "Invert signal: y = 1 - u"
    annotation (Placement(transformation(extent={{120,40},{140,60}})));
  Buildings.Fluid.HydronicConfigurations.ActiveNetworks.Diversion valDivCon(
    redeclare final package Medium = MediumBui,
    m2_flow_nominal=datChi.mCon_flow_nominal,
    dp2_nominal=0.05*dpCon_nominal,
    typCha=Buildings.Fluid.HydronicConfigurations.Types.ValveCharacteristic.Linear,
    dpBal1_nominal=0.05*dpCon_nominal,
    dpBal3_nominal=0.05*dpCon_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    val(from_dp=have_hotWat))      "Diversion valve on condenser side"
    annotation (Placement(transformation(extent={{-180,-30},{-160,-10}})));
  Controls.TwoTankCoordination twoTankCoordination(final have_hotWat=
        have_hotWat)
    annotation (Placement(transformation(extent={{-140,170},{-120,190}})));
equation
  connect(port_aSerAmb, hex.port_a1) annotation (Line(points={{-300,-200},{-280,
          -200},{-280,-260},{-10,-260}}, color={0,127,255}));
  connect(hex.port_b1, port_bSerAmb) annotation (Line(points={{10,-260},{280,-260},
          {280,-200},{300,-200}}, color={0,127,255}));
  connect(tanChiWat.port_aTop, dHFloChiWat.port_b2) annotation (Line(points={{200,
          112},{268,112},{268,120}}, color={0,127,255}));
  connect(dHFloChiWat.port_a1, tanChiWat.port_bBot) annotation (Line(points={{280,
          120},{280,100},{200,100}}, color={0,127,255}));
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
          {-276,238},{-276,312},{-352,312},{-352,-100},{-320,-100}},
                                                                   color={0,0,127}));
  connect(TColWat, dhw.TColWat) annotation (Line(points={{-320,-140},{-348,-140},
          {-348,152},{-276,152},{-276,204},{-216,204},{-216,234},{-202,234}},
                                                      color={0,0,127}));
  connect(QReqHotWat_flow, dhw.QReqHotWat_flow) annotation (Line(points={{-320,
          -180},{-356,-180},{-356,316},{-226,316},{-226,226},{-202,226}},
                                                                  color={0,0,127}));
  connect(dHFloHeaWat.port_a1, tanHeaWat.port_bTop) annotation (Line(points={{-268,
          120},{-268,110},{-200,110}}, color={0,127,255}));
  connect(tanHeaWat.port_aBot, dHFloHeaWat.port_b2) annotation (Line(points={{-200,
          98},{-280,98},{-280,120}}, color={0,127,255}));
  connect(dHFloHotWat.port_b1, dhw.port_b) annotation (Line(points={{-84,224},{
          -84,228},{-108,228},{-108,230},{-180,230}},   color={0,127,255}));
  connect(dhw.port_a, dHFloHotWat.port_a2) annotation (Line(points={{-200,230},
          {-220,230},{-220,252},{-92,252},{-92,236},{-96,236},{-96,224}},
                                             color={0,127,255}));
  connect(dHFloHotWat.dH_flow, dHHotWat_flow) annotation (Line(points={{-87,226},
          {-104,226},{-104,316},{280,316},{280,300},{318,300}},
                                                          color={0,0,127}));
  connect(tanHeaWat.port_bBot, parPip.port_a2) annotation (Line(points={{-180,98},
          {-164,98},{-164,70}}, color={0,127,255}));
  connect(parPip.port_b1, tanHeaWat.port_aTop) annotation (Line(points={{-176,70},
          {-176,110},{-180,110}},                     color={0,127,255}));
  connect(reaPasDhwPum.y, totPPum.u[3]) annotation (Line(points={{-59,240},{-48,
          240},{-48,252},{210,252},{210,-60},{258,-60}}, color={0,0,127}));
  connect(valDivEva.port_a2, tanChiWat.port_aBot) annotation (Line(points={{166,
          60},{166,100},{180,100}}, color={0,127,255}));
  connect(valDivEva.port_b2, tanChiWat.port_bTop) annotation (Line(points={{154,
          60},{154,112},{180,112}}, color={0,127,255}));
  connect(colChiWat.port_aDisSup, valDivEva.port_a1) annotation (Line(points={{
          140,-34},{154,-34},{154,40}}, color={0,127,255}));
  connect(valDivEva.port_b1, colChiWat.port_bDisRet) annotation (Line(points={{
          166,40},{166,-40},{140,-40}}, color={0,127,255}));
  connect(valDivEva.yVal, invEva.y)
    annotation (Line(points={{148,50},{142,50}}, color={0,0,127}));
  connect(conSup.yValIsoEva, invEva.u) annotation (Line(points={{-238,21},{-220,
          21},{-220,-80},{60,-80},{60,50},{118,50}}, color={0,0,127}));
  connect(colHeaWat.port_aDisSup, valDivCon.port_b1) annotation (Line(points={{
          -140,-34},{-164,-34},{-164,-30}}, color={0,127,255}));
  connect(parPip.port_b2, valDivCon.port_a2)
    annotation (Line(points={{-164,50},{-164,-10}}, color={0,127,255}));
  connect(valMixHea.port_2, valDivCon.port_a2) annotation (Line(points={{-80,110},
          {-70,110},{-70,34},{-164,34},{-164,-10}},
                                          color={0,127,255}));
  connect(valDivCon.port_b2, parPip.port_a1)
    annotation (Line(points={{-176,-10},{-176,50}}, color={0,127,255}));
  connect(colHeaWat.port_bDisRet, valDivCon.port_a1) annotation (Line(points={{
          -140,-40},{-176,-40},{-176,-30}}, color={0,127,255}));
  connect(jun.port_1, valDivCon.port_b2) annotation (Line(points={{-120,130},{
          -110,130},{-110,36},{-176,36},{-176,-10}},
                                          color={0,127,255}));
  connect(THeaWatSupSet, tanHeaWat.TTanTopSet) annotation (Line(points={{-320,
          -20},{-208,-20},{-208,114},{-201,114},{-201,113}}, color={0,0,127}));
  connect(dhw.charge, twoTankCoordination.uHot) annotation (Line(points={{-178,
          224},{-152,224},{-152,190},{-142,190}}, color={255,0,255}));
  connect(TConLvgHotSet.y, twoTankCoordination.TSetHot) annotation (Line(points
        ={{-198,280},{-160,280},{-160,182},{-142,182}}, color={0,0,127}));
  connect(dhw.TTanTop, twoTankCoordination.TTopHot) annotation (Line(points={{
          -178,240},{-156,240},{-156,186},{-142,186}}, color={0,0,127}));
  connect(dhw.PEle, reaPasDhwPum.u) annotation (Line(points={{-179,236},{-100,
          236},{-100,240},{-82,240}}, color={0,0,127}));
  connect(tanHeaWat.TTop, twoTankCoordination.TTopHea) annotation (Line(points=
          {{-179,113},{-156,113},{-156,174},{-142,174}}, color={0,0,127}));
  connect(tanHeaWat.charge, twoTankCoordination.uHea) annotation (Line(points={
          {-178,101},{-160,101},{-160,178},{-142,178}}, color={255,0,255}));
  connect(THeaWatSupSet, twoTankCoordination.TSetHea) annotation (Line(points={
          {-320,-20},{-208,-20},{-208,170},{-142,170}}, color={0,0,127}));
  connect(twoTankCoordination.yMix, valMixHea.y) annotation (Line(points={{-118,
          188},{-106,188},{-106,92},{-90,92},{-90,98}},
                                               color={0,0,127}));
  connect(twoTankCoordination.yDiv, valDivCon.yVal) annotation (Line(points={{
          -118,184},{-56,184},{-56,-6},{-184,-6},{-184,-20},{-182,-20}}, color=
          {0,0,127}));
  connect(twoTankCoordination.TTop, conSup.THeaWatTop) annotation (Line(points=
          {{-119,176},{-52,176},{-52,44},{-268,44},{-268,24},{-262,24},{-262,25}},
        color={0,0,127}));
  connect(conSup.THeaWatSupPreSet, twoTankCoordination.TSet) annotation (Line(
        points={{-262,27},{-266,27},{-266,40},{-48,40},{-48,172},{-119,172}},
        color={0,0,127}));
  connect(twoTankCoordination.y, conSup.uHea) annotation (Line(points={{-118,
          180},{-44,180},{-44,38},{-262,38},{-262,31}}, color={255,0,255}));
  connect(jun.port_2, tanHeaWat.port_aTop) annotation (Line(points={{-140,130},
          {-148,130},{-148,110},{-180,110}}, color={0,127,255}));
  connect(jun.port_3, dHFloHotWat.port_b2) annotation (Line(points={{-130,140},
          {-130,148},{-96,148},{-96,204}}, color={0,127,255}));
  connect(valMixHea.port_1, tanHeaWat.port_bBot) annotation (Line(points={{-100,
          110},{-140,110},{-140,98},{-180,98}}, color={0,127,255}));
  connect(valMixHea.port_3, dHFloHotWat.port_a1) annotation (Line(points={{-90,
          120},{-90,130},{-84,130},{-84,204}}, color={0,127,255}));
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
        Rectangle(extent={{-262,140},{258,-142}}, lineColor={95,95,95})}));
end ChillerThreeUtilities;
