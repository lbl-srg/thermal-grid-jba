within ThermalGridJBA.CentralPlants;
model CentralPlant "Central plant"

  package MediumW = Buildings.Media.Water "Water";

  parameter Integer nBorSec = 33
    "Number of borefield sectors. It includes 2 modules and the number should be divisible by 3";
  parameter Real TLooMin(
    unit="K",
    displayUnit="degC")=283.65
    "Design minimum district loop temperature";
  parameter Real TLooMax(
    unit="K",
    displayUnit="degC")=297.15
    "Design maximum district loop temperature";
  parameter Real TPlaHeaSet(
    unit="K",
    displayUnit="degC")=TLooMin
    "Design plant heating setpoint temperature";
  parameter Real TPlaCooSet(
    unit="K",
    displayUnit="degC")=TLooMax
    "Design plant cooling setpoint temperature";

  parameter Real mWat_flow_nominal(unit="kg/s")
    "Nominal water mass flow rate to each generation module";
  parameter Real dpValve_nominal(unit="Pa")=6000
    "Nominal pressure drop of fully open 2-way valve";

  // Heat exchanger parameters
  parameter Real dpHex_nominal(unit="Pa")=10000
    "Pressure difference across heat exchanger"
    annotation (Dialog(group="Heat exchanger"));
  parameter Real mHexGly_flow_nominal(unit="kg/s")
    "Nominal glycol mass flow rate for heat exchanger"
    annotation (Dialog(group="Heat exchanger"));
  // Heat exchanger parameters
  parameter Real dpDryCoo_nominal(unit="Pa")=10000
    "Nominal pressure drop of dry cooler"
    annotation (Dialog(group="Dry cooler"));
  parameter Real mDryCoo_flow_nominal(unit="kg/s")=
    mHexGly_flow_nominal + mHpGly_flow_nominal
    "Nominal glycol mass flow rate for dry cooler"
    annotation (Dialog(group="Dry cooler"));
  // Heat pump parameters
  parameter Real mHeaPumWat_flow_nominal(unit="kg/s")
    "Heat pump nominal water mass flow rate"
    annotation (Dialog(group="Heat pump"));
  parameter Real mHeaPumWat_flow_min(unit="kg/s")
    "Heat pump minimum water mass flow rate"
    annotation (Dialog(group="Heat pump"));
  parameter Real mHpGly_flow_nominal(unit="kg/s")
    "Nominal glycol mass flow rate for heat pump"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumHea_flow_nominal(unit="W")
    "Nominal heating capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConHea_nominal(unit="K")=TLooMin + TApp
    "Nominal temperature of the heated fluid in heating mode"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaHea_nominal(unit="K")
    "Nominal temperature of evaporator for heat pump design during heating"
    annotation (Dialog(group="Heat pump"));
  parameter Real QHeaPumCoo_flow_nominal(unit="W")
    "Nominal cooling capacity"
    annotation (Dialog(group="Heat pump"));
  parameter Real TConCoo_nominal(unit="K")
    "Nominal temperature of condenser for heat pump design during cooling"
    annotation (Dialog(group="Heat pump"));
  parameter Real TEvaCoo_nominal(unit="K")=TLooMax + TApp
    "Nominal temperature of the heated fluid in cooling mode"
    annotation (Dialog(group="Heat pump"));

  parameter Real staDowDel(
    unit="s")=3600
    "Minimum stage down delay, to avoid quickly staging down"
    annotation (Dialog(tab="Controls"));
  parameter Real TAppSet(unit="K")=2
    "Dry cooler approch setpoint"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real TApp(unit="K")=4
    "Approach temperature for checking if the dry cooler should be enabled"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
  parameter Real minFanSpe(unit="1")=0.1
    "Minimum dry cooler fan speed"
    annotation (Dialog(tab="Controls", group="Dry cooler"));
