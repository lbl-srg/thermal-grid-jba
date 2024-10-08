within ThermalGridJBA.Hubs.BaseClasses;
partial model PartialConnectedETS
  extends Buildings.DHC.Loads.BaseClasses.PartialBuildingWithPartialETS(
    redeclare Buildings.DHC.Loads.BaseClasses.BuildingTimeSeries bui(
      final filNam=datBui.filNam,
      final T_aHeaWat_nominal=datBui.THeaWatSup_nominal,
      final T_bHeaWat_nominal=datBui.THeaWatRet_nominal,
      final T_aChiWat_nominal=datBui.TChiWatSup_nominal,
      final T_bChiWat_nominal=datBui.TChiWatRet_nominal,
      final have_hotWat=datBui.have_hotWat),
    nPorts_heaWat=1,
    nPorts_chiWat=1);

  replaceable parameter ThermalGridJBA.Data.GenericConsumer datBui
    "Building data" annotation (Placement(
      transformation(extent={{20,140},{40,160}})), choicesAllMatching=true);

  parameter Modelica.Units.SI.HeatFlowRate QCoo_flow_nominal(
    max=-Modelica.Constants.eps)=
      Buildings.DHC.Loads.BaseClasses.getPeakLoad(
        string="#Peak space cooling load",
        filNam=Modelica.Utilities.Files.loadResource(datBui.filNam))
    "Design cooling heat flow rate (<=0)"
    annotation (Dialog(group="Design parameter"));
  parameter Modelica.Units.SI.HeatFlowRate QHea_flow_nominal(
    min=Modelica.Constants.eps)=
      Buildings.DHC.Loads.BaseClasses.getPeakLoad(
        string="#Peak space heating load",
        filNam=Modelica.Utilities.Files.loadResource(datBui.filNam))
    "Design heating heat flow rate (>=0)"
    annotation (Dialog(group="Design parameter"));
  parameter Buildings.Fluid.Chillers.Data.ElectricEIR.Generic datChi(
    QEva_flow_nominal=QCoo_flow_nominal,
    COP_nominal=3,
    PLRMax=1,
    PLRMinUnl=0.3,
    PLRMin=0.3,
    etaMotor=1,
    mEva_flow_nominal=abs(QCoo_flow_nominal)/5/4186,
    mCon_flow_nominal=QHea_flow_nominal/5/4186,
    TEvaLvg_nominal=277.15,
    capFunT={1.72,0.02,0,-0.02,0,0},
    EIRFunT={0.28,-0.02,0,0.02,0,0},
    EIRFunPLR={0.1,0.9,0},
    TEvaLvgMin=277.15,
    TEvaLvgMax=288.15,
    TConEnt_nominal=313.15,
    TConEntMin=298.15,
    TConEntMax=328.15) "Chiller performance data"
    annotation (Placement(transformation(extent={{20,180},{40,200}})));
  final parameter Modelica.Units.SI.Temperature TChiWatRet_nominal=
      TChiWatSup_nominal + dT_nominal "Chilled water return temperature";
  final parameter Modelica.Units.SI.Temperature THeaWatRet_nominal=
      THeaWatSup_nominal - dT_nominal "Heating water return temperature";
  parameter Modelica.Units.SI.Temperature TDisWatMin=6 + 273.15
    "District water minimum temperature" annotation (Dialog(group="ETS model parameters"));
  parameter Modelica.Units.SI.Temperature TDisWatMax=17 + 273.15
    "District water maximum temperature" annotation (Dialog(group="ETS model parameters"));
  parameter Modelica.Units.SI.TemperatureDifference dT_nominal(min=0) = 4
    "Water temperature drop/increase accross load and source-side HX (always positive)"
    annotation (Dialog(group="ETS model parameters"));
  parameter Modelica.Units.SI.Temperature TChiWatSup_nominal=18 + 273.15
    "Chilled water supply temperature"
    annotation (Dialog(group="ETS model parameters"));
  parameter Modelica.Units.SI.Temperature THeaWatSup_nominal=38 + 273.15
    "Heating water supply temperature"
    annotation (Dialog(group="ETS model parameters"));
  parameter Modelica.Units.SI.Temperature THotWatSup_nominal=63 + 273.15
    "Domestic hot water supply temperature to fixtures"
    annotation (Dialog(group="ETS model parameters", enable=have_hotWat));
  parameter Modelica.Units.SI.Temperature TColWat_nominal=288.15
    "Cold water temperature (for hot water production)"
    annotation (Dialog(group="ETS model parameters", enable=have_hotWat));
  parameter Modelica.Units.SI.Pressure dp_nominal(displayUnit="Pa")=50000
    "Pressure difference at nominal flow rate (for each flow leg)"
    annotation (Dialog(group="ETS model parameters"));
  parameter Real COPHeaWat_nominal(final unit="1") = 4.0
    "COP of heat pump for heating water production"
    annotation (Dialog(group="ETS model parameters"));
  parameter Real COPHotWat_nominal(final unit="1") = 2.3
    "COP of heat pump for hot water production";

  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter loaHeaNor(
    k=1/QHea_flow_nominal) "Normalized heating load"
    annotation (Placement(transformation(extent={{-140,-130},{-120,-110}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter loaCooNor(
    k=1/QCoo_flow_nominal) "Normalized cooling load"
    annotation (Placement(transformation(extent={{-140,-170},{-120,-150}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold uHea(
    final t=0.01,
    final h=0.005) "Enable heating"
    annotation (Placement(transformation(extent={{-100,-130},{-80,-110}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold uCoo(
    final t=0.01,
    final h=0.005)
    "Enable cooling"
    annotation (Placement(transformation(extent={{-100,-170},{-80,-150}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant THeaWatSupSet(
    final k=datBui.THeaWatSup_nominal,
    y(final unit="K", displayUnit="degC"))
    "Heating water supply temperature set point"
    annotation (Placement(transformation(extent={{-100,-30},{-80,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TChiWatSupSet(
    final k=datBui.TChiWatSup_nominal,
    y(final unit="K", displayUnit="degC"))
    "Chilled water supply temperature set point"
    annotation (Placement(transformation(extent={{-100,-70},{-80,-50}})));
equation
  connect(loaHeaNor.y, uHea.u)
    annotation (Line(points={{-118,-120},{-102,-120}}, color={0,0,127}));
  connect(loaCooNor.y, uCoo.u)
    annotation (Line(points={{-118,-160},{-102,-160}}, color={0,0,127}));
  connect(uHea.y, ets.uHea) annotation (Line(points={{-78,-120},{-50,-120},{-50,
          -46},{-34,-46}}, color={255,0,255}));
  connect(uCoo.y, ets.uCoo) annotation (Line(points={{-78,-160},{-40,-160},{-40,
          -50},{-34,-50}}, color={255,0,255}));
  connect(bui.QReqHea_flow, loaHeaNor.u) annotation (Line(points={{20,4},{20,-6},
          {76,-6},{76,-138},{-150,-138},{-150,-120},{-142,-120}}, color={0,0,
          127}));
  connect(loaCooNor.u, bui.QReqCoo_flow) annotation (Line(points={{-142,-160},{
          -150,-160},{-150,-142},{80,-142},{80,-4},{24,-4},{24,4}}, color={0,0,
          127}));
  connect(THeaWatSupSet.y, ets.THeaWatSupSet) annotation (Line(points={{-78,-20},
          {-64,-20},{-64,-58},{-34,-58}}, color={0,0,127}));
  connect(ets.TChiWatSupSet, TChiWatSupSet.y) annotation (Line(points={{-34,-62},
          {-68,-62},{-68,-60},{-78,-60}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
        defaultComponentName = "bui");
end PartialConnectedETS;
