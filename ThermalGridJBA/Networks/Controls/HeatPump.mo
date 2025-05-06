within ThermalGridJBA.Networks.Controls;
block HeatPump
  "Sequence for controlling heat pump and the associated valves and pumps"

  parameter Real mWat_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal water mass flow rate";
  parameter Real mWat_flow_min(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat pump minimum water mass flow rate";
  parameter Real mHeaPumGly_flow_nominal(final quantity="MassFlowRate", final
      unit="kg/s") "Nominal glycol mass flow rate for heat pump";
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
//   parameter Real TPlaCooSet(
//     final quantity="ThermodynamicTemperature",
//     final unit="K",
//     displayUnit="degC")=TLooMin
//     "Plant cooling setpoint temperature";
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
  parameter Real isoValStrTim(
    unit="s")=30
    "Time needed to fully open or close heat pump waterside isolation valve"
    annotation (Dialog(tab="Advanced"));
  parameter Real watPumRis(
    unit="s")=30
    "Time needed to change motor speed between zero and full speed for the heat pump waterside pump"
    annotation (Dialog(tab="Advanced"));
  parameter Real heaPumRisTim(
    unit="s")=30
    "Time needed to change motor speed between zero and full speed for the heat pump compressor"
    annotation (Dialog(tab="Advanced"));

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{-460,450},{-420,490}}),
        iconTransformation(extent={{-140,90},{-100,130}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "Plant load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-460,410},{-420,450}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSea
    "Season indicator. 1-Winter; 2-Spring; 3-Summer; 4-Fall"
    annotation (Placement(transformation(extent={{-460,370},{-420,410}}),
        iconTransformation(extent={{-140,50},{-100,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TPlaIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water into the central plant"
    annotation (Placement(transformation(extent={{-460,130},{-420,170}}),
        iconTransformation(extent={{-140,30},{-100,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TActPlaCooSet(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Active plant cooling setpoint"
    annotation (Placement(transformation(extent={{-460,40},{-420,80}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaPumIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water into the heat pump"
    annotation (Placement(transformation(extent={{-460,-10},{-420,30}}),
        iconTransformation(extent={{-140,-10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaPumOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Temperature of the water out of the heat pump"
    annotation (Placement(transformation(extent={{-460,-40},{-420,0}}),
        iconTransformation(extent={{-140,-30},{-100,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mPla_flow(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Plant mass flow rate"
    annotation (Placement(transformation(extent={{-460,-70},{-420,-30}}),
        iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mHeaPum_flow(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat pump mass flow rate"
    annotation (Placement(transformation(extent={{-460,-100},{-420,-60}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TGlyIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Temperature of the glycol flowing into the heat pump"
    annotation (Placement(transformation(extent={{-460,-340},{-420,-300}}),
        iconTransformation(extent={{-140,-110},{-100,-70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum(
    final unit="1",
    final min=0,
    final max=1)
    "District pump norminal speed"
    annotation (Placement(transformation(extent={{-460,-380},{-420,-340}}),
        iconTransformation(extent={{-140,-130},{-100,-90}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1Mod
    "=true for heating, =false for cooling"
    annotation (Placement(transformation(extent={{420,250},{460,290}}),
        iconTransformation(extent={{100,80},{140,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yComSet(
    final min=0,
    final max=1,
    final unit="1")
    "Heat pump compression speed setpoint"
    annotation (Placement(transformation(extent={{420,-160},{460,-120}}),
        iconTransformation(extent={{100,50},{140,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanOutput y1On
    "Heat pump valves commanded open"
    annotation (Placement(transformation(extent={{420,60},{460,100}}),
        iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumGly(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Pump speed setpoint in glycol side"
    annotation (Placement(transformation(extent={{420,20},{460,60}}),
        iconTransformation(extent={{100,-30},{140,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yVal(
    final min=0,
    final max=1,
    final unit="1")
    "Control valve position setpoint"
    annotation (Placement(transformation(extent={{420,-20},{460,20}}),
        iconTransformation(extent={{100,-60},{140,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValByp(
    final min=0,
    final max=1,
    final unit="1")
    "Bypass valve in glycol side, greater valve means less bypass flow"
    annotation (Placement(transformation(extent={{420,-320},{460,-280}}),
        iconTransformation(extent={{100,-90},{140,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPum(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Waterside pump speed setpoint"
    annotation (Placement(transformation(extent={{420,-500},{460,-460}}),
        iconTransformation(extent={{100,-120},{140,-80}})));

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-400,530},{-380,550}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High plant load"
    annotation (Placement(transformation(extent={{-340,530},{-320,550}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant spr(final k=2) "Spring"
    annotation (Placement(transformation(extent={{-260,530},{-240,550}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant fal(final k=4) "Fall"
    annotation (Placement(transformation(extent={{-260,490},{-240,510}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higEleRat "High electricity rate"
    annotation (Placement(transformation(extent={{-360,460},{-340,480}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higPlaLoa "High plant load"
    annotation (Placement(transformation(extent={{-300,460},{-280,480}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSpr "In Spring"
    annotation (Placement(transformation(extent={{-180,430},{-160,450}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inFal "In Fall"
    annotation (Placement(transformation(extent={{-180,400},{-160,420}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant heaSet(
    y(unit="K", displayUnit="degC"),
    final k=TPlaHeaSet)
    "Plant heating setpoint"
    annotation (Placement(transformation(extent={{-400,90},{-380,110}})));
  Buildings.Controls.OBC.CDL.Reals.Average aveSet
    "Average plant setpoint temperature"
    annotation (Placement(transformation(extent={{-360,70},{-340,90}})));
  Buildings.Controls.OBC.CDL.Reals.Less heaMod(
    final h=THys)
    "Heat pump should be in heating mode"
    annotation (Placement(transformation(extent={{-320,140},{-300,160}})));
  Buildings.Controls.OBC.CDL.Reals.Switch plaSet "Plant setpoint"
    annotation (Placement(transformation(extent={{-280,40},{-260,60}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minFloDivZer(final k=
        mWat_flow_min)
    "Minimum flow rate to avoid a division by zero if mass flow measurement is zero"
    annotation (Placement(transformation(extent={{-360,-116},{-340,-96}})));
  Buildings.Controls.OBC.CDL.Reals.Divide ratFlo
    "Ratio of plant over heat pump flow rate"
    annotation (Placement(transformation(extent={{-280,-80},{-260,-60}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract dTSetHeaPumIn
    "Temperature difference heat pump set point minus inlet temperature"
    annotation (Placement(transformation(extent={{-240,20},{-220,40}})));
  Buildings.Controls.OBC.CDL.Reals.Multiply mul "Multiply inputs"
    annotation (Placement(transformation(extent={{-200,-50},{-180,-30}})));
  Buildings.Controls.OBC.CDL.Reals.Add TLeaWatSet(y(displayUnit="degC", unit=
          "K")) "Heat pump leaving water temperature setpoint"
    annotation (Placement(transformation(extent={{-160,20},{-140,40}})));

  Buildings.Controls.OBC.CDL.Reals.PIDWithReset conPIDHea(
    final controllerType=heaPumConTyp,
    final k=kHeaPum,
    final Ti=TiHeaPum,
    final Td=TdHeaPum,
    final y_reset=1.5*minComSpe,
    u_s(final unit="K", displayUnit="degC"),
    u_m(final unit="K", displayUnit="degC"))
    "Heat pump controller for heating mode"
    annotation (Placement(transformation(extent={{40,40},{60,60}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset conPIDCoo(
    final controllerType=heaPumConTyp,
    final k=kHeaPum,
    final Ti=TiHeaPum,
    final Td=TdHeaPum,
    reverseActing=false,
    final y_reset=1.5*minComSpe) "Heat pump controller for cooling mode"
    annotation (Placement(transformation(extent={{40,0},{60,20}})));
  Buildings.Controls.OBC.CDL.Reals.Switch conPID
    "Switch to select output from heating or cooling PID controller"
    annotation (Placement(transformation(extent={{100,60},{120,80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(final k=0) "Zero"
    annotation (Placement(transformation(extent={{120,160},{140,180}})));
  Buildings.Controls.OBC.CDL.Logical.Pre pre "Break loop"
    annotation (Placement(transformation(extent={{-280,-180},{-260,-160}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay delChe(
    final delayTime=holOnTim)
    "After the minimum on time is passed, then do the check"
    annotation (Placement(transformation(extent={{-240,-180},{-220,-160}})));
  Buildings.Controls.OBC.CDL.Reals.LessThreshold lesThr(
    final t=minComSpe, final h=0.1*minComSpe)
    "Check if the compressor speed is lower than the minimum"
    annotation (Placement(transformation(extent={{-220,-140},{-200,-120}})));
  Buildings.Controls.OBC.CDL.Logical.And disHeaPum
    "Check if the heat pump should be disabled"
    annotation (Placement(transformation(extent={{-180,-140},{-160,-120}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay truDel(
    final delayTime=del)
    "Check if the compressor has been in minimum speed for sufficient time"
    annotation (Placement(transformation(extent={{-140,-140},{-120,-120}})));
  Buildings.Controls.OBC.CDL.Logical.Edge edg
    "Trigger the pulse to disable heat pump"
    annotation (Placement(transformation(extent={{-100,-140},{-80,-120}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold offHeaPum(
    final trueHoldDuration=offTim,
    final falseHoldDuration=0) "Keep heat pump being off for sufficient time"
    annotation (Placement(transformation(extent={{-60,-140},{-40,-120}})));
  Buildings.Controls.OBC.CDL.Logical.Not not1 "Not disabled"
    annotation (Placement(transformation(extent={{-20,-140},{0,-120}})));
  Buildings.Controls.OBC.CDL.Logical.And and2
    "Enabled heat pump "
    annotation (Placement(transformation(extent={{120,-120},{140,-100}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold holHeaPum(
    final trueHoldDuration=holOnTim,
    final falseHoldDuration=holOffTim)
    "Hold heat pump status for sufficient time"
    annotation (Placement(transformation(extent={{160,-120},{180,-100}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHeaPum
    "Enable heat pump"
    annotation (Placement(transformation(extent={{40,-100},{60,-80}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{220,110},{240,130}})));
  Buildings.Controls.OBC.CDL.Logical.Not norRat "Normal electricity rate"
    annotation (Placement(transformation(extent={{-300,360},{-280,380}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSpr "Normal rate in Spring"
    annotation (Placement(transformation(extent={{-120,360},{-100,380}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatFal "Normal rate in Fall"
    annotation (Placement(transformation(extent={{-120,320},{-100,340}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant desLooMin(
    y(unit="K", displayUnit="degC"),
    final k=TLooMin)
    "Design minimum district loop temperature"
    annotation (Placement(transformation(extent={{-180,280},{-160,300}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant desLooMax(
    y(unit="K", displayUnit="degC"),
    final k=TLooMax)
    "Design maximum district loop temperature"
    annotation (Placement(transformation(extent={{-180,200},{-160,220}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar(
    final p=-4)
    "4 degree lower than the inlet temperature"
    annotation (Placement(transformation(extent={{-180,240},{-160,260}})));
  Buildings.Controls.OBC.CDL.Reals.Max max1
    annotation (Placement(transformation(extent={{-120,260},{-100,280}})));
  Buildings.Controls.OBC.CDL.Reals.Min min1
    annotation (Placement(transformation(extent={{-120,180},{-100,200}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter addPar1(
    final p=4)
    "4 degree higher than the inlet temperature"
    annotation (Placement(transformation(extent={{-180,160},{-160,180}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHeaPumForBor
    "Enable borefield for borefields"
    annotation (Placement(transformation(extent={{-40,360},{-20,380}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi3
    "Heat pump leaving water temperature when the heat pump is used for charging borefields"
    annotation (Placement(transformation(extent={{-40,220},{-20,240}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi4(y(displayUnit="degC", unit="K"))
    annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi5
    "Heat pump leaving water temperature when the heat pump is used for charging borefields"
    annotation (Placement(transformation(extent={{40,180},{60,200}})));
  Buildings.Controls.OBC.CDL.Logical.Or inHeaMod "In heating mode"
    annotation (Placement(transformation(extent={{20,100},{40,120}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal heaModInd
    "Heating mode index"
    annotation (Placement(transformation(extent={{120,260},{140,280}})));
  Buildings.Controls.OBC.CDL.Discrete.TriggeredSampler triSam(y_start=1)
    annotation (Placement(transformation(extent={{190,260},{210,280}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(t=0.5)
    annotation (Placement(transformation(extent={{240,260},{260,280}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal isoVal
    "Heat pump isolation valve position"
    annotation (Placement(transformation(extent={{380,-10},{400,10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minConInTem(
    final k=TConInMin)
    "Minimum condenser inlet temperature"
    annotation (Placement(transformation(extent={{-180,-280},{-160,-260}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant maxEvaInlTem(
    final k=TEvaInMax)
    "Maximum evaporator inlet temperature"
    annotation (Placement(transformation(extent={{-220,-250},{-200,-230}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi7
    annotation (Placement(transformation(extent={{-120,-260},{-100,-240}})));
  Buildings.Controls.OBC.CDL.Reals.Switch entGlyTem
    "Heat pump glycol entering temperature setpoint"
    annotation (Placement(transformation(extent={{-40,-290},{-20,-270}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub2
    annotation (Placement(transformation(extent={{20,-310},{40,-290}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(final k=-1)
    "Reverse"
    annotation (Placement(transformation(extent={{60,-350},{80,-330}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi6
    annotation (Placement(transformation(extent={{100,-330},{120,-310}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer2(final k=0)
    "Zero"
    annotation (Placement(transformation(extent={{100,-270},{120,-250}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset thrWayValCon(
    final controllerType=thrWayValConTyp,
    final k=kVal,
    final Ti=TiVal,
    final Td=TdVal,
    reverseActing=false,
    final y_reset=1)
    "Three way valve controller, larger output means larger bypass flow"
    annotation (Placement(transformation(extent={{220,-270},{240,-250}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one3(final k=1)
    "One"
    annotation (Placement(transformation(extent={{220,-360},{240,-340}})));
  Buildings.Controls.OBC.CDL.Reals.Switch thrWayVal
    "Heat pump glycol side 3-way valve"
    annotation (Placement(transformation(extent={{300,-310},{320,-290}})));
  Buildings.Controls.OBC.CDL.Reals.Switch higLoaModFlo
    "Mass flow rate setpoint if the heat pump is enabeld due to the high load"
    annotation (Placement(transformation(extent={{60,-390},{80,-370}})));
  Buildings.Controls.OBC.CDL.Reals.Switch higLoaModFlo1
    "Mass flow rate setpoint if the heat pump is enabeld due to the high load"
    annotation (Placement(transformation(extent={{280,-430},{300,-410}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mWat_flow_nominal) "Convert mass flow rate"
    annotation (Placement(transformation(extent={{-380,-370},{-360,-350}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minWatRat(
    final k=mWat_flow_min)
    "Minimum water flow through heat pump"
    annotation (Placement(transformation(extent={{60,-430},{80,-410}})));
  Buildings.Controls.OBC.CDL.Reals.Max max2
    "Ensure minimum flow through heat pump"
    annotation (Placement(transformation(extent={{120,-410},{140,-390}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(final k=1)
    "Constant one"
    annotation (Placement(transformation(extent={{-120,-410},{-100,-390}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai3(
    final k=mBorFieCen_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{-80,-410},{-60,-390}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant one1(final k=0) "zero"
    annotation (Placement(transformation(extent={{220,-460},{240,-440}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant minSpe(final k=minComSpe)
    "Minimum compressor speed"
    annotation (Placement(transformation(extent={{120,220},{140,240}})));
  Buildings.Controls.OBC.CDL.Reals.Max max3
    "Ensure minimum heat pump compressor speed"
    annotation (Placement(transformation(extent={{220,200},{240,220}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi8
    annotation (Placement(transformation(extent={{260,184},{280,204}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi9(y(displayUnit="degC", unit="K"))
    annotation (Placement(transformation(extent={{-100,0},{-80,20}})));
  Buildings.Controls.OBC.CDL.Logical.Not expDis
    "Heat pump is expected to be disabled"
    annotation (Placement(transformation(extent={{160,-90},{180,-70}})));
  Buildings.Controls.OBC.CDL.Logical.And and1
    "Enabled heat pump "
    annotation (Placement(transformation(extent={{220,-90},{240,-70}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi10
    annotation (Placement(transformation(extent={{300,-60},{320,-40}})));
  Buildings.Controls.OBC.CDL.Logical.Switch heaPumMod "Heat pump mode"
    annotation (Placement(transformation(extent={{60,120},{80,140}})));
  Buildings.Controls.OBC.CDL.Logical.And higHeaLoa "High heating load"
    annotation (Placement(transformation(extent={{-180,80},{-160,100}})));
  Buildings.Controls.OBC.CDL.Logical.TrueFalseHold minOff(final
      trueHoldDuration=holOffTim, final falseHoldDuration=0)
    "Keep heat pump being off for minimum off time"
    annotation (Placement(transformation(extent={{-60,-180},{-40,-160}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaHeaPum1
    "Enable heat pump"
    annotation (Placement(transformation(extent={{80,-140},{100,-120}})));
  Buildings.Controls.OBC.CDL.Logical.And and3
    "Passed minimum off time and the plant load is high"
    annotation (Placement(transformation(extent={{40,-180},{60,-160}})));
  Buildings.Controls.OBC.CDL.Logical.Not pasMinOff "Passed minimum off time"
    annotation (Placement(transformation(extent={{-20,-180},{0,-160}})));

  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter mSetHPGly_flow(final k=
        mHeaPumGly_flow_nominal/mWat_flow_nominal)
    "Set point for heat pump glycol pump mass flow rate"
    annotation (Placement(transformation(extent={{380,30},{400,50}})));
  FalseDelay delValDis(final delayTime=watPumRis + heaPumRisTim)
    "Delay disabling the valve"
    annotation (Placement(transformation(extent={{220,-10},{240,10}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay delHeaPumOn(delayTime=
        isoValStrTim + watPumRis) "Delay enabling heat pum"
    annotation (Placement(transformation(extent={{220,70},{240,90}})));
  Buildings.Controls.OBC.CDL.Reals.LimitSlewRate ramLim(final raisingSlewRate=1/
        heaPumRisTim) "Limit the change rate of the heat pump compressor speed"
    annotation (Placement(transformation(extent={{382,-150},{402,-130}})));
  TrueFalseDelay delWatPum(final delayTrueTime=isoValStrTim, final
      delayFalseTime=heaPumRisTim) "Delay waterside pump"
    annotation (Placement(transformation(extent={{220,-430},{240,-410}})));
  Buildings.Controls.OBC.CDL.Logical.TrueDelay delBypVal(delayTime=isoValStrTim
         + watPumRis) "Delay enabling bypass valve"
    annotation (Placement(transformation(extent={{160,-310},{180,-290}})));
  Buildings.Controls.OBC.CDL.Reals.Max mHeaPum_flow_nonZero
    "Heat pump mass flow rate, bounded away from zero"
    annotation (Placement(transformation(extent={{-320,-110},{-300,-90}})));
  Buildings.Controls.OBC.CDL.Reals.Switch higLoaModFlo2
    "Mass flow rate setpoint if the heat pump is enabeld due to the high load"
    annotation (Placement(transformation(extent={{360,-490},{380,-470}})));

equation
  connect(uEleRat, higEleRat.u1)
    annotation (Line(points={{-440,470},{-362,470}}, color={255,127,0}));
  connect(higRat.y, higEleRat.u2) annotation (Line(points={{-378,540},{-370,540},
          {-370,462},{-362,462}}, color={255,127,0}));
  connect(higLoa.y, higPlaLoa.u1) annotation (Line(points={{-318,540},{-310,540},
          {-310,470},{-302,470}}, color={255,127,0}));
  connect(uSt, higPlaLoa.u2) annotation (Line(points={{-440,430},{-310,430},{-310,
          462},{-302,462}},      color={255,127,0}));
  connect(spr.y, inSpr.u1) annotation (Line(points={{-238,540},{-220,540},{-220,
          440},{-182,440}}, color={255,127,0}));
  connect(fal.y, inFal.u1) annotation (Line(points={{-238,500},{-230,500},{-230,
          410},{-182,410}}, color={255,127,0}));
  connect(uSea, inSpr.u2) annotation (Line(points={{-440,390},{-240,390},{-240,432},
          {-182,432}},      color={255,127,0}));
  connect(uSea, inFal.u2) annotation (Line(points={{-440,390},{-240,390},{-240,402},
          {-182,402}},      color={255,127,0}));
  connect(heaSet.y, aveSet.u1) annotation (Line(points={{-378,100},{-370,100},{-370,
          86},{-362,86}},        color={0,0,127}));
  connect(TPlaIn, heaMod.u1) annotation (Line(points={{-440,150},{-322,150}},
                                 color={0,0,127}));
  connect(aveSet.y, heaMod.u2) annotation (Line(points={{-338,80},{-330,80},{-330,
          142},{-322,142}},      color={0,0,127}));
  connect(heaMod.y, plaSet.u2) annotation (Line(points={{-298,150},{-290,150},{-290,
          50},{-282,50}},        color={255,0,255}));
  connect(heaSet.y, plaSet.u1) annotation (Line(points={{-378,100},{-320,100},{-320,
          58},{-282,58}},        color={0,0,127}));
  connect(mPla_flow, ratFlo.u1) annotation (Line(points={{-440,-50},{-290,-50},{
          -290,-64},{-282,-64}},    color={0,0,127}));
  connect(plaSet.y, dTSetHeaPumIn.u1) annotation (Line(points={{-258,50},{-254,50},
          {-254,36},{-242,36}},   color={0,0,127}));
  connect(THeaPumIn, dTSetHeaPumIn.u2) annotation (Line(points={{-440,10},{-250,
          10},{-250,24},{-242,24}},    color={0,0,127}));
  connect(dTSetHeaPumIn.y, mul.u1) annotation (Line(points={{-218,30},{-210,30},
          {-210,-34},{-202,-34}}, color={0,0,127}));
  connect(ratFlo.y, mul.u2) annotation (Line(points={{-258,-70},{-250,-70},{-250,
          -46},{-202,-46}}, color={0,0,127}));
  connect(THeaPumIn, TLeaWatSet.u1) annotation (Line(points={{-440,10},{-200,10},
          {-200,36},{-162,36}},   color={0,0,127}));
  connect(mul.y, TLeaWatSet.u2) annotation (Line(points={{-178,-40},{-170,-40},{
          -170,24},{-162,24}},    color={0,0,127}));
  connect(and2.y,pre. u) annotation (Line(points={{142,-110},{150,-110},{150,-190},
          {-300,-190},{-300,-170},{-282,-170}},
                                            color={255,0,255}));
  connect(enaHeaPum.y, and2.u1) annotation (Line(points={{62,-90},{110,-90},{110,
          -110},{118,-110}},color={255,0,255}));
  connect(lesThr.y, disHeaPum.u1)
    annotation (Line(points={{-198,-130},{-182,-130}}, color={255,0,255}));
  connect(disHeaPum.y, truDel.u)
    annotation (Line(points={{-158,-130},{-142,-130}}, color={255,0,255}));
  connect(truDel.y, edg.u)
    annotation (Line(points={{-118,-130},{-102,-130}}, color={255,0,255}));
  connect(edg.y, offHeaPum.u)
    annotation (Line(points={{-78,-130},{-62,-130}},   color={255,0,255}));
  connect(offHeaPum.y, not1.u)
    annotation (Line(points={{-38,-130},{-22,-130}}, color={255,0,255}));
  connect(pre.y, delChe.u)
    annotation (Line(points={{-258,-170},{-242,-170}}, color={255,0,255}));
  connect(delChe.y, disHeaPum.u2) annotation (Line(points={{-218,-170},{-190,-170},
          {-190,-138},{-182,-138}},       color={255,0,255}));
  connect(and2.y, holHeaPum.u)
    annotation (Line(points={{142,-110},{158,-110}},
                                                   color={255,0,255}));
  connect(zer.y, swi1.u3) annotation (Line(points={{142,170},{160,170},{160,112},
          {218,112}},color={0,0,127}));
  connect(swi1.y, lesThr.u) annotation (Line(points={{242,120},{250,120},{250,-60},
          {-240,-60},{-240,-130},{-222,-130}},  color={0,0,127}));
  connect(higEleRat.y, norRat.u) annotation (Line(points={{-338,470},{-320,470},
          {-320,370},{-302,370}}, color={255,0,255}));
  connect(norRat.y, norRatSpr.u2) annotation (Line(points={{-278,370},{-180,370},
          {-180,362},{-122,362}},color={255,0,255}));
  connect(inSpr.y, norRatSpr.u1) annotation (Line(points={{-158,440},{-140,440},
          {-140,370},{-122,370}},color={255,0,255}));
  connect(norRat.y, norRatFal.u2) annotation (Line(points={{-278,370},{-180,370},
          {-180,322},{-122,322}},color={255,0,255}));
  connect(inFal.y, norRatFal.u1) annotation (Line(points={{-158,410},{-150,410},
          {-150,330},{-122,330}},color={255,0,255}));
  connect(THeaPumIn, addPar.u) annotation (Line(points={{-440,10},{-200,10},{-200,
          250},{-182,250}}, color={0,0,127}));
  connect(addPar.y, max1.u2) annotation (Line(points={{-158,250},{-140,250},{-140,
          264},{-122,264}},color={0,0,127}));
  connect(desLooMin.y, max1.u1) annotation (Line(points={{-158,290},{-140,290},{
          -140,276},{-122,276}},color={0,0,127}));
  connect(desLooMax.y, min1.u1) annotation (Line(points={{-158,210},{-140,210},{
          -140,196},{-122,196}},color={0,0,127}));
  connect(addPar1.y, min1.u2) annotation (Line(points={{-158,170},{-140,170},{-140,
          184},{-122,184}},color={0,0,127}));
  connect(THeaPumIn, addPar1.u) annotation (Line(points={{-440,10},{-200,10},{-200,
          170},{-182,170}},      color={0,0,127}));
  connect(norRatSpr.y, enaHeaPumForBor.u1)
    annotation (Line(points={{-98,370},{-42,370}},color={255,0,255}));
  connect(norRatFal.y, enaHeaPumForBor.u2) annotation (Line(points={{-98,330},{-60,
          330},{-60,362},{-42,362}},color={255,0,255}));
  connect(norRatSpr.y, swi3.u2) annotation (Line(points={{-98,370},{-70,370},{-70,
          230},{-42,230}},color={255,0,255}));
  connect(max1.y, swi3.u1) annotation (Line(points={{-98,270},{-80,270},{-80,238},
          {-42,238}},color={0,0,127}));
  connect(min1.y, swi3.u3) annotation (Line(points={{-98,190},{-80,190},{-80,222},
          {-42,222}},color={0,0,127}));
  connect(enaHeaPumForBor.y, enaHeaPum.u2) annotation (Line(points={{-18,370},{0,
          370},{0,-98},{38,-98}},    color={255,0,255}));
  connect(higPlaLoa.y, enaHeaPum.u1) annotation (Line(points={{-278,470},{10,470},
          {10,-90},{38,-90}},   color={255,0,255}));
  connect(higPlaLoa.y, swi4.u2) annotation (Line(points={{-278,470},{-250,470},{
          -250,50},{-62,50}}, color={255,0,255}));
  connect(swi3.y, swi5.u1) annotation (Line(points={{-18,230},{20,230},{20,198},
          {38,198}},color={0,0,127}));
  connect(enaHeaPumForBor.y, swi5.u2) annotation (Line(points={{-18,370},{0,370},
          {0,190},{38,190}},  color={255,0,255}));
  connect(THeaPumOut, swi5.u3) annotation (Line(points={{-440,-20},{-20,-20},{-20,
          182},{38,182}}, color={0,0,127}));
  connect(swi5.y, swi4.u3) annotation (Line(points={{62,190},{80,190},{80,170},{
          -80,170},{-80,42},{-62,42}},  color={0,0,127}));
  connect(heaModInd.y, triSam.u)
    annotation (Line(points={{142,270},{188,270}}, color={0,0,127}));
  connect(triSam.y, greThr.u)
    annotation (Line(points={{212,270},{238,270}}, color={0,0,127}));
  connect(greThr.y, y1Mod)
    annotation (Line(points={{262,270},{440,270}}, color={255,0,255}));
  connect(isoVal.y, yVal)
    annotation (Line(points={{402,0},{440,0}},     color={0,0,127}));
  connect(greThr.y, swi7.u2) annotation (Line(points={{262,270},{288,270},{288,-220},
          {-150,-220},{-150,-250},{-122,-250}},color={255,0,255}));
  connect(maxEvaInlTem.y, swi7.u1) annotation (Line(points={{-198,-240},{-140,-240},
          {-140,-242},{-122,-242}},color={0,0,127}));
  connect(minConInTem.y, swi7.u3) annotation (Line(points={{-158,-270},{-140,-270},
          {-140,-258},{-122,-258}},color={0,0,127}));
  connect(swi7.y, entGlyTem.u1) annotation (Line(points={{-98,-250},{-80,-250},{
          -80,-272},{-42,-272}},color={0,0,127}));
  connect(TGlyIn, entGlyTem.u3) annotation (Line(points={{-440,-320},{-120,-320},
          {-120,-288},{-42,-288}},
                                 color={0,0,127}));
  connect(entGlyTem.y, sub2.u1) annotation (Line(points={{-18,-280},{-8,-280},{-8,
          -294},{18,-294}}, color={0,0,127}));
  connect(TGlyIn, sub2.u2) annotation (Line(points={{-440,-320},{-120,-320},{-120,
          -306},{18,-306}}, color={0,0,127}));
  connect(sub2.y, gai1.u) annotation (Line(points={{42,-300},{52,-300},{52,-340},
          {58,-340}}, color={0,0,127}));
  connect(sub2.y, swi6.u1) annotation (Line(points={{42,-300},{52,-300},{52,-312},
          {98,-312}},  color={0,0,127}));
  connect(gai1.y, swi6.u3) annotation (Line(points={{82,-340},{92,-340},{92,-328},
          {98,-328}},  color={0,0,127}));
  connect(greThr.y, swi6.u2) annotation (Line(points={{262,270},{288,270},{288,-220},
          {80,-220},{80,-320},{98,-320}},    color={255,0,255}));
  connect(zer2.y, thrWayValCon.u_s)
    annotation (Line(points={{122,-260},{218,-260}}, color={0,0,127}));
  connect(swi6.y, thrWayValCon.u_m) annotation (Line(points={{122,-320},{230,-320},
          {230,-272}}, color={0,0,127}));
  connect(thrWayValCon.y, thrWayVal.u1) annotation (Line(points={{242,-260},{250,
          -260},{250,-292},{298,-292}}, color={0,0,127}));
  connect(one3.y, thrWayVal.u3) annotation (Line(points={{242,-350},{250,-350},{
          250,-308},{298,-308}}, color={0,0,127}));
  connect(thrWayVal.y, yValByp)
    annotation (Line(points={{322,-300},{440,-300}}, color={0,0,127}));
  connect(higPlaLoa.y, higLoaModFlo.u2) annotation (Line(points={{-278,470},{10,
          470},{10,-380},{58,-380}}, color={255,0,255}));
  connect(uDisPum, gai2.u)
    annotation (Line(points={{-440,-360},{-382,-360}}, color={0,0,127}));
  connect(gai2.y, higLoaModFlo.u1) annotation (Line(points={{-358,-360},{-20,-360},
          {-20,-372},{58,-372}},color={0,0,127}));
  connect(con.y, gai3.u)
    annotation (Line(points={{-98,-400},{-82,-400}}, color={0,0,127}));
  connect(gai3.y, higLoaModFlo.u3) annotation (Line(points={{-58,-400},{-40,
          -400},{-40,-388},{58,-388}},
                               color={0,0,127}));
  connect(higLoaModFlo.y, max2.u1) annotation (Line(points={{82,-380},{100,-380},
          {100,-394},{118,-394}}, color={0,0,127}));
  connect(minWatRat.y, max2.u2) annotation (Line(points={{82,-420},{100,-420},{100,
          -406},{118,-406}},     color={0,0,127}));
  connect(max2.y, higLoaModFlo1.u1) annotation (Line(points={{142,-400},{250,-400},
          {250,-412},{278,-412}}, color={0,0,127}));
  connect(one1.y, higLoaModFlo1.u3) annotation (Line(points={{242,-450},{250,-450},
          {250,-428},{278,-428}}, color={0,0,127}));
  connect(minSpe.y, max3.u1) annotation (Line(points={{142,230},{210,230},{210,216},
          {218,216}}, color={0,0,127}));
  connect(max3.y, swi8.u1) annotation (Line(points={{242,210},{250,210},{250,202},
          {258,202}}, color={0,0,127}));
  connect(zer.y, swi8.u3) annotation (Line(points={{142,170},{160,170},{160,186},
          {258,186}},color={0,0,127}));
  connect(TLeaWatSet.y, swi9.u1) annotation (Line(points={{-138,30},{-120,30},{-120,
          18},{-102,18}},      color={0,0,127}));
  connect(THeaPumOut, swi9.u3) annotation (Line(points={{-440,-20},{-140,-20},{-140,
          2},{-102,2}},         color={0,0,127}));
  connect(swi9.y, swi4.u1) annotation (Line(points={{-78,10},{-70,10},{-70,58},{
          -62,58}},  color={0,0,127}));
  connect(enaHeaPum.y, expDis.u) annotation (Line(points={{62,-90},{110,-90},{110,
          -80},{158,-80}},        color={255,0,255}));
  connect(expDis.y, and1.u1)
    annotation (Line(points={{182,-80},{218,-80}},   color={255,0,255}));
  connect(and1.y, swi10.u2) annotation (Line(points={{242,-80},{260,-80},{260,-50},
          {298,-50}},        color={255,0,255}));
  connect(swi8.y, swi10.u3) annotation (Line(points={{282,194},{300,194},{300,110},
          {280,110},{280,-58},{298,-58}},      color={0,0,127}));
  connect(minSpe.y, swi10.u1) annotation (Line(points={{142,230},{210,230},{210,
          -42},{298,-42}}, color={0,0,127}));
  connect(higPlaLoa.y, heaPumMod.u2) annotation (Line(points={{-278,470},{-250,470},
          {-250,130},{58,130}},color={255,0,255}));
  connect(heaMod.y, heaPumMod.u1) annotation (Line(points={{-298,150},{40,150},{
          40,138},{58,138}},color={255,0,255}));
  connect(heaMod.y, higHeaLoa.u2) annotation (Line(points={{-298,150},{-290,150},
          {-290,82},{-182,82}}, color={255,0,255}));
  connect(higPlaLoa.y, higHeaLoa.u1) annotation (Line(points={{-278,470},{-250,470},
          {-250,90},{-182,90}}, color={255,0,255}));
  connect(higHeaLoa.y, inHeaMod.u2) annotation (Line(points={{-158,90},{-140,90},
          {-140,102},{18,102}},
                              color={255,0,255}));
  connect(norRatFal.y, inHeaMod.u1) annotation (Line(points={{-98,330},{-60,330},
          {-60,110},{18,110}},
                             color={255,0,255}));
  connect(inHeaMod.y, heaPumMod.u3) annotation (Line(points={{42,110},{50,110},{
          50,122},{58,122}},
                         color={255,0,255}));
  connect(heaPumMod.y, heaModInd.u) annotation (Line(points={{82,130},{90,130},{
          90,270},{118,270}},  color={255,0,255}));
  connect(greThr.y, conPID.u2) annotation (Line(points={{262,270},{288,270},{288,
          50},{92,50},{92,70},{98,70}},      color={255,0,255}));
  connect(minOff.y, pasMinOff.u)
    annotation (Line(points={{-38,-170},{-22,-170}},
                                                  color={255,0,255}));
  connect(pasMinOff.y, and3.u1)
    annotation (Line(points={{2,-170},{38,-170}},  color={255,0,255}));
  connect(edg.y, minOff.u) annotation (Line(points={{-78,-130},{-70,-130},{-70,-170},
          {-62,-170}},       color={255,0,255}));
  connect(higPlaLoa.y, and3.u2) annotation (Line(points={{-278,470},{10,470},{10,
          -178},{38,-178}},    color={255,0,255}));
  connect(not1.y, enaHeaPum1.u1)
    annotation (Line(points={{2,-130},{78,-130}},   color={255,0,255}));
  connect(and3.y, enaHeaPum1.u2) annotation (Line(points={{62,-170},{70,-170},{70,
          -138},{78,-138}},       color={255,0,255}));
  connect(enaHeaPum1.y, and2.u2) annotation (Line(points={{102,-130},{110,-130},
          {110,-118},{118,-118}}, color={255,0,255}));
  connect(swi4.y, conPIDHea.u_s) annotation (Line(points={{-38,50},{38,50}},
                      color={0,0,127}));
  connect(swi4.y, conPIDCoo.u_s) annotation (Line(points={{-38,50},{20,50},{20,10},
          {38,10}},  color={0,0,127}));
  connect(THeaPumOut, conPIDHea.u_m) annotation (Line(points={{-440,-20},{30,-20},
          {30,34},{50,34},{50,38}},    color={0,0,127}));
  connect(THeaPumOut, conPIDCoo.u_m) annotation (Line(points={{-440,-20},{50,-20},
          {50,-2}},                    color={0,0,127}));
  connect(conPIDHea.y, conPID.u1)
    annotation (Line(points={{62,50},{80,50},{80,78},{98,78}},
                                                   color={0,0,127}));
  connect(conPID.u3, conPIDCoo.y) annotation (Line(points={{98,62},{86,62},{86,10},
          {62,10}},      color={0,0,127}));
  connect(conPID.y, max3.u2) annotation (Line(points={{122,70},{186,70},{186,204},
          {218,204}}, color={0,0,127}));
  connect(conPID.y, swi1.u1) annotation (Line(points={{122,70},{186,70},{186,128},
          {218,128}},color={0,0,127}));
  connect(yPumGly, mSetHPGly_flow.y)
    annotation (Line(points={{440,40},{402,40}},   color={0,0,127}));
  connect(holHeaPum.y, delValDis.u) annotation (Line(points={{182,-110},{200,-110},
          {200,0},{218,0}},     color={255,0,255}));
  connect(delValDis.y, isoVal.u)
    annotation (Line(points={{242,0},{378,0}},     color={255,0,255}));
  connect(holHeaPum.y, delHeaPumOn.u) annotation (Line(points={{182,-110},{200,-110},
          {200,80},{218,80}}, color={255,0,255}));
  connect(delHeaPumOn.y, and1.u2) annotation (Line(points={{242,80},{260,80},{260,
          60},{190,60},{190,-88},{218,-88}},   color={255,0,255}));
  connect(swi10.y, ramLim.u) annotation (Line(points={{322,-50},{360,-50},{360,-140},
          {380,-140}},                             color={0,0,127}));
  connect(ramLim.y, yComSet)
    annotation (Line(points={{404,-140},{440,-140}}, color={0,0,127}));
  connect(holHeaPum.y, delWatPum.u) annotation (Line(points={{182,-110},{200,-110},
          {200,-420},{218,-420}},       color={255,0,255}));
  connect(delWatPum.y, higLoaModFlo1.u2)
    annotation (Line(points={{242,-420},{278,-420}}, color={255,0,255}));
  connect(delBypVal.y, thrWayVal.u2)
    annotation (Line(points={{182,-300},{298,-300}}, color={255,0,255}));
  connect(delBypVal.y, thrWayValCon.trigger) annotation (Line(points={{182,-300},
          {224,-300},{224,-272}}, color={255,0,255}));
  connect(holHeaPum.y, delBypVal.u) annotation (Line(points={{182,-110},{200,-110},
          {200,-280},{150,-280},{150,-300},{158,-300}},       color={255,0,255}));
  connect(delHeaPumOn.y, swi8.u2) annotation (Line(points={{242,80},{260,80},{260,
          170},{240,170},{240,194},{258,194}},     color={255,0,255}));
  connect(delHeaPumOn.y, triSam.trigger) annotation (Line(points={{242,80},{260,
          80},{260,170},{200,170},{200,258}}, color={255,0,255}));
  connect(delHeaPumOn.y, conPIDHea.trigger) annotation (Line(points={{242,80},{260,
          80},{260,60},{190,60},{190,30},{44,30},{44,38}},        color={255,0,
          255}));
  connect(delHeaPumOn.y, conPIDCoo.trigger) annotation (Line(points={{242,80},{260,
          80},{260,60},{190,60},{190,-10},{44,-10},{44,-2}},      color={255,0,
          255}));
  connect(delHeaPumOn.y, swi9.u2) annotation (Line(points={{242,80},{260,80},{260,
          60},{190,60},{190,-30},{-120,-30},{-120,10},{-102,10}},    color={255,
          0,255}));
  connect(delHeaPumOn.y, entGlyTem.u2) annotation (Line(points={{242,80},{260,80},
          {260,60},{190,60},{190,-210},{-60,-210},{-60,-280},{-42,-280}},
        color={255,0,255}));
  connect(delHeaPumOn.y, swi1.u2) annotation (Line(points={{242,80},{260,80},{260,
          100},{200,100},{200,120},{218,120}}, color={255,0,255}));
  connect(delValDis.y, y1On) annotation (Line(points={{242,0},{300,0},{300,80},
          {440,80}},     color={255,0,255}));
  connect(mHeaPum_flow, mHeaPum_flow_nonZero.u1) annotation (Line(points={{-440,
          -80},{-440,-82},{-332,-82},{-332,-94},{-322,-94}},      color={0,0,
          127}));
  connect(minFloDivZer.y, mHeaPum_flow_nonZero.u2)
    annotation (Line(points={{-338,-106},{-322,-106}}, color={0,0,127}));
  connect(mHeaPum_flow_nonZero.y, ratFlo.u2) annotation (Line(points={{-298,-100},
          {-290,-100},{-290,-76},{-282,-76}},         color={0,0,127}));
  connect(higLoaModFlo2.y, yPum)
    annotation (Line(points={{382,-480},{440,-480}}, color={0,0,127}));
  connect(higLoaModFlo2.y, mSetHPGly_flow.u) annotation (Line(points={{382,-480},
          {400,-480},{400,-180},{350,-180},{350,40},{378,40}}, color={0,0,127}));
  connect(and1.y, higLoaModFlo2.u2) annotation (Line(points={{242,-80},{260,-80},
          {260,-480},{358,-480}}, color={255,0,255}));
  connect(higLoaModFlo1.y, higLoaModFlo2.u3) annotation (Line(points={{302,-420},
          {320,-420},{320,-488},{358,-488}}, color={0,0,127}));
  connect(minWatRat.y, higLoaModFlo2.u1) annotation (Line(points={{82,-420},{
          100,-420},{100,-472},{358,-472}}, color={0,0,127}));
  connect(TActPlaCooSet, aveSet.u2) annotation (Line(points={{-440,60},{-380,60},
          {-380,74},{-362,74}}, color={0,0,127}));
  connect(TActPlaCooSet, plaSet.u3) annotation (Line(points={{-440,60},{-380,60},
          {-380,42},{-282,42}}, color={0,0,127}));
annotation (defaultComponentName="heaPumCon",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-120},{100,120}}),
                         graphics={Rectangle(
        extent={{-100,-120},{100,120}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,160},{100,120}},
          textString="%name",
          textColor={0,0,255})}),
                                Diagram(coordinateSystem(preserveAspectRatio=
            false, extent={{-420,-560},{420,560}})));
end HeatPump;
