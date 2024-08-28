within ThermalGridJBA.Hubs.Controls.Validation;
model HeatingWaterThreeStatus
  extends Modelica.Icons.Example;

  replaceable package Medium = Buildings.Media.Water "Medium model";

  parameter ThermalGridJBA.Data.Individual.B1380 buiDat
    annotation (Placement(transformation(extent={{-80,80},{-60,100}})));
  parameter Modelica.Units.SI.HeatFlowRate QHea_flow_nominal(min=Modelica.Constants.eps)
    =Buildings.DHC.Loads.BaseClasses.getPeakLoad(
    string="#Peak space heating load",
    filNam=Modelica.Utilities.Files.loadResource(buiDat.filNam))
    "Design heat flow rate (>=0)"
    annotation (Dialog(group="Design parameter"));
  parameter Modelica.Units.SI.ThermodynamicTemperature T_start=buiDat.THeaWatRet_nominal
    "Temperature start value for components";
  parameter Modelica.Units.SI.MassFlowRate mCon_flow_nominal=mSec_flow_nominal
    "Condenser nominal mass flow rate";
  parameter Modelica.Units.SI.MassFlowRate mSec_flow_nominal=QHea_flow_nominal/
      buiDat.dTHeaWat_nominal/4182
    "Secondary loop nominal mass flow rate";

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
  Modelica.Blocks.Sources.Constant TSupSet(k=buiDat.THeaWatSup_nominal)
    annotation (Placement(transformation(extent={{140,60},{160,80}})));
  ThermalGridJBA.Hubs.BaseClasses.StratifiedTank tan(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mSec_flow_nominal,
    final VTan=mCon_flow_nominal*buiDat.dTHeaWat_nominal*60/1000,
    final hTan=(tan.VTan*16/Modelica.Constants.pi)^(1/3),
    final dIns=0.1,
    final nSeg=9,
    final iMid=5,
    tan(T_start=T_start)) "Hot water tank"
    annotation (Placement(transformation(extent={{-20,-20},{0,0}})));
  Buildings.Fluid.MixingVolumes.MixingVolume vol(
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=T_start,
    final prescribedHeatFlowRate=true,
    redeclare package Medium = Medium,
    V=10,
    final mSenFac=1,
    final m_flow_nominal=mSec_flow_nominal,
    nPorts=2) "Volume for heating water distribution circuit" annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={-129,-10})));
  Buildings.HeatTransfer.Sources.PrescribedHeatFlow loaHea
    "Heating load as prescribed heat flow rate"
    annotation (Placement(transformation(extent={{-160,20},{-140,40}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow pumSec(
    redeclare final package Medium = Medium,
    T_start=T_start,
    final addPowerToMedium=false,
    final m_flow_nominal=mSec_flow_nominal,
    final dp_nominal=preDroSec.dp_nominal) "Secondary pump"
    annotation (Placement(transformation(extent={{-40,10},{-60,30}})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroCon(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mCon_flow_nominal,
    dp_nominal=40E3) "Pressure drop of the condenser primary loop" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={130,-40})));
  Buildings.Fluid.FixedResistances.PressureDrop preDroSec(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mSec_flow_nominal,
    dp_nominal=40E3) "Pressure drop of secondary loop" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-50,-40})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter heaToMas(final k=1/
        QHea_flow_nominal*mSec_flow_nominal)
    "Heat flow rate converted to mass flow rate" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-190,70})));
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
    annotation (Placement(transformation(extent={{-240,20},{-220,40}})));
  Buildings.Fluid.Sources.Boundary_pT bou(redeclare final package Medium =
        Medium, nPorts=1)
    "Pressure boundary condition representing expansion vessel (common to HHW and CHW)"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={210,20})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTRet(
    redeclare final package Medium = Medium,
    m_flow_nominal=mSec_flow_nominal,
    T_start=T_start) "Water return temperature" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-90,-40})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter neg(final k=-1)
    "Turns load negative" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-190,30})));
  ThermalGridJBA.Hubs.Controls.RealListParameters reaLisPar(n=3, x=
        mCon_flow_nominal*{0,0.3,1})
    annotation (Placement(transformation(extent={{60,40},{80,60}})));
  Buildings.Controls.OBC.CDL.Reals.LimitSlewRate ramLim(raisingSlewRate=
        mCon_flow_nominal/90)
    annotation (Placement(transformation(extent={{100,40},{120,60}})));
  ThermalGridJBA.Hubs.Controls.TankChargingTwoSpeed tanChaTwoSpe
    annotation (Placement(transformation(extent={{20,40},{40,60}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(p=-3)
    annotation (Placement(transformation(extent={{-20,40},{0,60}})));

equation
  connect(con.port_b,pumPri. port_a)
    annotation (Line(points={{150,0},{150,20},{140,20}},
                                                      color={0,127,255}));
  connect(TSupSet.y,con. T_in) annotation (Line(points={{161,70},{170,70},{170,
          -14},{162,-14}},
                     color={0,0,127}));
  connect(tan.port_aTop,pumPri. port_b) annotation (Line(points={{0,-4},{20,-4},
          {20,20},{120,20}},color={0,127,255}));
  connect(loaHea.port,vol. heatPort)
    annotation (Line(points={{-140,30},{-129,30},{-129,0}}, color={191,0,0}));
  connect(tan.port_bTop,pumSec. port_a) annotation (Line(points={{-20,-4},{-30,
          -4},{-30,20},{-40,20}},
                              color={0,127,255}));
  connect(pumSec.port_b,vol. ports[1]) annotation (Line(points={{-60,20},{-116,20},
          {-116,-9},{-119,-9}}, color={0,127,255}));
  connect(tan.port_bBot,preDroCon. port_a) annotation (Line(points={{0,-16},{20,
          -16},{20,-40},{120,-40}},color={0,127,255}));
  connect(preDroCon.port_b,con. port_a)
    annotation (Line(points={{140,-40},{150,-40},{150,-20}},
                                                          color={0,127,255}));
  connect(tan.port_aBot,preDroSec. port_b) annotation (Line(points={{-20,-16},{-30,
          -16},{-30,-40},{-40,-40}}, color={0,127,255}));
  connect(heaToMas.y,pumSec. m_flow_in)
    annotation (Line(points={{-178,70},{-50,70},{-50,32}}, color={0,0,127}));
  connect(bou.ports[1],pumPri. port_a)
    annotation (Line(points={{200,20},{140,20}},color={0,127,255}));
  connect(preDroSec.port_a,senTRet. port_b)
    annotation (Line(points={{-60,-40},{-80,-40}}, color={0,127,255}));
  connect(senTRet.port_a,vol. ports[2]) annotation (Line(points={{-100,-40},{-114,
          -40},{-114,-11},{-119,-11}}, color={0,127,255}));
  connect(neg.y,loaHea. Q_flow)
    annotation (Line(points={{-178,30},{-160,30}}, color={0,0,127}));
  connect(loa.y[2],neg. u)
    annotation (Line(points={{-219,30},{-202,30}}, color={0,0,127}));
  connect(loa.y[2],heaToMas. u) annotation (Line(points={{-219,30},{-210,30},{-210,
          70},{-202,70}}, color={0,0,127}));
  connect(reaLisPar.y, ramLim.u)
    annotation (Line(points={{82,50},{98,50}}, color={0,0,127}));
  connect(ramLim.y,pumPri. m_flow_in)
    annotation (Line(points={{122,50},{130,50},{130,32}}, color={0,0,127}));
  connect(tanChaTwoSpe.y, reaLisPar.u)
    annotation (Line(points={{42,50},{58,50}}, color={255,127,0}));
  connect(tan.T, tanChaTwoSpe.TTan) annotation (Line(points={{1,-12},{10,-12},{10,
          44},{18,44}}, color={0,0,127}));
  connect(TSupSet.y, addPar.u) annotation (Line(points={{161,70},{170,70},{170,90},
          {-30,90},{-30,50},{-22,50}},                   color={0,0,127}));
  connect(addPar.y, tanChaTwoSpe.TSet) annotation (Line(points={{2,50},{10,50},{
          10,56},{18,56}}, color={0,0,127}));
annotation(experiment(StopTime=864000,Tolerance=1E-6),
    __Dymola_Commands(
      file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Hubs/Controls/Validation/HeatingWaterThreeStatus.mos" "Simulate and plot"));
end HeatingWaterThreeStatus;
