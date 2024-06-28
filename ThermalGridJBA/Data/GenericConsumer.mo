within ThermalGridJBA.Data;
record GenericConsumer "Generic data record for a consumer hub"
  extends Modelica.Icons.Record;

  parameter String filNam
    "File name for the load profile";
  parameter Modelica.Units.SI.ThermodynamicTemperature TChiWatSup_nominal
    "Nominal chilled water supply temperature";
  parameter Modelica.Units.SI.TemperatureDifference dTChiWat_nominal
    "Nominal chilled water temperature difference";
  parameter Modelica.Units.SI.ThermodynamicTemperature THeaWatSup_nominal
    "Nominal heating hot water supply temperature";
  parameter Modelica.Units.SI.TemperatureDifference dTHeaWat_nominal
    "Nominal heating hot water temperature difference";
annotation(defaultComponentName="buiDat");
end GenericConsumer;
