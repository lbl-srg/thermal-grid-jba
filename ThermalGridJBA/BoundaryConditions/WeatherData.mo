within ThermalGridJBA.BoundaryConditions;
model WeatherData "Weather data reader"
  extends Buildings.BoundaryConditions.WeatherData.ReaderTMY3(
    computeWetBulbTemperature=true,
    final filNam = Modelica.Utilities.Files.loadResource("modelica://ThermalGridJBA/Resources/Data/BoundaryConditions/USA_MD_Andrews.AFB.745940_TMY3.mos"));
end WeatherData;
