within ThermalGridJBA.Data.Individual;
record B1380 "Data record for building 1380 [name]"
  extends GenericConsumer(
    filNam="modelica://ThermalGridJBA/Resources/Data/Hubs/Individual/1380.mos",
    TChiWatSup_nominal=4.7+273.15,
    dTChiWat_nominal=5.6,
    THeaWatSup_nominal=82+273.15,
    dTHeaWat_nominal=22);
end B1380;
