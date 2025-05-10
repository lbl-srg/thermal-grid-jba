within ThermalGridJBA.Data;
record GenericDistrict "District network design parameters"
  extends Modelica.Icons.Record;
  final package MediumG = Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T=293.15, X_a=0.40) "Glycol";
  constant Real cpWatLiq=Buildings.Utilities.Psychrometrics.Constants.cpWatLiq;
  constant Real cpGly=MediumG.cp_const;
  parameter Integer nBui
    "Number of served buildings"
    annotation(Evaluate=true, Dialog(group="Load"));
  parameter String filNamInd[nBui]
    "Library paths of the load files of each individual hub"
    annotation (Dialog(group="Load"));
  parameter String filNamCom
    "Library paths of the combined load file"
    annotation (Dialog(group="Load"));
  final parameter String weaFil =
    ThermalGridJBA.Hubs.BaseClasses.getWeatherFileName(
      string="#Weather file name",
      filNam=Modelica.Utilities.Files.loadResource(filNamCom))
    "Weather file name";

  parameter ThermalGridJBA.Data.HexSize hexSiz(
    QHeaLoa_flow_nominal =
      Buildings.DHC.Loads.BaseClasses.getPeakLoad(
        string="#Peak space heating load",
        filNam=Modelica.Utilities.Files.loadResource(filNamCom)),
    QCooLoa_flow_nominal =
      Buildings.DHC.Loads.BaseClasses.getPeakLoad(
        string="#Peak space cooling load",
        filNam=Modelica.Utilities.Files.loadResource(filNamCom)));

  parameter Modelica.Units.SI.HeatFlowRate QPlaPeaHea_flow(min=Modelica.Constants.eps)
    =hexSiz.QHea_flow_nominal
    "Peak heating load at all the ETS heat exchanger"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Modelica.Units.SI.HeatFlowRate QPlaPeaCoo_flow = hexSiz.QCoo_flow_nominal
    "Peak cooling load at all the ETS heat exchanger"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Modelica.Units.SI.TemperatureDifference dTLoo_nominal=4
    "Design temperature difference of the district loop";

  parameter Modelica.Units.SI.MassFlowRate mPumDis_flow_nominal=
    max(abs(QPlaPeaCoo_flow),QPlaPeaHea_flow)/(Buildings.Utilities.Psychrometrics.Constants.cpWatLiq * dTLoo_nominal)
    "Nominal mass flow rate of main distribution pump";

//   parameter Modelica.Units.SI.MassFlowRate mPumDis_flow_nominal=
//     sum(mCon_flow_nominal)
//     "Nominal mass flow rate of main distribution pump";
  parameter Modelica.Units.SI.MassFlowRate mPipDis_flow_nominal=
      mPumDis_flow_nominal "Nominal mass flow rate for main pipe sizing";
  parameter Modelica.Units.SI.MassFlowRate mCon_flow_nominal[nBui]
    "Nominal mass flow rate in each connection line";
  parameter Modelica.Units.SI.Temperature TLooMin=273.15 + 10.5
    "Minimum loop temperature";
  parameter Modelica.Units.SI.Temperature TLooMax=273.15 + 24
    "Maximum loop temperature";

  parameter Real dp_length_nominal(unit="Pa/m")=250
    "Pressure drop per pipe length at nominal flow rate";
  parameter Modelica.Units.SI.Length lDis[nBui+1]=fill(100, nBui + 1)
    "Length of distribution pipe, from plant to each building back to plant";
  parameter Modelica.Units.SI.Length lCon[nBui]=fill(10, nBui)
    "Length of each connection pipe (supply only, not counting return line)";

  // Central plant
  parameter Integer nGen=4
    "Number of generations in central plant"
    annotation (Dialog(tab="Central plant"));
  parameter Real staDowDel(unit="s")=3600
    "Minimum stage down delay, to avoid quickly staging down"
   annotation (Dialog(tab="Central plant"));
  parameter Real dTEqu_nominal(unit="K")=4
    "Temperature difference for sizing heat pump and the operational condition for dry cooler"
    annotation (Dialog(tab="Central plant"));
  parameter Modelica.Units.SI.Temperature TSoi_start(displayUnit="degC")=290.3
    "Initial temperature of the soil of borefield";
  parameter Modelica.Units.SI.TemperatureDifference dTOveSho(min=0)=2
    "Temperature difference to allow for control over or undershoot. dTOveSho >= 0"
   annotation (Dialog(tab="Central plant"));
  parameter Modelica.Units.SI.Temperature TPlaHeaSet=TLooMin+dTLoo_nominal*(QPlaPeaHea_flow/abs(QPlaPeaCoo_flow))+dTOveSho
    "Design plant heating setpoint temperature"
    annotation (Dialog(tab="Central plant"));
