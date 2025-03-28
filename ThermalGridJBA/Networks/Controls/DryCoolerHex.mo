within ThermalGridJBA.Networks.Controls;
model DryCoolerHex
  "Sequence for control dry cooler and heat exchanger"

  parameter Real mHexGly_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal glycol mass flow rate for heat exchanger";
  parameter Real mDryCoo_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
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

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1Spr "True: in Spring"
    annotation (Placement(transformation(extent={{-360,330},{-320,370}}),
        iconTransformation(extent={{-140,80},{-100,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1CooLoo
    "True: the loop water is cool; False: the loop water is warm"
    annotation (Placement(transformation(extent={{-360,300},{-320,340}}),
        iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1Fal "True: in Fall"
    annotation (Placement(transformation(extent={{-360,270},{-320,310}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{-360,200},{-320,240}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "District loop load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-360,150},{-320,190}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uGen
    "Season indicator. 1-winter; 2-shoulder; 3-summer"
    annotation (Placement(transformation(extent={{-360,100},{-320,140}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TGenIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Temperature of the water from the district loop"
    annotation (Placement(transformation(extent={{-360,60},{-320,100}}),
        iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-360,20},{-320,60}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPum
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{-360,-250},{-320,-210}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPumMod
    "Heat pump mode: true - heating mode"
    annotation (Placement(transformation(extent={{-360,-300},{-320,-260}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryCooOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Dry cooler outlet glycol temperature"
    annotation (Placement(transformation(extent={{-360,-360},{-320,-320}}),
        iconTransformation(extent={{-140,-120},{-100,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHexByp(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger bypass valve position setpoint"
    annotation (Placement(transformation(extent={{320,230},{360,270}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHex(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger valve position setpoint"
    annotation (Placement(transformation(extent={{320,190},{360,230}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumHex(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat exchanger pump speed setpoint"
    annotation (Placement(transformation(extent={{320,150},{360,190}}),
        iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumDryCoo(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint of the pump for the dry cooler"
    annotation (Placement(transformation(extent={{320,50},{360,90}}),
      iconTransformation(extent={{100,-60},{140,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDryCoo(
    final min=0,
    final max=1,
    final unit="1")
    "Speed setpoint of the dry cooler fan"
    annotation (Placement(transformation(extent={{320,-300},{360,-260}}),
        iconTransformation(extent={{100,-100},{140,-60}})));

  Buildings.Controls.OBC.CDL.Integers.Equal higRatMod
    "Check if it is in high electricity rate mode"
    annotation (Placement(transformation(extent={{-240,230},{-220,250}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooFan
    "Dry cooler fan speed setpoint"
    annotation (Placement(transformation(extent={{282,-290},{302,-270}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(
    final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-300,230},{-280,250}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant medLoa(
    final k=2)
    "Medium district load"
    annotation (Placement(transformation(extent={{-300,180},{-280,200}})));
  Buildings.Controls.OBC.CDL.Integers.Equal medLoaMod
    "Check if the district load is medium"
    annotation (Placement(transformation(extent={{-220,180},{-200,200}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(
    final k=1) "Winter"
    annotation (Placement(transformation(extent={{-300,130},{-280,150}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin "Check if it is in winter"
    annotation (Placement(transformation(extent={{-220,130},{-200,150}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(
    final p=-TApp)
    annotation (Placement(transformation(extent={{-300,30},{-280,50}})));
  Buildings.Controls.OBC.CDL.Reals.Less les(
    final h=THys)
    "Compare inputs"
    annotation (Placement(transformation(extent={{-220,70},{-200,90}})));
  Buildings.Controls.OBC.CDL.Logical.And winPre "In winter perferred condition"
    annotation (Placement(transformation(extent={{-140,130},{-120,150}})));
  Buildings.Controls.OBC.CDL.Logical.And higMed
    "High electricity rate and medium district load"
    annotation (Placement(transformation(extent={{-140,230},{-120,250}})));
  Buildings.Controls.OBC.CDL.Logical.And higMedWin
    "High rate, medium district load, and in winter preferred condition"
    annotation (Placement(transformation(extent={{-80,130},{-60,150}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(
    final k=1) "One"
    annotation (Placement(transformation(extent={{180,120},{200,140}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum
    "Check if it is in summer"
    annotation (Placement(transformation(extent={{-200,-50},{-180,-30}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum(
    final k=3)
    "Summer"
    annotation (Placement(transformation(extent={{-300,-50},{-280,-30}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(
    final p=TApp)
    annotation (Placement(transformation(extent={{-300,-10},{-280,10}})));
  Buildings.Controls.OBC.CDL.Reals.Greater gre(
    final h=THys)
    "Compare inputs"
    annotation (Placement(transformation(extent={{-220,10},{-200,30}})));
  Buildings.Controls.OBC.CDL.Logical.And sumPre
    "In summer preferred condition"
    annotation (Placement(transformation(extent={{-140,10},{-120,30}})));
  Buildings.Controls.OBC.CDL.Logical.And higMedSum
    "High rate, medium district load, and in summer preferred condition"
    annotation (Placement(transformation(extent={{-80,10},{-60,30}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higLoaMod
    "Check if the district load is high"
    annotation (Placement(transformation(extent={{-240,-90},{-220,-70}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(
    final k=3)
    "HIgh district load"
    annotation (Placement(transformation(extent={{-300,-90},{-280,-70}})));
  Buildings.Controls.OBC.CDL.Logical.And higHig
    "High electricity rate and high district load"
    annotation (Placement(transformation(extent={{-140,-90},{-120,-70}})));
  Buildings.Controls.OBC.CDL.Logical.And higHigWin
    "High rate, high district load, and in winter preferred condition"
    annotation (Placement(transformation(extent={{-80,-90},{-60,-70}})));
  Buildings.Controls.OBC.CDL.Logical.And higHigSum
    "High rate, high district load, and in summer preferred condition"
    annotation (Placement(transformation(extent={{-80,-130},{-60,-110}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant norRat(
    final k=0)
    "Normal electricity rate"
    annotation (Placement(transformation(extent={{-300,-170},{-280,-150}})));
  Buildings.Controls.OBC.CDL.Integers.Equal norRatMod
    "Check if it is in normal electricity rate mode"
    annotation (Placement(transformation(extent={{-260,-170},{-240,-150}})));
  Buildings.Controls.OBC.CDL.Logical.Or winOpe
    "Enable the dry cooler in winter"
    annotation (Placement(transformation(extent={{-20,-90},{0,-70}})));
  Buildings.Controls.OBC.CDL.Logical.Or winOpe1
    "Enable the dry cooler in winter"
    annotation (Placement(transformation(extent={{80,60},{100,80}})));
  Buildings.Controls.OBC.CDL.Logical.Or sumOpe
    "Enable the dry cooler in summer"
    annotation (Placement(transformation(extent={{-20,-130},{0,-110}})));
  Buildings.Controls.OBC.CDL.Logical.Or sumOpe1
    "Enable the dry cooler in summer"
    annotation (Placement(transformation(extent={{80,10},{100,30}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Check temperature difference"
    annotation (Placement(transformation(extent={{-260,-360},{-240,-340}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(
    final k=-1)
    "Reverse the subtract"
    annotation (Placement(transformation(extent={{160,-360},{180,-340}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(
    final k=TAppSet)
    "Dry cooler approach temperature setpoint"
    annotation (Placement(transformation(extent={{160,-270},{180,-250}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset fanCon(
    final controllerType=fanConTyp,
    final k=kFan,
    final Ti=TiFan,
    final Td=TdFan,
    final reverseActing=false,
    final y_reset=minFanSpe)
    "Dry cooler fan speed controller"
    annotation (Placement(transformation(extent={{220,-270},{240,-250}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{200,-320},{220,-300}})));
  Buildings.Controls.OBC.CDL.Logical.Or weaEna
    "Enable the dry cooler based on the weather condition"
    annotation (Placement(transformation(extent={{120,60},{140,80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo(
    final k=0)
    "Disable fan"
    annotation (Placement(transformation(extent={{220,-360},{240,-340}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooPum
    "Dry cooler pump speed setpoint"
    annotation (Placement(transformation(extent={{240,60},{260,80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo1(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{160,20},{180,40}})));
  Buildings.Controls.OBC.CDL.Logical.And norWin
    "Normal rate, in winter preferred condition"
    annotation (Placement(transformation(extent={{-80,-170},{-60,-150}})));
  Buildings.Controls.OBC.CDL.Logical.And norSum
    "Normal rate, in summer preferred condition"
    annotation (Placement(transformation(extent={{-80,-210},{-60,-190}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex "Enable heat exchanger"
    annotation (Placement(transformation(extent={{-20,-40},{0,-20}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex1 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex3 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{-20,160},{0,180}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex2 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex4 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{80,160},{100,180}})));
  Buildings.Controls.OBC.CDL.Reals.Switch hexPumVal
    "Heat exchanger pump and valve position setpoint"
    annotation (Placement(transformation(extent={{240,160},{260,180}})));
  Buildings.Controls.OBC.CDL.Reals.Switch hexPumByaVal
    "Heat exchanger bypass valve position setpoint"
    annotation (Placement(transformation(extent={{240,240},{260,260}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(
    final k=mDryCoo_flow_nominal)
    "Convert to the mass flow rate"
    annotation (Placement(transformation(extent={{280,60},{300,80}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mHexGly_flow_nominal)
    "Convert to the mass flow rate"
    annotation (Placement(transformation(extent={{280,160},{300,180}})));
  Buildings.Controls.OBC.CDL.Logical.And cooHeaPum
    "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{-80,-320},{-60,-300}})));
  Buildings.Controls.OBC.CDL.Logical.Not inCooMod "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{-260,-290},{-240,-270}})));
  Buildings.Controls.OBC.CDL.Logical.Or cooWat
    "Dry cooler should cooling down the water flow"
    annotation (Placement(transformation(extent={{120,-320},{140,-300}})));
  Buildings.Controls.OBC.CDL.Logical.Or ena
    "Enable the dry cooler based on weather condition, or heat pump operation"
    annotation (Placement(transformation(extent={{160,60},{180,80}})));
  Buildings.Controls.OBC.CDL.Logical.And warFal "Warm Fall"
    annotation (Placement(transformation(extent={{-140,280},{-120,300}})));
  Buildings.Controls.OBC.CDL.Logical.And colSpr "Cold spring"
    annotation (Placement(transformation(extent={{-140,340},{-120,360}})));
  Buildings.Controls.OBC.CDL.Logical.And sprWarLoo
    "In Spring and conditions are good for warm loop"
    annotation (Placement(transformation(extent={{-20,340},{0,360}})));
  Buildings.Controls.OBC.CDL.Logical.And falCooLoo
    "In Fall and conditions are good for cool loop"
    annotation (Placement(transformation(extent={{-20,280},{0,300}})));
  Buildings.Controls.OBC.CDL.Logical.Not warLoo "Warm loop"
    annotation (Placement(transformation(extent={{-80,310},{-60,330}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHexSho
    "Enable heat exchanger in shoulder season"
    annotation (Placement(transformation(extent={{80,340},{100,360}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHexSho1
    "Enable heat exchanger in shoulder season"
    annotation (Placement(transformation(extent={{140,240},{160,260}})));

equation
  connect(uEleRat, higRatMod.u2) annotation (Line(points={{-340,220},{-270,220},
          {-270,232},{-242,232}}, color={255,127,0}));
  connect(higRat.y, higRatMod.u1)
    annotation (Line(points={{-278,240},{-242,240}}, color={255,127,0}));
  connect(medLoa.y, medLoaMod.u1)
    annotation (Line(points={{-278,190},{-222,190}}, color={255,127,0}));
  connect(uSt, medLoaMod.u2) annotation (Line(points={{-340,170},{-260,170},{-260,
          182},{-222,182}}, color={255,127,0}));
  connect(win.y, inWin.u1)
    annotation (Line(points={{-278,140},{-222,140}}, color={255,127,0}));
  connect(uGen, inWin.u2) annotation (Line(points={{-340,120},{-250,120},{-250,132},
          {-222,132}}, color={255,127,0}));
  connect(TDryBul, addPar.u)
    annotation (Line(points={{-340,40},{-302,40}}, color={0,0,127}));
  connect(TGenIn, les.u1)
    annotation (Line(points={{-340,80},{-222,80}},   color={0,0,127}));
  connect(addPar.y, les.u2) annotation (Line(points={{-278,40},{-240,40},{-240,72},
          {-222,72}},     color={0,0,127}));
  connect(inWin.y, winPre.u1)
    annotation (Line(points={{-198,140},{-142,140}}, color={255,0,255}));
  connect(les.y, winPre.u2) annotation (Line(points={{-198,80},{-160,80},{-160,132},
          {-142,132}},      color={255,0,255}));
  connect(higRatMod.y, higMed.u1)
    annotation (Line(points={{-218,240},{-142,240}}, color={255,0,255}));
  connect(medLoaMod.y, higMed.u2) annotation (Line(points={{-198,190},{-180,190},
          {-180,232},{-142,232}}, color={255,0,255}));
  connect(winPre.y, higMedWin.u1)
    annotation (Line(points={{-118,140},{-82,140}}, color={255,0,255}));
  connect(higMed.y, higMedWin.u2) annotation (Line(points={{-118,240},{-110,240},
          {-110,132},{-82,132}}, color={255,0,255}));
  connect(sum.y, inSum.u1)
    annotation (Line(points={{-278,-40},{-202,-40}},
                                                   color={255,127,0}));
  connect(uGen, inSum.u2) annotation (Line(points={{-340,120},{-250,120},{-250,-48},
          {-202,-48}},
                     color={255,127,0}));
  connect(TDryBul, addPar1.u) annotation (Line(points={{-340,40},{-310,40},{-310,
          0},{-302,0}},   color={0,0,127}));
  connect(TGenIn, gre.u1) annotation (Line(points={{-340,80},{-230,80},{-230,20},
          {-222,20}}, color={0,0,127}));
  connect(addPar1.y, gre.u2) annotation (Line(points={{-278,0},{-240,0},{-240,12},
          {-222,12}},     color={0,0,127}));
  connect(gre.y, sumPre.u1)
    annotation (Line(points={{-198,20},{-142,20}}, color={255,0,255}));
  connect(inSum.y, sumPre.u2) annotation (Line(points={{-178,-40},{-160,-40},{-160,
          12},{-142,12}}, color={255,0,255}));
  connect(sumPre.y, higMedSum.u1)
    annotation (Line(points={{-118,20},{-82,20}}, color={255,0,255}));
  connect(higMed.y, higMedSum.u2) annotation (Line(points={{-118,240},{-110,240},
          {-110,12},{-82,12}}, color={255,0,255}));
  connect(higLoa.y, higLoaMod.u1)
    annotation (Line(points={{-278,-80},{-242,-80}}, color={255,127,0}));
  connect(uSt, higLoaMod.u2) annotation (Line(points={{-340,170},{-260,170},{-260,
          -88},{-242,-88}}, color={255,127,0}));
  connect(higLoaMod.y, higHig.u1)
    annotation (Line(points={{-218,-80},{-142,-80}}, color={255,0,255}));
  connect(higRatMod.y, higHig.u2) annotation (Line(points={{-218,240},{-150,240},
          {-150,-88},{-142,-88}}, color={255,0,255}));
  connect(higHig.y, higHigWin.u1)
    annotation (Line(points={{-118,-80},{-82,-80}},color={255,0,255}));
  connect(norRat.y, norRatMod.u1)
    annotation (Line(points={{-278,-160},{-262,-160}}, color={255,127,0}));
  connect(uEleRat, norRatMod.u2) annotation (Line(points={{-340,220},{-270,220},
          {-270,-168},{-262,-168}}, color={255,127,0}));
  connect(higMedWin.y, winOpe1.u1)
    annotation (Line(points={{-58,140},{-50,140},{-50,70},{78,70}},   color={255,0,255}));
  connect(winOpe.y, winOpe1.u2) annotation (Line(points={{2,-80},{50,-80},{50,62},
          {78,62}},  color={255,0,255}));
  connect(higMedSum.y, sumOpe1.u1)
    annotation (Line(points={{-58,20},{78,20}}, color={255,0,255}));
  connect(sumOpe.y, sumOpe1.u2) annotation (Line(points={{2,-120},{70,-120},{70,
          12},{78,12}},
                    color={255,0,255}));
  connect(TDryCooOut, sub.u1) annotation (Line(points={{-340,-340},{-280,-340},{
          -280,-344},{-262,-344}}, color={0,0,127}));
  connect(TDryBul, sub.u2) annotation (Line(points={{-340,40},{-310,40},{-310,-356},
          {-262,-356}}, color={0,0,127}));
  connect(sub.y, gai.u) annotation (Line(points={{-238,-350},{158,-350}},
                        color={0,0,127}));
  connect(sub.y, swi1.u1) annotation (Line(points={{-238,-350},{150,-350},{150,-302},
          {198,-302}}, color={0,0,127}));
  connect(gai.y, swi1.u3) annotation (Line(points={{182,-350},{190,-350},{190,-318},
          {198,-318}}, color={0,0,127}));
  connect(con1.y, fanCon.u_s)
    annotation (Line(points={{182,-260},{218,-260}}, color={0,0,127}));
  connect(swi1.y, fanCon.u_m) annotation (Line(points={{222,-310},{230,-310},{230,
          -272}}, color={0,0,127}));
  connect(winOpe1.y, weaEna.u1)
    annotation (Line(points={{102,70},{118,70}},   color={255,0,255}));
  connect(sumOpe1.y, weaEna.u2) annotation (Line(points={{102,20},{110,20},{110,
          62},{118,62}},   color={255,0,255}));
  connect(fanCon.y, dryCooFan.u1) annotation (Line(points={{242,-260},{260,-260},
          {260,-272},{280,-272}}, color={0,0,127}));
  connect(zeo.y, dryCooFan.u3) annotation (Line(points={{242,-350},{260,-350},{260,
          -288},{280,-288}}, color={0,0,127}));
  connect(con.y, dryCooPum.u1) annotation (Line(points={{202,130},{212,130},{212,
          78},{238,78}},   color={0,0,127}));
  connect(zeo1.y, dryCooPum.u3) annotation (Line(points={{182,30},{230,30},{230,
          62},{238,62}},   color={0,0,127}));
  connect(dryCooFan.y, yDryCoo)
    annotation (Line(points={{304,-280},{340,-280}}, color={0,0,127}));
  connect(norRatMod.y, norWin.u1)
    annotation (Line(points={{-238,-160},{-82,-160}}, color={255,0,255}));
  connect(norRatMod.y, norSum.u1) annotation (Line(points={{-238,-160},{-200,-160},
          {-200,-200},{-82,-200}}, color={255,0,255}));
  connect(winPre.y, norWin.u2) annotation (Line(points={{-118,140},{-100,140},{-100,
          -168},{-82,-168}}, color={255,0,255}));
  connect(sumPre.y, norSum.u2) annotation (Line(points={{-118,20},{-90,20},{-90,
          -208},{-82,-208}}, color={255,0,255}));
  connect(higHig.y, higHigSum.u1) annotation (Line(points={{-118,-80},{-110,-80},
          {-110,-120},{-82,-120}},
                                 color={255,0,255}));
  connect(winPre.y, higHigWin.u2) annotation (Line(points={{-118,140},{-100,140},
          {-100,-88},{-82,-88}}, color={255,0,255}));
  connect(sumPre.y, higHigSum.u2) annotation (Line(points={{-118,20},{-90,20},{-90,
          -128},{-82,-128}},
                           color={255,0,255}));
  connect(norSum.y, enaHex.u2) annotation (Line(points={{-58,-200},{-30,-200},{-30,
          -38},{-22,-38}},
                        color={255,0,255}));
  connect(norWin.y, enaHex.u1) annotation (Line(points={{-58,-160},{-36,-160},{-36,
          -30},{-22,-30}},
                        color={255,0,255}));
  connect(higHigSum.y, enaHex1.u2) annotation (Line(points={{-58,-120},{-42,-120},
          {-42,-8},{-22,-8}},color={255,0,255}));
  connect(higHigWin.y, enaHex1.u1) annotation (Line(points={{-58,-80},{-50,-80},
          {-50,0},{-22,0}},  color={255,0,255}));
  connect(higMedSum.y, enaHex3.u2) annotation (Line(points={{-58,20},{-40,20},{-40,
          162},{-22,162}},color={255,0,255}));
  connect(higMedWin.y, enaHex3.u1) annotation (Line(points={{-58,140},{-50,140},
          {-50,170},{-22,170}},color={255,0,255}));
  connect(enaHex1.y, enaHex2.u1)
    annotation (Line(points={{2,0},{18,0}},    color={255,0,255}));
  connect(enaHex.y, enaHex2.u2) annotation (Line(points={{2,-30},{10,-30},{10,-8},
          {18,-8}}, color={255,0,255}));
  connect(enaHex3.y, enaHex4.u1)
    annotation (Line(points={{2,170},{78,170}},  color={255,0,255}));
  connect(enaHex2.y, enaHex4.u2) annotation (Line(points={{42,0},{60,0},{60,162},
          {78,162}}, color={255,0,255}));
  connect(con.y, hexPumVal.u1) annotation (Line(points={{202,130},{212,130},{212,
          178},{238,178}}, color={0,0,127}));
  connect(zeo1.y, hexPumVal.u3) annotation (Line(points={{182,30},{230,30},{230,
          162},{238,162}}, color={0,0,127}));
  connect(zeo1.y, hexPumByaVal.u1) annotation (Line(points={{182,30},{230,30},{230,
          258},{238,258}}, color={0,0,127}));
  connect(con.y, hexPumByaVal.u3) annotation (Line(points={{202,130},{212,130},{
          212,242},{238,242}}, color={0,0,127}));
  connect(hexPumVal.y, yValHex) annotation (Line(points={{262,170},{270,170},{270,
          210},{340,210}}, color={0,0,127}));
  connect(hexPumByaVal.y, yValHexByp)
    annotation (Line(points={{262,250},{340,250}}, color={0,0,127}));
  connect(dryCooPum.y, gai1.u)
    annotation (Line(points={{262,70},{278,70}},   color={0,0,127}));
  connect(gai1.y, yPumDryCoo)
    annotation (Line(points={{302,70},{340,70}},   color={0,0,127}));
  connect(hexPumVal.y, gai2.u)
    annotation (Line(points={{262,170},{278,170}}, color={0,0,127}));
  connect(gai2.y, yPumHex)
    annotation (Line(points={{302,170},{340,170}}, color={0,0,127}));
  connect(higHigWin.y, winOpe.u1)
    annotation (Line(points={{-58,-80},{-22,-80}}, color={255,0,255}));
  connect(higHigSum.y, sumOpe.u1)
    annotation (Line(points={{-58,-120},{-22,-120}},
                                                   color={255,0,255}));
  connect(norWin.y, winOpe.u2) annotation (Line(points={{-58,-160},{-36,-160},{-36,
          -88},{-22,-88}}, color={255,0,255}));
  connect(norSum.y, sumOpe.u2) annotation (Line(points={{-58,-200},{-30,-200},{-30,
          -128},{-22,-128}},
                           color={255,0,255}));
  connect(u1HeaPumMod, inCooMod.u)
    annotation (Line(points={{-340,-280},{-262,-280}}, color={255,0,255}));
  connect(inCooMod.y, cooHeaPum.u2) annotation (Line(points={{-238,-280},{-220,-280},
          {-220,-318},{-82,-318}}, color={255,0,255}));
  connect(u1HeaPum, cooHeaPum.u1) annotation (Line(points={{-340,-230},{-160,-230},
          {-160,-310},{-82,-310}}, color={255,0,255}));
  connect(cooHeaPum.y, cooWat.u1)
    annotation (Line(points={{-58,-310},{118,-310}}, color={255,0,255}));
  connect(sumOpe1.y, cooWat.u2) annotation (Line(points={{102,20},{110,20},{110,
          -318},{118,-318}}, color={255,0,255}));
  connect(cooWat.y, swi1.u2)
    annotation (Line(points={{142,-310},{198,-310}}, color={255,0,255}));
  connect(weaEna.y, ena.u1)
    annotation (Line(points={{142,70},{158,70}},   color={255,0,255}));
  connect(u1HeaPum, ena.u2) annotation (Line(points={{-340,-230},{150,-230},{150,
          62},{158,62}},   color={255,0,255}));
  connect(ena.y, dryCooPum.u2)
    annotation (Line(points={{182,70},{238,70}},   color={255,0,255}));
  connect(ena.y, fanCon.trigger) annotation (Line(points={{182,70},{200,70},{200,
          -280},{224,-280},{224,-272}}, color={255,0,255}));
  connect(ena.y, dryCooFan.u2) annotation (Line(points={{182,70},{200,70},{200,-280},
          {280,-280}},       color={255,0,255}));
  connect(gre.y, colSpr.u2) annotation (Line(points={{-198,20},{-170,20},{-170,342},
          {-142,342}}, color={255,0,255}));
  connect(les.y, warFal.u2) annotation (Line(points={{-198,80},{-160,80},{-160,282},
          {-142,282}}, color={255,0,255}));
  connect(warFal.y, falCooLoo.u1)
    annotation (Line(points={{-118,290},{-22,290}}, color={255,0,255}));
  connect(colSpr.y, sprWarLoo.u1)
    annotation (Line(points={{-118,350},{-22,350}}, color={255,0,255}));
  connect(enaHexSho1.y, hexPumByaVal.u2)
    annotation (Line(points={{162,250},{238,250}}, color={255,0,255}));
  connect(enaHexSho1.y, hexPumVal.u2) annotation (Line(points={{162,250},{180,250},
          {180,170},{238,170}}, color={255,0,255}));
  connect(enaHexSho.y, enaHexSho1.u1) annotation (Line(points={{102,350},{120,350},
          {120,250},{138,250}}, color={255,0,255}));
  connect(enaHex4.y, enaHexSho1.u2) annotation (Line(points={{102,170},{120,170},
          {120,242},{138,242}}, color={255,0,255}));
  connect(u1CooLoo, warLoo.u)
    annotation (Line(points={{-340,320},{-82,320}}, color={255,0,255}));
  connect(warLoo.y, sprWarLoo.u2) annotation (Line(points={{-58,320},{-40,320},{
          -40,342},{-22,342}}, color={255,0,255}));
  connect(u1CooLoo, falCooLoo.u2) annotation (Line(points={{-340,320},{-100,320},
          {-100,282},{-22,282}}, color={255,0,255}));
  connect(u1Spr, colSpr.u1) annotation (Line(points={{-340,350},{-146,350},{-146,
          350},{-142,350}}, color={255,0,255}));
  connect(u1Fal, warFal.u1) annotation (Line(points={{-340,290},{-142,290},{-142,
          290}}, color={255,0,255}));
  connect(sprWarLoo.y, enaHexSho.u1)
    annotation (Line(points={{2,350},{78,350}}, color={255,0,255}));
  connect(falCooLoo.y, enaHexSho.u2) annotation (Line(points={{2,290},{20,290},{
          20,342},{78,342}}, color={255,0,255}));
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
          extent={{-100,48},{-52,32}},
          textColor={255,127,0},
          textString="uEleRat"),
        Text(
          extent={{-100,28},{-74,12}},
          textColor={255,127,0},
          textString="uSt"),
        Text(
          extent={{-100,8},{-62,-8}},
          textColor={255,127,0},
          textString="uGen"),
        Text(
          extent={{-98,-10},{-60,-26}},
          textColor={0,0,127},
          textString="TGenIn"),
        Text(
          extent={{-98,-32},{-60,-48}},
          textColor={0,0,127},
          textString="TDryBul"),
        Text(
          extent={{-98,-84},{-40,-100}},
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
          textString="yPumHex"),
        Text(
          extent={{-96,-68},{-32,-86}},
          textColor={255,0,255},
          textString="u1HeaPumMod"),
        Text(
          extent={{-96,90},{-46,72}},
          textColor={255,0,255},
          textString="u1CooLoo"),
        Text(
          extent={{-96,70},{-70,52}},
          textColor={255,0,255},
          textString="u1Fal"),
        Text(
          extent={{-96,104},{-66,86}},
          textColor={255,0,255},
          textString="u1Spr")}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-320,-380},{320,380}})),
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
