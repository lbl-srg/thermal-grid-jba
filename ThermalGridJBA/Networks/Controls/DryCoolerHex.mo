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
    annotation (Placement(transformation(extent={{-380,330},{-340,370}}),
        iconTransformation(extent={{-140,80},{-100,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uLooHea
    "-1: cool loop; 1: warm loop; 0: average" annotation (Placement(
        transformation(extent={{-380,300},{-340,340}}), iconTransformation(
          extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1Fal "True: in Fall"
    annotation (Placement(transformation(extent={{-380,260},{-340,300}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{-380,200},{-340,240}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "District loop load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-380,150},{-340,190}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uGen
    "Season indicator. 1-Winter; 2-shoulder; 3-Summer"
    annotation (Placement(transformation(extent={{-380,100},{-340,140}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TGenIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Temperature of the water from the district loop"
    annotation (Placement(transformation(extent={{-380,60},{-340,100}}),
        iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-380,20},{-340,60}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPum
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{-380,-300},{-340,-260}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPumMod
    "Heat pump mode: true - heating mode"
    annotation (Placement(transformation(extent={{-380,-340},{-340,-300}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryCooOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Dry cooler outlet glycol temperature"
    annotation (Placement(transformation(extent={{-380,-370},{-340,-330}}),
        iconTransformation(extent={{-140,-120},{-100,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHexByp(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger bypass valve position setpoint"
    annotation (Placement(transformation(extent={{340,230},{380,270}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValHex(
    final min=0,
    final max=1,
    final unit="1") "Heat exchanger valve position setpoint"
    annotation (Placement(transformation(extent={{340,190},{380,230}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumHex(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat exchanger pump speed setpoint"
    annotation (Placement(transformation(extent={{340,150},{380,190}}),
        iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumDryCoo(
    final quantity="MassFlowRate",
    final unit="kg/s") "Speed setpoint of the pump for the dry cooler"
    annotation (Placement(transformation(extent={{340,50},{380,90}}),
      iconTransformation(extent={{100,-40},{140,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAirDryCooIn(
    final unit="K",
    displayUnit="degC")
    "Dry cooler air temperature input"
    annotation (Placement(transformation(extent={{340,-240},{380,-200}}),
        iconTransformation(extent={{100,-80},{140,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDryCoo(
    final min=0,
    final max=1,
    final unit="1")
    "Speed setpoint of the dry cooler fan"
    annotation (Placement(transformation(extent={{340,-300},{380,-260}}),
        iconTransformation(extent={{100,-110},{140,-70}})));

  Buildings.Controls.OBC.CDL.Integers.Equal higRatMod
    "Check if it is in high electricity rate mode"
    annotation (Placement(transformation(extent={{-260,230},{-240,250}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooFan
    "Dry cooler fan speed setpoint"
    annotation (Placement(transformation(extent={{300,-290},{320,-270}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(
    final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-320,230},{-300,250}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant medLoa(
    final k=2)
    "Medium district load"
    annotation (Placement(transformation(extent={{-320,180},{-300,200}})));
  Buildings.Controls.OBC.CDL.Integers.Equal medLoaMod
    "Check if the district load is medium"
    annotation (Placement(transformation(extent={{-260,180},{-240,200}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(
    final k=1) "Winter"
    annotation (Placement(transformation(extent={{-320,130},{-300,150}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin "Check if it is in Winter"
    annotation (Placement(transformation(extent={{-240,130},{-220,150}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(
    final p=-TApp)
    annotation (Placement(transformation(extent={{-320,30},{-300,50}})));
  Buildings.Controls.OBC.CDL.Reals.Less les(
    final h=THys)
    "Compare inputs"
    annotation (Placement(transformation(extent={{-240,70},{-220,90}})));
  Buildings.Controls.OBC.CDL.Logical.And winPre "In Winter perferred condition"
    annotation (Placement(transformation(extent={{-180,130},{-160,150}})));
  Buildings.Controls.OBC.CDL.Logical.And higMed
    "High electricity rate and medium district load"
    annotation (Placement(transformation(extent={{-180,230},{-160,250}})));
  Buildings.Controls.OBC.CDL.Logical.And higMedWin
    "High rate, medium district load, and in Winter preferred condition"
    annotation (Placement(transformation(extent={{-120,130},{-100,150}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(
    final k=1) "One"
    annotation (Placement(transformation(extent={{200,120},{220,140}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum
    "Check if it is in Summer"
    annotation (Placement(transformation(extent={{-240,-50},{-220,-30}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum(
    final k=3)
    "Summer"
    annotation (Placement(transformation(extent={{-320,-50},{-300,-30}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(
    final p=TApp)
    annotation (Placement(transformation(extent={{-320,-10},{-300,10}})));
  Buildings.Controls.OBC.CDL.Reals.Greater gre(
    final h=THys)
    "Compare inputs"
    annotation (Placement(transformation(extent={{-240,10},{-220,30}})));
  Buildings.Controls.OBC.CDL.Logical.And sumPre
    "In Summer preferred condition"
    annotation (Placement(transformation(extent={{-180,10},{-160,30}})));
  Buildings.Controls.OBC.CDL.Logical.And higMedSum
    "High rate, medium district load, and in Summer preferred condition"
    annotation (Placement(transformation(extent={{-120,10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higLoaMod
    "Check if the district load is high"
    annotation (Placement(transformation(extent={{-260,-90},{-240,-70}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(
    final k=3)
    "HIgh district load"
    annotation (Placement(transformation(extent={{-320,-90},{-300,-70}})));
  Buildings.Controls.OBC.CDL.Logical.And higHig
    "High electricity rate and high district load"
    annotation (Placement(transformation(extent={{-180,-90},{-160,-70}})));
  Buildings.Controls.OBC.CDL.Logical.And higHigWin
    "High rate, high district load, and in Winter preferred condition"
    annotation (Placement(transformation(extent={{-120,-90},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Logical.And higHigSum
    "High rate, high district load, and in Summer preferred condition"
    annotation (Placement(transformation(extent={{-120,-130},{-100,-110}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant norRat(
    final k=0)
    "Normal electricity rate"
    annotation (Placement(transformation(extent={{-320,-160},{-300,-140}})));
  Buildings.Controls.OBC.CDL.Integers.Equal norRatMod
    "Check if it is in normal electricity rate mode"
    annotation (Placement(transformation(extent={{-280,-160},{-260,-140}})));
  Buildings.Controls.OBC.CDL.Logical.Or winOpe
    "Enable the dry cooler in Winter"
    annotation (Placement(transformation(extent={{-60,-90},{-40,-70}})));
  Buildings.Controls.OBC.CDL.Logical.Or winOpe1
    "Enable the dry cooler in Winter"
    annotation (Placement(transformation(extent={{60,60},{80,80}})));
  Buildings.Controls.OBC.CDL.Logical.Or sumOpe
    "Enable the dry cooler in Summer"
    annotation (Placement(transformation(extent={{-60,-130},{-40,-110}})));
  Buildings.Controls.OBC.CDL.Logical.Or sumOpe1
    "Enable the dry cooler in Summer"
    annotation (Placement(transformation(extent={{60,10},{80,30}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Check temperature difference"
    annotation (Placement(transformation(extent={{-280,-370},{-260,-350}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(
    final k=-1)
    "Reverse the subtract"
    annotation (Placement(transformation(extent={{180,-370},{200,-350}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(
    final k=TAppSet)
    "Dry cooler approach temperature setpoint"
    annotation (Placement(transformation(extent={{200,-270},{220,-250}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset fanCon(
    final controllerType=fanConTyp,
    final k=kFan,
    final Ti=TiFan,
    final Td=TdFan,
    final reverseActing=false,
    final y_reset=minFanSpe)
    "Dry cooler fan speed controller"
    annotation (Placement(transformation(extent={{240,-270},{260,-250}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{220,-320},{240,-300}})));
  Buildings.Controls.OBC.CDL.Logical.Or weaEna
    "Enable the dry cooler based on the weather condition"
    annotation (Placement(transformation(extent={{100,60},{120,80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo(
    final k=0)
    "Disable fan"
    annotation (Placement(transformation(extent={{240,-360},{260,-340}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooPum
    "Dry cooler pump speed setpoint"
    annotation (Placement(transformation(extent={{260,60},{280,80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo1(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{200,20},{220,40}})));
  Buildings.Controls.OBC.CDL.Logical.And norWin
    "Normal rate, in Winter preferred condition"
    annotation (Placement(transformation(extent={{-120,-160},{-100,-140}})));
  Buildings.Controls.OBC.CDL.Logical.And norSum
    "Normal rate, in Summer preferred condition"
    annotation (Placement(transformation(extent={{-120,-200},{-100,-180}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex "Enable heat exchanger"
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex1 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex3 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{-40,160},{-20,180}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex2 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHex4 "Enable heat exchanger"
    annotation (Placement(transformation(extent={{60,160},{80,180}})));
  Buildings.Controls.OBC.CDL.Reals.Switch hexPumVal
    "Heat exchanger pump and valve position setpoint"
    annotation (Placement(transformation(extent={{260,160},{280,180}})));
  Buildings.Controls.OBC.CDL.Reals.Switch hexPumByaVal
    "Heat exchanger bypass valve position setpoint"
    annotation (Placement(transformation(extent={{260,240},{280,260}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(
    final k=mDryCoo_flow_nominal)
    "Convert to the mass flow rate"
    annotation (Placement(transformation(extent={{300,60},{320,80}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mHexGly_flow_nominal)
    "Convert to the mass flow rate"
    annotation (Placement(transformation(extent={{300,160},{320,180}})));
  Buildings.Controls.OBC.CDL.Logical.And cooHeaPum
    "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{-100,-350},{-80,-330}})));
  Buildings.Controls.OBC.CDL.Logical.Not inCooMod "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{-280,-330},{-260,-310}})));
  Buildings.Controls.OBC.CDL.Logical.Or cooWat
    "Dry cooler should cooling down the water flow"
    annotation (Placement(transformation(extent={{140,-320},{160,-300}})));
  Buildings.Controls.OBC.CDL.Logical.Or ena
    "Enable the dry cooler based on weather condition, or heat pump operation"
    annotation (Placement(transformation(extent={{140,60},{160,80}})));
  Buildings.Controls.OBC.CDL.Logical.And warFal "Warm Fall"
    annotation (Placement(transformation(extent={{-180,270},{-160,290}})));
  Buildings.Controls.OBC.CDL.Logical.And colSpr "Cold spring"
    annotation (Placement(transformation(extent={{-180,340},{-160,360}})));
  Buildings.Controls.OBC.CDL.Logical.And sprWarLoo
    "In Spring and conditions are good for warm loop"
    annotation (Placement(transformation(extent={{-40,340},{-20,360}})));
  Buildings.Controls.OBC.CDL.Logical.And falCooLoo
    "In Fall and conditions are good for cool loop"
    annotation (Placement(transformation(extent={{-40,290},{-20,310}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHexSho
    "Enable heat exchanger in shoulder season"
    annotation (Placement(transformation(extent={{60,340},{80,360}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHexSho1
    "Enable heat exchanger in shoulder season"
    annotation (Placement(transformation(extent={{120,240},{140,260}})));

  Buildings.Controls.OBC.CDL.Integers.GreaterThreshold war "Warm loop"
    annotation (Placement(transformation(extent={{-100,310},{-80,330}})));
  Buildings.Controls.OBC.CDL.Integers.LessThreshold coo "Cool loop"
    annotation (Placement(transformation(extent={{-260,290},{-240,310}})));
  Buildings.Controls.OBC.CDL.Logical.Or ena1
    "Enable the dry cooler based on weather condition, or heat pump operation"
    annotation (Placement(transformation(extent={{200,60},{220,80}})));
  Buildings.Controls.OBC.CDL.Logical.Or cooWat1
    "Dry cooler should cooling down the water flow"
    annotation (Placement(transformation(extent={{100,-320},{120,-300}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooInAir
    "Dry cooler inlet air temperature"
    annotation (Placement(transformation(extent={{300,-230},{320,-210}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooInAir1
    "Dry cooler inlet air temperature"
    annotation (Placement(transformation(extent={{200,-200},{220,-180}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar2(p=TAppSet)
    annotation (Placement(transformation(extent={{40,-220},{60,-200}})));
equation
  connect(uEleRat, higRatMod.u2) annotation (Line(points={{-360,220},{-290,220},
          {-290,232},{-262,232}}, color={255,127,0}));
  connect(higRat.y, higRatMod.u1)
    annotation (Line(points={{-298,240},{-262,240}}, color={255,127,0}));
  connect(medLoa.y, medLoaMod.u1)
    annotation (Line(points={{-298,190},{-262,190}}, color={255,127,0}));
  connect(uSt, medLoaMod.u2) annotation (Line(points={{-360,170},{-280,170},{-280,
          182},{-262,182}}, color={255,127,0}));
  connect(win.y, inWin.u1)
    annotation (Line(points={{-298,140},{-242,140}}, color={255,127,0}));
  connect(uGen, inWin.u2) annotation (Line(points={{-360,120},{-270,120},{-270,132},
          {-242,132}}, color={255,127,0}));
  connect(TDryBul, addPar.u)
    annotation (Line(points={{-360,40},{-322,40}}, color={0,0,127}));
  connect(TGenIn, les.u1)
    annotation (Line(points={{-360,80},{-242,80}},   color={0,0,127}));
  connect(addPar.y, les.u2) annotation (Line(points={{-298,40},{-260,40},{-260,72},
          {-242,72}},     color={0,0,127}));
  connect(inWin.y, winPre.u1)
    annotation (Line(points={{-218,140},{-182,140}}, color={255,0,255}));
  connect(les.y, winPre.u2) annotation (Line(points={{-218,80},{-200,80},{-200,132},
          {-182,132}},      color={255,0,255}));
  connect(higRatMod.y, higMed.u1)
    annotation (Line(points={{-238,240},{-182,240}}, color={255,0,255}));
  connect(medLoaMod.y, higMed.u2) annotation (Line(points={{-238,190},{-220,190},
          {-220,232},{-182,232}}, color={255,0,255}));
  connect(winPre.y, higMedWin.u1)
    annotation (Line(points={{-158,140},{-122,140}},color={255,0,255}));
  connect(higMed.y, higMedWin.u2) annotation (Line(points={{-158,240},{-150,240},
          {-150,132},{-122,132}},color={255,0,255}));
  connect(sum.y, inSum.u1)
    annotation (Line(points={{-298,-40},{-242,-40}},
                                                   color={255,127,0}));
  connect(uGen, inSum.u2) annotation (Line(points={{-360,120},{-270,120},{-270,-48},
          {-242,-48}},
                     color={255,127,0}));
  connect(TDryBul, addPar1.u) annotation (Line(points={{-360,40},{-330,40},{-330,
          0},{-322,0}},   color={0,0,127}));
  connect(TGenIn, gre.u1) annotation (Line(points={{-360,80},{-250,80},{-250,20},
          {-242,20}}, color={0,0,127}));
  connect(addPar1.y, gre.u2) annotation (Line(points={{-298,0},{-260,0},{-260,12},
          {-242,12}},     color={0,0,127}));
  connect(gre.y, sumPre.u1)
    annotation (Line(points={{-218,20},{-182,20}}, color={255,0,255}));
  connect(inSum.y, sumPre.u2) annotation (Line(points={{-218,-40},{-210,-40},{-210,
          12},{-182,12}}, color={255,0,255}));
  connect(sumPre.y, higMedSum.u1)
    annotation (Line(points={{-158,20},{-122,20}},color={255,0,255}));
  connect(higMed.y, higMedSum.u2) annotation (Line(points={{-158,240},{-150,240},
          {-150,12},{-122,12}},color={255,0,255}));
  connect(higLoa.y, higLoaMod.u1)
    annotation (Line(points={{-298,-80},{-262,-80}}, color={255,127,0}));
  connect(uSt, higLoaMod.u2) annotation (Line(points={{-360,170},{-280,170},{-280,
          -88},{-262,-88}}, color={255,127,0}));
  connect(higLoaMod.y, higHig.u1)
    annotation (Line(points={{-238,-80},{-182,-80}}, color={255,0,255}));
  connect(higRatMod.y, higHig.u2) annotation (Line(points={{-238,240},{-190,240},
          {-190,-88},{-182,-88}}, color={255,0,255}));
  connect(higHig.y, higHigWin.u1)
    annotation (Line(points={{-158,-80},{-122,-80}},
                                                   color={255,0,255}));
  connect(norRat.y, norRatMod.u1)
    annotation (Line(points={{-298,-150},{-282,-150}}, color={255,127,0}));
  connect(uEleRat, norRatMod.u2) annotation (Line(points={{-360,220},{-290,220},
          {-290,-158},{-282,-158}}, color={255,127,0}));
  connect(higMedWin.y, winOpe1.u1)
    annotation (Line(points={{-98,140},{-90,140},{-90,70},{58,70}},   color={255,0,255}));
  connect(winOpe.y, winOpe1.u2) annotation (Line(points={{-38,-80},{30,-80},{30,
          62},{58,62}},
                     color={255,0,255}));
  connect(higMedSum.y, sumOpe1.u1)
    annotation (Line(points={{-98,20},{58,20}}, color={255,0,255}));
  connect(sumOpe.y, sumOpe1.u2) annotation (Line(points={{-38,-120},{40,-120},{40,
          12},{58,12}},
                    color={255,0,255}));
  connect(TDryCooOut, sub.u1) annotation (Line(points={{-360,-350},{-300,-350},{
          -300,-354},{-282,-354}}, color={0,0,127}));
  connect(TDryBul, sub.u2) annotation (Line(points={{-360,40},{-330,40},{-330,-366},
          {-282,-366}}, color={0,0,127}));
  connect(sub.y, gai.u) annotation (Line(points={{-258,-360},{178,-360}},
                        color={0,0,127}));
  connect(sub.y, swi1.u1) annotation (Line(points={{-258,-360},{170,-360},{170,-302},
          {218,-302}}, color={0,0,127}));
  connect(gai.y, swi1.u3) annotation (Line(points={{202,-360},{210,-360},{210,-318},
          {218,-318}}, color={0,0,127}));
  connect(con1.y, fanCon.u_s)
    annotation (Line(points={{222,-260},{238,-260}}, color={0,0,127}));
  connect(swi1.y, fanCon.u_m) annotation (Line(points={{242,-310},{250,-310},{250,
          -272}}, color={0,0,127}));
  connect(winOpe1.y, weaEna.u1)
    annotation (Line(points={{82,70},{98,70}},     color={255,0,255}));
  connect(sumOpe1.y, weaEna.u2) annotation (Line(points={{82,20},{90,20},{90,62},
          {98,62}},        color={255,0,255}));
  connect(fanCon.y, dryCooFan.u1) annotation (Line(points={{262,-260},{280,-260},
          {280,-272},{298,-272}}, color={0,0,127}));
  connect(zeo.y, dryCooFan.u3) annotation (Line(points={{262,-350},{280,-350},{280,
          -288},{298,-288}}, color={0,0,127}));
  connect(con.y, dryCooPum.u1) annotation (Line(points={{222,130},{240,130},{240,
          78},{258,78}},   color={0,0,127}));
  connect(zeo1.y, dryCooPum.u3) annotation (Line(points={{222,30},{250,30},{250,
          62},{258,62}},   color={0,0,127}));
  connect(dryCooFan.y, yDryCoo)
    annotation (Line(points={{322,-280},{360,-280}}, color={0,0,127}));
  connect(norRatMod.y, norWin.u1)
    annotation (Line(points={{-258,-150},{-122,-150}},color={255,0,255}));
  connect(norRatMod.y, norSum.u1) annotation (Line(points={{-258,-150},{-220,-150},
          {-220,-190},{-122,-190}},color={255,0,255}));
  connect(winPre.y, norWin.u2) annotation (Line(points={{-158,140},{-140,140},{-140,
          -158},{-122,-158}},color={255,0,255}));
  connect(sumPre.y, norSum.u2) annotation (Line(points={{-158,20},{-130,20},{-130,
          -198},{-122,-198}},color={255,0,255}));
  connect(higHig.y, higHigSum.u1) annotation (Line(points={{-158,-80},{-150,-80},
          {-150,-120},{-122,-120}},
                                 color={255,0,255}));
  connect(winPre.y, higHigWin.u2) annotation (Line(points={{-158,140},{-140,140},
          {-140,-88},{-122,-88}},color={255,0,255}));
  connect(sumPre.y, higHigSum.u2) annotation (Line(points={{-158,20},{-130,20},{
          -130,-128},{-122,-128}},
                           color={255,0,255}));
  connect(norSum.y, enaHex.u2) annotation (Line(points={{-98,-190},{-68,-190},{-68,
          -38},{-62,-38}},
                        color={255,0,255}));
  connect(norWin.y, enaHex.u1) annotation (Line(points={{-98,-150},{-76,-150},{-76,
          -30},{-62,-30}},
                        color={255,0,255}));
  connect(higHigSum.y, enaHex1.u2) annotation (Line(points={{-98,-120},{-84,-120},
          {-84,-8},{-62,-8}},color={255,0,255}));
  connect(higHigWin.y, enaHex1.u1) annotation (Line(points={{-98,-80},{-92,-80},
          {-92,0},{-62,0}},  color={255,0,255}));
  connect(higMedSum.y, enaHex3.u2) annotation (Line(points={{-98,20},{-80,20},{-80,
          162},{-42,162}},color={255,0,255}));
  connect(higMedWin.y, enaHex3.u1) annotation (Line(points={{-98,140},{-90,140},
          {-90,170},{-42,170}},color={255,0,255}));
  connect(enaHex1.y, enaHex2.u1)
    annotation (Line(points={{-38,0},{-22,0}}, color={255,0,255}));
  connect(enaHex.y, enaHex2.u2) annotation (Line(points={{-38,-30},{-30,-30},{-30,
          -8},{-22,-8}},
                    color={255,0,255}));
  connect(enaHex3.y, enaHex4.u1)
    annotation (Line(points={{-18,170},{58,170}},color={255,0,255}));
  connect(enaHex2.y, enaHex4.u2) annotation (Line(points={{2,0},{20,0},{20,162},
          {58,162}}, color={255,0,255}));
  connect(con.y, hexPumVal.u1) annotation (Line(points={{222,130},{240,130},{240,
          178},{258,178}}, color={0,0,127}));
  connect(zeo1.y, hexPumVal.u3) annotation (Line(points={{222,30},{250,30},{250,
          162},{258,162}}, color={0,0,127}));
  connect(zeo1.y, hexPumByaVal.u1) annotation (Line(points={{222,30},{250,30},{250,
          258},{258,258}}, color={0,0,127}));
  connect(con.y, hexPumByaVal.u3) annotation (Line(points={{222,130},{240,130},{
          240,242},{258,242}}, color={0,0,127}));
  connect(hexPumVal.y, yValHex) annotation (Line(points={{282,170},{290,170},{290,
          210},{360,210}}, color={0,0,127}));
  connect(hexPumByaVal.y, yValHexByp)
    annotation (Line(points={{282,250},{360,250}}, color={0,0,127}));
  connect(dryCooPum.y, gai1.u)
    annotation (Line(points={{282,70},{298,70}},   color={0,0,127}));
  connect(gai1.y, yPumDryCoo)
    annotation (Line(points={{322,70},{360,70}},   color={0,0,127}));
  connect(hexPumVal.y, gai2.u)
    annotation (Line(points={{282,170},{298,170}}, color={0,0,127}));
  connect(gai2.y, yPumHex)
    annotation (Line(points={{322,170},{360,170}}, color={0,0,127}));
  connect(higHigWin.y, winOpe.u1)
    annotation (Line(points={{-98,-80},{-62,-80}}, color={255,0,255}));
  connect(higHigSum.y, sumOpe.u1)
    annotation (Line(points={{-98,-120},{-62,-120}},
                                                   color={255,0,255}));
  connect(norWin.y, winOpe.u2) annotation (Line(points={{-98,-150},{-76,-150},{-76,
          -88},{-62,-88}}, color={255,0,255}));
  connect(norSum.y, sumOpe.u2) annotation (Line(points={{-98,-190},{-68,-190},{-68,
          -128},{-62,-128}},
                           color={255,0,255}));
  connect(u1HeaPumMod, inCooMod.u)
    annotation (Line(points={{-360,-320},{-282,-320}}, color={255,0,255}));
  connect(inCooMod.y, cooHeaPum.u2) annotation (Line(points={{-258,-320},{-220,-320},
          {-220,-348},{-102,-348}},color={255,0,255}));
  connect(u1HeaPum, cooHeaPum.u1) annotation (Line(points={{-360,-280},{-180,-280},
          {-180,-340},{-102,-340}},color={255,0,255}));
  connect(cooWat.y, swi1.u2)
    annotation (Line(points={{162,-310},{218,-310}}, color={255,0,255}));
  connect(weaEna.y, ena.u1)
    annotation (Line(points={{122,70},{138,70}},   color={255,0,255}));
  connect(u1HeaPum, ena.u2) annotation (Line(points={{-360,-280},{130,-280},{130,
          62},{138,62}},   color={255,0,255}));
  connect(gre.y, colSpr.u2) annotation (Line(points={{-218,20},{-210,20},{-210,342},
          {-182,342}}, color={255,0,255}));
  connect(les.y, warFal.u2) annotation (Line(points={{-218,80},{-200,80},{-200,272},
          {-182,272}}, color={255,0,255}));
  connect(colSpr.y, sprWarLoo.u1)
    annotation (Line(points={{-158,350},{-42,350}}, color={255,0,255}));
  connect(enaHexSho1.y, hexPumByaVal.u2)
    annotation (Line(points={{142,250},{258,250}}, color={255,0,255}));
  connect(enaHexSho1.y, hexPumVal.u2) annotation (Line(points={{142,250},{180,250},
          {180,170},{258,170}}, color={255,0,255}));
  connect(enaHexSho.y, enaHexSho1.u1) annotation (Line(points={{82,350},{100,350},
          {100,250},{118,250}}, color={255,0,255}));
  connect(enaHex4.y, enaHexSho1.u2) annotation (Line(points={{82,170},{100,170},
          {100,242},{118,242}}, color={255,0,255}));
  connect(u1Spr, colSpr.u1) annotation (Line(points={{-360,350},{-182,350}},
                            color={255,0,255}));
  connect(u1Fal, warFal.u1) annotation (Line(points={{-360,280},{-182,280}},
                 color={255,0,255}));
  connect(sprWarLoo.y, enaHexSho.u1)
    annotation (Line(points={{-18,350},{58,350}}, color={255,0,255}));
  connect(falCooLoo.y, enaHexSho.u2) annotation (Line(points={{-18,300},{40,300},
          {40,342},{58,342}},color={255,0,255}));
  connect(uLooHea, war.u)
    annotation (Line(points={{-360,320},{-102,320}},color={255,127,0}));
  connect(war.y, sprWarLoo.u2) annotation (Line(points={{-78,320},{-60,320},{-60,
          342},{-42,342}},     color={255,0,255}));
  connect(uLooHea, coo.u) annotation (Line(points={{-360,320},{-280,320},{-280,300},
          {-262,300}},      color={255,127,0}));
  connect(coo.y, falCooLoo.u1)
    annotation (Line(points={{-238,300},{-42,300}}, color={255,0,255}));
  connect(warFal.y, falCooLoo.u2) annotation (Line(points={{-158,280},{-60,280},
          {-60,292},{-42,292}}, color={255,0,255}));
  connect(enaHexSho1.y, ena1.u2) annotation (Line(points={{142,250},{180,250},{180,
          62},{198,62}}, color={255,0,255}));
  connect(ena.y, ena1.u1)
    annotation (Line(points={{162,70},{198,70}}, color={255,0,255}));
  connect(ena1.y, dryCooPum.u2)
    annotation (Line(points={{222,70},{258,70}}, color={255,0,255}));
  connect(ena1.y, fanCon.trigger) annotation (Line(points={{222,70},{230,70},{230,
          -280},{244,-280},{244,-272}}, color={255,0,255}));
  connect(ena1.y, dryCooFan.u2) annotation (Line(points={{222,70},{230,70},{230,
          -280},{298,-280}}, color={255,0,255}));
  connect(sumOpe1.y, cooWat1.u1) annotation (Line(points={{82,20},{90,20},{90,-310},
          {98,-310}}, color={255,0,255}));
  connect(sprWarLoo.y, cooWat1.u2) annotation (Line(points={{-18,350},{10,350},{
          10,-318},{98,-318}}, color={255,0,255}));
  connect(cooWat1.y, cooWat.u1)
    annotation (Line(points={{122,-310},{138,-310}}, color={255,0,255}));
  connect(cooHeaPum.y, cooWat.u2) annotation (Line(points={{-78,-340},{130,-340},
          {130,-318},{138,-318}}, color={255,0,255}));
  connect(dryCooInAir.y, TAirDryCooIn)
    annotation (Line(points={{322,-220},{360,-220}}, color={0,0,127}));
  connect(ena1.y, dryCooInAir.u2) annotation (Line(points={{222,70},{230,70},{230,
          -220},{298,-220}}, color={255,0,255}));
  connect(TDryBul, dryCooInAir.u3) annotation (Line(points={{-360,40},{-330,40},
          {-330,-228},{298,-228}}, color={0,0,127}));
  connect(cooWat.y, dryCooInAir1.u2) annotation (Line(points={{162,-310},{180,
          -310},{180,-190},{198,-190}},
                                  color={255,0,255}));
  connect(dryCooInAir1.y, dryCooInAir.u1) annotation (Line(points={{222,-190},{
          280,-190},{280,-212},{298,-212}},
                                        color={0,0,127}));
  connect(TDryBul, dryCooInAir1.u1) annotation (Line(points={{-360,40},{-330,40},
          {-330,-170},{180,-170},{180,-182},{198,-182}}, color={0,0,127}));
  connect(TDryBul, addPar2.u) annotation (Line(points={{-360,40},{-330,40},{
          -330,-210},{38,-210}}, color={0,0,127}));
  connect(addPar2.y, dryCooInAir1.u3) annotation (Line(points={{62,-210},{160,
          -210},{160,-198},{198,-198}}, color={0,0,127}));
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
          extent={{58,-78},{96,-98}},
          textColor={0,0,127},
          textString="yDryCoo"),
        Text(
          extent={{38,-10},{100,-28}},
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
          textColor={255,127,0},
          textString="uLooHea"),
        Text(
          extent={{-96,70},{-70,52}},
          textColor={255,0,255},
          textString="u1Fal"),
        Text(
          extent={{-96,104},{-66,86}},
          textColor={255,0,255},
          textString="u1Spr"),
        Text(
          extent={{36,-50},{98,-68}},
          textColor={0,0,127},
          textString="TAirDryCooIn")}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-340,-380},{340,380}})),
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
<td>1 (Winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut = TDryBul+TAppSet</code></td>
</tr>
<tr>
<td>1 (high)</td>
<td>2 (medium)</td>
<td>3 (Summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut = TDryBul-TAppSet</code></td>
</tr>
<tr>
<td>1 (high)</td>
<td>3 (high)</td>
<td>1 (Winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code>, or, <code>uHeaPum=true</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut = TDryBul+TAppSet</code></td>
</tr>
<tr>
<td>1 (high)</td>
<td>3 (high)</td>
<td>3 (Summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code>, or, <code>uHeaPum=true</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut = TDryBul-TAppSet</code></td>
</tr>
<tr>
<td>0 (normal)</td>
<td>x</td>
<td>1 (Winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code>, or, <code>uHeaPum=true</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut = TDryBul+TAppSet</code></td>
</tr>
<tr>
<td>0 (normal)</td>
<td>x</td>
<td>3 (Summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code>, or, <code>uHeaPum=true</code></td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut = TDryBul-TAppSet</code></td>
</tr>

<tr>
<td>x</td>
<td>x</td>
<td>2 (Spring)</td>
<td><code>yValHex=1</code> (warm loop in cold Spring)</td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut = TDryBul-TAppSet</code></td>
</tr>

<tr>
<td>x</td>
<td>x</td>
<td>2 (Fall)</td>
<td><code>yValHex=1</code> (cold loop in warm Fall)</td>
<td>1 (full speed)</td>
<td>track <code>TDryCooOut = TDryBul+TAppSet</code></td>
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
<td>1 (Winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
<tr>
<td>1 (high)</td>
<td>2 (medium)</td>
<td>3 (Summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
<tr>
<td>1 (high)</td>
<td>3 (high)</td>
<td>1 (Winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
<tr>
<td>1 (high)</td>
<td>3 (high)</td>
<td>3 (Summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
<tr>
<td>0 (normal)</td>
<td>x</td>
<td>1 (Winter)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code></td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>
<tr>
<td>0 (normal)</td>
<td>x</td>
<td>3 (Summer)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code> </td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>

<td>x</td>
<td>x</td>
<td>2 (Spring)</td>
<td><code>TGenIn &gt; TDryBul+TApp</code> and <code>uLooHea = 1</code> (warm loop in cold Spring)</td>
<td>1 (full speed)</td>
<td>1 (fully open)</td>
<td>0 (fully close)</td>
</tr>

<td>x</td>
<td>x</td>
<td>2 (Fall)</td>
<td><code>TGenIn &lt; TDryBul-TApp</code> and <code>uLooHea = -1</code> (cold loop in warm Fall)</td>
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
