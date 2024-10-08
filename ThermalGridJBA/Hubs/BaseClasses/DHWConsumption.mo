within ThermalGridJBA.Hubs.BaseClasses;
model DHWConsumption
  "DHW tank, HX, thermostatic mixing valve, and sink"
  extends Buildings.Fluid.Interfaces.PartialTwoPortInterface(
    final m_flow_nominal=QHotWat_flow_nominal/4200/dT_nominal);

  parameter Buildings.DHC.Loads.HotWater.Data.GenericDomesticHotWaterWithHeatExchanger
    dat "Performance data"
    annotation (Placement(transformation(extent={{60,80},{80,100}})));
  parameter Modelica.Units.SI.HeatFlowRate QHotWat_flow_nominal(min=0)
    "Nominal capacity of heat pump condenser for hot water production system (>=0)"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.TemperatureDifference dT_nominal(min=Modelica.Constants.eps)
    "Nominal temperature difference from the condenser"
    annotation(Dialog(group="Nominal condition"));

  Buildings.DHC.Loads.HotWater.StorageTankWithExternalHeatExchanger domHotWatTan(
    redeclare final package MediumDom = Medium,
    redeclare final package MediumHea = Medium,
    final dat=dat)
    annotation (Placement(transformation(extent={{20,-20},{40,0}})));
  Buildings.DHC.Loads.HotWater.ThermostaticMixingValve theMixVal(
    redeclare final package Medium = Medium, mMix_flow_nominal=1.2*dat.mDom_flow_nominal)
    annotation (Placement(transformation(extent={{60,20},{80,40}})));
  Buildings.Fluid.Sources.Boundary_pT souDCW(
    redeclare final package Medium = Medium,
    use_T_in=true,
    nPorts=1) "Source for domestic cold water"
                                 annotation (Placement(
      transformation(
      extent={{10,-10},{-10,10}},
      rotation=180,
      origin={-50,30})));
  Buildings.DHC.ETS.BaseClasses.Junction dcwSpl(
    redeclare final package Medium = Medium,
    final m_flow_nominal=m_flow_nominal*{1,-1,-1})
                                             "Splitter for domestic cold water"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={10,30})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THotWatSupSet(final unit="K",
      displayUnit="degC")
    "Domestic hot water temperature set point for supply to fixtures"
    annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-120,80}),
        iconTransformation(
        extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TColWat(final unit="K",
      displayUnit="degC")
    "Cold water temperature" annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-120,40}),  iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-120,40})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput QReqHotWat_flow(final unit="W")
                                   "Service hot water load"
    annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-120,-40}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-120,-40})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(k=1/
        QHotWat_flow_nominal)
    annotation (Placement(transformation(extent={{0,50},{20,70}})));
  Modelica.Blocks.Interfaces.RealOutput PEle(unit="W")
    "Electric power required for pumping equipment"
    annotation (Placement(transformation(extent={{100,20},{140,60}}),
        iconTransformation(extent={{100,50},{120,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput charge
    "Output true if tank needs to be charged, false if it is sufficiently charged"
    annotation (Placement(transformation(extent={{100,-60},{140,-20}}),
        iconTransformation(extent={{100,-80},{140,-40}})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TTanTop(
    final unit="K",
    displayUnit="degC") "Temperature at the tank top" annotation (Placement(
        transformation(extent={{100,60},{140,100}}), iconTransformation(extent=
            {{100,80},{140,120}})));
  Modelica.Blocks.Sources.RealExpression expTTanTop(
    y=domHotWatTan.TTanTop.T)
    annotation (Placement(transformation(extent={{60,50},{80,70}})));
equation
  connect(port_a, domHotWatTan.port_aHea) annotation (Line(points={{-100,0},{0,
          0},{0,-40},{50,-40},{50,-16},{40,-16}},      color={0,127,255}));
  connect(domHotWatTan.port_bHea, port_b) annotation (Line(points={{20,-16},{16,
          -16},{16,-28},{92,-28},{92,0},{100,0}},  color={0,127,255}));
  connect(domHotWatTan.port_bDom, theMixVal.port_hot) annotation (Line(points={{40,-4},
          {50,-4},{50,26},{60,26}},         color={0,127,255}));
  connect(souDCW.ports[1], dcwSpl.port_1)
    annotation (Line(points={{-40,30},{0,30}}, color={0,127,255}));
  connect(dcwSpl.port_2, theMixVal.port_col) annotation (Line(points={{20,30},{30,
          30},{30,22},{60,22}},    color={0,127,255}));
  connect(dcwSpl.port_3, domHotWatTan.port_aDom)
    annotation (Line(points={{10,20},{10,-4},{20,-4}}, color={0,127,255}));
  connect(souDCW.T_in, TColWat) annotation (Line(points={{-62,26},{-80,26},{-80,
          40},{-120,40}}, color={0,0,127}));
  connect(theMixVal.yMixSet, gai.y) annotation (Line(points={{59,38},{30,38},{30,
          60},{22,60}}, color={0,0,127}));
  connect(QReqHotWat_flow, gai.u) annotation (Line(points={{-120,-40},{-20,-40},
          {-20,60},{-2,60}}, color={0,0,127}));
  connect(THotWatSupSet, theMixVal.TMixSet) annotation (Line(points={{-120,80},{
          50,80},{50,32},{59,32}}, color={0,0,127}));
  connect(THotWatSupSet, domHotWatTan.TDomSet) annotation (Line(points={{-120,80},
          {-30,80},{-30,-10},{19,-10}}, color={0,0,127}));
  connect(domHotWatTan.PEle, PEle) annotation (Line(points={{41,-10},{86,-10},{86,
          40},{120,40}}, color={0,0,127}));
  connect(domHotWatTan.charge, charge) annotation (Line(points={{42,-19},{42,-18},
          {80,-18},{80,-40},{120,-40}}, color={255,0,255}));
  connect(expTTanTop.y, TTanTop) annotation (Line(points={{81,60},{86,60},{86,
          80},{120,80}}, color={0,0,127}));
  annotation (defaultComponentName="dhw",
    Icon(coordinateSystem(preserveAspectRatio=false),
        graphics={              Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid), Text(
          extent={{-66,40},{60,-38}},
          textColor={102,44,145},
          textString="DHW",
          textStyle={TextStyle.Bold})}),  Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end DHWConsumption;
