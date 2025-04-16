within ThermalGridJBA.Networks.Controls;
block HeatPump
  "Sequence for controlling heat pump and the associated valves, pumps"

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
  parameter Real mBorFieCen_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal water mass flow rate for center borefield";
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
  parameter Real TPlaCooSet(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=TLooMin
    "Plant cooling setpoint temperature";
  parameter Real TPlaHeaSet(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")=TLooMax
    "Plant heating setpoint temperature";
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
    "Heat pump off time due to the low compressor speed";
  parameter Real holOnTim(
    final unit="s")=1800
    "Heat pump hold on time";
  parameter Real holOffTim(
    final unit="s")=1800
    "Heat pump hold off time";
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

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{-420,400},{-380,440}}),
        iconTransformation(extent={{-140,90},{-100,130}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "Plant load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-420,360},{-380,400}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSea
    "Season indicator. 1-Winter; 2-Spring; 3-Summer; 4-Fall"
    annotation (Placement(transformation(extent={{-420,320},{-380,360}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TPlaIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water into the central plant"
    annotation (Placement(transformation(extent={{-420,80},{-380,120}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaPumIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water into the heat pump"
    annotation (Placement(transformation(extent={{-420,-60},{-380,-20}}),
        iconTransformation(extent={{-140,-10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaPumOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water out of the heat pump"
    annotation (Placement(transformation(extent={{-420,-90},{-380,-50}}),
        iconTransformation(extent={{-140,-30},{-100,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mPla_flow(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Plant mass flow rate"
    annotation (Placement(transformation(extent={{-420,-120},{-380,-80}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mHeaPum_flow(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat pump mass flow rate"
    annotation (Placement(transformation(extent={{-420,-150},{-380,-110}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TGlyIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Temperature of the glycol flowing into the heat pump"
    annotation (Placement(transformation(extent={{-420,-390},{-380,-350}}),
        iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum(
    final unit="1",
    final min=0,
    final max=1)
    "District pump norminal speed"
    annotation (Placement(transformation(extent={{-420,-440},{-380,-400}}),
        iconTransformation(extent={{-140,-130},{-100,-90}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1Mod
    "=true for heating, =false for cooling"
    annotation (Placement(transformation(extent={{380,200},{420,240}}),
        iconTransformation(extent={{100,80},{140,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yComSet(
    final min=0,
    final max=1,
    final unit="1")
    "Heat pump compression speed setpoint"
    annotation (Placement(transformation(extent={{380,-120},{420,-80}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1On
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{380,10},{420,50}}),
        iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumGly(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Pump speed setpoint in glycol side"
    annotation (Placement(transformation(extent={{380,-30},{420,10}}),
        iconTransformation(extent={{100,-30},{140,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yVal(
    final min=0,
    final max=1,
    final unit="1")
    "Control valve position setpoint"
    annotation (Placement(transformation(extent={{380,-70},{420,-30}}),
        iconTransformation(extent={{100,-60},{140,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValByp(
    final min=0,
    final max=1,
    final unit="1")
    "Bypass valve in glycol side, greater valve means less bypass flow"
    annotation (Placement(transformation(extent={{380,-370},{420,-330}}),
        iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPum(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Waterside pump speed setpoint"
    annotation (Placement(transformation(extent={{380,-500},{420,-460}}),
        iconTransformation(extent={{100,-120},{140,-80}})));

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-360,480},{-340,500}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High plant load"
    annotation (Placement(transformation(extent={{-300,480},{-280,500}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant spr(final k=2) "Spring"
    annotation (Placement(transformation(extent={{-220,480},{-200,500}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant fal(final k=4) "Fall"
    annotation (Placement(transformation(extent={{-220,440},{-200,460}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higEleRat "High electricity rate"
    annotation (Placement(transformation(extent={{-320,410},{-300,430}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higPlaLoa "High plant load"
    annotation (Placement(transformation(extent={{-260,410},{-240,430}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSpr "In Spring"
    annotation (Placement(transformation(extent={{-140,380},{-120,400}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inFal "In Fall"
    annotation (Placement(transformation(extent={{-140,350},{-120,370}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant heaSet(
    y(unit="K", displayUnit="degC"),
    final k=TPlaHeaSet)
    "Plant heating setpoint"
    annotation (Placement(transformation(extent={{-360,40},{-340,60}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant cooSet(
    y(unit="K", displayUnit="degC"),
    final k=TPlaCooSet)
    "Plant cooling setpoint"
    annotation (Placement(transformation(extent={{-360,-20},{-340,0}})));
  Buildings.Controls.OBC.CDL.Reals.Average aveSet
    "Average plant setpoint temperature"
    annotation (Placement(transformation(extent={{-320,10},{-300,30}})));
  Buildings.Controls.OBC.CDL.Reals.Less heaMod(
    final h=THys)
    "Heat pump should be in heating mode"
    annotation (Placement(transformation(extent={{-280,90},{-260,110}})));
  Buildings.Controls.OBC.CDL.Reals.Switch plaSet "Plant setpoint"
    annotation (Placement(transformation(extent={{-240,-10},{-220,10}})));
  Buildings.Controls.OBC.CDL.Reals.Switch heaPumFlo
    "Heat pump water flow rate"
    annotation (Placement(transformation(extent={{-280,-160},{-260,-140}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant dumCon(final k=1.5*
        mWat_flow_nominal)
    "Dummy constant to avoid zero division"
    annotation (Placement(transformation(extent={{-320,-190},{-300,-170}})));
  Buildings.Controls.OBC.CDL.Reals.Divide div1 "Input 1 divided by input 2"
    annotation (Placement(transformation(extent={{-240,-130},{-220,-110}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Find difference"
    annotation (Placement(transformation(extent={{-200,-30},{-180,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul "Multiply inputs"
    annotation (Placement(transformation(extent={{-160,-100},{-140,-80}})));
  Buildings.Controls.OBC.CDL.Reals.Add leaWatSet(y(displayUnit="degC", unit="K"))
    "Heat pump leaving water temperature setpoint"
    annotation (Placement(transformation(extent={{-120,-30},{-100,-10}})));

  Buildings.Controls.OBC.CDL.Reals.PIDWithReset heaPumCon(
    final controllerType=heaPumConTyp,
    final k=kHeaPum,
    final Ti=TiHeaPum,
    final Td=TdHeaPum,
    final reverseActing=false,
    final y_reset=1.5*minComSpe)
    "Heat pump controller"
    annotation (Placement(transformation(extent={{200,80},{220,100}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub1
    annotation (Placement(transformation(extent={{100,-40},{120,-20}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(final k=-1)
    "Reverse"
    annotation (Placement(transformation(extent={{140,-40},{160,-20}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi2
    annotation (Placement(transformation(extent={{180,0},{200,20}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(final k=0) "Zero"
    annotation (Placement(transformation(extent={{160,80},{180,100}})));
  Buildings.Controls.OBC.CDL.Logical.Pre pre "Break loop"
    annotation (Placement(transformation(extent={{-180,-230},{-160,-210}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay delChe(
    final delayTime=holOnTim)
    "Delay the check after holding time is passed"
    annotation (Placement(transformation(extent={{-140,-230},{-120,-210}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(
    final t=minComSpe, final h=0.1*minComSpe)
    "Check if the compressor speed is lower than the minimum"
    annotation (Placement(transformation(extent={{-140,-190},{-120,-170}})));
  Buildings.Controls.OBC.CDL.Logical.And disHeaPum
    "Check if the heat pump should be disabled"
    annotation (Placement(transformation(extent={{-80,-190},{-60,-170}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel(
    final delayTime=del)
    "Check if the compressor has been in minimum speed for sufficient time"
    annotation (Placement(transformation(extent={{-40,-190},{-20,-170}})));
  Buildings.Controls.OBC.CDL.Logical.Edge edg
    "Trigger the pulse to disable heat pump"
    annotation (Placement(transformation(extent={{0,-190},{20,-170}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold offHeaPum(
    final trueHoldDuration=offTim,
    final falseHoldDuration=0)
    "Keep heat pump being off for sufficient time"
    annotation (Placement(transformation(extent={{58,-190},{78,-170}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1
    "Not disabled"
    annotation (Placement(transformation(extent={{100,-190},{120,-170}})));
  Buildings.Controls.OBC.CDL.Logical.And and2
    "Enabled heat pump "
    annotation (Placement(transformation(extent={{160,-170},{180,-150}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold holHeaPum(
    final trueHoldDuration=holOnTim,
    final falseHoldDuration=holOffTim)
    "Hold heat pump status for sufficient time"
    annotation (Placement(transformation(extent={{200,-170},{220,-150}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHeaPum
    "Enable heat pump"
    annotation (Placement(transformation(extent={{80,-150},{100,-130}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{260,60},{280,80}})));
  Buildings.Controls.OBC.CDL.Logical.Not norRat "Normal electricity rate"
    annotation (Placement(transformation(extent={{-260,310},{-240,330}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSpr "Normal rate in Spring"
    annotation (Placement(transformation(extent={{-80,310},{-60,330}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatFal "Normal rate in Fall"
    annotation (Placement(transformation(extent={{-80,270},{-60,290}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant desLooMin(
    y(unit="K", displayUnit="degC"),
    final k=TLooMin)
    "Design minimum district loop temperature"
    annotation (Placement(transformation(extent={{-140,230},{-120,250}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant desLooMax(
    y(unit="K", displayUnit="degC"),
    final k=TLooMax)
    "Design maximum district loop temperature"
    annotation (Placement(transformation(extent={{-140,150},{-120,170}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(
    final p=-4)
    "4 degree lower than the inlet temperature"
    annotation (Placement(transformation(extent={{-140,190},{-120,210}})));
  Buildings.Controls.OBC.CDL.Reals.Max max1
    annotation (Placement(transformation(extent={{-80,210},{-60,230}})));
  Buildings.Controls.OBC.CDL.Reals.Min min1
    annotation (Placement(transformation(extent={{-80,130},{-60,150}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(
    final p=4)
    "4 degree higher than the inlet temperature"
    annotation (Placement(transformation(extent={{-140,110},{-120,130}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHeaPumForBor
    "Enable borefield for borefields"
    annotation (Placement(transformation(extent={{0,310},{20,330}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi3
    "Heat pump leaving water temperature when the heat pump is used for charging borefields"
    annotation (Placement(transformation(extent={{0,170},{20,190}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi4(y(displayUnit="degC", unit="K"))
    annotation (Placement(transformation(extent={{-20,10},{0,30}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi5
    "Heat pump leaving water temperature when the heat pump is used for charging borefields"
    annotation (Placement(transformation(extent={{80,130},{100,150}})));
  Buildings.Controls.OBC.CDL.Logical.Or inHeaMod "In heating mode"
    annotation (Placement(transformation(extent={{60,50},{80,70}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal heaModInd
    "Heating mode index"
    annotation (Placement(transformation(extent={{160,210},{180,230}})));
  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler triSam(y_start=1)
    annotation (Placement(transformation(extent={{230,210},{250,230}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(t=0.5)
    annotation (Placement(transformation(extent={{280,210},{300,230}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal glyPum(
    final realTrue=mHpGly_flow_nominal)
    "Heat pump glycol side pump speed"
    annotation (Placement(transformation(extent={{340,-20},{360,0}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal isoVal
    "Heat pump isolation valve position"
    annotation (Placement(transformation(extent={{340,-60},{360,-40}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minConInTem(
    final k=TConInMin)
    "Minimum condenser inlet temperature"
    annotation (Placement(transformation(extent={{-140,-330},{-120,-310}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant maxEvaInlTem(
    final k=TEvaInMax)
    "Maximum evaporator inlet temperature"
    annotation (Placement(transformation(extent={{-180,-300},{-160,-280}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi7
    annotation (Placement(transformation(extent={{-80,-310},{-60,-290}})));
  Buildings.Controls.OBC.CDL.Reals.Switch entGlyTem
    "Heat pump glycol entering temperature setpoint"
    annotation (Placement(transformation(extent={{0,-340},{20,-320}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub2
    annotation (Placement(transformation(extent={{60,-360},{80,-340}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(final k=-1)
    "Reverse"
    annotation (Placement(transformation(extent={{100,-400},{120,-380}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi6
    annotation (Placement(transformation(extent={{140,-380},{160,-360}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer2(final k=0)
    "Zero"
    annotation (Placement(transformation(extent={{140,-330},{160,-310}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset thrWayValCon(
    final controllerType=thrWayValConTyp,
    final k=kVal,
    final Ti=TiVal,
    final Td=TdVal,
    reverseActing=false,
    final y_reset=1)
    "Three way valve controller, larger output means larger bypass flow"
    annotation (Placement(transformation(extent={{260,-330},{280,-310}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one3(final k=1)
    "One"
    annotation (Placement(transformation(extent={{260,-400},{280,-380}})));
  Buildings.Controls.OBC.CDL.Reals.Switch thrWayVal
    "Heat pump glycol side 3-way valve"
    annotation (Placement(transformation(extent={{320,-360},{340,-340}})));
  Buildings.Controls.OBC.CDL.Reals.Switch higLoaModFlo
    "Mass flow rate setpoint if the heat pump is enabeld due to the high load"
    annotation (Placement(transformation(extent={{100,-450},{120,-430}})));
  Buildings.Controls.OBC.CDL.Reals.Switch higLoaModFlo1
    "Mass flow rate setpoint if the heat pump is enabeld due to the high load"
    annotation (Placement(transformation(extent={{320,-490},{340,-470}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mWat_flow_nominal)
    "Convert mass flow rate"
    annotation (Placement(transformation(extent={{-340,-430},{-320,-410}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minWatRat(
    final k=mWat_flow_min)
    "Minimum water flow through heat pump"
    annotation (Placement(transformation(extent={{100,-490},{120,-470}})));
  Buildings.Controls.OBC.CDL.Reals.Max max2
    "Ensure minimum flow through heat pump"
    annotation (Placement(transformation(extent={{162,-470},{182,-450}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(final k=1)
    "Constant one"
    annotation (Placement(transformation(extent={{-80,-470},{-60,-450}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai3(
    final k=mBorFieCen_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{-20,-470},{0,-450}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one1(final k=0) "zero"
    annotation (Placement(transformation(extent={{260,-510},{280,-490}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minSpe(final k=minComSpe)
    "Minimum compressor speed"
    annotation (Placement(transformation(extent={{160,170},{180,190}})));
  Buildings.Controls.OBC.CDL.Reals.Max max3
    "Ensure minimum heat pump compressor speed"
    annotation (Placement(transformation(extent={{260,150},{280,170}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi8
    annotation (Placement(transformation(extent={{300,110},{320,130}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi9(y(displayUnit="degC", unit="K"))
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Not norRat1
    "Normal electricity rate"
    annotation (Placement(transformation(extent={{200,-140},{220,-120}})));
  Buildings.Controls.OBC.CDL.Logical.And and1
    "Enabled heat pump "
    annotation (Placement(transformation(extent={{260,-140},{280,-120}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi10
    annotation (Placement(transformation(extent={{340,-110},{360,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Switch heaPumMod "Heat pump mode"
    annotation (Placement(transformation(extent={{120,70},{140,90}})));
  Buildings.Controls.OBC.CDL.Logical.And higHeaLoa "High heating load"
    annotation (Placement(transformation(extent={{-140,30},{-120,50}})));
equation
  connect(uEleRat, higEleRat.u1)
    annotation (Line(points={{-400,420},{-322,420}}, color={255,127,0}));
  connect(higRat.y, higEleRat.u2) annotation (Line(points={{-338,490},{-330,490},
          {-330,412},{-322,412}}, color={255,127,0}));
  connect(higLoa.y, higPlaLoa.u1) annotation (Line(points={{-278,490},{-270,490},
          {-270,420},{-262,420}}, color={255,127,0}));
  connect(uSt, higPlaLoa.u2) annotation (Line(points={{-400,380},{-270,380},{-270,
          412},{-262,412}},      color={255,127,0}));
  connect(spr.y, inSpr.u1) annotation (Line(points={{-198,490},{-180,490},{-180,
          390},{-142,390}}, color={255,127,0}));
  connect(fal.y, inFal.u1) annotation (Line(points={{-198,450},{-190,450},{-190,
          360},{-142,360}}, color={255,127,0}));
  connect(uSea, inSpr.u2) annotation (Line(points={{-400,340},{-200,340},{-200,382},
          {-142,382}},      color={255,127,0}));
  connect(uSea, inFal.u2) annotation (Line(points={{-400,340},{-200,340},{-200,352},
          {-142,352}},      color={255,127,0}));
  connect(heaSet.y, aveSet.u1) annotation (Line(points={{-338,50},{-330,50},{-330,
          26},{-322,26}},        color={0,0,127}));
  connect(cooSet.y, aveSet.u2) annotation (Line(points={{-338,-10},{-330,-10},{-330,
          14},{-322,14}},        color={0,0,127}));
  connect(TPlaIn, heaMod.u1) annotation (Line(points={{-400,100},{-282,100}},
                                 color={0,0,127}));
  connect(aveSet.y, heaMod.u2) annotation (Line(points={{-298,20},{-290,20},{-290,
          92},{-282,92}},        color={0,0,127}));
  connect(heaMod.y, plaSet.u2) annotation (Line(points={{-258,100},{-250,100},{-250,
          0},{-242,0}},          color={255,0,255}));
  connect(heaSet.y, plaSet.u1) annotation (Line(points={{-338,50},{-280,50},{-280,
          8},{-242,8}},          color={0,0,127}));
  connect(cooSet.y, plaSet.u3) annotation (Line(points={{-338,-10},{-280,-10},{-280,
          -8},{-242,-8}},        color={0,0,127}));
  connect(mHeaPum_flow, heaPumFlo.u1) annotation (Line(points={{-400,-130},{-290,
          -130},{-290,-142},{-282,-142}},
                                       color={0,0,127}));
  connect(dumCon.y, heaPumFlo.u3) annotation (Line(points={{-298,-180},{-290,-180},
          {-290,-158},{-282,-158}},
                                  color={0,0,127}));
  connect(mPla_flow, div1.u1) annotation (Line(points={{-400,-100},{-250,-100},{
          -250,-114},{-242,-114}},
                            color={0,0,127}));
  connect(heaPumFlo.y, div1.u2) annotation (Line(points={{-258,-150},{-250,-150},
          {-250,-126},{-242,-126}},
                                  color={0,0,127}));
  connect(plaSet.y, sub.u1) annotation (Line(points={{-218,0},{-210,0},{-210,-14},
          {-202,-14}},         color={0,0,127}));
  connect(THeaPumIn, sub.u2) annotation (Line(points={{-400,-40},{-210,-40},{-210,
          -26},{-202,-26}},
                          color={0,0,127}));
  connect(sub.y, mul.u1) annotation (Line(points={{-178,-20},{-170,-20},{-170,-84},
          {-162,-84}},color={0,0,127}));
  connect(div1.y, mul.u2) annotation (Line(points={{-218,-120},{-170,-120},{-170,
          -96},{-162,-96}},
                        color={0,0,127}));
  connect(THeaPumIn, leaWatSet.u1) annotation (Line(points={{-400,-40},{-160,-40},
          {-160,-14},{-122,-14}},
                                color={0,0,127}));
  connect(mul.y, leaWatSet.u2) annotation (Line(points={{-138,-90},{-130,-90},{-130,
          -26},{-122,-26}},    color={0,0,127}));
  connect(zer.y, heaPumCon.u_s)
    annotation (Line(points={{182,90},{198,90}}, color={0,0,127}));
  connect(THeaPumOut, sub1.u2) annotation (Line(points={{-400,-70},{20,-70},{20,
          -36},{98,-36}},     color={0,0,127}));
  connect(sub1.y, gai.u)
    annotation (Line(points={{122,-30},{138,-30}},
                                                 color={0,0,127}));
  connect(gai.y, swi2.u3) annotation (Line(points={{162,-30},{168,-30},{168,2},
          {178,2}},  color={0,0,127}));
  connect(sub1.y, swi2.u1) annotation (Line(points={{122,-30},{130,-30},{130,18},
          {178,18}}, color={0,0,127}));
  connect(swi2.y, heaPumCon.u_m)
    annotation (Line(points={{202,10},{210,10},{210,78}}, color={0,0,127}));
  connect(and2.y,pre. u) annotation (Line(points={{182,-160},{190,-160},{190,-240},
          {-200,-240},{-200,-220},{-182,-220}},
                                            color={255,0,255}));
  connect(enaHeaPum.y, and2.u1) annotation (Line(points={{102,-140},{150,-140},{
          150,-160},{158,-160}},
                            color={255,0,255}));
  connect(lesThr.y, disHeaPum.u1)
    annotation (Line(points={{-118,-180},{-82,-180}},  color={255,0,255}));
  connect(disHeaPum.y, truDel.u)
    annotation (Line(points={{-58,-180},{-42,-180}},   color={255,0,255}));
  connect(truDel.y, edg.u)
    annotation (Line(points={{-18,-180},{-2,-180}},    color={255,0,255}));
  connect(edg.y, offHeaPum.u)
    annotation (Line(points={{22,-180},{56,-180}},     color={255,0,255}));
  connect(offHeaPum.y, not1.u)
    annotation (Line(points={{80,-180},{98,-180}},   color={255,0,255}));
  connect(not1.y, and2.u2) annotation (Line(points={{122,-180},{150,-180},{150,-168},
          {158,-168}},color={255,0,255}));
  connect(pre.y, delChe.u)
    annotation (Line(points={{-158,-220},{-142,-220}}, color={255,0,255}));
  connect(delChe.y, disHeaPum.u2) annotation (Line(points={{-118,-220},{-100,-220},
          {-100,-188},{-82,-188}},        color={255,0,255}));
  connect(and2.y, holHeaPum.u)
    annotation (Line(points={{182,-160},{198,-160}},
                                                   color={255,0,255}));
  connect(holHeaPum.y, swi1.u2) annotation (Line(points={{222,-160},{240,-160},{
          240,70},{258,70}},   color={255,0,255}));
  connect(heaPumCon.y, swi1.u1) annotation (Line(points={{222,90},{230,90},{230,
          78},{258,78}},       color={0,0,127}));
  connect(zer.y, swi1.u3) annotation (Line(points={{182,90},{190,90},{190,62},{258,
          62}},      color={0,0,127}));
  connect(swi1.y, lesThr.u) annotation (Line(points={{282,70},{290,70},{290,-110},
          {-160,-110},{-160,-180},{-142,-180}}, color={0,0,127}));
  connect(holHeaPum.y, y1On) annotation (Line(points={{222,-160},{240,-160},{240,
          30},{400,30}}, color={255,0,255}));
  connect(higEleRat.y, norRat.u) annotation (Line(points={{-298,420},{-280,420},
          {-280,320},{-262,320}}, color={255,0,255}));
  connect(norRat.y, norRatSpr.u2) annotation (Line(points={{-238,320},{-140,320},
          {-140,312},{-82,312}}, color={255,0,255}));
  connect(inSpr.y, norRatSpr.u1) annotation (Line(points={{-118,390},{-100,390},
          {-100,320},{-82,320}}, color={255,0,255}));
  connect(norRat.y, norRatFal.u2) annotation (Line(points={{-238,320},{-140,320},
          {-140,272},{-82,272}}, color={255,0,255}));
  connect(inFal.y, norRatFal.u1) annotation (Line(points={{-118,360},{-110,360},
          {-110,280},{-82,280}}, color={255,0,255}));
  connect(THeaPumIn, addPar.u) annotation (Line(points={{-400,-40},{-160,-40},{-160,
          200},{-142,200}}, color={0,0,127}));
  connect(addPar.y, max1.u2) annotation (Line(points={{-118,200},{-100,200},{-100,
          214},{-82,214}}, color={0,0,127}));
  connect(desLooMin.y, max1.u1) annotation (Line(points={{-118,240},{-100,240},{
          -100,226},{-82,226}}, color={0,0,127}));
  connect(desLooMax.y, min1.u1) annotation (Line(points={{-118,160},{-100,160},{
          -100,146},{-82,146}}, color={0,0,127}));
  connect(addPar1.y, min1.u2) annotation (Line(points={{-118,120},{-100,120},{-100,
          134},{-82,134}}, color={0,0,127}));
  connect(THeaPumIn, addPar1.u) annotation (Line(points={{-400,-40},{-160,-40},{
          -160,120},{-142,120}}, color={0,0,127}));
  connect(norRatSpr.y, enaHeaPumForBor.u1)
    annotation (Line(points={{-58,320},{-2,320}}, color={255,0,255}));
  connect(norRatFal.y, enaHeaPumForBor.u2) annotation (Line(points={{-58,280},{-20,
          280},{-20,312},{-2,312}}, color={255,0,255}));
  connect(norRatSpr.y, swi3.u2) annotation (Line(points={{-58,320},{-30,320},{-30,
          180},{-2,180}}, color={255,0,255}));
  connect(max1.y, swi3.u1) annotation (Line(points={{-58,220},{-40,220},{-40,188},
          {-2,188}}, color={0,0,127}));
  connect(min1.y, swi3.u3) annotation (Line(points={{-58,140},{-40,140},{-40,172},
          {-2,172}}, color={0,0,127}));
  connect(enaHeaPumForBor.y, enaHeaPum.u2) annotation (Line(points={{22,320},{40,
          320},{40,-148},{78,-148}}, color={255,0,255}));
  connect(higPlaLoa.y, enaHeaPum.u1) annotation (Line(points={{-238,420},{50,420},
          {50,-140},{78,-140}}, color={255,0,255}));
  connect(holHeaPum.y, heaPumCon.trigger) annotation (Line(points={{222,-160},{240,
          -160},{240,70},{204,70},{204,78}}, color={255,0,255}));
  connect(higPlaLoa.y, swi4.u2) annotation (Line(points={{-238,420},{-210,420},{
          -210,20},{-22,20}}, color={255,0,255}));
  connect(swi4.y, sub1.u1) annotation (Line(points={{2,20},{60,20},{60,-24},{98,
          -24}}, color={0,0,127}));
  connect(swi3.y, swi5.u1) annotation (Line(points={{22,180},{60,180},{60,148},{
          78,148}}, color={0,0,127}));
  connect(enaHeaPumForBor.y, swi5.u2) annotation (Line(points={{22,320},{40,320},
          {40,140},{78,140}}, color={255,0,255}));
  connect(THeaPumOut, swi5.u3) annotation (Line(points={{-400,-70},{20,-70},{20,
          132},{78,132}}, color={0,0,127}));
  connect(swi5.y, swi4.u3) annotation (Line(points={{102,140},{120,140},{120,120},
          {-40,120},{-40,12},{-22,12}}, color={0,0,127}));
  connect(heaModInd.y, triSam.u)
    annotation (Line(points={{182,220},{228,220}}, color={0,0,127}));
  connect(triSam.y, greThr.u)
    annotation (Line(points={{252,220},{278,220}}, color={0,0,127}));
  connect(greThr.y, y1Mod)
    annotation (Line(points={{302,220},{400,220}}, color={255,0,255}));
  connect(holHeaPum.y, triSam.trigger) annotation (Line(points={{222,-160},{240,
          -160},{240,208}}, color={255,0,255}));
  connect(glyPum.y, yPumGly)
    annotation (Line(points={{362,-10},{400,-10}}, color={0,0,127}));
  connect(holHeaPum.y, glyPum.u) annotation (Line(points={{222,-160},{240,-160},
          {240,-10},{338,-10}}, color={255,0,255}));
  connect(holHeaPum.y, isoVal.u) annotation (Line(points={{222,-160},{240,-160},
          {240,-50},{338,-50}}, color={255,0,255}));
  connect(isoVal.y, yVal)
    annotation (Line(points={{362,-50},{400,-50}}, color={0,0,127}));
  connect(greThr.y, swi7.u2) annotation (Line(points={{302,220},{328,220},{328,
          -270},{-110,-270},{-110,-300},{-82,-300}},
                                               color={255,0,255}));
  connect(maxEvaInlTem.y, swi7.u1) annotation (Line(points={{-158,-290},{-100,-290},
          {-100,-292},{-82,-292}}, color={0,0,127}));
  connect(minConInTem.y, swi7.u3) annotation (Line(points={{-118,-320},{-100,-320},
          {-100,-308},{-82,-308}}, color={0,0,127}));
  connect(swi7.y, entGlyTem.u1) annotation (Line(points={{-58,-300},{-40,-300},{
          -40,-322},{-2,-322}}, color={0,0,127}));
  connect(TGlyIn, entGlyTem.u3) annotation (Line(points={{-400,-370},{-80,-370},
          {-80,-338},{-2,-338}}, color={0,0,127}));
  connect(holHeaPum.y, entGlyTem.u2) annotation (Line(points={{222,-160},{240,-160},
          {240,-290},{-20,-290},{-20,-330},{-2,-330}}, color={255,0,255}));
  connect(entGlyTem.y, sub2.u1) annotation (Line(points={{22,-330},{32,-330},{32,
          -344},{58,-344}}, color={0,0,127}));
  connect(TGlyIn, sub2.u2) annotation (Line(points={{-400,-370},{-80,-370},{-80,
          -356},{58,-356}}, color={0,0,127}));
  connect(sub2.y, gai1.u) annotation (Line(points={{82,-350},{92,-350},{92,-390},
          {98,-390}}, color={0,0,127}));
  connect(sub2.y, swi6.u1) annotation (Line(points={{82,-350},{92,-350},{92,-362},
          {138,-362}}, color={0,0,127}));
  connect(gai1.y, swi6.u3) annotation (Line(points={{122,-390},{132,-390},{132,-378},
          {138,-378}}, color={0,0,127}));
  connect(greThr.y, swi6.u2) annotation (Line(points={{302,220},{328,220},{328,
          -270},{120,-270},{120,-370},{138,-370}},
                                             color={255,0,255}));
  connect(zer2.y, thrWayValCon.u_s)
    annotation (Line(points={{162,-320},{258,-320}}, color={0,0,127}));
  connect(swi6.y, thrWayValCon.u_m) annotation (Line(points={{162,-370},{270,-370},
          {270,-332}}, color={0,0,127}));
  connect(holHeaPum.y, thrWayValCon.trigger) annotation (Line(points={{222,-160},
          {240,-160},{240,-350},{264,-350},{264,-332}}, color={255,0,255}));
  connect(holHeaPum.y, thrWayVal.u2) annotation (Line(points={{222,-160},{240,-160},
          {240,-350},{318,-350}}, color={255,0,255}));
  connect(thrWayValCon.y, thrWayVal.u1) annotation (Line(points={{282,-320},{300,
          -320},{300,-342},{318,-342}}, color={0,0,127}));
  connect(one3.y, thrWayVal.u3) annotation (Line(points={{282,-390},{300,-390},{
          300,-358},{318,-358}}, color={0,0,127}));
  connect(thrWayVal.y, yValByp)
    annotation (Line(points={{342,-350},{400,-350}}, color={0,0,127}));
  connect(higLoaModFlo1.y, yPum)
    annotation (Line(points={{342,-480},{400,-480}}, color={0,0,127}));
  connect(higPlaLoa.y, higLoaModFlo.u2) annotation (Line(points={{-238,420},{50,
          420},{50,-440},{98,-440}}, color={255,0,255}));
  connect(uDisPum, gai2.u)
    annotation (Line(points={{-400,-420},{-342,-420}}, color={0,0,127}));
  connect(gai2.y, higLoaModFlo.u1) annotation (Line(points={{-318,-420},{20,-420},
          {20,-432},{98,-432}}, color={0,0,127}));
  connect(con.y, gai3.u)
    annotation (Line(points={{-58,-460},{-22,-460}}, color={0,0,127}));
  connect(gai3.y, higLoaModFlo.u3) annotation (Line(points={{2,-460},{20,-460},{
          20,-448},{98,-448}}, color={0,0,127}));
  connect(higLoaModFlo.y, max2.u1) annotation (Line(points={{122,-440},{142,-440},
          {142,-454},{160,-454}}, color={0,0,127}));
  connect(minWatRat.y, max2.u2) annotation (Line(points={{122,-480},{140,-480},{
          140,-466},{160,-466}}, color={0,0,127}));
  connect(max2.y, higLoaModFlo1.u1) annotation (Line(points={{184,-460},{300,-460},
          {300,-472},{318,-472}}, color={0,0,127}));
  connect(holHeaPum.y, higLoaModFlo1.u2) annotation (Line(points={{222,-160},{240,
          -160},{240,-480},{318,-480}}, color={255,0,255}));
  connect(one1.y, higLoaModFlo1.u3) annotation (Line(points={{282,-500},{300,-500},
          {300,-488},{318,-488}}, color={0,0,127}));
  connect(holHeaPum.y, heaPumFlo.u2) annotation (Line(points={{222,-160},{240,-160},
          {240,-260},{-340,-260},{-340,-150},{-282,-150}}, color={255,0,255}));
  connect(heaPumCon.y, max3.u2) annotation (Line(points={{222,90},{230,90},{230,
          154},{258,154}}, color={0,0,127}));
  connect(minSpe.y, max3.u1) annotation (Line(points={{182,180},{250,180},{250,
          166},{258,166}},
                      color={0,0,127}));
  connect(max3.y, swi8.u1) annotation (Line(points={{282,160},{290,160},{290,
          128},{298,128}},
                      color={0,0,127}));
  connect(zer.y, swi8.u3) annotation (Line(points={{182,90},{190,90},{190,112},
          {298,112}},color={0,0,127}));
  connect(holHeaPum.y, swi8.u2) annotation (Line(points={{222,-160},{240,-160},
          {240,120},{298,120}},color={255,0,255}));
  connect(holHeaPum.y, swi9.u2) annotation (Line(points={{222,-160},{240,-160},
          {240,-100},{-80,-100},{-80,-40},{-62,-40}}, color={255,0,255}));
  connect(leaWatSet.y, swi9.u1) annotation (Line(points={{-98,-20},{-80,-20},{
          -80,-32},{-62,-32}}, color={0,0,127}));
  connect(THeaPumOut, swi9.u3) annotation (Line(points={{-400,-70},{-100,-70},{
          -100,-48},{-62,-48}}, color={0,0,127}));
  connect(swi9.y, swi4.u1) annotation (Line(points={{-38,-40},{-30,-40},{-30,28},
          {-22,28}}, color={0,0,127}));
  connect(enaHeaPum.y, norRat1.u) annotation (Line(points={{102,-140},{150,-140},
          {150,-130},{198,-130}}, color={255,0,255}));
  connect(norRat1.y, and1.u1)
    annotation (Line(points={{222,-130},{258,-130}}, color={255,0,255}));
  connect(holHeaPum.y, and1.u2) annotation (Line(points={{222,-160},{240,-160},
          {240,-138},{258,-138}}, color={255,0,255}));
  connect(and1.y, swi10.u2) annotation (Line(points={{282,-130},{300,-130},{300,
          -100},{338,-100}}, color={255,0,255}));
  connect(swi8.y, swi10.u3) annotation (Line(points={{322,120},{340,120},{340,
          60},{320,60},{320,-108},{338,-108}}, color={0,0,127}));
  connect(swi10.y, yComSet)
    annotation (Line(points={{362,-100},{400,-100}}, color={0,0,127}));
  connect(minSpe.y, swi10.u1) annotation (Line(points={{182,180},{250,180},{250,
          -92},{338,-92}}, color={0,0,127}));
  connect(higPlaLoa.y, heaPumMod.u2) annotation (Line(points={{-238,420},{-210,420},
          {-210,80},{118,80}}, color={255,0,255}));
  connect(heaMod.y, heaPumMod.u1) annotation (Line(points={{-258,100},{80,100},{
          80,88},{118,88}}, color={255,0,255}));
  connect(heaMod.y, higHeaLoa.u2) annotation (Line(points={{-258,100},{-250,100},
          {-250,32},{-142,32}}, color={255,0,255}));
  connect(higPlaLoa.y, higHeaLoa.u1) annotation (Line(points={{-238,420},{-210,420},
          {-210,40},{-142,40}}, color={255,0,255}));
  connect(higHeaLoa.y, inHeaMod.u2) annotation (Line(points={{-118,40},{-100,40},
          {-100,52},{58,52}}, color={255,0,255}));
  connect(norRatFal.y, inHeaMod.u1) annotation (Line(points={{-58,280},{-20,280},
          {-20,60},{58,60}}, color={255,0,255}));
  connect(inHeaMod.y, heaPumMod.u3) annotation (Line(points={{82,60},{90,60},{90,
          72},{118,72}}, color={255,0,255}));
  connect(heaPumMod.y, heaModInd.u) annotation (Line(points={{142,80},{150,80},{
          150,220},{158,220}}, color={255,0,255}));
  connect(greThr.y, swi2.u2) annotation (Line(points={{302,220},{328,220},{328,40},
          {160,40},{160,10},{178,10}}, color={255,0,255}));
annotation (defaultComponentName="heaPumCon",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-120},
            {100,120}}), graphics={Rectangle(
        extent={{-100,-120},{100,120}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,160},{100,120}},
          textString="%name",
          textColor={0,0,255})}),
                                Diagram(coordinateSystem(preserveAspectRatio=
            false, extent={{-380,-520},{380,520}})));
end HeatPump;
