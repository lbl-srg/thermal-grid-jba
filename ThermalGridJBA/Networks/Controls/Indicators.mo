within ThermalGridJBA.Networks.Controls;
model Indicators "District load, electricity rate and season indicator"

  parameter Real TPlaHeaSet(
    unit="K",
    displayUnit="degC")=283.65
    "Design plant heating setpoint temperature"
    annotation (Dialog(group="Plant load"));
  parameter Real TPlaCooSet(
    unit="K",
    displayUnit="degC")=297.15
    "Design plant cooling setpoint temperature"
    annotation (Dialog(group="Plant load"));
  parameter Real TPlaSumCooSet(
    unit="K",
    displayUnit="degC")=TPlaCooSet-2
    "Design plant summer cooling setpoint temperature"
    annotation (Dialog(group="Plant load"));
  parameter Real TDryBulSum(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=297.15
    "Threshold of the dry bulb temperaure in summer below which starts charging borefield";
  parameter Real staDowDel(
    unit="s")=3600
    "Minimum stage down delay, to avoid quickly staging down"
    annotation (Dialog(group="Plant load"));
  parameter Integer winEndWee=12
    "Week that winter season ends after it"
    annotation (Dialog(group="Season"));
  parameter Integer winStaWee=44
    "Week that winter season starts at beginning of it"
    annotation (Dialog(group="Season"));
  parameter Integer sumStaWee=26
    "Week that summer season starts at beginning of it"
    annotation (Dialog(group="Season"));
  parameter Integer sumEndWee=36
    "Week that summer season ends after it"
    annotation (Dialog(group="Season"));
  parameter Real higRatSum=24.5
    "Summer high rate, cent per kWh"
    annotation (Dialog(group="Electricity rate"));
  parameter Real lowRatSum=12.0
    "Summer low rate, cent per kWh"
    annotation (Dialog(group="Electricity rate"));
  parameter Real higRatWin=20.9
    "Winter high rate, cent per kWh"
    annotation (Dialog(group="Electricity rate"));
  parameter Real lowRatWin=12.0
    "Winter low rate, cent per kWh"
    annotation (Dialog(group="Electricity rate"));
  parameter Integer sumPeaSta=15
    "Summer high rate starts at the beginning of this hour"
    annotation (Dialog(tab="Electricity rate"));
  parameter Integer sumPeaEnd=19
    "Summer high rate ends after the end of this hour"
    annotation (Dialog(tab="Electricity rate"));
  parameter Integer winLowEnd1=5
    "Winter low rate ends after the end of this hour"
    annotation (Dialog(tab="Electricity rate"));
  parameter Integer winLowSta1=9
    "Winter low rate starts at the beginning of this hour"
    annotation (Dialog(tab="Electricity rate"));
  parameter Integer winLowEnd2=16
    "Winter low rate ends after the end of this hour"
    annotation (Dialog(tab="Electricity rate"));
  parameter Integer winLowSta2=21
    "Winter low rate starts at the beginning of this hour"
    annotation (Dialog(tab="Electricity rate"));

  Buildings.Controls.OBC.CDL.Interfaces.RealInput TPlaOut(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC") "Central plant outlet water temperature"
    annotation (Placement(transformation(extent={{-280,200},{-240,240}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC") "Dry bulb temperature"
    annotation (Placement(transformation(extent={{-280,-20},{-240,20}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPlaOut
    "Plant load"
    annotation (Placement(transformation(extent={{240,120},{280,160}}),
        iconTransformation(extent={{100,60},{140,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TActPlaCooSet(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC")
    "Active plant cooling setpoint"
    annotation (Placement(transformation(extent={{240,30},{280,70}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput ySt
    "Load indicator"
    annotation (Placement(transformation(extent={{240,-40},{280,0}}),
        iconTransformation(extent={{100,0},{140,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yEle
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{240,-120},{280,-80}}),
        iconTransformation(extent={{100,-30},{140,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, dollar per kWh"
    annotation (Placement(transformation(extent={{240,-150},{280,-110}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput ySea
    "Season indicator: 1 winter; 2 spring; 3 summer; 4 fall"
    annotation (Placement(transformation(extent={{240,-200},{280,-160}}),
        iconTransformation(extent={{100,-100},{140,-60}})));

  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(final t=1/3, h=0.05)
    "Check if the speed is less than 1/3"
    annotation (Placement(transformation(extent={{-200,-30},{-180,-10}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(final t=2/3, h=0.05)
    "Check if the speed is greater than 2/3"
    annotation (Placement(transformation(extent={{-200,-70},{-180,-50}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi3 "Check district load"
    annotation (Placement(transformation(extent={{-40,-30},{-20,-10}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant lowLoa(final k=1)
    "Low district loop load"
    annotation (Placement(transformation(extent={{-160,-10},{-140,10}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High district loop load"
    annotation (Placement(transformation(extent={{-160,-50},{-140,-30}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi4 "Check district load"
    annotation (Placement(transformation(extent={{-100,-70},{-80,-50}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant medLoa(final k=2)
    "Medium district loop load"
    annotation (Placement(transformation(extent={{-160,-90},{-140,-70}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.TimeTable seaTab(
    table=[0,1; winEndWee,2; sumStaWee,3; sumEndWee,4; winStaWee,1],
    timeScale=7*24*3600,
    period(displayUnit="d") = 31536000)
    "Table that outputs season: 1 winter; 2 spring; 3 summer; 4 fall"
    annotation (Placement(transformation(extent={{60,-210},{80,-190}})));
  Buildings.Controls.OBC.CDL.Reals.Line plaHeaLoa "Plant heating load"
    annotation (Placement(transformation(extent={{20,180},{40,200}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one(
    final k=1) "Constant 1"
    annotation (Placement(transformation(extent={{-40,194},{-20,214}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant heaSet(
    y(unit="K", displayUnit="degC"),
    final k=TPlaHeaSet) "Plant heating setpoint"
    annotation (Placement(transformation(extent={{-84,214},{-64,234}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(
    final k=0) "Constant 0"
    annotation (Placement(transformation(extent={{-40,150},{-20,170}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant heaSetPlu(
    y(unit="K", displayUnit="degC"),
    final k=TPlaHeaSet + 1)
    "One degree higher than the plant heating setpoint"
    annotation (Placement(transformation(extent={{-80,150},{-60,170}})));
  Buildings.Controls.OBC.CDL.Reals.Line plaCooLoa "Plant cooling load"
    annotation (Placement(transformation(extent={{20,90},{40,110}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant negOne(
    final k=-1)
    "Constant -1"
    annotation (Placement(transformation(extent={{-20,60},{0,80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant cooSetNonSum(y(unit="K",
        displayUnit="degC"), final k=TPlaCooSet)
    "Plant cooling setpoint except for summer"
    annotation (Placement(transformation(extent={{-220,36},{-200,56}})));
  Buildings.Controls.OBC.CDL.Reals.Add plaLoa
    "Plant load"
    annotation (Placement(transformation(extent={{80,130},{100,150}})));
  Buildings.Controls.OBC.CDL.Reals.Abs absLoa
    "Absolute value of the plant load"
    annotation (Placement(transformation(extent={{120,90},{140,110}})));
  Buildings.Controls.OBC.CDL.Integers.Change cha(final pre_u_start=2)
    "Check if there is any stage change"
    annotation (Placement(transformation(extent={{20,-30},{40,-10}})));
  Buildings.Controls.OBC.CDL.Logical.Latch lat "Hold staging up"
    annotation (Placement(transformation(extent={{100,-30},{120,-10}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold truFalHol(final
      trueHoldDuration=staDowDel, final falseHoldDuration=0)
    "Ensure minimum delay to stage down"
    annotation (Placement(transformation(extent={{140,-30},{160,-10}})));
  Buildings.Controls.OBC.CDL.Integers.Switch plaLoaInd "Plant load indicator"
    annotation (Placement(transformation(extent={{200,-30},{220,-10}})));
  Buildings.Controls.OBC.CDL.Conversions.IntegerToReal intToRea
    "Convert integer to real"
    annotation (Placement(transformation(extent={{20,0},{40,20}})));
  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler triSam(final y_start=1)
    "Sample the load indicator when it starts staging up"
    annotation (Placement(transformation(extent={{60,0},{80,20}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt
    "Convert real to integer"
    annotation (Placement(transformation(extent={{120,0},{140,20}})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim(t=staDowDel)
    "Check if the minimum dealy has passed"
    annotation (Placement(transformation(extent={{200,-60},{220,-40}})));
  Buildings.Controls.OBC.CDL.Logical.Or or2
    "Check if there is staging down or the minimum delay has passed"
    annotation (Placement(transformation(extent={{60,-70},{80,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Pre pre "Break loop"
    annotation (Placement(transformation(extent={{20,-70},{40,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.TimeTable sumWin(
    table=[0,0; 152,1; 274,0],
    timeScale=24*3600,
    period(displayUnit="d") = 31536000)
    "Output summer or winter: true - in summer; false - in winter"
    annotation (Placement(transformation(extent={{-140,-140},{-120,-120}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.TimeTable sumRat(
    table=[0,lowRatSum; 15,higRatSum; 20,lowRatSum; 24,lowRatSum],
    smoothness=Buildings.Controls.OBC.CDL.Types.Smoothness.ConstantSegments,
    timeScale=3600) "Summer rate"
    annotation (Placement(transformation(extent={{-20,-120},{0,-100}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.TimeTable winRat(
    table=[0,lowRatWin; 6,higRatWin; 9,lowRatWin; 17,higRatWin; 21,lowRatWin;
        24,lowRatWin],
    smoothness=Buildings.Controls.OBC.CDL.Types.Smoothness.ConstantSegments,
    timeScale=3600) "Winter rate"
    annotation (Placement(transformation(extent={{-20,-160},{0,-140}})));
  Buildings.Controls.OBC.CDL.Reals.Switch eleRat "Electricity rate"
    annotation (Placement(transformation(extent={{60,-140},{80,-120}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold higRat(final t=lowRatSum)
    "Check if it is high rate"
    annotation (Placement(transformation(extent={{120,-110},{140,-90}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger ratInd
    "Convert to rate indicator"
    annotation (Placement(transformation(extent={{160,-110},{180,-90}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(k=1/100)
    "Convert cents to dollars"
    annotation (Placement(transformation(extent={{160,-140},{180,-120}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant cooSumSet(y(unit="K",
        displayUnit="degC"), final k=TPlaSumCooSet)
    "Plant summer cooling setpoint"
    annotation (Placement(transformation(extent={{-220,142},{-200,162}})));
  Buildings.Controls.OBC.CDL.Reals.Switch plaCooSet "Plant cooling setpoint"
    annotation (Placement(transformation(extent={{-140,52},{-120,72}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(final p=-1)
    "One degree  lower"
    annotation (Placement(transformation(extent={{-100,98},{-80,118}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum "In summer"
    annotation (Placement(transformation(extent={{160,-210},{180,-190}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sumInd(k=3)
    "Summer indicator"
    annotation (Placement(transformation(extent={{102,-230},{122,-210}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant cooSumSetHot(y(unit="K",
        displayUnit="degC"), final k=TPlaSumCooSet - 2)
    "Plant cooling setpoint during hot outdoor temperatures"
    annotation (Placement(transformation(extent={{-220,70},{-200,90}})));
  Buildings.Controls.OBC.CDL.Reals.Line plaCooSetSumShi(
    x1(final unit="K", displayUnit="degC"),
    f1(final unit="K", displayUnit="degC"),
    x2(final unit="K", displayUnit="degC"),
    f2(final unit="K", displayUnit="degC"),
    u(final unit="K", displayUnit="degC"),
    y(final unit="K", displayUnit="degC"))
    "Set point for plant during summer"
    annotation (Placement(transformation(extent={{-174,120},{-154,140}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TDryBulHig(y(unit="K",
        displayUnit="degC"), final k=TDryBulSum + 1)
    "High limit to shift cooling set point"
    annotation (Placement(transformation(extent={{-220,100},{-200,120}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TDryBulLow(y(unit="K",
        displayUnit="degC"), final k=TDryBulSum - 1)
    "Low limit to shift cooling set point"
    annotation (Placement(transformation(extent={{-220,180},{-200,200}})));
equation
  connect(lesThr.y, intSwi3.u2)
    annotation (Line(points={{-178,-20},{-42,-20}}, color={255,0,255}));
  connect(lowLoa.y, intSwi3.u1) annotation (Line(points={{-138,0},{-60,0},{-60,-12},
          {-42,-12}},          color={255,127,0}));
  connect(higLoa.y, intSwi4.u1) annotation (Line(points={{-138,-40},{-120,-40},{
          -120,-52},{-102,-52}},  color={255,127,0}));
  connect(greThr.y, intSwi4.u2)
    annotation (Line(points={{-178,-60},{-102,-60}},color={255,0,255}));
  connect(medLoa.y, intSwi4.u3) annotation (Line(points={{-138,-80},{-120,-80},{
          -120,-68},{-102,-68}}, color={255,127,0}));
  connect(intSwi4.y, intSwi3.u3) annotation (Line(points={{-78,-60},{-60,-60},{-60,
          -28},{-42,-28}},     color={255,127,0}));
  connect(seaTab.y[1],ySea)
    annotation (Line(points={{82,-200},{140,-200},{140,-180},{260,-180}},
                                                     color={255,127,0}));
  connect(heaSet.y, plaHeaLoa.x1) annotation (Line(points={{-62,224},{10,224},{10,
          198},{18,198}},      color={0,0,127}));
  connect(one.y, plaHeaLoa.f1) annotation (Line(points={{-18,204},{8,204},{8,194},
          {18,194}},       color={0,0,127}));
  connect(TPlaOut, plaHeaLoa.u)
    annotation (Line(points={{-260,220},{-100,220},{-100,190},{18,190}},
                                                    color={0,0,127}));
  connect(heaSetPlu.y, plaHeaLoa.x2) annotation (Line(points={{-58,160},{-48,160},
          {-48,186},{18,186}},   color={0,0,127}));
  connect(zer.y, plaHeaLoa.f2) annotation (Line(points={{-18,160},{0,160},{0,182},
          {18,182}},       color={0,0,127}));
  connect(TPlaOut, plaCooLoa.u) annotation (Line(points={{-260,220},{-100,220},{
          -100,190},{10,190},{10,100},{18,100}},
                                color={0,0,127}));
  connect(negOne.y, plaCooLoa.f2) annotation (Line(points={{2,70},{10,70},{10,92},
          {18,92}},            color={0,0,127}));
  connect(plaHeaLoa.y, plaLoa.u1) annotation (Line(points={{42,190},{60,190},{60,
          146},{78,146}}, color={0,0,127}));
  connect(plaCooLoa.y, plaLoa.u2) annotation (Line(points={{42,100},{60,100},{60,
          134},{78,134}}, color={0,0,127}));
  connect(plaLoa.y, yPlaOut)
    annotation (Line(points={{102,140},{260,140}},color={0,0,127}));
  connect(plaLoa.y, absLoa.u) annotation (Line(points={{102,140},{110,140},{110,
          100},{118,100}},
                     color={0,0,127}));
  connect(zer.y, plaCooLoa.f1) annotation (Line(points={{-18,160},{0,160},{0,104},
          {18,104}},           color={0,0,127}));
  connect(absLoa.y, greThr.u) annotation (Line(points={{142,100},{150,100},{150,
          30},{-220,30},{-220,-60},{-202,-60}},   color={0,0,127}));
  connect(absLoa.y, lesThr.u) annotation (Line(points={{142,100},{150,100},{150,
          30},{-220,30},{-220,-20},{-202,-20}},   color={0,0,127}));
  connect(intSwi3.y, cha.u) annotation (Line(points={{-18,-20},{18,-20}},
                     color={255,127,0}));
  connect(cha.up, lat.u) annotation (Line(points={{42,-14},{70,-14},{70,-20},{98,
          -20}},    color={255,0,255}));
  connect(lat.y, truFalHol.u)
    annotation (Line(points={{122,-20},{138,-20}}, color={255,0,255}));
  connect(truFalHol.y, plaLoaInd.u2)
    annotation (Line(points={{162,-20},{198,-20}}, color={255,0,255}));
  connect(intSwi3.y, plaLoaInd.u3) annotation (Line(points={{-18,-20},{0,-20},{0,
          -40},{180,-40},{180,-28},{198,-28}}, color={255,127,0}));
  connect(intSwi3.y, intToRea.u) annotation (Line(points={{-18,-20},{0,-20},{0,10},
          {18,10}},       color={255,127,0}));
  connect(intToRea.y, triSam.u)
    annotation (Line(points={{42,10},{58,10}},   color={0,0,127}));
  connect(triSam.y, reaToInt.u)
    annotation (Line(points={{82,10},{118,10}},   color={0,0,127}));
  connect(cha.up, triSam.trigger)
    annotation (Line(points={{42,-14},{70,-14},{70,-2}},  color={255,0,255}));
  connect(reaToInt.y, plaLoaInd.u1) annotation (Line(points={{142,10},{180,10},{
          180,-12},{198,-12}},  color={255,127,0}));
  connect(truFalHol.y, tim.u) annotation (Line(points={{162,-20},{190,-20},{190,
          -50},{198,-50}}, color={255,0,255}));
  connect(cha.down, or2.u1) annotation (Line(points={{42,-26},{52,-26},{52,-60},
          {58,-60}},color={255,0,255}));
  connect(tim.passed, pre.u) annotation (Line(points={{222,-58},{230,-58},{230,-80},
          {10,-80},{10,-60},{18,-60}},
                                    color={255,0,255}));
  connect(pre.y, or2.u2) annotation (Line(points={{42,-60},{46,-60},{46,-68},{58,
          -68}},color={255,0,255}));
  connect(or2.y, lat.clr) annotation (Line(points={{82,-60},{90,-60},{90,-26},{98,
          -26}},          color={255,0,255}));
  connect(plaLoaInd.y, ySt)
    annotation (Line(points={{222,-20},{260,-20}}, color={255,127,0}));
  connect(sumWin.y[1], eleRat.u2)
    annotation (Line(points={{-118,-130},{58,-130}}, color={255,0,255}));
  connect(sumRat.y[1], eleRat.u1) annotation (Line(points={{2,-110},{40,-110},{40,
          -122},{58,-122}},    color={0,0,127}));
  connect(winRat.y[1], eleRat.u3) annotation (Line(points={{2,-150},{40,-150},{40,
          -138},{58,-138}},    color={0,0,127}));
  connect(eleRat.y, higRat.u) annotation (Line(points={{82,-130},{100,-130},{100,
          -100},{118,-100}},     color={0,0,127}));
  connect(higRat.y, ratInd.u)
    annotation (Line(points={{142,-100},{158,-100}}, color={255,0,255}));
  connect(ratInd.y, yEle)
    annotation (Line(points={{182,-100},{260,-100}}, color={255,127,0}));
  connect(eleRat.y, gai1.u)
    annotation (Line(points={{82,-130},{158,-130}}, color={0,0,127}));
  connect(gai1.y, yEleRat)
    annotation (Line(points={{182,-130},{260,-130}}, color={0,0,127}));
  connect(cooSetNonSum.y, plaCooSet.u3) annotation (Line(points={{-198,46},{-170,
          46},{-170,54},{-142,54}}, color={0,0,127}));
  connect(plaCooSet.y, plaCooLoa.x2) annotation (Line(points={{-118,62},{-70,62},
          {-70,96},{18,96}},   color={0,0,127}));
  connect(addPar.y, plaCooLoa.x1) annotation (Line(points={{-78,108},{18,108}},
                              color={0,0,127}));
  connect(plaCooSet.y, addPar.u) annotation (Line(points={{-118,62},{-110,62},{-110,
          108},{-102,108}}, color={0,0,127}));
  connect(sumInd.y, inSum.u2) annotation (Line(points={{124,-220},{140,-220},{140,
          -208},{158,-208}},     color={255,127,0}));
  connect(seaTab.y[1], inSum.u1) annotation (Line(points={{82,-200},{158,-200}},
                                  color={255,127,0}));
  connect(inSum.y, plaCooSet.u2) annotation (Line(points={{182,-200},{204,-200},
          {204,-170},{-226,-170},{-226,62},{-142,62}}, color={255,0,255}));
  connect(plaCooSet.y, TActPlaCooSet) annotation (Line(points={{-118,62},{-110,
          62},{-110,50},{260,50}},
                               color={0,0,127}));
  connect(TDryBul, plaCooSetSumShi.u) annotation (Line(points={{-260,0},{-228,0},
          {-228,130},{-176,130}}, color={0,0,127}));
  connect(plaCooSetSumShi.y, plaCooSet.u1) annotation (Line(points={{-152,130},{
          -150,130},{-150,70},{-142,70}}, color={0,0,127}));
  connect(TDryBulLow.y, plaCooSetSumShi.x1) annotation (Line(points={{-198,190},
          {-184,190},{-184,138},{-176,138}}, color={0,0,127}));
  connect(plaCooSetSumShi.x2, TDryBulHig.y) annotation (Line(points={{-176,126},
          {-186,126},{-186,110},{-198,110}}, color={0,0,127}));
  connect(plaCooSetSumShi.f2, cooSumSetHot.y) annotation (Line(points={{-176,
          122},{-182,122},{-182,80},{-198,80}}, color={0,0,127}));
  connect(cooSumSet.y, plaCooSetSumShi.f1) annotation (Line(points={{-198,152},
          {-194,152},{-194,134},{-176,134}}, color={0,0,127}));
annotation (defaultComponentName="ind",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-108,144},{92,104}},
          textString="%name",
          textColor={0,0,255})}),
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-240,-240},{240,240}})),
Documentation(info="
<html>
<p>
It outputs the indicators for current plant load <code>ySt</code>, electricity
rate <code>yEleRat</code>, and the season <code>ySea</code>.
</p>
<h4>Electricity rate indicator</h4>
<p>
Based on the current electricity rate, the electricity rate indicator is either set
to normal rates or high rates.
</p>
<ul>
<li>
Summer rates are from June to September. High rates are 15:00 to 20:00 at 24.5 &cent;/kWh
(<code>higRatSum</code>) and otherwise it is low rates at 12.0 &cent;/kWh
(<code>lowRatSum</code>).
</li>
<li>
Winter rates are from October to May. Low rates are 00:00 to 6:00, 9:00 to 17:00, and
21:00 to 24:00 at 12.0 &cent;/kWh (<code>lowRatWin</code>), and otherwise it is
high rate at 20.9 &cent;/kWh (<code>higRatWin</code>).
</li>
</ul>
<h4>Plant load indicator</h4>
<p>
The plant control signal <code>yPlaOut</code> can be computed based on the measured
plant outlet temperature <code>TPlaOut</code>, as shown 
</p>
<p align=\"center\">
<img src=\"modelica://ThermalGridJBA/Resources/Images/Networks/Controls/plantLoad.png\"
     alt=\"plantLoad.png\" />
</p>
<p>
The plant load indicator is then:
</p>
<ul>
<li>
If <code>|yPlaOut|</code> &ge; 0 and <code>|yPlaOut|</code> &lt; 1/3,
then <code>ySt</code> = 1;
</li>
<li>
Else if <code>|yPlaOut|</code> &ge; 1/3 and <code>|yPlaOut|</code> &lt; 2/3,
then <code>ySt</code> = 2;
</li>
<li>
Else, <code>ySt</code> = 3.
</li>
</ul>
<h4>Seanson indicator</h4>
<p>
Based on the week of the year, the plant is either in winter, spring, summer or
fall mode. Determining the switch-over time is done offline based on the net heating
and cooling load analysis of the thermal energy network. The season indicator is used
to determine whether the central plant should add heat or cold to the system if the
electrical rates are normal. Therefore, we set the season indicator to
</p>
<ul>
<li>
If current week is later than the winter start week <code>winStaWee</code>, or earlier
than winter end week <code>winEndWee</code>, it is in winter. Thus,
<code>ySea</code> = 1.
</li>
<li>
Else if current week is later than the winter end week <code>winEndWee</code> and
earlier than summer start week <code>sumStaWee</code>, it is in spring. Thus,
<code>ySa</code> = 2.
</li>
<li>
Else if current week is later than the summer start week <code>sumStaWee</code> and
earlier than summer end week <code>sumEndWee</code>, it is in summer. Thus,
<code>ySea</code> = 3.
</li>
<li>
Else, it is in fall. Thus, <code>ySea</code> = 4.
</li>
</ul>
</html>", revisions="<html>
<ul>
<li>
January 31, 2025, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"));
end Indicators;
