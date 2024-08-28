within ThermalGridJBA.Hubs.BaseClasses;
model BTS "Adapted BTS validation model with key parameters exposed"
  extends Buildings.DHC.Loads.BaseClasses.Examples.CouplingTimeSeries(
    bui(
      final filNam=buiDat.filNam,
      final T_aHeaWat_nominal=buiDat.THeaWatSup_nominal,
      final T_bHeaWat_nominal=buiDat.THeaWatRet_nominal,
      final T_aChiWat_nominal=buiDat.TChiWatSup_nominal,
      final T_bChiWat_nominal=buiDat.TChiWatRet_nominal,
      final have_hotWat=buiDat.have_hotWat));

parameter ThermalGridJBA.Data.Individual.B1380 buiDat
    annotation (Placement(transformation(extent={{-40,
            80},{-20,100}})), choicesAllMatching=true);

    annotation(experiment(
      StopTime=864000,
      Tolerance=1e-06),
      Documentation(
      info="<html>
<p>
This model is adapted from
<code>Buildings.DHC.Loads.BaseClasses.Examples.CouplingTimeSeries</code>
for the convenience of using JBA building data.
</p>
</html>"));
end BTS;
