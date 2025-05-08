within ThermalGridJBA.Data;
record SoilData "Data record for soil data"
  extends Buildings.Fluid.Geothermal.ZonedBorefields.Data.Soil.Template(
    final kSoi=1.55,
    final cSoi=0.97E6/1800,
    final dSoi=1800);
end SoilData;
