within ThermalGridJBA.Networks.Controls;
block HeatPump_2
  "Sequence for controlling heat pump and the associated valves, pumps"
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{-420,310},{-380,350}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "Plant load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-420,270},{-380,310}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSea
    "Season indicator. 1-Winter; 2-Spring; 3-Summer; 4-Fall"
    annotation (Placement(transformation(extent={{-420,230},{-380,270}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-360,430},{-340,450}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High plant load"
    annotation (Placement(transformation(extent={{-300,430},{-280,450}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(final k=1) "Winter"
    annotation (Placement(transformation(extent={{-220,430},{-200,450}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant spr(final k=2) "Spring"
    annotation (Placement(transformation(extent={{-220,400},{-200,420}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum1(final k=3)
                                                                      "Summer"
    annotation (Placement(transformation(extent={{-220,370},{-200,390}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant fal(final k=4) "Fall"
    annotation (Placement(transformation(extent={{-220,340},{-200,360}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higEleRat "High electricity rate"
    annotation (Placement(transformation(extent={{-320,320},{-300,340}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higPlaLoa "High plant load"
    annotation (Placement(transformation(extent={{-260,320},{-240,340}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin "In Winter"
    annotation (Placement(transformation(extent={{-140,320},{-120,340}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSpr "In Spring"
    annotation (Placement(transformation(extent={{-140,290},{-120,310}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum "In Summer"
    annotation (Placement(transformation(extent={{-140,260},{-120,280}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inFal "In Fall"
    annotation (Placement(transformation(extent={{-140,230},{-120,250}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TPlaIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water into the central plant"
    annotation (Placement(transformation(extent={{-420,180},{-380,220}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant heaSet(y(unit="K",
        displayUnit="degC"), final k=TPlaHeaSet)
                        "Plant heating setpoint"
    annotation (Placement(transformation(extent={{-360,140},{-340,160}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant cooSet(y(unit="K",
        displayUnit="degC"), final k=TPlaCooSet)
    "Plant cooling setpoint"
    annotation (Placement(transformation(extent={{-360,80},{-340,100}})));
  Buildings.Controls.OBC.CDL.Reals.Average aveSet
    "Average plant setpoint temperature"
    annotation (Placement(transformation(extent={{-320,110},{-300,130}})));
  Buildings.Controls.OBC.CDL.Reals.Less heaMod(final h=THys)
    "Heat pump should be in heating mode"
    annotation (Placement(transformation(extent={{-280,170},{-260,190}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1Mod
    "=true for heating, =false for cooling"
    annotation (Placement(transformation(extent={{380,400},{420,440}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yComSet(
    final min=0,
    final max=1,
    final unit="1") "Heat pump compression speed setpoint" annotation (
      Placement(transformation(extent={{380,110},{420,150}}),iconTransformation(
          extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1On
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{380,20},{420,60}}),
        iconTransformation(extent={{100,-10},{140,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumGly(final quantity=
        "MassFlowRate", final unit="kg/s")
    "Pump speed setpoint in glycol side"
    annotation (Placement(transformation(extent={{380,-20},{420,20}}),
        iconTransformation(extent={{100,-40},{140,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yVal(
    final min=0,
    final max=1,
    final unit="1")
    "Control valve position setpoint"
    annotation (Placement(transformation(extent={{380,-60},{420,-20}}),
        iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPum(final quantity=
        "MassFlowRate", final unit="kg/s")
    "Waterside pump speed setpoint"
    annotation (Placement(transformation(extent={{380,-130},{420,-90}}),
        iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValByp(
    final min=0,
    final max=1,
    final unit="1")
    "Bypass valve in glycol side, greater valve means less bypass flow"
    annotation (Placement(transformation(extent={{380,-390},{420,-350}}),
        iconTransformation(extent={{100,-110},{140,-70}})));
  Buildings.Controls.OBC.CDL.Reals.Switch plaSet "Plant setpoint"
    annotation (Placement(transformation(extent={{-240,110},{-220,130}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mPla_flow(final quantity=
        "MassFlowRate", final unit="kg/s") "Plant mass flow rate" annotation (
      Placement(transformation(extent={{-420,-20},{-380,20}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mHeaPum_flow(final quantity=
        "MassFlowRate", final unit="kg/s") "Heat pump mass flow rate"
    annotation (Placement(transformation(extent={{-420,-50},{-380,-10}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Reals.Switch heaPumFlo "Heat pump water flow rate"
    annotation (Placement(transformation(extent={{-320,-60},{-300,-40}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant dumCon(final k=1e-3)
    "Dummy constant to avoid zero division"
    annotation (Placement(transformation(extent={{-360,-90},{-340,-70}})));
  Buildings.Controls.OBC.CDL.Reals.Divide div1 "Input 1 divided by input 2"
    annotation (Placement(transformation(extent={{-280,-30},{-260,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub "Find difference"
    annotation (Placement(transformation(extent={{-200,80},{-180,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaPumIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water into the heat pump"
    annotation (Placement(transformation(extent={{-420,40},{-380,80}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul "Multiply inputs"
    annotation (Placement(transformation(extent={{-160,0},{-140,20}})));
  Buildings.Controls.OBC.CDL.Reals.Add leaWatSet
    "Heat pump leaving water temperature setpoint"
    annotation (Placement(transformation(extent={{-120,70},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum(
    final unit="1",
    final min=0,
    final max=1)
    "District pump norminal speed"
    annotation (Placement(transformation(extent={{-420,-220},{-380,-180}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaPumOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water out of the heat pump"
    annotation (Placement(transformation(extent={{-420,10},{-380,50}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset heaPumCon(
    final controllerType=heaPumConTyp,
    final k=kHeaPum,
    final Ti=TiHeaPum,
    final Td=TdHeaPum,
    final reverseActing=false,
    final y_reset=1)
    "Heat pump controller"
    annotation (Placement(transformation(extent={{80,210},{100,230}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub1
    annotation (Placement(transformation(extent={{-80,50},{-60,70}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(final k=-1)
    "Reverse"
    annotation (Placement(transformation(extent={{-40,50},{-20,70}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi2
    annotation (Placement(transformation(extent={{-2,100},{18,120}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(final k=0)
               "Zero"
    annotation (Placement(transformation(extent={{20,210},{40,230}})));
  Buildings.Controls.OBC.CDL.Logical.Pre pre "Break loop"
    annotation (Placement(transformation(extent={{-320,-180},{-300,-160}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay delChe(final delayTime=holOnTim)
    "Delay the check after holding time is passed"
    annotation (Placement(transformation(extent={{-280,-180},{-260,-160}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(final t=minComSpe,
      final h=speHys)
    "Check if the compressor speed is lower than the minimum"
    annotation (Placement(transformation(extent={{-280,-140},{-260,-120}})));
  Buildings.Controls.OBC.CDL.Logical.And disHeaPum
    "Check if the heat pump should be disabled"
    annotation (Placement(transformation(extent={{-220,-140},{-200,-120}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel(final delayTime=del)
    "Check if the compressor has been in minimum speed for sufficient time"
    annotation (Placement(transformation(extent={{-180,-140},{-160,-120}})));
  Buildings.Controls.OBC.CDL.Logical.Edge edg
    "Trigger the pulse to disable heat pump"
    annotation (Placement(transformation(extent={{-140,-140},{-120,-120}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold offHeaPum(final
      trueHoldDuration=offTim, final falseHoldDuration=0)
                               "Keep heat pump being off for sufficient time"
    annotation (Placement(transformation(extent={{-100,-140},{-80,-120}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1
    "Not disabled"
    annotation (Placement(transformation(extent={{-40,-140},{-20,-120}})));
  Buildings.Controls.OBC.CDL.Logical.And and2
    "Enabled heat pump "
    annotation (Placement(transformation(extent={{20,-120},{40,-100}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold holHeaPum(final
      trueHoldDuration=holOnTim, final falseHoldDuration=holOffTim)
    "Hold heat pump status for sufficient time"
    annotation (Placement(transformation(extent={{60,-120},{80,-100}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHeaPum
    "Enable heat pump"
    annotation (Placement(transformation(extent={{-100,-90},{-80,-70}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{160,180},{180,200}})));
equation
  connect(uEleRat, higEleRat.u1)
    annotation (Line(points={{-400,330},{-322,330}}, color={255,127,0}));
  connect(higRat.y, higEleRat.u2) annotation (Line(points={{-338,440},{-330,440},
          {-330,322},{-322,322}}, color={255,127,0}));
  connect(higLoa.y, higPlaLoa.u1) annotation (Line(points={{-278,440},{-270,440},
          {-270,330},{-262,330}}, color={255,127,0}));
  connect(uSt, higPlaLoa.u2) annotation (Line(points={{-400,290},{-270,290},{
          -270,322},{-262,322}}, color={255,127,0}));
  connect(win.y, inWin.u1) annotation (Line(points={{-198,440},{-150,440},{-150,
          330},{-142,330}}, color={255,127,0}));
  connect(spr.y, inSpr.u1) annotation (Line(points={{-198,410},{-160,410},{-160,
          300},{-142,300}}, color={255,127,0}));
  connect(sum1.y, inSum.u1) annotation (Line(points={{-198,380},{-170,380},{
          -170,270},{-142,270}}, color={255,127,0}));
  connect(fal.y, inFal.u1) annotation (Line(points={{-198,350},{-180,350},{-180,
          240},{-142,240}}, color={255,127,0}));
  connect(uSea, inWin.u2) annotation (Line(points={{-400,250},{-190,250},{-190,
          322},{-142,322}}, color={255,127,0}));
  connect(uSea, inSpr.u2) annotation (Line(points={{-400,250},{-190,250},{-190,
          292},{-142,292}}, color={255,127,0}));
  connect(uSea, inSum.u2) annotation (Line(points={{-400,250},{-190,250},{-190,
          262},{-142,262}}, color={255,127,0}));
  connect(uSea, inFal.u2) annotation (Line(points={{-400,250},{-190,250},{-190,
          232},{-142,232}}, color={255,127,0}));
  connect(heaSet.y, aveSet.u1) annotation (Line(points={{-338,150},{-330,150},{
          -330,126},{-322,126}}, color={0,0,127}));
  connect(cooSet.y, aveSet.u2) annotation (Line(points={{-338,90},{-330,90},{
          -330,114},{-322,114}}, color={0,0,127}));
  connect(TPlaIn, heaMod.u1) annotation (Line(points={{-400,200},{-320,200},{
          -320,180},{-282,180}}, color={0,0,127}));
  connect(aveSet.y, heaMod.u2) annotation (Line(points={{-298,120},{-290,120},{
          -290,172},{-282,172}}, color={0,0,127}));
  connect(heaMod.y, plaSet.u2) annotation (Line(points={{-258,180},{-250,180},{
          -250,120},{-242,120}}, color={255,0,255}));
  connect(heaSet.y, plaSet.u1) annotation (Line(points={{-338,150},{-280,150},{
          -280,128},{-242,128}}, color={0,0,127}));
  connect(cooSet.y, plaSet.u3) annotation (Line(points={{-338,90},{-280,90},{
          -280,112},{-242,112}}, color={0,0,127}));
  connect(mHeaPum_flow, heaPumFlo.u1) annotation (Line(points={{-400,-30},{-330,
          -30},{-330,-42},{-322,-42}}, color={0,0,127}));
  connect(dumCon.y, heaPumFlo.u3) annotation (Line(points={{-338,-80},{-330,-80},
          {-330,-58},{-322,-58}}, color={0,0,127}));
  connect(mPla_flow, div1.u1) annotation (Line(points={{-400,0},{-290,0},{-290,
          -14},{-282,-14}}, color={0,0,127}));
  connect(heaPumFlo.y, div1.u2) annotation (Line(points={{-298,-50},{-290,-50},
          {-290,-26},{-282,-26}}, color={0,0,127}));
  connect(plaSet.y, sub.u1) annotation (Line(points={{-218,120},{-210,120},{
          -210,96},{-202,96}}, color={0,0,127}));
  connect(THeaPumIn, sub.u2) annotation (Line(points={{-400,60},{-210,60},{-210,
          84},{-202,84}}, color={0,0,127}));
  connect(sub.y, mul.u1) annotation (Line(points={{-178,90},{-170,90},{-170,16},
          {-162,16}}, color={0,0,127}));
  connect(div1.y, mul.u2) annotation (Line(points={{-258,-20},{-170,-20},{-170,
          4},{-162,4}}, color={0,0,127}));
  connect(THeaPumIn, leaWatSet.u1) annotation (Line(points={{-400,60},{-140,60},
          {-140,86},{-122,86}}, color={0,0,127}));
  connect(mul.y, leaWatSet.u2) annotation (Line(points={{-138,10},{-130,10},{
          -130,74},{-122,74}}, color={0,0,127}));
  connect(zer.y, heaPumCon.u_s)
    annotation (Line(points={{42,220},{78,220}}, color={0,0,127}));
  connect(leaWatSet.y, sub1.u1) annotation (Line(points={{-98,80},{-90,80},{-90,
          66},{-82,66}}, color={0,0,127}));
  connect(THeaPumOut, sub1.u2) annotation (Line(points={{-400,30},{-100,30},{
          -100,54},{-82,54}}, color={0,0,127}));
  connect(sub1.y, gai.u)
    annotation (Line(points={{-58,60},{-42,60}}, color={0,0,127}));
  connect(gai.y, swi2.u3) annotation (Line(points={{-18,60},{-12,60},{-12,102},
          {-4,102}}, color={0,0,127}));
  connect(heaMod.y, swi2.u2) annotation (Line(points={{-258,180},{-100,180},{
          -100,110},{-4,110}}, color={255,0,255}));
  connect(sub1.y, swi2.u1) annotation (Line(points={{-58,60},{-50,60},{-50,118},
          {-4,118}}, color={0,0,127}));
  connect(swi2.y, heaPumCon.u_m)
    annotation (Line(points={{20,110},{90,110},{90,208}}, color={0,0,127}));
  connect(higPlaLoa.y, heaPumCon.trigger) annotation (Line(points={{-238,330},{
          -230,330},{-230,200},{84,200},{84,208}}, color={255,0,255}));
  connect(and2.y,pre. u) annotation (Line(points={{42,-110},{50,-110},{50,-190},
          {-340,-190},{-340,-170},{-322,-170}},
                                            color={255,0,255}));
  connect(higPlaLoa.y, enaHeaPum.u1) annotation (Line(points={{-238,330},{-230,
          330},{-230,-80},{-102,-80}}, color={255,0,255}));
  connect(enaHeaPum.y, and2.u1) annotation (Line(points={{-78,-80},{0,-80},{0,
          -110},{18,-110}}, color={255,0,255}));
  connect(lesThr.y, disHeaPum.u1)
    annotation (Line(points={{-258,-130},{-222,-130}}, color={255,0,255}));
  connect(disHeaPum.y, truDel.u)
    annotation (Line(points={{-198,-130},{-182,-130}}, color={255,0,255}));
  connect(truDel.y, edg.u)
    annotation (Line(points={{-158,-130},{-142,-130}}, color={255,0,255}));
  connect(edg.y, offHeaPum.u)
    annotation (Line(points={{-118,-130},{-102,-130}}, color={255,0,255}));
  connect(offHeaPum.y, not1.u)
    annotation (Line(points={{-78,-130},{-42,-130}}, color={255,0,255}));
  connect(not1.y, and2.u2) annotation (Line(points={{-18,-130},{0,-130},{0,-118},
          {18,-118}}, color={255,0,255}));
  connect(pre.y, delChe.u)
    annotation (Line(points={{-298,-170},{-282,-170}}, color={255,0,255}));
  connect(delChe.y, disHeaPum.u2) annotation (Line(points={{-258,-170},{-240,
          -170},{-240,-138},{-222,-138}}, color={255,0,255}));
  connect(and2.y, holHeaPum.u)
    annotation (Line(points={{42,-110},{58,-110}}, color={255,0,255}));
  connect(holHeaPum.y, swi1.u2) annotation (Line(points={{82,-110},{140,-110},{
          140,190},{158,190}}, color={255,0,255}));
  connect(heaPumCon.y, swi1.u1) annotation (Line(points={{102,220},{140,220},{
          140,198},{158,198}}, color={0,0,127}));
  connect(zer.y, swi1.u3) annotation (Line(points={{42,220},{58,220},{58,182},{
          158,182}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-380,
            -460},{380,460}})), Diagram(coordinateSystem(preserveAspectRatio=
            false, extent={{-380,-460},{380,460}})));
end HeatPump_2;
