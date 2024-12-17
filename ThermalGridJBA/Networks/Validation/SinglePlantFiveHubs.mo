within ThermalGridJBA.Networks.Validation;
model SinglePlantFiveHubs "District with five hubs"
  extends SinglePlant(
    redeclare ThermalGridJBA.Data.Districts.FiveHubs datDis(
    mCon_flow_nominal=bui.ets.hex.m1_flow_nominal));
  annotation (
  Diagram(
  coordinateSystem(preserveAspectRatio=false, extent={{-400,-260},{400,260}})),
    __Dymola_Commands(
  file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Networks/Validation/SinglePlantFiveHubs.mos"
  "Simulate and plot"),
  experiment(
      StartTime=7776000,
      StopTime=8640000,
      Tolerance=1e-06),
    Documentation(info="<html>
<p>
District with five clustered hubs.
</p>
</html>"),
    Icon(coordinateSystem(extent={{-100,-100},{100,100}})));
end SinglePlantFiveHubs;
