within ThermalGridJBA.CentralPlants;
block BorefieldMILP "Energy of borefiled as computed by MILP"
  extends Modelica.Blocks.Icons.Block;
  final parameter Modelica.Units.SI.Energy EBorMil =
    Modelica.Units.Conversions.from_kWh(
    Buildings.DHC.Loads.BaseClasses.getPeakLoad(
      string="# Capacity",
      filNam=Modelica.Utilities.Files.loadResource(
      "modelica://ThermalGridJBA/Resources/Data/BorefieldSOC/borefield_soc_solution3.mos")))
  "Capacity of borefield from MILP optimization";
  final parameter Real SOC_start =
    Buildings.DHC.Loads.BaseClasses.getPeakLoad(
      string="# SOC_start",
      filNam=Modelica.Utilities.Files.loadResource(
      "modelica://ThermalGridJBA/Resources/Data/BorefieldSOC/borefield_soc_solution3.mos"))
  "Capacity of borefield from MILP optimization";
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput SOC(
     final unit="1")
     "State of charge"
    annotation (Placement(transformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput E(
     final unit="J",
     displayUnit="Wh")
     "Energy of borefield"
    annotation (Placement(transformation(extent={{100,-60},{140,-20}})));

  Modelica.Blocks.Sources.CombiTimeTable resMIL(
    tableOnFile=true,
    tableName="tab1",
    fileName=ModelicaServices.ExternalReferences.loadResource("modelica://ThermalGridJBA/Resources/Data/BorefieldSOC/borefield_soc_solution3.mos"),
    columns={2},
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    timeEvents=Modelica.Blocks.Types.TimeEvents.NoTimeEvents) "Reader for the borefield SOC (y[1] is SOC). 
    The input file is from the MILP optimization (Solution 3 - TEN + PV + Battery). 
    SOC = 1 when the temperature of the borefield is the highest, 0 when the temperature in the borefield is the lowest"
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
protected
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter socToEne(final k=EBorMil)
    "Gain to convert SOC to energy"
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));

public
  Buildings.Controls.OBC.CDL.Reals.AddParameter subSOCStart(p=-SOC_start)
    "Subtract state of charge of t=0"
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
equation
  connect(socToEne.y, E) annotation (Line(points={{42,0},{80,0},{80,-40},{120,-40}},
        color={0,0,127}));
  connect(resMIL.y[1], SOC)
    annotation (Line(points={{-59,0},{-40,0},{-40,40},{120,40}},
                                                             color={0,0,127}));
  connect(subSOCStart.y, socToEne.u)
    annotation (Line(points={{2,0},{18,0}}, color={0,0,127}));
  connect(subSOCStart.u, resMIL.y[1])
    annotation (Line(points={{-22,0},{-59,0}}, color={0,0,127}));
  annotation (
  defaultComponentName="borMil",
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-86,94},{86,-88}},
          lineColor={0,0,0},
          fillColor={234,210,210},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-72,82},{-44,54}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-34,82},{-6,54}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{4,82},{32,54}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{42,82},{70,54}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-34,-50},{-6,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{4,-50},{32,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{42,-50},{70,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-72,-50},{-44,-78}},
          lineColor={0,0,0},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-34,-18},{-6,-46}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{4,-18},{32,-46}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{40,-18},{68,-46}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-72,-18},{-44,-46}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-34,14},{-6,-14}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{4,14},{32,-14}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{42,14},{70,-14}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-72,14},{-44,-14}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-70,48},{-42,20}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-32,48},{-4,20}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{6,48},{34,20}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{42,48},{70,20}},
          lineColor={0,0,0},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid)}),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p>
Borefield state of charge and energy content as computed by MILP optimization.
</p>
<p>
This model allows comparing the energy stored in the borefield between MILP and Modelica.
</p>
</html>", revisions="<html>
<ul>
<li>
May 8, 2025, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end BorefieldMILP;
