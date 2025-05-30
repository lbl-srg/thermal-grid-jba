within ThermalGridJBA.Data.Districts;
record FiveHubs "District set up for five clustered hubs using fTMY"
  extends GenericDistrict(
    final nBui=5,
    final filNamInd=
      if sce == ThermalGridJBA.Types.Scenario.FutureTMY then
        {
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_futu.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_futu.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_futu.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_futu.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_futu.mos"}
      else if sce == ThermalGridJBA.Types.Scenario.Baseline then
        {
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_base.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_base.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_base.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_base.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_base.mos"}
      else if sce == ThermalGridJBA.Types.Scenario.PostECM then
        {
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_post.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_post.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_post.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_post.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_post.mos"}
      else if sce == ThermalGridJBA.Types.Scenario.HeatWave then
        {
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_heat.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_heat.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_heat.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_heat.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_heat.mos"}
      else
        {
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CA_cold.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CB_cold.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CC_cold.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CD_cold.mos",
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/CE_cold.mos"},
    final filNamCom=
      if sce == ThermalGridJBA.Types.Scenario.FutureTMY then
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/All_futu.mos"
      else if sce == ThermalGridJBA.Types.Scenario.Baseline then
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/All_base.mos"
      else if sce == ThermalGridJBA.Types.Scenario.PostECM then
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/All_post.mos"
      else if sce == ThermalGridJBA.Types.Scenario.HeatWave then
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/All_heat.mos"
      else
        "modelica://ThermalGridJBA/Resources/Data/Consumptions/All_cold.mos",
    final lDis={34,688,347,401,1412,578},
    final lCon={27,226,237,48,31},
    final facTerUniSizHea={1,1.3,1.3,1,1});

  parameter ThermalGridJBA.Types.Scenario sce = ThermalGridJBA.Types.Scenario.FutureTMY
    "Weather scenario";

  annotation (
    defaultComponentName="datDis",
    defaultComponentPrefixes="inner",
    Documentation(info="<html>
<p>
The in-scope buildings are separated to five hubs. See guide for details.
The connection points of the five hubs are at, in sequence:
Jones Buildings (1500), Malcolm Grow Medical Complex (1058-1060),
Aerospace Physiology Fac (1045), Presidential Inn (1380),
and Transient Lodging Facility (1800).
</html>"));
end FiveHubs;
