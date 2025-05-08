within ThermalGridJBA.Data;
record SoilData "Data record for soil data"
  extends Buildings.Fluid.Geothermal.ZonedBorefields.Data.Soil.Template(
    kSoi=1.55,
    cSoi=0.97E6/1800,
    dSoi=1800);
end SoilData;
