within ThermalGridJBA.Networks.Data.Borefield;
record Validation "Borefield data record for the validation models"
  extends ThermalGridJBA.Networks.Data.Borefield.Template                   (
    filDat=ThermalGridJBA.Networks.Data.Filling.Bentonite(),
    soiDat=ThermalGridJBA.Networks.Data.Soil.SandStone(),
    conDat=ThermalGridJBA.Networks.Data.Configuration.Validation());

  annotation (
defaultComponentPrefixes="parameter",
defaultComponentName="borFieDat",
Documentation(
info="<html>
<p>
This record presents an example on how to define borefield records
using the template in
<a href=\"modelica://Buildings.Fluid.Geothermal.ZonedBorefields.Template\">
Buildings.Fluid.Geothermal.ZonedBorefields.Template</a>.
</p>
</html>",
revisions="<html>
<ul>
<li>
May 2024, by Massimo Cimmino:<br/>
First implementation.
</li>
</ul>
</html>"));
end Validation;
