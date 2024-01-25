within grid.Loads.Combined;
model BuildingTimeSeriesWithETS_chiller
  "Model of a building with loads provided as time series, connected to an ETS"
  extends grid.Loads.Combined.BaseClasses.PartialBuildingWithETS_chiller(
      redeclare
      Buildings.Experimental.DHC.Loads.BaseClasses.Examples.BaseClasses.BuildingTimeSeries
      bui(
      final filNam=filNam,
      T_aHeaWat_nominal=THeaWatSup_nominal,
      T_bHeaWat_nominal=THeaWatSup_nominal - 5,
      T_aChiWat_nominal=TChiWatSup_nominal,
      T_bChiWat_nominal=TChiWatSup_nominal + 5), ets(
      QChiWat_flow_nominal=QCoo_flow_nominal,
      QHeaWat_flow_nominal=QHea_flow_nominal,
      QHotWat_flow_nominal=QHot_flow_nominal));
  parameter String filNam
    "Library path of the file with thermal loads as time series";
  final parameter Modelica.Units.SI.HeatFlowRate QCoo_flow_nominal(
    max=-Modelica.Constants.eps)=
    bui.facMul * bui.QCoo_flow_nominal
    "Space cooling design load (<=0)"
    annotation (Dialog(group="Design parameter"));
  final parameter Modelica.Units.SI.HeatFlowRate QHea_flow_nominal(
    min=Modelica.Constants.eps)=
    bui.facMul * bui.QHea_flow_nominal
    "Space heating design load (>=0)"
    annotation (Dialog(group="Design parameter"));
  final parameter Modelica.Units.SI.HeatFlowRate QHot_flow_nominal(
    min=Modelica.Constants.eps)=
    bui.facMul * Buildings.Experimental.DHC.Loads.BaseClasses.getPeakLoad(
      string="#Peak water heating load",
      filNam=Modelica.Utilities.Files.loadResource(filNam))
    "Hot water design load (>=0)"
    annotation (Dialog(group="Design parameter"));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter loaHeaNor(
    k=1/QHea_flow_nominal) "Normalized heating load"
    annotation (Placement(transformation(extent={{-200,-110},{-180,-90}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold enaHeaCoo[2](each t=1e-4)
    "Threshold comparison to enable heating and cooling"
    annotation (Placement(transformation(extent={{-110,-130},{-90,-110}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter loaCooNor(k=1/
        QCoo_flow_nominal) "Normalized cooling load"
    annotation (Placement(transformation(extent={{-200,-150},{-180,-130}})));
equation
  connect(enaHeaCoo[1].y, ets.uHea) annotation (Line(points={{-88,-120},{-40,-120},
          {-40,-48},{-34,-48}},       color={255,0,255}));
  connect(enaHeaCoo[2].y, ets.uCoo) annotation (Line(points={{-88,-120},{-40,-120},
          {-40,-54},{-34,-54}},       color={255,0,255}));
  connect(loaHeaNor.y, enaHeaCoo[1].u) annotation (Line(points={{-178,-100},{
          -120,-100},{-120,-120},{-112,-120}}, color={0,0,127}));
  connect(loaCooNor.y, enaHeaCoo[2].u) annotation (Line(points={{-178,-140},{
          -120,-140},{-120,-120},{-112,-120}}, color={0,0,127}));
  connect(bui.QReqHea_flow, loaHeaNor.u) annotation (Line(points={{20,4},{20,-6},
          {-218,-6},{-218,-100},{-202,-100}}, color={0,0,127}));
  connect(bui.QReqCoo_flow, loaCooNor.u) annotation (Line(points={{24,4},{24,-4},
          {-220,-4},{-220,-140},{-202,-140}}, color={0,0,127}));
  connect(loaHeaNor.y, resTHeaWatSup.u) annotation (Line(points={{-178,-100},{
          -120,-100},{-120,-40},{-112,-40}},  color={0,0,127}));
  annotation (
    Documentation(info="<html>
<p>
This model is composed of a heat pump based energy transfer station model
<a href=\"modelica://Buildings.Experimental.DHC.EnergyTransferStations.Combined.HeatPumpHeatExchanger\">
Buildings.Experimental.DHC.EnergyTransferStations.Combined.HeatPumpHeatExchanger</a>
connected to a simplified building model where the space heating, cooling
and hot water loads are provided as time series.
</p>
<h4>Scaling</h4>
<p>
The parameter <code>bui.facMul</code> is the multiplier factor
applied to the building loads that are provided as time series.
It is used to represent multiple identical buildings served by
a unique energy transfer station.
The parameter <code>facMul</code> is the multiplier factor
applied to the whole system composed of the building(s) and the
energy transfer station.
It is used to represent multiple identical ETSs served by
the DHC system.
So, if for instance the overall heating and cooling efficiency is
equal to <i>1</i>, then the load on the district loop
is the load provided as time series multiplied by <i>facMul * bui.facMul</i>.
</p>
<p>
Note that the parameters <code>QCoo_flow_nominal</code>, <code>QHea_flow_nominal</code>
and <code>QHot_flow_nominal</code> are the <i>ETS</i> design values. They include
the building loads multiplier factor <code>bui.facMul</code> but not
the building and ETS multiplier factor <code>facMul</code>.
</p>
</html>", revisions="<html>
<ul>
<li>
November 21, 2022, by David Blum:<br/>
Change <code>bui.facMulHea</code> and <code>bui.facMulCoo</code> to be default.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/2302\">
issue 2302</a>.
</li>
<li>
February 23, 2021, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-300,-300},{
            300,300}})));
end BuildingTimeSeriesWithETS_chiller;
