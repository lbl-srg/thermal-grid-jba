within ThermalGridJBA.BoundaryConditions.Validation;
model WeatherData "Test model for weather data"
  extends Modelica.Icons.Example;
  ThermalGridJBA.BoundaryConditions.WeatherData weaDat "Weather data reader"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  annotation (experiment(
      StopTime=31536000,
      Tolerance=1e-06),
     __Dymola_Commands(file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/BoundaryConditions/Validation/WeatherData.mos"
        "Simulate and plot"));
end WeatherData;
