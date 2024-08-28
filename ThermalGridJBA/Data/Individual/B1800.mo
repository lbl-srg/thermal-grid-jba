within ThermalGridJBA.Data.Individual;
record B1800
  "Data record for 1800 Transient Lodging Facility"
  extends GenericConsumer(
    filNam="modelica://ThermalGridJBA/Resources/Data/Hubs/Individual/1800.mos",
    TChiWatSup_nominal=6.666666666666667+273.15,
    dTChiWat_nominal=5.555555555555555,
    THeaWatSup_nominal=82.22222222222223+273.15,
    dTHeaWat_nominal=22.22222222222222,
    THotWatSup_nominal=57.22222222222222+273.15,
    have_hotWat=true);
end B1800;