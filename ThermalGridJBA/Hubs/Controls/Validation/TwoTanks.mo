within ThermalGridJBA.Hubs.Controls.Validation;
model TwoTanks
  extends Modelica.Icons.Example;

  package Medium = Buildings.Media.Water "Medium model";

  parameter Data.Individual.B1380 buiDat
    annotation (Placement(transformation(extent={{40,120},{60,140}})));
  parameter Buildings.DHC.Loads.HotWater.Data.GenericDomesticHotWaterWithHeatExchanger
    datWatHea(
    VTan=mCon_flow_nominal*buiDat.dTHeaWat_nominal*5*60/1000,
    mDom_flow_nominal=QHot_flow_nominal/4200/(datWatHea.TDom_nominal - datWatHea.TCol_nominal),
    QHex_flow_nominal=QHot_flow_nominal)
    "Data for heat pump water heater with tank"
    annotation (Placement(transformation(extent={{80,120},{100,140}})));
  parameter Modelica.Units.SI.HeatFlowRate QHot_flow_nominal(
    min=Modelica.Constants.eps) =
    Buildings.DHC.Loads.BaseClasses.getPeakLoad(
      string="#Peak water heating load",
      filNam=Modelica.Utilities.Files.loadResource(buiDat.filNam))
    "Design domestic hot water load (>=0)";
  parameter Modelica.Units.SI.HeatFlowRate QHea_flow_nominal(
    min=Modelica.Constants.eps) =
    Buildings.DHC.Loads.BaseClasses.getPeakLoad(
      string="#Peak space heating load",
      filNam=Modelica.Utilities.Files.loadResource(buiDat.filNam))
    "Design heating hot water load (>=0)"
    annotation (Dialog(group="Design parameter"));
  parameter Modelica.Units.SI.MassFlowRate mSecHot_flow_nominal =
    QHot_flow_nominal/buiDat.dTHeaWat_nominal/4182
    "Domestic hot water secondary loop nominal mass flow rate";
    // DHW loop dT is the same as HHW. Not an error.
  parameter Modelica.Units.SI.MassFlowRate mSecHea_flow_nominal =
    QHea_flow_nominal/buiDat.dTHeaWat_nominal/4182
    "Domestic hot water secondary loop nominal mass flow rate";
  parameter Modelica.Units.SI.MassFlowRate mCon_flow_nominal =
    max(mSecHot_flow_nominal,mSecHea_flow_nominal)
    "Condenser nominal mass flow rate";
  parameter Modelica.Units.SI.ThermodynamicTemperature T_start =
    buiDat.THeaWatRet_nominal
    "Temperature start value for components";

  Buildings.Fluid.Sources.PropertySource_T con(
    redeclare final package Medium = Medium,
    final use_T_in=true)
    "Condenser side of the heat recovery chiller represented by an ideal temperature source"
                                                         annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={70,-10})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumPri(
    redeclare final package Medium = Medium,
    T_start=T_start,
    final addPowerToMedium=false,
    final m_flow_nominal=mCon_flow_nominal,
    final dp_nominal=preDroCon.dp_nominal) "Primary CHW pump"
    annotation (Placement(transformation(extent={{60,10},{40,30}})));
  ThermalGridJBA.Hubs.BaseClasses.StratifiedTank tanHea(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mSecHea_flow_nominal,
    final VTan=mSecHea_flow_nominal*buiDat.dTHeaWat_nominal*5*60/1000,
    final hTan=(tanHea.VTan*16/Modelica.Constants.pi)^(1/3),
    final dIns=0.1,
    final nSeg=9,
    final iMid=5,
    tan(T_start=buiDat.THeaWatSup_nominal)) "Heating hot water tank"
    annotation (Placement(transformation(extent={{-82,-20},{-62,0}})));
  Buildings.Fluid.MixingVolumes.MixingVolume volHea(
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=T_start,
    final prescribedHeatFlowRate=true,
    redeclare package Medium = Medium,
    V=10,
    final mSenFac=1,
    final m_flow_nominal=mSecHea_flow_nominal,
    nPorts=2) "Volume for heating water distribution circuit" annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={-191,-10})));
  Buildings.HeatTransfer.Sources.PrescribedHeatFlow loaHea
    "Heating load as prescribed heat flow rate"
    annotation (Placement(transformation(extent={{-220,0},{-200,20}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumSecHea(
    redeclare final package Medium = Medium,
    T_start=T_start,
    final addPowerToMedium=false,
    final m_flow_nominal=mSecHea_flow_nominal,
    final dp_nominal=preDroSecHea.dp_nominal)
    "Secondary pump for heating hot water"
    annotation (Placement(transformation(extent={{-102,10},{-122,30}})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroCon(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mCon_flow_nominal,
    dp_nominal=40E3) "Pressure drop of the condenser primary loop" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={50,-40})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroSecHea(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mSecHea_flow_nominal,
    dp_nominal=40E3) "Pressure drop of heating hot water secondary loop"
                                                       annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-112,-40})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter heaToMasHea(final k=
        mSecHea_flow_nominal/QHea_flow_nominal)
    "Heat flow rate converted to mass flow rate" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-250,50})));
  Modelica.Blocks.Sources.CombiTimeTable loa(
    tableOnFile=true,
    tableName="tab1",
    fileName=Modelica.Utilities.Files.loadResource(buiDat.filNam),
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    y(each unit="W"),
    offset={0,0,0},
    columns={2,3,4},
    smoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1)
    "Reader for thermal loads (y[1] is cooling load, y[2] is space heating load, y[3] is domestic water heat load)"
    annotation (Placement(transformation(extent={{-300,40},{-280,60}})));
  Buildings.Fluid.Sources.Boundary_pT bou(redeclare final package Medium =
        Medium, nPorts=1)
    "Pressure boundary condition representing expansion vessel (common to HHW and CHW)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={130,20})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTRetHea(
    redeclare final package Medium = Medium,
    m_flow_nominal=mSecHea_flow_nominal,
    T_start=T_start) "Return temperature of heating hot water"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-152,-40})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter negHea(final k=-1)
    "Turns load negative" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-250,10})));
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare final package Medium = Medium,
    T_start=T_start,
    final portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    final portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    final portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    final dp_nominal={0,0,0},
    final energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    final tau=1,
    final m_flow_nominal={-mCon_flow_nominal,mSecHea_flow_nominal,
        mSecHot_flow_nominal}) "Junction" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={10,20})));
  Buildings.Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear val(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    T_start=T_start,
    m_flow_nominal=mCon_flow_nominal,
    dpValve_nominal=6000)
    "Three way valve selecting condenser flow from HHW or DHW return"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-10,-40})));
  ThermalGridJBA.Hubs.Controls.TwoTankControl twoTanCon(
    T2Sup=323.15,
    T3Sup=buiDat.THeaWatSup_nominal,
    m_flow_set=mCon_flow_nominal,
    rSlo=0.3)
    annotation (Placement(transformation(extent={{40,60},{60,80}})));
  ThermalGridJBA.Hubs.Controls.TankChargingTwoSpeed tanChaTwoSpe
    annotation (Placement(transformation(extent={{-40,40},{-20,60}})));
  Modelica.Blocks.Sources.Constant TTanHeaSet(k=buiDat.THeaWatSup_nominal - 3)
    annotation (Placement(transformation(extent={{-80,40},{-60,60}})));
  ThermalGridJBA.Hubs.BaseClasses.DHWConsumption dhw(
    redeclare final package Medium = Medium,
    final dat=datWatHea,
    QHotWat_flow_nominal=QHot_flow_nominal,
    dT_nominal=buiDat.dTHeaWat_nominal)
    annotation (Placement(transformation(extent={{-120,80},{-100,100}})));
  Modelica.Blocks.Sources.Constant TTanHotSet(k=40 + 273.15)
    annotation (Placement(transformation(extent={{-300,120},{-280,140}})));
  Modelica.Blocks.Sources.Constant TColWat(k=15 + 273.15)
    "Domestic cold water temperature"
    annotation (Placement(transformation(extent={{-300,80},{-280,100}})));
