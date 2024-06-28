within ThermalGridJBA.Hubs.BaseClasses;
model BTS "Adapted BTS validation model with key parameters exposed"
  extends Buildings.DHC.Loads.BaseClasses.Examples.CouplingTimeSeries(
    bui(
      final filNam=filNam,
      final T_aHeaWat_nominal=THeaWatSup_nominal,
      final T_bHeaWat_nominal=THeaWatSup_nominal-dTHeaWat_nominal,
      final T_aChiWat_nominal=TChiWatSup_nominal,
      final T_bChiWat_nominal=TChiWatSup_nominal+dTChiWat_nominal));

  parameter String filNam="modelica://ThermalGridJBA/Resources/Data/Hubs/Individual/1380.mos"
    "File name for the load profile";
  parameter Modelica.Units.SI.ThermodynamicTemperature TChiWatSup_nominal =
    4.7 + 273.15
    "Nominal chilled water supply temperature";
  parameter Modelica.Units.SI.TemperatureDifference dTChiWat_nominal =
    5.6
    "Nominal chilled water temperature difference";
  parameter Modelica.Units.SI.ThermodynamicTemperature THeaWatSup_nominal =
    82 + 273.15
    "Nominal heating hot water supply temperature";
  parameter Modelica.Units.SI.TemperatureDifference dTHeaWat_nominal =
    22
    "Nominal heating hot water temperature difference";
    annotation(experiment(
      StopTime=864000,
      Tolerance=1e-06),
      Documentation(
      info="<html>
<p>
This model is adapted from
<code>Buildings.DHC.Loads.BaseClasses.Examples.CouplingTimeSeries</code>
for the convenience of using JBA building data.
</p>
</html>"));
end BTS;
