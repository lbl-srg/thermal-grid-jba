within ThermalGridJBA.Hubs.Validation;
model ConnectedETSNoDHW
  "Validation model for ConnectedETS without DHW"
  extends Modelica.Icons.Example;
  package Medium=Buildings.Media.Water
    "Medium model";

  parameter String filNam =
    "modelica://ThermalGridJBA/Resources/Data/Consumptions/B1500.mos";

  ThermalGridJBA.BoundaryConditions.WeatherDataFTMY wea "fTMY weather data reader"
    annotation (Placement(transformation(extent={{-20,60},{0,80}})));
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
    final filNam=filNam,
    allowFlowReversalSer=true)
    annotation (Placement(transformation(extent={{40,-20},{60,0}})));
  Modelica.Blocks.Continuous.Integrator dHHeaWat
    "Cumulative enthalpy difference of heating hot water"
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
  Modelica.Blocks.Continuous.Integrator dHChiWat
    "Cumulative enthalpy difference of chilled water"
    annotation (Placement(transformation(extent={{40,70},{60,90}})));
  Modelica.Blocks.Continuous.Integrator dHHotWat if bui.have_hotWat
    "Cumulative enthalpy difference of domestic hot water"
    annotation (Placement(transformation(extent={{40,10},{60,30}})));
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
  connect(bui.dHHeaWat_flow, dHHeaWat.u) annotation (Line(points={{46,-22},{46,
          -38},{22,-38},{22,50},{38,50}}, color={0,0,127}));
  connect(bui.dHChiWat_flow, dHChiWat.u) annotation (Line(points={{48,-22},{48,
          -40},{20,-40},{20,80},{38,80}}, color={0,0,127}));
  connect(bui.dHHotWat_flow, dHHotWat.u) annotation (Line(points={{44,-22},{44,-36},
          {24,-36},{24,20},{38,20}}, color={0,0,127}));
  connect(wea.weaBus, bui.weaBus) annotation (Line(
      points={{0,70},{10,70},{10,4},{50,4},{50,0}},
      color={255,204,51},
      thickness=0.5));
  annotation (
    Icon(
      coordinateSystem(
        preserveAspectRatio=false)),
    Diagram(
        coordinateSystem(
        preserveAspectRatio=false)),
    __Dymola_Commands(
      file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Hubs/Validation/ConnectedETSNoDHW.mos" "Simulate and plot"),
    experiment(
      StartTime=7776000,
      StopTime=8640000,
      Tolerance=1e-06),
    Documentation(info="<html>
<p>
Validation model for a single building without DHW integration in the ETS.
The model itself does not impose that DHW integration is not present.
This information is determined from the load profile.
The following buildings do not have DHW load and are suitable for this model:
1045, 1345, 1349, 1359, 1500, 1560, 1569, 1676.
</p>
</html>"));
end ConnectedETSNoDHW;
