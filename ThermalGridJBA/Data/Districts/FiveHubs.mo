within ThermalGridJBA.Data.Districts;
record FiveHubs "District set up for five clustered hubs"
  extends GenericDistrict(
    nBui=5,
    filNam={
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD.mos",
      "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE.mos"},
    lDis={34,688,347,401,1412,578},
    lCon={27,226,237,48,31});
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
end FiveHubs;
