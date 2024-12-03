within ThermalGridJBA.Data;
record BuildingSetPoints "Set points for the buildings"
  extends Modelica.Icons.Record;

  parameter Modelica.Units.SI.ThermodynamicTemperature TChiWatSup_nominal =
    Modelica.Units.Conversions.from_degF(44)
    "Nominal chilled water supply temperature";
  parameter Modelica.Units.SI.TemperatureDifference dTChiWat_nominal =
    10/9*5 "Nominal chilled water temperature difference";
  final parameter Modelica.Units.SI.ThermodynamicTemperature TChiWatRet_nominal
  = TChiWatSup_nominal + dTChiWat_nominal
    "Nominal chilled water return temperature";
  parameter Modelica.Units.SI.ThermodynamicTemperature THeaWatSup_nominal =
    Modelica.Units.Conversions.from_degF(140)
    "Nominal heating hot water supply temperature";
  parameter Modelica.Units.SI.TemperatureDifference dTHeaWat_nominal =
    20/9*5
    "Nominal heating hot water temperature difference";
  final parameter Modelica.Units.SI.ThermodynamicTemperature THeaWatRet_nominal
  = THeaWatSup_nominal - dTHeaWat_nominal
    "Nominal heating hot water supply temperature";
  parameter Modelica.Units.SI.ThermodynamicTemperature THotWatSupTan_nominal =
    50 + 273.15 "Nominal domestic hot water supply temperature to the tank";
  parameter Modelica.Units.SI.ThermodynamicTemperature THotWatSupFix_nominal =
    40 + 273.15 "Nominal domestic hot water supply temperature to the fixture";
  parameter Modelica.Units.SI.ThermodynamicTemperature TColWat_nominal =
    15 + 273.15 "Nominal domestic cold water temperature";
    annotation(defaultComponentName="datBuiSet",
    Documentation(info="<html>
<p>
Unified set point declarations. All buildings use the same set points.
</p>    
</html>"));
end BuildingSetPoints;
