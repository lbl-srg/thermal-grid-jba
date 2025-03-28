within ThermalGridJBA.BoundaryConditions.Validation;
model WeatherData "Test model for weather data"
  extends Modelica.Icons.Example;
  ThermalGridJBA.BoundaryConditions.WeatherData weaDat_fTMY(weaFil=
        ThermalGridJBA.Hubs.BaseClasses.getWeatherFileName(
        string="#Weather file name",
        filNam=Modelica.Utilities.Files.loadResource("modelica://ThermalGridJBA/Resources/Data/Consumptions/All_futu.mos")))
    "Weather data reader for the fTMY file"
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  ThermalGridJBA.BoundaryConditions.WeatherData weaDat_HeaWav(weaFil=
        ThermalGridJBA.Hubs.BaseClasses.getWeatherFileName(
        string="#Weather file name",
        filNam=Modelica.Utilities.Files.loadResource("modelica://ThermalGridJBA/Resources/Data/Consumptions/All_heat.mos")))
    "Weather data reader for the heat wave file"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
  ThermalGridJBA.BoundaryConditions.WeatherData weaDat_ColSna(weaFil=
        ThermalGridJBA.Hubs.BaseClasses.getWeatherFileName(
        string="#Weather file name",
        filNam=Modelica.Utilities.Files.loadResource("modelica://ThermalGridJBA/Resources/Data/Consumptions/All_cold.mos")))
    "Weather data reader for the cold snap file"
    annotation (Placement(transformation(extent={{-80,-60},{-60,-40}})));
  annotation (experiment(
      StopTime=31536000,
      Tolerance=1e-06),
     __Dymola_Commands(file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/BoundaryConditions/Validation/WeatherData.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
This validation model compares the three weather files: fTMY, heat wave, and
cold snap.
The weather file is selected through a line in the load profile.
This ensures the correct weather file is selected.
</p>
</html>"));
end WeatherData;
