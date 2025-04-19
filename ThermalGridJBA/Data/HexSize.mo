within ThermalGridJBA.Data;
record HexSize "Converting end use load to hex size"
  extends Modelica.Icons.Record;

  parameter Real COP_hexSizRejHea = 2.3183610439300537
    "Heating rejection COP for hex sizing"
    annotation (Dialog(group="COP"));
  parameter Real COP_hexSizRejCoo = 11.570534706115723
    "Cooling rejection COP for hex sizing"
    annotation (Dialog(group="COP"));

  parameter Modelica.Units.SI.HeatFlowRate QHeaLoa_flow_nominal(
    min=Modelica.Constants.eps)
    "Peak heating load all hubs combined (>=0)"
    annotation (Dialog(group="Load"));
  parameter Modelica.Units.SI.HeatFlowRate QCooLoa_flow_nominal(
    max=-Modelica.Constants.eps)
    "Peak cooling load all hubs combined (<=0)"
    annotation (Dialog(group="Load"));

  final parameter Modelica.Units.SI.HeatFlowRate QHea_flow_nominal(
    min=Modelica.Constants.eps) =
      QHeaLoa_flow_nominal * COP_hexSizRejHea / (1 + COP_hexSizRejHea)
    "Nominal hex heat flow rate sized for heating (>=0)";
  final parameter Modelica.Units.SI.HeatFlowRate QCoo_flow_nominal(
    max=-Modelica.Constants.eps) =
      QCooLoa_flow_nominal * (1 + COP_hexSizRejCoo) / COP_hexSizRejCoo
    "Nominal hex heat flow rate sized for cooling (<=0)";

  final parameter Modelica.Units.SI.HeatFlowRate Q_flow_nominal(
    min=Modelica.Constants.eps) =
      max(QHea_flow_nominal, abs(QCoo_flow_nominal))
    "Nominal hex heat flow rate";

annotation (
    defaultComponentPrefixes="parameter",
    defaultComponentName="hexSiz",
    Documentation(info="<html>
<p>
This record hosts parameters needed to size the ETS hex based on end use load.
</p>
<p>
The sizing converts nominal end use heating or cooling load via
the heat recovery chiller COP to heat flow rate required at the ETS hex.
The heating rejection COP uses the worse value and the cooling rejection COP
uses the best value. These values are found through ETS test model runs with
the load profiles. For details see
PythonResources/RunCases/findCOPForHexSizing.py.
</p>
</html>"));
end HexSize;
