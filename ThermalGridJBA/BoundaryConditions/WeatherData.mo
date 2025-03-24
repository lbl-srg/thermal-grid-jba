within ThermalGridJBA.BoundaryConditions;
model WeatherData "Weather data reader"
  extends Buildings.BoundaryConditions.WeatherData.ReaderTMY3(
    computeWetBulbTemperature=false,
    final filNam = Modelica.Utilities.Files.loadResource("modelica://ThermalGridJBA/Resources/Data/BoundaryConditions/"+weaFil));

  parameter String weaFil "Name of the weather file";

    annotation(
    defaultComponentName="wea",
    Documentation(info="<html>
<p>
This class reads the specified weather file whose name will be provided
externally from reading the load file.
This is to ensure that the correct weather file is used.
</p>
</html>"));
end WeatherData;
