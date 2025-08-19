within ThermalGridJBA.Hubs.Validation;
model AirToWater "Load profile with AWHP plant template"
  extends Modelica.Icons.Example;
  replaceable package Medium=Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Main medium (common for CHW and HW)";
  parameter String filNam =
    "modelica://ThermalGridJBA/Resources/Data/Consumptions/All_futu.mos"
    "File name with thermal loads as time series";
  parameter Boolean have_chiWat=true
    "Set to true if the plant provides CHW"
    annotation (Evaluate=true,
    Dialog(group="Configuration"));
  inner parameter
    Buildings.Templates.Plants.HeatPumps.Validation.UserProject.Data.AllSystems
    datAll(pla(final cfg=pla.cfg, hp(
        capHeaHp_nominal=QHea_flow_nominal + QHot_flow_nominal,
        THeaWatSupHp_nominal=333.15,
        capCooHp_nominal=abs(QCoo_flow_nominal),
        TChiWatSupHp_nominal=279.85)))
                                   "Plant parameters"
    annotation (Placement(transformation(extent={{160,160},{180,180}})));
  parameter Boolean allowFlowReversal=true
    "= true to allow flow reversal, false restricts to design direction (port_a -> port_b)"
    annotation (Dialog(tab="Assumptions"),
    Evaluate=true);
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation (Evaluate=true,
    Dialog(tab="Dynamics",group="Conservation equations"));

  parameter Modelica.Units.SI.HeatFlowRate QCoo_flow_nominal(
    max=-Modelica.Constants.eps)=
      Buildings.DHC.Loads.BaseClasses.getPeakLoad(
        string="#Peak space cooling load",
        filNam=Modelica.Utilities.Files.loadResource(filNam))
    "Design cooling heat flow rate (<=0)"
    annotation (Dialog(group="Design parameter"));
  parameter Modelica.Units.SI.HeatFlowRate QHea_flow_nominal(
    min=Modelica.Constants.eps)=
      Buildings.DHC.Loads.BaseClasses.getPeakLoad(
        string="#Peak space heating load",
        filNam=Modelica.Utilities.Files.loadResource(filNam))
    "Design heating heat flow rate (>=0)"
    annotation (Dialog(group="Design parameter"));
  parameter Modelica.Units.SI.HeatFlowRate QHot_flow_nominal(
    min=0)=Buildings.DHC.Loads.BaseClasses.getPeakLoad(
          string="#Peak water heating load",
          filNam=Modelica.Utilities.Files.loadResource(filNam))
    "Design heating heat flow rate (>=0)";

  ThermalGridJBA.BoundaryConditions.WeatherData weaDat(final weaFil=
        ThermalGridJBA.Hubs.BaseClasses.getWeatherFileName(
        string="#Weather file name",
        filNam=Modelica.Utilities.Files.loadResource(filNam)))
    "Outdoor conditions" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-170,-60})));
  Buildings.Fluid.HeatExchangers.SensibleCooler_T loaHeaWat(
    redeclare final package Medium = Medium,
    final m_flow_nominal=pla.mHeaWat_flow_nominal,
    show_T=true,
    final dp_nominal=0,
    final energyDynamics=energyDynamics,
    tau=300,
    QMin_flow=-pla.capHea_nominal)
    "HW system approximated by prescribed return temperature"
    annotation (Placement(transformation(extent={{70,-130},{90,-110}})));
  Buildings.Fluid.HeatExchangers.Heater_T loaChiWat(
    redeclare final package Medium = Medium,
    final m_flow_nominal=pla.mChiWat_flow_nominal,
    show_T=true,
    final dp_nominal=0,
    final energyDynamics=energyDynamics,
    tau=300,
    QMax_flow=pla.capCoo_nominal) if have_chiWat
    "CHW system system approximated by prescribed return temperature"
    annotation (Placement(transformation(extent={{70,-70},{90,-50}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valDisHeaWat(
    redeclare final package Medium = Medium,
    m_flow_nominal=pla.mHeaWat_flow_nominal,
    dpValve_nominal=3E4,
    dpFixed_nominal=datAll.pla.ctl.dpHeaWatRemSet_max[1] - 3E4)
    "Distribution system approximated by variable flow resistance"
    annotation (Placement(transformation(extent={{110,-130},{130,-110}})));
  Buildings.Fluid.Actuators.Valves.TwoWayEqualPercentage valDisChiWat(
    redeclare final package Medium = Medium,
    m_flow_nominal=pla.mChiWat_flow_nominal,
    dpValve_nominal=3E4,
    dpFixed_nominal=datAll.pla.ctl.dpChiWatRemSet_max[1] - 3E4) if have_chiWat
    "Distribution system approximated by variable flow resistance"
    annotation (Placement(transformation(extent={{110,-70},{130,-50}})));
  Buildings.Templates.Plants.HeatPumps.AirToWater pla(
    redeclare final package MediumHeaWat=Medium,
    have_hrc_select=true,
    final dat=datAll.pla,
    final have_chiWat=have_chiWat,
    nHp=3,
    typPumHeaWatPri_select1=Buildings.Templates.Plants.HeatPumps.Types.PumpsPrimary.Constant,
    final allowFlowReversal=allowFlowReversal,
    linearized=true,
    show_T=true,
    ctl(
      nAirHan=1,
      nEquZon=0),
    is_dpBalYPumSetCal=true)
    "Heat pump plant"
    annotation (Placement(transformation(extent={{-80,-120},{-40,-80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TDum(
    k=293.15,
    y(final unit="K",
      displayUnit="degC"))
    "Placeholder signal for request generator"
    annotation (Placement(transformation(extent={{-180,150},{-160,170}})));
  Buildings.Fluid.Sensors.RelativePressure dpHeaWatRem[1](redeclare each final
      package Medium = Medium)
    "HW differential pressure at one remote location" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={40,-140})));
  Buildings.Fluid.Sensors.RelativePressure dpChiWatRem[1](redeclare each final
      package Medium = Medium) if have_chiWat
    "CHW differential pressure at one remote location" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={40,-80})));
  Buildings.Controls.OBC.ASHRAE.G36.AHUs.MultiZone.VAV.SetPoints.PlantRequests reqPlaRes(
    final heaCoi=Buildings.Controls.OBC.ASHRAE.G36.Types.HeatingCoil.WaterBased,
    final cooCoi=if have_chiWat then Buildings.Controls.OBC.ASHRAE.G36.Types.CoolingCoil.WaterBased
      else Buildings.Controls.OBC.ASHRAE.G36.Types.CoolingCoil.None)
    "Plant and reset request"
    annotation (Placement(transformation(extent={{90,122},{70,142}})));
  Buildings.Templates.AirHandlersFans.Interfaces.Bus busAirHan
    "AHU control bus" annotation (Placement(transformation(extent={{-60,120},{-20,
            160}}), iconTransformation(extent={{-340,-140},{-300,-100}})));
  Buildings.Templates.Plants.HeatPumps.Interfaces.Bus busPla
    "Plant control bus" annotation (Placement(transformation(extent={{-100,-60},
            {-60,-20}}), iconTransformation(extent={{-370,-70},{-330,-30}})));
  Buildings.Controls.OBC.CDL.Reals.PID ctlEquZon[if have_chiWat then 2 else 1](
    each k=0.1,
    each Ti=60,
    each final reverseActing=true)
    "Zone equipment controller"
    annotation (Placement(transformation(extent={{70,90},{90,110}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter norFlo[if have_chiWat
    then 2 else 1](
    k=if have_chiWat then {1 / pla.mHeaWat_flow_nominal, 1 / pla.mChiWat_flow_nominal}
      else {1 / pla.mHeaWat_flow_nominal})
    "Normalize flow rate"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},rotation=90,
      origin={180,0})));
  Buildings.Fluid.Sensors.MassFlowRate mChiWat_flow(redeclare final package
      Medium = Medium) if have_chiWat "CHW mass flow rate" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={160,-80})));
  Buildings.Fluid.Sensors.MassFlowRate mHeaWat_flow(redeclare final package
      Medium = Medium) "HW mass flow rate" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={160,-140})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter TChiWatRet(
    p=pla.TChiWatRet_nominal - pla.TChiWatSup_nominal)
    if have_chiWat
    "Prescribed CHW return temperature"
    annotation (Placement(transformation(extent={{-130,52},{-110,72}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter THeaWatRet(
    p=pla.THeaWatRet_nominal - pla.THeaWatSup_nominal)
    "Prescribed HW return temperature"
    annotation (Placement(transformation(extent={{-130,12},{-110,32}})));
  Buildings.Controls.OBC.CDL.Reals.Max max2
    "Limit prescribed HWRT"
    annotation (Placement(transformation(extent={{-90,12},{-70,32}})));
  Buildings.Controls.OBC.CDL.Reals.Min min1
    if have_chiWat
    "Limit prescribed CHWRT"
    annotation (Placement(transformation(extent={{-90,52},{-70,72}})));
  Buildings.Controls.OBC.CDL.Integers.Multiply mulInt[4]
    "Importance multiplier"
    annotation (Placement(transformation(extent={{0,130},{-20,150}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant cst[4](
    each k=10)
    "Constant"
    annotation (Placement(transformation(extent={{40,170},{20,190}})));
  Buildings.Fluid.FixedResistances.PressureDrop pipHeaWat(
    redeclare final package Medium=Medium,
    final m_flow_nominal=pla.mHeaWat_flow_nominal,
    final dp_nominal=Buildings.Templates.Data.Defaults.dpHeaWatLocSet_max - max(datAll.pla.ctl.dpHeaWatRemSet_max))
    "Piping"
    annotation (Placement(transformation(extent={{10,-170},{-10,-150}})));
  Buildings.Fluid.FixedResistances.PressureDrop pipChiWat(
    redeclare final package Medium=Medium,
    final m_flow_nominal=pla.mChiWat_flow_nominal,
    final dp_nominal=Buildings.Templates.Data.Defaults.dpChiWatLocSet_max - max(datAll.pla.ctl.dpChiWatRemSet_max))
    if have_chiWat
    "Piping"
    annotation (Placement(transformation(extent={{10,-110},{-10,-90}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(
    k=293.15)
    "Constant limiting prescribed return temperature"
    annotation (Placement(transformation(extent={{-180,32},{-160,52}})));
  Buildings.Templates.Plants.Controls.Utilities.PlaceholderInteger ph[2](each final
            have_inp=have_chiWat, each final u_internal=0) "Placeholder value"
    annotation (Placement(transformation(extent={{40,134},{20,154}})));
  Modelica.Blocks.Sources.CombiTimeTable loa(
    tableOnFile=true,
    tableName="tab1",
    fileName=Modelica.Utilities.Files.loadResource(filNam),
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    y(each unit="W"),
    offset={0,0,0},
    columns={2,3,4},
    smoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1)
    "Reader for thermal loads (y[1] is cooling load, y[2] is space heating load, y[3] is domestic water heat load)"
    annotation (Placement(transformation(extent={{-180,100},{-160,120}})));
  Buildings.Controls.OBC.CDL.Reals.Add addHea
    "Add heating hot water load and domestic hot water load together"
    annotation (Placement(transformation(extent={{-130,80},{-110,100}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiCoo(k=1/
        QCoo_flow_nominal)
    "Normalise cooling load"
    annotation (Placement(transformation(extent={{-90,118},{-70,138}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiHea(k=1/(
        QHea_flow_nominal + QHot_flow_nominal))
    "Normalise heating load, including space heating and domestic hot water, if present"
    annotation (Placement(transformation(extent={{-90,80},{-70,100}})));
equation
  if have_chiWat then
    connect(mulInt[3].y, busAirHan.reqResChiWat)
      annotation (Line(points={{-22,140},{-40,140}},color={255,127,0}));
    connect(mulInt[4].y, busAirHan.reqPlaChiWat)
      annotation (Line(points={{-22,140},{-40,140}},color={255,127,0}));
  end if;
  connect(weaDat.weaBus, pla.busWea)
    annotation (Line(points={{-160,-60},{-60,-60},{-60,-80}},color={255,204,51},thickness=0.5));
  connect(pla.port_bChiWat, loaChiWat.port_a)
    annotation (Line(points={{-40,-96},{-20,-96},{-20,-60},{70,-60}},color={0,127,255}));
  connect(loaChiWat.port_b, valDisChiWat.port_a)
    annotation (Line(points={{90,-60},{110,-60}},color={0,127,255}));
  connect(loaHeaWat.port_b, valDisHeaWat.port_a)
    annotation (Line(points={{90,-120},{110,-120}},color={0,127,255}));
  connect(pla.port_bHeaWat, loaHeaWat.port_a)
    annotation (Line(points={{-40,-110},{-20,-110},{-20,-120},{70,-120}},color={0,127,255}));
  connect(loaChiWat.port_a, dpChiWatRem[1].port_a)
    annotation (Line(points={{70,-60},{40,-60},{40,-70}},color={0,127,255}));
  connect(dpHeaWatRem[1].port_a, loaHeaWat.port_a)
    annotation (Line(points={{40,-130},{40,-120},{70,-120}},color={0,127,255}));
  connect(TDum.y, reqPlaRes.TAirSup)
    annotation (Line(points={{-158,160},{100,160},{100,140},{92,140}},color={0,0,127}));
  connect(TDum.y, reqPlaRes.TAirSupSet)
    annotation (Line(points={{-158,160},{100,160},{100,135},{92,135}},color={0,0,127}));
  connect(busAirHan, pla.busAirHan[1])
    annotation (Line(points={{-40,140},{-40,-82}},color={255,204,51},thickness=0.5));
  connect(pla.bus, busPla)
    annotation (Line(points={{-80,-82},{-80,-40}},color={255,204,51},thickness=0.5));
  connect(valDisChiWat.y_actual, reqPlaRes.uCooCoiSet)
    annotation (Line(points={{125,-53},{140,-53},{140,129},{92,129}},color={0,0,127}));
  connect(valDisHeaWat.y_actual, reqPlaRes.uHeaCoiSet)
    annotation (Line(points={{125,-113},{136,-113},{136,124},{92,124}},color={0,0,127}));
  connect(valDisChiWat.port_b, mChiWat_flow.port_a)
    annotation (Line(points={{130,-60},{160,-60},{160,-70}},color={0,127,255}));
  connect(mChiWat_flow.port_b, dpChiWatRem[1].port_b)
    annotation (Line(points={{160,-90},{160,-100},{40,-100},{40,-90}},color={0,127,255}));
  connect(valDisHeaWat.port_b, mHeaWat_flow.port_a)
    annotation (Line(points={{130,-120},{160,-120},{160,-130}},color={0,127,255}));
  connect(mHeaWat_flow.port_b, dpHeaWatRem[1].port_b)
    annotation (Line(points={{160,-150},{160,-160},{40,-160},{40,-150}},color={0,127,255}));
  connect(mHeaWat_flow.m_flow, norFlo[1].u)
    annotation (Line(points={{171,-140},{180,-140},{180,-12}},color={0,0,127}));
  connect(mChiWat_flow.m_flow, norFlo[2].u)
    annotation (Line(points={{171,-80},{180,-80},{180,-12}},color={0,0,127}));
  connect(norFlo.y, ctlEquZon.u_m)
    annotation (Line(points={{180,12},{180,60},{80,60},{80,88}},color={0,0,127}));
  connect(ctlEquZon[2].y, valDisChiWat.y)
    annotation (Line(points={{92,100},{100,100},{100,-40},{120,-40},{120,-48}},
      color={0,0,127}));
  connect(ctlEquZon[1].y, valDisHeaWat.y)
    annotation (Line(points={{92,100},{100,100},{100,-104},{120,-104},{120,-108}},
      color={0,0,127}));
  connect(busPla.THeaWatPriSup, THeaWatRet.u)
    annotation (Line(points={{-80,-40},{-140,-40},{-140,22},{-132,22}},color={255,204,51},thickness=0.5));
  connect(busPla.TChiWatPriSup, TChiWatRet.u)
    annotation (Line(points={{-80,-40},{-140,-40},{-140,62},{-132,62}},color={255,204,51},thickness=0.5));
  connect(TChiWatRet.y, min1.u1)
    annotation (Line(points={{-108,62},{-100,62},{-100,68},{-92,68}},color={0,0,127}));
  connect(min1.y, loaChiWat.TSet)
    annotation (Line(points={{-68,62},{62,62},{62,-52},{68,-52}},color={0,0,127}));
  connect(max2.y, loaHeaWat.TSet)
    annotation (Line(points={{-68,22},{60,22},{60,-112},{68,-112}},color={0,0,127}));
  connect(cst.y, mulInt.u1)
    annotation (Line(points={{18,180},{6,180},{6,146},{2,146}},color={255,127,0}));
  connect(mulInt[1].y, busAirHan.reqResHeaWat)
    annotation (Line(points={{-22,140},{-40,140}},color={255,127,0}));
  connect(mulInt[2].y, busAirHan.reqPlaHeaWat)
    annotation (Line(points={{-22,140},{-40,140}},color={255,127,0}));
  connect(pipHeaWat.port_b, pla.port_aHeaWat)
    annotation (Line(points={{-10,-160},{-30,-160},{-30,-118},{-40,-118}},color={0,127,255}));
  connect(pipChiWat.port_b, pla.port_aChiWat)
    annotation (Line(points={{-10,-100},{-20,-100},{-20,-104},{-40,-104}},color={0,127,255}));
  connect(mChiWat_flow.port_b, pipChiWat.port_a)
    annotation (Line(points={{160,-90},{160,-100},{10,-100}},color={0,127,255}));
  connect(mHeaWat_flow.port_b, pipHeaWat.port_a)
    annotation (Line(points={{160,-150},{160,-160},{10,-160}},color={0,127,255}));
  connect(con.y, min1.u2)
    annotation (Line(points={{-158,42},{-100,42},{-100,56},{-92,56}},color={0,0,127}));
  connect(con.y, max2.u1)
    annotation (Line(points={{-158,42},{-100,42},{-100,28},{-92,28}},color={0,0,127}));
  connect(THeaWatRet.y, max2.u2)
    annotation (Line(points={{-108,22},{-100,22},{-100,16},{-92,16}},color={0,0,127}));
  connect(reqPlaRes.yChiWatResReq, ph[1].u)
    annotation (Line(points={{68,140},{50,140},{50,144},{42,144}},color={255,127,0}));
  connect(reqPlaRes.yChiPlaReq, ph[2].u)
    annotation (Line(points={{68,135},{50,135},{50,144},{42,144}},color={255,127,0}));
  connect(reqPlaRes.yHotWatResReq, mulInt[1].u2)
    annotation (Line(points={{68,129},{12,129},{12,134},{2,134}},color={255,127,0}));
  connect(reqPlaRes.yHotWatPlaReq, mulInt[2].u2)
    annotation (Line(points={{68,124},{12,124},{12,134},{2,134}},color={255,127,0}));
  connect(ph[1].y, mulInt[3].u2)
    annotation (Line(points={{18,144},{12,144},{12,134},{2,134}},color={255,127,0}));
  connect(ph[2].y, mulInt[4].u2)
    annotation (Line(points={{18,144},{12,144},{12,134},{2,134}},color={255,127,0}));
  connect(dpChiWatRem.p_rel, busPla.dpChiWatRem)
    annotation (Line(points={{31,-80},{20.5,-80},{20.5,-40},{-80,-40}},color={0,0,127}),
      Text(string="%second",index=1,extent={{-6,3},{-6,3}},horizontalAlignment=TextAlignment.Right));
  connect(dpHeaWatRem.p_rel, busPla.dpHeaWatRem)
    annotation (Line(points={{31,-140},{18,-140},{18,-42},{-80,-42},{-80,-40}},
      color={0,0,127}),Text(string="%second",index=1,extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(loa.y[2], addHea.u1) annotation (Line(points={{-159,110},{-140,110},{-140,
          96},{-132,96}}, color={0,0,127}));
  connect(loa.y[3], addHea.u2) annotation (Line(points={{-159,110},{-140,110},{-140,
          84},{-132,84}}, color={0,0,127}));
  connect(gaiCoo.y, ctlEquZon[2].u_s) annotation (Line(points={{-68,128},{-60,128},
          {-60,100},{68,100}}, color={0,0,127}));
  connect(gaiHea.y, ctlEquZon[1].u_s) annotation (Line(points={{-68,90},{-60,90},
          {-60,100},{68,100}}, color={0,0,127}));
  connect(addHea.y, gaiHea.u)
    annotation (Line(points={{-108,90},{-92,90}}, color={0,0,127}));
  connect(loa.y[1], gaiCoo.u) annotation (Line(points={{-159,110},{-140,110},{-140,
          128},{-92,128}}, color={0,0,127}));
  annotation (
    __Dymola_Commands(
      file=
        "modelica://ThermalGridJBA/Resources/Scripts/Dymola/Hubs/Validation/AirToWater.mos"
        "Simulate and plot"),
    experiment(
      Tolerance=1e-6,
      StartTime=17844800,
      StopTime=19094400),
    Documentation(
      info="<html>
<p>
This model validates
<a href=\"modelica://Buildings.Templates.Plants.HeatPumps.AirToWater\">
Buildings.Templates.Plants.HeatPumps.AirToWater</a>
by simulating a <i>24</i>-hour period with overlapping heating and
cooling loads.
The heating loads reach their peak value first, the cooling loads reach it last.
</p>
<p>
Three equally sized heat pumps are modeled, which can all be lead/lag alternated.
A heat recovery chiller is included (<code>pla.have_hrc_select=true</code>) 
and connected to the HW and CHW return pipes (sidestream integration).
A unique aggregated load is modeled on each loop by means of a cooling or heating
component controlled to maintain a constant <i>&Delta;T</i>
and a modulating valve controlled to track a prescribed flow rate.
An importance multiplier of <i>10</i> is applied to the plant requests
and reset requests generated from the valve position.
</p>
<p>
The user can toggle the top-level parameter <code>have_chiWat</code>
to switch between a cooling and heating system (the default setting)
to a heating-only system.
Advanced equipment and control options can be modified via the parameter
dialog of the plant component.
</p>
<p>
Simulating this model shows how the plant responds to a varying load by
</p>
<ul>
<li>
staging or unstaging the AWHPs and associated primary pumps,
</li>
<li>
rotating lead/lag alternate equipment to ensure even wear,
</li>
<li>
resetting the supply temperature and remote differential pressure
in both the CHW and HW loops based on the valve position,
</li>
<li>
staging and controlling the secondary pumps to meet the
remote differential pressure setpoint.
</li>
</ul>
<h4>Details</h4>
<p>
By default, all valves within the plant are modeled considering a linear
variation of the pressure drop with the flow rate (<code>pla.linearized=true</code>),
as opposed to the quadratic relationship usually considered for
a turbulent flow regime.
By limiting the size of the system of nonlinear equations, this setting
reduces the risk of solver failure and the time to solution for testing
various plant configurations.
</p>
<h4>ESTCP Adaptation</h4>
<p>
Adapted from
<code>Buildings.Templates.Plants.HeatPumps.Validation.AirToWater</code>.
</p>
<p>
A load profile is used to replaced the load ratio input in the original model.
The plant is resized accordingly.
</p>
</html>",
      revisions="<html>
<ul>
<li>
May 31, 2024, by Antoine Gautier:<br/>
Added sidestream HRC and refactored the model after updating the HP plant template.
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/3808\">#3808</a>.
</li>
<li>
March 29, 2024, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(
      coordinateSystem(
        extent={{-200,-200},{200,200}})));
end AirToWater;
