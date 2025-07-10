within ThermalGridJBA;
package Types "Package with type definitions"
  extends Modelica.Icons.TypesPackage;
  type Scenario = enumeration(
      FutureTMY
        "Post-ECM consumption level and fTMY weather file, this is the default",
      Baseline "Pre-ECM consumption level and TMY3 weather file",
      PostECM
        "Post-ECM consumption level and TMY3 weather file",
      HeatWave
        "Post-ECM consumption level and heat wave weather file based on fTMY",
      ColdSnap
        "Post-ECM consumption level and cold snap weather file based on fTMY",
      CriticalLoad
        "Post-ECM consumption level reduced to 50% for 7 days following hottest and coldest day")
    "Enumeration to choose the combination of consumption level and weather file"
    annotation (Documentation(info="<html>
<p>
Enumeration to specify the energy consumption level and weather file.
Combinations not included in this enumeration do not have corresponding
load files available.
</p>
</html>"));
 annotation (preferredView="info", Documentation(info="<html>
<p>
This package contains type definitions for the library.
</p>
</html>"));
end Types;
