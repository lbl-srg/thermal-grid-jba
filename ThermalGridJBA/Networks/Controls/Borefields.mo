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
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uDisPum(
    final unit="1",
    final min=0,
    final max=1)
    "District pump norminal speed"
    annotation (Placement(transformation(extent={{-300,-120},{-260,-80}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValPriByp(
    final min=0,
    final max=1,
    final unit="1") "Primary bypass valve position setpoint"
    annotation (Placement(transformation(extent={{260,-30},{300,10}}),
        iconTransformation(extent={{100,60},{140,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValIso(
    final min=0,
    final max=1,
    final unit="1") "Secondary loop isolation valve position"
    annotation (Placement(transformation(extent={{260,-70},{300,-30}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumPerBor(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint for the pump of the perimeter borefield"
    annotation (Placement(transformation(extent={{260,-120},{300,-80}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumPri(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint for the pump of the primary loop"
    annotation (Placement(transformation(extent={{260,-160},{300,-120}}),
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
    annotation (Placement(transformation(extent={{-240,280},{-220,300}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(final k=1) "Winter"
    annotation (Placement(transformation(extent={{-100,280},{-80,300}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum(final k=3) "Summer"
    annotation (Placement(transformation(extent={{-100,220},{-80,240}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higEleRat "High electricity rate"
    annotation (Placement(transformation(extent={{-200,170},{-180,190}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin "In Winter"
    annotation (Placement(transformation(extent={{-20,170},{0,190}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum "In Summer"
    annotation (Placement(transformation(extent={{-20,110},{0,130}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High plant load"
    annotation (Placement(transformation(extent={{-180,280},{-160,300}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant spr(final k=2) "Spring"
    annotation (Placement(transformation(extent={{-100,250},{-80,270}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant fal(final k=4) "Fall"
    annotation (Placement(transformation(extent={{-100,190},{-80,210}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higPlaLoa "High plant load"
    annotation (Placement(transformation(extent={{-142,170},{-122,190}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSpr "In Spring"
    annotation (Placement(transformation(extent={{-20,140},{0,160}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inFal "In Fall"
    annotation (Placement(transformation(extent={{-20,80},{0,100}})));
  Buildings.Controls.OBC.CDL.Logical.Not norRat "Normal rate"
    annotation (Placement(transformation(extent={{-140,40},{-120,60}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSpr "Normal rate in Spring"
    annotation (Placement(transformation(extent={{60,40},{80,60}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatFal "Normal rate in Fall"
    annotation (Placement(transformation(extent={{60,10},{80,30}})));
  Buildings.Controls.OBC.CDL.Logical.Or onlPer1
    "Enable only perimeter borefield"
    annotation (Placement(transformation(extent={{100,40},{120,60}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatHig
    "High rate and high plant load"
    annotation (Placement(transformation(extent={{-100,-20},{-80,0}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatWin "Normal rate in Winter"
    annotation (Placement(transformation(extent={{60,-50},{80,-30}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSum "Normal rate in Summer"
    annotation (Placement(transformation(extent={{60,-80},{80,-60}})));
  Buildings.Controls.OBC.CDL.Logical.Or botBor
    "Enable both perimeter and center borefields"
    annotation (Placement(transformation(extent={{100,-50},{120,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Or botBor1
    "Enable both perimeter and center borefields"
    annotation (Placement(transformation(extent={{160,-20},{180,0}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(
    final k=mBorFiePer_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{60,-110},{80,-90}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(
    final k=mWat_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{60,-150},{80,-130}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal byPasPri(
    final realTrue=0,
    final realFalse=1)
    "Bypass valve position"
    annotation (Placement(transformation(extent={{220,-20},{240,0}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal isoSec
    "Secondary loop isolation valve"
    annotation (Placement(transformation(extent={{220,-60},{240,-40}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mBorFieCen_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{60,-190},{80,-170}})));
  Buildings.Controls.OBC.CDL.Reals.Switch cenBorPum
    "Speed setpoint for the pump of center borfield "
    annotation (Placement(transformation(extent={{220,-210},{240,-190}})));
  Buildings.Controls.OBC.CDL.Reals.Switch secLooPum
    "Speed setpoint for the pump of secondary loop"
    annotation (Placement(transformation(extent={{220,-250},{240,-230}})));
  Buildings.Controls.OBC.CDL.Reals.Switch cenBorPum1
    "Speed setpoint for the pump of center borfield "
    annotation (Placement(transformation(extent={{140,-270},{160,-250}})));
  Buildings.Controls.OBC.CDL.Reals.Switch secLooPum1
    "Speed setpoint for the pump of secondary loop"
    annotation (Placement(transformation(extent={{140,-310},{160,-290}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(final k=1)
    "Constant one"
    annotation (Placement(transformation(extent={{-20,-250},{0,-230}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai3(
    final k=mBorFieCen_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{40,-250},{60,-230}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(final k=0)
    "Constant zero"
    annotation (Placement(transformation(extent={{40,-300},{60,-280}})));

equation
  connect(higRat.y, higEleRat.u2) annotation (Line(points={{-218,290},{-210,290},
          {-210,172},{-202,172}}, color={255,127,0}));
  connect(uEleRat, higEleRat.u1)
    annotation (Line(points={{-280,180},{-202,180}}, color={255,127,0}));
  connect(higLoa.y, higPlaLoa.u1) annotation (Line(points={{-158,290},{-150,290},
          {-150,180},{-144,180}}, color={255,127,0}));
  connect(uSt, higPlaLoa.u2) annotation (Line(points={{-280,140},{-150,140},{-150,
          172},{-144,172}}, color={255,127,0}));
  connect(win.y, inWin.u1) annotation (Line(points={{-78,290},{-30,290},{-30,180},
          {-22,180}},color={255,127,0}));
  connect(spr.y, inSpr.u1) annotation (Line(points={{-78,260},{-40,260},{-40,150},
          {-22,150}}, color={255,127,0}));
  connect(sum.y, inSum.u1) annotation (Line(points={{-78,230},{-50,230},{-50,120},
          {-22,120}}, color={255,127,0}));
  connect(fal.y, inFal.u1) annotation (Line(points={{-78,200},{-60,200},{-60,90},
          {-22,90}},color={255,127,0}));
  connect(uSea, inWin.u2) annotation (Line(points={{-280,100},{-90,100},{-90,172},
          {-22,172}},color={255,127,0}));
  connect(uSea, inSpr.u2) annotation (Line(points={{-280,100},{-90,100},{-90,142},
          {-22,142}}, color={255,127,0}));
  connect(uSea, inSum.u2) annotation (Line(points={{-280,100},{-90,100},{-90,112},
          {-22,112}}, color={255,127,0}));
  connect(uSea, inFal.u2) annotation (Line(points={{-280,100},{-90,100},{-90,82},
          {-22,82}},color={255,127,0}));
  connect(higEleRat.y, norRat.u) annotation (Line(points={{-178,180},{-170,180},
          {-170,50},{-142,50}},   color={255,0,255}));
  connect(norRat.y, norRatSpr.u2) annotation (Line(points={{-118,50},{-20,50},{-20,
          42},{58,42}},      color={255,0,255}));
  connect(norRat.y, norRatFal.u2) annotation (Line(points={{-118,50},{-20,50},{-20,
          12},{58,12}},        color={255,0,255}));
  connect(inSpr.y, norRatSpr.u1) annotation (Line(points={{2,150},{40,150},{40,50},
          {58,50}},       color={255,0,255}));
  connect(inFal.y, norRatFal.u1) annotation (Line(points={{2,90},{20,90},{20,20},
          {58,20}},         color={255,0,255}));
  connect(norRatSpr.y, onlPer1.u1)
    annotation (Line(points={{82,50},{98,50}},     color={255,0,255}));
  connect(norRatFal.y, onlPer1.u2) annotation (Line(points={{82,20},{90,20},{90,
          42},{98,42}},               color={255,0,255}));
  connect(higEleRat.y, higRatHig.u2) annotation (Line(points={{-178,180},{-170,180},
          {-170,-18},{-102,-18}},       color={255,0,255}));
  connect(higPlaLoa.y, higRatHig.u1) annotation (Line(points={{-120,180},{-110,180},
          {-110,-10},{-102,-10}},      color={255,0,255}));
  connect(norRat.y, norRatWin.u2) annotation (Line(points={{-118,50},{-20,50},{-20,
          -48},{58,-48}},      color={255,0,255}));
  connect(norRat.y, norRatSum.u2) annotation (Line(points={{-118,50},{-20,50},{-20,
          -78},{58,-78}},      color={255,0,255}));
  connect(inWin.y, norRatWin.u1) annotation (Line(points={{2,180},{50,180},{50,-40},
          {58,-40}},        color={255,0,255}));
  connect(inSum.y, norRatSum.u1) annotation (Line(points={{2,120},{30,120},{30,-70},
          {58,-70}},        color={255,0,255}));
  connect(norRatWin.y, botBor.u1)
    annotation (Line(points={{82,-40},{98,-40}},     color={255,0,255}));
  connect(norRatSum.y, botBor.u2) annotation (Line(points={{82,-70},{90,-70},{90,
          -48},{98,-48}},         color={255,0,255}));
  connect(higRatHig.y, botBor1.u1)
    annotation (Line(points={{-78,-10},{158,-10}},   color={255,0,255}));
  connect(botBor.y, botBor1.u2) annotation (Line(points={{122,-40},{140,-40},{140,
          -18},{158,-18}},        color={255,0,255}));
  connect(uDisPum, gai.u) annotation (Line(points={{-280,-100},{58,-100}},
                                 color={0,0,127}));
  connect(gai.y, yPumPerBor)
    annotation (Line(points={{82,-100},{280,-100}},  color={0,0,127}));
  connect(uDisPum, gai1.u) annotation (Line(points={{-280,-100},{20,-100},{20,-140},
          {58,-140}},            color={0,0,127}));
  connect(gai1.y, yPumPri)
    annotation (Line(points={{82,-140},{280,-140}},  color={0,0,127}));
  connect(botBor1.y, byPasPri.u)
    annotation (Line(points={{182,-10},{218,-10}},   color={255,0,255}));
  connect(byPasPri.y, yValPriByp)
    annotation (Line(points={{242,-10},{280,-10}},   color={0,0,127}));
  connect(isoSec.y, yValIso)
    annotation (Line(points={{242,-50},{280,-50}},   color={0,0,127}));
  connect(botBor1.y, isoSec.u) annotation (Line(points={{182,-10},{200,-10},{200,
          -50},{218,-50}},       color={255,0,255}));
  connect(uDisPum, gai2.u) annotation (Line(points={{-280,-100},{20,-100},{20,-180},
          {58,-180}},            color={0,0,127}));
  connect(botBor1.y, cenBorPum.u2) annotation (Line(points={{182,-10},{200,-10},
          {200,-200},{218,-200}},       color={255,0,255}));
  connect(gai2.y, cenBorPum.u1) annotation (Line(points={{82,-180},{180,-180},{180,
          -192},{218,-192}},      color={0,0,127}));
  connect(secLooPum.y, yPumSec) annotation (Line(points={{242,-240},{280,-240}},
                                  color={0,0,127}));
  connect(botBor1.y, secLooPum.u2) annotation (Line(points={{182,-10},{200,-10},
          {200,-240},{218,-240}},       color={255,0,255}));
  connect(gai1.y, secLooPum.u1) annotation (Line(points={{82,-140},{140,-140},{140,
          -232},{218,-232}},      color={0,0,127}));
  connect(cenBorPum.y, yPumCenBor)
    annotation (Line(points={{242,-200},{280,-200}}, color={0,0,127}));
  connect(onlPer1.y, cenBorPum1.u2) annotation (Line(points={{122,50},{130,50},{
          130,-260},{138,-260}},  color={255,0,255}));
  connect(onlPer1.y, secLooPum1.u2) annotation (Line(points={{122,50},{130,50},{
          130,-300},{138,-300}},  color={255,0,255}));
  connect(con.y, gai3.u)
    annotation (Line(points={{2,-240},{38,-240}},  color={0,0,127}));
  connect(gai3.y, cenBorPum1.u1) annotation (Line(points={{62,-240},{100,-240},{
          100,-252},{138,-252}},  color={0,0,127}));
  connect(gai3.y, secLooPum1.u1) annotation (Line(points={{62,-240},{100,-240},{
          100,-292},{138,-292}},  color={0,0,127}));
  connect(con1.y, cenBorPum1.u3) annotation (Line(points={{62,-290},{90,-290},{90,
          -268},{138,-268}},      color={0,0,127}));
  connect(con1.y, secLooPum1.u3) annotation (Line(points={{62,-290},{90,-290},{90,
          -308},{138,-308}},      color={0,0,127}));
  connect(cenBorPum1.y, cenBorPum.u3) annotation (Line(points={{162,-260},{170,-260},
          {170,-208},{218,-208}},       color={0,0,127}));
  connect(secLooPum1.y, secLooPum.u3) annotation (Line(points={{162,-300},{180,-300},
          {180,-248},{218,-248}},       color={0,0,127}));
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
