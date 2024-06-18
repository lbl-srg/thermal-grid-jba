within ThermalGridJBA.Hubs;
model ConnectedETS "Load connected to the network via ETS"
  extends Buildings.DHC.Loads.Combined.BaseClasses.PartialBuildingWithETS(
    redeclare Buildings.DHC.Loads.BaseClasses.BuildingTimeSeries bui(
      filNam=filNam,
      have_hotWat=true,
      T_aHeaWat_nominal=THeaWatSup_nominal,
      T_bHeaWat_nominal=THeaWatRet_nominal,
      T_aChiWat_nominal=TChiWatSup_nominal,
      T_bChiWat_nominal=TChiWatRet_nominal),
    redeclare Buildings.DHC.ETS.Combined.ChillerBorefield ets(
      //redeclare package MediumSer = MediumSer,
      //redeclare package MediumBui = MediumBui,
      QChiWat_flow_nominal=QCoo_flow_nominal,
      QHeaWat_flow_nominal=QHea_flow_nominal,
      dp1Hex_nominal=40E3,
      dp2Hex_nominal=40E3,
      QHex_flow_nominal=-QCoo_flow_nominal,
      T_a1Hex_nominal=284.15,
      T_b1Hex_nominal=279.15,
      T_a2Hex_nominal=277.15,
      T_b2Hex_nominal=282.15,
      QWSE_flow_nominal=QCoo_flow_nominal,
      dpCon_nominal=40E3,
      dpEva_nominal=40E3,
      datChi=datChi));
      //nPorts_bChiWat=1,
      //nPorts_bHeaWat=1,
      //nPorts_aHeaWat=1,
      //nPorts_aChiWat=1

  parameter String filNam=""
    "File name with thermal loads as time series";
  parameter Modelica.Units.SI.HeatFlowRate QCoo_flow_nominal(max=-Modelica.Constants.eps)=
       -1e6 "Design cooling heat flow rate (<=0)"
    annotation (Dialog(group="Design parameter"));
  parameter Modelica.Units.SI.HeatFlowRate QHea_flow_nominal(min=Modelica.Constants.eps)=
       abs(QCoo_flow_nominal)*(1 + 1/datChi.COP_nominal)
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

  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter loaHeaNor(k=1/
        QHea_flow_nominal) "Normalized heating load"
    annotation (Placement(transformation(extent={{-140,-130},{-120,-110}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter loaCooNor(k=1/
        QCoo_flow_nominal) "Normalized cooling load"
    annotation (Placement(transformation(extent={{-140,-170},{-120,-150}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold uHea(final t=0.01, final h=
        0.005)
    "Enable heating"
    annotation (Placement(transformation(extent={{-100,-130},{-80,-110}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold uCoo(final t=0.01, final h=
        0.005)
    "Enable cooling"
    annotation (Placement(transformation(extent={{-100,-170},{-80,-150}})));
equation
  connect(loaHeaNor.y, uHea.u)
    annotation (Line(points={{-118,-120},{-102,-120}}, color={0,0,127}));
  connect(loaCooNor.y, uCoo.u)
    annotation (Line(points={{-118,-160},{-102,-160}}, color={0,0,127}));
  connect(uHea.y, ets.uHea) annotation (Line(points={{-78,-120},{-50,-120},{-50,
          -48},{-34,-48}}, color={255,0,255}));
  connect(uCoo.y, ets.uCoo) annotation (Line(points={{-78,-160},{-40,-160},{-40,
          -54},{-34,-54}}, color={255,0,255}));
  connect(bui.QReqHea_flow, loaHeaNor.u) annotation (Line(points={{20,4},{20,-6},
          {76,-6},{76,-138},{-150,-138},{-150,-120},{-142,-120}}, color={0,0,
          127}));
  connect(loaCooNor.u, bui.QReqCoo_flow) annotation (Line(points={{-142,-160},{
          -150,-160},{-150,-142},{80,-142},{80,-4},{24,-4},{24,4}}, color={0,0,
          127}));
  connect(loaHeaNor.y, resTHeaWatSup.u) annotation (Line(points={{-118,-120},{
          -114,-120},{-114,-40},{-112,-40}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
        defaultComponentName = "bui");
end ConnectedETS;
