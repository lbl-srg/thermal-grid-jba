within ThermalGridJBA.Networks.Controls;
model DryCoolerHex
  "Sequence for control dry cooler and heat exchanger"

  parameter Real TAppSet(
    final quantity="TemperatureDifference",
    final unit="K")=2
    "Dry cooler approch setpoint";
  parameter Real TApp(
    final quantity="TemperatureDifference",
    final unit="K")=4
    "Approach temperature for checking if the dry cooler should be enabled";
  parameter Real minFanSpe(
    final min=0,
    final max=1,
    final unit="1")=0.1
    "Minimum dry cooler fan speed";
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController fanConTyp=
    Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Type of dry cooler fan controller";
  parameter Real kFan=1 "Gain of controller"
    annotation (Dialog(group="Fan controller"));
  parameter Real TiFan=0.5 "Time constant of integrator block"
    annotation (Dialog(group="Fan controller",
      enable=fanConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
          or fanConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Real TdFan=0.1 "Time constant of derivative block"
    annotation (Dialog(group="Fan controller",
      enable=fanConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PD
          or fanConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Real THys=0.1 "Hysteresis for comparing temperature"
    annotation (Dialog(tab="Advanced"));

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{-340,250},{-300,290}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "District loop load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-340,200},{-300,240}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uGen
    "Season indicator. 1-winter; 2-shoulder; 3-summer"
    annotation (Placement(transformation(extent={{-340,150},{-300,190}}),
        iconTransformation(extent={{-140,30},{-100,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TGenIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water from the district loop"
    annotation (Placement(transformation(extent={{-340,110},{-300,150}}),
        iconTransformation(extent={{-140,-10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-340,70},{-300,110}}),
        iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPum
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{-340,-80},{-300,-40}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryCooOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Dry cooler outlet glycol temperature"
    annotation (Placement(transformation(extent={{-340,-240},{-300,-200}}),
        iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHexByp(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger bypass valve position setpoint"
    annotation (Placement(transformation(extent={{300,280},{340,320}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHex(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger valve position setpoint"
    annotation (Placement(transformation(extent={{300,240},{340,280}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumHex(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger pump speed setpoint"
    annotation (Placement(transformation(extent={{300,200},{340,240}}),
        iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumDryCoo(
    final min=0,
    final max=1,
    final unit="1") "Speed setpoint of the pump for the dry cooler"
    annotation (Placement(transformation(extent={{300,100},{340,140}}),
      iconTransformation(extent={{100,-60},{140,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDryCoo(
    final min=0,
    final max=1,
    final unit="1")
    "Speed setpoint of the dry cooler fan"
    annotation (Placement(transformation(extent={{300,-250},{340,-210}}),
        iconTransformation(extent={{100,-100},{140,-60}})));

  Buildings.Controls.OBC.CDL.Integers.Equal higRatMod
    "Check if it is in high electricity rate mode"
    annotation (Placement(transformation(extent={{-240,280},{-220,300}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooFan
    "Dry cooler fan speed setpoint"
    annotation (Placement(transformation(extent={{260,-240},{280,-220}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(
    final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-280,280},{-260,300}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant medLoa(
    final k=2)
    "Medium district load"
    annotation (Placement(transformation(extent={{-280,230},{-260,250}})));
  Buildings.Controls.OBC.CDL.Integers.Equal medLoaMod
    "Check if the district load is medium"
    annotation (Placement(transformation(extent={{-220,230},{-200,250}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(
    final k=1)
    "Winter"
    annotation (Placement(transformation(extent={{-280,180},{-260,200}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin
    "Check if it is in winter"
    annotation (Placement(transformation(extent={{-220,180},{-200,200}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(
    final p=-TApp)
    annotation (Placement(transformation(extent={{-280,80},{-260,100}})));
  Buildings.Controls.OBC.CDL.Reals.Less les(
    final h=THys)
    "Compare inputs"
    annotation (Placement(transformation(extent={{-180,120},{-160,140}})));
  Buildings.Controls.OBC.CDL.Logical.And winPre
    "In winter perferred condition"
    annotation (Placement(transformation(extent={{-120,180},{-100,200}})));
  Buildings.Controls.OBC.CDL.Logical.And higMed
    "High electricity rate and medium district load"
    annotation (Placement(transformation(extent={{-120,280},{-100,300}})));
  Buildings.Controls.OBC.CDL.Logical.And higMedWin
    "High rate, medium district load, and in winter preferred condition"
    annotation (Placement(transformation(extent={{-60,180},{-40,200}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(
    final k=1) "One"
    annotation (Placement(transformation(extent={{200,170},{220,190}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum
    "Check if it is in summer"
    annotation (Placement(transformation(extent={{-180,0},{-160,20}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum(
    final k=3)
    "Summer"
    annotation (Placement(transformation(extent={{-280,0},{-260,20}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(
    final p=TApp)
    annotation (Placement(transformation(extent={{-280,40},{-260,60}})));
  Buildings.Controls.OBC.CDL.Reals.Greater gre(
    final h=THys)
    "Compare inputs"
    annotation (Placement(transformation(extent={{-180,60},{-160,80}})));
  Buildings.Controls.OBC.CDL.Logical.And sumPre
    "In summer preferred condition"
    annotation (Placement(transformation(extent={{-120,60},{-100,80}})));
  Buildings.Controls.OBC.CDL.Logical.And higMedSum
    "High rate, medium district load, and in summer preferred condition"
    annotation (Placement(transformation(extent={{-60,60},{-40,80}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higLoaMod
    "Check if the district load is high"
    annotation (Placement(transformation(extent={{-220,-40},{-200,-20}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(
    final k=3)
    "HIgh district load"
    annotation (Placement(transformation(extent={{-280,-40},{-260,-20}})));
  Buildings.Controls.OBC.CDL.Logical.And higHig
    "High electricity rate and high district load"
    annotation (Placement(transformation(extent={{-120,-40},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Logical.And higHigWin
    "High rate, high district load, and in winter preferred condition"
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
  Buildings.Controls.OBC.CDL.Logical.And higHigSum
    "High rate, high district load, and in summer preferred condition"
    annotation (Placement(transformation(extent={{-60,-100},{-40,-80}})));
  Buildings.Controls.OBC.CDL.Logical.Or higHigWinHeaPum
    "High rate, high district load, in winter preferred condition, or heat pump is enabled"
    annotation (Placement(transformation(extent={{0,-40},{20,-20}})));
  Buildings.Controls.OBC.CDL.Logical.Or higHigSumHeaPum
    "High rate, high district load, in summer preferred condition, or heat pump is enabled"
    annotation (Placement(transformation(extent={{0,-100},{20,-80}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant norRat(
    final k=0)
    "Normal electricity rate"
    annotation (Placement(transformation(extent={{-280,-150},{-260,-130}})));
  Buildings.Controls.OBC.CDL.Integers.Equal norRatMod
    "Check if it is in normal electricity rate mode"
    annotation (Placement(transformation(extent={{-240,-150},{-220,-130}})));
  Buildings.Controls.OBC.CDL.Logical.Or norWinHeaPum
    "Normal rate in winter preferred condition, or heat pump is enabled"
    annotation (Placement(transformation(extent={{0,-150},{20,-130}})));
  Buildings.Controls.OBC.CDL.Logical.Or norSumHeaPum
    "Normal rate in summer preferred condition, or heat pump is enabled"
    annotation (Placement(transformation(extent={{0,-190},{20,-170}})));
  Buildings.Controls.OBC.CDL.Logical.Or winOpe
    "Enable the dry cooler in winter"
    annotation (Placement(transformation(extent={{40,-40},{60,-20}})));
  Buildings.Controls.OBC.CDL.Logical.Or winOpe1
    "Enable the dry cooler in winter"
    annotation (Placement(transformation(extent={{100,110},{120,130}})));
  Buildings.Controls.OBC.CDL.Logical.Or sumOpe
    "Enable the dry cooler in summer"
    annotation (Placement(transformation(extent={{60,-100},{80,-80}})));
  Buildings.Controls.OBC.CDL.Logical.Or sumOpe1
    "Enable the dry cooler in summer"
    annotation (Placement(transformation(extent={{100,60},{120,80}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Check temperature difference"
    annotation (Placement(transformation(extent={{-240,-250},{-220,-230}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(
    final k=-1)
    "Reverse the subtract"
    annotation (Placement(transformation(extent={{-180,-290},{-160,-270}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(
    final k=TAppSet)
    "Dry cooler approach temperature setpoint"
    annotation (Placement(transformation(extent={{140,-220},{160,-200}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset fanCon(
    final controllerType=fanConTyp,
    final k=kFan,
    final Ti=TiFan,
    final Td=TdFan,
    final reverseActing=false,
    final y_reset=minFanSpe)
    "Dry cooler fan speed controller"
    annotation (Placement(transformation(extent={{200,-220},{220,-200}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{140,-270},{160,-250}})));
  Buildings.Controls.OBC.CDL.Logical.Or ope
    "Enable the dry cooler"
    annotation (Placement(transformation(extent={{140,110},{160,130}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo(
    final k=0)
    "Disable fan"
    annotation (Placement(transformation(extent={{200,-290},{220,-270}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooPum
    "Dry cooler pump speed setpoint"
    annotation (Placement(transformation(extent={{260,110},{280,130}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo1(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{200,80},{220,100}})));
  Buildings.Controls.OBC.CDL.Logical.And norWin
    "Normal rate, in winter preferred condition"
    annotation (Placement(transformation(extent={{-60,-150},{-40,-130}})));
  Buildings.Controls.OBC.CDL.Logical.And norSum
    "Normal rate, in summer preferred condition"
    annotation (Placement(transformation(extent={{-60,-190},{-40,-170}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex "Enable heat exchanger"
    annotation (Placement(transformation(extent={{0,10},{20,30}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex1 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{0,40},{20,60}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex3 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{0,210},{20,230}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex2 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex4 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{100,210},{120,230}})));
  Buildings.Controls.OBC.CDL.Reals.Switch hexPumVal
    "Heat exchanger pump and valve position setpoint"
    annotation (Placement(transformation(extent={{260,210},{280,230}})));
  Buildings.Controls.OBC.CDL.Reals.Switch hexPumByaVal
    "Heat exchanger bypass valve position setpoint"
    annotation (Placement(transformation(extent={{260,290},{280,310}})));

equation
  connect(uEleRat, higRatMod.u2) annotation (Line(points={{-320,270},{-250,270},
          {-250,282},{-242,282}}, color={255,127,0}));
  connect(higRat.y, higRatMod.u1)
    annotation (Line(points={{-258,290},{-242,290}}, color={255,127,0}));
  connect(medLoa.y, medLoaMod.u1)
    annotation (Line(points={{-258,240},{-222,240}}, color={255,127,0}));
  connect(uSt, medLoaMod.u2) annotation (Line(points={{-320,220},{-240,220},{-240,
          232},{-222,232}}, color={255,127,0}));
  connect(win.y, inWin.u1)
    annotation (Line(points={{-258,190},{-222,190}}, color={255,127,0}));
  connect(uGen, inWin.u2) annotation (Line(points={{-320,170},{-230,170},{-230,182},
          {-222,182}}, color={255,127,0}));
  connect(TDryBul, addPar.u)
    annotation (Line(points={{-320,90},{-282,90}}, color={0,0,127}));
  connect(TGenIn, les.u1)
    annotation (Line(points={{-320,130},{-182,130}}, color={0,0,127}));
  connect(addPar.y, les.u2) annotation (Line(points={{-258,90},{-220,90},{-220,122},
          {-182,122}},    color={0,0,127}));
  connect(inWin.y, winPre.u1)
    annotation (Line(points={{-198,190},{-122,190}}, color={255,0,255}));
  connect(les.y, winPre.u2) annotation (Line(points={{-158,130},{-150,130},{-150,
          182},{-122,182}}, color={255,0,255}));
  connect(higRatMod.y, higMed.u1)
    annotation (Line(points={{-218,290},{-122,290}}, color={255,0,255}));
  connect(medLoaMod.y, higMed.u2) annotation (Line(points={{-198,240},{-190,240},
          {-190,282},{-122,282}}, color={255,0,255}));
  connect(winPre.y, higMedWin.u1)
    annotation (Line(points={{-98,190},{-62,190}},  color={255,0,255}));
  connect(higMed.y, higMedWin.u2) annotation (Line(points={{-98,290},{-90,290},{
          -90,182},{-62,182}}, color={255,0,255}));
  connect(sum.y, inSum.u1)
    annotation (Line(points={{-258,10},{-182,10}}, color={255,127,0}));
  connect(uGen, inSum.u2) annotation (Line(points={{-320,170},{-230,170},{-230,2},
          {-182,2}}, color={255,127,0}));
  connect(TDryBul, addPar1.u) annotation (Line(points={{-320,90},{-290,90},{-290,
          50},{-282,50}}, color={0,0,127}));
  connect(TGenIn, gre.u1) annotation (Line(points={{-320,130},{-200,130},{-200,70},
          {-182,70}}, color={0,0,127}));
  connect(addPar1.y, gre.u2) annotation (Line(points={{-258,50},{-220,50},{-220,
          62},{-182,62}}, color={0,0,127}));
  connect(gre.y, sumPre.u1)
    annotation (Line(points={{-158,70},{-122,70}}, color={255,0,255}));
  connect(inSum.y, sumPre.u2) annotation (Line(points={{-158,10},{-140,10},{-140,
          62},{-122,62}}, color={255,0,255}));
  connect(sumPre.y, higMedSum.u1)
    annotation (Line(points={{-98,70},{-62,70}},  color={255,0,255}));
  connect(higMed.y, higMedSum.u2) annotation (Line(points={{-98,290},{-90,290},{
          -90,62},{-62,62}}, color={255,0,255}));
  connect(higLoa.y, higLoaMod.u1)
    annotation (Line(points={{-258,-30},{-222,-30}}, color={255,127,0}));
  connect(uSt, higLoaMod.u2) annotation (Line(points={{-320,220},{-240,220},{-240,
          -38},{-222,-38}}, color={255,127,0}));
  connect(higLoaMod.y, higHig.u1)
    annotation (Line(points={{-198,-30},{-122,-30}}, color={255,0,255}));
  connect(higRatMod.y, higHig.u2) annotation (Line(points={{-218,290},{-130,290},
          {-130,-38},{-122,-38}}, color={255,0,255}));
  connect(higHig.y, higHigWin.u1)
    annotation (Line(points={{-98,-30},{-62,-30}}, color={255,0,255}));
  connect(higHigWin.y, higHigWinHeaPum.u1)
    annotation (Line(points={{-38,-30},{-2,-30}},  color={255,0,255}));
  connect(higHigSum.y, higHigSumHeaPum.u1)
    annotation (Line(points={{-38,-90},{-2,-90}},  color={255,0,255}));
  connect(u1HeaPum, higHigWinHeaPum.u2) annotation (Line(points={{-320,-60},{-30,
          -60},{-30,-38},{-2,-38}},  color={255,0,255}));
  connect(u1HeaPum, higHigSumHeaPum.u2) annotation (Line(points={{-320,-60},{-30,
          -60},{-30,-98},{-2,-98}},  color={255,0,255}));
  connect(norRat.y, norRatMod.u1)
    annotation (Line(points={{-258,-140},{-242,-140}}, color={255,127,0}));
  connect(uEleRat, norRatMod.u2) annotation (Line(points={{-320,270},{-250,270},
          {-250,-148},{-242,-148}}, color={255,127,0}));
  connect(higHigWinHeaPum.y, winOpe.u1)
    annotation (Line(points={{22,-30},{38,-30}},  color={255,0,255}));
  connect(norWinHeaPum.y, winOpe.u2) annotation (Line(points={{22,-140},{30,-140},
          {30,-38},{38,-38}}, color={255,0,255}));
  connect(higMedWin.y, winOpe1.u1)
    annotation (Line(points={{-38,190},{-30,190},{-30,120},{98,120}}, color={255,0,255}));
  connect(winOpe.y, winOpe1.u2) annotation (Line(points={{62,-30},{70,-30},{70,112},
          {98,112}}, color={255,0,255}));
  connect(higHigSumHeaPum.y, sumOpe.u1)
    annotation (Line(points={{22,-90},{58,-90}},color={255,0,255}));
  connect(norSumHeaPum.y, sumOpe.u2) annotation (Line(points={{22,-180},{40,-180},
          {40,-98},{58,-98}}, color={255,0,255}));
  connect(higMedSum.y, sumOpe1.u1)
    annotation (Line(points={{-38,70},{98,70}}, color={255,0,255}));
  connect(sumOpe.y, sumOpe1.u2) annotation (Line(points={{82,-90},{90,-90},{90,62},
          {98,62}}, color={255,0,255}));
  connect(TDryCooOut, sub.u1) annotation (Line(points={{-320,-220},{-260,-220},{
          -260,-234},{-242,-234}}, color={0,0,127}));
  connect(TDryBul, sub.u2) annotation (Line(points={{-320,90},{-290,90},{-290,-246},
          {-242,-246}}, color={0,0,127}));
  connect(sub.y, gai.u) annotation (Line(points={{-218,-240},{-200,-240},{-200,-280},
          {-182,-280}}, color={0,0,127}));
  connect(sumOpe1.y, swi1.u2) annotation (Line(points={{122,70},{130,70},{130,-260},
          {138,-260}},color={255,0,255}));
  connect(sub.y, swi1.u1) annotation (Line(points={{-218,-240},{120,-240},{120,-252},
          {138,-252}}, color={0,0,127}));
  connect(gai.y, swi1.u3) annotation (Line(points={{-158,-280},{120,-280},{120,-268},
          {138,-268}}, color={0,0,127}));
  connect(con1.y, fanCon.u_s)
    annotation (Line(points={{162,-210},{198,-210}}, color={0,0,127}));
  connect(swi1.y, fanCon.u_m) annotation (Line(points={{162,-260},{210,-260},{210,
          -222}}, color={0,0,127}));
  connect(winOpe1.y, ope.u1)
    annotation (Line(points={{122,120},{138,120}},color={255,0,255}));
  connect(sumOpe1.y, ope.u2) annotation (Line(points={{122,70},{130,70},{130,112},
          {138,112}}, color={255,0,255}));
  connect(fanCon.y, dryCooFan.u1) annotation (Line(points={{222,-210},{250,-210},
          {250,-222},{258,-222}}, color={0,0,127}));
  connect(ope.y, dryCooFan.u2) annotation (Line(points={{162,120},{240,120},{240,
          -230},{258,-230}}, color={255,0,255}));
  connect(zeo.y, dryCooFan.u3) annotation (Line(points={{222,-280},{240,-280},{240,
          -238},{258,-238}}, color={0,0,127}));
  connect(ope.y, fanCon.trigger) annotation (Line(points={{162,120},{170,120},{170,
          -240},{204,-240},{204,-222}}, color={255,0,255}));
  connect(con.y, dryCooPum.u1) annotation (Line(points={{222,180},{232,180},{232,
          128},{258,128}}, color={0,0,127}));
  connect(ope.y, dryCooPum.u2)
    annotation (Line(points={{162,120},{258,120}}, color={255,0,255}));
  connect(zeo1.y, dryCooPum.u3) annotation (Line(points={{222,90},{250,90},{250,
          112},{258,112}}, color={0,0,127}));
  connect(dryCooPum.y, yPumDryCoo)
    annotation (Line(points={{282,120},{320,120}}, color={0,0,127}));
  connect(dryCooFan.y, yDryCoo)
    annotation (Line(points={{282,-230},{320,-230}}, color={0,0,127}));
  connect(norWin.y, norWinHeaPum.u1)
    annotation (Line(points={{-38,-140},{-2,-140}},  color={255,0,255}));
  connect(norSum.y, norSumHeaPum.u1)
    annotation (Line(points={{-38,-180},{-2,-180}},  color={255,0,255}));
  connect(u1HeaPum, norWinHeaPum.u2) annotation (Line(points={{-320,-60},{-30,-60},
          {-30,-148},{-2,-148}},  color={255,0,255}));
  connect(u1HeaPum, norSumHeaPum.u2) annotation (Line(points={{-320,-60},{-30,-60},
          {-30,-188},{-2,-188}},  color={255,0,255}));
  connect(norRatMod.y, norWin.u1)
    annotation (Line(points={{-218,-140},{-62,-140}}, color={255,0,255}));
  connect(norRatMod.y, norSum.u1) annotation (Line(points={{-218,-140},{-180,-140},
          {-180,-180},{-62,-180}}, color={255,0,255}));
  connect(winPre.y, norWin.u2) annotation (Line(points={{-98,190},{-80,190},{-80,
          -148},{-62,-148}}, color={255,0,255}));
  connect(sumPre.y, norSum.u2) annotation (Line(points={{-98,70},{-70,70},{-70,-188},
          {-62,-188}}, color={255,0,255}));
  connect(higHig.y, higHigSum.u1) annotation (Line(points={{-98,-30},{-90,-30},{
          -90,-90},{-62,-90}}, color={255,0,255}));
  connect(winPre.y, higHigWin.u2) annotation (Line(points={{-98,190},{-80,190},{
          -80,-38},{-62,-38}}, color={255,0,255}));
  connect(sumPre.y, higHigSum.u2) annotation (Line(points={{-98,70},{-70,70},{-70,
          -98},{-62,-98}}, color={255,0,255}));
  connect(norSum.y, enaHex.u2) annotation (Line(points={{-38,-180},{-10,-180},{-10,
          12},{-2,12}}, color={255,0,255}));
  connect(norWin.y, enaHex.u1) annotation (Line(points={{-38,-140},{-16,-140},{-16,
          20},{-2,20}}, color={255,0,255}));
  connect(higHigSum.y, enaHex1.u2) annotation (Line(points={{-38,-90},{-22,-90},
          {-22,42},{-2,42}}, color={255,0,255}));
  connect(higHigWin.y, enaHex1.u1) annotation (Line(points={{-38,-30},{-30,-30},
          {-30,50},{-2,50}}, color={255,0,255}));
  connect(higMedSum.y, enaHex3.u2) annotation (Line(points={{-38,70},{-20,70},{-20,
          212},{-2,212}}, color={255,0,255}));
  connect(higMedWin.y, enaHex3.u1) annotation (Line(points={{-38,190},{-30,190},
          {-30,220},{-2,220}}, color={255,0,255}));
  connect(enaHex1.y, enaHex2.u1)
    annotation (Line(points={{22,50},{38,50}}, color={255,0,255}));
  connect(enaHex.y, enaHex2.u2) annotation (Line(points={{22,20},{30,20},{30,42},
          {38,42}}, color={255,0,255}));
  connect(enaHex3.y, enaHex4.u1)
    annotation (Line(points={{22,220},{98,220}}, color={255,0,255}));
  connect(enaHex2.y, enaHex4.u2) annotation (Line(points={{62,50},{80,50},{80,212},
          {98,212}}, color={255,0,255}));
  connect(enaHex4.y, hexPumVal.u2)
    annotation (Line(points={{122,220},{258,220}}, color={255,0,255}));
  connect(con.y, hexPumVal.u1) annotation (Line(points={{222,180},{232,180},{232,
          228},{258,228}}, color={0,0,127}));
  connect(zeo1.y, hexPumVal.u3) annotation (Line(points={{222,90},{250,90},{250,
          212},{258,212}}, color={0,0,127}));
  connect(enaHex4.y, hexPumByaVal.u2) annotation (Line(points={{122,220},{160,220},
          {160,300},{258,300}}, color={255,0,255}));
  connect(zeo1.y, hexPumByaVal.u1) annotation (Line(points={{222,90},{250,90},{250,
          308},{258,308}}, color={0,0,127}));
  connect(con.y, hexPumByaVal.u3) annotation (Line(points={{222,180},{232,180},{
          232,292},{258,292}}, color={0,0,127}));
  connect(hexPumVal.y, yPumHex)
    annotation (Line(points={{282,220},{320,220}}, color={0,0,127}));
  connect(hexPumVal.y, yValHex) annotation (Line(points={{282,220},{290,220},{290,
          260},{320,260}}, color={0,0,127}));
  connect(hexPumByaVal.y, yValHexByp)
    annotation (Line(points={{282,300},{320,300}}, color={0,0,127}));
annotation (defaultComponentName="dryCooHexCon",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255}),
        Text(
          extent={{-100,100},{-52,84}},
          textColor={255,127,0},
          textString="uEleRat"),
        Text(
          extent={{-100,80},{-74,64}},
          textColor={255,127,0},
          textString="uSt"),
        Text(
          extent={{-100,60},{-62,44}},
          textColor={255,127,0},
          textString="uGen"),
        Text(
          extent={{-98,18},{-60,2}},
          textColor={0,0,127},
          textString="TGenIn"),
        Text(
          extent={{-98,-12},{-60,-28}},
          textColor={0,0,127},
          textString="TDryBul"),
        Text(
          extent={{-98,-82},{-40,-98}},
          textColor={0,0,127},
          textString="TDryCooOut"),
        Text(
          extent={{-96,-50},{-46,-68}},
          textColor={255,0,255},
          textString="u1HeaPum"),
        Text(
          extent={{58,-68},{96,-88}},
          textColor={0,0,127},
          textString="yDryCoo"),
        Text(
          extent={{38,-30},{100,-48}},
          textColor={0,0,127},
          textString="yPumDryCoo"),
        Text(
          extent={{40,100},{98,82}},
          textColor={0,0,127},
          textString="yValHexByp"),
        Text(
          extent={{50,78},{98,62}},
          textColor={0,0,127},
          textString="yValHex"),
        Text(
          extent={{48,50},{98,32}},
          textColor={0,0,127},
          textString="yPumHex")}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-300,-320},{300,320}})),
Documentation(info="
<html>
<h4>Dry cooler</h4>
<p>
The dry cooler shall be enabled as in the table below.
When the dry cooler is enabled, the fan tracks a 2 Kelvin approach temperature
(<code>TAppSet</code>) between
outdoor dry bulb temperature (<code>TDryBul</code>) and leaving glycol temperature
(<code>TDryCooOut</code>).
The pump operates at full speed when commanded on.
</p>

<table summary=\"summary\" border=\"1\">
<tr>
<th>Electricity rate (<code>uEleRat</code>)</th>
<th>District load (<code>uSt</code>)</th>
<th>Season (<code>uGen</code>)</th>
<th> Preferred condition </th>
<th>Pump speed(<code>yPumDryCoo</code>)</th>
<th>Fan speed (<code>yDryCoo</code>)</th>
</tr>
<tr>
<td>1 (high)</td>
<td>2 (medium)</td>
<td>1 (winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryBul - TDryCooOut = TAppSet</code></td>
</tr>
<tr>
<td>1 (high)</td>
<td>2 (medium)</td>
<td>3 (summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut - TDryBul = TAppSet</code></td>
</tr>
<tr>
<td>1 (high)</td>
<td>3 (high)</td>
<td>1 (winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code>, or, <code>uHeaPum=true</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryBul - TDryCooOut = TAppSet</code></td>
</tr>
<tr>
<td>1 (high)</td>
<td>3 (high)</td>
<td>3 (summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code>, or, <code>uHeaPum=true</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut - TDryBul = TAppSet</code></td>
</tr>
<tr>
<td>0 (normal)</td>
<td>x</td>
<td>1 (winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code>, or, <code>uHeaPum=true</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryBul - TDryCooOut = TAppSet</code></td>
</tr>
<tr>
<td>0 (normal)</td>
<td>x</td>
<td>3 (summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code>, or, <code>uHeaPum=true</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut - TDryBul = TAppSet</code></td>
</tr>
</table>


<h4>Heat exchanger</h4>
<p>
The heat exchanger shall be enabled as in the table below.
When the heat exchanger is enabled, the pump in the glycol side of the heat exchanger
shall be at full speed (<code>yPumHex=1</code>). The water side valve on the heat
exchanger branch shall be fully open (<code>yValHex=1</code>) and the bypass valve
should be closed (<code>yValHexByp=0</code>).
</p>
<table summary=\"summary\" border=\"1\">
<tr>
<th>Electricity rate (<code>uEleRat</code>)</th>
<th>District load (<code>uSt</code>)</th>
<th>Season (<code>uGen</code>)</th>
<th> Preferred condition </th>
<th>Pump speed(<code>yPumHex</code>)</th>
<th>Branch valve position (<code>yValHex</code>)</th>
<th>Bypass valve position (<code>yValHexByp</code>)</th>
</tr>
<tr>
<td>1 (high)</td>
<td>2 (medium)</td>
<td>1 (winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
<tr>
<td>1 (high)</td>
<td>2 (medium)</td>
<td>3 (summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
<tr>
<td>1 (high)</td>
<td>3 (high)</td>
<td>1 (winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
<tr>
<td>1 (high)</td>
<td>3 (high)</td>
<td>3 (summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
<tr>
<td>0 (normal)</td>
<td>x</td>
<td>1 (winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
<tr>
<td>0 (normal)</td>
<td>x</td>
<td>3 (summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
</table>
</html>", revisions="<html>
<ul>
<li>
January 31, 2025, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"));
end DryCoolerHex;
