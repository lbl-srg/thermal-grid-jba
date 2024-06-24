within ThermalGridJBA.BoundaryConditions;
model WeatherData "Weather data reader for Andrews AFB TMY3"
  extends Buildings.BoundaryConditions.WeatherData.ReaderTMY3(
    computeWetBulbTemperature=true,
    final filNam = Modelica.Utilities.Files.loadResource("modelica://ThermalGridJBA/Resources/Data/BoundaryConditions/USA_MD_Andrews.AFB.745940_TMY3.mos"));
    annotation(Documentation(info="<html>
<p>
This class reads the
<a href=\"https://energyplus.net/weather-location/north_and_central_america_wmo_region_4/USA/MD/USA_MD_Andrews.AFB.745940_TMY3\">
Adrews AFB TMY3</a> weather data.
</p>
</html>"));
end WeatherData;