//   parameter Modelica.Units.SI.Temperature TPlaHeaSet=TLooMin+dTLoo_nominal
//     "Design plant heating setpoint temperature"
//     annotation (Dialog(tab="Central plant"));
  parameter Modelica.Units.SI.Temperature TPlaCooSet=TLooMax-dTLoo_nominal-dTOveSho
    "Design plant cooling setpoint temperature"
    annotation (Dialog(tab="Central plant"));
  parameter Modelica.Units.SI.Temperature TPlaSumCooSet=TLooMax - dTLoo_nominal
    "Design plant summer cooling setpoint temperature"
    annotation (Dialog(tab="Central plant"));
  parameter Real TDryBulSum(
    unit="K",
    displayUnit="degC")=297.15
    "Threshold of the dry bulb temperaure in summer below which starts charging borefield"
    annotation (Dialog(tab="Central plant"));
//   parameter Real mPlaWat_flow_nominal(unit="kg/s")=sum(mCon_flow_nominal)
//     "Nominal water mass flow rate of plant"
//     annotation (Dialog(tab="Central plant"));
  parameter Real mPlaWat_flow_nominal(unit="kg/s")=mPumDis_flow_nominal
    "Nominal water mass flow rate of plant"
    annotation (Dialog(tab="Central plant"));
  parameter Real dpPlaValve_nominal(unit="Pa")=6000
    "Nominal pressure drop of fully open 2-way valve"
    annotation (Dialog(tab="Central plant"));
  // Central plant: heat exchangers
  parameter Real dpPlaHex_nominal(unit="Pa")=10000
    "Pressure difference across heat exchanger"
    annotation (Dialog(tab="Central plant", group="Heat exchanger"));
  parameter Real mPlaHexGly_flow_nominal(unit="kg/s")=mPlaWat_flow_nominal*
    cpWatLiq/cpGly
    "Nominal glycol mass flow rate for heat exchanger"
    annotation (Dialog(tab="Central plant", group="Heat exchanger"));
  // Central plant: dry coolers
  parameter Real dpDryCoo_nominal(unit="Pa")=10000
    "Nominal pressure drop of dry cooler"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  parameter Real mDryCoo_flow_nominal(unit="kg/s")=mPlaHexGly_flow_nominal +
    mPlaHeaPumGly_flow_nominal
    "Nominal glycol mass flow rate for dry cooler"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  parameter Real TDryAppSet(unit="K")=2
    "Dry cooler approach setpoint"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  parameter Real minFanSpe(unit="1")=0.1
    "Minimum dry cooler fan speed"
    annotation (Dialog(tab="Central plant", group="Dry cooler"));
  // Central plant: heat pumps
  parameter Real mPlaHeaPumWat_flow_nominal(unit="kg/s")=max(abs(
    QPlaHeaPumCoo_flow_nominal), QPlaHeaPumHea_flow_nominal)/(cpWatLiq*
    dTLoo_nominal)
    "Heat pump minimum water mass flow rate"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real mPlaHeaPumWat_flow_min(unit="kg/s")=mPlaHeaPumWat_flow_nominal
    *0.2/nGen
    "Heat pump minimum water mass flow rate"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real mPlaHeaPumGly_flow_nominal(unit="kg/s")=
    mPlaHeaPumWat_flow_nominal*cpWatLiq/cpGly
    "Nominal glycol mass flow rate for heat pump"
    annotation (Dialog(tab="Central plant", group="Heat pump"));

    // We assume that the borefield can provide maximum cooling of 10e6 W and maximum
    // heating of 3e6 W.
