within ThermalGridJBA.Hubs.BaseClasses;
model PartialParallel
  "Partial ETS model with district heat exchanger and parallel connection of production systems"
  extends Buildings.DHC.ETS.BaseClasses.PartialETS(
    final typ=Buildings.DHC.Types.DistrictSystemType.CombinedGeneration5,
    final have_heaWat=true,
    final have_chiWat=true,
    final have_pum=true,
    have_hotWat=false,
    have_eleHea=false,
    have_weaBus=false);

  parameter Buildings.DHC.ETS.Types.ConnectionConfiguration conCon=
      Buildings.DHC.ETS.Types.ConnectionConfiguration.Pump
    "District connection configuration" annotation (Evaluate=true);
  parameter Integer nSysHea
    "Number of heating systems"
    annotation (Evaluate=true);
  parameter Integer nSysCoo=nSysHea
    "Number of cooling systems"
    annotation (Evaluate=true);
  parameter Integer nSouAmb=1
    "Number of ambient sources"
    annotation (Evaluate=true);
  parameter Modelica.Units.SI.PressureDifference dpValIso_nominal(displayUnit=
        "Pa") = 2E3 "Nominal pressure drop of ambient circuit isolation valves"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.PressureDifference dp1Hex_nominal(displayUnit=
        "Pa") "Nominal pressure drop across heat exchanger on district side"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.Units.SI.PressureDifference dp2Hex_nominal(displayUnit=
        "Pa") "Nominal pressure drop across heat exchanger on building side"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.Units.SI.HeatFlowRate QHex_flow_nominal
    "Nominal heat flow rate through heat exchanger (from district to building)"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.Units.SI.Temperature T_a1Hex_nominal
    "Nominal water inlet temperature on district side"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.Units.SI.Temperature T_b1Hex_nominal
    "Nominal water outlet temperature on district side"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.Units.SI.Temperature T_a2Hex_nominal
    "Nominal water inlet temperature on building side"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.Units.SI.Temperature T_b2Hex_nominal
    "Nominal water outlet temperature on building side"
    annotation (Dialog(group="District heat exchanger"));
  parameter Real spePum1HexMin(
    final unit="1",
    min=0)=0.1
    "Heat exchanger primary pump minimum speed (fractional)"
    annotation (Dialog(group="District heat exchanger",enable=not have_val1Hex));
  parameter Real spePum2HexMin(
    final unit="1",
    min=0.01)=0.1
    "Heat exchanger secondary pump minimum speed (fractional)"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.Units.SI.Volume VTanHeaWat "Heating water tank volume"
    annotation (Dialog(group="Buffer Tank"));
  parameter Modelica.Units.SI.Length hTanHeaWat=(VTanHeaWat*16/Modelica.Constants.pi)
      ^(1/3) "Heating water tank height (assuming twice the diameter)"
    annotation (Dialog(group="Buffer Tank"));
  parameter Modelica.Units.SI.Length dInsTanHeaWat=0.1
    "Heating water tank insulation thickness"
    annotation (Dialog(group="Buffer Tank"));
  parameter Modelica.Units.SI.Volume VTanChiWat "Chilled water tank volume"
    annotation (Dialog(group="Buffer Tank"));
  parameter Modelica.Units.SI.Length hTanChiWat=(VTanChiWat*16/Modelica.Constants.pi)
      ^(1/3) "Chilled water tank height (without insulation)"
    annotation (Dialog(group="Buffer Tank"));
  parameter Modelica.Units.SI.Length dInsTanChiWat=0.1
    "Chilled water tank insulation thickness"
    annotation (Dialog(group="Buffer Tank"));
  parameter Integer nSegTan=3
    "Number of volume segments for tanks"
    annotation (Dialog(group="Buffer Tank"));

  // IO VARIABLES
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uCoo
    "Cooling enable signal"
    annotation (Placement(transformation(extent={{-340,40},{-300,80}}),iconTransformation(extent={{-380,20},
            {-300,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaWatSupSet(
    final unit="K",
    displayUnit="degC")
    "Heating water supply temperature set point"
    annotation (Placement(transformation(extent={{-340,-40},{-300,0}}),iconTransformation(extent={{-380,
            -60},{-300,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TChiWatSupSet(
    final unit="K",
    displayUnit="degC")
    "Chilled water supply temperature set point"
    annotation (Placement(transformation(extent={{-340,-80},{-300,-40}}),iconTransformation(extent={{-380,
            -100},{-300,-20}})));
  // COMPONENTS
  replaceable Buildings.DHC.ETS.Combined.Controls.BaseClasses.PartialSupervisory conSup
    constrainedby Buildings.DHC.ETS.Combined.Controls.BaseClasses.PartialSupervisory(
      final nSouAmb=nSouAmb)
    "Supervisory controller"
    annotation (Placement(transformation(extent={{-260,12},{-240,32}})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear valIsoEva(
    redeclare final package Medium = MediumBui,
    final dpValve_nominal=dpValIso_nominal,
    final m_flow_nominal=colAmbWat.mDis_flow_nominal,
    use_strokeTime=false) "Evaporator to ambient loop isolation valve"
    annotation (Placement(transformation(extent={{70,-130},{50,-110}})));
  Buildings.Fluid.Actuators.Valves.TwoWayLinear valIsoCon(
    redeclare final package Medium = MediumBui,
    final dpValve_nominal=dpValIso_nominal,
    final m_flow_nominal=colAmbWat.mDis_flow_nominal,
    use_strokeTime=false)
                         "Condenser to ambient loop isolation valve"
    annotation (Placement(transformation(extent={{-70,-130},{-50,-110}})));
  Buildings.DHC.ETS.Combined.Subsystems.HeatExchanger hex(
    redeclare final package Medium1=MediumSer,
    redeclare final package Medium2=MediumBui,
    final allowFlowReversal1=allowFlowReversalSer,
    final allowFlowReversal2=allowFlowReversalBui,
    final conCon=conCon,
    final dp1Hex_nominal=dp1Hex_nominal,
    final dp2Hex_nominal=dp2Hex_nominal,
    final Q_flow_nominal=QHex_flow_nominal,
    final T_a1_nominal=T_a1Hex_nominal,
    final T_b1_nominal=T_b1Hex_nominal,
    final T_a2_nominal=T_a2Hex_nominal,
    final T_b2_nominal=T_b2Hex_nominal,
    final spePum1Min=spePum1HexMin,
    final spePum2Min=spePum2HexMin) "District heat exchanger"
    annotation (Placement(transformation(extent={{-10,-244},{10,-264}})));
  Buildings.DHC.ETS.BaseClasses.StratifiedTank tanChiWat(
    redeclare final package Medium = MediumBui,
    final m_flow_nominal=colChiWat.mDis_flow_nominal,
    final VTan=VTanChiWat,
    final hTan=hTanChiWat,
    final dIns=dInsTanChiWat,
    final nSeg=nSegTan) "Chilled water tank"
    annotation (Placement(transformation(extent={{180,96},{200,116}})));
  ThermalGridJBA.Hubs.BaseClasses.StratifiedTankWithCommand tanHeaWat(
    redeclare final package Medium = MediumBui,
    final m_flow_nominal=colHeaWat.mDis_flow_nominal,
    final VTan=VTanHeaWat,
    final hTan=hTanHeaWat,
    final dIns=dInsTanHeaWat,
    final nSeg=nSegTan) "Heating hot water tank"
    annotation (Placement(transformation(extent={{-200,94},{-180,114}})));
  Buildings.DHC.ETS.BaseClasses.CollectorDistributor colChiWat(
    redeclare final package Medium = MediumBui,
    final nCon=1 + nSysCoo,
    mCon_flow_nominal={colAmbWat.mDis_flow_nominal})
    "Collector/distributor for chilled water" annotation (Placement(
        transformation(
        extent={{-20,10},{20,-10}},
        rotation=180,
        origin={120,-34})));
  Buildings.DHC.ETS.BaseClasses.CollectorDistributor colHeaWat(
    redeclare final package Medium = MediumBui,
    final nCon=1 + nSysHea,
    mCon_flow_nominal={colAmbWat.mDis_flow_nominal})
    "Collector/distributor for heating water" annotation (Placement(
        transformation(
        extent={{20,10},{-20,-10}},
        rotation=180,
        origin={-120,-34})));
  Buildings.DHC.ETS.BaseClasses.CollectorDistributor colAmbWat(
    redeclare final package Medium = MediumBui,
    final nCon=nSouAmb,
    mCon_flow_nominal={hex.m2_flow_nominal})
    "Collector/distributor for ambient water" annotation (Placement(
        transformation(
        extent={{20,-10},{-20,10}},
        rotation=180,
        origin={0,-106})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum totPPum(
    nin=1)
    "Total pump power"
    annotation (Placement(transformation(extent={{260,-70},{280,-50}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum totPHea(
    nin=1)
    "Total power drawn by heating system"
    annotation (Placement(transformation(extent={{260,50},{280,70}})));
  Buildings.Controls.OBC.CDL.Reals.MultiSum totPCoo(
    nin=1)
    "Total power drawn by cooling system"
    annotation (Placement(transformation(extent={{260,10},{280,30}})));
  Buildings.Fluid.Sources.Boundary_pT bou(redeclare final package Medium =
        MediumBui, nPorts=1)
    "Pressure boundary condition representing expansion vessel (common to HHW and CHW)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={190,-34})));
protected
  parameter Boolean have_val1Hex=
    conCon ==Buildings.DHC.ETS.Types.ConnectionConfiguration.TwoWayValve
    "True in case of control valve on district side, false in case of a pump";
equation
  connect(hex.PPum,totPPum.u[1])
    annotation (Line(points={{12,-254},{36,-254},{36,-60},{258,-60}},color={0,0,127}));
  connect(tanChiWat.TBot,conSup.TChiWatBot)
    annotation (Line(points={{201,97},{206,97},{206,0},{-274,0},{-274,19},{-262,
          19}},                                                                        color={0,0,127}));
  connect(hex.port_b2,colAmbWat.ports_aCon[1])
    annotation (Line(points={{-10,-248},{-20,-248},{-20,-160},{12,-160},{12,-116}},color={0,127,255}));
  connect(hex.port_a2,colAmbWat.ports_bCon[1])
    annotation (Line(points={{10,-248},{20,-248},{20,-140},{-12,-140},{-12,-116}},color={0,127,255}));
  connect(totPPum.y,PPum)
    annotation (Line(points={{282,-60},{290,-60},{290,-40},{320,-40}},
                                                  color={0,0,127}));
  connect(hex.yValIso_actual[1],valIsoCon.y_actual)
    annotation (Line(points={{-12,-251.5},{-40,-251.5},{-40,-113},{-55,-113}},
                                                                          color={0,0,127}));
  connect(hex.yValIso_actual[2],valIsoEva.y_actual)
    annotation (Line(points={{-12,-252.5},{-16,-252.5},{-16,-240},{40,-240},{40,
          -113},{55,-113}},                                                                  color={0,0,127}));
  connect(valIsoEva.port_b,colAmbWat.port_bDisSup)
    annotation (Line(points={{50,-120},{30,-120},{30,-106},{20,-106}},color={0,127,255}));
  connect(valIsoCon.port_b,colAmbWat.port_aDisSup)
    annotation (Line(points={{-50,-120},{-30,-120},{-30,-106},{-20,-106}},color={0,127,255}));
  connect(TChiWatSupSet,conSup.TChiWatSupPreSet)
    annotation (Line(points={{-320,-60},{-290,-60},{-290,21},{-262,21}},color={0,0,127}));
  connect(uCoo,conSup.uCoo)
    annotation (Line(points={{-320,60},{-292,60},{-292,29},{-262,29}},color={255,0,255}));
  connect(valIsoEva.port_a,colChiWat.ports_aCon[1])
    annotation (Line(points={{70,-120},{90,-120},{90,-24},{108,-24}},
                                                             color={0,127,255}));
  connect(colAmbWat.port_aDisRet,colChiWat.ports_bCon[1])
    annotation (Line(points={{20,-100},{150,-100},{150,-24},{132,-24}},
                                                             color={0,127,255}));
  connect(conSup.yValIsoEva,valIsoEva.y)
    annotation (Line(points={{-238,21},{-220,21},{-220,-80},{60,-80},{60,-108}},color={0,0,127}));
  connect(conSup.yValIsoCon,valIsoCon.y)
    annotation (Line(points={{-238,23},{-218,23},{-218,-76},{-60,-76},{-60,-108}},color={0,0,127}));
  connect(conSup.yAmb[nSouAmb],hex.u)
    annotation (Line(points={{-238,25},{-200,25},{-200,-256},{-12,-256}},color={0,0,127}));
  connect(valIsoCon.port_a,colHeaWat.ports_aCon[1])
    annotation (Line(points={{-70,-120},{-90,-120},{-90,-24},{-108,-24}},
                                                                color={0,127,255}));
  connect(colAmbWat.port_bDisRet,colHeaWat.ports_bCon[1])
    annotation (Line(points={{-20,-100},{-150,-100},{-150,-24},{-132,-24}},
                                                                color={0,127,255}));
  connect(totPHea.y,PHea)
    annotation (Line(points={{282,60},{290,60},{290,80},{320,80}},
                                                color={0,0,127}));
  connect(totPCoo.y,PCoo)
    annotation (Line(points={{282,20},{290,20},{290,40},{320,40}},
                                                color={0,0,127}));
  connect(bou.ports[1], colChiWat.port_aDisSup)
    annotation (Line(points={{180,-34},{140,-34}},            color={0,127,255}));
  annotation (
    Icon(
      coordinateSystem(
        preserveAspectRatio=false)),
    Diagram(
      coordinateSystem(
        preserveAspectRatio=false,
        extent={{-300,-300},{300,300}}),
      graphics={
        Line(
          points={{86,92}},
          color={28,108,200},
          pattern=LinePattern.Dash)}),
    defaultComponentName="ets",
    Documentation(
      info="<html>
<p>
Revised from Buildings.DHC.ETS.Combined.BaseClasses.PartialParallel.
</p>
</html>"));
end PartialParallel;
