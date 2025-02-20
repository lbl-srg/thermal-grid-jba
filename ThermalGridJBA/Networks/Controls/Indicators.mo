within ThermalGridJBA.Networks.Controls;
model Indicators "District load, electricity rate and season indicator"

  parameter Integer winEndWee=14
    "Week that winter season ends after it"
    annotation (Dialog(group="Season"));
  parameter Integer winStaWee=45
    "Week that winter season starts at beginning of it"
    annotation (Dialog(group="Season"));
  parameter Integer sumStaWee=24
    "Week that summer season starts at beginning of it"
    annotation (Dialog(group="Season"));
  parameter Integer sumEndWee=40
    "Week that summer season ends after it"
    annotation (Dialog(group="Season"));
  parameter Real samplePeriod=7200
    "Sample period of district loop pump speed"
    annotation (Dialog(group="District load"));
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

  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum
    "District loop pump speed"
    annotation (Placement(transformation(extent={{-280,240},{-240,280}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uSolTim
    "Solar time. An output from weather data"
    annotation (Placement(transformation(extent={{-280,-154},{-240,-114}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput ySt
    "District loop load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{240,240},{280,280}}),
        iconTransformation(extent={{100,40},{140,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yEle
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{240,100},{280,140}}),
        iconTransformation(extent={{100,-10},{140,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, cent per kWh"
    annotation (Placement(transformation(extent={{240,20},{280,60}}),
        iconTransformation(extent={{100,-30},{140,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yGen
    "Season indicator. 1-winter; 2-shoulder; 3-summer"
    annotation (Placement(transformation(extent={{240,-200},{280,-160}}),
        iconTransformation(extent={{100,-80},{140,-40}})));

  Buildings.Controls.OBC.CDL.Reals.Divide wee "Week of the year"
    annotation (Placement(transformation(extent={{-160,-150},{-140,-130}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(
    final k=7*24*3600) "One week"
    annotation (Placement(transformation(extent={{-220,-170},{-200,-150}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold winEnd(
    final t=winEndWee) "Winter end week"
    annotation (Placement(transformation(extent={{-100,-150},{-80,-130}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold winSta(
    final t=winStaWee) "Winter start week"
    annotation (Placement(transformation(extent={{-100,-190},{-80,-170}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi "Check season"
    annotation (Placement(transformation(extent={{100,-190},{120,-170}})));
  Buildings.Controls.OBC.CDL.Logical.Or win "Check if it is in winter"
    annotation (Placement(transformation(extent={{-40,-150},{-20,-130}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant winInd(
    final k=1) "Winter indicator"
    annotation (Placement(transformation(extent={{40,-160},{60,-140}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold sumSta(
    final t=sumStaWee)
    "Summer start week"
    annotation (Placement(transformation(extent={{-100,-230},{-80,-210}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold sumEnd(
    final t=sumEndWee)
    "Summer End week"
    annotation (Placement(transformation(extent={{-100,-260},{-80,-240}})));
  Buildings.Controls.OBC.CDL.Logical.And sum "Check if it is in summer"
    annotation (Placement(transformation(extent={{-40,-230},{-20,-210}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi1 "Check season"
    annotation (Placement(transformation(extent={{20,-230},{40,-210}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sumInd(final k=3)
    "Summer indicator"
    annotation (Placement(transformation(extent={{-40,-190},{-20,-170}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant shoInd(final k=2)
    "Shoulder season indicator"
    annotation (Placement(transformation(extent={{-40,-270},{-20,-250}})));
  Buildings.Controls.OBC.CDL.Discrete.Sampler sam(
    final samplePeriod=samplePeriod)
    "District loop load sampler"
    annotation (Placement(transformation(extent={{-220,250},{-200,270}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(final t=1/3)
    "Check if the speed is less than 1/3"
    annotation (Placement(transformation(extent={{-160,250},{-140,270}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(final t=2/3)
    "Check if the speed is greater than 2/3"
    annotation (Placement(transformation(extent={{-160,210},{-140,230}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi3 "Check district load"
    annotation (Placement(transformation(extent={{40,250},{60,270}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant lowLoa(final k=1)
    "Low district loop load"
    annotation (Placement(transformation(extent={{-80,270},{-60,290}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High district loop load"
    annotation (Placement(transformation(extent={{-80,230},{-60,250}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi4 "Check district load"
    annotation (Placement(transformation(extent={{-20,210},{0,230}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant medLoa(final k=2)
    "Medium district loop load"
    annotation (Placement(transformation(extent={{-80,190},{-60,210}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.CalendarTime calTim(
    final zerTim=Buildings.Controls.OBC.CDL.Types.ZeroTime.NY2025)
    "Calendar time"
    annotation (Placement(transformation(extent={{-220,120},{-200,140}})));
  Buildings.Controls.OBC.CDL.Integers.GreaterEqualThreshold aftJun(final t=6)
    "After June"
    annotation (Placement(transformation(extent={{-180,120},{-160,140}})));
  Buildings.Controls.OBC.CDL.Integers.LessEqualThreshold earSep(final t=9)
    "Earlier than September"
    annotation (Placement(transformation(extent={{-180,90},{-160,110}})));
  Buildings.Controls.OBC.CDL.Integers.GreaterEqualThreshold fouPm(
    final t=sumPeaSta)
    "Later than 4PM"
    annotation (Placement(transformation(extent={{-180,60},{-160,80}})));
  Buildings.Controls.OBC.CDL.Integers.LessEqualThreshold senPm(
    final t=sumPeaEnd)
    "Earlier than 7PM"
    annotation (Placement(transformation(extent={{-180,30},{-160,50}})));
  Buildings.Controls.OBC.CDL.Logical.And inSum
    "Check if it is in summer rate period"
    annotation (Placement(transformation(extent={{-140,120},{-120,140}})));
  Buildings.Controls.OBC.CDL.Logical.And sumHig
    "Check if it is in summer high rate period"
    annotation (Placement(transformation(extent={{-140,60},{-120,80}})));
  Buildings.Controls.OBC.CDL.Logical.And sumHigRat
    "Check if it is in summer high rate period"
    annotation (Placement(transformation(extent={{-20,120},{0,140}})));
  Buildings.Controls.OBC.CDL.Logical.Not sumLow "Summer low rate"
    annotation (Placement(transformation(extent={{-80,40},{-60,60}})));
  Buildings.Controls.OBC.CDL.Logical.And sumLowRat
    "Check if it is in summer low rate period"
    annotation (Placement(transformation(extent={{-20,70},{0,90}})));
  Buildings.Controls.OBC.CDL.Integers.LessEqualThreshold sixAm(
    final t=winLowEnd1)
    "Earlier than 6AM"
    annotation (Placement(transformation(extent={{-180,-10},{-160,10}})));
  Buildings.Controls.OBC.CDL.Integers.GreaterEqualThreshold ninAm(
    final t=winLowSta1)
    "Later than 9AM"
    annotation (Placement(transformation(extent={{-180,-40},{-160,-20}})));
  Buildings.Controls.OBC.CDL.Integers.LessEqualThreshold fivPm(
    final t=winLowEnd2)
    "Earlier than 5PM"
    annotation (Placement(transformation(extent={{-180,-70},{-160,-50}})));
  Buildings.Controls.OBC.CDL.Integers.GreaterEqualThreshold ninPm1(
    final t=winLowSta2)
    "Later than 9PM"
    annotation (Placement(transformation(extent={{-180,-100},{-160,-80}})));
  Buildings.Controls.OBC.CDL.Logical.And ninToFiv
    "Check if it is between 9AM and 5PM"
    annotation (Placement(transformation(extent={{-140,-40},{-120,-20}})));
  Buildings.Controls.OBC.CDL.Logical.Or winLow
    "Winter low rate period"
    annotation (Placement(transformation(extent={{-100,-20},{-80,0}})));
  Buildings.Controls.OBC.CDL.Logical.Or winLow1
    "Winter low rate period"
    annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));
  Buildings.Controls.OBC.CDL.Logical.Not inWin
    "In winter"
    annotation (Placement(transformation(extent={{-100,10},{-80,30}})));
  Buildings.Controls.OBC.CDL.Logical.And winLowRat
    "Check if it is in winter low rate period"
    annotation (Placement(transformation(extent={{0,-20},{20,0}})));
  Buildings.Controls.OBC.CDL.Logical.Not winHig "Winter high rate"
    annotation (Placement(transformation(extent={{0,-58},{20,-38}})));
  Buildings.Controls.OBC.CDL.Logical.And winHihRat
    "Check if it is in winter high rate period"
    annotation (Placement(transformation(extent={{40,-80},{60,-60}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea(
    final realTrue=higRatSum)
    "Convert to summer high rate"
    annotation (Placement(transformation(extent={{40,80},{60,100}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger booToInt
    "Convert to high rate flag"
    annotation (Placement(transformation(extent={{40,120},{60,140}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea1(
    final realTrue=lowRatSum)
    "Convert to summer low rate"
    annotation (Placement(transformation(extent={{42,40},{62,60}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger booToInt1
    "Convert to high rate flag"
    annotation (Placement(transformation(extent={{100,-80},{120,-60}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea2(
    final realTrue=lowRatWin)
    "Convert to winter low rate"
    annotation (Placement(transformation(extent={{40,-20},{60,0}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea3(
    final realTrue=higRatWin)
    "Convert to winter high rate"
    annotation (Placement(transformation(extent={{100,-50},{120,-30}})));
  Buildings.Controls.OBC.CDL.Integers.Add ratInd
    "Find the rate indicator"
    annotation (Placement(transformation(extent={{200,110},{220,130}})));
  Buildings.Controls.OBC.CDL.Reals.Add curRat
    "Find current rate"
    annotation (Placement(transformation(extent={{100,60},{120,80}})));
  Buildings.Controls.OBC.CDL.Reals.Add curRat1
    "Find current rate"
    annotation (Placement(transformation(extent={{160,-10},{180,10}})));
  Buildings.Controls.OBC.CDL.Reals.Add curRat2
    "Find current rate"
    annotation (Placement(transformation(extent={{200,30},{220,50}})));

equation
  connect(con.y, wee.u2) annotation (Line(points={{-198,-160},{-180,-160},{-180,
          -146},{-162,-146}}, color={0,0,127}));
  connect(wee.y, winEnd.u)
    annotation (Line(points={{-138,-140},{-102,-140}}, color={0,0,127}));
  connect(wee.y, winSta.u) annotation (Line(points={{-138,-140},{-120,-140},{-120,
          -180},{-102,-180}}, color={0,0,127}));
  connect(winEnd.y,win. u1)
    annotation (Line(points={{-78,-140},{-42,-140}},color={255,0,255}));
  connect(winSta.y,win. u2) annotation (Line(points={{-78,-180},{-60,-180},{-60,
          -148},{-42,-148}},color={255,0,255}));
  connect(win.y, intSwi.u2)
    annotation (Line(points={{-18,-140},{20,-140},{20,-180},{98,-180}},
          color={255,0,255}));
  connect(winInd.y, intSwi.u1) annotation (Line(points={{62,-150},{80,-150},{80,
          -172},{98,-172}}, color={255,127,0}));
  connect(sumSta.y, sum.u1)
    annotation (Line(points={{-78,-220},{-42,-220}},color={255,0,255}));
  connect(sumEnd.y, sum.u2) annotation (Line(points={{-78,-250},{-60,-250},{-60,
          -228},{-42,-228}},color={255,0,255}));
  connect(wee.y, sumSta.u) annotation (Line(points={{-138,-140},{-120,-140},{-120,
          -220},{-102,-220}}, color={0,0,127}));
  connect(wee.y, sumEnd.u) annotation (Line(points={{-138,-140},{-120,-140},{-120,
          -250},{-102,-250}}, color={0,0,127}));
  connect(sum.y, intSwi1.u2)
    annotation (Line(points={{-18,-220},{18,-220}},color={255,0,255}));
  connect(sumInd.y, intSwi1.u1) annotation (Line(points={{-18,-180},{0,-180},{0,
          -212},{18,-212}}, color={255,127,0}));
  connect(shoInd.y, intSwi1.u3) annotation (Line(points={{-18,-260},{0,-260},{0,
          -228},{18,-228}}, color={255,127,0}));
  connect(intSwi1.y, intSwi.u3) annotation (Line(points={{42,-220},{80,-220},{80,
          -188},{98,-188}}, color={255,127,0}));
  connect(intSwi.y, yGen)
    annotation (Line(points={{122,-180},{260,-180}}, color={255,127,0}));
  connect(wee.u1, uSolTim) annotation (Line(points={{-162,-134},{-260,-134}},
          color={0,0,127}));
  connect(uDisPum, sam.u)
    annotation (Line(points={{-260,260},{-222,260}}, color={0,0,127}));
  connect(lesThr.y, intSwi3.u2)
    annotation (Line(points={{-138,260},{38,260}},color={255,0,255}));
  connect(lowLoa.y, intSwi3.u1) annotation (Line(points={{-58,280},{20,280},{20,
          268},{38,268}}, color={255,127,0}));
  connect(higLoa.y, intSwi4.u1) annotation (Line(points={{-58,240},{-40,240},{-40,
          228},{-22,228}}, color={255,127,0}));
  connect(greThr.y, intSwi4.u2)
    annotation (Line(points={{-138,220},{-22,220}}, color={255,0,255}));
  connect(medLoa.y, intSwi4.u3) annotation (Line(points={{-58,200},{-40,200},{-40,
          212},{-22,212}}, color={255,127,0}));
  connect(intSwi4.y, intSwi3.u3) annotation (Line(points={{2,220},{20,220},{20,252},
          {38,252}}, color={255,127,0}));
  connect(sam.y, lesThr.u)
    annotation (Line(points={{-198,260},{-162,260}}, color={0,0,127}));
  connect(sam.y, greThr.u) annotation (Line(points={{-198,260},{-178,260},{-178,
          220},{-162,220}}, color={0,0,127}));
  connect(intSwi3.y, ySt)
    annotation (Line(points={{62,260},{260,260}},  color={255,127,0}));
  connect(calTim.month, aftJun.u)
    annotation (Line(points={{-199,130},{-182,130}}, color={255,127,0}));
  connect(calTim.month, earSep.u) annotation (Line(points={{-199,130},{-188,130},
          {-188,100},{-182,100}}, color={255,127,0}));
  connect(aftJun.y, inSum.u1)
    annotation (Line(points={{-158,130},{-142,130}}, color={255,0,255}));
  connect(earSep.y, inSum.u2) annotation (Line(points={{-158,100},{-150,100},{-150,
          122},{-142,122}}, color={255,0,255}));
  connect(calTim.hour, fouPm.u) annotation (Line(points={{-199,136},{-194,136},{
          -194,70},{-182,70}}, color={255,127,0}));
  connect(calTim.hour, senPm.u) annotation (Line(points={{-199,136},{-194,136},{
          -194,40},{-182,40}}, color={255,127,0}));
  connect(fouPm.y, sumHig.u1)
    annotation (Line(points={{-158,70},{-142,70}}, color={255,0,255}));
  connect(senPm.y, sumHig.u2) annotation (Line(points={{-158,40},{-150,40},{-150,
          62},{-142,62}}, color={255,0,255}));
  connect(inSum.y, sumHigRat.u1)
    annotation (Line(points={{-118,130},{-22,130}}, color={255,0,255}));
  connect(sumHig.y, sumHigRat.u2) annotation (Line(points={{-118,70},{-100,70},{
          -100,122},{-22,122}}, color={255,0,255}));
  connect(sumHig.y, sumLow.u) annotation (Line(points={{-118,70},{-100,70},{-100,
          50},{-82,50}}, color={255,0,255}));
  connect(sumLow.y, sumLowRat.u2) annotation (Line(points={{-58,50},{-40,50},{-40,
          72},{-22,72}}, color={255,0,255}));
  connect(inSum.y, sumLowRat.u1) annotation (Line(points={{-118,130},{-110,130},
          {-110,80},{-22,80}}, color={255,0,255}));
  connect(calTim.hour, sixAm.u) annotation (Line(points={{-199,136},{-194,136},{
          -194,0},{-182,0}}, color={255,127,0}));
  connect(calTim.hour, ninAm.u) annotation (Line(points={{-199,136},{-194,136},{
          -194,-30},{-182,-30}}, color={255,127,0}));
  connect(calTim.hour, fivPm.u) annotation (Line(points={{-199,136},{-194,136},{
          -194,-60},{-182,-60}}, color={255,127,0}));
  connect(calTim.hour, ninPm1.u) annotation (Line(points={{-199,136},{-194,136},
          {-194,-90},{-182,-90}}, color={255,127,0}));
  connect(ninAm.y, ninToFiv.u1)
    annotation (Line(points={{-158,-30},{-142,-30}}, color={255,0,255}));
  connect(fivPm.y, ninToFiv.u2) annotation (Line(points={{-158,-60},{-150,-60},{
          -150,-38},{-142,-38}}, color={255,0,255}));
  connect(sixAm.y, winLow.u1) annotation (Line(points={{-158,0},{-110,0},{-110,-10},
          {-102,-10}}, color={255,0,255}));
  connect(ninToFiv.y, winLow.u2) annotation (Line(points={{-118,-30},{-110,-30},
          {-110,-18},{-102,-18}}, color={255,0,255}));
  connect(ninPm1.y, winLow1.u2) annotation (Line(points={{-158,-90},{-70,-90},{-70,
          -18},{-62,-18}}, color={255,0,255}));
  connect(winLow.y, winLow1.u1)
    annotation (Line(points={{-78,-10},{-62,-10}}, color={255,0,255}));
  connect(inSum.y, inWin.u) annotation (Line(points={{-118,130},{-110,130},{-110,
          20},{-102,20}}, color={255,0,255}));
  connect(winLow1.y, winLowRat.u1)
    annotation (Line(points={{-38,-10},{-2,-10}}, color={255,0,255}));
  connect(inWin.y, winLowRat.u2) annotation (Line(points={{-78,20},{-20,20},{-20,
          -18},{-2,-18}}, color={255,0,255}));
  connect(winLow1.y, winHig.u) annotation (Line(points={{-38,-10},{-30,-10},{-30,
          -48},{-2,-48}}, color={255,0,255}));
  connect(winHig.y, winHihRat.u1) annotation (Line(points={{22,-48},{30,-48},{30,
          -70},{38,-70}}, color={255,0,255}));
  connect(inWin.y, winHihRat.u2) annotation (Line(points={{-78,20},{-20,20},{-20,
          -78},{38,-78}}, color={255,0,255}));
  connect(winHihRat.y, booToInt1.u)
    annotation (Line(points={{62,-70},{98,-70}}, color={255,0,255}));
  connect(winHihRat.y, booToRea3.u) annotation (Line(points={{62,-70},{70,-70},{
          70,-40},{98,-40}}, color={255,0,255}));
  connect(winLowRat.y, booToRea2.u)
    annotation (Line(points={{22,-10},{38,-10}}, color={255,0,255}));
  connect(sumLowRat.y, booToRea1.u)
    annotation (Line(points={{2,80},{20,80},{20,50},{40,50}}, color={255,0,255}));
  connect(sumHigRat.y, booToInt.u)
    annotation (Line(points={{2,130},{38,130}}, color={255,0,255}));
  connect(sumHigRat.y, booToRea.u) annotation (Line(points={{2,130},{20,130},{20,
          90},{38,90}},   color={255,0,255}));
  connect(booToInt1.y,ratInd. u2) annotation (Line(points={{122,-70},{130,-70},{
          130,114},{198,114}}, color={255,127,0}));
  connect(booToInt.y,ratInd. u1) annotation (Line(points={{62,130},{130,130},{130,
          126},{198,126}}, color={255,127,0}));
  connect(ratInd.y, yEle)
    annotation (Line(points={{222,120},{260,120}}, color={255,127,0}));
  connect(booToRea.y, curRat.u1) annotation (Line(points={{62,90},{80,90},{80,76},
          {98,76}}, color={0,0,127}));
  connect(booToRea1.y, curRat.u2) annotation (Line(points={{64,50},{80,50},{80,64},
          {98,64}}, color={0,0,127}));
  connect(booToRea2.y, curRat1.u1) annotation (Line(points={{62,-10},{100,-10},{
          100,6},{158,6}}, color={0,0,127}));
  connect(booToRea3.y, curRat1.u2) annotation (Line(points={{122,-40},{140,-40},
          {140,-6},{158,-6}}, color={0,0,127}));
  connect(curRat1.y, curRat2.u2) annotation (Line(points={{182,0},{190,0},{190,34},
          {198,34}}, color={0,0,127}));
  connect(curRat.y, curRat2.u1) annotation (Line(points={{122,70},{160,70},{160,
          46},{198,46}}, color={0,0,127}));
  connect(curRat2.y, yEleRat)
    annotation (Line(points={{222,40},{260,40}}, color={0,0,127}));
annotation (defaultComponentName="ind",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-240,-300},{240,300}})),
Documentation(info="
<html>
<p>
It outputs the indicators for current district loop load <code>ySt</code>, electricity
rate <code>yEleRat</code>, and heating or cooling season <code>yGen</code>.
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
<h4>District loop load indicator</h4>
<p>
Based on the control signal of the district loop pump <code>uDisPum</code>, the
district loop load indicator <code>ySt</code> is:
</p>
<ul>
<li>
If <code>uDisPum</code> &ge; 0 and <code>uDisPum</code> &lt; 1/3,
then <code>ySt</code> = 1;
</li>
<li>
Else if <code>uDisPum</code> &ge; 1/3 and <code>uDisPum</code> &lt; 2/3,
then <code>ySt</code> = 2;
</li>
<li>
Else, <code>ySt</code> = 3.
</li>
</ul>
<p>
The district loop pump speed is sampled with frequency specified by
<code>samplePeriod</code>.
</p>
<h4>Seanson indicator</h4>
<p>
Based on the week of the year, the plant is either in heating, shoulder or cooling
mode. The season indicator is used to determine whether the generation should add
heat or cold to the system if the electrical rates are normal.
</p>
<ul>
<li>
If current week is later than the winter start week <code>winStaWee</code>, or earlier
than winter end week <code>winEndWee</code>, it is in the winter senson. Thus,
<code>yGen</code> = 1.
</li>
<li>
Else if current week is later than the summer start week <code>sumStaWee</code> and
earlier than summer end week <code>sumEndWee</code>, it is in the summer senson. Thus,
<code>yGen</code> = 3.
</li>
<li>
Else, it is in the shoulder season. Thus, <code>yGen</code> = 2.
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