//   parameter Real TCooSet(unit="K")=TLooMin
//     "Heat pump tracking temperature setpoint in cooling mode"
//     annotation (Dialog(tab="Controls", group="Heat pump"));
//   parameter Real THeaSet(unit="K")=TLooMax
//     "Heat pump tracking temperature setpoint in heating mode"
//     annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TConInMin(unit="K", displayUnit="degC")
    "Minimum condenser inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real TEvaInMax(unit="K", displayUnit="degC")
    "Maximum evaporator inlet temperature"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real offTim(unit="s")=12*3600
     "Heat pump off time due to the low compressor speed"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real holOnTim(unit="s")=1800
    "Heat pump hold on time"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real holOffTim(unit="s")=1800
    "Heat pump hold off time"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real minComSpe(unit="1")=0.2
    "Minimum heat pump compressor speed"
    annotation (Dialog(tab="Controls", group="Heat pump"));
  parameter Real minHeaPumSpeHol=120
    "Threshold time for checking if the compressor has been in the minimum speed"
     annotation (Dialog(tab="Controls", group="Heat pump"));

  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow from the district"
    annotation (Placement(transformation(extent={{-250,-10},{-230,10}}),
      iconTransformation(extent={{-110,-10},{-90,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TPlaOut(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC")
    "Central plant outlet water temperature"
    annotation (Placement(transformation(extent={{-280,120},{-240,160}}),
        iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum
    "District loop pump speed"
    annotation (Placement(transformation(extent={{-280,70},{-240,110}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixAve(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Average temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-280,-100},{-240,-60}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TLooMaxMea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Maximum temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-280,-160},{-240,-120}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TLooMinMea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Minimum temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-280,-220},{-240,-180}}),
        iconTransformation(extent={{-140,-140},{-100,-100}})));

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-280,40},{-240,80}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumCirPum(quantity="Power",
      final unit="W")
    "Electrical power consumed by circulation pump"
    annotation (Placement(transformation(extent={{320,-190},{360,-150}}),
        iconTransformation(extent={{100,-160},{140,-120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumWat(quantity="Power",
      final unit="W")
    "Electrical power consumed by heat pump waterside pump"
    annotation (Placement(transformation(extent={{320,-160},{360,-120}}),
        iconTransformation(extent={{100,-140},{140,-100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QBorPer_flow(unit="W")
    "Heat flow from borefield perimeter to water"
    annotation (Placement(transformation(extent={{320,-220},{360,-180}}),
        iconTransformation(extent={{100,-180},{140,-140}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PCom(quantity="Power",
      final unit="W")
    "Electric power consumed by compressor"
    annotation (Placement(transformation(extent={{320,-130},{360,-90}}),
        iconTransformation(extent={{100,-120},{140,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHeaPumGly(quantity="Power",
      final unit="W")
    "Electrical power consumed by glycol pump of heat pump"
    annotation (Placement(transformation(extent={{320,-100},{360,-60}}),
        iconTransformation(extent={{100,-40},{140,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumHexGly(quantity="Power",
      final unit="W")
    "Electrical power consumed by the glycol pump of heat exchanger"
    annotation (Placement(transformation(extent={{320,130},{360,170}}),
        iconTransformation(extent={{100,10},{140,50}})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumBorFiePer(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by pump for borefield perimeter"
    annotation (Placement(transformation(extent={{320,90},{360,130}}),
        iconTransformation(extent={{100,-60},{140,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumBorFieCen(
    final quantity="Power",
    final unit="W")
    "Electrical power consumed by pump for borefield center"
    annotation (Placement(transformation(extent={{320,60},{360,100}}),
        iconTransformation(extent={{100,-80},{140,-40}})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumDryCoo(quantity="Power",
      final unit="W")
    "Electrical power consumed by dry cool pump"
    annotation (Placement(transformation(extent={{320,160},{360,200}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, dollor per kWh"
    annotation (Placement(transformation(extent={{320,220},{360,260}}),
        iconTransformation(extent={{100,70},{140,110}})));

  Generations gen(
    final TLooMin=TLooMin,
    final TLooMax=TLooMax,
    final TPlaHeaSet=TPlaHeaSet,
    final TPlaCooSet=TPlaCooSet,
    final mWat_flow_nominal=mWat_flow_nominal,
    mBorFiePer_flow_nominal=borFie.mPer_flow_nominal,
    mBorFieCen_flow_nominal=borFie.mCen_flow_nominal,
    dpBorFiePer_nominal=borFie.dp_nominal,
    dpBorFieCen_nominal=borFie.dp_nominal,
    final mHeaPumWat_flow_nominal=mHeaPumWat_flow_nominal,
    final mHeaPumWat_flow_min=mHeaPumWat_flow_min,
    final mHexGly_flow_nominal=mHexGly_flow_nominal,
    final mHpGly_flow_nominal=mHpGly_flow_nominal,
    final mDryCoo_flow_nominal=mDryCoo_flow_nominal,
    final dpHex_nominal=dpHex_nominal,
    final dpValve_nominal=dpValve_nominal,
    final dpDryCoo_nominal=dpDryCoo_nominal,
    final QHeaPumHea_flow_nominal=QHeaPumHea_flow_nominal,
    final TConHea_nominal=TConHea_nominal,
    final TEvaHea_nominal=TEvaHea_nominal,
    final QHeaPumCoo_flow_nominal=QHeaPumCoo_flow_nominal,
    final TConCoo_nominal=TConCoo_nominal,
    final TEvaCoo_nominal=TEvaCoo_nominal,
    final staDowDel=staDowDel,
    final TAppSet=TAppSet,
    final TApp=TApp,
    final minFanSpe=minFanSpe,
    final TConInMin=TConInMin,
    final TEvaInMax=TEvaInMax,
    final offTim=offTim,
    holOnTim=holOnTim,
    holOffTim=holOffTim,
    final minComSpe=minComSpe,
    final minHeaPumSpeHol=minHeaPumSpeHol,
    kHeaPum=0.1,
    TiHeaPum=200,
    kVal=0.1,
    TiVal=200,
    kFan=0.1,
    TiFan=200) "Cooling and heating generation devices"
    annotation (Placement(transformation(extent={{-160,-10},{-140,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = MediumW)
    "Fluid connector for waterflow to the district"
    annotation (Placement(transformation(extent={{312,-10},{332,10}}),
      iconTransformation(extent={{90,-10},{110,10}})));

  Modelica.Blocks.Sources.RealExpression heaPumHea(y=gen.heaPum.Q1_flow)
    "Heat pump heat flow"
    annotation (Placement(transformation(extent={{-100,210},{-80,230}})));
  Modelica.Blocks.Sources.RealExpression hexHea(y=gen.hex.Q2_flow)
    "Heat exchanger heat flow"
    annotation (Placement(transformation(extent={{-100,190},{-80,210}})));
  Modelica.Blocks.Continuous.Integrator EHeaPumEne(initType=Modelica.Blocks.Types.Init.InitialState)
    "Heat pump energy"
    annotation (Placement(transformation(extent={{-60,210},{-40,230}})));
  Modelica.Blocks.Continuous.Integrator EHexEne(initType=Modelica.Blocks.Types.Init.InitialState)
    "Heat exchanger energy"
    annotation (Placement(transformation(extent={{20,190},{40,210}})));

  BaseClasses.Borefield borFie                                   "Borefield"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput QBorCen_flow(unit="W")
    "Heat flow from borefield center to water" annotation (Placement(
        transformation(extent={{320,-250},{360,-210}}), iconTransformation(
          extent={{100,-200},{140,-160}})));

  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(k=1/100)
    "Convert cent to dollor"
    annotation (Placement(transformation(extent={{140,230},{160,250}})));
equation

  connect(uDisPum, gen.uDisPum) annotation (Line(points={{-260,90},{-180,90},{-180,
          5},{-162,5}},      color={0,0,127}));
  connect(TMixAve, gen.TMixAve) annotation (Line(points={{-260,-80},{-190,-80},{
          -190,-4.2},{-162,-4.2}},
                        color={0,0,127}));
  connect(TDryBul, gen.TDryBul) annotation (Line(points={{-260,60},{-186,60},{-186,
          1.8},{-162,1.8}},    color={0,0,127}));
  connect(heaPumHea.y, EHeaPumEne.u)
    annotation (Line(points={{-79,220},{-62,220}}, color={0,0,127}));
  connect(hexHea.y, EHexEne.u)
    annotation (Line(points={{-79,200},{18,200}}, color={0,0,127}));

  connect(gen.PPumDryCoo, PPumDryCoo) annotation (Line(points={{-138,5},{-120,5},
          {-120,180},{340,180}}, color={0,0,127}));
  connect(gen.PPumHexGly, PPumHexGly) annotation (Line(points={{-138,3},{-110,3},
          {-110,150},{340,150}}, color={0,0,127}));
  connect(port_a, gen.port_a)
    annotation (Line(points={{-240,0},{-200,0},{-200,-16},{-160,-16}},
                                                 color={0,127,255}));
  connect(gen.PPumHeaPumGly, PPumHeaPumGly) annotation (Line(points={{-138,1},{-100,
          1},{-100,-80},{340,-80}},          color={0,0,127}));
  connect(gen.PCom, PCom) annotation (Line(points={{-138,-5},{-108,-5},{-108,-110},
          {340,-110}},       color={0,0,127}));
  connect(gen.PPumHeaPumWat, PPumHeaPumWat) annotation (Line(points={{-138,-7},{
          -114,-7},{-114,-140},{340,-140}},  color={0,0,127}));
  connect(gen.PPumCirPum, PPumCirPum) annotation (Line(points={{-138,-9},{-120,-9},
          {-120,-170},{340,-170}},     color={0,0,127}));
  connect(gen.portBorFiePer_b, borFie.portPer_a) annotation (Line(points={{-158,
          10},{-158,20},{-60,20},{-60,8},{40,8}}, color={0,127,255}));
  connect(borFie.portPer_b, gen.portBorFiePer_a) annotation (Line(points={{60,8},
          {70,8},{70,24},{-154,24},{-154,10}}, color={0,127,255}));
  connect(gen.portBorFieCen_b, borFie.portCen_a) annotation (Line(points={{-146,
          10},{-146,18},{-62,18},{-62,-8},{40,-8}}, color={0,127,255}));
  connect(borFie.portCen_b, gen.portBorFieCen_a) annotation (Line(points={{59.8,
          -8},{74,-8},{74,26},{-142,26},{-142,10}}, color={0,127,255}));
  connect(gen.port_b, port_b) annotation (Line(points={{-160,-20},{-170,-20},{-170,
          -32},{280,-32},{280,0},{322,0}}, color={0,127,255}));
  connect(borFie.QPer_flow, QBorPer_flow) annotation (Line(points={{62,4},{100,4},
          {100,-200},{340,-200}}, color={0,0,127}));
  connect(borFie.QCen_flow, QBorCen_flow) annotation (Line(points={{62,1},{96,1},
          {96,-230},{340,-230}}, color={0,0,127}));
  connect(gen.PPumBorFiePer, PPumBorFiePer) annotation (Line(points={{-138,-1},
          {-104,-1},{-104,110},{340,110}}, color={0,0,127}));
  connect(gen.PPumBorFieCen, PPumBorFieCen) annotation (Line(points={{-138,-3},
          {-102,-3},{-102,80},{340,80}}, color={0,0,127}));
  connect(TLooMaxMea, gen.TLooMaxMea) annotation (Line(points={{-260,-140},{-186,
          -140},{-186,-8.2},{-162,-8.2}}, color={0,0,127}));
  connect(TLooMinMea, gen.TLooMinMea) annotation (Line(points={{-260,-200},{-182,
          -200},{-182,-12.2},{-162,-12.2}}, color={0,0,127}));
  connect(TPlaOut, gen.TPlaOut) annotation (Line(points={{-260,140},{-174,140},{
          -174,8},{-162,8}}, color={0,0,127}));
  connect(gen.yEleRat, gai1.u) annotation (Line(points={{-138,9},{-130,9},{-130,
          240},{138,240}}, color={0,0,127}));
  connect(gai1.y, yEleRat)
    annotation (Line(points={{162,240},{340,240}}, color={0,0,127}));
  annotation (defaultComponentName="cenPla",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={
                                Rectangle(
        extent={{-100,-200},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,-8},{0,8}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{0,-8},{100,8}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-40,-20},{40,60}},
          lineColor={27,0,55},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255}),
        Rectangle(
          extent={{-62,-44},{62,-190}},
          lineColor={0,0,0},
          fillColor={234,210,210},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-52,-50},{-24,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-14,-50},{14,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{24,-50},{52,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-14,-152},{14,-180}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{24,-152},{52,-180}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-52,-152},{-24,-180}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-14,-120},{14,-148}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{24,-120},{52,-148}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-52,-120},{-24,-148}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-14,-88},{14,-116}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{24,-88},{52,-116}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-52,-88},{-24,-116}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid)}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-240,-280},{320,280}})));
end CentralPlant;
