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
    totPPum(nin=3),
    break tanHeaWat,
    break connect(THeaWatSupSet, conSup.THeaWatSupPreSet),
    break connect(uHea, conSup.uHea));

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
  parameter Integer nSegTanHea=9
    "Number of volume segments for heating hot water tank"
    annotation (Dialog(group="Buffer Tank"));
  parameter Integer iMidTanHea=3
    "Idex of the middle volume for heating hot water tank"
    annotation (Dialog(group="Buffer Tank"));

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
    dT_nominal=22.22222222222222)
    annotation (Placement(transformation(extent={{-220,220},{-200,240}})));
  Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear val(
    redeclare package Medium = MediumBui,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal=datChi.mCon_flow_nominal,
    dpValve_nominal=6000)
    "Three way valve selecting condenser flow from HHW or DHW return"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-110,80})));
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare final package Medium = MediumBui,
    final portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    final portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    final portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    final dp_nominal={0,0,0},
    final energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    final tau=1,
    final m_flow_nominal=datChi.mCon_flow_nominal*{-1,1,1})
                               "Junction" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={-150,100})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uSHW
    "SHW production enable signal"
    annotation (Placement(transformation(extent={{-340,0},{-300,40}}),
                                     iconTransformation(extent={{-380,-20},{-300,
            60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THotWatSupSet(final unit="K",
      displayUnit="degC")
    "Domestic hot water temperature set point for supply to fixtures"
    annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-320,-100}),
        iconTransformation(
        extent={{-380,-140},{-300,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TColWat(final unit="K",
      displayUnit="degC")
    "Cold water temperature" annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-320,-140}),iconTransformation(
        extent={{-40,-40},{40,40}},
        rotation=0,
        origin={-340,-140})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput QReqHotWat_flow(final unit="W")
                                   "Service hot water load"
    annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-320,-180}),iconTransformation(
        extent={{-40,-40},{40,40}},
        rotation=0,
        origin={-340,-180})));

  ThermalGridJBA.Hubs.BaseClasses.StratifiedTank tanHeaWat(
    redeclare final package Medium = MediumBui,
    final m_flow_nominal=colHeaWat.mDis_flow_nominal,
    final VTan=VTanHeaWat,
    final hTan=hTanHeaWat,
    final dIns=dInsTanHeaWat,
    final nSeg=nSegTanHea,
    final iMid=iMidTanHea) "Heating hot water tank"
    annotation (Placement(transformation(extent={{-200,94},{-180,114}})));
  ThermalGridJBA.Hubs.Controls.TankChargingTwoSpeed tanChaTwoSpe
    annotation (Placement(transformation(extent={{-160,170},{-140,190}})));
  ThermalGridJBA.Hubs.Controls.SelectTank selTan
    "Select the set point and top temperature signal from HHW or DHW"
    annotation (Placement(transformation(extent={{-80,170},{-60,190}})));
  Buildings.Controls.OBC.CDL.Logical.Or or2
    annotation (Placement(transformation(extent={{-280,70},{-260,90}})));
  Buildings.DHC.Networks.BaseClasses.DifferenceEnthalpyFlowRate dHFloHotWat(
      redeclare final package Medium1 = MediumBui, final m_flow_nominal=
        colHeaWat.mDis_flow_nominal) "Variation of enthalpy flow rate"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={-130,130})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TConLvgHotSet(final k=55 +
        273.15) "Condenser leaving temperature set point for DHW"
    annotation (Placement(transformation(extent={{-160,270},{-140,290}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput dHHotWat_flow(final unit="W")
    "Domestic hot water distributed energy flow rate" annotation (Placement(
        transformation(extent={{298,280},{338,320}}), iconTransformation(
        extent={{-40,-40},{40,40}},
        rotation=-90,
        origin={200,-340})));
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
  connect(dhw.THotWatSupSet, THotWatSupSet) annotation (Line(points={{-222,238},
          {-246,238},{-246,60},{-286,60},{-286,-100},{-320,-100}}, color={0,0,127}));
  connect(TColWat, dhw.TColWat) annotation (Line(points={{-320,-140},{-282,-140},
          {-282,56},{-242,56},{-242,234},{-222,234}}, color={0,0,127}));
  connect(QReqHotWat_flow, dhw.QReqHotWat_flow) annotation (Line(points={{-320,-180},
          {-278,-180},{-278,54},{-238,54},{-238,226},{-222,226}}, color={0,0,127}));
  connect(dhw.PEle, totPPum.u[3]) annotation (Line(points={{-199,236},{-110,236},
          {-110,254},{212,254},{212,-60},{258,-60}}, color={0,0,127}));
  connect(dHFloHeaWat.port_a1, tanHeaWat.port_bTop) annotation (Line(points={{-268,
          120},{-268,110},{-200,110}}, color={0,127,255}));
  connect(tanHeaWat.port_aBot, dHFloHeaWat.port_b2) annotation (Line(points={{-200,
          98},{-280,98},{-280,120}}, color={0,127,255}));
  connect(tanHeaWat.T, tanChaTwoSpe.TTan) annotation (Line(points={{-179,102},{-170,
          102},{-170,174},{-162,174}}, color={0,0,127}));
  connect(tanChaTwoSpe.y, selTan.u3) annotation (Line(points={{-138,180},{-104,180},
          {-104,186},{-82,186}}, color={255,127,0}));
  connect(dhw.charge, selTan.u2) annotation (Line(points={{-198,224},{-84,224},{
          -84,190},{-82,190}}, color={255,0,255}));
  connect(THeaWatSupSet, selTan.THeaWatSupPreSet) annotation (Line(points={{-320,
          -20},{-228,-20},{-228,168},{-100,168},{-100,182},{-82,182}}, color={0,
          0,127}));
  connect(tanHeaWat.T[1], selTan.THeaWatTop) annotation (Line(points={{-179,
          101.667},{-170,101.667},{-170,164},{-96,164},{-96,178},{-82,178}},
                                                                    color={0,0,127}));
  connect(dhw.TTanTop, selTan.THotWatTop) annotation (Line(points={{-198,240},{-92,
          240},{-92,170},{-82,170}}, color={0,0,127}));
  connect(selTan.TWatSupSet, conSup.THeaWatSupPreSet) annotation (Line(points={{
          -58,186},{-48,186},{-48,48},{-270,48},{-270,28},{-262,28},{-262,27}},
        color={0,0,127}));
  connect(selTan.TTanTop, conSup.THeaWatTop) annotation (Line(points={{-58,180},
          {-52,180},{-52,44},{-268,44},{-268,25},{-262,25}}, color={0,0,127}));
  connect(val.y, selTan.yVal) annotation (Line(points={{-98,80},{-92,80},{-92,
          164},{-58,164},{-58,174}},
                      color={0,0,127}));
  connect(or2.u1, uHea) annotation (Line(points={{-282,80},{-296,80},{-296,100},
          {-320,100}}, color={255,0,255}));
  connect(or2.u2, uSHW) annotation (Line(points={{-282,72},{-296,72},{-296,20},
          {-320,20}}, color={255,0,255}));
  connect(conSup.uHea, or2.y) annotation (Line(points={{-262,31},{-290,31},{
          -290,64},{-250,64},{-250,80},{-258,80}}, color={255,0,255}));
  connect(tanHeaWat.port_bBot, val.port_3) annotation (Line(points={{-180,98},{
          -170,98},{-170,80},{-120,80}}, color={0,127,255}));
  connect(val.port_2, colHeaWat.port_aDisSup) annotation (Line(points={{-110,70},
          {-110,60},{-160,60},{-160,-34},{-140,-34}}, color={0,127,255}));
  connect(colHeaWat.port_bDisRet, jun.port_1) annotation (Line(points={{-140,
          -40},{-170,-40},{-170,70},{-152,70},{-152,90},{-150,90}},
                                                           color={0,127,255}));
  connect(tanHeaWat.port_aTop, jun.port_3) annotation (Line(points={{-180,110},
          {-166,110},{-166,100},{-160,100}}, color={0,127,255}));
  connect(dHFloHotWat.port_b2, jun.port_2) annotation (Line(points={{-136,120},
          {-150,120},{-150,110}}, color={0,127,255}));
  connect(val.port_1, dHFloHotWat.port_a1) annotation (Line(points={{-110,90},{
          -112,90},{-112,112},{-124,112},{-124,120}}, color={0,127,255}));
  connect(dHFloHotWat.port_b1, dhw.port_b) annotation (Line(points={{-124,140},
          {-124,150},{-192,150},{-192,230},{-200,230}}, color={0,127,255}));
  connect(tanChaTwoSpe.TSet, THeaWatSupSet) annotation (Line(points={{-162,186},
          {-228,186},{-228,-20},{-320,-20}}, color={0,0,127}));
  connect(selTan.THotWatSupPreSet, TConLvgHotSet.y) annotation (Line(points={{
          -82,174},{-120,174},{-120,280},{-138,280}}, color={0,0,127}));
  connect(dhw.port_a, dHFloHotWat.port_a2) annotation (Line(points={{-220,230},
          {-234,230},{-234,140},{-136,140}}, color={0,127,255}));
  connect(dHFloHotWat.dH_flow, dHHotWat_flow) annotation (Line(points={{-127,
          142},{-127,156},{200,156},{200,300},{318,300}}, color={0,0,127}));
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
