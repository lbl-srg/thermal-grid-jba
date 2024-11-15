within ThermalGridJBA.Hubs;
model ConnectedETS
  "Load connected to the network via ETS with or without DHW integration"
  extends ThermalGridJBA.Hubs.BaseClasses.PartialConnectedETS(redeclare
      ThermalGridJBA.Hubs.BaseClasses.ChillerThreeUtilities ets(
      final have_hotWat=datBui.have_hotWat,
      QChiWat_flow_nominal=QCoo_flow_nominal,
      QHeaWat_flow_nominal=QHea_flow_nominal,
      QHotWat_flow_nominal=QHot_flow_nominal,
      dp1Hex_nominal=40E3,
      dp2Hex_nominal=40E3,
      QHex_flow_nominal=-QCoo_flow_nominal,
      T_a1Hex_nominal=284.15,
      T_b1Hex_nominal=279.15,
      T_a2Hex_nominal=277.15,
      T_b2Hex_nominal=282.15,
      VTanHeaWat=datChi.mCon_flow_nominal*datBui.dTHeaWat_nominal*5*60/1000,
      VTanChiWat=datChi.mEva_flow_nominal*datBui.dTChiWat_nominal*5*60/1000,
      dpCon_nominal=40E3,
      dpEva_nominal=40E3,
      datChi=datChi,
      datDhw=datDhw,
      kHot=0.02),
    allowFlowReversalBui=true);
  parameter
    Buildings.DHC.Loads.HotWater.Data.GenericDomesticHotWaterWithHeatExchanger datDhw(
    VTan=datChi.mCon_flow_nominal*datBui.dTHeaWat_nominal*5*60/1000,
    mDom_flow_nominal=datDhw.QHex_flow_nominal/4200/(datDhw.TDom_nominal -
        datDhw.TCol_nominal),
    QHex_flow_nominal=max(QHotWat_flow_nominal, QHeaWat_flow_nominal),
    TDom_nominal=datBui.THotWatSup_nominal)
    "Performance data of the domestic hot water component"
    annotation (Placement(transformation(extent={{20,222},{40,242}})));
  parameter Modelica.Units.SI.HeatFlowRate QHot_flow_nominal(
    min=Modelica.Constants.eps)=
    max(Buildings.DHC.Loads.BaseClasses.getPeakLoad(
          string="#Peak water heating load",
          filNam=Modelica.Utilities.Files.loadResource(datBui.filNam)),
        1)
    "Design heating heat flow rate (>=0)"
    annotation (Dialog(group="Design parameter"));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant THotWatSupSet(
    final k=40 + 273.15,
    y(final unit="K", displayUnit="degC")) if datBui.have_hotWat
    "Domestic hot water supply temperature set point"
    annotation (Placement(transformation(extent={{-140,-10},{-120,10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TColWat(final k=15 + 273.15,
      y(final unit="K", displayUnit="degC")) if datBui.have_hotWat
                                             "Domestic cold water temperature"
    annotation (Placement(transformation(extent={{-140,-50},{-120,-30}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter loaHotNor(k=1/
        QHot_flow_nominal) if have_hotWat
                           "Normalized DHW load"
    annotation (Placement(transformation(extent={{-140,-200},{-120,-180}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold uHot(final t=0.01, final h=0.005)
    if have_hotWat
    "Enable hot water"
    annotation (Placement(transformation(extent={{-100,-200},{-80,-180}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput dHHeaWat_flow(final unit="W")
    "Heating water distributed energy flow rate"
    annotation (Placement(transformation(extent={{300,-140},{340,-100}}),
      iconTransformation(extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={-40,-120})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput dHChiWat_flow(final unit="W")
    "Chilled water distributed energy flow rate"
    annotation (Placement(transformation(extent={{300,-100},{340,-60}}),
      iconTransformation(extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={-20,-120})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput dHHotWat_flow(final unit="W")
    if have_hotWat
    "Domestic hot water distributed energy flow rate" annotation (Placement(
        transformation(extent={{300,-180},{340,-140}}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={-60,-120})));
equation

  connect(ets.QReqHotWat_flow, bui.QReqHotWat_flow) annotation (Line(points={{-34,-74},
          {-36,-74},{-36,-146},{84,-146},{84,-2},{28,-2},{28,4}},      color={0,
          0,127}));
  connect(ets.THotWatSupSet, THotWatSupSet.y) annotation (Line(points={{-34,-66},
          {-70,-66},{-70,0},{-118,0}}, color={0,0,127}));
  connect(TColWat.y, ets.TColWat) annotation (Line(points={{-118,-40},{-74,-40},
          {-74,-70},{-34,-70}}, color={0,0,127}));
  connect(loaHotNor.y, uHot.u)
    annotation (Line(points={{-118,-190},{-102,-190}}, color={0,0,127}));
  connect(uHot.y,ets.uDHW)  annotation (Line(points={{-78,-190},{-38,-190},{-38,
          -54},{-34,-54}}, color={255,0,255}));
  connect(loaHotNor.u, bui.QReqHotWat_flow) annotation (Line(points={{-142,-190},
          {-150,-190},{-150,-212},{-36,-212},{-36,-146},{84,-146},{84,-2},{28,-2},
          {28,4}}, color={0,0,127}));
  connect(ets.dHChiWat_flow, dHChiWat_flow) annotation (Line(points={{28,-90},{
          28,-100},{280,-100},{280,-80},{320,-80}}, color={0,0,127}));
  connect(dHHeaWat_flow, ets.dHHeaWat_flow) annotation (Line(points={{320,-120},
          {280,-120},{280,-106},{24,-106},{24,-90}}, color={0,0,127}));
  connect(ets.dHHotWat_flow, dHHotWat_flow) annotation (Line(points={{20,-90},{
          20,-112},{276,-112},{276,-160},{320,-160}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
        defaultComponentName = "bui");
end ConnectedETS;
