within ThermalGridJBA.Hubs.Controls;
block TankChargingTwoSpeed
  extends Modelica.Blocks.Icons.Block;

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TTan[3](
    each final unit="K",
    each displayUnit="degC") "Temperature vector of the tank" annotation (
      Placement(transformation(extent={{-140,-80},{-100,-40}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSet(
    each final unit="K",
    each displayUnit="degC") "Temperature set point" annotation (Placement(
        transformation(extent={{-140,40},{-100,80}}), iconTransformation(extent
          ={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput y
    "Connector of Integer output signal"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  TankChargingController tanChaFas(hysTop=-1, hysBot=-1)
    "Charge fast when top temperature too low"
    annotation (Placement(transformation(extent={{-50,40},{-30,60}})));
  TankChargingController tanChaSlo(hysTop=-1, hysBot=-1)
    "Charge slowly when top temperature too low"
    annotation (Placement(transformation(extent={{-50,-60},{-30,-40}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold holFas(trueHoldDuration=
        900) annotation (Placement(transformation(extent={{-20,40},{0,60}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold holSlo(trueHoldDuration=
        900)
    annotation (Placement(transformation(extent={{-20,-60},{0,-40}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger booToIntEmp
    annotation (Placement(transformation(extent={{10,40},{30,60}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger booToIntLow
    annotation (Placement(transformation(extent={{10,-60},{30,-40}})));
  Buildings.Controls.OBC.CDL.Integers.Add addInt
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Controls.OBC.CDL.Integers.AddParameter addPar(p=1)
    annotation (Placement(transformation(extent={{70,-10},{90,10}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter dTOff(p=-2) "Offset"
    annotation (Placement(transformation(extent={{-90,50},{-70,70}})));
equation
  connect(TTan[1], tanChaFas.TTanTop) annotation (Line(points={{-120,-66.6667},
          {-120,-60},{-56,-60},{-56,50},{-52,50}},color={0,0,127}));
  connect(TTan[2], tanChaFas.TTanBot) annotation (Line(points={{-120,-60},{-56,
          -60},{-56,42},{-52,42}},
                              color={0,0,127}));
  connect(TTan[2], tanChaSlo.TTanTop) annotation (Line(points={{-120,-60},{-56,
          -60},{-56,-50},{-52,-50}},
                                color={0,0,127}));
  connect(TTan[3], tanChaSlo.TTanBot) annotation (Line(points={{-120,-53.3333},
          {-120,-60},{-56,-60},{-56,-58},{-52,-58}},color={0,0,127}));
  connect(holFas.y,booToIntEmp. u)
    annotation (Line(points={{2,50},{8,50}},   color={255,0,255}));
  connect(holSlo.y,booToIntLow. u)
    annotation (Line(points={{2,-50},{8,-50}},   color={255,0,255}));
  connect(booToIntEmp.y,addInt. u1) annotation (Line(points={{32,50},{36,50},{
          36,6},{38,6}},
                      color={255,127,0}));
  connect(addInt.u2,booToIntLow. y) annotation (Line(points={{38,-6},{36,-6},{
          36,-50},{32,-50}},
                          color={255,127,0}));
  connect(addInt.y,addPar. u)
    annotation (Line(points={{62,0},{68,0}}, color={255,127,0}));
  connect(tanChaFas.charge, holFas.u)
    annotation (Line(points={{-28,50},{-22,50}}, color={255,0,255}));
  connect(holSlo.u, tanChaSlo.charge)
    annotation (Line(points={{-22,-50},{-28,-50}}, color={255,0,255}));
  connect(addPar.y, y)
    annotation (Line(points={{92,0},{120,0}}, color={255,127,0}));
  connect(dTOff.u, TSet)
    annotation (Line(points={{-92,60},{-120,60}}, color={0,0,127}));
  connect(dTOff.y, tanChaFas.TTanTopSet) annotation (Line(points={{-68,60},{-64,
          60},{-64,58},{-51,58}}, color={0,0,127}));
  connect(dTOff.y, tanChaSlo.TTanTopSet) annotation (Line(points={{-68,60},{-64,
          60},{-64,-42},{-51,-42}}, color={0,0,127}));
annotation(defaultComponentName="tanChaTwoSpe");
end TankChargingTwoSpeed;
