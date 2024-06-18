within ThermalGridJBA.Hubs.Validation;
model ConnectedETS
  "Validation model for the ConnectedETS component model"
  extends Modelica.Icons.Example;
  package Medium=Buildings.Media.Water
    "Medium model";

  parameter String filNam="modelica://ThermalGridJBA/Resources/Data/Hubs/1380.mos"
    "File name with thermal loads as time series";

  Buildings.Fluid.Sources.Boundary_pT supAmbWat(
    redeclare package Medium = Medium,
    p(displayUnit="bar"),
    use_T_in=true,
    T=280.15,
    nPorts=1) "Ambient water supply"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},rotation=0,origin={-50,-10})));
  Buildings.Fluid.Sources.Boundary_pT sinAmbWat(
    redeclare package Medium = Medium,
    p(displayUnit="bar"),
    nPorts=1) "Sink for ambient water"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},rotation=0,origin={-50,-70})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFlo(
    redeclare package Medium = Medium)
    "Mass flow rate sensor"
    annotation (Placement(transformation(extent={{-20,-20},{0,0}})));
  Modelica.Blocks.Sources.Constant TDisSup(k(
      unit="K",
      displayUnit="degC") = 288.15)
    "District supply temperature"
    annotation (Placement(transformation(extent={{-92,-16},{-72,4}})));
  ThermalGridJBA.Hubs.ConnectedETS bui(
    redeclare package MediumSer = Medium,
    redeclare package MediumBui = Medium,
    allowFlowReversalSer=true,
    THotWatSup_nominal=322.15,
    final filNam=filNam,
    QCoo_flow_nominal=Buildings.DHC.Loads.BaseClasses.getPeakLoad(
      string="#Peak space cooling load",
      filNam=Modelica.Utilities.Files.loadResource(filNam)),
    QHea_flow_nominal=Buildings.DHC.Loads.BaseClasses.getPeakLoad(
      string="#Peak space heating load",
      filNam=Modelica.Utilities.Files.loadResource(filNam)))
    annotation (Placement(transformation(extent={{40,-20},{60,0}})));
equation
  connect(supAmbWat.ports[1], senMasFlo.port_a)
    annotation (Line(points={{-40,-10},{-20,-10}},
                                                 color={0,127,255}));
  connect(TDisSup.y,supAmbWat. T_in)
    annotation (Line(points={{-71,-6},{-62,-6}}, color={0,0,127}));
  connect(senMasFlo.port_b, bui.port_aSerAmb) annotation (Line(points={{0,-10},
          {40,-10}},              color={0,127,255}));
  connect(sinAmbWat.ports[1], bui.port_bSerAmb) annotation (Line(points={{-40,-70},
          {70,-70},{70,-10},{60,-10}}, color={0,127,255}));
  annotation (
    Icon(
      coordinateSystem(
        preserveAspectRatio=false)),
    Diagram(
        coordinateSystem(
        preserveAspectRatio=false)),
    __Dymola_Commands(
      file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Hubs/Validation/ConnectedETS.mos" "Simulate and plot"),
    experiment(
      StopTime=864000,
      Tolerance=1e-06),
    Documentation(info="<html>
<p>
Validation model adapted from
<a href=\"modelica://Buildings.DHC.Loads.Combined.Examples.BuildingTimeSeriesWithETS\">
Buildings.DHC.Loads.Combined.Examples.BuildingTimeSeriesWithETS</a>.
The <code>bui</code> component is replaced.
</p>
</html>"));
end ConnectedETS;
