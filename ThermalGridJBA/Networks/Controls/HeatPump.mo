within ThermalGridJBA.Networks.Controls;
model HeatPump "Sequence for controlling heat pump, its pumps and valves"

  parameter Real TDisLooMin(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=283.65
    "Design minimum district loop temperature";
  parameter Real TDisLooMax(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=297.15
    "Design maximum district loop temperature";
  parameter Real TCooSet(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=TDisLooMin
    "Heat pump tracking temperature setpoint in cooling mode";
  parameter Real THeaSet(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=TDisLooMax
    "Heat pump tracking temperature setpoint in heating mode";
  parameter Real TConInMin(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Minimum condenser inlet temperature";
  parameter Real TEvaInMax(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Maximum evaporator inlet temperature";
  parameter Real minComSpe(
    final min=0,
    final max=1,
    final unit="1")=0.2
    "Minimum heat pump compressor speed";
  parameter Real offTim(
    final unit="s")=12*3600
    "Heat pump off time";
  parameter Real del(
    final unit="s")=120
    "Threshold time for checking if the compressor has been in the minimum speed"
    annotation (Dialog(tab="Advanced"));
  parameter Real THys(
    final quantity="TemperatureDifference",
    final unit="K")=0.1
    "Hysteresis for comparing temperature"
    annotation (Dialog(tab="Advanced"));
  parameter Real speHys=0.01
    "Hysteresis for speed check"
    annotation (Dialog(tab="Advanced"));

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{-320,400},{-280,440}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "District loop load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-320,350},{-280,390}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixAve(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Average temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-320,310},{-280,350}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water flowing out the heat pump"
    annotation (Placement(transformation(extent={{-320,200},{-280,240}}),
        iconTransformation(extent={{-140,-10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uGen
    "Season indicator. 1-winter; 2-shoulder; 3-summer"
    annotation (Placement(transformation(extent={{-320,100},{-280,140}}),
        iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum(
    final min=0,
    final max=1,
    final unit="1")
    "District loop pump speed setpoint"
    annotation (Placement(transformation(extent={{-320,-160},{-280,-120}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TGlyIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Temperature of the glycol flowing into the heat pump"
    annotation (Placement(transformation(extent={{-320,-300},{-280,-260}}),
        iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1Mod
    "=true for heating, =false for cooling" annotation (Placement(
        transformation(extent={{280,380},{320,420}}), iconTransformation(extent
          ={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TLea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Leaving water temperature setpoint"
    annotation (Placement(transformation(extent={{280,240},{320,280}}),
        iconTransformation(extent={{100,40},{140,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput ySet(
    final min=0,
    final max=1,
    final unit="1")
    "Heat pump compression speed setpoint"
    annotation (Placement(transformation(extent={{280,110},{320,150}}),
        iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1On
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{280,40},{320,80}}),
        iconTransformation(extent={{100,-10},{140,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumGly(
    final min=0,
    final max=1,
    final unit="1")
    "Pump speed setpoint in glycol side"
    annotation (Placement(transformation(extent={{280,-20},{320,20}}),
        iconTransformation(extent={{100,-40},{140,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yVal(
    final min=0,
    final max=1,
    final unit="1")
    "Control valve position setpoint"
    annotation (Placement(transformation(extent={{280,-80},{320,-40}}),
        iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPum(
    final min=0,
    final max=1,
    final unit="1")
    "Waterside pump speed setpoint"
    annotation (Placement(transformation(extent={{280,-150},{320,-110}}),
        iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValByp(
    final min=0,
    final max=1,
    final unit="1")
    "Bypass valve in glycol side, greater valve means larger bypass flow"
    annotation (Placement(transformation(extent={{280,-410},{320,-370}}),
        iconTransformation(extent={{100,-110},{140,-70}})));

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(
    final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-260,430},{-240,450}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(
    final k=3)
    "HIgh district load"
    annotation (Placement(transformation(extent={{-260,380},{-240,400}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higRatMod
    "Check if it is in high electricity rate mode"
    annotation (Placement(transformation(extent={{-220,430},{-200,450}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higLoaMod
    "Check if the district load is high"
    annotation (Placement(transformation(extent={{-200,380},{-180,400}})));
  Buildings.Controls.OBC.CDL.Logical.And higHig
    "High electricity rate and high district load"
    annotation (Placement(transformation(extent={{-140,430},{-120,450}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant desMinDisTem(
    final k=TDisLooMin)
    "Design minimum district loop temperature"
    annotation (Placement(transformation(extent={{-260,290},{-240,310}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant desMaxDisTem(
    final k=TDisLooMax)
    "Design maximum district loop temperature"
    annotation (Placement(transformation(extent={{-260,250},{-240,270}})));
  Buildings.Controls.OBC.CDL.Reals.Average ave
    annotation (Placement(transformation(extent={{-180,270},{-160,290}})));
  Buildings.Controls.OBC.CDL.Reals.Less colLoo(
    final h=THys)
    "Check if the district loop is too cold"
    annotation (Placement(transformation(extent={{-140,320},{-120,340}})));
  Buildings.Controls.OBC.CDL.Logical.And heaMod "Heat pump in heating mode"
    annotation (Placement(transformation(extent={{-60,320},{-40,340}})));
  Buildings.Controls.OBC.CDL.Logical.Not hotLoo
    "Check if the district loop is too hot"
    annotation (Placement(transformation(extent={{-100,240},{-80,260}})));
  Buildings.Controls.OBC.CDL.Logical.And cooMod "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{-60,240},{-40,260}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(
    final k=1)
    "Winter"
    annotation (Placement(transformation(extent={{-260,130},{-240,150}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin
    "Check if it is in winter"
    annotation (Placement(transformation(extent={{-180,130},{-160,150}})));
  Buildings.Controls.OBC.CDL.Integers.Equal norRatMod
    "Check if it is in normal electricity rate mode"
    annotation (Placement(transformation(extent={{-180,170},{-160,190}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant norRat(
    final k=0)
    "Normal electricity rate"
    annotation (Placement(transformation(extent={{-260,170},{-240,190}})));
  Buildings.Controls.OBC.CDL.Logical.And heaMod1
    "Heat pump in heating mode"
    annotation (Placement(transformation(extent={{-60,170},{-40,190}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum1(
    final k=3)
    "Summer"
    annotation (Placement(transformation(extent={{-260,80},{-240,100}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum
    "Check if it is in summer"
    annotation (Placement(transformation(extent={{-180,80},{-160,100}})));
  Buildings.Controls.OBC.CDL.Logical.And cooMod1
    "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{-60,80},{-40,100}})));
  Buildings.Controls.OBC.CDL.Logical.Or heaMod2
    "Heat pump in heating mode"
    annotation (Placement(transformation(extent={{0,320},{20,340}})));
  Buildings.Controls.OBC.CDL.Logical.Or cooMod2
    "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{0,240},{20,260}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi
    annotation (Placement(transformation(extent={{140,320},{160,340}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{100,240},{120,260}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant cooTraTem(
    final k=TCooSet)
    "Heat pump tracking temperature in cooling mode"
    annotation (Placement(transformation(extent={{0,280},{20,300}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant heaTraTem(
    final k=THeaSet)
    "Heat pump tracking temperature in heating mode"
    annotation (Placement(transformation(extent={{0,360},{20,380}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset heaPumCon(
    final y_reset=1)
    "Heat pump controller"
    annotation (Placement(transformation(extent={{100,100},{120,120}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHeaPum
    "Enable heat pump"
    annotation (Placement(transformation(extent={{60,50},{80,70}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel(
    final delayTime=del)
    "Check if the compressor has been in minimum speed for sufficient time"
    annotation (Placement(transformation(extent={{-140,0},{-120,20}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(
    final t=minComSpe,
    final h=speHys)
    "Check if the compressor speed is lower than the minimum"
    annotation (Placement(transformation(extent={{-180,0},{-160,20}})));
  Buildings.Controls.OBC.CDL.Logical.And disHeaPum
    "Check if the heat pump should be disabled"
    annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{60,100},{80,120}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    annotation (Placement(transformation(extent={{80,190},{100,210}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi2
    annotation (Placement(transformation(extent={{160,170},{180,190}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(
    final k=-1)
    "Reverse"
    annotation (Placement(transformation(extent={{120,150},{140,170}})));
  Buildings.Controls.OBC.CDL.Reals.Switch leaWatTem
    "Heat pump leaving water temperature setpoint"
    annotation (Placement(transformation(extent={{220,250},{240,270}})));
  Buildings.Controls.OBC.CDL.Reals.Switch comSpe
    "Heat pump compresson speed"
    annotation (Placement(transformation(extent={{222,120},{242,140}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one(
    final k=1) "One"
    annotation (Placement(transformation(extent={{60,-80},{80,-60}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi4
    "Waterside valve position and the pump speed in glycol side"
    annotation (Placement(transformation(extent={{220,-70},{240,-50}})));
  Buildings.Controls.OBC.CDL.Reals.Switch comSpe2
    "Heat pump compresson speed"
    annotation (Placement(transformation(extent={{160,-110},{180,-90}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer1(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{60,-40},{80,-20}})));
  Buildings.Controls.OBC.CDL.Reals.Switch pumSpe1
    "Waterside pump speed"
    annotation (Placement(transformation(extent={{160,-170},{180,-150}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi3
    "Waterside pump speed"
    annotation (Placement(transformation(extent={{220,-140},{240,-120}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub1
    annotation (Placement(transformation(extent={{80,-340},{100,-320}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(
    final k=-1)
    "Reverse"
    annotation (Placement(transformation(extent={{120,-380},{140,-360}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi5
    annotation (Placement(transformation(extent={{160,-360},{180,-340}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset thrWayValCon(
    final reverseActing=false,
    final y_reset=1)
    "Three way valve controller, larger output means larger bypass flow"
    annotation (Placement(transformation(extent={{120,-448},{140,-428}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer2(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{60,-448},{80,-428}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi6
    annotation (Placement(transformation(extent={{120,-270},{140,-250}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi7
    annotation (Placement(transformation(extent={{160,-210},{180,-190}})));
  Buildings.Controls.OBC.CDL.Reals.Switch entGlyTem
    "Heat pump glycol entering temperature setpoint"
    annotation (Placement(transformation(extent={{220,-300},{240,-280}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minConInTem(
    final k=TConInMin)
    "Minimum condenser inlet temperature"
    annotation (Placement(transformation(extent={{60,-242},{80,-222}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant maxEvaInlTem(
    final k=TEvaInMax)
    "Maximum evaporator inlet temperature"
    annotation (Placement(transformation(extent={{60,-190},{80,-170}})));
  Buildings.Controls.OBC.CDL.Reals.Switch thrWayVal
    "Heat pump glycol side 3-way valve"
    annotation (Placement(transformation(extent={{220,-400},{240,-380}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one3(
    final k=1) "One"
    annotation (Placement(transformation(extent={{60,-410},{80,-390}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold offHeaPum(
    final trueHoldDuration=offTim,
    final falseHoldDuration=0)
    "Keep heat pump being off for sufficient time"
    annotation (Placement(transformation(extent={{0,0},{20,20}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1
    "Not disabled"
    annotation (Placement(transformation(extent={{160,20},{180,40}})));
  Buildings.Controls.OBC.CDL.Logical.And and2
    "Enabled heat pump "
    annotation (Placement(transformation(extent={{220,50},{240,70}})));

equation
  connect(higRat.y, higRatMod.u1)
    annotation (Line(points={{-238,440},{-222,440}}, color={255,127,0}));
  connect(uEleRat, higRatMod.u2) annotation (Line(points={{-300,420},{-230,420},
          {-230,432},{-222,432}}, color={255,127,0}));
  connect(higLoa.y, higLoaMod.u1)
    annotation (Line(points={{-238,390},{-202,390}}, color={255,127,0}));
  connect(uSt, higLoaMod.u2) annotation (Line(points={{-300,370},{-220,370},{-220,
          382},{-202,382}},      color={255,127,0}));
  connect(higRatMod.y, higHig.u1)
    annotation (Line(points={{-198,440},{-142,440}}, color={255,0,255}));
  connect(higLoaMod.y, higHig.u2) annotation (Line(points={{-178,390},{-150,390},
          {-150,432},{-142,432}}, color={255,0,255}));
  connect(desMinDisTem.y, ave.u1) annotation (Line(points={{-238,300},{-200,300},
          {-200,286},{-182,286}}, color={0,0,127}));
  connect(desMaxDisTem.y, ave.u2) annotation (Line(points={{-238,260},{-200,260},
          {-200,274},{-182,274}}, color={0,0,127}));
  connect(TMixAve, colLoo.u1)
    annotation (Line(points={{-300,330},{-142,330}}, color={0,0,127}));
  connect(ave.y, colLoo.u2) annotation (Line(points={{-158,280},{-150,280},{-150,
          322},{-142,322}}, color={0,0,127}));
  connect(colLoo.y, heaMod.u1)
    annotation (Line(points={{-118,330},{-62,330}}, color={255,0,255}));
  connect(higHig.y, heaMod.u2) annotation (Line(points={{-118,440},{-70,440},{-70,
          322},{-62,322}},   color={255,0,255}));
  connect(colLoo.y, hotLoo.u) annotation (Line(points={{-118,330},{-110,330},{-110,
          250},{-102,250}}, color={255,0,255}));
  connect(win.y, inWin.u1)
    annotation (Line(points={{-238,140},{-182,140}}, color={255,127,0}));
  connect(uGen, inWin.u2) annotation (Line(points={{-300,120},{-210,120},{-210,132},
          {-182,132}}, color={255,127,0}));
  connect(norRat.y, norRatMod.u1)
    annotation (Line(points={{-238,180},{-182,180}}, color={255,127,0}));
  connect(uEleRat, norRatMod.u2) annotation (Line(points={{-300,420},{-230,420},
          {-230,172},{-182,172}}, color={255,127,0}));
  connect(norRatMod.y, heaMod1.u1)
    annotation (Line(points={{-158,180},{-62,180}}, color={255,0,255}));
  connect(inWin.y, heaMod1.u2) annotation (Line(points={{-158,140},{-100,140},{-100,
          172},{-62,172}}, color={255,0,255}));
  connect(sum1.y, inSum.u1)
    annotation (Line(points={{-238,90},{-182,90}}, color={255,127,0}));
  connect(uGen, inSum.u2) annotation (Line(points={{-300,120},{-210,120},{-210,82},
          {-182,82}}, color={255,127,0}));
  connect(inSum.y, cooMod1.u1)
    annotation (Line(points={{-158,90},{-62,90}}, color={255,0,255}));
  connect(norRatMod.y, cooMod1.u2) annotation (Line(points={{-158,180},{-120,180},
          {-120,82},{-62,82}}, color={255,0,255}));
  connect(heaMod.y, heaMod2.u1)
    annotation (Line(points={{-38,330},{-2,330}}, color={255,0,255}));
  connect(heaMod1.y, heaMod2.u2) annotation (Line(points={{-38,180},{-20,180},{-20,
          322},{-2,322}}, color={255,0,255}));
  connect(cooMod.y, cooMod2.u1)
    annotation (Line(points={{-38,250},{-2,250}}, color={255,0,255}));
  connect(cooMod1.y, cooMod2.u2) annotation (Line(points={{-38,90},{-10,90},{-10,
          242},{-2,242}},color={255,0,255}));
  connect(heaMod2.y, swi.u2)
    annotation (Line(points={{22,330},{138,330}}, color={255,0,255}));
  connect(cooMod2.y, swi1.u2)
    annotation (Line(points={{22,250},{98,250}},color={255,0,255}));
  connect(hotLoo.y, cooMod.u1)
    annotation (Line(points={{-78,250},{-62,250}}, color={255,0,255}));
  connect(higHig.y, cooMod.u2) annotation (Line(points={{-118,440},{-70,440},{-70,
          242},{-62,242}}, color={255,0,255}));
  connect(cooTraTem.y, swi1.u1) annotation (Line(points={{22,290},{40,290},{40,258},
          {98,258}}, color={0,0,127}));
  connect(heaTraTem.y, swi.u1) annotation (Line(points={{22,370},{80,370},{80,338},
          {138,338}},    color={0,0,127}));
  connect(swi1.y, swi.u3) annotation (Line(points={{122,250},{130,250},{130,322},
          {138,322}}, color={0,0,127}));
  connect(heaMod2.y, y1Mod) annotation (Line(points={{22,330},{50,330},{50,400},
          {300,400}}, color={255,0,255}));
  connect(TWatOut, swi1.u3) annotation (Line(points={{-300,220},{40,220},{40,242},
          {98,242}},   color={0,0,127}));
  connect(cooMod2.y, enaHeaPum.u2) annotation (Line(points={{22,250},{30,250},{30,
          52},{58,52}},     color={255,0,255}));
  connect(heaMod2.y, enaHeaPum.u1) annotation (Line(points={{22,330},{50,330},{50,
          60},{58,60}},     color={255,0,255}));
  connect(enaHeaPum.y, heaPumCon.trigger)
    annotation (Line(points={{82,60},{104,60},{104,98}}, color={255,0,255}));
  connect(heaPumCon.y, lesThr.u) annotation (Line(points={{122,110},{140,110},{140,
          40},{-200,40},{-200,10},{-182,10}}, color={0,0,127}));
  connect(lesThr.y, truDel.u)
    annotation (Line(points={{-158,10},{-142,10}}, color={255,0,255}));
  connect(truDel.y, disHeaPum.u1)
    annotation (Line(points={{-118,10},{-62,10}}, color={255,0,255}));
  connect(enaHeaPum.y, disHeaPum.u2) annotation (Line(points={{82,60},{104,60},{
          104,32},{-80,32},{-80,2},{-62,2}}, color={255,0,255}));
  connect(disHeaPum.y, offHeaPum.u)
    annotation (Line(points={{-38,10},{-2,10}}, color={255,0,255}));
  connect(zer.y, heaPumCon.u_s)
    annotation (Line(points={{82,110},{98,110}}, color={0,0,127}));
  connect(TWatOut, sub.u1) annotation (Line(points={{-300,220},{40,220},{40,206},
          {78,206}}, color={0,0,127}));
  connect(heaMod2.y, swi2.u2) annotation (Line(points={{22,330},{50,330},{50,180},
          {158,180}}, color={255,0,255}));
  connect(sub.y, swi2.u1) annotation (Line(points={{102,200},{110,200},{110,188},
          {158,188}}, color={0,0,127}));
  connect(gai.y, swi2.u3) annotation (Line(points={{142,160},{150,160},{150,172},
          {158,172}}, color={0,0,127}));
  connect(sub.y, gai.u) annotation (Line(points={{102,200},{110,200},{110,160},{
          118,160}}, color={0,0,127}));
  connect(swi2.y, heaPumCon.u_m) annotation (Line(points={{182,180},{190,180},{190,
          90},{110,90},{110,98}}, color={0,0,127}));
  connect(offHeaPum.y, leaWatTem.u2) annotation (Line(points={{22,10},{200,10},{
          200,260},{218,260}}, color={255,0,255}));
  connect(TWatOut, leaWatTem.u1) annotation (Line(points={{-300,220},{190,220},{
          190,268},{218,268}}, color={0,0,127}));
  connect(swi.y, leaWatTem.u3) annotation (Line(points={{162,330},{170,330},{170,
          252},{218,252}}, color={0,0,127}));
  connect(leaWatTem.y, sub.u2) annotation (Line(points={{242,260},{250,260},{250,
          230},{60,230},{60,194},{78,194}}, color={0,0,127}));
  connect(offHeaPum.y, comSpe.u2) annotation (Line(points={{22,10},{200,10},{200,
          130},{220,130}}, color={255,0,255}));
  connect(zer.y, comSpe.u1) annotation (Line(points={{82,110},{90,110},{90,138},
          {220,138}}, color={0,0,127}));
  connect(heaPumCon.y, comSpe.u3) annotation (Line(points={{122,110},{140,110},{
          140,122},{220,122}}, color={0,0,127}));
  connect(offHeaPum.y, swi4.u2) annotation (Line(points={{22,10},{200,10},{200,-60},
          {218,-60}}, color={255,0,255}));
  connect(one.y, comSpe2.u1) annotation (Line(points={{82,-70},{140,-70},{140,-92},
          {158,-92}}, color={0,0,127}));
  connect(enaHeaPum.y, comSpe2.u2) annotation (Line(points={{82,60},{104,60},{104,
          -100},{158,-100}}, color={255,0,255}));
  connect(zer1.y, swi4.u1) annotation (Line(points={{82,-30},{120,-30},{120,-52},
          {218,-52}}, color={0,0,127}));
  connect(comSpe2.y, swi4.u3) annotation (Line(points={{182,-100},{210,-100},{210,
          -68},{218,-68}}, color={0,0,127}));
  connect(zer1.y, comSpe2.u3) annotation (Line(points={{82,-30},{120,-30},{120,-108},
          {158,-108}}, color={0,0,127}));
  connect(offHeaPum.y, swi3.u2) annotation (Line(points={{22,10},{200,10},{200,-130},
          {218,-130}}, color={255,0,255}));
  connect(zer1.y, swi3.u1) annotation (Line(points={{82,-30},{120,-30},{120,-122},
          {218,-122}}, color={0,0,127}));
  connect(pumSpe1.y, swi3.u3) annotation (Line(points={{182,-160},{212,-160},{212,
          -138},{218,-138}}, color={0,0,127}));
  connect(enaHeaPum.y, pumSpe1.u2) annotation (Line(points={{82,60},{104,60},{104,
          -160},{158,-160}}, color={255,0,255}));
  connect(uDisPum, pumSpe1.u1) annotation (Line(points={{-300,-140},{150,-140},{
          150,-152},{158,-152}}, color={0,0,127}));
  connect(zer1.y, pumSpe1.u3) annotation (Line(points={{82,-30},{120,-30},{120,-168},
          {158,-168}}, color={0,0,127}));
  connect(sub1.y, swi5.u1) annotation (Line(points={{102,-330},{110,-330},{110,-342},
          {158,-342}}, color={0,0,127}));
  connect(gai1.y, swi5.u3) annotation (Line(points={{142,-370},{150,-370},{150,-358},
          {158,-358}}, color={0,0,127}));
  connect(swi5.y, thrWayValCon.u_m) annotation (Line(points={{182,-350},{190,-350},
          {190,-460},{130,-460},{130,-450}}, color={0,0,127}));
  connect(sub1.y, gai1.u) annotation (Line(points={{102,-330},{110,-330},{110,-370},
          {118,-370}}, color={0,0,127}));
  connect(heaMod2.y, swi7.u2) annotation (Line(points={{22,330},{50,330},{50,-200},
          {158,-200}}, color={255,0,255}));
  connect(maxEvaInlTem.y, swi7.u1) annotation (Line(points={{82,-180},{150,-180},
          {150,-192},{158,-192}}, color={0,0,127}));
  connect(minConInTem.y, swi6.u1) annotation (Line(points={{82,-232},{110,-232},
          {110,-252},{118,-252}}, color={0,0,127}));
  connect(swi6.y, swi7.u3) annotation (Line(points={{142,-260},{150,-260},{150,-208},
          {158,-208}}, color={0,0,127}));
  connect(cooMod2.y, swi6.u2) annotation (Line(points={{22,250},{30,250},{30,-260},
          {118,-260}}, color={255,0,255}));
  connect(TGlyIn, swi6.u3) annotation (Line(points={{-300,-280},{110,-280},{110,
          -268},{118,-268}}, color={0,0,127}));
  connect(offHeaPum.y, entGlyTem.u2) annotation (Line(points={{22,10},{200,10},{
          200,-290},{218,-290}}, color={255,0,255}));
  connect(TGlyIn, entGlyTem.u1) annotation (Line(points={{-300,-280},{110,-280},
          {110,-282},{218,-282}}, color={0,0,127}));
  connect(swi7.y, entGlyTem.u3) annotation (Line(points={{182,-200},{190,-200},{
          190,-298},{218,-298}}, color={0,0,127}));
  connect(heaMod2.y, swi5.u2) annotation (Line(points={{22,330},{50,330},{50,-350},
          {158,-350}}, color={255,0,255}));
  connect(TGlyIn, sub1.u1) annotation (Line(points={{-300,-280},{-200,-280},{-200,
          -324},{78,-324}}, color={0,0,127}));
  connect(entGlyTem.y, sub1.u2) annotation (Line(points={{242,-290},{250,-290},{
          250,-310},{70,-310},{70,-336},{78,-336}}, color={0,0,127}));
  connect(zer2.y, thrWayValCon.u_s)
    annotation (Line(points={{82,-438},{118,-438}}, color={0,0,127}));
  connect(offHeaPum.y, thrWayVal.u2) annotation (Line(points={{22,10},{200,10},{
          200,-390},{218,-390}}, color={255,0,255}));
  connect(thrWayValCon.y, thrWayVal.u3) annotation (Line(points={{142,-438},{180,
          -438},{180,-398},{218,-398}}, color={0,0,127}));
  connect(enaHeaPum.y, thrWayValCon.trigger) annotation (Line(points={{82,60},{104,
          60},{104,-460},{124,-460},{124,-450}}, color={255,0,255}));
  connect(one3.y, thrWayVal.u1) annotation (Line(points={{82,-400},{160,-400},{160,
          -382},{218,-382}}, color={0,0,127}));
  connect(leaWatTem.y, TLea)
    annotation (Line(points={{242,260},{300,260}}, color={0,0,127}));
  connect(comSpe.y, ySet)
    annotation (Line(points={{244,130},{300,130}}, color={0,0,127}));
  connect(swi4.y, yVal)
    annotation (Line(points={{242,-60},{300,-60}}, color={0,0,127}));
  connect(swi4.y, yPumGly) annotation (Line(points={{242,-60},{250,-60},{250,0},
          {300,0}}, color={0,0,127}));
  connect(swi3.y, yPum)
    annotation (Line(points={{242,-130},{300,-130}}, color={0,0,127}));
  connect(thrWayVal.y, yValByp)
    annotation (Line(points={{242,-390},{300,-390}}, color={0,0,127}));
  connect(enaHeaPum.y, and2.u1)
    annotation (Line(points={{82,60},{218,60}}, color={255,0,255}));
  connect(offHeaPum.y, not1.u) annotation (Line(points={{22,10},{140,10},{140,30},
          {158,30}}, color={255,0,255}));
  connect(not1.y, and2.u2) annotation (Line(points={{182,30},{190,30},{190,52},{
          218,52}}, color={255,0,255}));
  connect(and2.y, y1On)
    annotation (Line(points={{242,60},{300,60}}, color={255,0,255}));
  annotation (defaultComponentName="heaPumCon",
Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics={Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),
                                Diagram(coordinateSystem(preserveAspectRatio=
            false, extent={{-280,-480},{280,480}})),
Documentation(info="
<html>
<p>
FIXME:
</p>
</html>", revisions="<html>
<ul>
<li>
February 3, 2025, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"));
end HeatPump;
