within ThermalGridJBA.Networks.Controls;
model HeatPump "Sequence for controlling heat pump, its pumps and valves"

  parameter Real mWat_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal water mass flow rate";
  parameter Real mWat_flow_min(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat pump minimum water mass flow rate";
  parameter Real mHpGly_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal glycol mass flow rate for heat pump";
  parameter Real TLooMin(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=283.65
    "Design minimum district loop temperature";
  parameter Real TLooMax(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=297.15
    "Design maximum district loop temperature";
  parameter Real TCooSet(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=TLooMin
    "Heat pump tracking temperature setpoint in cooling mode";
  parameter Real THeaSet(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=TLooMax
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
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController heaPumConTyp=
      Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Heat pump controller type"
    annotation (Dialog(group="Heat pump controller"));
  parameter Real kHeaPum=1 "Gain of controller"
    annotation (Dialog(group="Heat pump controller"));
  parameter Real TiHeaPum=0.5 "Time constant of integrator block"
    annotation (Dialog(group="Heat pump controller",
      enable=heaPumConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
          or heaPumConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Real TdHeaPum=0.1 "Time constant of derivative block"
    annotation (Dialog(group="Heat pump controller",
      enable=heaPumConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PD
          or heaPumConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController thrWayValConTyp=
      Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Three-way valve controller type"
    annotation (Dialog(group="Three way valve"));
  parameter Real kVal=1 "Gain of controller"
    annotation (Dialog(group="Three way valve"));
  parameter Real TiVal=0.5 "Time constant of integrator block"
    annotation (Dialog(group="Three way valve",
      enable=thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PI
          or thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Real TdVal=0.1 "Time constant of derivative block"
    annotation (Dialog(group="Three way valve",
      enable=thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PD
          or thrWayValConTyp == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
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
    annotation (Placement(transformation(extent={{-340,400},{-300,440}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "District loop load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-340,350},{-300,390}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TMixAve(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Average temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-340,310},{-300,350}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TWatOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water flowing out the heat pump"
    annotation (Placement(transformation(extent={{-340,200},{-300,240}}),
        iconTransformation(extent={{-140,-10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uGen
    "Season indicator. 1-winter; 2-shoulder; 3-summer"
    annotation (Placement(transformation(extent={{-340,100},{-300,140}}),
        iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum(
    final min=0,
    final max=1,
    final unit="1")
    "District loop pump speed setpoint"
    annotation (Placement(transformation(extent={{-340,-140},{-300,-100}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TGlyIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Temperature of the glycol flowing into the heat pump"
    annotation (Placement(transformation(extent={{-340,-300},{-300,-260}}),
        iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1Mod
    "=true for heating, =false for cooling"
    annotation (Placement(transformation(extent={{300,380},{340,420}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TLea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Leaving water temperature setpoint"
    annotation (Placement(transformation(extent={{300,240},{340,280}}),
        iconTransformation(extent={{100,40},{140,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput ySet(
    final min=0,
    final max=1,
    final unit="1")
    "Heat pump compression speed setpoint"
    annotation (Placement(transformation(extent={{300,90},{340,130}}),
        iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1On
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{300,30},{340,70}}),
        iconTransformation(extent={{100,-10},{140,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumGly(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Pump speed setpoint in glycol side"
    annotation (Placement(transformation(extent={{300,-20},{340,20}}),
        iconTransformation(extent={{100,-40},{140,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yVal(
    final min=0,
    final max=1,
    final unit="1")
    "Control valve position setpoint"
    annotation (Placement(transformation(extent={{300,-80},{340,-40}}),
        iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPum(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Waterside pump speed setpoint"
    annotation (Placement(transformation(extent={{300,-150},{340,-110}}),
        iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValByp(
    final min=0,
    final max=1,
    final unit="1")
    "Bypass valve in glycol side, greater valve means less bypass flow"
    annotation (Placement(transformation(extent={{300,-410},{340,-370}}),
        iconTransformation(extent={{100,-110},{140,-70}})));

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(
    final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-280,430},{-260,450}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(
    final k=3)
    "HIgh district load"
    annotation (Placement(transformation(extent={{-280,380},{-260,400}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higRatMod
    "Check if it is in high electricity rate mode"
    annotation (Placement(transformation(extent={{-240,430},{-220,450}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higLoaMod
    "Check if the district load is high"
    annotation (Placement(transformation(extent={{-220,380},{-200,400}})));
  Buildings.Controls.OBC.CDL.Logical.And higHig
    "High electricity rate and high district load"
    annotation (Placement(transformation(extent={{-160,430},{-140,450}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant desMinDisTem(
    final k=TLooMin)
    "Design minimum district loop temperature"
    annotation (Placement(transformation(extent={{-280,290},{-260,310}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant desMaxDisTem(
    final k=TLooMax)
    "Design maximum district loop temperature"
    annotation (Placement(transformation(extent={{-280,250},{-260,270}})));
  Buildings.Controls.OBC.CDL.Reals.Average ave
    annotation (Placement(transformation(extent={{-200,270},{-180,290}})));
  Buildings.Controls.OBC.CDL.Reals.Less colLoo(
    final h=THys)
    "Check if the district loop is too cold"
    annotation (Placement(transformation(extent={{-160,320},{-140,340}})));
  Buildings.Controls.OBC.CDL.Logical.And heaMod "Heat pump in heating mode"
    annotation (Placement(transformation(extent={{-80,320},{-60,340}})));
  Buildings.Controls.OBC.CDL.Logical.Not hotLoo
    "Check if the district loop is too hot"
    annotation (Placement(transformation(extent={{-120,240},{-100,260}})));
  Buildings.Controls.OBC.CDL.Logical.And cooMod "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{-80,240},{-60,260}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(
    final k=1)
    "Winter"
    annotation (Placement(transformation(extent={{-280,130},{-260,150}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin
    "Check if it is in winter"
    annotation (Placement(transformation(extent={{-200,130},{-180,150}})));
  Buildings.Controls.OBC.CDL.Integers.Equal norRatMod
    "Check if it is in normal electricity rate mode"
    annotation (Placement(transformation(extent={{-200,170},{-180,190}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant norRat(
    final k=0)
    "Normal electricity rate"
    annotation (Placement(transformation(extent={{-280,170},{-260,190}})));
  Buildings.Controls.OBC.CDL.Logical.And heaMod1
    "Heat pump in heating mode"
    annotation (Placement(transformation(extent={{-80,170},{-60,190}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum1(
    final k=3)
    "Summer"
    annotation (Placement(transformation(extent={{-280,80},{-260,100}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum
    "Check if it is in summer"
    annotation (Placement(transformation(extent={{-200,80},{-180,100}})));
  Buildings.Controls.OBC.CDL.Logical.And cooMod1
    "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{-80,80},{-60,100}})));
  Buildings.Controls.OBC.CDL.Logical.Or heaMod2
    "Heat pump in heating mode"
    annotation (Placement(transformation(extent={{-20,320},{0,340}})));
  Buildings.Controls.OBC.CDL.Logical.Or cooMod2
    "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{-20,240},{0,260}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi
    annotation (Placement(transformation(extent={{120,320},{140,340}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{80,240},{100,260}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant cooTraTem(
    final k=TCooSet)
    "Heat pump tracking temperature in cooling mode"
    annotation (Placement(transformation(extent={{-20,280},{0,300}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant heaTraTem(
    final k=THeaSet)
    "Heat pump tracking temperature in heating mode"
    annotation (Placement(transformation(extent={{-20,360},{0,380}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset heaPumCon(
    final controllerType=heaPumConTyp,
    final k=kHeaPum,
    final Ti=TiHeaPum,
    final Td=TdHeaPum,
    final y_reset=1)
    "Heat pump controller"
    annotation (Placement(transformation(extent={{80,120},{100,140}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHeaPum
    "Enable heat pump"
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel(
    final delayTime=del)
    "Check if the compressor has been in minimum speed for sufficient time"
    annotation (Placement(transformation(extent={{-160,-20},{-140,0}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(
    final t=minComSpe,
    final h=speHys)
    "Check if the compressor speed is lower than the minimum"
    annotation (Placement(transformation(extent={{-200,-20},{-180,0}})));
  Buildings.Controls.OBC.CDL.Logical.And disHeaPum
    "Check if the heat pump should be disabled"
    annotation (Placement(transformation(extent={{-100,-20},{-80,0}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{40,120},{60,140}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    annotation (Placement(transformation(extent={{60,190},{80,210}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi2
    annotation (Placement(transformation(extent={{140,170},{160,190}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(
    final k=-1)
    "Reverse"
    annotation (Placement(transformation(extent={{100,150},{120,170}})));
  Buildings.Controls.OBC.CDL.Reals.Switch leaWatTem
    "Heat pump leaving water temperature setpoint"
    annotation (Placement(transformation(extent={{200,250},{220,270}})));
  Buildings.Controls.OBC.CDL.Reals.Switch comSpe
    "Heat pump compresson speed"
    annotation (Placement(transformation(extent={{200,100},{220,120}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one(
    final k=1) "One"
    annotation (Placement(transformation(extent={{40,-50},{60,-30}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi4
    "Waterside valve position and the pump speed in glycol side"
    annotation (Placement(transformation(extent={{200,-70},{220,-50}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer1(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{40,-90},{60,-70}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi3
    "Waterside pump speed"
    annotation (Placement(transformation(extent={{200,-140},{220,-120}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub1
    annotation (Placement(transformation(extent={{60,-340},{80,-320}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(
    final k=-1)
    "Reverse"
    annotation (Placement(transformation(extent={{100,-380},{120,-360}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi5
    annotation (Placement(transformation(extent={{140,-360},{160,-340}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset thrWayValCon(
    final controllerType=thrWayValConTyp,
    final k=kVal,
    final Ti=TiVal,
    final Td=TdVal,
    final y_reset=1)
    "Three way valve controller, larger output means larger bypass flow"
    annotation (Placement(transformation(extent={{100,-420},{120,-400}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer2(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{40,-420},{60,-400}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi6
    annotation (Placement(transformation(extent={{100,-270},{120,-250}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi7
    annotation (Placement(transformation(extent={{140,-210},{160,-190}})));
  Buildings.Controls.OBC.CDL.Reals.Switch entGlyTem
    "Heat pump glycol entering temperature setpoint"
    annotation (Placement(transformation(extent={{200,-250},{220,-230}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minConInTem(
    final k=TConInMin)
    "Minimum condenser inlet temperature"
    annotation (Placement(transformation(extent={{40,-240},{60,-220}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant maxEvaInlTem(
    final k=TEvaInMax) "Maximum evaporator inlet temperature"
    annotation (Placement(transformation(extent={{40,-190},{60,-170}})));
  Buildings.Controls.OBC.CDL.Reals.Switch thrWayVal
    "Heat pump glycol side 3-way valve"
    annotation (Placement(transformation(extent={{220,-400},{240,-380}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one3(
    final k=1) "One"
    annotation (Placement(transformation(extent={{40,-470},{60,-450}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold offHeaPum(
    final trueHoldDuration=offTim,
    final falseHoldDuration=0)
    "Keep heat pump being off for sufficient time"
    annotation (Placement(transformation(extent={{-20,-20},{0,0}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1
    "Not disabled"
    annotation (Placement(transformation(extent={{40,0},{60,20}})));
  Buildings.Controls.OBC.CDL.Logical.And and2
    "Enabled heat pump "
    annotation (Placement(transformation(extent={{120,40},{140,60}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mWat_flow_nominal)
    "Convert mass flow rate"
    annotation (Placement(transformation(extent={{-240,-130},{-220,-110}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai3(
    final k=mHpGly_flow_nominal)
    "Convert mass flow rate"
    annotation (Placement(transformation(extent={{260,-10},{280,10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minWatRat(
    final k=mWat_flow_min)
    "Minimum water flow through heat pump"
    annotation (Placement(transformation(extent={{-240,-180},{-220,-160}})));
  Buildings.Controls.OBC.CDL.Reals.Max max1
    "Ensure minimum flow through heat pump"
    annotation (Placement(transformation(extent={{-140,-150},{-120,-130}})));
  Buildings.Controls.OBC.CDL.Logical.Edge edg
    "Trigger the pulse to disable heat pump"
    annotation (Placement(transformation(extent={{-60,-20},{-40,0}})));

equation
  connect(higRat.y, higRatMod.u1)
    annotation (Line(points={{-258,440},{-242,440}}, color={255,127,0}));
  connect(uEleRat, higRatMod.u2) annotation (Line(points={{-320,420},{-250,420},
          {-250,432},{-242,432}}, color={255,127,0}));
  connect(higLoa.y, higLoaMod.u1)
    annotation (Line(points={{-258,390},{-222,390}}, color={255,127,0}));
  connect(uSt, higLoaMod.u2) annotation (Line(points={{-320,370},{-240,370},{-240,
          382},{-222,382}}, color={255,127,0}));
  connect(higRatMod.y, higHig.u1)
    annotation (Line(points={{-218,440},{-162,440}}, color={255,0,255}));
  connect(higLoaMod.y, higHig.u2) annotation (Line(points={{-198,390},{-170,390},
          {-170,432},{-162,432}}, color={255,0,255}));
  connect(desMinDisTem.y, ave.u1) annotation (Line(points={{-258,300},{-220,300},
          {-220,286},{-202,286}}, color={0,0,127}));
  connect(desMaxDisTem.y, ave.u2) annotation (Line(points={{-258,260},{-220,260},
          {-220,274},{-202,274}}, color={0,0,127}));
  connect(TMixAve, colLoo.u1)
    annotation (Line(points={{-320,330},{-162,330}}, color={0,0,127}));
  connect(ave.y, colLoo.u2) annotation (Line(points={{-178,280},{-170,280},{-170,
          322},{-162,322}}, color={0,0,127}));
  connect(colLoo.y, heaMod.u1)
    annotation (Line(points={{-138,330},{-82,330}}, color={255,0,255}));
  connect(higHig.y, heaMod.u2) annotation (Line(points={{-138,440},{-90,440},{-90,
          322},{-82,322}},   color={255,0,255}));
  connect(colLoo.y, hotLoo.u) annotation (Line(points={{-138,330},{-130,330},{-130,
          250},{-122,250}}, color={255,0,255}));
  connect(win.y, inWin.u1)
    annotation (Line(points={{-258,140},{-202,140}}, color={255,127,0}));
  connect(uGen, inWin.u2) annotation (Line(points={{-320,120},{-230,120},{-230,132},
          {-202,132}}, color={255,127,0}));
  connect(norRat.y, norRatMod.u1)
    annotation (Line(points={{-258,180},{-202,180}}, color={255,127,0}));
  connect(uEleRat, norRatMod.u2) annotation (Line(points={{-320,420},{-250,420},
          {-250,172},{-202,172}}, color={255,127,0}));
  connect(norRatMod.y, heaMod1.u1)
    annotation (Line(points={{-178,180},{-82,180}}, color={255,0,255}));
  connect(inWin.y, heaMod1.u2) annotation (Line(points={{-178,140},{-120,140},{-120,
          172},{-82,172}}, color={255,0,255}));
  connect(sum1.y, inSum.u1)
    annotation (Line(points={{-258,90},{-202,90}}, color={255,127,0}));
  connect(uGen, inSum.u2) annotation (Line(points={{-320,120},{-230,120},{-230,82},
          {-202,82}}, color={255,127,0}));
  connect(inSum.y, cooMod1.u1)
    annotation (Line(points={{-178,90},{-82,90}}, color={255,0,255}));
  connect(norRatMod.y, cooMod1.u2) annotation (Line(points={{-178,180},{-140,180},
          {-140,82},{-82,82}}, color={255,0,255}));
  connect(heaMod.y, heaMod2.u1)
    annotation (Line(points={{-58,330},{-22,330}},color={255,0,255}));
  connect(heaMod1.y, heaMod2.u2) annotation (Line(points={{-58,180},{-40,180},{-40,
          322},{-22,322}},color={255,0,255}));
  connect(cooMod.y, cooMod2.u1)
    annotation (Line(points={{-58,250},{-22,250}},color={255,0,255}));
  connect(cooMod1.y, cooMod2.u2) annotation (Line(points={{-58,90},{-30,90},{-30,
          242},{-22,242}}, color={255,0,255}));
  connect(heaMod2.y, swi.u2)
    annotation (Line(points={{2,330},{118,330}},  color={255,0,255}));
  connect(cooMod2.y, swi1.u2)
    annotation (Line(points={{2,250},{78,250}}, color={255,0,255}));
  connect(hotLoo.y, cooMod.u1)
    annotation (Line(points={{-98,250},{-82,250}}, color={255,0,255}));
  connect(higHig.y, cooMod.u2) annotation (Line(points={{-138,440},{-90,440},{-90,
          242},{-82,242}}, color={255,0,255}));
  connect(cooTraTem.y, swi1.u1) annotation (Line(points={{2,290},{20,290},{20,258},
          {78,258}}, color={0,0,127}));
  connect(heaTraTem.y, swi.u1) annotation (Line(points={{2,370},{60,370},{60,338},
          {118,338}}, color={0,0,127}));
  connect(swi1.y, swi.u3) annotation (Line(points={{102,250},{110,250},{110,322},
          {118,322}}, color={0,0,127}));
  connect(heaMod2.y, y1Mod) annotation (Line(points={{2,330},{30,330},{30,400},{
          320,400}}, color={255,0,255}));
  connect(TWatOut, swi1.u3) annotation (Line(points={{-320,220},{20,220},{20,242},
          {78,242}}, color={0,0,127}));
  connect(cooMod2.y, enaHeaPum.u2) annotation (Line(points={{2,250},{10,250},{10,
          42},{38,42}}, color={255,0,255}));
  connect(heaMod2.y, enaHeaPum.u1) annotation (Line(points={{2,330},{30,330},{30,
          50},{38,50}},  color={255,0,255}));
  connect(heaPumCon.y, lesThr.u) annotation (Line(points={{102,130},{120,130},{120,
          70},{-220,70},{-220,-10},{-202,-10}}, color={0,0,127}));
  connect(lesThr.y, truDel.u)
    annotation (Line(points={{-178,-10},{-162,-10}}, color={255,0,255}));
  connect(truDel.y, disHeaPum.u1)
    annotation (Line(points={{-138,-10},{-102,-10}}, color={255,0,255}));
  connect(enaHeaPum.y, disHeaPum.u2) annotation (Line(points={{62,50},{80,50},{
          80,32},{-120,32},{-120,-18},{-102,-18}},
                                                 color={255,0,255}));
  connect(zer.y, heaPumCon.u_s)
    annotation (Line(points={{62,130},{78,130}}, color={0,0,127}));
  connect(TWatOut, sub.u1) annotation (Line(points={{-320,220},{20,220},{20,206},
          {58,206}}, color={0,0,127}));
  connect(heaMod2.y, swi2.u2) annotation (Line(points={{2,330},{30,330},{30,180},
          {138,180}}, color={255,0,255}));
  connect(sub.y, swi2.u1) annotation (Line(points={{82,200},{90,200},{90,188},{138,
          188}}, color={0,0,127}));
  connect(gai.y, swi2.u3) annotation (Line(points={{122,160},{130,160},{130,172},
          {138,172}}, color={0,0,127}));
  connect(sub.y, gai.u) annotation (Line(points={{82,200},{90,200},{90,160},{98,
          160}}, color={0,0,127}));
  connect(swi2.y, heaPumCon.u_m) annotation (Line(points={{162,180},{170,180},{170,
          90},{90,90},{90,118}},  color={0,0,127}));
  connect(leaWatTem.y, sub.u2) annotation (Line(points={{222,260},{230,260},{230,
          230},{40,230},{40,194},{58,194}}, color={0,0,127}));
  connect(sub1.y, swi5.u1) annotation (Line(points={{82,-330},{90,-330},{90,-342},
          {138,-342}}, color={0,0,127}));
  connect(gai1.y, swi5.u3) annotation (Line(points={{122,-370},{130,-370},{130,-358},
          {138,-358}}, color={0,0,127}));
  connect(swi5.y, thrWayValCon.u_m) annotation (Line(points={{162,-350},{170,-350},
          {170,-430},{110,-430},{110,-422}}, color={0,0,127}));
  connect(sub1.y, gai1.u) annotation (Line(points={{82,-330},{90,-330},{90,-370},
          {98,-370}},  color={0,0,127}));
  connect(heaMod2.y, swi7.u2) annotation (Line(points={{2,330},{30,330},{30,-200},
          {138,-200}}, color={255,0,255}));
  connect(maxEvaInlTem.y, swi7.u1) annotation (Line(points={{62,-180},{130,-180},
          {130,-192},{138,-192}}, color={0,0,127}));
  connect(minConInTem.y, swi6.u1) annotation (Line(points={{62,-230},{72,-230},{
          72,-252},{98,-252}},    color={0,0,127}));
  connect(swi6.y, swi7.u3) annotation (Line(points={{122,-260},{130,-260},{130,-208},
          {138,-208}}, color={0,0,127}));
  connect(cooMod2.y, swi6.u2) annotation (Line(points={{2,250},{10,250},{10,-260},
          {98,-260}},  color={255,0,255}));
  connect(TGlyIn, swi6.u3) annotation (Line(points={{-320,-280},{20,-280},{20,-268},
          {98,-268}},        color={0,0,127}));
  connect(heaMod2.y, swi5.u2) annotation (Line(points={{2,330},{30,330},{30,-350},
          {138,-350}}, color={255,0,255}));
  connect(TGlyIn, sub1.u1) annotation (Line(points={{-320,-280},{20,-280},{20,-324},
          {58,-324}},       color={0,0,127}));
  connect(entGlyTem.y, sub1.u2) annotation (Line(points={{222,-240},{230,-240},{
          230,-310},{50,-310},{50,-336},{58,-336}}, color={0,0,127}));
  connect(zer2.y, thrWayValCon.u_s)
    annotation (Line(points={{62,-410},{98,-410}},  color={0,0,127}));
  connect(leaWatTem.y, TLea)
    annotation (Line(points={{222,260},{320,260}}, color={0,0,127}));
  connect(comSpe.y, ySet)
    annotation (Line(points={{222,110},{320,110}}, color={0,0,127}));
  connect(swi4.y, yVal)
    annotation (Line(points={{222,-60},{320,-60}}, color={0,0,127}));
  connect(thrWayVal.y, yValByp)
    annotation (Line(points={{242,-390},{320,-390}}, color={0,0,127}));
  connect(enaHeaPum.y, and2.u1)
    annotation (Line(points={{62,50},{118,50}}, color={255,0,255}));
  connect(offHeaPum.y, not1.u) annotation (Line(points={{2,-10},{20,-10},{20,10},
          {38,10}},  color={255,0,255}));
  connect(not1.y, and2.u2) annotation (Line(points={{62,10},{100,10},{100,42},{118,
          42}},     color={255,0,255}));
  connect(and2.y, y1On)
    annotation (Line(points={{142,50},{320,50}}, color={255,0,255}));
  connect(swi4.y, gai3.u) annotation (Line(points={{222,-60},{230,-60},{230,0},{
          258,0}}, color={0,0,127}));
  connect(gai3.y, yPumGly)
    annotation (Line(points={{282,0},{320,0}}, color={0,0,127}));
  connect(uDisPum, gai2.u)
    annotation (Line(points={{-320,-120},{-242,-120}}, color={0,0,127}));
  connect(gai2.y, max1.u1) annotation (Line(points={{-218,-120},{-180,-120},{-180,
          -134},{-142,-134}}, color={0,0,127}));
  connect(minWatRat.y, max1.u2) annotation (Line(points={{-218,-170},{-180,-170},
          {-180,-146},{-142,-146}}, color={0,0,127}));
  connect(swi3.y, yPum)
    annotation (Line(points={{222,-130},{320,-130}}, color={0,0,127}));
  connect(disHeaPum.y, edg.u)
    annotation (Line(points={{-78,-10},{-62,-10}}, color={255,0,255}));
  connect(edg.y, offHeaPum.u)
    annotation (Line(points={{-38,-10},{-22,-10}}, color={255,0,255}));
  connect(and2.y, heaPumCon.trigger) annotation (Line(points={{142,50},{180,50},
          {180,80},{84,80},{84,118}}, color={255,0,255}));
  connect(and2.y, leaWatTem.u2) annotation (Line(points={{142,50},{180,50},{180,
          260},{198,260}}, color={255,0,255}));
  connect(TWatOut, leaWatTem.u3) annotation (Line(points={{-320,220},{160,220},{
          160,252},{198,252}}, color={0,0,127}));
  connect(swi.y, leaWatTem.u1) annotation (Line(points={{142,330},{180,330},{180,
          268},{198,268}}, color={0,0,127}));
  connect(heaPumCon.y, comSpe.u1) annotation (Line(points={{102,130},{120,130},{
          120,118},{198,118}}, color={0,0,127}));
  connect(and2.y, comSpe.u2) annotation (Line(points={{142,50},{180,50},{180,110},
          {198,110}}, color={255,0,255}));
  connect(zer.y, comSpe.u3) annotation (Line(points={{62,130},{70,130},{70,102},
          {198,102}}, color={0,0,127}));
  connect(one.y, swi4.u1) annotation (Line(points={{62,-40},{120,-40},{120,-52},
          {198,-52}}, color={0,0,127}));
  connect(zer1.y, swi4.u3) annotation (Line(points={{62,-80},{100,-80},{100,-68},
          {198,-68}}, color={0,0,127}));
  connect(and2.y, swi4.u2) annotation (Line(points={{142,50},{180,50},{180,-60},
          {198,-60}}, color={255,0,255}));
  connect(max1.y, swi3.u1) annotation (Line(points={{-118,-140},{-20,-140},{-20,
          -122},{198,-122}}, color={0,0,127}));
  connect(zer1.y, swi3.u3) annotation (Line(points={{62,-80},{100,-80},{100,-138},
          {198,-138}}, color={0,0,127}));
  connect(and2.y, swi3.u2) annotation (Line(points={{142,50},{180,50},{180,-130},
          {198,-130}}, color={255,0,255}));
  connect(swi7.y, entGlyTem.u1) annotation (Line(points={{162,-200},{170,-200},{
          170,-232},{198,-232}}, color={0,0,127}));
  connect(TGlyIn, entGlyTem.u3) annotation (Line(points={{-320,-280},{160,-280},
          {160,-248},{198,-248}}, color={0,0,127}));
  connect(and2.y, entGlyTem.u2) annotation (Line(points={{142,50},{180,50},{180,
          -240},{198,-240}}, color={255,0,255}));
  connect(thrWayValCon.y, thrWayVal.u1) annotation (Line(points={{122,-410},{140,
          -410},{140,-382},{218,-382}}, color={0,0,127}));
  connect(one3.y, thrWayVal.u3) annotation (Line(points={{62,-460},{200,-460},{200,
          -398},{218,-398}}, color={0,0,127}));
  connect(and2.y, thrWayVal.u2) annotation (Line(points={{142,50},{180,50},{180,
          -390},{218,-390}}, color={255,0,255}));
  connect(and2.y, thrWayValCon.trigger) annotation (Line(points={{142,50},{180,50},
          {180,-440},{104,-440},{104,-422}}, color={255,0,255}));
  annotation (defaultComponentName="heaPumCon",
Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),
                                Diagram(coordinateSystem(preserveAspectRatio=
            false, extent={{-300,-480},{300,480}})),
Documentation(info="
<html>
<p>
The table below shows when the heat pump will be enabled. It also shows how to control
each related equipment when the heat pump is enabled.
</p>
<table summary=\"summary\" border=\"1\">
<tr>
<th>Electricity rate (<code>uEleRat</code>)</th>
<th>District load (<code>uSt</code>)</th>
<th>Season (<code>uGen</code>)</th>
<th>Preferred condition</th>
<th>Mode <code>y1Mod</code></th>
<th>Heat pump compressor <code>yHeaPum</code></th>
<th>Waterside valve <code>yVal</code></th>
<th>Waterside pump <code>yPum</code></th>
<th>Glycol side pump <code>yPumGly</code></th>
<th>Glycol side bypass valve <code>yValByp</code></th>
</tr>
<tr>
<td>1 (high)</td>
<td>3 (high)</td>
<td>x</td>
<td><code>TMixAve &lt; (TLooMin+TLooMax)/2</code></td>
<td>true (heating)</td>
<td>track <code>TWatOut = THeaSet</code></td>
<td>1</td>
<td><code>uDisPum</code></td>
<td>1</td>
<td>track <code>TGlyIn = TEvaInMax</code></td>
</tr>
<tr>
<td>1 (high)</td>
<td>3 (high)</td>
<td>x</td>
<td><code>TMixAve &gt; (TLooMin+TLooMax)/2</code></td>
<td>false (cooling)</td>
<td>track <code>TWatOut = TCooSet</code></td>
<td>1</td>
<td><code>uDisPum</code></td>
<td>1</td>
<td>track <code>TGlyIn = TConInMin</code></td>
</tr>
<tr>
<td>0 (normal)</td>
<td>x</td>
<td>1 (winter)</td>
<td>x</td>
<td>true (heating)</td>
<td>track <code>TWatOut = THeaSet</code></td>
<td>1</td>
<td><code>uDisPum</code></td>
<td>1</td>
<td>track <code>TGlyIn = TEvaInMax</code></td>
</tr>
<tr>
<td>0 (normal)</td>
<td>x</td>
<td>3 (summer)</td>
<td>x</td>
<td>false (cooling)</td>
<td>track <code>TWatOut = TCooSet</code></td>
<td>1</td>
<td><code>uDisPum</code></td>
<td>1</td>
<td>track <code>TGlyIn = TConInMin</code></td>
</tr>
</table>
<p>
Note that if the heat pump operates below 20% of the full compressor speed,
switch it off, and keep it off for 12 hours (<code>offTim</code>, adjustable)
</p>
</html>", revisions="<html>
<ul>
<li>
January 31, 2025, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"));
end HeatPump;
