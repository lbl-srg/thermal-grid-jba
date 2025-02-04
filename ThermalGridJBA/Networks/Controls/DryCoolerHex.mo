within ThermalGridJBA.Networks.Controls;
model DryCoolerHex
  "Sequence for control dry cooler and heat exchanger"

  parameter Modelica.Units.SI.MassFlowRate mHexGly_flow_nominal
    "Nominal glycol mass flow rate for heat exchanger";
  parameter Modelica.Units.SI.MassFlowRate mDryCoo_flow_nominal
    "Nominal glycol mass flow rate for dry cooler";
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
    "Type of dry cooler fan controller"
    annotation (Dialog(group="Fan controller"));
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
    annotation (Placement(transformation(extent={{-360,250},{-320,290}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "District loop load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-360,200},{-320,240}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uGen
    "Season indicator. 1-winter; 2-shoulder; 3-summer"
    annotation (Placement(transformation(extent={{-360,150},{-320,190}}),
        iconTransformation(extent={{-140,30},{-100,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TGenIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Temperature of the water from the district loop"
    annotation (Placement(transformation(extent={{-360,110},{-320,150}}),
        iconTransformation(extent={{-140,-10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-360,70},{-320,110}}),
        iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPum
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{-360,-80},{-320,-40}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryCooOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Dry cooler outlet glycol temperature"
    annotation (Placement(transformation(extent={{-360,-240},{-320,-200}}),
        iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHexByp(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger bypass valve position setpoint"
    annotation (Placement(transformation(extent={{320,280},{360,320}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHex(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger valve position setpoint"
    annotation (Placement(transformation(extent={{320,240},{360,280}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumHex(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat exchanger pump speed setpoint"
    annotation (Placement(transformation(extent={{320,200},{360,240}}),
        iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumDryCoo(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint of the pump for the dry cooler"
    annotation (Placement(transformation(extent={{320,100},{360,140}}),
      iconTransformation(extent={{100,-60},{140,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDryCoo(
    final min=0,
    final max=1,
    final unit="1")
    "Speed setpoint of the dry cooler fan"
    annotation (Placement(transformation(extent={{320,-250},{360,-210}}),
        iconTransformation(extent={{100,-100},{140,-60}})));

  Buildings.Controls.OBC.CDL.Integers.Equal higRatMod
    "Check if it is in high electricity rate mode"
    annotation (Placement(transformation(extent={{-260,280},{-240,300}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooFan
    "Dry cooler fan speed setpoint"
    annotation (Placement(transformation(extent={{240,-240},{260,-220}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(
    final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-300,280},{-280,300}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant medLoa(
    final k=2)
    "Medium district load"
    annotation (Placement(transformation(extent={{-300,230},{-280,250}})));
  Buildings.Controls.OBC.CDL.Integers.Equal medLoaMod
    "Check if the district load is medium"
    annotation (Placement(transformation(extent={{-240,230},{-220,250}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(
    final k=1)
    "Winter"
    annotation (Placement(transformation(extent={{-300,180},{-280,200}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin
    "Check if it is in winter"
    annotation (Placement(transformation(extent={{-240,180},{-220,200}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(
    final p=-TApp)
    annotation (Placement(transformation(extent={{-300,80},{-280,100}})));
  Buildings.Controls.OBC.CDL.Reals.Less les(
    final h=THys)
    "Compare inputs"
    annotation (Placement(transformation(extent={{-200,120},{-180,140}})));
  Buildings.Controls.OBC.CDL.Logical.And winPre
    "In winter perferred condition"
    annotation (Placement(transformation(extent={{-140,180},{-120,200}})));
  Buildings.Controls.OBC.CDL.Logical.And higMed
    "High electricity rate and medium district load"
    annotation (Placement(transformation(extent={{-140,280},{-120,300}})));
  Buildings.Controls.OBC.CDL.Logical.And higMedWin
    "High rate, medium district load, and in winter preferred condition"
    annotation (Placement(transformation(extent={{-80,180},{-60,200}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(
    final k=1) "One"
    annotation (Placement(transformation(extent={{180,170},{200,190}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum
    "Check if it is in summer"
    annotation (Placement(transformation(extent={{-200,0},{-180,20}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum(
    final k=3)
    "Summer"
    annotation (Placement(transformation(extent={{-300,0},{-280,20}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(
    final p=TApp)
    annotation (Placement(transformation(extent={{-300,40},{-280,60}})));
  Buildings.Controls.OBC.CDL.Reals.Greater gre(
    final h=THys)
    "Compare inputs"
    annotation (Placement(transformation(extent={{-200,60},{-180,80}})));
  Buildings.Controls.OBC.CDL.Logical.And sumPre
    "In summer preferred condition"
    annotation (Placement(transformation(extent={{-140,60},{-120,80}})));
  Buildings.Controls.OBC.CDL.Logical.And higMedSum
    "High rate, medium district load, and in summer preferred condition"
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higLoaMod
    "Check if the district load is high"
    annotation (Placement(transformation(extent={{-240,-40},{-220,-20}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(
    final k=3)
    "HIgh district load"
    annotation (Placement(transformation(extent={{-300,-40},{-280,-20}})));
  Buildings.Controls.OBC.CDL.Logical.And higHig
    "High electricity rate and high district load"
    annotation (Placement(transformation(extent={{-140,-40},{-120,-20}})));
  Buildings.Controls.OBC.CDL.Logical.And higHigWin
    "High rate, high district load, and in winter preferred condition"
    annotation (Placement(transformation(extent={{-80,-40},{-60,-20}})));
  Buildings.Controls.OBC.CDL.Logical.And higHigSum
    "High rate, high district load, and in summer preferred condition"
    annotation (Placement(transformation(extent={{-80,-100},{-60,-80}})));
  Buildings.Controls.OBC.CDL.Logical.Or higHigWinHeaPum
    "High rate, high district load, in winter preferred condition, or heat pump is enabled"
    annotation (Placement(transformation(extent={{-20,-40},{0,-20}})));
  Buildings.Controls.OBC.CDL.Logical.Or higHigSumHeaPum
    "High rate, high district load, in summer preferred condition, or heat pump is enabled"
    annotation (Placement(transformation(extent={{-20,-100},{0,-80}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant norRat(
    final k=0)
    "Normal electricity rate"
    annotation (Placement(transformation(extent={{-300,-150},{-280,-130}})));
  Buildings.Controls.OBC.CDL.Integers.Equal norRatMod
    "Check if it is in normal electricity rate mode"
    annotation (Placement(transformation(extent={{-260,-150},{-240,-130}})));
  Buildings.Controls.OBC.CDL.Logical.Or norWinHeaPum
    "Normal rate in winter preferred condition, or heat pump is enabled"
    annotation (Placement(transformation(extent={{-20,-150},{0,-130}})));
  Buildings.Controls.OBC.CDL.Logical.Or norSumHeaPum
    "Normal rate in summer preferred condition, or heat pump is enabled"
    annotation (Placement(transformation(extent={{-20,-190},{0,-170}})));
  Buildings.Controls.OBC.CDL.Logical.Or winOpe
    "Enable the dry cooler in winter"
    annotation (Placement(transformation(extent={{20,-40},{40,-20}})));
  Buildings.Controls.OBC.CDL.Logical.Or winOpe1
    "Enable the dry cooler in winter"
    annotation (Placement(transformation(extent={{80,110},{100,130}})));
  Buildings.Controls.OBC.CDL.Logical.Or sumOpe
    "Enable the dry cooler in summer"
    annotation (Placement(transformation(extent={{40,-100},{60,-80}})));
  Buildings.Controls.OBC.CDL.Logical.Or sumOpe1
    "Enable the dry cooler in summer"
    annotation (Placement(transformation(extent={{80,60},{100,80}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Check temperature difference"
    annotation (Placement(transformation(extent={{-260,-250},{-240,-230}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(
    final k=-1)
    "Reverse the subtract"
    annotation (Placement(transformation(extent={{-200,-290},{-180,-270}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(
    final k=TAppSet)
    "Dry cooler approach temperature setpoint"
    annotation (Placement(transformation(extent={{120,-220},{140,-200}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset fanCon(
    final controllerType=fanConTyp,
    final k=kFan,
    final Ti=TiFan,
    final Td=TdFan,
    final reverseActing=false,
    final y_reset=minFanSpe)
    "Dry cooler fan speed controller"
    annotation (Placement(transformation(extent={{180,-220},{200,-200}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{120,-270},{140,-250}})));
  Buildings.Controls.OBC.CDL.Logical.Or ope
    "Enable the dry cooler"
    annotation (Placement(transformation(extent={{120,110},{140,130}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo(
    final k=0)
    "Disable fan"
    annotation (Placement(transformation(extent={{180,-290},{200,-270}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooPum
    "Dry cooler pump speed setpoint"
    annotation (Placement(transformation(extent={{240,110},{260,130}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo1(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{180,80},{200,100}})));
  Buildings.Controls.OBC.CDL.Logical.And norWin
    "Normal rate, in winter preferred condition"
    annotation (Placement(transformation(extent={{-80,-150},{-60,-130}})));
  Buildings.Controls.OBC.CDL.Logical.And norSum
    "Normal rate, in summer preferred condition"
    annotation (Placement(transformation(extent={{-80,-190},{-60,-170}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex "Enable heat exchanger"
    annotation (Placement(transformation(extent={{-20,10},{0,30}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex1 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{-20,40},{0,60}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex3 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{-20,210},{0,230}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex2 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{20,40},{40,60}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex4 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{80,210},{100,230}})));
  Buildings.Controls.OBC.CDL.Reals.Switch hexPumVal
    "Heat exchanger pump and valve position setpoint"
    annotation (Placement(transformation(extent={{240,210},{260,230}})));
  Buildings.Controls.OBC.CDL.Reals.Switch hexPumByaVal
    "Heat exchanger bypass valve position setpoint"
    annotation (Placement(transformation(extent={{240,290},{260,310}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(
    final k=mDryCoo_flow_nominal)
    "Convert to the mass flow rate"
    annotation (Placement(transformation(extent={{282,110},{302,130}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mHexGly_flow_nominal)
    "Convert to the mass flow rate"
    annotation (Placement(transformation(extent={{280,210},{300,230}})));
equation
  connect(uEleRat, higRatMod.u2) annotation (Line(points={{-340,270},{-270,270},
          {-270,282},{-262,282}}, color={255,127,0}));
  connect(higRat.y, higRatMod.u1)
    annotation (Line(points={{-278,290},{-262,290}}, color={255,127,0}));
  connect(medLoa.y, medLoaMod.u1)
    annotation (Line(points={{-278,240},{-242,240}}, color={255,127,0}));
  connect(uSt, medLoaMod.u2) annotation (Line(points={{-340,220},{-260,220},{-260,
          232},{-242,232}}, color={255,127,0}));
  connect(win.y, inWin.u1)
    annotation (Line(points={{-278,190},{-242,190}}, color={255,127,0}));
  connect(uGen, inWin.u2) annotation (Line(points={{-340,170},{-250,170},{-250,182},
          {-242,182}}, color={255,127,0}));
  connect(TDryBul, addPar.u)
    annotation (Line(points={{-340,90},{-302,90}}, color={0,0,127}));
  connect(TGenIn, les.u1)
    annotation (Line(points={{-340,130},{-202,130}}, color={0,0,127}));
  connect(addPar.y, les.u2) annotation (Line(points={{-278,90},{-240,90},{-240,122},
          {-202,122}},    color={0,0,127}));
  connect(inWin.y, winPre.u1)
    annotation (Line(points={{-218,190},{-142,190}}, color={255,0,255}));
  connect(les.y, winPre.u2) annotation (Line(points={{-178,130},{-170,130},{-170,
          182},{-142,182}}, color={255,0,255}));
  connect(higRatMod.y, higMed.u1)
    annotation (Line(points={{-238,290},{-142,290}}, color={255,0,255}));
  connect(medLoaMod.y, higMed.u2) annotation (Line(points={{-218,240},{-210,240},
          {-210,282},{-142,282}}, color={255,0,255}));
  connect(winPre.y, higMedWin.u1)
    annotation (Line(points={{-118,190},{-82,190}}, color={255,0,255}));
  connect(higMed.y, higMedWin.u2) annotation (Line(points={{-118,290},{-110,290},
          {-110,182},{-82,182}}, color={255,0,255}));
  connect(sum.y, inSum.u1)
    annotation (Line(points={{-278,10},{-202,10}}, color={255,127,0}));
  connect(uGen, inSum.u2) annotation (Line(points={{-340,170},{-250,170},{-250,2},
          {-202,2}}, color={255,127,0}));
  connect(TDryBul, addPar1.u) annotation (Line(points={{-340,90},{-310,90},{-310,
          50},{-302,50}}, color={0,0,127}));
  connect(TGenIn, gre.u1) annotation (Line(points={{-340,130},{-220,130},{-220,70},
          {-202,70}}, color={0,0,127}));
  connect(addPar1.y, gre.u2) annotation (Line(points={{-278,50},{-240,50},{-240,
          62},{-202,62}}, color={0,0,127}));
  connect(gre.y, sumPre.u1)
    annotation (Line(points={{-178,70},{-142,70}}, color={255,0,255}));
  connect(inSum.y, sumPre.u2) annotation (Line(points={{-178,10},{-160,10},{-160,
          62},{-142,62}}, color={255,0,255}));
  connect(sumPre.y, higMedSum.u1)
    annotation (Line(points={{-118,70},{-82,70}}, color={255,0,255}));
  connect(higMed.y, higMedSum.u2) annotation (Line(points={{-118,290},{-110,290},
          {-110,62},{-82,62}}, color={255,0,255}));
  connect(higLoa.y, higLoaMod.u1)
    annotation (Line(points={{-278,-30},{-242,-30}}, color={255,127,0}));
  connect(uSt, higLoaMod.u2) annotation (Line(points={{-340,220},{-260,220},{-260,
          -38},{-242,-38}}, color={255,127,0}));
  connect(higLoaMod.y, higHig.u1)
    annotation (Line(points={{-218,-30},{-142,-30}}, color={255,0,255}));
  connect(higRatMod.y, higHig.u2) annotation (Line(points={{-238,290},{-150,290},
          {-150,-38},{-142,-38}}, color={255,0,255}));
  connect(higHig.y, higHigWin.u1)
    annotation (Line(points={{-118,-30},{-82,-30}},color={255,0,255}));
  connect(higHigWin.y, higHigWinHeaPum.u1)
    annotation (Line(points={{-58,-30},{-22,-30}}, color={255,0,255}));
  connect(higHigSum.y, higHigSumHeaPum.u1)
    annotation (Line(points={{-58,-90},{-22,-90}}, color={255,0,255}));
  connect(u1HeaPum, higHigWinHeaPum.u2) annotation (Line(points={{-340,-60},{-50,
          -60},{-50,-38},{-22,-38}}, color={255,0,255}));
  connect(u1HeaPum, higHigSumHeaPum.u2) annotation (Line(points={{-340,-60},{-50,
          -60},{-50,-98},{-22,-98}}, color={255,0,255}));
  connect(norRat.y, norRatMod.u1)
    annotation (Line(points={{-278,-140},{-262,-140}}, color={255,127,0}));
  connect(uEleRat, norRatMod.u2) annotation (Line(points={{-340,270},{-270,270},
          {-270,-148},{-262,-148}}, color={255,127,0}));
  connect(higHigWinHeaPum.y, winOpe.u1)
    annotation (Line(points={{2,-30},{18,-30}},   color={255,0,255}));
  connect(norWinHeaPum.y, winOpe.u2) annotation (Line(points={{2,-140},{10,-140},
          {10,-38},{18,-38}}, color={255,0,255}));
  connect(higMedWin.y, winOpe1.u1)
    annotation (Line(points={{-58,190},{-50,190},{-50,120},{78,120}}, color={255,0,255}));
  connect(winOpe.y, winOpe1.u2) annotation (Line(points={{42,-30},{50,-30},{50,112},
          {78,112}}, color={255,0,255}));
  connect(higHigSumHeaPum.y, sumOpe.u1)
    annotation (Line(points={{2,-90},{38,-90}}, color={255,0,255}));
  connect(norSumHeaPum.y, sumOpe.u2) annotation (Line(points={{2,-180},{20,-180},
          {20,-98},{38,-98}}, color={255,0,255}));
  connect(higMedSum.y, sumOpe1.u1)
    annotation (Line(points={{-58,70},{78,70}}, color={255,0,255}));
  connect(sumOpe.y, sumOpe1.u2) annotation (Line(points={{62,-90},{70,-90},{70,62},
          {78,62}}, color={255,0,255}));
  connect(TDryCooOut, sub.u1) annotation (Line(points={{-340,-220},{-280,-220},{
          -280,-234},{-262,-234}}, color={0,0,127}));
  connect(TDryBul, sub.u2) annotation (Line(points={{-340,90},{-310,90},{-310,-246},
          {-262,-246}}, color={0,0,127}));
  connect(sub.y, gai.u) annotation (Line(points={{-238,-240},{-220,-240},{-220,-280},
          {-202,-280}}, color={0,0,127}));
  connect(sumOpe1.y, swi1.u2) annotation (Line(points={{102,70},{110,70},{110,-260},
          {118,-260}},color={255,0,255}));
  connect(sub.y, swi1.u1) annotation (Line(points={{-238,-240},{100,-240},{100,-252},
          {118,-252}}, color={0,0,127}));
  connect(gai.y, swi1.u3) annotation (Line(points={{-178,-280},{100,-280},{100,-268},
          {118,-268}}, color={0,0,127}));
  connect(con1.y, fanCon.u_s)
    annotation (Line(points={{142,-210},{178,-210}}, color={0,0,127}));
  connect(swi1.y, fanCon.u_m) annotation (Line(points={{142,-260},{190,-260},{190,
          -222}}, color={0,0,127}));
  connect(winOpe1.y, ope.u1)
    annotation (Line(points={{102,120},{118,120}},color={255,0,255}));
  connect(sumOpe1.y, ope.u2) annotation (Line(points={{102,70},{110,70},{110,112},
          {118,112}}, color={255,0,255}));
  connect(fanCon.y, dryCooFan.u1) annotation (Line(points={{202,-210},{230,-210},
          {230,-222},{238,-222}}, color={0,0,127}));
  connect(ope.y, dryCooFan.u2) annotation (Line(points={{142,120},{220,120},{220,
          -230},{238,-230}}, color={255,0,255}));
  connect(zeo.y, dryCooFan.u3) annotation (Line(points={{202,-280},{220,-280},{220,
          -238},{238,-238}}, color={0,0,127}));
  connect(ope.y, fanCon.trigger) annotation (Line(points={{142,120},{150,120},{150,
          -240},{184,-240},{184,-222}}, color={255,0,255}));
  connect(con.y, dryCooPum.u1) annotation (Line(points={{202,180},{212,180},{212,
          128},{238,128}}, color={0,0,127}));
  connect(ope.y, dryCooPum.u2)
    annotation (Line(points={{142,120},{238,120}}, color={255,0,255}));
  connect(zeo1.y, dryCooPum.u3) annotation (Line(points={{202,90},{230,90},{230,
          112},{238,112}}, color={0,0,127}));
  connect(dryCooFan.y, yDryCoo)
    annotation (Line(points={{262,-230},{340,-230}}, color={0,0,127}));
  connect(norWin.y, norWinHeaPum.u1)
    annotation (Line(points={{-58,-140},{-22,-140}}, color={255,0,255}));
  connect(norSum.y, norSumHeaPum.u1)
    annotation (Line(points={{-58,-180},{-22,-180}}, color={255,0,255}));
  connect(u1HeaPum, norWinHeaPum.u2) annotation (Line(points={{-340,-60},{-50,-60},
          {-50,-148},{-22,-148}}, color={255,0,255}));
  connect(u1HeaPum, norSumHeaPum.u2) annotation (Line(points={{-340,-60},{-50,-60},
          {-50,-188},{-22,-188}}, color={255,0,255}));
  connect(norRatMod.y, norWin.u1)
    annotation (Line(points={{-238,-140},{-82,-140}}, color={255,0,255}));
  connect(norRatMod.y, norSum.u1) annotation (Line(points={{-238,-140},{-200,-140},
          {-200,-180},{-82,-180}}, color={255,0,255}));
  connect(winPre.y, norWin.u2) annotation (Line(points={{-118,190},{-100,190},{-100,
          -148},{-82,-148}}, color={255,0,255}));
  connect(sumPre.y, norSum.u2) annotation (Line(points={{-118,70},{-90,70},{-90,
          -188},{-82,-188}}, color={255,0,255}));
  connect(higHig.y, higHigSum.u1) annotation (Line(points={{-118,-30},{-110,-30},
          {-110,-90},{-82,-90}}, color={255,0,255}));
  connect(winPre.y, higHigWin.u2) annotation (Line(points={{-118,190},{-100,190},
          {-100,-38},{-82,-38}}, color={255,0,255}));
  connect(sumPre.y, higHigSum.u2) annotation (Line(points={{-118,70},{-90,70},{-90,
          -98},{-82,-98}}, color={255,0,255}));
  connect(norSum.y, enaHex.u2) annotation (Line(points={{-58,-180},{-30,-180},{-30,
          12},{-22,12}},color={255,0,255}));
  connect(norWin.y, enaHex.u1) annotation (Line(points={{-58,-140},{-36,-140},{-36,
          20},{-22,20}},color={255,0,255}));
  connect(higHigSum.y, enaHex1.u2) annotation (Line(points={{-58,-90},{-42,-90},
          {-42,42},{-22,42}},color={255,0,255}));
  connect(higHigWin.y, enaHex1.u1) annotation (Line(points={{-58,-30},{-50,-30},
          {-50,50},{-22,50}},color={255,0,255}));
  connect(higMedSum.y, enaHex3.u2) annotation (Line(points={{-58,70},{-40,70},{-40,
          212},{-22,212}},color={255,0,255}));
  connect(higMedWin.y, enaHex3.u1) annotation (Line(points={{-58,190},{-50,190},
          {-50,220},{-22,220}},color={255,0,255}));
  connect(enaHex1.y, enaHex2.u1)
    annotation (Line(points={{2,50},{18,50}},  color={255,0,255}));
  connect(enaHex.y, enaHex2.u2) annotation (Line(points={{2,20},{10,20},{10,42},
          {18,42}}, color={255,0,255}));
  connect(enaHex3.y, enaHex4.u1)
    annotation (Line(points={{2,220},{78,220}},  color={255,0,255}));
  connect(enaHex2.y, enaHex4.u2) annotation (Line(points={{42,50},{60,50},{60,212},
          {78,212}}, color={255,0,255}));
  connect(enaHex4.y, hexPumVal.u2)
    annotation (Line(points={{102,220},{238,220}}, color={255,0,255}));
  connect(con.y, hexPumVal.u1) annotation (Line(points={{202,180},{212,180},{212,
          228},{238,228}}, color={0,0,127}));
  connect(zeo1.y, hexPumVal.u3) annotation (Line(points={{202,90},{230,90},{230,
          212},{238,212}}, color={0,0,127}));
  connect(enaHex4.y, hexPumByaVal.u2) annotation (Line(points={{102,220},{140,220},
          {140,300},{238,300}}, color={255,0,255}));
  connect(zeo1.y, hexPumByaVal.u1) annotation (Line(points={{202,90},{230,90},{230,
          308},{238,308}}, color={0,0,127}));
  connect(con.y, hexPumByaVal.u3) annotation (Line(points={{202,180},{212,180},{
          212,292},{238,292}}, color={0,0,127}));
  connect(hexPumVal.y, yValHex) annotation (Line(points={{262,220},{270,220},{270,
          260},{340,260}}, color={0,0,127}));
  connect(hexPumByaVal.y, yValHexByp)
    annotation (Line(points={{262,300},{340,300}}, color={0,0,127}));
  connect(dryCooPum.y, gai1.u)
    annotation (Line(points={{262,120},{280,120}}, color={0,0,127}));
  connect(gai1.y, yPumDryCoo)
    annotation (Line(points={{304,120},{340,120}}, color={0,0,127}));
  connect(hexPumVal.y, gai2.u)
    annotation (Line(points={{262,220},{278,220}}, color={0,0,127}));
  connect(gai2.y, yPumHex)
    annotation (Line(points={{302,220},{340,220}}, color={0,0,127}));
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
          extent={{-320,-320},{320,320}})),
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
