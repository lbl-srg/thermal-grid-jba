within ThermalGridJBA.Hubs.Validation;
model ConnectedETSWithDHW
  extends ThermalGridJBA.Hubs.Validation.ConnectedETSNoDHW(
    redeclare ThermalGridJBA.Data.Individual.B1380 datBui(have_hotWat=true));

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
The model can load any building record even if the record has
<code>have_hotWat=false</code>.
This Boolean switch would be overriden to <code>true</code> and the DHW
subsystem would be present without any load.
</p>
</html>"));
end ConnectedETSWithDHW;
