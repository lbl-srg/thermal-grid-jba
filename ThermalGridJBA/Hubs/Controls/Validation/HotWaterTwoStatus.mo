within ThermalGridJBA.Hubs.Controls.Validation;
model HotWaterTwoStatus
  extends Modelica.Icons.Example;

  replaceable package Medium = Buildings.Media.Water "Medium model";

  parameter Data.Individual.B1380 datBui
    annotation (Placement(transformation(extent={{-40,60},{-20,80}})));
  parameter Buildings.DHC.Loads.HotWater.Data.GenericDomesticHotWaterWithHeatExchanger
    datWatHea(
    VTan=mCon_flow_nominal*datBui.dTHeaWat_nominal*30*60/1000,
    mDom_flow_nominal=QHotWat_flow_nominal/4200/(TDom_nominal-TCol_nominal),
    QHex_flow_nominal=QHotWat_flow_nominal)
    "Data for heat pump water heater with tank"
    annotation (Placement(transformation(extent={{0,60},{20,80}})));
  parameter Modelica.Units.SI.HeatFlowRate QHotWat_flow_nominal(
    min=Modelica.Constants.eps) =
    Buildings.DHC.Loads.BaseClasses.getPeakLoad(
      string="#Peak water heating load",
      filNam=Modelica.Utilities.Files.loadResource(datBui.filNam))
    "Design heat flow rate (>=0)"
    annotation (Dialog(group="Design parameter"));
  parameter Modelica.Units.SI.HeatFlowRate QHeaWat_flow_nominal(
    min=Modelica.Constants.eps) =
    Buildings.DHC.Loads.BaseClasses.getPeakLoad(
      string="#Peak space heating load",
      filNam=Modelica.Utilities.Files.loadResource(datBui.filNam))
    "Design heat flow rate (>=0)"
    annotation (Dialog(group="Design parameter"));
  parameter Modelica.Units.SI.ThermodynamicTemperature T_start=datBui.THeaWatRet_nominal
    "Temperature start value for components";
  parameter Modelica.Units.SI.MassFlowRate mCon_flow_nominal=
    QHeaWat_flow_nominal/datBui.dTHeaWat_nominal/4182
    "Secondary loop nominal mass flow rate";
    // Sized for HHW
  parameter Modelica.Units.SI.Temperature TDom_nominal = 40 + 273.15
    "Temperature of domestic hot water leaving heater at nominal conditions";
  parameter Modelica.Units.SI.Temperature TCol_nominal = 15 + 273.15
    "Temperature of cold water at nominal conditions";

  ThermalGridJBA.Hubs.BaseClasses.DHWConsumption dhw(
    redeclare final package Medium = Medium,
    final dat=datWatHea,
    final QHotWat_flow_nominal=QHotWat_flow_nominal,
    final dT_nominal=datBui.dTHeaWat_nominal)
    annotation (Placement(transformation(extent={{0,-20},{20,0}})));
  Buildings.Fluid.Sources.PropertySource_T con(redeclare final package Medium
      = Medium, final use_T_in=true)
    "Condenser side of the heat recovery chiller represented by an ideal temperature source"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={150,-10})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumPri(
    redeclare final package Medium = Medium,
    T_start=T_start,
    final addPowerToMedium=false,
    final m_flow_nominal=mCon_flow_nominal,
    final dp_nominal=preDroCon.dp_nominal) "Primary CHW pump"
    annotation (Placement(transformation(extent={{140,10},{120,30}})));
  Modelica.Blocks.Sources.Constant TSupSet(k=50 + 273.15)
    annotation (Placement(transformation(extent={{140,60},{160,80}})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroCon(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mCon_flow_nominal,
    dp_nominal=40E3) "Pressure drop of the condenser primary loop" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={130,-40})));
  Modelica.Blocks.Sources.CombiTimeTable loa(
    tableOnFile=true,
    tableName="tab1",
    fileName=Modelica.Utilities.Files.loadResource(datBui.filNam),
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    y(each unit="W"),
    offset={0,0,0},
    columns={2,3,4},
    smoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1)
    "Reader for thermal loads (y[1] is cooling load, y[2] is space heating load, y[3] is domestic water heat load)"
    annotation (Placement(transformation(extent={{-60,-60},{-40,-40}})));

  Buildings.Fluid.Sources.Boundary_pT bou(redeclare final package Medium =
        Medium, nPorts=1)
    "Pressure boundary condition representing expansion vessel (common to HHW and CHW)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={210,20})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea(realTrue=
        mCon_flow_nominal, realFalse=0)
    annotation (Placement(transformation(extent={{70,40},{90,60}})));
  Buildings.Controls.OBC.CDL.Reals.LimitSlewRate ramLim(raisingSlewRate=
        mCon_flow_nominal/90)
    annotation (Placement(transformation(extent={{100,40},{120,60}})));
  Modelica.Blocks.Sources.Constant TSupSet1(k=40 + 273.15)
    annotation (Placement(transformation(extent={{-60,20},{-40,40}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold truFalHol(trueHoldDuration=900)
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
  Modelica.Blocks.Sources.Constant TColWat(k=15 + 273.15)
    "Domestic cold water temperature"
    annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTRet(
    redeclare final package Medium = Medium,
    m_flow_nominal=mCon_flow_nominal,
    T_start=T_start) "Water return temperature"
                               annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={70,-10})));
equation
  connect(con.port_b,pumPri. port_a)
    annotation (Line(points={{150,0},{150,20},{140,20}},
                                                      color={0,127,255}));
  connect(TSupSet.y,con. T_in) annotation (Line(points={{161,70},{170,70},{170,
          -14},{162,-14}},
                     color={0,0,127}));
  connect(preDroCon.port_b,con. port_a)
    annotation (Line(points={{140,-40},{150,-40},{150,-20}},
                                                          color={0,127,255}));
  connect(bou.ports[1],pumPri. port_a)
    annotation (Line(points={{200,20},{140,20}},color={0,127,255}));
  connect(booToRea.y,ramLim. u)
    annotation (Line(points={{92,50},{98,50}},
                                             color={0,0,127}));
  connect(ramLim.y,pumPri. m_flow_in)
    annotation (Line(points={{122,50},{130,50},{130,32}}, color={0,0,127}));
  connect(truFalHol.y,booToRea. u)
    annotation (Line(points={{62,50},{68,50}}, color={255,0,255}));
  connect(pumPri.port_b, dhw.port_a) annotation (Line(points={{120,20},{-10,20},
          {-10,-10},{0,-10}}, color={0,127,255}));
  connect(dhw.charge, truFalHol.u) annotation (Line(points={{22,-16},{32,-16},{32,
          50},{38,50}}, color={255,0,255}));
  connect(loa.y[3], dhw.QReqHotWat_flow) annotation (Line(points={{-39,-50},{-12,
          -50},{-12,-14},{-2,-14}}, color={0,0,127}));
  connect(TSupSet1.y, dhw.THotWatSupSet) annotation (Line(points={{-39,30},{-20,
          30},{-20,-2},{-2,-2}}, color={0,0,127}));
  connect(TColWat.y, dhw.TColWat) annotation (Line(points={{-39,-10},{-20,-10},{
          -20,-6},{-2,-6}}, color={0,0,127}));
  connect(dhw.port_b, senTRet.port_a)
    annotation (Line(points={{20,-10},{60,-10}}, color={0,127,255}));
  connect(senTRet.port_b, preDroCon.port_a) annotation (Line(points={{80,-10},{
          114,-10},{114,-40},{120,-40}}, color={0,127,255}));
annotation(experiment(StopTime=864000,Tolerance=1E-6),
    __Dymola_Commands(
      file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Hubs/Controls/Validation/HotWaterTwoStatus.mos" "Simulate and plot"));
end HotWaterTwoStatus;