//   parameter Real QPlaHeaPumHea_flow_nominal(unit="W")=
//     mPlaWat_flow_nominal*cpWatLiq*dTLoo_nominal
//     "Nominal heating capacity"
//     annotation (Dialog(tab="Central plant", group="Heat pump"));
//   parameter Real QPlaHeaPumHea_flow_nominal(unit="W")=QPlaPeaHea_flow
//     "Nominal heating capacity"
//     annotation (Dialog(tab="Central plant", group="Heat pump"));
  // Downsize the heat pump capacity by considering the heating supply from borefield
  parameter Real QPlaHeaPumHea_flow_nominal(unit="W")=QPlaPeaHea_flow - 0.5*3e6
    "Nominal heating capacity"
    annotation (Dialog(tab="Central plant", group="Heat pump"));

//   parameter Real QPlaHeaPumCoo_flow_nominal(unit="W")=-QPlaHeaPumHea_flow_nominal
//     "Nominal cooling capacity"
//     annotation (Dialog(tab="Central plant", group="Heat pump"));
//   parameter Real QPlaHeaPumCoo_flow_nominal(unit="W")=QPlaPeaCoo_flow
//     "Nominal cooling capacity"
//     annotation (Dialog(tab="Central plant", group="Heat pump"));
  // Downsize the heat pump capacity by considering the heating supply from borefield
  parameter Real QPlaHeaPumCoo_flow_nominal(unit="W")=QPlaPeaCoo_flow + 0.5*
    10e6
    "Nominal cooling capacity"
    annotation (Dialog(tab="Central plant", group="Heat pump"));


  parameter Real TPlaConHea_nominal(unit="K")=TLooMin
    "Nominal temperature of the heated fluid in heating mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaEvaHea_nominal(unit="K")=260.15
    "Nominal temperature used to size the heat pump in heating mode (cold side minimum temperature)"
    annotation (Dialog(tab="Central plant", group="Heat pump"));

  parameter Real TPlaConCoo_nominal(unit="K")=TLooMax
    "Nominal temperature of the cooled fluid in cooling mode"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaEvaCoo_nominal(unit="K")=42 + 273.15
    "Nominal temperature used to size the heat pump in cooling mode (hot side maximum temperature)"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaConInMin(unit="K")=TLooMax - dTEqu_nominal - dTLoo_nominal
    "Minimum condenser inlet temperature"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real TPlaEvaInMax(unit="K")=TLooMin + dTEqu_nominal + dTLoo_nominal
    "Maximum evaporator inlet temperature"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real minPlaComSpe(unit="1")=0.2/nGen
    "Minimum heat pump compressor speed"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real minHeaPumSpeHol=600
    "Threshold time for checking if the compressor has been in the minimum speed"
     annotation (Dialog(tab="Central plant", group="Heat pump"));

  parameter Real offTim(unit="s")=3600
    "Heat pump off time due to the low compressor speed"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real holOnTim(unit="s")=3600
    "Heat pump hold on time"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  parameter Real holOffTim(unit="s")=1800
    "Heat pump hold off time"
    annotation (Dialog(tab="Central plant", group="Heat pump"));
  // District pump
  parameter Real TUpp(unit="K")=TLooMax - dTOveSho
    "Upper bound temperature"
    annotation (Dialog(tab="District pump"));
  parameter Real TLow(unit="K")=TLooMin + dTOveSho
    "Lower bound temperature"
    annotation (Dialog(tab="District pump"));
  parameter Real dTSlo(unit="K")=2
    "Temperature deadband for changing pump speed"
    annotation (Dialog(tab="District pump"));
  parameter Real yDisPumMin(unit="1")=0.1
    "District loop pump minimum speed"
    annotation (Dialog(tab="District pump"));
  annotation (
    defaultComponentName="datDis",
    defaultComponentPrefixes="inner",
    Documentation(info="<html>
<p>
This record contains parameter declarations of a district system.
</html>"));
end GenericDistrict;
