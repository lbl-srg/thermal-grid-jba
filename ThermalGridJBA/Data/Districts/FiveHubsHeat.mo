within ThermalGridJBA.Data.Districts;
record FiveHubsHeat
  "District set up for five clustered hubs using the heat wave scenario"
  extends ThermalGridJBA.Data.Districts.FiveHubs(
    filNamInd={
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_heat.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_heat.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_heat.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_heat.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_heat.mos"},
    filNamCom=
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/All_heat.mos");
  annotation (
    defaultComponentName="datDis",
    defaultComponentPrefixes="inner",
    Documentation(info="<html>
<p>
The in-scope buildings are separated to five hubs. See guide for details (todo).
The locations of the combined hubs are assumed at, in sequence:
Jones Buildings (1500), Malcolm Grow Medical Complex (1058-1060),
Aerospace Physiology Fac (1045), Presidential Inn (1380),
and Transient Lodging Facility (1800).
</html>"));
end FiveHubsHeat;
