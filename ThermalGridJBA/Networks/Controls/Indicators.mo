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
  parameter Integer peaHouSta=16
    "Peak rate start hour"
    annotation (Dialog(group="Electricity rate"));
  parameter Integer peaHouEnd=21
    "Peak rate end hour"
    annotation (Dialog(group="Electricity rate"));
  parameter Real samplePeriod=7200
    "Sample period of district loop pump speed"
    annotation (Dialog(group="District load"));

  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum
    "District loop pump speed"
    annotation (Placement(transformation(extent={{-180,220},{-140,260}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uSolTim
    "Solar time. An output from weather data"
    annotation (Placement(transformation(extent={{-178,-60},{-138,-20}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput ySt
    "District loop load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{140,220},{180,260}}),
        iconTransformation(extent={{100,40},{140,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{140,0},{180,40}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yGen
    "Season indicator. 1-winter; 2-shoulder; 3-summer"
    annotation (Placement(transformation(extent={{140,-130},{180,-90}}),
        iconTransformation(extent={{100,-80},{140,-40}})));

  Buildings.Controls.OBC.CDL.Reals.Divide wee "Week of the year"
    annotation (Placement(transformation(extent={{-80,-120},{-60,-100}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(
    final k=7*24*3600) "One week"
    annotation (Placement(transformation(extent={{-120,-140},{-100,-120}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold winEnd(
    final t=winEndWee) "Winter end week"
    annotation (Placement(transformation(extent={{-40,-120},{-20,-100}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold winSta(
    final t=winStaWee) "Winter start week"
    annotation (Placement(transformation(extent={{-40,-170},{-20,-150}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi "Check season"
    annotation (Placement(transformation(extent={{80,-120},{100,-100}})));
  Buildings.Controls.OBC.CDL.Logical.Or win "Check if it is in winter"
    annotation (Placement(transformation(extent={{0,-120},{20,-100}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant winInd(
    final k=1) "Winter indicator"
    annotation (Placement(transformation(extent={{0,-80},{20,-60}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold sumSta(
    final t=sumStaWee)
    "Summer start week"
    annotation (Placement(transformation(extent={{-40,-200},{-20,-180}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold sumEnd(
    final t=sumEndWee)
    "Summer End week"
    annotation (Placement(transformation(extent={{-40,-230},{-20,-210}})));
  Buildings.Controls.OBC.CDL.Logical.And sum "Check if it is in summer"
    annotation (Placement(transformation(extent={{0,-200},{20,-180}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi1 "Check season"
    annotation (Placement(transformation(extent={{40,-200},{60,-180}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sumInd(final k=3)
    "Summer indicator"
    annotation (Placement(transformation(extent={{0,-170},{20,-150}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant shoInd(final k=2)
    "Shoulder season indicator"
    annotation (Placement(transformation(extent={{0,-240},{20,-220}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(
    final k=24*3600)
    "One day"
    annotation (Placement(transformation(extent={{-120,120},{-100,140}})));
  Buildings.Controls.OBC.CDL.Reals.Modulo mod1
    annotation (Placement(transformation(extent={{-80,140},{-60,160}})));
  Buildings.Controls.OBC.CDL.Reals.Divide hou "Hour of the day"
    annotation (Placement(transformation(extent={{-40,120},{-20,140}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con2(
    final k=3600)
    "One hour"
    annotation (Placement(transformation(extent={{-80,100},{-60,120}})));
  Buildings.Controls.OBC.CDL.Reals.Round rou(final n=0)
    "Round the hour to the nearest hour"
    annotation (Placement(transformation(extent={{0,120},{20,140}})));
  Buildings.Controls.OBC.CDL.Reals.Greater gre
    annotation (Placement(transformation(extent={{40,88},{60,108}})));
  Buildings.Controls.OBC.CDL.Reals.Switch curHou "Current hour"
    annotation (Placement(transformation(extent={{80,120},{100,140}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(
    final p=-1)
    "Previous hour"
    annotation (Placement(transformation(extent={{40,140},{60,160}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold endNor(
    final t=peaHouSta)
    "Check if it is the normal rate hour"
    annotation (Placement(transformation(extent={{-60,10},{-40,30}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold staNor(
    final t=peaHouEnd)
    "Check if it is in the normal rate hour"
    annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));
  Buildings.Controls.OBC.CDL.Logical.Or norRatHou
    "Check if it is in the normal rate hour"
    annotation (Placement(transformation(extent={{20,10},{40,30}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi2 "Check electricity rate"
    annotation (Placement(transformation(extent={{100,10},{120,30}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant norRatInd(
    final k=0)
    "Normal rate indicator"
    annotation (Placement(transformation(extent={{0,50},{20,70}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRatInd(
    final k=1) "High rate indicator"
    annotation (Placement(transformation(extent={{0,-30},{20,-10}})));
  Buildings.Controls.OBC.CDL.Discrete.Sampler sam(
    final samplePeriod=samplePeriod)
    "District loop load sampler"
    annotation (Placement(transformation(extent={{-120,230},{-100,250}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(final t=1/3)
    "Check if the speed is less than 1/3"
    annotation (Placement(transformation(extent={{-80,230},{-60,250}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(final t=2/3)
    "Check if the speed is greater than 2/3"
    annotation (Placement(transformation(extent={{-80,190},{-60,210}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi3 "Check district load"
    annotation (Placement(transformation(extent={{100,230},{120,250}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant lowLoa(final k=1)
    "Low district loop load"
    annotation (Placement(transformation(extent={{0,250},{20,270}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High district loop load"
    annotation (Placement(transformation(extent={{0,210},{20,230}})));
  Buildings.Controls.OBC.CDL.Integers.Switch intSwi4 "Check district load"
    annotation (Placement(transformation(extent={{60,190},{80,210}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant medLoa(final k=2)
    "Medium district loop load"
    annotation (Placement(transformation(extent={{0,170},{20,190}})));

equation
  connect(con.y, wee.u2) annotation (Line(points={{-98,-130},{-90,-130},{-90,-116},
          {-82,-116}},color={0,0,127}));
  connect(wee.y, winEnd.u)
    annotation (Line(points={{-58,-110},{-42,-110}}, color={0,0,127}));
  connect(wee.y, winSta.u) annotation (Line(points={{-58,-110},{-50,-110},{-50,-160},
          {-42,-160}}, color={0,0,127}));
  connect(winEnd.y,win. u1)
    annotation (Line(points={{-18,-110},{-2,-110}}, color={255,0,255}));
  connect(winSta.y,win. u2) annotation (Line(points={{-18,-160},{-10,-160},{-10,
          -118},{-2,-118}}, color={255,0,255}));
  connect(win.y, intSwi.u2)
    annotation (Line(points={{22,-110},{78,-110}}, color={255,0,255}));
  connect(winInd.y, intSwi.u1) annotation (Line(points={{22,-70},{70,-70},{70,-102},
          {78,-102}}, color={255,127,0}));
  connect(sumSta.y, sum.u1)
    annotation (Line(points={{-18,-190},{-2,-190}}, color={255,0,255}));
  connect(sumEnd.y, sum.u2) annotation (Line(points={{-18,-220},{-10,-220},{-10,
          -198},{-2,-198}}, color={255,0,255}));
  connect(wee.y, sumSta.u) annotation (Line(points={{-58,-110},{-50,-110},{-50,-190},
          {-42,-190}},color={0,0,127}));
  connect(wee.y, sumEnd.u) annotation (Line(points={{-58,-110},{-50,-110},{-50,-220},
          {-42,-220}},color={0,0,127}));
  connect(sum.y, intSwi1.u2)
    annotation (Line(points={{22,-190},{38,-190}}, color={255,0,255}));
  connect(sumInd.y, intSwi1.u1) annotation (Line(points={{22,-160},{30,-160},{30,
          -182},{38,-182}}, color={255,127,0}));
  connect(shoInd.y, intSwi1.u3) annotation (Line(points={{22,-230},{30,-230},{30,
          -198},{38,-198}}, color={255,127,0}));
  connect(intSwi1.y, intSwi.u3) annotation (Line(points={{62,-190},{70,-190},{70,
          -118},{78,-118}}, color={255,127,0}));
  connect(intSwi.y, yGen)
    annotation (Line(points={{102,-110},{160,-110}}, color={255,127,0}));
  connect(wee.u1, uSolTim) annotation (Line(points={{-82,-104},{-130,-104},{-130,
          -40},{-158,-40}}, color={0,0,127}));
  connect(con1.y, mod1.u2) annotation (Line(points={{-98,130},{-90,130},{-90,144},
          {-82,144}}, color={0,0,127}));
  connect(uSolTim, mod1.u1) annotation (Line(points={{-158,-40},{-130,-40},{-130,
          156},{-82,156}}, color={0,0,127}));
  connect(mod1.y, hou.u1) annotation (Line(points={{-58,150},{-50,150},{-50,136},
          {-42,136}}, color={0,0,127}));
  connect(con2.y, hou.u2) annotation (Line(points={{-58,110},{-50,110},{-50,124},
          {-42,124}}, color={0,0,127}));
  connect(hou.y, rou.u)
    annotation (Line(points={{-18,130},{-2,130}}, color={0,0,127}));
  connect(rou.y, gre.u1) annotation (Line(points={{22,130},{30,130},{30,98},{38,
          98}},  color={0,0,127}));
  connect(hou.y, gre.u2) annotation (Line(points={{-18,130},{-10,130},{-10,90},{
          38,90}},   color={0,0,127}));
  connect(gre.y, curHou.u2) annotation (Line(points={{62,98},{70,98},{70,130},{78,
          130}},     color={255,0,255}));
  connect(rou.y, addPar.u) annotation (Line(points={{22,130},{30,130},{30,150},{
          38,150}}, color={0,0,127}));
  connect(addPar.y, curHou.u1) annotation (Line(points={{62,150},{70,150},{70,138},
          {78,138}}, color={0,0,127}));
  connect(rou.y, curHou.u3) annotation (Line(points={{22,130},{30,130},{30,122},
          {78,122}}, color={0,0,127}));
  connect(norRatHou.y, intSwi2.u2)
    annotation (Line(points={{42,20},{98,20}}, color={255,0,255}));
  connect(endNor.y, norRatHou.u1)
    annotation (Line(points={{-38,20},{18,20}}, color={255,0,255}));
  connect(staNor.y, norRatHou.u2) annotation (Line(points={{-38,-10},{-20,-10},{
          -20,12},{18,12}}, color={255,0,255}));
  connect(intSwi2.y, yEleRat)
    annotation (Line(points={{122,20},{160,20}}, color={255,127,0}));
  connect(norRatInd.y, intSwi2.u1) annotation (Line(points={{22,60},{80,60},{80,
          28},{98,28}}, color={255,127,0}));
  connect(higRatInd.y, intSwi2.u3) annotation (Line(points={{22,-20},{80,-20},{80,
          12},{98,12}}, color={255,127,0}));
  connect(curHou.y, staNor.u) annotation (Line(points={{102,130},{120,130},{120,
          80},{-80,80},{-80,-10},{-62,-10}}, color={0,0,127}));
  connect(curHou.y, endNor.u) annotation (Line(points={{102,130},{120,130},{120,
          80},{-80,80},{-80,20},{-62,20}},   color={0,0,127}));
  connect(uDisPum, sam.u)
    annotation (Line(points={{-160,240},{-122,240}}, color={0,0,127}));
  connect(lesThr.y, intSwi3.u2)
    annotation (Line(points={{-58,240},{98,240}}, color={255,0,255}));
  connect(lowLoa.y, intSwi3.u1) annotation (Line(points={{22,260},{80,260},{80,248},
          {98,248}}, color={255,127,0}));
  connect(higLoa.y, intSwi4.u1) annotation (Line(points={{22,220},{40,220},{40,208},
          {58,208}}, color={255,127,0}));
  connect(greThr.y, intSwi4.u2)
    annotation (Line(points={{-58,200},{58,200}}, color={255,0,255}));
  connect(medLoa.y, intSwi4.u3) annotation (Line(points={{22,180},{40,180},{40,192},
          {58,192}}, color={255,127,0}));
  connect(intSwi4.y, intSwi3.u3) annotation (Line(points={{82,200},{90,200},{90,
          232},{98,232}}, color={255,127,0}));
  connect(sam.y, lesThr.u)
    annotation (Line(points={{-98,240},{-82,240}}, color={0,0,127}));
  connect(sam.y, greThr.u) annotation (Line(points={{-98,240},{-90,240},{-90,200},
          {-82,200}}, color={0,0,127}));
  connect(intSwi3.y, ySt)
    annotation (Line(points={{122,240},{160,240}}, color={255,127,0}));
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
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-140,-260},{140,280}})));
end Indicators;
