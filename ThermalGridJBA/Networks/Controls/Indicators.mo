within ThermalGridJBA.Networks.Controls;
model Indicators "District load, electricity rate and season indicator"

  parameter Real TIniPlaHeaSet(
    unit="K",
    displayUnit="degC")=283.65
    "Design plant heating setpoint temperature"
    annotation (Dialog(group="Plant load"));
  parameter Real TIniPlaCooSet(
    unit="K",
    displayUnit="degC")=297.15
    "Design plant cooling setpoint temperature"
    annotation (Dialog(group="Plant load"));
  parameter Real TDryBulSum(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=297.15
    "Threshold of the dry bulb temperaure in summer below which starts charging borefield"
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
    annotation (Placement(transformation(extent={{-280,180},{-240,220}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC") "Dry bulb temperature"
    annotation (Placement(transformation(extent={{-280,140},{-240,180}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
   Buildings.Controls.OBC.CDL.Interfaces.RealInput dTActCooOveSho(
     final unit="K",
     final quantity="TemperatureDifference")
    "Actual cooling overshot temperature"
    annotation (Placement(transformation(extent={{-280,76},{-240,116}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dTActHeaOveSho(
    final unit="K",
    final quantity="TemperatureDifference")
    "Actual heating overshot temperature"
    annotation (Placement(transformation(extent={{-280,210},{-240,250}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TActPlaHeaSet(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC")
    "Actual plant heating setpoint"
    annotation (Placement(transformation(extent={{240,230},{280,270}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPlaOut
    "Plant load"
    annotation (Placement(transformation(extent={{240,150},{280,190}}),
        iconTransformation(extent={{100,40},{140,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TActPlaCooSet(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC") "Actual plant cooling setpoint"
    annotation (Placement(transformation(extent={{240,70},{280,110}}),
        iconTransformation(extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput ySt
    "Load indicator"
    annotation (Placement(transformation(extent={{240,10},{280,50}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yEle
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{240,-160},{280,-120}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yEleRat
    "Current electricity rate, dollar per kWh"
    annotation (Placement(transformation(extent={{240,-190},{280,-150}}),
        iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput ySea
    "Season indicator: 1 winter; 2 spring; 3 summer; 4 fall"
    annotation (Placement(transformation(extent={{240,-240},{280,-200}}),
        iconTransformation(extent={{100,-100},{140,-60}})));

  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(final t=1/3, h=0.05)
    "Check if the speed is less than 1/3"
    annotation (Placement(transformation(extent={{-220,-40},{-200,-20}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(final t=2/3, h=0.05)
    "Check if the speed is greater than 2/3"
    annotation (Placement(transformation(extent={{-220,-80},{-200,-60}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi3 "Check district load"
    annotation (Placement(transformation(extent={{-100,-40},{-80,-20}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant lowLoa(final k=1)
    "Low district loop load"
    annotation (Placement(transformation(extent={{-180,-20},{-160,0}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High district loop load"
    annotation (Placement(transformation(extent={{-180,-60},{-160,-40}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi4 "Check district load"
    annotation (Placement(transformation(extent={{-140,-80},{-120,-60}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant medLoa(final k=2)
    "Medium district loop load"
    annotation (Placement(transformation(extent={{-180,-100},{-160,-80}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.TimeTable seaTab(
    table=[0,1; winEndWee,2; sumStaWee,3; sumEndWee,4; winStaWee,1],
    timeScale=7*24*3600,
    period(displayUnit="d") = 31536000)
    "Table that outputs season: 1 winter; 2 spring; 3 summer; 4 fall"
    annotation (Placement(transformation(extent={{60,-250},{80,-230}})));
  Buildings.Controls.OBC.CDL.Reals.Line plaHeaLoa "Plant heating load"
    annotation (Placement(transformation(extent={{100,190},{120,210}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one(
    final k=1) "Constant 1"
    annotation (Placement(transformation(extent={{40,210},{60,230}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant iniHeaSet(y(unit="K",
        displayUnit="degC"), final k=TIniPlaHeaSet)
    "Plant initial heating setpoint"
    annotation (Placement(transformation(extent={{-140,240},{-120,260}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(
    final k=0) "Constant 0"
    annotation (Placement(transformation(extent={{40,170},{60,190}})));
  Buildings.Controls.OBC.CDL.Reals.Line plaCooLoa "Plant cooling load"
    annotation (Placement(transformation(extent={{100,120},{120,140}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant negOne(
    final k=-1)
    "Constant -1"
    annotation (Placement(transformation(extent={{60,100},{80,120}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant iniCooSet(y(unit="K",
        displayUnit="degC"), final k=TIniPlaCooSet)
    "Plant initial cooling setpoint except for summer"
    annotation (Placement(transformation(extent={{-220,120},{-200,140}})));
  Buildings.Controls.OBC.CDL.Reals.Add plaLoa
    "Plant load"
    annotation (Placement(transformation(extent={{140,160},{160,180}})));
  Buildings.Controls.OBC.CDL.Reals.Abs absLoa
    "Absolute value of the plant load"
    annotation (Placement(transformation(extent={{180,120},{200,140}})));
  Buildings.Controls.OBC.CDL.Integers.Change cha(final pre_u_start=2)
    "Check if there is any stage change"
    annotation (Placement(transformation(extent={{-40,-70},{-20,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Latch lat "Hold staging up"
    annotation (Placement(transformation(extent={{40,-70},{60,-50}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold truFalHol(final
      trueHoldDuration=staDowDel, final falseHoldDuration=0)
    "Ensure minimum delay to stage down"
    annotation (Placement(transformation(extent={{80,-70},{100,-50}})));
  Buildings.Controls.OBC.CDL.Integers.Switch plaLoaInd "Plant load indicator"
    annotation (Placement(transformation(extent={{160,-70},{180,-50}})));
  Buildings.Controls.OBC.CDL.Conversions.IntegerToReal intToRea
    "Convert integer to real"
    annotation (Placement(transformation(extent={{-40,-20},{-20,0}})));
  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler triSam(final y_start=1)
    "Sample the load indicator when it starts staging up"
    annotation (Placement(transformation(extent={{10,-20},{30,0}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt
    "Convert real to integer"
    annotation (Placement(transformation(extent={{80,-20},{100,0}})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim(t=staDowDel)
    "Check if the minimum dealy has passed"
    annotation (Placement(transformation(extent={{120,-110},{140,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Or or2
    "Check if there is staging down or the minimum delay has passed"
    annotation (Placement(transformation(extent={{0,-110},{20,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Pre pre "Break loop"
    annotation (Placement(transformation(extent={{-40,-110},{-20,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.TimeTable sumWin(
    table=[0,0; 152,1; 274,0],
    timeScale=24*3600,
    period(displayUnit="d") = 31536000)
    "Output summer or winter: true - in summer; false - in winter"
    annotation (Placement(transformation(extent={{-60,-180},{-40,-160}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.TimeTable sumRat(
    table=[0,lowRatSum; 15,higRatSum; 20,lowRatSum; 24,lowRatSum],
    smoothness=Buildings.Controls.OBC.CDL.Types.Smoothness.ConstantSegments,
    timeScale=3600) "Summer rate"
    annotation (Placement(transformation(extent={{-20,-160},{0,-140}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.TimeTable winRat(
    table=[0,lowRatWin; 6,higRatWin; 9,lowRatWin; 17,higRatWin; 21,lowRatWin;
        24,lowRatWin],
    smoothness=Buildings.Controls.OBC.CDL.Types.Smoothness.ConstantSegments,
    timeScale=3600) "Winter rate"
    annotation (Placement(transformation(extent={{-20,-200},{0,-180}})));
  Buildings.Controls.OBC.CDL.Reals.Switch eleRat "Electricity rate"
    annotation (Placement(transformation(extent={{60,-180},{80,-160}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold higRat(final t=lowRatSum)
    "Check if it is high rate"
    annotation (Placement(transformation(extent={{120,-150},{140,-130}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger ratInd
    "Convert to rate indicator"
    annotation (Placement(transformation(extent={{160,-150},{180,-130}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(k=1/100)
    "Convert cents to dollars"
    annotation (Placement(transformation(extent={{160,-180},{180,-160}})));
  Buildings.Controls.OBC.CDL.Reals.Switch plaCooSet "Plant cooling setpoint"
    annotation (Placement(transformation(extent={{-20,100},{0,120}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(final p=-1)
    "One degree  lower"
    annotation (Placement(transformation(extent={{20,128},{40,148}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum "In summer"
    annotation (Placement(transformation(extent={{160,-250},{180,-230}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sumInd(k=3)
    "Summer indicator"
    annotation (Placement(transformation(extent={{100,-270},{120,-250}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter hotSumSet(p=-2, y(unit="K",
        displayUnit="degC")) "Plant cooling setpoint during hot summer time"
    annotation (Placement(transformation(extent={{-100,130},{-80,150}})));
  Buildings.Controls.OBC.CDL.Reals.Line plaCooSetSumShi(
    x1(final unit="K", displayUnit="degC"),
    f1(final unit="K", displayUnit="degC"),
    x2(final unit="K", displayUnit="degC"),
    f2(final unit="K", displayUnit="degC"),
    u(final unit="K", displayUnit="degC"),
    y(final unit="K", displayUnit="degC"))
    "Set point for plant during summer"
    annotation (Placement(transformation(extent={{-58,150},{-38,170}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TDryBulHig(y(unit="K",
        displayUnit="degC"), final k=TDryBulSum + 1)
    "High limit to shift cooling set point"
    annotation (Placement(transformation(extent={{-200,170},{-180,190}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TDryBulLow(y(unit="K",
        displayUnit="degC"), final k=TDryBulSum - 1)
    "Low limit to shift cooling set point"
    annotation (Placement(transformation(extent={{-100,170},{-80,190}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract nonSumCooSet
    "Plant cooling setpoint except summer"
    annotation (Placement(transformation(extent={{-180,92},{-160,112}})));
  Buildings.Controls.OBC.CDL.Reals.Add actPlaHeaSet
    "Actual plant heating setpoint"
    annotation (Placement(transformation(extent={{-80,240},{-60,260}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(final p=1)
    "One degree higher than the plant heating setpoint"
    annotation (Placement(transformation(extent={{0,170},{20,190}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter cooSumSet11(final p=-2)
    "Plant cooling setpoint when it is in the cool summer"
    annotation (Placement(transformation(extent={{-140,170},{-120,190}})));
  ContinuousIntegerMax conMax "Find the continuous maximum stage"
    annotation (Placement(transformation(extent={{120,-20},{140,0}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inHigLoa "In high load mode"
    annotation (Placement(transformation(extent={{80,20},{100,40}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoaInd(final k=3)
    "High load index"
    annotation (Placement(transformation(extent={{40,20},{60,40}})));
  Buildings.Controls.OBC.CDL.Conversions.IntegerToReal intToRea1
    "Convert integer to real"
    annotation (Placement(transformation(extent={{80,50},{100,70}})));
  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler triSam1(final y_start=1)
    "Sample the load indicator when it starts staging up"
    annotation (Placement(transformation(extent={{120,50},{140,70}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold truFalHol1(final
      trueHoldDuration=staDowDel, final falseHoldDuration=0)
    "Ensure minimum delay to stage down"
    annotation (Placement(transformation(extent={{160,20},{180,40}})));
  Buildings.Controls.OBC.CDL.Integers.Switch plaLoaInd1
                                                       "Plant load indicator"
    annotation (Placement(transformation(extent={{200,20},{220,40}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt1
    "Convert real to integer"
    annotation (Placement(transformation(extent={{160,50},{180,70}})));
equation
  connect(lesThr.y, intSwi3.u2)
    annotation (Line(points={{-198,-30},{-102,-30}},color={255,0,255}));
  connect(lowLoa.y, intSwi3.u1) annotation (Line(points={{-158,-10},{-120,-10},{
          -120,-22},{-102,-22}},
                               color={255,127,0}));
  connect(higLoa.y, intSwi4.u1) annotation (Line(points={{-158,-50},{-150,-50},{
          -150,-62},{-142,-62}},  color={255,127,0}));
  connect(greThr.y, intSwi4.u2)
    annotation (Line(points={{-198,-70},{-142,-70}},color={255,0,255}));
  connect(medLoa.y, intSwi4.u3) annotation (Line(points={{-158,-90},{-150,-90},{
          -150,-78},{-142,-78}}, color={255,127,0}));
  connect(intSwi4.y, intSwi3.u3) annotation (Line(points={{-118,-70},{-110,-70},
          {-110,-38},{-102,-38}}, color={255,127,0}));
  connect(seaTab.y[1],ySea)
    annotation (Line(points={{82,-240},{140,-240},{140,-220},{260,-220}},
                                                     color={255,127,0}));
  connect(one.y, plaHeaLoa.f1) annotation (Line(points={{62,220},{80,220},{80,204},
          {98,204}},       color={0,0,127}));
  connect(TPlaOut, plaHeaLoa.u)
    annotation (Line(points={{-260,200},{98,200}},  color={0,0,127}));
  connect(zer.y, plaHeaLoa.f2) annotation (Line(points={{62,180},{90,180},{90,192},
          {98,192}},       color={0,0,127}));
  connect(TPlaOut, plaCooLoa.u) annotation (Line(points={{-260,200},{80,200},{80,
          130},{98,130}},       color={0,0,127}));
  connect(negOne.y, plaCooLoa.f2) annotation (Line(points={{82,110},{88,110},{88,
          122},{98,122}},      color={0,0,127}));
  connect(plaHeaLoa.y, plaLoa.u1) annotation (Line(points={{122,200},{130,200},{
          130,176},{138,176}}, color={0,0,127}));
  connect(plaCooLoa.y, plaLoa.u2) annotation (Line(points={{122,130},{130,130},{
          130,164},{138,164}}, color={0,0,127}));
  connect(plaLoa.y, yPlaOut)
    annotation (Line(points={{162,170},{260,170}},color={0,0,127}));
  connect(plaLoa.y, absLoa.u) annotation (Line(points={{162,170},{170,170},{170,
          130},{178,130}}, color={0,0,127}));
  connect(zer.y, plaCooLoa.f1) annotation (Line(points={{62,180},{90,180},{90,134},
          {98,134}},           color={0,0,127}));
  connect(absLoa.y, greThr.u) annotation (Line(points={{202,130},{220,130},{220,
          80},{-230,80},{-230,-70},{-222,-70}},   color={0,0,127}));
  connect(absLoa.y, lesThr.u) annotation (Line(points={{202,130},{220,130},{220,
          80},{-230,80},{-230,-30},{-222,-30}},   color={0,0,127}));
  connect(intSwi3.y, cha.u) annotation (Line(points={{-78,-30},{-60,-30},{-60,-60},
          {-42,-60}},color={255,127,0}));
  connect(cha.up, lat.u) annotation (Line(points={{-18,-54},{20,-54},{20,-60},{38,
          -60}}, color={255,0,255}));
  connect(lat.y, truFalHol.u)
    annotation (Line(points={{62,-60},{78,-60}},   color={255,0,255}));
  connect(intSwi3.y, plaLoaInd.u3) annotation (Line(points={{-78,-30},{-60,-30},
          {-60,-80},{140,-80},{140,-68},{158,-68}},  color={255,127,0}));
  connect(intSwi3.y, intToRea.u) annotation (Line(points={{-78,-30},{-60,-30},{-60,
          -10},{-42,-10}},color={255,127,0}));
  connect(intToRea.y, triSam.u)
    annotation (Line(points={{-18,-10},{8,-10}}, color={0,0,127}));
  connect(truFalHol.y, tim.u) annotation (Line(points={{102,-60},{110,-60},{110,
          -100},{118,-100}},
                           color={255,0,255}));
  connect(cha.down, or2.u1) annotation (Line(points={{-18,-66},{-8,-66},{-8,-100},
          {-2,-100}},
                    color={255,0,255}));
  connect(tim.passed, pre.u) annotation (Line(points={{142,-108},{160,-108},{160,
          -120},{-60,-120},{-60,-100},{-42,-100}},
                                          color={255,0,255}));
  connect(pre.y, or2.u2) annotation (Line(points={{-18,-100},{-12,-100},{-12,-108},
          {-2,-108}},color={255,0,255}));
  connect(or2.y, lat.clr) annotation (Line(points={{22,-100},{30,-100},{30,-66},
          {38,-66}},      color={255,0,255}));
  connect(sumWin.y[1], eleRat.u2)
    annotation (Line(points={{-38,-170},{58,-170}},  color={255,0,255}));
  connect(sumRat.y[1], eleRat.u1) annotation (Line(points={{2,-150},{40,-150},{40,
          -162},{58,-162}},    color={0,0,127}));
  connect(winRat.y[1], eleRat.u3) annotation (Line(points={{2,-190},{40,-190},{40,
          -178},{58,-178}},    color={0,0,127}));
  connect(eleRat.y, higRat.u) annotation (Line(points={{82,-170},{100,-170},{100,
          -140},{118,-140}},     color={0,0,127}));
  connect(higRat.y, ratInd.u)
    annotation (Line(points={{142,-140},{158,-140}}, color={255,0,255}));
  connect(ratInd.y, yEle)
    annotation (Line(points={{182,-140},{260,-140}}, color={255,127,0}));
  connect(eleRat.y, gai1.u)
    annotation (Line(points={{82,-170},{158,-170}}, color={0,0,127}));
  connect(gai1.y, yEleRat)
    annotation (Line(points={{182,-170},{260,-170}}, color={0,0,127}));
  connect(plaCooSet.y, plaCooLoa.x2) annotation (Line(points={{2,110},{50,110},{
          50,126},{98,126}},   color={0,0,127}));
  connect(addPar.y, plaCooLoa.x1) annotation (Line(points={{42,138},{98,138}},
                              color={0,0,127}));
  connect(plaCooSet.y, addPar.u) annotation (Line(points={{2,110},{10,110},{10,138},
          {18,138}},        color={0,0,127}));
  connect(sumInd.y, inSum.u2) annotation (Line(points={{122,-260},{140,-260},{140,
          -248},{158,-248}},     color={255,127,0}));
  connect(seaTab.y[1], inSum.u1) annotation (Line(points={{82,-240},{158,-240}},
                                  color={255,127,0}));
  connect(inSum.y, plaCooSet.u2) annotation (Line(points={{182,-240},{200,-240},
          {200,-210},{-70,-210},{-70,110},{-22,110}},  color={255,0,255}));
  connect(plaCooSet.y, TActPlaCooSet) annotation (Line(points={{2,110},{10,110},
          {10,90},{260,90}},   color={0,0,127}));
  connect(TDryBul, plaCooSetSumShi.u) annotation (Line(points={{-260,160},{-60,160}},
                                  color={0,0,127}));
  connect(plaCooSetSumShi.y, plaCooSet.u1) annotation (Line(points={{-36,160},{-30,
          160},{-30,118},{-22,118}},      color={0,0,127}));
  connect(TDryBulLow.y, plaCooSetSumShi.x1) annotation (Line(points={{-78,180},{
          -70,180},{-70,168},{-60,168}},     color={0,0,127}));
  connect(plaCooSetSumShi.x2, TDryBulHig.y) annotation (Line(points={{-60,156},{
          -160,156},{-160,180},{-178,180}},  color={0,0,127}));
  connect(plaCooSetSumShi.f2, hotSumSet.y) annotation (Line(points={{-60,152},{-70,
          152},{-70,140},{-78,140}}, color={0,0,127}));
  connect(nonSumCooSet.y, plaCooSet.u3) annotation (Line(points={{-158,102},{-22,
          102}},              color={0,0,127}));
  connect(iniHeaSet.y, actPlaHeaSet.u1) annotation (Line(points={{-118,250},{-100,
          250},{-100,256},{-82,256}}, color={0,0,127}));
  connect(dTActHeaOveSho, actPlaHeaSet.u2) annotation (Line(points={{-260,230},{
          -92,230},{-92,244},{-82,244}}, color={0,0,127}));
  connect(actPlaHeaSet.y, plaHeaLoa.x1) annotation (Line(points={{-58,250},{90,250},
          {90,208},{98,208}}, color={0,0,127}));
  connect(actPlaHeaSet.y, addPar1.u) annotation (Line(points={{-58,250},{-20,250},
          {-20,180},{-2,180}},  color={0,0,127}));
  connect(addPar1.y, plaHeaLoa.x2) annotation (Line(points={{22,180},{30,180},{30,
          196},{98,196}}, color={0,0,127}));
  connect(actPlaHeaSet.y, TActPlaHeaSet)
    annotation (Line(points={{-58,250},{260,250}},           color={0,0,127}));
  connect(nonSumCooSet.y, cooSumSet11.u) annotation (Line(points={{-158,102},{-150,
          102},{-150,180},{-142,180}},color={0,0,127}));
  connect(cooSumSet11.y, plaCooSetSumShi.f1) annotation (Line(points={{-118,180},
          {-110,180},{-110,164},{-60,164}}, color={0,0,127}));
  connect(cooSumSet11.y, hotSumSet.u) annotation (Line(points={{-118,180},{-110,
          180},{-110,140},{-102,140}}, color={0,0,127}));
  connect(iniCooSet.y, nonSumCooSet.u1) annotation (Line(points={{-198,130},{-190,
          130},{-190,108},{-182,108}},
                                    color={0,0,127}));
  connect(dTActCooOveSho, nonSumCooSet.u2) annotation (Line(points={{-260,96},{-182,
          96}}, color={0,0,127}));
  connect(truFalHol.y, plaLoaInd.u2)
    annotation (Line(points={{102,-60},{158,-60}}, color={255,0,255}));
  connect(cha.up, triSam.trigger)
    annotation (Line(points={{-18,-54},{20,-54},{20,-22}},color={255,0,255}));
  connect(triSam.y, reaToInt.u)
    annotation (Line(points={{32,-10},{78,-10}},
                                               color={0,0,127}));
  connect(reaToInt.y, conMax.u)
    annotation (Line(points={{102,-10},{118,-10}},
                                                 color={255,127,0}));
  connect(truFalHol.y, conMax.active) annotation (Line(points={{102,-60},{110,-60},
          {110,-18},{118,-18}},    color={255,0,255}));
  connect(conMax.y, plaLoaInd.u1) annotation (Line(points={{142,-10},{150,-10},{
          150,-52},{158,-52}}, color={255,127,0}));
  connect(higLoaInd.y, inHigLoa.u1)
    annotation (Line(points={{62,30},{78,30}}, color={255,127,0}));
  connect(plaLoaInd.y, inHigLoa.u2) annotation (Line(points={{182,-60},{190,-60},
          {190,10},{70,10},{70,22},{78,22}}, color={255,127,0}));
  connect(inHigLoa.y, triSam1.trigger)
    annotation (Line(points={{102,30},{130,30},{130,48}}, color={255,0,255}));
  connect(intToRea1.y, triSam1.u)
    annotation (Line(points={{102,60},{118,60}}, color={0,0,127}));
  connect(inHigLoa.y, truFalHol1.u)
    annotation (Line(points={{102,30},{158,30}}, color={255,0,255}));
  connect(plaLoaInd.y, intToRea1.u) annotation (Line(points={{182,-60},{190,-60},
          {190,10},{70,10},{70,60},{78,60}}, color={255,127,0}));
  connect(triSam1.y, reaToInt1.u)
    annotation (Line(points={{142,60},{158,60}}, color={0,0,127}));
  connect(reaToInt1.y, plaLoaInd1.u1) annotation (Line(points={{182,60},{190,60},
          {190,38},{198,38}}, color={255,127,0}));
  connect(truFalHol1.y, plaLoaInd1.u2)
    annotation (Line(points={{182,30},{198,30}}, color={255,0,255}));
  connect(plaLoaInd.y, plaLoaInd1.u3) annotation (Line(points={{182,-60},{190,-60},
          {190,22},{198,22}}, color={255,127,0}));
  connect(plaLoaInd1.y, ySt)
    annotation (Line(points={{222,30},{260,30}}, color={255,127,0}));
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
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-240,-280},{240,280}})),
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
