within ThermalGridJBA.Hubs.Validation;
model ConnectedETSWithDHW
  extends ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW(
    filNam="modelica://ThermalGridJBA/Resources/Data/Consumptions/CE.mos");

equation

annotation(
    __Dymola_Commands(
      file="modelica://ThermalGridJBA/Resources/Scripts/Dymola/Hubs/Validation/ConnectedETSWithDHW.mos" "Simulate and plot"),
    experiment(
      StartTime=7776000,
      StopTime=8640000,
      Tolerance=1e-06),
Documentation(info="<html>
<p>
Validation model for a single building with DHW integration in the ETS.
The model itself does not impose that DHW integration is present.
This information is determined from the load profile.
The following buildings have DHW load and are suitable for this model:
1058x1060, 1065, 1380, 1631, 1657, 1690, 1691, 1692, 1800.
</p>
</html>"));
end ConnectedETSWithDHW;
