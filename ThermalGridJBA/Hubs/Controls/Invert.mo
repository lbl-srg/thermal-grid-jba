within ThermalGridJBA.Hubs.Controls;
block Invert "Invert the input signal from u to 1-u"
  extends Modelica.Blocks.Icons.Block;
  Buildings.Controls.OBC.CDL.Interfaces.RealInput u "Input signal" annotation (
      Placement(transformation(extent={{-140,-20},{-100,20}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput y "Output signal"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),
        iconTransformation(extent={{100,-20},{140,20}})));
protected
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant uni(final k=1) "Unity"
    annotation (Placement(transformation(extent={{-30,-10},{-10,10}})));
  Modelica.Blocks.Math.Feedback inv "Inversion of control signal"
    annotation (Placement(transformation(extent={{10,-10},{30,10}})));
equation
  connect(uni.y, inv.u1)
    annotation (Line(points={{-8,0},{12,0}}, color={0,0,127}));
  connect(u, inv.u2) annotation (Line(points={{-120,0},{-60,0},{-60,-40},{20,-40},
          {20,-8}}, color={0,0,127}));
  connect(inv.y, y) annotation (Line(points={{29,0},{120,0}}, color={0,0,127}));
  annotation (Diagram(graphics={
        Line(
          points={{-14,-2}},
          color={28,108,200},
          pattern=LinePattern.Dash)}),
          defaultComponentName="inv",
          Documentation(info="<html>
<p>
Outputs <i>y = 1 - u</i>.
</p>
</html>"));
end Invert;
