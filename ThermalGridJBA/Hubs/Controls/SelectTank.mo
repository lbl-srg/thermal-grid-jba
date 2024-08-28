within ThermalGridJBA.Hubs.Controls;
block SelectTank "Select the signals of the HHW tank or DHW tank"
  extends Modelica.Blocks.Icons.Block;
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaWatTop(final unit="K",
      displayUnit="degC") "Heating water temperature at tank top"
    annotation (Placement(transformation(extent={{-140,-40},{-100,0}}),
    iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaWatSupPreSet(final unit="K",
      displayUnit="degC") "Heating water supply temperature set point"
    annotation (Placement(transformation(extent={{-140,0},{-100,40}}),
    iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THotWatTop(final unit="K",
      displayUnit="degC") "Domestic hot water temperature at tank top"
    annotation (Placement(transformation(extent={{-140,-120},{-100,-80}}),
        iconTransformation(extent={{-140,-120},{-100,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THotWatSupPreSet(final unit="K",
      displayUnit="degC") "Domestic hot water supply temperature set point"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u2 annotation (Placement(
        transformation(rotation=0, extent={{-140,80},{-100,120}}),
        iconTransformation(extent={{-140,80},{-100,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput u3 annotation (Placement(
        transformation(rotation=0, extent={{-140,40},{-100,80}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yVal "Mixing valve position"
    annotation (Placement(transformation(extent={{100,-80},{140,-40}}),
        iconTransformation(extent={{100,-80},{140,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TWatSupSet(final unit="K",
      displayUnit="degC") "Supply temperature of the selected tank" annotation
    (Placement(transformation(extent={{100,40},{140,80}}), iconTransformation(
          extent={{100,40},{140,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TTanTop(final unit="K",
      displayUnit="degC") "Water temperature of the selected tank" annotation (
      Placement(transformation(extent={{100,-20},{140,20}}), iconTransformation(
          extent={{100,-20},{140,20}})));
  ThermalGridJBA.Hubs.Controls.TwoTankCommand twoTanCom
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Buildings.Controls.OBC.CDL.Integers.Equal intEqu
    annotation (Placement(transformation(extent={{-10,60},{10,80}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conInt(k=3)
    annotation (Placement(transformation(extent={{-50,40},{-30,60}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swiTSup
    "Switch for water supply temperature set point"
    annotation (Placement(transformation(extent={{60,50},{80,70}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swiTTanTop
    "Switch for tank top temperature signal"
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea(realTrue=1,
      realFalse=0)
    annotation (Placement(transformation(extent={{60,-70},{80,-50}})));
equation
  connect(u2, twoTanCom.u2) annotation (Line(points={{-120,100},{-90,100},{-90,76},
          {-82,76}}, color={255,0,255}));
  connect(u3, twoTanCom.u3) annotation (Line(points={{-120,60},{-90,60},{-90,64},
          {-82,64}}, color={255,127,0}));
  connect(conInt.y, intEqu.u2) annotation (Line(points={{-28,50},{-20,50},{-20,62},
          {-12,62}}, color={255,127,0}));
  connect(twoTanCom.y, intEqu.u1)
    annotation (Line(points={{-58,70},{-12,70}}, color={255,127,0}));
  connect(intEqu.y, swiTSup.u2) annotation (Line(points={{12,70},{40,70},{40,60},
          {58,60}}, color={255,0,255}));
  connect(THotWatSupPreSet, swiTSup.u1) annotation (Line(points={{-120,-60},{30,
          -60},{30,68},{58,68}}, color={0,0,127}));
  connect(THeaWatSupPreSet, swiTSup.u3) annotation (Line(points={{-120,20},{20,20},
          {20,52},{58,52}}, color={0,0,127}));
  connect(swiTSup.y, TWatSupSet)
    annotation (Line(points={{82,60},{120,60}}, color={0,0,127}));
  connect(swiTTanTop.y, TTanTop)
    annotation (Line(points={{82,0},{120,0}}, color={0,0,127}));
  connect(intEqu.y, swiTTanTop.u2) annotation (Line(points={{12,70},{40,70},{40,
          0},{58,0}}, color={255,0,255}));
  connect(THeaWatTop, swiTTanTop.u3) annotation (Line(points={{-120,-20},{-60,-20},
          {-60,-8},{58,-8}}, color={0,0,127}));
  connect(THotWatTop, swiTTanTop.u1) annotation (Line(points={{-120,-100},{-100,
          -100},{-100,-98},{-80,-98},{-80,8},{58,8}}, color={0,0,127}));
  connect(booToRea.u, intEqu.y) annotation (Line(points={{58,-60},{40,-60},{40,70},
          {12,70}}, color={255,0,255}));
  connect(booToRea.y, yVal)
    annotation (Line(points={{82,-60},{120,-60}}, color={0,0,127}));
annotation(defaultComponentName="selTan");
end SelectTank;
