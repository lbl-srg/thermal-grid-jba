within ThermalGridJBA.Data.Individual;
record B1631
  "Data record for 1631 Dorm"
  extends GenericConsumer(
    filNam="modelica://ThermalGridJBA/Resources/Data/Hubs/Individual/1631.mos",
    TChiWatSup_nominal=6.666666666666667+273.15,
    dTChiWat_nominal=5.555555555555555,
    THeaWatSup_nominal=60+273.15,
    dTHeaWat_nominal=5.555555555555555,
    THotWatSup_nominal=57.22222222222222+273.15,
    have_hotWat=true);
end B1631;