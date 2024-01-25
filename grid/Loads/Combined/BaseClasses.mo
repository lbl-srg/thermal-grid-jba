within grid.Loads.Combined;
package BaseClasses "Package with base classes that are used by multiple models"
  extends Modelica.Icons.BasesPackage;

  model PartialBuildingWithETS_chiller
    "Partial model with ETS model and partial building model"
    extends
      Buildings.Experimental.DHC.Loads.BaseClasses.PartialBuildingWithPartialETS(
      nPorts_heaWat=1,
      nPorts_chiWat=1,
      redeclare Buildings.Experimental.DHC.EnergyTransferStations.Combined.ChillerBorefield ets(
      hex(show_T=true),
        WSE(show_T=true),
        conCon=Buildings.Experimental.DHC.EnergyTransferStations.Types.ConnectionConfiguration.Pump,
        dp1Hex_nominal=20E3,
        dp2Hex_nominal=20E3,
        QHex_flow_nominal=abs(QChiWat_flow_nominal),
        T_a1Hex_nominal=282.15,
        T_b1Hex_nominal=278.15,
        T_a2Hex_nominal=276.15,
        T_b2Hex_nominal=280.15,
        have_WSE=true,
        QWSE_flow_nominal=QChiWat_flow_nominal,
        dpCon_nominal=15E3,
        dpEva_nominal=15E3,
        final datChi=datChi,
        T_a1WSE_nominal=281.15,
        T_b1WSE_nominal=286.15,
        T_a2WSE_nominal=288.15,
        T_b2WSE_nominal=283.15));
    parameter Modelica.Units.SI.TemperatureDifference dT_nominal(min=0) = 4
      "Water temperature drop/increase accross load and source-side HX (always positive)"
      annotation (Dialog(group="ETS model parameters"));
    parameter Modelica.Units.SI.Temperature TChiWatSup_nominal=18 + 273.15
      "Chilled water supply temperature"
      annotation (Dialog(group="ETS model parameters"));
    parameter Modelica.Units.SI.Temperature THeaWatSup_nominal=38 + 273.15
      "Heating water supply temperature"
      annotation (Dialog(group="ETS model parameters"));
    parameter Modelica.Units.SI.Pressure dp_nominal=50000
      "Pressure difference at nominal flow rate (for each flow leg)"
      annotation (Dialog(group="ETS model parameters"));
    parameter Real COPHeaWat_nominal(final unit="1") = 4.0
      "COP of heat pump for heating water production"
      annotation (Dialog(group="ETS model parameters"));
    parameter Real COPHotWat_nominal(final unit="1") = 2.3
      "COP of heat pump for hot water production"
      annotation (Dialog(group="ETS model parameters", enable=have_hotWat));
    // IO CONNECTORS
    Buildings.Controls.OBC.CDL.Interfaces.RealInput TChiWatSupSet(
      final unit="K",
      displayUnit="degC")
      "Chilled water supply temperature set point"
      annotation (Placement(
          transformation(
          extent={{-20,-20},{20,20}},
          rotation=0,
          origin={-320,80}), iconTransformation(
          extent={{-20,-20},{20,20}},
          rotation=0,
          origin={-120,50})));
    Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaWatSupMaxSet(
      final unit="K",
      displayUnit="degC")
      "Heating water supply temperature set point - Maximum value"
      annotation (
        Placement(transformation(
          extent={{-20,-20},{20,20}},
          rotation=0,
          origin={-320,120}), iconTransformation(
          extent={{-20,-20},{20,20}},
          rotation=0,
          origin={-120,70})));
    Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaWatSupMinSet(
      final unit="K",
      displayUnit="degC")
      "Heating water supply temperature set point - Minimum value"
      annotation (
        Placement(transformation(
          extent={{-20,-20},{20,20}},
          rotation=0,
          origin={-320,160}), iconTransformation(
          extent={{-20,-20},{20,20}},
          rotation=0,
          origin={-120,90})));
    // COMPONENTS
    Buildings.Controls.OBC.CDL.Reals.Line resTHeaWatSup
      "HW supply temperature reset"
      annotation (Placement(transformation(extent={{-110,-50},{-90,-30}})));
    Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(k=0)
      "Zero"
      annotation (Placement(transformation(extent={{-180,-30},{-160,-10}})));
    Buildings.Controls.OBC.CDL.Reals.Sources.Constant one(k=1)
      "One"
      annotation (Placement(transformation(extent={{-180,-70},{-160,-50}})));
    Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter mulPPumETS(u(final
          unit="W"), final k=facMul) if have_pum "Scaling"
      annotation (Placement(transformation(extent={{270,-10},{290,10}})));
    Buildings.Controls.OBC.CDL.Interfaces.RealOutput PPumETS(
      final unit="W") if have_pum
      "ETS pump power"
      annotation (Placement(
          transformation(extent={{300,-20},{340,20}}),iconTransformation(
          extent={{-20,-20},{20,20}},
          rotation=90,
          origin={70,120})));
    parameter Buildings.Fluid.Chillers.Data.ElectricEIR.Generic datChi(
      QEva_flow_nominal=QChiWat_flow_nominal,
      COP_nominal=3.8,
      PLRMax=1,
      PLRMinUnl=0.3,
      PLRMin=0.3,
      etaMotor=1,
      mEva_flow_nominal=abs(QChiWat_flow_nominal)/4186/4,
      mCon_flow_nominal=abs(QChiWat_flow_nominal)*(1+1/datChi.COP_nominal)/4186/8,
      TEvaLvg_nominal=276.15,
      capFunT={1.72,0.02,0,-0.02,0,0},
      EIRFunT={0.28,-0.02,0,0.02,0,0},
      EIRFunPLR={0.1,0.9,0},
      TEvaLvgMin=276.15,
      TEvaLvgMax=288.15,
      TConEnt_nominal=315.15,
      TConEntMin=291.15,
      TConEntMax=328.15)
      "Chiller performance data"
      annotation (Placement(transformation(extent={{-250,260},{-230,280}})));
  equation
    connect(TChiWatSupSet, ets.TChiWatSupSet) annotation (Line(points={{-320,80},{
            -132,80},{-132,-66},{-34,-66}},color={0,0,127}));
    connect(resTHeaWatSup.y, ets.THeaWatSupSet) annotation (Line(points={{-88,-40},
            {-60,-40},{-60,-60},{-34,-60}}, color={0,0,127}));
    connect(THeaWatSupMaxSet, resTHeaWatSup.f2) annotation (Line(points={{-320,120},
            {-280,120},{-280,-48},{-112,-48}}, color={0,0,127}));
    connect(THeaWatSupMinSet, resTHeaWatSup.f1) annotation (Line(points={{-320,160},
            {-276,160},{-276,-36},{-112,-36}}, color={0,0,127}));
    connect(one.y, resTHeaWatSup.x2) annotation (Line(points={{-158,-60},{-126,-60},
            {-126,-44},{-112,-44}}, color={0,0,127}));
    connect(zer.y, resTHeaWatSup.x1) annotation (Line(points={{-158,-20},{-116,-20},
            {-116,-32},{-112,-32}}, color={0,0,127}));
    connect(mulPPumETS.y, PPumETS)
      annotation (Line(points={{292,0},{320,0}},   color={0,0,127}));
    connect(ets.PPum, mulPPumETS.u) annotation (Line(points={{34,-60},{240,-60},{
            240,0},{268,0}},   color={0,0,127}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)),
      Documentation(info="<html>
<p>
This model is composed of a heat pump based energy transfer station model 
<a href=\"modelica://Buildings.Experimental.DHC.EnergyTransferStations.Combined.HeatPumpHeatExchanger\">
Buildings.Experimental.DHC.EnergyTransferStations.Combined.HeatPumpHeatExchanger</a>
connected to a repleacable building load model. 
</p>
</html>",   revisions="<html>
<ul>
<li>
February 23, 2021, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
  end PartialBuildingWithETS_chiller;
annotation (Documentation(info="<html>
<p>
This package contains base classes that are used to construct the classes in
<a href=\"modelica://Buildings.Experimental.DHC.Loads.Combined\">
Buildings.Experimental.DHC.Loads.Combined</a>.
</p>
</html>"));
end BaseClasses;
