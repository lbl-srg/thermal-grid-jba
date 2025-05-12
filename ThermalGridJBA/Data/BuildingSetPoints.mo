within ThermalGridJBA.Data;
record BuildingSetPoints "Set points for the buildings"
  extends Modelica.Icons.Record;

  parameter Real facTerUniSizHea[5](
     each final unit="1") = {1, 1.3, 1.3, 1, 1}
    "Factor to increase design capacity of space terminal units for heating";
  parameter Modelica.Units.SI.ThermodynamicTemperature TChiWatSup_nominal = 7+273.15
    "Nominal chilled water supply temperature"
    annotation (Dialog(group="Chilled water"));
  parameter Modelica.Units.SI.TemperatureDifference dTChiWat_nominal = 5
    "Nominal chilled water temperature difference"
    annotation (Dialog(group="Chilled water"));
  final parameter Modelica.Units.SI.ThermodynamicTemperature TChiWatRet_nominal = TChiWatSup_nominal + dTChiWat_nominal
    "Nominal chilled water return temperature";
  final parameter Modelica.Units.SI.ThermodynamicTemperature THeaRooSet = 273.15+20.5
    "Room air temperature set point for heating system at which control is at zero demand";
  final parameter Modelica.Units.SI.ThermodynamicTemperature TCooRooSet = 273.15+23.5
    "Room air temperature set point for cooling system at which control is at zero demand";
  parameter Modelica.Units.SI.ThermodynamicTemperature tabChiWatRes[2,2](each displayUnit="degC")=
    [TCooRooSet-1, 12+273.15;
     TCooRooSet, TChiWatSup_nominal]
    "Chilled water supply temperature reset schedule"
    annotation (Dialog(group="Chilled water"));

  parameter Modelica.Units.SI.ThermodynamicTemperature THeaWatSup_nominal(displayUnit="degC") = 60+273.15
    "Nominal heating hot water supply temperature"
    annotation (Dialog(group="Heating hot water"));
  parameter Modelica.Units.SI.TemperatureDifference dTHeaWat_nominal = 10
    "Nominal heating hot water temperature difference"
    annotation (Dialog(group="Heating hot water"));
  final parameter Modelica.Units.SI.ThermodynamicTemperature THeaWatRet_nominal = THeaWatSup_nominal - dTHeaWat_nominal
    "Nominal heating hot water supply temperature";
  parameter Real tabHeaWatRes[2,2]=[
      THeaRooSet-1, THeaWatSup_nominal;
      THeaRooSet, THeaRooSet+1.5]
    "Heating hot water supply temperature reset schedule"
    annotation (Dialog(group="Heating hot water"));
  parameter Modelica.Units.SI.ThermodynamicTemperature THotWatSupTan_nominal(displayUnit="degC") =
    50 + 273.15 "Nominal domestic hot water supply temperature to the tank"
    annotation (Dialog(group="Domestic hot water"));
  parameter Modelica.Units.SI.ThermodynamicTemperature THotWatSupFix_nominal(displayUnit="degC") =
    40 + 273.15 "Nominal domestic hot water supply temperature to the fixture"
    annotation (Dialog(group="Domestic hot water"));
  parameter Modelica.Units.SI.ThermodynamicTemperature TColWat_nominal(displayUnit="degC") =
    15 + 273.15 "Nominal domestic cold water temperature"
    annotation (Dialog(group="Domestic hot water"));
    annotation(defaultComponentName="datBuiSet",
    Documentation(info="<html>
<p>
Unified set point declarations. All buildings use the same set points.
</p>
</html>"));
end BuildingSetPoints;
