within ThermalGridJBA.Hubs.BaseClasses;
partial model PartialConnectedETS
  extends Buildings.DHC.Loads.BaseClasses.PartialBuildingWithPartialETS(
    redeclare Buildings.DHC.Loads.BaseClasses.BuildingTimeSeries bui(
      final filNam=filNam,
      final T_aHeaWat_nominal=datBuiSet.THeaWatSup_nominal,
      final T_bHeaWat_nominal=datBuiSet.THeaWatRet_nominal,
      final T_aChiWat_nominal=datBuiSet.TChiWatSup_nominal,
      final T_bChiWat_nominal=datBuiSet.TChiWatRet_nominal,
      final have_hotWat=have_hotWat),
    nPorts_heaWat=1,
    nPorts_chiWat=1);

  parameter String filNam
    "File name for the load profile";
  parameter ThermalGridJBA.Data.BuildingSetPoints datBuiSet
    "Building set points" annotation (Placement(
      transformation(extent={{20,140},{40,160}})));

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
  parameter Buildings.Fluid.Chillers.Data.ElectricEIR.Generic datChi(
    QEva_flow_nominal=QCoo_flow_nominal,
    COP_nominal=3,
    PLRMax=1,
    PLRMinUnl=0.3,
    PLRMin=0.3,
    etaMotor=1,
    mEva_flow_nominal=abs(QCoo_flow_nominal)/5/4186,
    mCon_flow_nominal=QHea_flow_nominal/5/4186,
    TEvaLvg_nominal=datBuiSet.TChiWatSup_nominal,
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
      datBuiSet.TChiWatRet_nominal "Chilled water return temperature";
  final parameter Modelica.Units.SI.Temperature THeaWatRet_nominal=
      datBuiSet.THeaWatRet_nominal "Heating water return temperature";
  parameter Modelica.Units.SI.Temperature TDisWatMin=6 + 273.15
    "District water minimum temperature" annotation (Dialog(group="ETS model parameters"));
  parameter Modelica.Units.SI.Temperature TDisWatMax=17 + 273.15
    "District water maximum temperature" annotation (Dialog(group="ETS model parameters"));
  parameter Modelica.Units.SI.TemperatureDifference dT_nominal(min=0) = 4
    "Water temperature drop/increase accross load and source-side HX (always positive)"
    annotation (Dialog(group="ETS model parameters"));
  parameter Modelica.Units.SI.Temperature TChiWatSup_nominal =
    datBuiSet.TChiWatSup_nominal "Chilled water supply temperature"
    annotation (Dialog(group="ETS model parameters"));
  parameter Modelica.Units.SI.Temperature THeaWatSup_nominal =
    datBuiSet.THeaWatSup_nominal "Heating water supply temperature"
    annotation (Dialog(group="ETS model parameters"));
  parameter Modelica.Units.SI.Temperature THotWatSup_nominal =
    datBuiSet.THotWatSupFix_nominal "Domestic hot water supply temperature to fixtures"
    annotation (Dialog(group="ETS model parameters", enable=have_hotWat));
  parameter Modelica.Units.SI.Temperature TColWat_nominal =
    datBuiSet.TColWat_nominal
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

  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter loaCooNor(
    k=1/QCoo_flow_nominal) "Normalized cooling load"
    annotation (Placement(transformation(extent={{-140,-170},{-120,-150}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold uCoo(
    final t=0.01,
    final h=0.005)
    "Enable cooling"
    annotation (Placement(transformation(extent={{-100,-170},{-80,-150}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant THeaWatSupSet(
    final k=datBuiSet.THeaWatSup_nominal,
    y(final unit="K", displayUnit="degC"))
    "Heating water supply temperature set point"
    annotation (Placement(transformation(extent={{-100,-30},{-80,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TChiWatSupSet(
    final k=datBuiSet.TChiWatSup_nominal,
    y(final unit="K", displayUnit="degC"))
    "Chilled water supply temperature set point"
    annotation (Placement(transformation(extent={{-100,-70},{-80,-50}})));
equation
  connect(loaCooNor.y, uCoo.u)
    annotation (Line(points={{-118,-160},{-102,-160}}, color={0,0,127}));
  connect(uCoo.y, ets.uCoo) annotation (Line(points={{-78,-160},{-40,-160},{-40,
          -50},{-34,-50}}, color={255,0,255}));
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
