within ThermalGridJBA.Data;
record SoilData "Data record for soil data"
  extends Buildings.Fluid.Geothermal.ZonedBorefields.Data.Soil.Template(
    kSoi=1.1,
    cSoi=1.4E6/1800,
    dSoi=1800);
end SoilData;
