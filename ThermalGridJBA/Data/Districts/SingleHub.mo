within ThermalGridJBA.Data.Districts;
record SingleHub
  "District set up for one single hub covering the whole JBA site"
  extends GenericDistrict(
    nBui=1,
    filNam={"modelica://ThermalGridJBA/Resources/Data/Consumptions/All.mos"},
    lDis={722,2738},
    lCon={226});
  annotation (
    defaultComponentName="datDis",
    defaultComponentPrefixes="inner",
    Documentation(info="<html>
<p>
One hub containing combined loads of all in-scope buildings of JBA.
The location of the combined hub is assumed at
Malcolm Grow Medical Complex (1058-1060).
</html>"));
end SingleHub;
