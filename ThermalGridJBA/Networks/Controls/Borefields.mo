within ThermalGridJBA.Networks.Controls;
block Borefields
  "Sequence for control borefield pumps and the associated valves"

  parameter Real mWat_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal water mass flow rate to the central plant";
  parameter Real mBorFiePer_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal water mass flow rate to the perimeter borefield";
  parameter Real mBorFieCen_flow_nominal(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Nominal water mass flow rate to the center borefield";
  parameter Real mBorFiePer_flow_minimum(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Minimum water mass flow rate to the perimeter borefield to get turbulent flow";
  parameter Real mBorFieCen_flow_minimum(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Minimum water mass flow rate to the center borefield to get turbulent flow";

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uEleRat
    "Electricity rate indicator. 0-normal rate; 1-high rate"
    annotation (Placement(transformation(extent={{-300,160},{-260,200}}),
        iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSt
    "Plant load indicator. 1-low load; 2-medium load; 3-high load"
    annotation (Placement(transformation(extent={{-300,120},{-260,160}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uSea
    "Season indicator. 1-Winter; 2-Spring; 3-Summer; 4-Fall"
    annotation (Placement(transformation(extent={{-300,80},{-260,120}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1SumCooBor
    "=true for cooling down borefield in summer"
    annotation (Placement(transformation(extent={{-300,0},{-260,40}}),
        iconTransformation(extent={{-140,-10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum(
    final unit="1",
    final min=0,
    final max=1)
    "District pump norminal speed"
    annotation (Placement(transformation(extent={{-300,-140},{-260,-100}}),
        iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPum
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{-300,-300},{-260,-260}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mHeaPum_flow(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat pump mass flow rate"
    annotation (Placement(transformation(extent={{-300,-270},{-260,-230}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValPriByp(
    final min=0,
    final max=1,
    final unit="1") "Primary bypass valve position setpoint"
    annotation (Placement(transformation(extent={{260,-20},{300,20}}),
        iconTransformation(extent={{100,60},{140,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValIso(
    final min=0,
    final max=1,
    final unit="1") "Secondary loop isolation valve position"
    annotation (Placement(transformation(extent={{260,-60},{300,-20}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumPerBor(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint for the pump of the perimeter borefield"
    annotation (Placement(transformation(extent={{260,-140},{300,-100}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumPri(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint for the pump of the primary loop"
    annotation (Placement(transformation(extent={{260,-170},{300,-130}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumCenBor(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint for the pump of the center borefield"
    annotation (Placement(transformation(extent={{260,-220},{300,-180}}),
        iconTransformation(extent={{100,-80},{140,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumSec(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint for the pump of the secondary loop"
    annotation (Placement(transformation(extent={{260,-260},{300,-220}}),
        iconTransformation(extent={{100,-110},{140,-70}})));

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-240,290},{-220,310}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(final k=1) "Winter"
    annotation (Placement(transformation(extent={{-140,290},{-120,310}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum(final k=3) "Summer"
    annotation (Placement(transformation(extent={{-140,230},{-120,250}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higEleRat "High electricity rate"
    annotation (Placement(transformation(extent={{-200,170},{-180,190}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin "In Winter"
    annotation (Placement(transformation(extent={{-80,170},{-60,190}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum "In Summer"
    annotation (Placement(transformation(extent={{-80,110},{-60,130}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High plant load"
    annotation (Placement(transformation(extent={{-200,290},{-180,310}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant spr(final k=2) "Spring"
    annotation (Placement(transformation(extent={{-140,260},{-120,280}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant fal(final k=4) "Fall"
    annotation (Placement(transformation(extent={{-140,200},{-120,220}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higPlaLoa "High plant load"
    annotation (Placement(transformation(extent={{-160,150},{-140,170}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSpr "In Spring"
    annotation (Placement(transformation(extent={{-80,140},{-60,160}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inFal "In Fall"
    annotation (Placement(transformation(extent={{-80,80},{-60,100}})));
  Buildings.Controls.OBC.CDL.Logical.Not norRat "Normal rate"
    annotation (Placement(transformation(extent={{-160,50},{-140,70}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSpr "Normal rate in Spring"
    annotation (Placement(transformation(extent={{0,60},{20,80}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatFal "Normal rate in Fall"
    annotation (Placement(transformation(extent={{0,30},{20,50}})));
  Buildings.Controls.OBC.CDL.Logical.Or onlPer1
    "Only use perimeter borefield to cool or heat loop water"
    annotation (Placement(transformation(extent={{40,60},{60,80}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatWin "Normal rate in Winter"
    annotation (Placement(transformation(extent={{40,-30},{60,-10}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSum "Normal rate in Summer"
    annotation (Placement(transformation(extent={{-20,-90},{0,-70}})));
  Buildings.Controls.OBC.CDL.Logical.Or botBor
    "Use both perimeter and center borefields to cool or heat loop water"
    annotation (Placement(transformation(extent={{80,-30},{100,-10}})));
  Buildings.Controls.OBC.CDL.Logical.Or botBor1
    "Enable both perimeter and center borefields"
    annotation (Placement(transformation(extent={{140,-10},{160,10}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(
    final k=mBorFiePer_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{-140,-130},{-120,-110}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(
    final k=mWat_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{-140,-160},{-120,-140}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal byPasPri(
    final realTrue=0,
    final realFalse=1)
    "Bypass valve position"
    annotation (Placement(transformation(extent={{220,-10},{240,10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal isoSec
    "Secondary loop isolation valve"
    annotation (Placement(transformation(extent={{220,-50},{240,-30}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mBorFieCen_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{-140,-208},{-120,-188}})));
  Buildings.Controls.OBC.CDL.Reals.Switch cenBorPum
    "Speed setpoint for the pump of center borfield "
    annotation (Placement(transformation(extent={{180,-210},{200,-190}})));
  Buildings.Controls.OBC.CDL.Reals.Switch secLooPum
    "Speed setpoint for the pump of secondary loop"
    annotation (Placement(transformation(extent={{180,-250},{200,-230}})));
  Buildings.Controls.OBC.CDL.Reals.Switch cenBorPum1
    "Speed setpoint for the pump of center borfield "
    annotation (Placement(transformation(extent={{120,-270},{140,-250}})));
  Buildings.Controls.OBC.CDL.Reals.Switch secLooPum1
    "Speed setpoint for the pump of secondary loop"
    annotation (Placement(transformation(extent={{120,-310},{140,-290}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(final k=0)
    "Constant zero"
    annotation (Placement(transformation(extent={{-180,-310},{-160,-290}})));
  Buildings.Controls.OBC.CDL.Reals.Switch heaPumFlo
    "Speed setpoint for the pumps to ensure same flow"
    annotation (Placement(transformation(extent={{-80,-290},{-60,-270}})));
  Buildings.Controls.OBC.CDL.Logical.Not notCooBor
    "Not cooling down borefield in summer"
    annotation (Placement(transformation(extent={{-140,-70},{-120,-50}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSum1
    "Normal rate in Summer but not cooling borefield with heat pump"
    annotation (Placement(transformation(extent={{40,-70},{60,-50}})));
  Buildings.Controls.OBC.CDL.Logical.Or onlPer2
    "Only use perimeter borefield to cool or heat loop water"
    annotation (Placement(transformation(extent={{80,60},{100,80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant mPer_min(final k=
        mBorFiePer_flow_minimum) "Minimum flow rate for perimeter"
    annotation (Placement(transformation(extent={{40,-110},{60,-90}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant mCen_min(final k=
        mBorFieCen_flow_minimum) "Minimum flow rate for center"
    annotation (Placement(transformation(extent={{40,-180},{60,-160}})));
  Buildings.Controls.OBC.CDL.Reals.Max mPer_flow
    "Flow rate for borefield perimeter to ensure turbulent flow"
    annotation (Placement(transformation(extent={{80,-130},{100,-110}})));
  Buildings.Controls.OBC.CDL.Reals.Max mCen_flow
    "Flow rate for borefield center to ensure turbulent flow"
    annotation (Placement(transformation(extent={{80,-202},{100,-182}})));
equation
  connect(higRat.y, higEleRat.u2) annotation (Line(points={{-218,300},{-210,300},
          {-210,172},{-202,172}}, color={255,127,0}));
  connect(uEleRat, higEleRat.u1)
    annotation (Line(points={{-280,180},{-202,180}}, color={255,127,0}));
  connect(higLoa.y, higPlaLoa.u1) annotation (Line(points={{-178,300},{-168,300},
          {-168,160},{-162,160}}, color={255,127,0}));
  connect(uSt, higPlaLoa.u2) annotation (Line(points={{-280,140},{-168,140},{-168,
          152},{-162,152}}, color={255,127,0}));
  connect(win.y, inWin.u1) annotation (Line(points={{-118,300},{-96,300},{-96,180},
          {-82,180}},color={255,127,0}));
  connect(spr.y, inSpr.u1) annotation (Line(points={{-118,270},{-102,270},{-102,
          150},{-82,150}},
                      color={255,127,0}));
  connect(sum.y, inSum.u1) annotation (Line(points={{-118,240},{-108,240},{-108,
          120},{-82,120}},
                      color={255,127,0}));
  connect(fal.y, inFal.u1) annotation (Line(points={{-118,210},{-114,210},{-114,
          90},{-82,90}},
                    color={255,127,0}));
  connect(uSea, inWin.u2) annotation (Line(points={{-280,100},{-120,100},{-120,172},
          {-82,172}},color={255,127,0}));
  connect(uSea, inSpr.u2) annotation (Line(points={{-280,100},{-120,100},{-120,142},
          {-82,142}}, color={255,127,0}));
  connect(uSea, inSum.u2) annotation (Line(points={{-280,100},{-120,100},{-120,112},
          {-82,112}}, color={255,127,0}));
  connect(uSea, inFal.u2) annotation (Line(points={{-280,100},{-120,100},{-120,82},
          {-82,82}},color={255,127,0}));
  connect(higEleRat.y, norRat.u) annotation (Line(points={{-178,180},{-174,180},
          {-174,60},{-162,60}},   color={255,0,255}));
  connect(norRat.y, norRatSpr.u2) annotation (Line(points={{-138,60},{-60,60},{-60,
          62},{-2,62}},      color={255,0,255}));
  connect(norRat.y, norRatFal.u2) annotation (Line(points={{-138,60},{-60,60},{-60,
          32},{-2,32}},        color={255,0,255}));
  connect(inSpr.y, norRatSpr.u1) annotation (Line(points={{-58,150},{-30,150},{-30,
          70},{-2,70}},   color={255,0,255}));
  connect(inFal.y, norRatFal.u1) annotation (Line(points={{-58,90},{-50,90},{-50,
          40},{-2,40}},     color={255,0,255}));
  connect(norRatSpr.y, onlPer1.u1)
    annotation (Line(points={{22,70},{38,70}},     color={255,0,255}));
  connect(norRatFal.y, onlPer1.u2) annotation (Line(points={{22,40},{30,40},{30,
          62},{38,62}},               color={255,0,255}));
  connect(norRat.y, norRatWin.u2) annotation (Line(points={{-138,60},{-60,60},{-60,
          -28},{38,-28}},      color={255,0,255}));
  connect(norRat.y, norRatSum.u2) annotation (Line(points={{-138,60},{-60,60},{-60,
          -88},{-22,-88}},     color={255,0,255}));
  connect(inWin.y, norRatWin.u1) annotation (Line(points={{-58,180},{-20,180},{-20,
          -20},{38,-20}},   color={255,0,255}));
  connect(inSum.y, norRatSum.u1) annotation (Line(points={{-58,120},{-40,120},{-40,
          -80},{-22,-80}},  color={255,0,255}));
  connect(norRatWin.y, botBor.u1)
    annotation (Line(points={{62,-20},{78,-20}},     color={255,0,255}));
  connect(botBor.y, botBor1.u2) annotation (Line(points={{102,-20},{120,-20},{120,
          -8},{138,-8}},          color={255,0,255}));
  connect(uDisPum, gai.u) annotation (Line(points={{-280,-120},{-142,-120}},
                                 color={0,0,127}));
  connect(uDisPum, gai1.u) annotation (Line(points={{-280,-120},{-160,-120},{
          -160,-150},{-142,-150}},
                                 color={0,0,127}));
  connect(gai1.y, yPumPri)
    annotation (Line(points={{-118,-150},{280,-150}},color={0,0,127}));
  connect(botBor1.y, byPasPri.u)
    annotation (Line(points={{162,0},{218,0}},       color={255,0,255}));
  connect(byPasPri.y, yValPriByp)
    annotation (Line(points={{242,0},{280,0}},       color={0,0,127}));
  connect(isoSec.y, yValIso)
    annotation (Line(points={{242,-40},{280,-40}},   color={0,0,127}));
  connect(botBor1.y, isoSec.u) annotation (Line(points={{162,0},{170,0},{170,-40},
          {218,-40}},            color={255,0,255}));
  connect(uDisPum, gai2.u) annotation (Line(points={{-280,-120},{-160,-120},{
          -160,-198},{-142,-198}},
                                 color={0,0,127}));
  connect(botBor1.y, cenBorPum.u2) annotation (Line(points={{162,0},{170,0},{170,
          -200},{178,-200}},            color={255,0,255}));
  connect(botBor1.y, secLooPum.u2) annotation (Line(points={{162,0},{170,0},{170,
          -240},{178,-240}},            color={255,0,255}));
  connect(gai1.y, secLooPum.u1) annotation (Line(points={{-118,-150},{-40,-150},
          {-40,-232},{178,-232}}, color={0,0,127}));
  connect(cenBorPum1.y, cenBorPum.u3) annotation (Line(points={{142,-260},{150,-260},
          {150,-208},{178,-208}},       color={0,0,127}));
  connect(secLooPum1.y, secLooPum.u3) annotation (Line(points={{142,-300},{160,-300},
          {160,-248},{178,-248}},       color={0,0,127}));
  connect(higPlaLoa.y, botBor1.u1) annotation (Line(points={{-138,160},{-130,160},
          {-130,0},{138,0}},        color={255,0,255}));
  connect(con1.y, heaPumFlo.u3) annotation (Line(points={{-158,-300},{-100,-300},
          {-100,-288},{-82,-288}}, color={0,0,127}));
  connect(u1HeaPum, heaPumFlo.u2)
    annotation (Line(points={{-280,-280},{-82,-280}}, color={255,0,255}));
  connect(mHeaPum_flow, heaPumFlo.u1) annotation (Line(points={{-280,-250},{-100,
          -250},{-100,-272},{-82,-272}},      color={0,0,127}));
  connect(heaPumFlo.y, cenBorPum1.u3) annotation (Line(points={{-58,-280},{90,-280},
          {90,-268},{118,-268}},       color={0,0,127}));
  connect(heaPumFlo.y, secLooPum1.u3) annotation (Line(points={{-58,-280},{90,-280},
          {90,-308},{118,-308}},       color={0,0,127}));
  connect(cenBorPum.y, yPumCenBor)
    annotation (Line(points={{202,-200},{280,-200}}, color={0,0,127}));
  connect(secLooPum.y, yPumSec)
    annotation (Line(points={{202,-240},{280,-240}}, color={0,0,127}));
  connect(u1SumCooBor, notCooBor.u) annotation (Line(points={{-280,20},{-200,20},
          {-200,-60},{-142,-60}}, color={255,0,255}));
  connect(notCooBor.y, norRatSum1.u1)
    annotation (Line(points={{-118,-60},{38,-60}}, color={255,0,255}));
  connect(norRatSum.y, norRatSum1.u2) annotation (Line(points={{2,-80},{20,-80},
          {20,-68},{38,-68}}, color={255,0,255}));
  connect(norRatSum1.y, botBor.u2) annotation (Line(points={{62,-60},{70,-60},{70,
          -28},{78,-28}}, color={255,0,255}));
  connect(onlPer1.y, onlPer2.u1)
    annotation (Line(points={{62,70},{78,70}}, color={255,0,255}));
  connect(u1SumCooBor, onlPer2.u2) annotation (Line(points={{-280,20},{70,20},{70,
          62},{78,62}}, color={255,0,255}));
  connect(onlPer2.y, cenBorPum1.u2) annotation (Line(points={{102,70},{110,70},{
          110,-260},{118,-260}}, color={255,0,255}));
  connect(onlPer2.y, secLooPum1.u2) annotation (Line(points={{102,70},{110,70},{
          110,-300},{118,-300}}, color={255,0,255}));
  connect(mHeaPum_flow, cenBorPum1.u1) annotation (Line(points={{-280,-250},{80,
          -250},{80,-252},{118,-252}}, color={0,0,127}));
  connect(mHeaPum_flow, secLooPum1.u1) annotation (Line(points={{-280,-250},{80,
          -250},{80,-292},{118,-292}}, color={0,0,127}));
  connect(mPer_flow.u2, gai.y) annotation (Line(points={{78,-126},{-100,-126},{
          -100,-120},{-118,-120}}, color={0,0,127}));
  connect(mPer_flow.y, yPumPerBor)
    annotation (Line(points={{102,-120},{280,-120}}, color={0,0,127}));
  connect(mPer_min.y, mPer_flow.u1) annotation (Line(points={{62,-100},{72,-100},
          {72,-114},{78,-114}}, color={0,0,127}));
  connect(cenBorPum.u1, mCen_flow.y)
    annotation (Line(points={{178,-192},{102,-192}}, color={0,0,127}));
  connect(mCen_flow.u1, mCen_min.y) annotation (Line(points={{78,-186},{68,-186},
          {68,-170},{62,-170}}, color={0,0,127}));
  connect(mCen_flow.u2, gai2.y)
    annotation (Line(points={{78,-198},{-118,-198}}, color={0,0,127}));
annotation (defaultComponentName="borCon",
Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-100,140},{100,100}},
          textString="%name",
          textColor={0,0,255})}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-260,-320},{260,320}})));
end Borefields;
