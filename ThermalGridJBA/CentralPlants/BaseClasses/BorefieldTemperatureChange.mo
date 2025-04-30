within ThermalGridJBA.CentralPlants.BaseClasses;
block BorefieldTemperatureChange
  "Model that approximates the average temperature difference in a borefield"
  extends Modelica.Blocks.Icons.Block;
  Modelica.Blocks.Interfaces.RealInput E(
     final unit="J",
     displayUnit="Wh")
     "Energy exchanged with the borefield"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  final parameter ThermalGridJBA.Data.SoilData soiDat "Soil data"
    annotation (Placement(transformation(extent={{60,60},{80,80}})));
  parameter Modelica.Units.SI.Temperature T_start "Initial temperature of soil";
  parameter Modelica.Units.SI.Volume V
    "Volume over which the average temperature increase is computed";

  Modelica.Blocks.Interfaces.RealOutput T(
    final unit="K",
    displayUnit="degC")
    "Temperature of soil"
    annotation (Placement(transformation(extent={{100,-70},{120,-50}})));

  Modelica.Blocks.Interfaces.RealOutput dTSoi
    "Temperature difference of soil"
    annotation (Placement(transformation(extent={{100,50},{120,70}})));
equation
  dTSoi = E/(V*soiDat.dSoi*soiDat.cSoi);
  T = T_start + dTSoi;

  annotation (
  defaultComponentName="dTSoi",
  Documentation(info="<html>
<p>
Block that approximates the temperature change in the soil, under the
assumption that the temperature uniformly increases over the whole
volume <code>V</code>.
</p>
</html>", revisions="<html>
<ul>
<li>
April 18, 2025, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
  Icon(
    graphics={
        Text(
          extent={{62,28},{-58,-22}},
          textColor={255,255,255},
          textString=DynamicSelect("", String(T-273.15, format=".1f"))),
        Rectangle(
          extent={{-78,0},{80,-86}}, lineColor={0,0,0},
          fillPattern=FillPattern.Solid,
          fillColor=DynamicSelect({0, 127, 255},
          min(1, max(0, (1-(T-273.15)/20)))*{28,108,200}+
          min(1, max(0, ((T-273.15)/20)))*{255,0,0})),
        Text(
          extent={{96,70},{134,94}},
          textColor={0,0,127},
          textString="dT"),
        Text(
          extent={{96,-48},{134,-24}},
          textColor={0,0,127},
          textString="T"),
        Text(
          extent={{-150,20},{-112,44}},
          textColor={0,0,127},
          textString="E")}));
end BorefieldTemperatureChange;
