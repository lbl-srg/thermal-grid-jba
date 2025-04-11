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
  parameter Real dT(
    final quantity="TemperatureDifference",
    final unit="K")=0.5
    "Hysteresis for comparing with average threshold temperature"
    annotation (Dialog(tab="Advanced"));
  parameter Real speHys=0.01
    "Hysteresis for speed check"
    annotation (Dialog(tab="Advanced"));

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{-340,380},{-300,420}}),
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
    annotation (Placement(transformation(extent={{-340,210},{-300,250}}),
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
    annotation (Placement(transformation(extent={{-340,-360},{-300,-320}}),
        iconTransformation(extent={{-140,-160},{-100,-120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TGlyIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Temperature of the glycol flowing into the heat pump"
    annotation (Placement(transformation(extent={{-340,-300},{-300,-260}}),
        iconTransformation(extent={{-140,-70},{-100,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput yLooHea
    "-1: cool loop; 1: warm loop; 0: average"
    annotation (Placement(transformation(extent={{300,440},{340,480}}),
        iconTransformation(extent={{100,70},{140,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1Mod
    "=true for heating, =false for cooling"
    annotation (Placement(transformation(extent={{300,380},{340,420}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TLea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Leaving water temperature setpoint"
    annotation (Placement(transformation(extent={{300,240},{340,280}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yComSet(
    final min=0,
    final max=1,
    final unit="1") "Heat pump compression speed setpoint" annotation (
      Placement(transformation(extent={{300,90},{340,130}}), iconTransformation(
          extent={{100,10},{140,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1On
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{300,0},{340,40}}),
        iconTransformation(extent={{100,-10},{140,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumGly(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Pump speed setpoint in glycol side"
    annotation (Placement(transformation(extent={{300,-40},{340,0}}),
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

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(
    final k=3)
    "HIgh district load"
    annotation (Placement(transformation(extent={{-280,420},{-260,440}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higLoaMod
    "Check if the district load is high"
    annotation (Placement(transformation(extent={{-220,350},{-200,370}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant desMinDisTem(
    final k=TLooMin)
    "Design minimum district loop temperature"
    annotation (Placement(transformation(extent={{-280,290},{-260,310}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant desMaxDisTem(
    final k=TLooMax)
    "Design maximum district loop temperature"
    annotation (Placement(transformation(extent={{-280,250},{-260,270}})));
  Buildings.Controls.OBC.CDL.Reals.Average ave
    annotation (Placement(transformation(extent={{-220,270},{-200,290}})));
  Buildings.Controls.OBC.CDL.Reals.Less colLoo(
    final h=THys)
    "Check if the district loop is too cold"
    annotation (Placement(transformation(extent={{-180,300},{-160,320}})));
  Buildings.Controls.OBC.CDL.Logical.And higLoaHeaMod
    "Heat pump in heating mode when loop load is high"
    annotation (Placement(transformation(extent={{-100,320},{-80,340}})));
  Buildings.Controls.OBC.CDL.Logical.Not hotLoo
    "Check if the district loop is too hot"
    annotation (Placement(transformation(extent={{-140,240},{-120,260}})));
  Buildings.Controls.OBC.CDL.Logical.And higLoaCooMod
    "Heat pump in cooling mode when loop load is high"
    annotation (Placement(transformation(extent={{-100,240},{-80,260}})));
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
  Buildings.Controls.OBC.CDL.Logical.And winHeaMod
    "Heat pump in heating mode when it is in winter and normal rate"
    annotation (Placement(transformation(extent={{-120,170},{-100,190}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum1(
    final k=3)
    "Summer"
    annotation (Placement(transformation(extent={{-280,80},{-260,100}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum
    "Check if it is in summer"
    annotation (Placement(transformation(extent={{-200,80},{-180,100}})));
  Buildings.Controls.OBC.CDL.Logical.And sumCooMod
    "Heat pump in cooling mode when it is in summer and normal rate"
    annotation (Placement(transformation(extent={{-120,80},{-100,100}})));
  Buildings.Controls.OBC.CDL.Logical.Or heaMod2
    "Heat pump in heating mode"
    annotation (Placement(transformation(extent={{-40,320},{-20,340}})));
  Buildings.Controls.OBC.CDL.Logical.Or cooMod2
    "Heat pump in cooling mode"
    annotation (Placement(transformation(extent={{-40,240},{-20,260}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swiHeaPumMod
    "Switch for heat pump mode between heating and cooling"
    annotation (Placement(transformation(extent={{120,290},{140,310}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant cooTraTem(
    final k=TCooSet)
    "Heat pump tracking temperature in cooling mode"
    annotation (Placement(transformation(extent={{60,260},{80,280}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant heaTraTem(
    final k=THeaSet)
    "Heat pump tracking temperature in heating mode"
    annotation (Placement(transformation(extent={{60,330},{80,350}})));
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
    annotation (Placement(transformation(extent={{40,30},{60,50}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel(
    final delayTime=del)
    "Check if the compressor has been in minimum speed for sufficient time"
    annotation (Placement(transformation(extent={{-100,-10},{-80,10}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(
    final t=minComSpe,
    final h=speHys)
    "Check if the compressor speed is lower than the minimum"
    annotation (Placement(transformation(extent={{-200,-10},{-180,10}})));
  Buildings.Controls.OBC.CDL.Logical.And disHeaPum
    "Check if the heat pump should be disabled"
    annotation (Placement(transformation(extent={{-140,-10},{-120,10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{40,80},{60,100}})));
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
    annotation (Placement(transformation(extent={{220,250},{240,270}})));
  Buildings.Controls.OBC.CDL.Reals.Switch comSpe "Heat pump compresson speed"
    annotation (Placement(transformation(extent={{132,100},{152,120}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one(
    final k=1) "One"
    annotation (Placement(transformation(extent={{100,-100},{120,-80}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi4
    "Waterside valve position and the pump speed in glycol side"
    annotation (Placement(transformation(extent={{200,-70},{220,-50}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer1(
    final k=0) "Zero"
    annotation (Placement(transformation(extent={{100,-160},{120,-140}})));
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
  Buildings.Controls.OBC.CDL.Reals.Switch swi7
    annotation (Placement(transformation(extent={{120,-220},{140,-200}})));
  Buildings.Controls.OBC.CDL.Reals.Switch entGlyTem
    "Heat pump glycol entering temperature setpoint"
    annotation (Placement(transformation(extent={{200,-250},{220,-230}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minConInTem(
    final k=TConInMin)
    "Minimum condenser inlet temperature"
    annotation (Placement(transformation(extent={{60,-250},{80,-230}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant maxEvaInlTem(
    final k=TEvaInMax) "Maximum evaporator inlet temperature"
    annotation (Placement(transformation(extent={{60,-190},{80,-170}})));
  Buildings.Controls.OBC.CDL.Reals.Switch thrWayVal
    "Heat pump glycol side 3-way valve"
    annotation (Placement(transformation(extent={{220,-400},{240,-380}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one3(
    final k=1) "One"
    annotation (Placement(transformation(extent={{40,-470},{60,-450}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold offHeaPum(
    final trueHoldDuration=offTim,
    final falseHoldDuration=0) "Keep heat pump being off for sufficient time"
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1
    "Not disabled"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Buildings.Controls.OBC.CDL.Logical.And and2
    "Enabled heat pump "
    annotation (Placement(transformation(extent={{100,10},{120,30}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mWat_flow_nominal)
    "Convert mass flow rate"
    annotation (Placement(transformation(extent={{-240,-350},{-220,-330}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai3(
    final k=mHpGly_flow_nominal)
    "Convert mass flow rate"
    annotation (Placement(transformation(extent={{260,-30},{280,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minWatRat(
    final k=mWat_flow_min)
    "Minimum water flow through heat pump"
    annotation (Placement(transformation(extent={{-240,-400},{-220,-380}})));
  Buildings.Controls.OBC.CDL.Reals.Max max1
    "Ensure minimum flow through heat pump"
    annotation (Placement(transformation(extent={{-140,-370},{-120,-350}})));
  Buildings.Controls.OBC.CDL.Logical.Edge edg
    "Trigger the pulse to disable heat pump"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold holHeaPum(final
      trueHoldDuration=holOnTim, final falseHoldDuration=holOffTim)
    "Hold heat pump status for sufficient time"
    annotation (Placement(transformation(extent={{140,10},{160,30}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay delChe(final delayTime=holOnTim)
    "Delay the check after holding time is passed"
    annotation (Placement(transformation(extent={{-200,-50},{-180,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Pre pre "Break loop"
    annotation (Placement(transformation(extent={{-240,-50},{-220,-30}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(p=dT)
    "Greater than average threshold temperature"
    annotation (Placement(transformation(extent={{-180,390},{-160,410}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(p=-dT)
    "Less than average threshold temperature"
    annotation (Placement(transformation(extent={{-180,440},{-160,460}})));
  Buildings.Controls.OBC.CDL.Reals.Greater coo(h=THys)
    "Less than average threshold temperature"
    annotation (Placement(transformation(extent={{-140,440},{-120,460}})));
  Buildings.Controls.OBC.CDL.Reals.Less war(h=THys)
    "Greater than average threshold temperature"
    annotation (Placement(transformation(extent={{-140,390},{-120,410}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger cooInd(integerTrue=-1)
    "Cool loop indicator"
    annotation (Placement(transformation(extent={{-60,440},{-40,460}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger warInd(integerTrue=1)
    "Warm loop indicator"
    annotation (Placement(transformation(extent={{-60,390},{-40,410}})));
  Buildings.Controls.OBC.CDL.Integers.Add addInt
    annotation (Placement(transformation(extent={{0,450},{20,470}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal heaModInd
    "Heating mode index"
    annotation (Placement(transformation(extent={{60,410},{80,430}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal cooModInd(final realTrue
      =-1) "Cooling mode index"
    annotation (Placement(transformation(extent={{60,370},{80,390}})));
  Buildings.Controls.OBC.CDL.Reals.Add add2
    annotation (Placement(transformation(extent={{120,390},{140,410}})));
  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler triSam(y_start=1)
    annotation (Placement(transformation(extent={{170,390},{190,410}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr
    annotation (Placement(transformation(extent={{220,390},{240,410}})));
  Buildings.Controls.OBC.CDL.Reals.PID sigHeaPumCoo(controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.P,
      reverseActing=false) "Signal for cooling load (between 0 and 1)"
    annotation (Placement(transformation(extent={{-240,-120},{-220,-100}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant conTLooMax(k=TLooMax - 1)
    "Constant signal for maximum allowed loop temperature"
    annotation (Placement(transformation(extent={{-270,-120},{-250,-100}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant conTLooMin(k=TLooMin)
    "Constant signal for minimum allowed loop temperature"
    annotation (Placement(transformation(extent={{-270,-180},{-250,-160}})));
  Buildings.Controls.OBC.CDL.Reals.PID sigHeaPumHea(controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.P)
    "Signal for heating load (between 0 and 1)"
    annotation (Placement(transformation(extent={{-240,-180},{-220,-160}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TLooMaxMea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Maximum temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-340,-160},{-300,-120}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TLooMinMea(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Minimum temperature of mixing points after each energy transfer station"
    annotation (Placement(transformation(extent={{-340,-220},{-300,-180}}),
        iconTransformation(extent={{-140,-130},{-100,-90}})));
  Buildings.Controls.OBC.CDL.Reals.Max yComHeaPum
    "Maximum signal to use for heat pump compressor"
    annotation (Placement(transformation(extent={{-190,-160},{-170,-140}})));
  Buildings.Controls.OBC.CDL.Reals.Switch comSpeLoa
    "Heat pump compresson speed"
    annotation (Placement(transformation(extent={{220,120},{240,140}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minComSpeLim(final k=
        minComSpe) "Limit for minimum compressor speed signal"
    annotation (Placement(transformation(extent={{220,160},{240,180}})));
  Buildings.Controls.OBC.CDL.Reals.Max maxComSpe
    "Limiter to enforce minimum compressor speed"
    annotation (Placement(transformation(extent={{254,150},{274,170}})));
  Buildings.Controls.OBC.CDL.Reals.Switch comSpeOnOff
    "Switch to set compressor speed of if heat pump is disabled"
    annotation (Placement(transformation(extent={{260,100},{280,120}})));
equation
  connect(higLoa.y, higLoaMod.u1)
    annotation (Line(points={{-258,430},{-240,430},{-240,360},{-222,360}},
                                                     color={255,127,0}));
  connect(uSt, higLoaMod.u2) annotation (Line(points={{-320,370},{-260,370},{-260,
          352},{-222,352}}, color={255,127,0}));
  connect(desMinDisTem.y, ave.u1) annotation (Line(points={{-258,300},{-240,300},
          {-240,286},{-222,286}}, color={0,0,127}));
  connect(desMaxDisTem.y, ave.u2) annotation (Line(points={{-258,260},{-240,260},
          {-240,274},{-222,274}}, color={0,0,127}));
  connect(TMixAve, colLoo.u1)
    annotation (Line(points={{-320,330},{-200,330},{-200,310},{-182,310}},
                                                     color={0,0,127}));
  connect(ave.y, colLoo.u2) annotation (Line(points={{-198,280},{-190,280},{-190,
          302},{-182,302}}, color={0,0,127}));
  connect(colLoo.y, higLoaHeaMod.u1)
    annotation (Line(points={{-158,310},{-120,310},{-120,330},{-102,330}},
                                                    color={255,0,255}));
  connect(colLoo.y, hotLoo.u) annotation (Line(points={{-158,310},{-150,310},{
          -150,250},{-142,250}},
                            color={255,0,255}));
  connect(win.y, inWin.u1)
    annotation (Line(points={{-258,140},{-202,140}}, color={255,127,0}));
  connect(uGen, inWin.u2) annotation (Line(points={{-320,120},{-230,120},{-230,132},
          {-202,132}}, color={255,127,0}));
  connect(norRat.y, norRatMod.u1)
    annotation (Line(points={{-258,180},{-202,180}}, color={255,127,0}));
  connect(uEleRat, norRatMod.u2) annotation (Line(points={{-320,400},{-250,400},
          {-250,172},{-202,172}}, color={255,127,0}));
  connect(norRatMod.y, winHeaMod.u1)
    annotation (Line(points={{-178,180},{-122,180}},color={255,0,255}));
  connect(inWin.y, winHeaMod.u2) annotation (Line(points={{-178,140},{-130,140},
          {-130,172},{-122,172}},color={255,0,255}));
  connect(sum1.y, inSum.u1)
    annotation (Line(points={{-258,90},{-202,90}}, color={255,127,0}));
  connect(uGen, inSum.u2) annotation (Line(points={{-320,120},{-230,120},{-230,82},
          {-202,82}}, color={255,127,0}));
  connect(inSum.y, sumCooMod.u1)
    annotation (Line(points={{-178,90},{-122,90}},color={255,0,255}));
  connect(norRatMod.y, sumCooMod.u2) annotation (Line(points={{-178,180},{-140,
          180},{-140,82},{-122,82}},
                               color={255,0,255}));
  connect(higLoaHeaMod.y, heaMod2.u1)
    annotation (Line(points={{-78,330},{-42,330}}, color={255,0,255}));
  connect(winHeaMod.y, heaMod2.u2) annotation (Line(points={{-98,180},{-70,180},
          {-70,322},{-42,322}}, color={255,0,255}));
  connect(higLoaCooMod.y, cooMod2.u1)
    annotation (Line(points={{-78,250},{-42,250}}, color={255,0,255}));
  connect(sumCooMod.y, cooMod2.u2) annotation (Line(points={{-98,90},{-60,90},{
          -60,242},{-42,242}},
                           color={255,0,255}));
  connect(hotLoo.y, higLoaCooMod.u1)
    annotation (Line(points={{-118,250},{-102,250}},
                                                   color={255,0,255}));
  connect(heaTraTem.y, swiHeaPumMod.u1) annotation (Line(points={{82,340},{100,
          340},{100,308},{118,308}}, color={0,0,127}));
  connect(cooMod2.y, enaHeaPum.u2) annotation (Line(points={{-18,250},{0,250},{
          0,32},{38,32}},
                        color={255,0,255}));
  connect(heaMod2.y, enaHeaPum.u1) annotation (Line(points={{-18,330},{10,330},
          {10,40},{38,40}},
                         color={255,0,255}));
  connect(zer.y, heaPumCon.u_s)
    annotation (Line(points={{62,90},{70,90},{70,130},{78,130}},
                                                 color={0,0,127}));
  connect(TWatOut, sub.u1) annotation (Line(points={{-320,230},{20,230},{20,206},
          {58,206}}, color={0,0,127}));
  connect(sub.y, swi2.u1) annotation (Line(points={{82,200},{90,200},{90,188},{138,
          188}}, color={0,0,127}));
  connect(gai.y, swi2.u3) annotation (Line(points={{122,160},{130,160},{130,172},
          {138,172}}, color={0,0,127}));
  connect(sub.y, gai.u) annotation (Line(points={{82,200},{90,200},{90,160},{98,
          160}}, color={0,0,127}));
  connect(swi2.y, heaPumCon.u_m) annotation (Line(points={{162,180},{170,180},{
          170,94},{90,94},{90,118}},
                                  color={0,0,127}));
  connect(leaWatTem.y, sub.u2) annotation (Line(points={{242,260},{280,260},{280,
          220},{40,220},{40,194},{58,194}}, color={0,0,127}));
  connect(sub1.y, swi5.u1) annotation (Line(points={{82,-330},{90,-330},{90,-342},
          {138,-342}}, color={0,0,127}));
  connect(gai1.y, swi5.u3) annotation (Line(points={{122,-370},{130,-370},{130,-358},
          {138,-358}}, color={0,0,127}));
  connect(swi5.y, thrWayValCon.u_m) annotation (Line(points={{162,-350},{170,-350},
          {170,-430},{110,-430},{110,-422}}, color={0,0,127}));
  connect(sub1.y, gai1.u) annotation (Line(points={{82,-330},{90,-330},{90,-370},
          {98,-370}},  color={0,0,127}));
  connect(maxEvaInlTem.y, swi7.u1) annotation (Line(points={{82,-180},{100,-180},
          {100,-202},{118,-202}}, color={0,0,127}));
  connect(TGlyIn, sub1.u1) annotation (Line(points={{-320,-280},{20,-280},{20,-324},
          {58,-324}},       color={0,0,127}));
  connect(entGlyTem.y, sub1.u2) annotation (Line(points={{222,-240},{230,-240},{
          230,-310},{50,-310},{50,-336},{58,-336}}, color={0,0,127}));
  connect(zer2.y, thrWayValCon.u_s)
    annotation (Line(points={{62,-410},{98,-410}},  color={0,0,127}));
  connect(leaWatTem.y, TLea)
    annotation (Line(points={{242,260},{320,260}}, color={0,0,127}));
  connect(swi4.y, yVal)
    annotation (Line(points={{222,-60},{320,-60}}, color={0,0,127}));
  connect(thrWayVal.y, yValByp)
    annotation (Line(points={{242,-390},{320,-390}}, color={0,0,127}));
  connect(offHeaPum.y, not1.u) annotation (Line(points={{2,0},{38,0}},
                     color={255,0,255}));
  connect(not1.y, and2.u2) annotation (Line(points={{62,0},{80,0},{80,12},{98,
          12}},     color={255,0,255}));
  connect(swi4.y, gai3.u) annotation (Line(points={{222,-60},{240,-60},{240,-20},
          {258,-20}},
                   color={0,0,127}));
  connect(gai3.y, yPumGly)
    annotation (Line(points={{282,-20},{320,-20}},
                                               color={0,0,127}));
  connect(uDisPum, gai2.u)
    annotation (Line(points={{-320,-340},{-242,-340}}, color={0,0,127}));
  connect(gai2.y, max1.u1) annotation (Line(points={{-218,-340},{-180,-340},{
          -180,-354},{-142,-354}},
                              color={0,0,127}));
  connect(minWatRat.y, max1.u2) annotation (Line(points={{-218,-390},{-180,-390},
          {-180,-366},{-142,-366}}, color={0,0,127}));
  connect(swi3.y, yPum)
    annotation (Line(points={{222,-130},{320,-130}}, color={0,0,127}));
  connect(edg.y, offHeaPum.u)
    annotation (Line(points={{-38,0},{-22,0}},     color={255,0,255}));
  connect(TWatOut, leaWatTem.u3) annotation (Line(points={{-320,230},{160,230},{
          160,252},{218,252}}, color={0,0,127}));
  connect(swiHeaPumMod.y, leaWatTem.u1) annotation (Line(points={{142,300},{160,
          300},{160,268},{218,268}}, color={0,0,127}));
  connect(heaPumCon.y, comSpe.u1) annotation (Line(points={{102,130},{120,130},
          {120,118},{130,118}},color={0,0,127}));
  connect(zer.y, comSpe.u3) annotation (Line(points={{62,90},{70,90},{70,102},{
          130,102}},  color={0,0,127}));
  connect(one.y, swi4.u1) annotation (Line(points={{122,-90},{150,-90},{150,-52},
          {198,-52}}, color={0,0,127}));
  connect(zer1.y, swi4.u3) annotation (Line(points={{122,-150},{160,-150},{160,
          -68},{198,-68}},
                      color={0,0,127}));
  connect(max1.y, swi3.u1) annotation (Line(points={{-118,-360},{-20,-360},{-20,
          -122},{198,-122}}, color={0,0,127}));
  connect(zer1.y, swi3.u3) annotation (Line(points={{122,-150},{160,-150},{160,
          -138},{198,-138}},
                       color={0,0,127}));
  connect(swi7.y, entGlyTem.u1) annotation (Line(points={{142,-210},{160,-210},
          {160,-232},{198,-232}},color={0,0,127}));
  connect(TGlyIn, entGlyTem.u3) annotation (Line(points={{-320,-280},{160,-280},
          {160,-248},{198,-248}}, color={0,0,127}));
  connect(thrWayValCon.y, thrWayVal.u1) annotation (Line(points={{122,-410},{140,
          -410},{140,-382},{218,-382}}, color={0,0,127}));
  connect(one3.y, thrWayVal.u3) annotation (Line(points={{62,-460},{200,-460},{200,
          -398},{218,-398}}, color={0,0,127}));
  connect(higLoaMod.y, higLoaHeaMod.u2) annotation (Line(points={{-198,360},{
          -112,360},{-112,322},{-102,322}},
                                     color={255,0,255}));
  connect(higLoaMod.y, higLoaCooMod.u2) annotation (Line(points={{-198,360},{
          -112,360},{-112,242},{-102,242}},
                                     color={255,0,255}));
  connect(disHeaPum.y, truDel.u) annotation (Line(points={{-118,0},{-102,0}},
                                  color={255,0,255}));
  connect(truDel.y, edg.u)
    annotation (Line(points={{-78,0},{-62,0}},     color={255,0,255}));
  connect(lesThr.y, disHeaPum.u1)
    annotation (Line(points={{-178,0},{-142,0}},     color={255,0,255}));
  connect(and2.y, holHeaPum.u)
    annotation (Line(points={{122,20},{138,20}}, color={255,0,255}));
  connect(holHeaPum.y, y1On)
    annotation (Line(points={{162,20},{320,20}}, color={255,0,255}));
  connect(holHeaPum.y, comSpe.u2) annotation (Line(points={{162,20},{180,20},{
          180,80},{120,80},{120,110},{130,110}},
                               color={255,0,255}));
  connect(holHeaPum.y, heaPumCon.trigger) annotation (Line(points={{162,20},{
          180,20},{180,80},{84,80},{84,118}},   color={255,0,255}));
  connect(holHeaPum.y, swi4.u2) annotation (Line(points={{162,20},{180,20},{180,
          -60},{198,-60}}, color={255,0,255}));
  connect(holHeaPum.y, swi3.u2) annotation (Line(points={{162,20},{180,20},{180,
          -130},{198,-130}}, color={255,0,255}));
  connect(holHeaPum.y, entGlyTem.u2) annotation (Line(points={{162,20},{180,20},
          {180,-240},{198,-240}}, color={255,0,255}));
  connect(holHeaPum.y, thrWayVal.u2) annotation (Line(points={{162,20},{180,20},
          {180,-390},{218,-390}}, color={255,0,255}));
  connect(holHeaPum.y, thrWayValCon.trigger) annotation (Line(points={{162,20},
          {180,20},{180,-440},{104,-440},{104,-422}}, color={255,0,255}));
  connect(enaHeaPum.y, and2.u1) annotation (Line(points={{62,40},{80,40},{80,20},
          {98,20}}, color={255,0,255}));
  connect(delChe.y, disHeaPum.u2) annotation (Line(points={{-178,-40},{-160,-40},
          {-160,-8},{-142,-8}}, color={255,0,255}));
  connect(pre.y, delChe.u)
    annotation (Line(points={{-218,-40},{-202,-40}}, color={255,0,255}));
  connect(and2.y, pre.u) annotation (Line(points={{122,20},{130,20},{130,-60},{
          -260,-60},{-260,-40},{-242,-40}}, color={255,0,255}));
  connect(enaHeaPum.y, leaWatTem.u2) annotation (Line(points={{62,40},{190,40},
          {190,260},{218,260}}, color={255,0,255}));
  connect(ave.y, addPar.u) annotation (Line(points={{-198,280},{-190,280},{-190,
          400},{-182,400}}, color={0,0,127}));
  connect(ave.y, addPar1.u) annotation (Line(points={{-198,280},{-190,280},{
          -190,450},{-182,450}},
                            color={0,0,127}));
  connect(TMixAve, war.u2) annotation (Line(points={{-320,330},{-150,330},{-150,
          392},{-142,392}}, color={0,0,127}));
  connect(addPar.y, war.u1)
    annotation (Line(points={{-158,400},{-142,400}}, color={0,0,127}));
  connect(addPar1.y, coo.u1)
    annotation (Line(points={{-158,450},{-142,450}}, color={0,0,127}));
  connect(TMixAve, coo.u2) annotation (Line(points={{-320,330},{-150,330},{-150,
          442},{-142,442}}, color={0,0,127}));
  connect(coo.y, cooInd.u)
    annotation (Line(points={{-118,450},{-62,450}},color={255,0,255}));
  connect(war.y, warInd.u)
    annotation (Line(points={{-118,400},{-62,400}},color={255,0,255}));
  connect(warInd.y, addInt.u2) annotation (Line(points={{-38,400},{-20,400},{
          -20,454},{-2,454}},
                          color={255,127,0}));
  connect(cooInd.y, addInt.u1) annotation (Line(points={{-38,450},{-30,450},{
          -30,466},{-2,466}},
                          color={255,127,0}));
  connect(addInt.y, yLooHea)
    annotation (Line(points={{22,460},{320,460}}, color={255,127,0}));
  connect(cooMod2.y, cooModInd.u) annotation (Line(points={{-18,250},{0,250},{0,
          380},{58,380}}, color={255,0,255}));
  connect(heaMod2.y, heaModInd.u) annotation (Line(points={{-18,330},{10,330},{
          10,420},{58,420}}, color={255,0,255}));
  connect(heaModInd.y, add2.u1) annotation (Line(points={{82,420},{100,420},{
          100,406},{118,406}}, color={0,0,127}));
  connect(cooModInd.y, add2.u2) annotation (Line(points={{82,380},{100,380},{
          100,394},{118,394}}, color={0,0,127}));
  connect(add2.y, triSam.u)
    annotation (Line(points={{142,400},{168,400}}, color={0,0,127}));
  connect(holHeaPum.y, triSam.trigger)
    annotation (Line(points={{162,20},{180,20},{180,388}}, color={255,0,255}));
  connect(triSam.y, greThr.u)
    annotation (Line(points={{192,400},{218,400}}, color={0,0,127}));
  connect(greThr.y, y1Mod)
    annotation (Line(points={{242,400},{320,400}}, color={255,0,255}));
  connect(greThr.y, swiHeaPumMod.u2) annotation (Line(points={{242,400},{260,
          400},{260,360},{30,360},{30,300},{118,300}}, color={255,0,255}));
  connect(greThr.y, swi2.u2) annotation (Line(points={{242,400},{260,400},{260,
          360},{30,360},{30,180},{138,180}}, color={255,0,255}));
  connect(greThr.y, swi7.u2) annotation (Line(points={{242,400},{260,400},{260,
          360},{30,360},{30,-210},{118,-210}}, color={255,0,255}));
  connect(greThr.y, swi5.u2) annotation (Line(points={{242,400},{260,400},{260,
          360},{30,360},{30,-350},{138,-350}}, color={255,0,255}));
  connect(minConInTem.y, swi7.u3) annotation (Line(points={{82,-240},{100,-240},
          {100,-218},{118,-218}}, color={0,0,127}));
  connect(cooTraTem.y, swiHeaPumMod.u3) annotation (Line(points={{82,270},{100,
          270},{100,292},{118,292}}, color={0,0,127}));
  connect(TLooMaxMea, sigHeaPumCoo.u_m) annotation (Line(points={{-320,-140},{
          -230,-140},{-230,-122}}, color={0,0,127}));
  connect(sigHeaPumCoo.u_s, conTLooMax.y)
    annotation (Line(points={{-242,-110},{-248,-110}}, color={0,0,127}));
  connect(conTLooMin.y, sigHeaPumHea.u_s)
    annotation (Line(points={{-248,-170},{-242,-170}}, color={0,0,127}));
  connect(TLooMinMea, sigHeaPumHea.u_m) annotation (Line(points={{-320,-200},{
          -230,-200},{-230,-182}}, color={0,0,127}));
  connect(yComHeaPum.u1, sigHeaPumCoo.y) annotation (Line(points={{-192,-144},{
          -206,-144},{-206,-110},{-218,-110}}, color={0,0,127}));
  connect(yComHeaPum.u2, sigHeaPumHea.y) annotation (Line(points={{-192,-156},{
          -206,-156},{-206,-170},{-218,-170}}, color={0,0,127}));
  connect(comSpe.y, comSpeLoa.u3) annotation (Line(points={{154,110},{206,110},
          {206,122},{218,122}}, color={0,0,127}));
  connect(higLoaMod.y, comSpeLoa.u2) annotation (Line(points={{-198,360},{-112,
          360},{-112,226},{206,226},{206,130},{218,130}}, color={255,0,255}));
  connect(yComHeaPum.y, comSpeLoa.u1) annotation (Line(points={{-168,-150},{
          -160,-150},{-160,-80},{-280,-80},{-280,68},{200,68},{200,138},{218,
          138}}, color={0,0,127}));
  connect(comSpeLoa.y, lesThr.u) annotation (Line(points={{242,130},{248,130},{
          248,64},{-220,64},{-220,0},{-202,0}}, color={0,0,127}));
  connect(minComSpeLim.y, maxComSpe.u1) annotation (Line(points={{242,170},{248,
          170},{248,166},{252,166}}, color={0,0,127}));
  connect(comSpeLoa.y, maxComSpe.u2) annotation (Line(points={{242,130},{248,
          130},{248,154},{252,154}}, color={0,0,127}));
  connect(comSpeOnOff.y, yComSet)
    annotation (Line(points={{282,110},{320,110}}, color={0,0,127}));
  connect(maxComSpe.y, comSpeOnOff.u1) annotation (Line(points={{276,160},{286,
          160},{286,140},{252,140},{252,118},{258,118}}, color={0,0,127}));
  connect(holHeaPum.y, comSpeOnOff.u2) annotation (Line(points={{162,20},{254,
          20},{254,110},{258,110}}, color={255,0,255}));
  connect(zer.y, comSpeOnOff.u3) annotation (Line(points={{62,90},{230,90},{230,
          102},{258,102}}, color={0,0,127}));
  annotation (defaultComponentName="heaPumCon",
Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={Rectangle(
        extent={{-100,-154},{100,100}},
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


<tr>
<td>x</td>
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
<td>x</td>
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





</table>
<p>
Note that if the heat pump operates below the minimum speed 20%(<code>minComSpe</code>,
adjustable) for 2 minutes (<code>del</code>, adjustable),
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
