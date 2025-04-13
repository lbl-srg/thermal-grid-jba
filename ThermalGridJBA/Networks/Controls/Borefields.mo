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
    annotation (Placement(transformation(extent={{-300,-90},{-260,-50}}),
        iconTransformation(extent={{-140,-40},{-100,0}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPum
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{-300,-240},{-260,-200}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput mHeaPum_flow(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Heat pump mass flow rate"
    annotation (Placement(transformation(extent={{-300,-280},{-260,-240}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValPriByp(
    final min=0,
    final max=1,
    final unit="1") "Primary bypass valve position setpoint"
    annotation (Placement(transformation(extent={{260,0},{300,40}}),
        iconTransformation(extent={{100,60},{140,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValIso(
    final min=0,
    final max=1,
    final unit="1") "Secondary loop isolation valve position"
    annotation (Placement(transformation(extent={{260,-40},{300,0}}),
        iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumPerBor(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint for the pump of the perimeter borefield"
    annotation (Placement(transformation(extent={{260,-90},{300,-50}}),
        iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumPri(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint for the pump of the primary loop"
    annotation (Placement(transformation(extent={{260,-120},{300,-80}}),
        iconTransformation(extent={{100,-50},{140,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumCenBor(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint for the pump of the center borefield"
    annotation (Placement(transformation(extent={{260,-200},{300,-160}}),
        iconTransformation(extent={{100,-80},{140,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumSec(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint for the pump of the secondary loop"
    annotation (Placement(transformation(extent={{260,-320},{300,-280}}),
        iconTransformation(extent={{100,-110},{140,-70}})));

  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higRat(final k=1)
    "High electricity rate"
    annotation (Placement(transformation(extent={{-240,290},{-220,310}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant win(final k=1) "Winter"
    annotation (Placement(transformation(extent={{-120,290},{-100,310}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant sum(final k=3) "Summer"
    annotation (Placement(transformation(extent={{-120,230},{-100,250}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higEleRat "High electricity rate"
    annotation (Placement(transformation(extent={{-200,170},{-180,190}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inWin "In Winter"
    annotation (Placement(transformation(extent={{-40,170},{-20,190}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSum "In Summer"
    annotation (Placement(transformation(extent={{-40,110},{-20,130}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant higLoa(final k=3)
    "High plant load"
    annotation (Placement(transformation(extent={{-180,290},{-160,310}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant spr(final k=2) "Spring"
    annotation (Placement(transformation(extent={{-120,260},{-100,280}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant fal(final k=4) "Fall"
    annotation (Placement(transformation(extent={{-120,200},{-100,220}})));
  Buildings.Controls.OBC.CDL.Integers.Equal higPlaLoa "High plant load"
    annotation (Placement(transformation(extent={{-140,150},{-120,170}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inSpr "In Spring"
    annotation (Placement(transformation(extent={{-40,140},{-20,160}})));
  Buildings.Controls.OBC.CDL.Integers.Equal inFal "In Fall"
    annotation (Placement(transformation(extent={{-40,80},{-20,100}})));
  Buildings.Controls.OBC.CDL.Logical.Not norRat "Normal rate"
    annotation (Placement(transformation(extent={{-140,50},{-120,70}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSpr "Normal rate in Spring"
    annotation (Placement(transformation(extent={{40,60},{60,80}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatFal "Normal rate in Fall"
    annotation (Placement(transformation(extent={{40,30},{60,50}})));
  Buildings.Controls.OBC.CDL.Logical.Or onlPer1
    "Enable only perimeter borefield"
    annotation (Placement(transformation(extent={{80,60},{100,80}})));
  Buildings.Controls.OBC.CDL.Logical.And higRatHig
    "High rate and high plant load"
    annotation (Placement(transformation(extent={{-100,10},{-80,30}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatWin "Normal rate in Winter"
    annotation (Placement(transformation(extent={{40,-20},{60,0}})));
  Buildings.Controls.OBC.CDL.Logical.And norRatSum "Normal rate in Summer"
    annotation (Placement(transformation(extent={{40,-50},{60,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Or botBor
    "Enable both perimeter and center borefields"
    annotation (Placement(transformation(extent={{80,-20},{100,0}})));
  Buildings.Controls.OBC.CDL.Logical.Or botBor1
    "Enable both perimeter and center borefields"
    annotation (Placement(transformation(extent={{140,10},{160,30}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(
    final k=mBorFiePer_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{40,-80},{60,-60}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai1(
    final k=mWat_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{40,-110},{60,-90}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal byPasPri(
    final realTrue=0,
    final realFalse=1)
    "Bypass valve position"
    annotation (Placement(transformation(extent={{220,10},{240,30}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal isoSec
    "Secondary loop isolation valve"
    annotation (Placement(transformation(extent={{220,-30},{240,-10}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai2(
    final k=mBorFieCen_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{40,-140},{60,-120}})));
  Buildings.Controls.OBC.CDL.Reals.Switch cenBorPum
    "Speed setpoint for the pump of center borfield "
    annotation (Placement(transformation(extent={{180,-140},{200,-120}})));
  Buildings.Controls.OBC.CDL.Reals.Switch secLooPum
    "Speed setpoint for the pump of secondary loop"
    annotation (Placement(transformation(extent={{180,-220},{200,-200}})));
  Buildings.Controls.OBC.CDL.Reals.Switch cenBorPum1
    "Speed setpoint for the pump of center borfield "
    annotation (Placement(transformation(extent={{120,-240},{140,-220}})));
  Buildings.Controls.OBC.CDL.Reals.Switch secLooPum1
    "Speed setpoint for the pump of secondary loop"
    annotation (Placement(transformation(extent={{120,-270},{140,-250}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(final k=1)
    "Constant one"
    annotation (Placement(transformation(extent={{20,-220},{40,-200}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai3(
    final k=mBorFieCen_flow_nominal)
    "Convert to mass flow rate"
    annotation (Placement(transformation(extent={{60,-220},{80,-200}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(final k=0)
    "Constant zero"
    annotation (Placement(transformation(extent={{40,-270},{60,-250}})));
  Buildings.Controls.OBC.CDL.Reals.Switch cenBorPum2
    "Speed setpoint for the pump of center borfield "
    annotation (Placement(transformation(extent={{220,-190},{240,-170}})));
  Buildings.Controls.OBC.CDL.Reals.Max max1
    annotation (Placement(transformation(extent={{-140,-182},{-120,-162}})));
  Buildings.Controls.OBC.CDL.Reals.Switch secLooPum2
    "Speed setpoint for the pump of secondary loop"
    annotation (Placement(transformation(extent={{220,-310},{240,-290}})));
  Buildings.Controls.OBC.CDL.Reals.Max max2
    annotation (Placement(transformation(extent={{-140,-310},{-120,-290}})));
equation
  connect(higRat.y, higEleRat.u2) annotation (Line(points={{-218,300},{-210,300},
          {-210,172},{-202,172}}, color={255,127,0}));
  connect(uEleRat, higEleRat.u1)
    annotation (Line(points={{-280,180},{-202,180}}, color={255,127,0}));
  connect(higLoa.y, higPlaLoa.u1) annotation (Line(points={{-158,300},{-150,300},
          {-150,160},{-142,160}}, color={255,127,0}));
  connect(uSt, higPlaLoa.u2) annotation (Line(points={{-280,140},{-150,140},{-150,
          152},{-142,152}}, color={255,127,0}));
  connect(win.y, inWin.u1) annotation (Line(points={{-98,300},{-60,300},{-60,180},
          {-42,180}},color={255,127,0}));
  connect(spr.y, inSpr.u1) annotation (Line(points={{-98,270},{-70,270},{-70,150},
          {-42,150}}, color={255,127,0}));
  connect(sum.y, inSum.u1) annotation (Line(points={{-98,240},{-80,240},{-80,120},
          {-42,120}}, color={255,127,0}));
  connect(fal.y, inFal.u1) annotation (Line(points={{-98,210},{-90,210},{-90,90},
          {-42,90}},color={255,127,0}));
  connect(uSea, inWin.u2) annotation (Line(points={{-280,100},{-100,100},{-100,172},
          {-42,172}},color={255,127,0}));
  connect(uSea, inSpr.u2) annotation (Line(points={{-280,100},{-100,100},{-100,142},
          {-42,142}}, color={255,127,0}));
  connect(uSea, inSum.u2) annotation (Line(points={{-280,100},{-100,100},{-100,112},
          {-42,112}}, color={255,127,0}));
  connect(uSea, inFal.u2) annotation (Line(points={{-280,100},{-100,100},{-100,82},
          {-42,82}},color={255,127,0}));
  connect(higEleRat.y, norRat.u) annotation (Line(points={{-178,180},{-170,180},
          {-170,60},{-142,60}},   color={255,0,255}));
  connect(norRat.y, norRatSpr.u2) annotation (Line(points={{-118,60},{-20,60},{-20,
          62},{38,62}},      color={255,0,255}));
  connect(norRat.y, norRatFal.u2) annotation (Line(points={{-118,60},{-20,60},{-20,
          32},{38,32}},        color={255,0,255}));
  connect(inSpr.y, norRatSpr.u1) annotation (Line(points={{-18,150},{10,150},{10,
          70},{38,70}},   color={255,0,255}));
  connect(inFal.y, norRatFal.u1) annotation (Line(points={{-18,90},{-10,90},{-10,
          40},{38,40}},     color={255,0,255}));
  connect(norRatSpr.y, onlPer1.u1)
    annotation (Line(points={{62,70},{78,70}},     color={255,0,255}));
  connect(norRatFal.y, onlPer1.u2) annotation (Line(points={{62,40},{70,40},{70,
          62},{78,62}},               color={255,0,255}));
  connect(higEleRat.y, higRatHig.u2) annotation (Line(points={{-178,180},{-170,180},
          {-170,12},{-102,12}},         color={255,0,255}));
  connect(higPlaLoa.y, higRatHig.u1) annotation (Line(points={{-118,160},{-110,160},
          {-110,20},{-102,20}},        color={255,0,255}));
  connect(norRat.y, norRatWin.u2) annotation (Line(points={{-118,60},{-20,60},{-20,
          -18},{38,-18}},      color={255,0,255}));
  connect(norRat.y, norRatSum.u2) annotation (Line(points={{-118,60},{-20,60},{-20,
          -48},{38,-48}},      color={255,0,255}));
  connect(inWin.y, norRatWin.u1) annotation (Line(points={{-18,180},{20,180},{20,
          -10},{38,-10}},   color={255,0,255}));
  connect(inSum.y, norRatSum.u1) annotation (Line(points={{-18,120},{0,120},{0,-40},
          {38,-40}},        color={255,0,255}));
  connect(norRatWin.y, botBor.u1)
    annotation (Line(points={{62,-10},{78,-10}},     color={255,0,255}));
  connect(norRatSum.y, botBor.u2) annotation (Line(points={{62,-40},{70,-40},{70,
          -18},{78,-18}},         color={255,0,255}));
  connect(higRatHig.y, botBor1.u1)
    annotation (Line(points={{-78,20},{138,20}},     color={255,0,255}));
  connect(botBor.y, botBor1.u2) annotation (Line(points={{102,-10},{120,-10},{120,
          12},{138,12}},          color={255,0,255}));
  connect(uDisPum, gai.u) annotation (Line(points={{-280,-70},{38,-70}},
                                 color={0,0,127}));
  connect(gai.y, yPumPerBor)
    annotation (Line(points={{62,-70},{280,-70}},    color={0,0,127}));
  connect(uDisPum, gai1.u) annotation (Line(points={{-280,-70},{20,-70},{20,-100},
          {38,-100}},            color={0,0,127}));
  connect(gai1.y, yPumPri)
    annotation (Line(points={{62,-100},{280,-100}},  color={0,0,127}));
  connect(botBor1.y, byPasPri.u)
    annotation (Line(points={{162,20},{218,20}},     color={255,0,255}));
  connect(byPasPri.y, yValPriByp)
    annotation (Line(points={{242,20},{280,20}},     color={0,0,127}));
  connect(isoSec.y, yValIso)
    annotation (Line(points={{242,-20},{280,-20}},   color={0,0,127}));
  connect(botBor1.y, isoSec.u) annotation (Line(points={{162,20},{170,20},{170,-20},
          {218,-20}},            color={255,0,255}));
  connect(uDisPum, gai2.u) annotation (Line(points={{-280,-70},{20,-70},{20,-130},
          {38,-130}},            color={0,0,127}));
  connect(botBor1.y, cenBorPum.u2) annotation (Line(points={{162,20},{170,20},{170,
          -130},{178,-130}},            color={255,0,255}));
  connect(gai2.y, cenBorPum.u1) annotation (Line(points={{62,-130},{150,-130},{150,
          -122},{178,-122}},      color={0,0,127}));
  connect(botBor1.y, secLooPum.u2) annotation (Line(points={{162,20},{170,20},{170,
          -210},{178,-210}},            color={255,0,255}));
  connect(gai1.y, secLooPum.u1) annotation (Line(points={{62,-100},{140,-100},{140,
          -202},{178,-202}},      color={0,0,127}));
  connect(onlPer1.y, cenBorPum1.u2) annotation (Line(points={{102,70},{110,70},{
          110,-230},{118,-230}},  color={255,0,255}));
  connect(onlPer1.y, secLooPum1.u2) annotation (Line(points={{102,70},{110,70},{
          110,-260},{118,-260}},  color={255,0,255}));
  connect(con.y, gai3.u)
    annotation (Line(points={{42,-210},{58,-210}}, color={0,0,127}));
  connect(gai3.y, cenBorPum1.u1) annotation (Line(points={{82,-210},{100,-210},{
          100,-222},{118,-222}},  color={0,0,127}));
  connect(gai3.y, secLooPum1.u1) annotation (Line(points={{82,-210},{100,-210},{
          100,-252},{118,-252}},  color={0,0,127}));
  connect(con1.y, cenBorPum1.u3) annotation (Line(points={{62,-260},{90,-260},{90,
          -238},{118,-238}},      color={0,0,127}));
  connect(con1.y, secLooPum1.u3) annotation (Line(points={{62,-260},{90,-260},{90,
          -268},{118,-268}},      color={0,0,127}));
  connect(cenBorPum1.y, cenBorPum.u3) annotation (Line(points={{142,-230},{150,-230},
          {150,-138},{178,-138}},       color={0,0,127}));
  connect(secLooPum1.y, secLooPum.u3) annotation (Line(points={{142,-260},{160,-260},
          {160,-218},{178,-218}},       color={0,0,127}));
  connect(cenBorPum.y, max1.u1) annotation (Line(points={{202,-130},{210,-130},{
          210,-150},{-160,-150},{-160,-166},{-142,-166}}, color={0,0,127}));
  connect(u1HeaPum, cenBorPum2.u2) annotation (Line(points={{-280,-220},{-40,-220},
          {-40,-180},{218,-180}}, color={255,0,255}));
  connect(max1.y, cenBorPum2.u1)
    annotation (Line(points={{-118,-172},{218,-172}}, color={0,0,127}));
  connect(cenBorPum.y, cenBorPum2.u3) annotation (Line(points={{202,-130},{210,-130},
          {210,-188},{218,-188}}, color={0,0,127}));
  connect(cenBorPum2.y, yPumCenBor)
    annotation (Line(points={{242,-180},{280,-180}}, color={0,0,127}));
  connect(secLooPum.y, secLooPum2.u3) annotation (Line(points={{202,-210},{210,-210},
          {210,-308},{218,-308}}, color={0,0,127}));
  connect(mHeaPum_flow, max1.u2) annotation (Line(points={{-280,-260},{-180,-260},
          {-180,-178},{-142,-178}}, color={0,0,127}));
  connect(mHeaPum_flow, max2.u2) annotation (Line(points={{-280,-260},{-180,-260},
          {-180,-306},{-142,-306}}, color={0,0,127}));
  connect(secLooPum.y, max2.u1) annotation (Line(points={{202,-210},{210,-210},{
          210,-280},{-160,-280},{-160,-294},{-142,-294}}, color={0,0,127}));
  connect(max2.y, secLooPum2.u1) annotation (Line(points={{-118,-300},{-100,-300},
          {-100,-292},{218,-292}}, color={0,0,127}));
  connect(u1HeaPum, secLooPum2.u2) annotation (Line(points={{-280,-220},{-40,-220},
          {-40,-300},{218,-300}}, color={255,0,255}));
  connect(secLooPum2.y, yPumSec)
    annotation (Line(points={{242,-300},{280,-300}}, color={0,0,127}));
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
