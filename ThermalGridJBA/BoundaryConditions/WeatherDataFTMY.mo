within ThermalGridJBA.BoundaryConditions;
model WeatherDataFTMY "Weather data reader for Andrews AFB fTMY NORESM2 2020-2039"
  extends Buildings.BoundaryConditions.WeatherData.ReaderTMY3(
    computeWetBulbTemperature=false,
    final filNam = Modelica.Utilities.Files.loadResource("modelica://ThermalGridJBA/Resources/Data/BoundaryConditions/fTMY_Maryland_Prince_George's_NORESM2_2020_2039.mos"));
    annotation(
    defaultComponentName="wea",
    Documentation(info="<html>
<p>
This class reads the
<a href=\"https://energyplus.net/weather-location/north_and_central_america_wmo_region_4/USA/MD/fTMY_Maryland_Prince_George's_NORESM2_2020_2039\">
Adrews AFB fTMY (NORESM2 2020-2039)</a> weather data.
</p>
</html>"));
end WeatherDataFTMY;
