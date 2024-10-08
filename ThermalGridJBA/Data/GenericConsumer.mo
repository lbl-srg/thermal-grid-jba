within ThermalGridJBA.Data;
record GenericConsumer "Generic data record for a consumer hub"
  extends Modelica.Icons.Record;

  parameter String filNam
    "File name for the load profile";
  parameter Modelica.Units.SI.ThermodynamicTemperature TChiWatSup_nominal
    "Nominal chilled water supply temperature";
  parameter Modelica.Units.SI.TemperatureDifference dTChiWat_nominal
    "Nominal chilled water temperature difference";
  final parameter Modelica.Units.SI.ThermodynamicTemperature TChiWatRet_nominal
  = TChiWatSup_nominal + dTChiWat_nominal
    "Nominal chilled water return temperature";
  parameter Modelica.Units.SI.ThermodynamicTemperature THeaWatSup_nominal
    "Nominal heating hot water supply temperature";
  parameter Modelica.Units.SI.TemperatureDifference dTHeaWat_nominal
    "Nominal heating hot water temperature difference";
  final parameter Modelica.Units.SI.ThermodynamicTemperature THeaWatRet_nominal
  = THeaWatSup_nominal - dTHeaWat_nominal
    "Nominal heating hot water supply temperature";
  parameter Modelica.Units.SI.ThermodynamicTemperature THotWatSup_nominal
    "Nominal domestic hot water supply temperature";
  parameter Boolean have_hotWat
    "Building has domestic hot water system";
annotation(defaultComponentName="datBui");
end GenericConsumer;