equation
  connect(con.port_b,pumPri. port_a)
    annotation (Line(points={{70,0},{70,20},{60,20}}, color={0,127,255}));
  connect(loaHea.port, volHea.heatPort)
    annotation (Line(points={{-200,10},{-191,10},{-191,0}}, color={191,0,0}));
  connect(tanHea.port_bTop, pumSecHea.port_a) annotation (Line(points={{-82,-4},
          {-96,-4},{-96,20},{-102,20}}, color={0,127,255}));
  connect(pumSecHea.port_b, volHea.ports[1]) annotation (Line(points={{-122,20},
          {-178,20},{-178,-9},{-181,-9}}, color={0,127,255}));
  connect(preDroCon.port_b,con. port_a)
    annotation (Line(points={{60,-40},{70,-40},{70,-20}}, color={0,127,255}));
  connect(tanHea.port_aBot, preDroSecHea.port_b) annotation (Line(points={{-82,-16},
          {-92,-16},{-92,-40},{-102,-40}}, color={0,127,255}));
  connect(heaToMasHea.y, pumSecHea.m_flow_in)
    annotation (Line(points={{-238,50},{-112,50},{-112,32}}, color={0,0,127}));
  connect(bou.ports[1],pumPri. port_a)
    annotation (Line(points={{120,20},{60,20}}, color={0,127,255}));
  connect(preDroSecHea.port_a, senTRetHea.port_b)
    annotation (Line(points={{-122,-40},{-142,-40}}, color={0,127,255}));
  connect(senTRetHea.port_a, volHea.ports[2]) annotation (Line(points={{-162,-40},
          {-176,-40},{-176,-11},{-181,-11}}, color={0,127,255}));
  connect(negHea.y, loaHea.Q_flow)
    annotation (Line(points={{-238,10},{-220,10}}, color={0,0,127}));
  connect(loa.y[2], negHea.u) annotation (Line(points={{-279,50},{-270,50},{-270,
          10},{-262,10}}, color={0,0,127}));
  connect(loa.y[2], heaToMasHea.u) annotation (Line(points={{-279,50},{-262,50}},
                                color={0,0,127}));
  connect(val.port_2, preDroCon.port_a)
    annotation (Line(points={{0,-40},{40,-40}}, color={0,127,255}));
  connect(val.port_1, tanHea.port_bBot) annotation (Line(points={{-20,-40},{-30,
          -40},{-30,-16},{-62,-16}}, color={0,127,255}));
  connect(jun.port_1, pumPri.port_b)
    annotation (Line(points={{20,20},{40,20}}, color={0,127,255}));
  connect(jun.port_2, tanHea.port_aTop) annotation (Line(points={{0,20},{-30,20},
          {-30,-4},{-62,-4}}, color={0,127,255}));
  connect(twoTanCon.TConSup, con.T_in) annotation (Line(points={{62,76},{90,76},
          {90,-14},{82,-14}}, color={0,0,127}));
  connect(twoTanCon.mPum_flow, pumPri.m_flow_in) annotation (Line(points={{62,70},
          {80,70},{80,42},{50,42},{50,32}}, color={0,0,127}));
  connect(twoTanCon.yVal, val.y) annotation (Line(points={{62,64},{100,64},{100,
          -62},{-10,-62},{-10,-52}}, color={0,0,127}));
  connect(tanChaTwoSpe.y, twoTanCon.u3) annotation (Line(points={{-18,50},{30,50},
          {30,64},{38,64}}, color={255,127,0}));
  connect(tanHea.T, tanChaTwoSpe.TTan) annotation (Line(points={{-61,-12},{-50,-12},
          {-50,44},{-42,44}}, color={0,0,127}));
  connect(TTanHeaSet.y, tanChaTwoSpe.TSet) annotation (Line(points={{-59,50},{-50,
          50},{-50,56},{-42,56}}, color={0,0,127}));
  connect(jun.port_3, dhw.port_a) annotation (Line(points={{10,30},{10,110},{-130,
          110},{-130,90},{-120,90}}, color={0,127,255}));
  connect(dhw.port_b, val.port_3) annotation (Line(points={{-100,90},{-10,90},{-10,
          -30}}, color={0,127,255}));
  connect(dhw.charge, twoTanCon.u2) annotation (Line(points={{-98,84},{28,84},{28,
          76},{38,76}}, color={255,0,255}));
  connect(loa.y[3], dhw.QReqHotWat_flow) annotation (Line(points={{-279,50},{-270,
          50},{-270,86},{-122,86}}, color={0,0,127}));
  connect(TColWat.y, dhw.TColWat) annotation (Line(points={{-279,90},{-140,90},{
          -140,94},{-122,94}}, color={0,0,127}));
  connect(TTanHotSet.y, dhw.THotWatSupSet) annotation (Line(points={{-279,130},{
          -140,130},{-140,98},{-122,98}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}})),                                        Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-320,-120},{160,240}})),
        experiment(StopTime=864000,Tolerance=1E-6),
__Dymola_Commands(
      file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Hubs/Controls/Validation/TwoTanks.mos" "Simulate and plot"));
end TwoTanks;
