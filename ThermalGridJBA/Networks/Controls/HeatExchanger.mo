within ThermalGridJBA.Networks.Controls;
block HeatExchanger
  "Heat exchanger, the associated pump and valves control"

  parameter Real mHexGly_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal glycol mass flow rate for heat exchanger";
  parameter Real TApp(
    final quantity="TemperatureDifference",
    final unit="K")=4
    "Approach temperature for checking if the economizer should be enabled";
  parameter Real THys=0.1 "Hysteresis for comparing temperature"
    annotation (Dialog(tab="Advanced"));

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{-320,130},{-280,170}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "Plant load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-320,100},{-280,140}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSea
    "Season indicator. 1-Winter; 2-Spring; 3-Summer; 4-Fall"
    annotation (Placement(transformation(extent={{-320,70},{-280,110}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TPlaIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water into the central plant"
    annotation (Placement(transformation(extent={{-320,-40},{-280,0}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-320,-80},{-280,-40}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput on
    "Output true if heat exchanger is commanded on" annotation (Placement(
        transformation(extent={{280,80},{320,120}}), iconTransformation(extent=
            {{100,60},{140,100}})));

  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHexByp(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger bypass valve position setpoint"
    annotation (Placement(transformation(extent={{280,20},{320,60}}),
        iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHex(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger valve position setpoint"
    annotation (Placement(transformation(extent={{280,-20},{320,20}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumHex(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat exchanger pump speed setpoint"
    annotation (Placement(transformation(extent={{280,-60},{320,-20}}),
        iconTransformation(extent={{100,-60},{140,-20}})));

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-260,200},{-240,220}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(final k=1) "Winter"
    annotation (Placement(transformation(extent={{-60,200},{-40,220}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum(final k=3) "Summer"
    annotation (Placement(transformation(extent={{-60,170},{-40,190}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higEleRat "High electricity rate"
    annotation (Placement(transformation(extent={{-200,140},{-180,160}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin "In Winter"
    annotation (Placement(transformation(extent={{20,140},{40,160}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum "In Summer"
    annotation (Placement(transformation(extent={{20,100},{40,120}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(
    final p=-TApp)
    annotation (Placement(transformation(extent={{-260,-70},{-240,-50}})));
  Buildings.Controls.OBC.CDL.Reals.Less warAmb(
    final h=THys) "Warm ambient"
    annotation (Placement(transformation(extent={{-200,-30},{-180,-10}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(
    final p=TApp)
    annotation (Placement(transformation(extent={{-260,-110},{-240,-90}})));
  Buildings.Controls.OBC.CDL.Reals.Greater colAmb(
    final h=THys) "Cold ambient"
    annotation (Placement(transformation(extent={{-200,-90},{-180,-70}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant lowLoa(final k=1)
    "Low plant load"
    annotation (Placement(transformation(extent={{-180,200},{-160,220}})));
  Buildings.Controls.OBC.CDL.Integers.Equal lowPlaLoa "Low plant load"
    annotation (Placement(transformation(extent={{-120,140},{-100,160}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatNotLow
    "High rate and plant load is not low"
    annotation (Placement(transformation(extent={{0,30},{20,50}})));
  Buildings.Controls.OBC.CDL.Logical.Not notLowLoa "Plant load is not low"
    annotation (Placement(transformation(extent={{-60,50},{-40,70}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatNotLowWin
    "High rate and plant load is not low, in Winter"
    annotation (Placement(transformation(extent={{80,10},{100,30}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatNotLowWin1
    "High rate and plant load is not low, in Winter"
    annotation (Placement(transformation(extent={{120,-10},{140,10}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatNotLowSum
    "High rate and plant load is not low, in Summer"
    annotation (Placement(transformation(extent={{80,-40},{100,-20}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatNotLowSum1
    "High rate and plant load is not low, in Summer"
    annotation (Placement(transformation(extent={{120,-60},{140,-40}})));
  Buildings.Controls.OBC.CDL.Logical.Not norRat "Normal rate"
    annotation (Placement(transformation(extent={{-120,-150},{-100,-130}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatWin "Normal rate in Winter"
    annotation (Placement(transformation(extent={{80,-120},{100,-100}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatWin1 "Normal rate in Winter"
    annotation (Placement(transformation(extent={{120,-140},{140,-120}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSum "Normal rate in Summer"
    annotation (Placement(transformation(extent={{80,-180},{100,-160}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSum1 "Normal rate in Summer"
    annotation (Placement(transformation(extent={{120,-200},{140,-180}})));
  Buildings.Controls.OBC.CDL.Logical.Or ena "Enable economizer"
    annotation (Placement(transformation(extent={{162,-10},{182,10}})));
  Buildings.Controls.OBC.CDL.Logical.Or ena1 "Enable economizer"
    annotation (Placement(transformation(extent={{162,-140},{182,-120}})));
  Buildings.Controls.OBC.CDL.Logical.Or ena2 "Enable economizer"
    annotation (Placement(transformation(extent={{200,-10},{220,10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal byPasVal(final realTrue=0,
      final realFalse=1) "Bypass valve position"
    annotation (Placement(transformation(extent={{240,30},{260,50}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal hexVal
    "HEX valve position"
    annotation (Placement(transformation(extent={{240,-10},{260,10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal hexGlyPum(final realTrue
      =mHexGly_flow_nominal) "Heat exchanger glyco side pump speed setpoint"
    annotation (Placement(transformation(extent={{240,-50},{260,-30}})));

equation
  connect(uEleRat, higEleRat.u1)
    annotation (Line(points={{-300,150},{-202,150}}, color={255,127,0}));
  connect(higRat.y, higEleRat.u2) annotation (Line(points={{-238,210},{-220,210},
          {-220,142},{-202,142}}, color={255,127,0}));
  connect(uSea, inWin.u2) annotation (Line(points={{-300,90},{-40,90},{-40,142},
          {18,142}},  color={255,127,0}));
  connect(uSea, inSum.u2) annotation (Line(points={{-300,90},{-40,90},{-40,102},
          {18,102}},  color={255,127,0}));
  connect(win.y, inWin.u1) annotation (Line(points={{-38,210},{-12,210},{-12,150},
          {18,150}},  color={255,127,0}));
  connect(sum.y, inSum.u1) annotation (Line(points={{-38,180},{-20,180},{-20,110},
          {18,110}},  color={255,127,0}));
  connect(TPlaIn, warAmb.u1)
    annotation (Line(points={{-300,-20},{-202,-20}}, color={0,0,127}));
  connect(addPar.y, warAmb.u2) annotation (Line(points={{-238,-60},{-220,-60},{-220,
          -28},{-202,-28}}, color={0,0,127}));
  connect(TDryBul, addPar.u)
    annotation (Line(points={{-300,-60},{-262,-60}}, color={0,0,127}));
  connect(TDryBul, addPar1.u) annotation (Line(points={{-300,-60},{-270,-60},{-270,
          -100},{-262,-100}}, color={0,0,127}));
  connect(TPlaIn, colAmb.u1) annotation (Line(points={{-300,-20},{-230,-20},{-230,
          -80},{-202,-80}}, color={0,0,127}));
  connect(addPar1.y, colAmb.u2) annotation (Line(points={{-238,-100},{-220,-100},
          {-220,-88},{-202,-88}},color={0,0,127}));
  connect(uSt, lowPlaLoa.u2) annotation (Line(points={{-300,120},{-140,120},{-140,
          142},{-122,142}}, color={255,127,0}));
  connect(lowLoa.y, lowPlaLoa.u1) annotation (Line(points={{-158,210},{-140,210},
          {-140,150},{-122,150}}, color={255,127,0}));
  connect(lowPlaLoa.y, notLowLoa.u) annotation (Line(points={{-98,150},{-80,150},
          {-80,60},{-62,60}}, color={255,0,255}));
  connect(higEleRat.y, higRatNotLow.u2) annotation (Line(points={{-178,150},{-160,
          150},{-160,32},{-2,32}}, color={255,0,255}));
  connect(notLowLoa.y, higRatNotLow.u1) annotation (Line(points={{-38,60},{-20,60},
          {-20,40},{-2,40}}, color={255,0,255}));
  connect(higRatNotLow.y, higRatNotLowWin.u2) annotation (Line(points={{22,40},{
          40,40},{40,12},{78,12}}, color={255,0,255}));
  connect(inWin.y, higRatNotLowWin.u1) annotation (Line(points={{42,150},{70,150},
          {70,20},{78,20}}, color={255,0,255}));
  connect(higRatNotLowWin.y, higRatNotLowWin1.u1) annotation (Line(points={{102,
          20},{110,20},{110,0},{118,0}}, color={255,0,255}));
  connect(warAmb.y, higRatNotLowWin1.u2) annotation (Line(points={{-178,-20},{0,
          -20},{0,-8},{118,-8}}, color={255,0,255}));
  connect(inSum.y, higRatNotLowSum.u1) annotation (Line(points={{42,110},{60,110},
          {60,-30},{78,-30}}, color={255,0,255}));
  connect(higRatNotLow.y, higRatNotLowSum.u2) annotation (Line(points={{22,40},{
          40,40},{40,-38},{78,-38}}, color={255,0,255}));
  connect(higRatNotLowSum.y, higRatNotLowSum1.u1) annotation (Line(points={{102,
          -30},{110,-30},{110,-50},{118,-50}}, color={255,0,255}));
  connect(colAmb.y, higRatNotLowSum1.u2) annotation (Line(points={{-178,-80},{-20,
          -80},{-20,-58},{118,-58}}, color={255,0,255}));
  connect(higEleRat.y, norRat.u) annotation (Line(points={{-178,150},{-160,150},
          {-160,-140},{-122,-140}}, color={255,0,255}));
  connect(norRat.y, norRatWin.u2) annotation (Line(points={{-98,-140},{-80,-140},
          {-80,-118},{78,-118}},  color={255,0,255}));
  connect(inWin.y, norRatWin.u1) annotation (Line(points={{42,150},{70,150},{70,
          -110},{78,-110}}, color={255,0,255}));
  connect(norRatWin.y, norRatWin1.u1) annotation (Line(points={{102,-110},{110,-110},
          {110,-130},{118,-130}}, color={255,0,255}));
  connect(warAmb.y, norRatWin1.u2) annotation (Line(points={{-178,-20},{0,-20},{
          0,-138},{118,-138}}, color={255,0,255}));
  connect(norRat.y, norRatSum.u2) annotation (Line(points={{-98,-140},{-80,-140},
          {-80,-178},{78,-178}},  color={255,0,255}));
  connect(inSum.y, norRatSum.u1) annotation (Line(points={{42,110},{60,110},{60,
          -170},{78,-170}}, color={255,0,255}));
  connect(norRatSum.y, norRatSum1.u1) annotation (Line(points={{102,-170},{110,-170},
          {110,-190},{118,-190}}, color={255,0,255}));
  connect(colAmb.y, norRatSum1.u2) annotation (Line(points={{-178,-80},{-20,-80},
          {-20,-198},{118,-198}}, color={255,0,255}));
  connect(higRatNotLowWin1.y, ena.u1)
    annotation (Line(points={{142,0},{160,0}}, color={255,0,255}));
  connect(higRatNotLowSum1.y, ena.u2) annotation (Line(points={{142,-50},{150,-50},
          {150,-8},{160,-8}}, color={255,0,255}));
  connect(norRatWin1.y, ena1.u1)
    annotation (Line(points={{142,-130},{160,-130}}, color={255,0,255}));
  connect(norRatSum1.y, ena1.u2) annotation (Line(points={{142,-190},{150,-190},
          {150,-138},{160,-138}}, color={255,0,255}));
  connect(ena.y, ena2.u1)
    annotation (Line(points={{184,0},{198,0}}, color={255,0,255}));
  connect(ena1.y, ena2.u2) annotation (Line(points={{184,-130},{190,-130},{190,-8},
          {198,-8}}, color={255,0,255}));
  connect(ena2.y, hexVal.u)
    annotation (Line(points={{222,0},{238,0}}, color={255,0,255}));
  connect(hexVal.y, yValHex)
    annotation (Line(points={{262,0},{300,0}}, color={0,0,127}));
  connect(hexGlyPum.y, yPumHex)
    annotation (Line(points={{262,-40},{300,-40}}, color={0,0,127}));
  connect(ena2.y, byPasVal.u) annotation (Line(points={{222,0},{230,0},{230,40},
          {238,40}}, color={255,0,255}));
  connect(ena2.y, hexGlyPum.u) annotation (Line(points={{222,0},{230,0},{230,-40},
          {238,-40}}, color={255,0,255}));
  connect(byPasVal.y, yValHexByp)
    annotation (Line(points={{262,40},{300,40}}, color={0,0,127}));

  connect(ena2.y, on) annotation (Line(points={{222,0},{230,0},{230,100},{300,
          100}},
        color={255,0,255}));
annotation (defaultComponentName="hexCon",
Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics={Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-280,-240},{280,240}})));
end HeatExchanger;
