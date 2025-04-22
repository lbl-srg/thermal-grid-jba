within ThermalGridJBA.Networks.Controls;
block DryCooler "Dry cooler and the associated pump control"

  parameter Real mDryCoo_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal glycol mass flow rate for dry cooler";
  parameter Real TAppSet(
    final quantity="TemperatureDifference",
    final unit="K")=2
    "Dry cooler approach setpoint";
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
    annotation (Placement(transformation(extent={{-360,300},{-320,340}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "Plant load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-360,260},{-320,300}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSea
    "Season indicator. 1-Winter; 2-Spring; 3-Summer; 4-Fall"
    annotation (Placement(transformation(extent={{-360,220},{-320,260}}),
        iconTransformation(extent={{-140,30},{-100,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TPlaIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water into the central plant"
    annotation (Placement(transformation(extent={{-360,160},{-320,200}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-360,120},{-320,160}}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPum
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{-360,-220},{-320,-180}}),
        iconTransformation(extent={{-140,-50},{-100,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPumMod
    "Heat pump mode: true - heating mode"
    annotation (Placement(transformation(extent={{-360,-290},{-320,-250}}),
        iconTransformation(extent={{-140,-70},{-100,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryCooOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Dry cooler outlet glycol temperature"
    annotation (Placement(transformation(extent={{-360,-360},{-320,-320}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAirDryCooIn(
    final unit="K",
    displayUnit="degC")
    "Dry cooler air temperature input"
    annotation (Placement(transformation(extent={{320,-150},{360,-110}}),
        iconTransformation(extent={{100,40},{140,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumDryCoo(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint of the pump for the dry cooler"
    annotation (Placement(transformation(extent={{320,-240},{360,-200}}),
      iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDryCoo(
    final min=0,
    final max=1,
    final unit="1")
    "Speed setpoint of the dry cooler fan"
    annotation (Placement(transformation(extent={{320,-340},{360,-300}}),
        iconTransformation(extent={{100,-80},{140,-40}})));

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant medLoa(final k=2)
    "Medium plant load"
    annotation (Placement(transformation(extent={{-200,390},{-180,410}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High plant load"
    annotation (Placement(transformation(extent={{-200,350},{-180,370}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-300,390},{-280,410}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(final k=1) "Winter"
    annotation (Placement(transformation(extent={{-80,390},{-60,410}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum(final k=3) "Summer"
    annotation (Placement(transformation(extent={{-80,350},{-60,370}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higEleRat "High electricity rate"
    annotation (Placement(transformation(extent={{-240,310},{-220,330}})));
  Buildings.Controls.OBC.CDL.Integers.Equal medPlaLoa "Medium plant load"
    annotation (Placement(transformation(extent={{-140,310},{-120,330}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higPlaLoa "High plant load"
    annotation (Placement(transformation(extent={{-140,280},{-120,300}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin "In Winter"
    annotation (Placement(transformation(extent={{-20,310},{0,330}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum "In Summer"
    annotation (Placement(transformation(extent={{-20,280},{0,300}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooPum
    "Dry cooler pump speed setpoint"
    annotation (Placement(transformation(extent={{280,-230},{300,-210}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(final k=0) "Zero"
    annotation (Placement(transformation(extent={{240,-260},{260,-240}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatMedLoa
    "High rate and medium plant load"
    annotation (Placement(transformation(extent={{-60,190},{-40,210}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatMedLoaWin
    "High rate and medium plant load, in Winter"
    annotation (Placement(transformation(extent={{40,190},{60,210}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(
    final p=-TApp)
    annotation (Placement(transformation(extent={{-300,130},{-280,150}})));
  Buildings.Controls.OBC.CDL.Reals.Less warAmb(
    final h=THys) "Warm ambient"
    annotation (Placement(transformation(extent={{-240,170},{-220,190}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(
    final p=TApp)
    annotation (Placement(transformation(extent={{-300,90},{-280,110}})));
  Buildings.Controls.OBC.CDL.Reals.Greater colAmb(
    final h=THys) "Cold ambient"
    annotation (Placement(transformation(extent={{-240,110},{-220,130}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatMedLoaWin1
    "High rate and medium plant load, in Winter"
    annotation (Placement(transformation(extent={{80,190},{100,210}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(
    final k=mDryCoo_flow_nominal) "Dry cooler nomimal flow rate"
    annotation (Placement(transformation(extent={{240,-200},{260,-180}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatMedLoaSum
    "High rate and medium plant load, in Summer"
    annotation (Placement(transformation(extent={{40,140},{60,160}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatMedLoaSum1
    "High rate and medium plant load, in Summer"
    annotation (Placement(transformation(extent={{80,140},{100,160}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatHigLoa
    "High rate and high plant load"
    annotation (Placement(transformation(extent={{-20,90},{0,110}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatHigLoaWar
    "High rate and high plant load, warm ambient"
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatHigLoaCol
    "High rate and high plant load, cold ambient"
    annotation (Placement(transformation(extent={{80,40},{100,60}})));
  Buildings.Controls.OBC.CDL.Logical.Not norRat "Normal rate"
    annotation (Placement(transformation(extent={{-140,10},{-120,30}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatWin "Normal rate in Winter"
    annotation (Placement(transformation(extent={{40,10},{60,30}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatWinWar
    "Normal rate in Winter, warm ambient"
    annotation (Placement(transformation(extent={{80,-10},{100,10}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSum "Normal rate in Summer"
    annotation (Placement(transformation(extent={{40,-40},{60,-20}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSumCol
    "Normal rate in Summer, cold ambient"
    annotation (Placement(transformation(extent={{80,-60},{100,-40}})));
  Buildings.Controls.OBC.CDL.Logical.Or cooDryCoo "Dry cooler for cooling"
    annotation (Placement(transformation(extent={{160,140},{180,160}})));
  Buildings.Controls.OBC.CDL.Logical.Or cooDryCoo1 "Dry cooler for cooling"
    annotation (Placement(transformation(extent={{200,120},{220,140}})));
  Buildings.Controls.OBC.CDL.Logical.Or heaDryCoo "Dry cooler for heating"
    annotation (Placement(transformation(extent={{160,80},{180,100}})));
  Buildings.Controls.OBC.CDL.Logical.Or heaDryCoo1 "Dry cooler for heating"
    annotation (Placement(transformation(extent={{200,60},{220,80}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaDryCoo "Enable dry cooler"
    annotation (Placement(transformation(extent={{260,120},{280,140}})));
  Buildings.Controls.OBC.CDL.Logical.And heaPumCoo
    "Heat pump enabled in cooling mode"
    annotation (Placement(transformation(extent={{-180,-280},{-160,-260}})));
  Buildings.Controls.OBC.CDL.Logical.Not notHea "Not in heating mode"
    annotation (Placement(transformation(extent={{-240,-280},{-220,-260}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con2(final k=TAppSet)
    "Dry cooler approach temperature setpoint"
    annotation (Placement(transformation(extent={{140,-300},{160,-280}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset fanCon(
    final controllerType=fanConTyp,
    final k=kFan,
    final Ti=TiFan,
    final Td=TdFan,
    final reverseActing=false,
    final y_reset=minFanSpe)
    "Dry cooler fan speed controller"
    annotation (Placement(transformation(extent={{220,-300},{240,-280}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooFan
    "Dry cooler fan speed setpoint"
    annotation (Placement(transformation(extent={{280,-330},{300,-310}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo(final k=0)
    "Disable fan"
    annotation (Placement(transformation(extent={{220,-370},{240,-350}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaDryCoo1 "Enable dry cooler"
    annotation (Placement(transformation(extent={{180,-230},{200,-210}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{180,-350},{200,-330}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(final k=-1)
    "Reverse the subtract"
    annotation (Placement(transformation(extent={{120,-390},{140,-370}})));
  Buildings.Controls.OBC.CDL.Logical.Or cooWat
    "Dry cooler should cooling down the water flow"
    annotation (Placement(transformation(extent={{20,-350},{40,-330}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Check temperature difference"
    annotation (Placement(transformation(extent={{-260,-390},{-240,-370}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter heaShi(
    final p=-TAppSet)
    "Temperature shift when the dry cooler should heat up the fluid"
    annotation (Placement(transformation(extent={{-100,-190},{-80,-170}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter cooShi(
    final p=TAppSet)
    "Temperature shift when the dry cooler should cool down the fluid"
    annotation (Placement(transformation(extent={{-100,-110},{-80,-90}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooInAir1
    "Dry cooler inlet air temperature"
    annotation (Placement(transformation(extent={{180,-110},{200,-90}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooInAir
    "Dry cooler inlet air temperature"
    annotation (Placement(transformation(extent={{260,-140},{280,-120}})));

equation
  connect(uEleRat, higEleRat.u1)
    annotation (Line(points={{-340,320},{-242,320}}, color={255,127,0}));
  connect(higRat.y, higEleRat.u2) annotation (Line(points={{-278,400},{-260,400},
          {-260,312},{-242,312}}, color={255,127,0}));
  connect(medLoa.y, medPlaLoa.u1) annotation (Line(points={{-178,400},{-160,400},
          {-160,320},{-142,320}}, color={255,127,0}));
  connect(higLoa.y, higPlaLoa.u1) annotation (Line(points={{-178,360},{-170,360},
          {-170,290},{-142,290}}, color={255,127,0}));
  connect(uSt, medPlaLoa.u2) annotation (Line(points={{-340,280},{-180,280},{-180,
          312},{-142,312}}, color={255,127,0}));
  connect(uSt, higPlaLoa.u2) annotation (Line(points={{-340,280},{-180,280},{-180,
          282},{-142,282}}, color={255,127,0}));
  connect(uSea, inWin.u2) annotation (Line(points={{-340,240},{-50,240},{-50,312},
          {-22,312}}, color={255,127,0}));
  connect(uSea, inSum.u2) annotation (Line(points={{-340,240},{-50,240},{-50,282},
          {-22,282}}, color={255,127,0}));
  connect(win.y, inWin.u1) annotation (Line(points={{-58,400},{-30,400},{-30,320},
          {-22,320}}, color={255,127,0}));
  connect(sum.y, inSum.u1) annotation (Line(points={{-58,360},{-40,360},{-40,290},
          {-22,290}}, color={255,127,0}));
  connect(dryCooPum.y, yPumDryCoo)
    annotation (Line(points={{302,-220},{340,-220}}, color={0,0,127}));
  connect(higEleRat.y, higRatMedLoa.u2) annotation (Line(points={{-218,320},{-190,
          320},{-190,192},{-62,192}}, color={255,0,255}));
  connect(medPlaLoa.y, higRatMedLoa.u1) annotation (Line(points={{-118,320},{-80,
          320},{-80,200},{-62,200}}, color={255,0,255}));
  connect(higRatMedLoa.y, higRatMedLoaWin.u1)
    annotation (Line(points={{-38,200},{38,200}}, color={255,0,255}));
  connect(inWin.y, higRatMedLoaWin.u2) annotation (Line(points={{2,320},{30,320},
          {30,192},{38,192}}, color={255,0,255}));
  connect(TPlaIn, warAmb.u1)
    annotation (Line(points={{-340,180},{-242,180}}, color={0,0,127}));
  connect(addPar.y, warAmb.u2) annotation (Line(points={{-278,140},{-260,140},{-260,
          172},{-242,172}}, color={0,0,127}));
  connect(TDryBul, addPar.u)
    annotation (Line(points={{-340,140},{-302,140}}, color={0,0,127}));
  connect(TDryBul, addPar1.u) annotation (Line(points={{-340,140},{-310,140},{-310,
          100},{-302,100}}, color={0,0,127}));
  connect(TPlaIn, colAmb.u1) annotation (Line(points={{-340,180},{-270,180},{-270,
          120},{-242,120}}, color={0,0,127}));
  connect(addPar1.y, colAmb.u2) annotation (Line(points={{-278,100},{-260,100},{
          -260,112},{-242,112}}, color={0,0,127}));
  connect(higRatMedLoaWin.y, higRatMedLoaWin1.u1)
    annotation (Line(points={{62,200},{78,200}}, color={255,0,255}));
  connect(warAmb.y, higRatMedLoaWin1.u2) annotation (Line(points={{-218,180},{70,
          180},{70,192},{78,192}}, color={255,0,255}));
  connect(higRatMedLoa.y, higRatMedLoaSum.u2) annotation (Line(points={{-38,200},
          {0,200},{0,142},{38,142}}, color={255,0,255}));
  connect(inSum.y, higRatMedLoaSum.u1) annotation (Line(points={{2,290},{20,290},
          {20,150},{38,150}}, color={255,0,255}));
  connect(higRatMedLoaSum.y, higRatMedLoaSum1.u1)
    annotation (Line(points={{62,150},{78,150}}, color={255,0,255}));
  connect(colAmb.y, higRatMedLoaSum1.u2) annotation (Line(points={{-218,120},{70,
          120},{70,142},{78,142}}, color={255,0,255}));
  connect(higEleRat.y, higRatHigLoa.u2) annotation (Line(points={{-218,320},{-190,
          320},{-190,92},{-22,92}}, color={255,0,255}));
  connect(higPlaLoa.y, higRatHigLoa.u1) annotation (Line(points={{-118,290},{-90,
          290},{-90,100},{-22,100}}, color={255,0,255}));
  connect(higRatHigLoa.y, higRatHigLoaWar.u1) annotation (Line(points={{2,100},{
          40,100},{40,90},{78,90}}, color={255,0,255}));
  connect(warAmb.y, higRatHigLoaWar.u2) annotation (Line(points={{-218,180},{-200,
          180},{-200,82},{78,82}}, color={255,0,255}));
  connect(colAmb.y, higRatHigLoaCol.u2) annotation (Line(points={{-218,120},{-210,
          120},{-210,42},{78,42}}, color={255,0,255}));
  connect(higRatHigLoa.y, higRatHigLoaCol.u1) annotation (Line(points={{2,100},{
          40,100},{40,50},{78,50}}, color={255,0,255}));
  connect(higEleRat.y, norRat.u) annotation (Line(points={{-218,320},{-190,320},
          {-190,20},{-142,20}}, color={255,0,255}));
  connect(norRat.y, norRatWin.u1)
    annotation (Line(points={{-118,20},{38,20}}, color={255,0,255}));
  connect(inWin.y, norRatWin.u2) annotation (Line(points={{2,320},{30,320},{30,12},
          {38,12}}, color={255,0,255}));
  connect(norRatWin.y, norRatWinWar.u1) annotation (Line(points={{62,20},{70,20},
          {70,0},{78,0}}, color={255,0,255}));
  connect(warAmb.y, norRatWinWar.u2) annotation (Line(points={{-218,180},{-200,180},
          {-200,-8},{78,-8}}, color={255,0,255}));
  connect(norRat.y, norRatSum.u1) annotation (Line(points={{-118,20},{0,20},{0,-30},
          {38,-30}}, color={255,0,255}));
  connect(inSum.y, norRatSum.u2) annotation (Line(points={{2,290},{20,290},{20,-38},
          {38,-38}}, color={255,0,255}));
  connect(norRatSum.y, norRatSumCol.u1) annotation (Line(points={{62,-30},{70,-30},
          {70,-50},{78,-50}}, color={255,0,255}));
  connect(colAmb.y, norRatSumCol.u2) annotation (Line(points={{-218,120},{-210,120},
          {-210,-58},{78,-58}}, color={255,0,255}));
  connect(higRatMedLoaSum1.y, cooDryCoo.u1)
    annotation (Line(points={{102,150},{158,150}}, color={255,0,255}));
  connect(higRatHigLoaCol.y, cooDryCoo.u2) annotation (Line(points={{102,50},{130,
          50},{130,142},{158,142}}, color={255,0,255}));
  connect(cooDryCoo.y, cooDryCoo1.u1) annotation (Line(points={{182,150},{190,150},
          {190,130},{198,130}}, color={255,0,255}));
  connect(norRatSumCol.y, cooDryCoo1.u2) annotation (Line(points={{102,-50},{140,
          -50},{140,122},{198,122}}, color={255,0,255}));
  connect(higRatHigLoaWar.y, heaDryCoo.u1)
    annotation (Line(points={{102,90},{158,90}}, color={255,0,255}));
  connect(higRatMedLoaWin1.y, heaDryCoo.u2) annotation (Line(points={{102,200},{
          120,200},{120,82},{158,82}}, color={255,0,255}));
  connect(heaDryCoo.y, heaDryCoo1.u1) annotation (Line(points={{182,90},{190,90},
          {190,70},{198,70}}, color={255,0,255}));
  connect(norRatWinWar.y, heaDryCoo1.u2) annotation (Line(points={{102,0},{190,0},
          {190,62},{198,62}}, color={255,0,255}));
  connect(cooDryCoo1.y, enaDryCoo.u1)
    annotation (Line(points={{222,130},{258,130}}, color={255,0,255}));
  connect(heaDryCoo1.y, enaDryCoo.u2) annotation (Line(points={{222,70},{240,70},
          {240,122},{258,122}}, color={255,0,255}));
  connect(con1.y, dryCooPum.u1) annotation (Line(points={{262,-190},{270,-190},{
          270,-212},{278,-212}}, color={0,0,127}));
  connect(con.y, dryCooPum.u3) annotation (Line(points={{262,-250},{270,-250},{270,
          -228},{278,-228}}, color={0,0,127}));
  connect(u1HeaPumMod, notHea.u)
    annotation (Line(points={{-340,-270},{-242,-270}}, color={255,0,255}));
  connect(notHea.y, heaPumCoo.u1)
    annotation (Line(points={{-218,-270},{-182,-270}}, color={255,0,255}));
  connect(u1HeaPum, heaPumCoo.u2) annotation (Line(points={{-340,-200},{-200,-200},
          {-200,-278},{-182,-278}}, color={255,0,255}));
  connect(u1HeaPum, enaDryCoo1.u1) annotation (Line(points={{-340,-200},{-200,-200},
          {-200,-220},{178,-220}}, color={255,0,255}));
  connect(enaDryCoo.y, enaDryCoo1.u2) annotation (Line(points={{282,130},{300,130},
          {300,-160},{160,-160},{160,-228},{178,-228}}, color={255,0,255}));
  connect(enaDryCoo1.y, dryCooPum.u2)
    annotation (Line(points={{202,-220},{278,-220}}, color={255,0,255}));
  connect(dryCooFan.y, yDryCoo)
    annotation (Line(points={{302,-320},{340,-320}}, color={0,0,127}));
  connect(con2.y, fanCon.u_s)
    annotation (Line(points={{162,-290},{218,-290}}, color={0,0,127}));
  connect(fanCon.y, dryCooFan.u1) annotation (Line(points={{242,-290},{260,-290},
          {260,-312},{278,-312}}, color={0,0,127}));
  connect(enaDryCoo1.y, dryCooFan.u2) annotation (Line(points={{202,-220},{210,-220},
          {210,-320},{278,-320}}, color={255,0,255}));
  connect(zeo.y, dryCooFan.u3) annotation (Line(points={{242,-360},{260,-360},{260,
          -328},{278,-328}}, color={0,0,127}));
  connect(enaDryCoo1.y, fanCon.trigger) annotation (Line(points={{202,-220},{210,
          -220},{210,-320},{224,-320},{224,-302}}, color={255,0,255}));
  connect(heaPumCoo.y, cooWat.u2) annotation (Line(points={{-158,-270},{-80,-270},
          {-80,-348},{18,-348}}, color={255,0,255}));
  connect(cooDryCoo1.y, cooWat.u1) annotation (Line(points={{222,130},{230,130},
          {230,-80},{-20,-80},{-20,-340},{18,-340}}, color={255,0,255}));
  connect(cooWat.y, swi1.u2)
    annotation (Line(points={{42,-340},{178,-340}}, color={255,0,255}));
  connect(TDryCooOut, sub.u1) annotation (Line(points={{-340,-340},{-280,-340},{
          -280,-374},{-262,-374}}, color={0,0,127}));
  connect(TDryBul, sub.u2) annotation (Line(points={{-340,140},{-310,140},{-310,
          -386},{-262,-386}}, color={0,0,127}));
  connect(sub.y, gai.u)
    annotation (Line(points={{-238,-380},{118,-380}}, color={0,0,127}));
  connect(sub.y, swi1.u1) annotation (Line(points={{-238,-380},{100,-380},{100,-332},
          {178,-332}}, color={0,0,127}));
  connect(gai.y, swi1.u3) annotation (Line(points={{142,-380},{160,-380},{160,-348},
          {178,-348}}, color={0,0,127}));
  connect(swi1.y, fanCon.u_m) annotation (Line(points={{202,-340},{230,-340},{230,
          -302}}, color={0,0,127}));
  connect(TDryBul, cooShi.u) annotation (Line(points={{-340,140},{-310,140},{-310,
          -100},{-102,-100}}, color={0,0,127}));
  connect(TDryBul, heaShi.u) annotation (Line(points={{-340,140},{-310,140},{-310,
          -180},{-102,-180}}, color={0,0,127}));
  connect(cooWat.y, dryCooInAir1.u2) annotation (Line(points={{42,-340},{80,-340},
          {80,-100},{178,-100}}, color={255,0,255}));
  connect(cooShi.y, dryCooInAir1.u1) annotation (Line(points={{-78,-100},{60,-100},
          {60,-92},{178,-92}}, color={0,0,127}));
  connect(heaShi.y, dryCooInAir1.u3) annotation (Line(points={{-78,-180},{100,-180},
          {100,-108},{178,-108}}, color={0,0,127}));
  connect(enaDryCoo1.y, dryCooInAir.u2) annotation (Line(points={{202,-220},{210,
          -220},{210,-130},{258,-130}}, color={255,0,255}));
  connect(dryCooInAir1.y, dryCooInAir.u1) annotation (Line(points={{202,-100},{240,
          -100},{240,-122},{258,-122}}, color={0,0,127}));
  connect(TDryBul, dryCooInAir.u3) annotation (Line(points={{-340,140},{-310,140},
          {-310,-138},{258,-138}}, color={0,0,127}));
  connect(dryCooInAir.y, TAirDryCooIn)
    annotation (Line(points={{282,-130},{340,-130}}, color={0,0,127}));
annotation (defaultComponentName="dryCooCon",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics={Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-320,-420},{320,420}})));
end DryCooler;
