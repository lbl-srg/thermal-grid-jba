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
  parameter Integer sumStaWee=22
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
    displayUnit="degC")
    "Central plant outlet water temperature"
    annotation (Placement(transformation(extent={{-280,330},{-240,370}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPlaOut
    "Plant load"
    annotation (Placement(transformation(extent={{240,280},{280,320}}),
        iconTransformation(extent={{100,60},{140,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput ySt
    "Load indicator"
    annotation (Placement(transformation(extent={{240,120},{280,160}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yEle
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{240,10},{280,50}}),
        iconTransformation(extent={{100,-30},{140,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, cent per kWh"
    annotation (Placement(transformation(extent={{240,-70},{280,-30}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput ySea
    "Season indicator: 1 winter; 2 spring; 3 summer; 4 fall"
    annotation (Placement(transformation(extent={{240,-260},{280,-220}}),
        iconTransformation(extent={{100,-100},{140,-60}})));

  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(final t=1/3, h=0.05)
    "Check if the speed is less than 1/3"
    annotation (Placement(transformation(extent={{-200,130},{-180,150}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(final t=2/3, h=0.05)
    "Check if the speed is greater than 2/3"
    annotation (Placement(transformation(extent={{-200,90},{-180,110}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi3 "Check district load"
    annotation (Placement(transformation(extent={{-40,130},{-20,150}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant lowLoa(final k=1)
    "Low district loop load"
    annotation (Placement(transformation(extent={{-160,150},{-140,170}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High district loop load"
    annotation (Placement(transformation(extent={{-160,110},{-140,130}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi4 "Check district load"
    annotation (Placement(transformation(extent={{-100,90},{-80,110}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant medLoa(final k=2)
    "Medium district loop load"
    annotation (Placement(transformation(extent={{-160,70},{-140,90}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.CalendarTime calTim(
    final zerTim=Buildings.Controls.OBC.CDL.Types.ZeroTime.NY2025)
    "Calendar time"
    annotation (Placement(transformation(extent={{-220,30},{-200,50}})));
  Buildings.Controls.OBC.CDL.Integers.GreaterEqualThreshold aftJun(final t=6)
    "After June"
    annotation (Placement(transformation(extent={{-180,30},{-160,50}})));
  Buildings.Controls.OBC.CDL.Integers.LessEqualThreshold earSep(final t=9)
    "Earlier than September"
    annotation (Placement(transformation(extent={{-180,0},{-160,20}})));
  Buildings.Controls.OBC.CDL.Integers.GreaterEqualThreshold fouPm(
    final t=sumPeaSta)
    "Later than 4PM"
    annotation (Placement(transformation(extent={{-180,-30},{-160,-10}})));
  Buildings.Controls.OBC.CDL.Integers.LessEqualThreshold senPm(
    final t=sumPeaEnd)
    "Earlier than 7PM"
    annotation (Placement(transformation(extent={{-180,-60},{-160,-40}})));
  Buildings.Controls.OBC.CDL.Logical.And inSum
    "Check if it is in summer rate period"
    annotation (Placement(transformation(extent={{-140,30},{-120,50}})));
  Buildings.Controls.OBC.CDL.Logical.And sumHig
    "Check if it is in summer high rate period"
    annotation (Placement(transformation(extent={{-140,-30},{-120,-10}})));
  Buildings.Controls.OBC.CDL.Logical.And sumHigRat
    "Check if it is in summer high rate period"
    annotation (Placement(transformation(extent={{-20,30},{0,50}})));
  Buildings.Controls.OBC.CDL.Logical.Not sumLow "Summer low rate"
    annotation (Placement(transformation(extent={{-80,-50},{-60,-30}})));
  Buildings.Controls.OBC.CDL.Logical.And sumLowRat
    "Check if it is in summer low rate period"
    annotation (Placement(transformation(extent={{-20,-20},{0,0}})));
  Buildings.Controls.OBC.CDL.Integers.LessEqualThreshold sixAm(
    final t=winLowEnd1)
    "Earlier than 6AM"
    annotation (Placement(transformation(extent={{-180,-100},{-160,-80}})));
  Buildings.Controls.OBC.CDL.Integers.GreaterEqualThreshold ninAm(
    final t=winLowSta1)
    "Later than 9AM"
    annotation (Placement(transformation(extent={{-180,-130},{-160,-110}})));
  Buildings.Controls.OBC.CDL.Integers.LessEqualThreshold fivPm(
    final t=winLowEnd2)
    "Earlier than 5PM"
    annotation (Placement(transformation(extent={{-180,-160},{-160,-140}})));
  Buildings.Controls.OBC.CDL.Integers.GreaterEqualThreshold ninPm1(
    final t=winLowSta2)
    "Later than 9PM"
    annotation (Placement(transformation(extent={{-180,-190},{-160,-170}})));
  Buildings.Controls.OBC.CDL.Logical.And ninToFiv
    "Check if it is between 9AM and 5PM"
    annotation (Placement(transformation(extent={{-140,-130},{-120,-110}})));
  Buildings.Controls.OBC.CDL.Logical.Or winLow
    "Winter low rate period"
    annotation (Placement(transformation(extent={{-100,-110},{-80,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Or winLow1
    "Winter low rate period"
    annotation (Placement(transformation(extent={{-60,-110},{-40,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Not inWin
    "In winter"
    annotation (Placement(transformation(extent={{-100,-80},{-80,-60}})));
  Buildings.Controls.OBC.CDL.Logical.And winLowRat
    "Check if it is in winter low rate period"
    annotation (Placement(transformation(extent={{0,-110},{20,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Not winHig "Winter high rate"
    annotation (Placement(transformation(extent={{0,-148},{20,-128}})));
  Buildings.Controls.OBC.CDL.Logical.And winHihRat
    "Check if it is in winter high rate period"
    annotation (Placement(transformation(extent={{40,-170},{60,-150}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea(
    final realTrue=higRatSum)
    "Convert to summer high rate"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger booToInt
    "Convert to high rate flag"
    annotation (Placement(transformation(extent={{40,30},{60,50}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea1(
    final realTrue=lowRatSum)
    "Convert to summer low rate"
    annotation (Placement(transformation(extent={{42,-50},{62,-30}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger booToInt1
    "Convert to high rate flag"
    annotation (Placement(transformation(extent={{100,-170},{120,-150}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea2(
    final realTrue=lowRatWin)
    "Convert to winter low rate"
    annotation (Placement(transformation(extent={{40,-110},{60,-90}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea3(
    final realTrue=higRatWin)
    "Convert to winter high rate"
    annotation (Placement(transformation(extent={{100,-140},{120,-120}})));
  Buildings.Controls.OBC.CDL.Integers.Add ratInd
    "Find the rate indicator"
    annotation (Placement(transformation(extent={{200,20},{220,40}})));
  Buildings.Controls.OBC.CDL.Reals.Add curRat
    "Find current rate"
    annotation (Placement(transformation(extent={{100,-30},{120,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Add curRat1
    "Find current rate"
    annotation (Placement(transformation(extent={{160,-100},{180,-80}})));
  Buildings.Controls.OBC.CDL.Reals.Add curRat2
    "Find current rate"
    annotation (Placement(transformation(extent={{200,-60},{220,-40}})));

  Buildings.Controls.OBC.CDL.Integers.Sources.TimeTable seaTab(
    table=[0,1; winEndWee,2; sumStaWee,3; sumEndWee,4; winStaWee,1],
    timeScale=7*24*3600,
    period(displayUnit="d") = 31536000)
    "Table that outputs season: 1 winter; 2 spring; 3 summer; 4 fall"
    annotation (Placement(transformation(extent={{200,-250},{220,-230}})));
  Buildings.Controls.OBC.CDL.Reals.Line plaHeaLoa "Plant heating load"
    annotation (Placement(transformation(extent={{-40,340},{-20,360}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one(
    final k=1) "Constant 1"
    annotation (Placement(transformation(extent={{-180,370},{-160,390}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant heaSet(
    y(unit="K", displayUnit="degC"),
    final k=TPlaHeaSet) "Plant heating setpoint"
    annotation (Placement(transformation(extent={{-120,370},{-100,390}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(
    final k=0) "Constant 0"
    annotation (Placement(transformation(extent={{-120,310},{-100,330}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant heaSetPlu(
    y(unit="K", displayUnit="degC"),
    final k=TPlaHeaSet + 1)
    "One degree higher than the plant heating setpoint"
    annotation (Placement(transformation(extent={{-180,310},{-160,330}})));
  Buildings.Controls.OBC.CDL.Reals.Line plaCooLoa "Plant cooling load"
    annotation (Placement(transformation(extent={{-40,240},{-20,260}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant cooSetMin(
    y(unit="K", displayUnit="degC"),
    final k=TPlaCooSet - 1)
    "One degree lower than the plant cooling setpoint"
    annotation (Placement(transformation(extent={{-180,270},{-160,290}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant negOne(
    final k=-1)
    "Constant -1"
    annotation (Placement(transformation(extent={{-120,210},{-100,230}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant cooSet(
    y(unit="K", displayUnit="degC"),
    final k=TPlaCooSet)
    "Plant cooling setpoint"
    annotation (Placement(transformation(extent={{-180,210},{-160,230}})));
  Buildings.Controls.OBC.CDL.Reals.Add plaLoa
    "Plant load"
    annotation (Placement(transformation(extent={{40,290},{60,310}})));
  Buildings.Controls.OBC.CDL.Reals.Abs absLoa
    "Absolute value of the plant load"
    annotation (Placement(transformation(extent={{100,230},{120,250}})));
  Buildings.Controls.OBC.CDL.Integers.Change cha(final pre_u_start=2)
    "Check if there is any stage change"
    annotation (Placement(transformation(extent={{20,130},{40,150}})));
  Buildings.Controls.OBC.CDL.Logical.Latch lat "Hold staging up"
    annotation (Placement(transformation(extent={{100,130},{120,150}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold truFalHol(final
      trueHoldDuration=staDowDel, final falseHoldDuration=0)
    "Ensure minimum delay to stage down"
    annotation (Placement(transformation(extent={{140,130},{160,150}})));
  Buildings.Controls.OBC.CDL.Integers.Switch plaLoaInd "Plant load indicator"
    annotation (Placement(transformation(extent={{200,130},{220,150}})));
  Buildings.Controls.OBC.CDL.Conversions.IntegerToReal intToRea
    "Convert integer to real"
    annotation (Placement(transformation(extent={{20,160},{40,180}})));
  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler triSam(final y_start=1)
    "Sample the load indicator when it starts staging up"
    annotation (Placement(transformation(extent={{60,160},{80,180}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt
    "Convert real to integer"
    annotation (Placement(transformation(extent={{120,160},{140,180}})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim(t=staDowDel)
    "Check if the minimum dealy has passed"
    annotation (Placement(transformation(extent={{200,100},{220,120}})));
  Buildings.Controls.OBC.CDL.Logical.Or or2
    "Check if there is staging down or the minimum delay has passed"
    annotation (Placement(transformation(extent={{60,90},{80,110}})));
  Buildings.Controls.OBC.CDL.Logical.Pre pre "Break loop"
    annotation (Placement(transformation(extent={{20,90},{40,110}})));
equation
  connect(lesThr.y, intSwi3.u2)
    annotation (Line(points={{-178,140},{-42,140}}, color={255,0,255}));
  connect(lowLoa.y, intSwi3.u1) annotation (Line(points={{-138,160},{-60,160},{
          -60,148},{-42,148}}, color={255,127,0}));
  connect(higLoa.y, intSwi4.u1) annotation (Line(points={{-138,120},{-120,120},
          {-120,108},{-102,108}}, color={255,127,0}));
  connect(greThr.y, intSwi4.u2)
    annotation (Line(points={{-178,100},{-102,100}},color={255,0,255}));
  connect(medLoa.y, intSwi4.u3) annotation (Line(points={{-138,80},{-120,80},{
          -120,92},{-102,92}}, color={255,127,0}));
  connect(intSwi4.y, intSwi3.u3) annotation (Line(points={{-78,100},{-60,100},{
          -60,132},{-42,132}}, color={255,127,0}));
  connect(calTim.month, aftJun.u)
    annotation (Line(points={{-199,40},{-182,40}},   color={255,127,0}));
  connect(calTim.month, earSep.u) annotation (Line(points={{-199,40},{-188,40},{
          -188,10},{-182,10}},    color={255,127,0}));
  connect(aftJun.y, inSum.u1)
    annotation (Line(points={{-158,40},{-142,40}},   color={255,0,255}));
  connect(earSep.y, inSum.u2) annotation (Line(points={{-158,10},{-150,10},{-150,
          32},{-142,32}},   color={255,0,255}));
  connect(calTim.hour, fouPm.u) annotation (Line(points={{-199,46},{-194,46},{-194,
          -20},{-182,-20}},    color={255,127,0}));
  connect(calTim.hour, senPm.u) annotation (Line(points={{-199,46},{-194,46},{-194,
          -50},{-182,-50}},    color={255,127,0}));
  connect(fouPm.y, sumHig.u1)
    annotation (Line(points={{-158,-20},{-142,-20}}, color={255,0,255}));
  connect(senPm.y, sumHig.u2) annotation (Line(points={{-158,-50},{-150,-50},{-150,
          -28},{-142,-28}}, color={255,0,255}));
  connect(inSum.y, sumHigRat.u1)
    annotation (Line(points={{-118,40},{-22,40}},   color={255,0,255}));
  connect(sumHig.y, sumHigRat.u2) annotation (Line(points={{-118,-20},{-100,-20},
          {-100,32},{-22,32}},  color={255,0,255}));
  connect(sumHig.y, sumLow.u) annotation (Line(points={{-118,-20},{-100,-20},{-100,
          -40},{-82,-40}}, color={255,0,255}));
  connect(sumLow.y, sumLowRat.u2) annotation (Line(points={{-58,-40},{-40,-40},{
          -40,-18},{-22,-18}}, color={255,0,255}));
  connect(inSum.y, sumLowRat.u1) annotation (Line(points={{-118,40},{-110,40},{-110,
          -10},{-22,-10}},     color={255,0,255}));
  connect(calTim.hour, sixAm.u) annotation (Line(points={{-199,46},{-194,46},{-194,
          -90},{-182,-90}},  color={255,127,0}));
  connect(calTim.hour, ninAm.u) annotation (Line(points={{-199,46},{-194,46},{-194,
          -120},{-182,-120}},    color={255,127,0}));
  connect(calTim.hour, fivPm.u) annotation (Line(points={{-199,46},{-194,46},{-194,
          -150},{-182,-150}},    color={255,127,0}));
  connect(calTim.hour, ninPm1.u) annotation (Line(points={{-199,46},{-194,46},{-194,
          -180},{-182,-180}},     color={255,127,0}));
  connect(ninAm.y, ninToFiv.u1)
    annotation (Line(points={{-158,-120},{-142,-120}}, color={255,0,255}));
  connect(fivPm.y, ninToFiv.u2) annotation (Line(points={{-158,-150},{-150,-150},
          {-150,-128},{-142,-128}}, color={255,0,255}));
  connect(sixAm.y, winLow.u1) annotation (Line(points={{-158,-90},{-110,-90},{-110,
          -100},{-102,-100}}, color={255,0,255}));
  connect(ninToFiv.y, winLow.u2) annotation (Line(points={{-118,-120},{-110,-120},
          {-110,-108},{-102,-108}}, color={255,0,255}));
  connect(ninPm1.y, winLow1.u2) annotation (Line(points={{-158,-180},{-70,-180},
          {-70,-108},{-62,-108}}, color={255,0,255}));
  connect(winLow.y, winLow1.u1)
    annotation (Line(points={{-78,-100},{-62,-100}}, color={255,0,255}));
  connect(inSum.y, inWin.u) annotation (Line(points={{-118,40},{-110,40},{-110,-70},
          {-102,-70}},    color={255,0,255}));
  connect(winLow1.y, winLowRat.u1)
    annotation (Line(points={{-38,-100},{-2,-100}}, color={255,0,255}));
  connect(inWin.y, winLowRat.u2) annotation (Line(points={{-78,-70},{-20,-70},{-20,
          -108},{-2,-108}}, color={255,0,255}));
  connect(winLow1.y, winHig.u) annotation (Line(points={{-38,-100},{-30,-100},{-30,
          -138},{-2,-138}}, color={255,0,255}));
  connect(winHig.y, winHihRat.u1) annotation (Line(points={{22,-138},{30,-138},{
          30,-160},{38,-160}}, color={255,0,255}));
  connect(inWin.y, winHihRat.u2) annotation (Line(points={{-78,-70},{-20,-70},{-20,
          -168},{38,-168}}, color={255,0,255}));
  connect(winHihRat.y, booToInt1.u)
    annotation (Line(points={{62,-160},{98,-160}}, color={255,0,255}));
  connect(winHihRat.y, booToRea3.u) annotation (Line(points={{62,-160},{70,-160},
          {70,-130},{98,-130}}, color={255,0,255}));
  connect(winLowRat.y, booToRea2.u)
    annotation (Line(points={{22,-100},{38,-100}}, color={255,0,255}));
  connect(sumLowRat.y, booToRea1.u)
    annotation (Line(points={{2,-10},{20,-10},{20,-40},{40,-40}}, color={255,0,255}));
  connect(sumHigRat.y, booToInt.u)
    annotation (Line(points={{2,40},{38,40}},   color={255,0,255}));
  connect(sumHigRat.y, booToRea.u) annotation (Line(points={{2,40},{20,40},{20,0},
          {38,0}},        color={255,0,255}));
  connect(booToInt1.y,ratInd. u2) annotation (Line(points={{122,-160},{130,-160},
          {130,24},{198,24}},  color={255,127,0}));
  connect(booToInt.y,ratInd. u1) annotation (Line(points={{62,40},{130,40},{130,
          36},{198,36}},   color={255,127,0}));
  connect(ratInd.y, yEle)
    annotation (Line(points={{222,30},{260,30}},   color={255,127,0}));
  connect(booToRea.y, curRat.u1) annotation (Line(points={{62,0},{80,0},{80,-14},
          {98,-14}},color={0,0,127}));
  connect(booToRea1.y, curRat.u2) annotation (Line(points={{64,-40},{80,-40},{80,
          -26},{98,-26}}, color={0,0,127}));
  connect(booToRea2.y, curRat1.u1) annotation (Line(points={{62,-100},{100,-100},
          {100,-84},{158,-84}}, color={0,0,127}));
  connect(booToRea3.y, curRat1.u2) annotation (Line(points={{122,-130},{140,-130},
          {140,-96},{158,-96}}, color={0,0,127}));
  connect(curRat1.y, curRat2.u2) annotation (Line(points={{182,-90},{190,-90},{190,
          -56},{198,-56}}, color={0,0,127}));
  connect(curRat.y, curRat2.u1) annotation (Line(points={{122,-20},{160,-20},{160,
          -44},{198,-44}}, color={0,0,127}));
  connect(curRat2.y, yEleRat)
    annotation (Line(points={{222,-50},{260,-50}}, color={0,0,127}));
  connect(seaTab.y[1],ySea)
    annotation (Line(points={{222,-240},{260,-240}}, color={255,127,0}));
  connect(heaSet.y, plaHeaLoa.x1) annotation (Line(points={{-98,380},{-60,380},{
          -60,358},{-42,358}}, color={0,0,127}));
  connect(one.y, plaHeaLoa.f1) annotation (Line(points={{-158,380},{-140,380},{-140,
          354},{-42,354}}, color={0,0,127}));
  connect(TPlaOut, plaHeaLoa.u)
    annotation (Line(points={{-260,350},{-42,350}}, color={0,0,127}));
  connect(heaSetPlu.y, plaHeaLoa.x2) annotation (Line(points={{-158,320},{-140,320},
          {-140,346},{-42,346}}, color={0,0,127}));
  connect(zer.y, plaHeaLoa.f2) annotation (Line(points={{-98,320},{-80,320},{
          -80,342},{-42,342}},
                           color={0,0,127}));
  connect(cooSetMin.y, plaCooLoa.x1) annotation (Line(points={{-158,280},{-60,280},
          {-60,258},{-42,258}}, color={0,0,127}));
  connect(TPlaOut, plaCooLoa.u) annotation (Line(points={{-260,350},{-220,350},{
          -220,250},{-42,250}}, color={0,0,127}));
  connect(cooSet.y, plaCooLoa.x2) annotation (Line(points={{-158,220},{-140,220},
          {-140,246},{-42,246}}, color={0,0,127}));
  connect(negOne.y, plaCooLoa.f2) annotation (Line(points={{-98,220},{-60,220},{
          -60,242},{-42,242}}, color={0,0,127}));
  connect(plaHeaLoa.y, plaLoa.u1) annotation (Line(points={{-18,350},{20,350},{20,
          306},{38,306}}, color={0,0,127}));
  connect(plaCooLoa.y, plaLoa.u2) annotation (Line(points={{-18,250},{20,250},{20,
          294},{38,294}}, color={0,0,127}));
  connect(plaLoa.y, yPlaOut)
    annotation (Line(points={{62,300},{260,300}}, color={0,0,127}));
  connect(plaLoa.y, absLoa.u) annotation (Line(points={{62,300},{80,300},{80,240},
          {98,240}}, color={0,0,127}));
  connect(zer.y, plaCooLoa.f1) annotation (Line(points={{-98,320},{-80,320},{
          -80,254},{-42,254}}, color={0,0,127}));
  connect(absLoa.y, greThr.u) annotation (Line(points={{122,240},{140,240},{140,
          200},{-220,200},{-220,100},{-202,100}}, color={0,0,127}));
  connect(absLoa.y, lesThr.u) annotation (Line(points={{122,240},{140,240},{140,
          200},{-220,200},{-220,140},{-202,140}}, color={0,0,127}));
  connect(intSwi3.y, cha.u) annotation (Line(points={{-18,140},{18,140}},
                     color={255,127,0}));
  connect(cha.up, lat.u) annotation (Line(points={{42,146},{70,146},{70,140},{98,
          140}},    color={255,0,255}));
  connect(lat.y, truFalHol.u)
    annotation (Line(points={{122,140},{138,140}}, color={255,0,255}));
  connect(truFalHol.y, plaLoaInd.u2)
    annotation (Line(points={{162,140},{198,140}}, color={255,0,255}));
  connect(intSwi3.y, plaLoaInd.u3) annotation (Line(points={{-18,140},{0,140},{0,
          120},{180,120},{180,132},{198,132}}, color={255,127,0}));
  connect(intSwi3.y, intToRea.u) annotation (Line(points={{-18,140},{0,140},{0,
          170},{18,170}}, color={255,127,0}));
  connect(intToRea.y, triSam.u)
    annotation (Line(points={{42,170},{58,170}}, color={0,0,127}));
  connect(triSam.y, reaToInt.u)
    annotation (Line(points={{82,170},{118,170}}, color={0,0,127}));
  connect(cha.up, triSam.trigger)
    annotation (Line(points={{42,146},{70,146},{70,158}}, color={255,0,255}));
  connect(reaToInt.y, plaLoaInd.u1) annotation (Line(points={{142,170},{180,170},
          {180,148},{198,148}}, color={255,127,0}));
  connect(truFalHol.y, tim.u) annotation (Line(points={{162,140},{190,140},{190,
          110},{198,110}},
                         color={255,0,255}));
  connect(cha.down, or2.u1) annotation (Line(points={{42,134},{52,134},{52,100},
          {58,100}},color={255,0,255}));
  connect(tim.passed, pre.u) annotation (Line(points={{222,102},{230,102},{230,80},
          {10,80},{10,100},{18,100}},
                                    color={255,0,255}));
  connect(pre.y, or2.u2) annotation (Line(points={{42,100},{46,100},{46,92},{58,
          92}}, color={255,0,255}));
  connect(or2.y, lat.clr) annotation (Line(points={{82,100},{90,100},{90,134},{98,
          134}},          color={255,0,255}));
  connect(plaLoaInd.y, ySt)
    annotation (Line(points={{222,140},{260,140}}, color={255,127,0}));
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
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-240,-300},{240,400}})),
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
