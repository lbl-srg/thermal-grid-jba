within ThermalGridJBA.Networks.Controls;
model RateSeasonIndicator "Electricity rate and season indicator"

  parameter Integer winEndWee=14
    "Week that winter season ends after it";
  parameter Integer winStaWee=45
    "Week that winter season starts at beginning of it";
  parameter Integer sumStaWee=24
    "Week that summer season starts at beginning of it";
  parameter Integer sumEndWee=40
    "Week that summer season ends after it";
  parameter Integer peaHouSta=16
    "Peak rate start hour";
  parameter Integer peaHouEnd=21
    "Peak rate end hour";

  Buildings.Controls.OBC.CDL.Interfaces.RealInput uSolTim
    "Solar time. An output from weather data"
    annotation (Placement(transformation(extent={{-178,-20},{-138,20}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{140,40},{180,80}}),
        iconTransformation(extent={{100,40},{140,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yGen
    "Season indicator. 1-winter; 2-summer; 3-shoulder"
    annotation (Placement(transformation(extent={{140,-90},{180,-50}}),
        iconTransformation(extent={{100,-80},{140,-40}})));

  Buildings.Controls.OBC.CDL.Reals.Divide wee "Week of the year"
    annotation (Placement(transformation(extent={{-80,-80},{-60,-60}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(
    final k=7*24*3600) "One week"
    annotation (Placement(transformation(extent={{-120,-100},{-100,-80}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold winEnd(
    final t=winEndWee) "Winter end week"
    annotation (Placement(transformation(extent={{-40,-80},{-20,-60}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold winSta(
    final t=winStaWee) "Winter start week"
    annotation (Placement(transformation(extent={{-40,-130},{-20,-110}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi "Check season"
    annotation (Placement(transformation(extent={{80,-80},{100,-60}})));
  Buildings.Controls.OBC.CDL.Logical.Or win "Check if it is in winter"
    annotation (Placement(transformation(extent={{0,-80},{20,-60}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant winInd(
    final k=1) "Winter indicator"
    annotation (Placement(transformation(extent={{0,-40},{20,-20}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold sumSta(
    final t=sumStaWee)
    "Summer start week"
    annotation (Placement(transformation(extent={{-40,-160},{-20,-140}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold sumEnd(
    final t=sumEndWee)
    "Summer End week"
    annotation (Placement(transformation(extent={{-40,-190},{-20,-170}})));
  Buildings.Controls.OBC.CDL.Logical.And sum "Check if it is in summer"
    annotation (Placement(transformation(extent={{0,-160},{20,-140}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi1 "Check season"
    annotation (Placement(transformation(extent={{40,-160},{60,-140}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sumInd(
    final k=2)
    "Summer indicator"
    annotation (Placement(transformation(extent={{0,-130},{20,-110}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant shoInd(
    final k=3)
    "Shoulder season indicator"
    annotation (Placement(transformation(extent={{0,-200},{20,-180}})));

  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(
    final k=24*3600)
    "One day"
    annotation (Placement(transformation(extent={{-120,160},{-100,180}})));
  Buildings.Controls.OBC.CDL.Reals.Modulo mod1
    annotation (Placement(transformation(extent={{-80,180},{-60,200}})));
  Buildings.Controls.OBC.CDL.Reals.Divide hou "Hour of the day"
    annotation (Placement(transformation(extent={{-40,160},{-20,180}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con2(
    final k=3600)
    "One hour"
    annotation (Placement(transformation(extent={{-80,140},{-60,160}})));
  Buildings.Controls.OBC.CDL.Reals.Round rou(final n=0)
    "Round the hour to the nearest hour"
    annotation (Placement(transformation(extent={{0,160},{20,180}})));
  Buildings.Controls.OBC.CDL.Reals.Greater gre
    annotation (Placement(transformation(extent={{40,128},{60,148}})));
  Buildings.Controls.OBC.CDL.Reals.Switch curHou "Current hour"
    annotation (Placement(transformation(extent={{80,160},{100,180}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(
    final p=-1)
    "Previous hour"
    annotation (Placement(transformation(extent={{40,180},{60,200}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold endNor(
    final t=peaHouSta)
    "Check if it is the normal rate hour"
    annotation (Placement(transformation(extent={{-60,50},{-40,70}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold staNor(
    final t=peaHouEnd)
    "Check if it is in the normal rate hour"
    annotation (Placement(transformation(extent={{-60,20},{-40,40}})));
  Buildings.Controls.OBC.CDL.Logical.Or norRatHou
    "Check if it is in the normal rate hour"
    annotation (Placement(transformation(extent={{20,50},{40,70}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi2
    "Check season"
    annotation (Placement(transformation(extent={{100,50},{120,70}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant norRatInd(
    final k=0)
    "Normal rate indicator"
    annotation (Placement(transformation(extent={{0,90},{20,110}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRatInd(
    final k=1)
    "High rate indicator"
    annotation (Placement(transformation(extent={{0,10},{20,30}})));

equation
  connect(con.y, wee.u2) annotation (Line(points={{-98,-90},{-90,-90},{-90,-76},
          {-82,-76}}, color={0,0,127}));
  connect(wee.y, winEnd.u)
    annotation (Line(points={{-58,-70},{-42,-70}}, color={0,0,127}));
  connect(wee.y, winSta.u) annotation (Line(points={{-58,-70},{-50,-70},{-50,-120},
          {-42,-120}}, color={0,0,127}));
  connect(winEnd.y,win. u1)
    annotation (Line(points={{-18,-70},{-2,-70}}, color={255,0,255}));
  connect(winSta.y,win. u2) annotation (Line(points={{-18,-120},{-10,-120},{-10,
          -78},{-2,-78}}, color={255,0,255}));
  connect(win.y, intSwi.u2)
    annotation (Line(points={{22,-70},{78,-70}}, color={255,0,255}));
  connect(winInd.y, intSwi.u1) annotation (Line(points={{22,-30},{70,-30},{70,-62},
          {78,-62}},color={255,127,0}));
  connect(sumSta.y, sum.u1)
    annotation (Line(points={{-18,-150},{-2,-150}}, color={255,0,255}));
  connect(sumEnd.y, sum.u2) annotation (Line(points={{-18,-180},{-10,-180},{-10,
          -158},{-2,-158}}, color={255,0,255}));
  connect(wee.y, sumSta.u) annotation (Line(points={{-58,-70},{-50,-70},{-50,-150},
          {-42,-150}},color={0,0,127}));
  connect(wee.y, sumEnd.u) annotation (Line(points={{-58,-70},{-50,-70},{-50,-180},
          {-42,-180}},color={0,0,127}));
  connect(sum.y, intSwi1.u2)
    annotation (Line(points={{22,-150},{38,-150}}, color={255,0,255}));
  connect(sumInd.y, intSwi1.u1) annotation (Line(points={{22,-120},{30,-120},{30,
          -142},{38,-142}}, color={255,127,0}));
  connect(shoInd.y, intSwi1.u3) annotation (Line(points={{22,-190},{30,-190},{30,
          -158},{38,-158}}, color={255,127,0}));
  connect(intSwi1.y, intSwi.u3) annotation (Line(points={{62,-150},{70,-150},{70,
          -78},{78,-78}}, color={255,127,0}));
  connect(intSwi.y, yGen)
    annotation (Line(points={{102,-70},{160,-70}}, color={255,127,0}));
  connect(wee.u1, uSolTim) annotation (Line(points={{-82,-64},{-130,-64},{-130,0},
          {-158,0}},  color={0,0,127}));
  connect(con1.y, mod1.u2) annotation (Line(points={{-98,170},{-90,170},{-90,184},
          {-82,184}}, color={0,0,127}));
  connect(uSolTim, mod1.u1) annotation (Line(points={{-158,0},{-130,0},{-130,196},
          {-82,196}}, color={0,0,127}));
  connect(mod1.y, hou.u1) annotation (Line(points={{-58,190},{-50,190},{-50,176},
          {-42,176}}, color={0,0,127}));
  connect(con2.y, hou.u2) annotation (Line(points={{-58,150},{-50,150},{-50,164},
          {-42,164}}, color={0,0,127}));
  connect(hou.y, rou.u)
    annotation (Line(points={{-18,170},{-2,170}}, color={0,0,127}));
  connect(rou.y, gre.u1) annotation (Line(points={{22,170},{30,170},{30,138},{38,
          138}}, color={0,0,127}));
  connect(hou.y, gre.u2) annotation (Line(points={{-18,170},{-10,170},{-10,130},
          {38,130}}, color={0,0,127}));
  connect(gre.y, curHou.u2) annotation (Line(points={{62,138},{70,138},{70,170},
          {78,170}}, color={255,0,255}));
  connect(rou.y, addPar.u) annotation (Line(points={{22,170},{30,170},{30,190},{
          38,190}}, color={0,0,127}));
  connect(addPar.y, curHou.u1) annotation (Line(points={{62,190},{70,190},{70,178},
          {78,178}}, color={0,0,127}));
  connect(rou.y, curHou.u3) annotation (Line(points={{22,170},{30,170},{30,162},
          {78,162}}, color={0,0,127}));
  connect(norRatHou.y, intSwi2.u2)
    annotation (Line(points={{42,60},{98,60}}, color={255,0,255}));
  connect(endNor.y, norRatHou.u1)
    annotation (Line(points={{-38,60},{18,60}}, color={255,0,255}));
  connect(staNor.y, norRatHou.u2) annotation (Line(points={{-38,30},{-20,30},{-20,
          52},{18,52}}, color={255,0,255}));
  connect(intSwi2.y, yEleRat)
    annotation (Line(points={{122,60},{160,60}}, color={255,127,0}));
  connect(norRatInd.y, intSwi2.u1) annotation (Line(points={{22,100},{80,100},{80,
          68},{98,68}}, color={255,127,0}));
  connect(higRatInd.y, intSwi2.u3) annotation (Line(points={{22,20},{80,20},{80,
          52},{98,52}}, color={255,127,0}));
  connect(curHou.y, staNor.u) annotation (Line(points={{102,170},{120,170},{120,
          120},{-80,120},{-80,30},{-62,30}}, color={0,0,127}));
  connect(curHou.y, endNor.u) annotation (Line(points={{102,170},{120,170},{120,
          120},{-80,120},{-80,60},{-62,60}}, color={0,0,127}));
annotation (defaultComponentName="ratSeaInd",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-140,-220},{140,220}})));
end RateSeasonIndicator;
