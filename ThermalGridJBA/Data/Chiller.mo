within ThermalGridJBA.Data;
record Chiller "Parameters for the modular expandable chiller"
  extends Modelica.Icons.Record;

  parameter Buildings.Fluid.HeatPumps.ModularReversible.Data.TableData2D.GenericHeatPump datHea
    = Buildings.Fluid.HeatPumps.ModularReversible.Data.TableData2D.EN14511.WAMAK_WaterToWater_220kW()
    "Performance map for the heat pump"
    annotation (Dialog(group="Performance map"));
  parameter Buildings.Fluid.Chillers.ModularReversible.Data.TableData2D.Generic datCoo
    = Buildings.Fluid.Chillers.ModularReversible.Data.TableData2D.EN14511.Carrier30XWP1012_1MW()
    "Not used - performance map for the cooling mode"
    annotation (Dialog(group="Performance map"));

  parameter Real PLRMax(min=0) = 1 "Maximum part load ratio"
    annotation (Dialog(group="Part load"));
  parameter Real PLRMin(min=0) = 0.3 "Minimum part load ratio"
    annotation (Dialog(group="Part load"));

  parameter Modelica.Units.SI.HeatFlowRate QHea_flow_nominal(min=Modelica.Constants.eps)
    "Nominal heating capacity"
    annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.HeatFlowRate QCoo_flow_nominal(max=0)=0
    "Nominal cooling capacity"
    annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.TemperatureDifference dTCon_nominal
    "Nominal temperature difference in condenser medium"
    annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.TemperatureDifference dTEva_nominal
    "Nominal temperature difference in evaporator medium"
    annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.TemperatureDifference TConLvg_nominal(
     displayUnit="degC") "Nominal condenser leaving temperature"
    annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.TemperatureDifference TEvaLvg_nominal(
     displayUnit="degC") "Nominal evaporator leaving temperature"
    annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.Temperature TConEntMin(displayUnit="degC")
    "Minimum of condenser water entering temperature"
    annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.Temperature TEvaEntMax(displayUnit="degC")
    "Maximum of evaporator water entering temperature"
    annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.Temperature TEvaLvgMin(displayUnit="degC")
    "Minimum value for leaving evaporator temperature"
    annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.Temperature TEvaLvgMax(displayUnit="degC")
    "Maximum value for leaving evaporator temperature"
    annotation (Dialog(group="Evaporator"));
  parameter Modelica.Units.SI.MassFlowRate mCon_flow_nominal =
    m_flow_nominal_internal
    "Nominal medium flow rate in the condenser"
    annotation (Dialog(group="Condenser"));
  parameter Modelica.Units.SI.MassFlowRate mEva_flow_nominal =
    m_flow_nominal_internal
    "Nominal medium flow rate in the evaporator"
    annotation (Dialog(group="Evaporator"));

  final parameter Modelica.Units.SI.MassFlowRate m_flow_nominal_internal =
    max(QHea_flow_nominal/dTCon_nominal/4186,
        abs(QCoo_flow_nominal)/dTEva_nominal/4186)
    "Intermediate value";

annotation(defaultComponentName="datChi");
end Chiller;
