within ThermalGridJBA.Networks.Controls;
block DryCooler "Dry cooler and the associated pump control"

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


  Buildings.Controls.OBC.CDL.Interfaces.RealInput mDryCooLoa_flow[2](
    each final unit="kg/s")
    "Mass flow rate of loads to be served by dry cooler"
    annotation (Placement(transformation(extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-260,-40}),
        iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryBul(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Ambient dry bulb temperature"
    annotation (Placement(transformation(extent={{-280,-210},{-240,-170}}),
        iconTransformation(extent={{-140,-120},{-100,-80}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPum
    "Heat pump commanded on"
    annotation (Placement(transformation(extent={{-280,60},{-240,100}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1HeaPumMod
    "Heat pump mode: true - heating mode"
    annotation (Placement(transformation(extent={{-280,-10},{-240,30}}),
        iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDyrCooIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Dry cooler inlet temperature"
    annotation (Placement(transformation(extent={{-280,-100},{-240,-60}}),
        iconTransformation(extent={{-140,-50},{-100,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TDryCooOut(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Dry cooler outlet glycol temperature"
    annotation (Placement(transformation(extent={{-280,-160},{-240,-120}}),
        iconTransformation(extent={{-140,-90},{-100,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TAirDryCooIn(
    final unit="K",
    displayUnit="degC")
    "Dry cooler air temperature input"
    annotation (Placement(transformation(extent={{240,120},{280,160}}),
        iconTransformation(extent={{100,60},{140,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yPumDryCoo(
    final quantity="MassFlowRate",
    final unit="kg/s")
    "Speed setpoint of the pump for the dry cooler"
    annotation (Placement(transformation(extent={{240,30},{280,70}}),
      iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yDryCoo(
    final min=0,
    final max=1,
    final unit="1")
    "Speed setpoint of the dry cooler fan"
    annotation (Placement(transformation(extent={{240,-70},{280,-30}}),
        iconTransformation(extent={{100,-100},{140,-60}})));

  Buildings.Controls.OBC.CDL.Reals.Switch dryCooPum
    "Dry cooler pump speed setpoint"
    annotation (Placement(transformation(extent={{200,40},{220,60}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(final k=0) "Zero"
    annotation (Placement(transformation(extent={{160,10},{180,30}})));
  Buildings.Controls.OBC.CDL.Logical.And heaPumCoo
    "Heat pump enabled in cooling mode"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
  Buildings.Controls.OBC.CDL.Logical.Not notHea "Not in heating mode"
    annotation (Placement(transformation(extent={{-160,0},{-140,20}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con2(final k=TAppSet)
    "Dry cooler approach temperature setpoint"
    annotation (Placement(transformation(extent={{60,-30},{80,-10}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset fanCon(
    final controllerType=fanConTyp,
    final k=kFan,
    final Ti=TiFan,
    final Td=TdFan,
    final reverseActing=false,
    final y_reset=minFanSpe)
    "Dry cooler fan speed controller"
    annotation (Placement(transformation(extent={{140,-30},{160,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooFan
    "Dry cooler fan speed setpoint"
    annotation (Placement(transformation(extent={{200,-60},{220,-40}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo(final k=0)
    "Disable fan"
    annotation (Placement(transformation(extent={{140,-100},{160,-80}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaDryCoo1 "Enable dry cooler"
    annotation (Placement(transformation(extent={{-80,40},{-60,60}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{100,-60},{120,-40}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(final k=-1)
    "Reverse the subtract"
    annotation (Placement(transformation(extent={{40,-120},{60,-100}})));
  Buildings.Controls.OBC.CDL.Logical.Or cooWat
    "Dry cooler should cooling down the water flow"
    annotation (Placement(transformation(extent={{-30,-60},{-10,-40}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Check temperature difference"
    annotation (Placement(transformation(extent={{-180,-194},{-160,-174}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter heaShi(
    final p=-TAppSet)
    "Temperature shift when the dry cooler should heat up the fluid"
    annotation (Placement(transformation(extent={{-40,98},{-20,118}})));
  Buildings.Controls.OBC.CDL.Reals.AddParameter cooShi(
    final p=TAppSet)
    "Temperature shift when the dry cooler should cool down the fluid"
    annotation (Placement(transformation(extent={{-40,150},{-20,170}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooInAir1
    "Dry cooler inlet air temperature"
    annotation (Placement(transformation(extent={{100,140},{120,160}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooInAir
    "Dry cooler inlet air temperature"
    annotation (Placement(transformation(extent={{180,130},{200,150}})));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1Eco
    "Economizer commanded on" annotation (Placement(transformation(extent={{-280,
            160},{-240,200}}), iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Reals.Greater rejHea(final h=0.25)
    "Output true if heat needs to be rejected"
    annotation (Placement(transformation(extent={{-160,-90},{-140,-70}})));

  Buildings.Controls.OBC.CDL.Reals.Add mTot "Total mass flow rate to be served"
    annotation (Placement(transformation(extent={{-160,-50},{-140,-30}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiM_flow(final k=1.05)
    "Gain for mass flow rate (in real systems to make sure loads are not starved)"
    annotation (Placement(transformation(extent={{-120,-50},{-100,-30}})));
equation
  connect(dryCooPum.y, yPumDryCoo)
    annotation (Line(points={{222,50},{260,50}},     color={0,0,127}));
  connect(con.y, dryCooPum.u3) annotation (Line(points={{182,20},{190,20},{190,42},
          {198,42}},         color={0,0,127}));
  connect(u1HeaPumMod, notHea.u)
    annotation (Line(points={{-260,10},{-162,10}},     color={255,0,255}));
  connect(notHea.y, heaPumCoo.u1)
    annotation (Line(points={{-138,10},{-82,10}},      color={255,0,255}));
  connect(u1HeaPum, heaPumCoo.u2) annotation (Line(points={{-260,80},{-98,80},{
          -98,2},{-82,2}},          color={255,0,255}));
  connect(u1HeaPum, enaDryCoo1.u1) annotation (Line(points={{-260,80},{-98,80},{
          -98,50},{-82,50}},       color={255,0,255}));
  connect(enaDryCoo1.y, dryCooPum.u2)
    annotation (Line(points={{-58,50},{198,50}},     color={255,0,255}));
  connect(dryCooFan.y, yDryCoo)
    annotation (Line(points={{222,-50},{260,-50}},   color={0,0,127}));
  connect(con2.y, fanCon.u_s)
    annotation (Line(points={{82,-20},{138,-20}},    color={0,0,127}));
  connect(fanCon.y, dryCooFan.u1) annotation (Line(points={{162,-20},{180,-20},{
          180,-42},{198,-42}},    color={0,0,127}));
  connect(enaDryCoo1.y, dryCooFan.u2) annotation (Line(points={{-58,50},{130,50},
          {130,-40},{164,-40},{164,-50},{198,-50}},
                                  color={255,0,255}));
  connect(zeo.y, dryCooFan.u3) annotation (Line(points={{162,-90},{180,-90},{180,
          -58},{198,-58}},   color={0,0,127}));
  connect(enaDryCoo1.y, fanCon.trigger) annotation (Line(points={{-58,50},{130,50},
          {130,-40},{144,-40},{144,-32}},          color={255,0,255}));
  connect(heaPumCoo.y, cooWat.u2) annotation (Line(points={{-58,10},{-50,10},{
          -50,-58},{-32,-58}},   color={255,0,255}));
  connect(cooWat.y, swi1.u2)
    annotation (Line(points={{-8,-50},{98,-50}},    color={255,0,255}));
  connect(TDryCooOut, sub.u1) annotation (Line(points={{-260,-140},{-200,-140},{
          -200,-178},{-182,-178}}, color={0,0,127}));
  connect(TDryBul, sub.u2) annotation (Line(points={{-260,-190},{-182,-190}},
                              color={0,0,127}));
  connect(sub.y, gai.u)
    annotation (Line(points={{-158,-184},{-60,-184},{-60,-110},{38,-110}},
                                                      color={0,0,127}));
  connect(sub.y, swi1.u1) annotation (Line(points={{-158,-184},{100,-184},{100,-42},
          {98,-42}},   color={0,0,127}));
  connect(gai.y, swi1.u3) annotation (Line(points={{62,-110},{80,-110},{80,-58},
          {98,-58}},   color={0,0,127}));
  connect(swi1.y, fanCon.u_m) annotation (Line(points={{122,-50},{150,-50},{150,
          -32}},  color={0,0,127}));
  connect(TDryBul, cooShi.u) annotation (Line(points={{-260,-190},{-212,-190},{-212,
          160},{-42,160}},    color={0,0,127}));
  connect(TDryBul, heaShi.u) annotation (Line(points={{-260,-190},{-212,-190},{-212,
          108},{-42,108}},    color={0,0,127}));
  connect(cooWat.y, dryCooInAir1.u2) annotation (Line(points={{-8,-50},{0,-50},{
          0,150},{98,150}},      color={255,0,255}));
  connect(cooShi.y, dryCooInAir1.u1) annotation (Line(points={{-18,160},{40,160},
          {40,158},{98,158}},  color={0,0,127}));
  connect(heaShi.y, dryCooInAir1.u3) annotation (Line(points={{-18,108},{20,108},
          {20,142},{98,142}},     color={0,0,127}));
  connect(enaDryCoo1.y, dryCooInAir.u2) annotation (Line(points={{-58,50},{130,50},
          {130,140},{178,140}},         color={255,0,255}));
  connect(dryCooInAir1.y, dryCooInAir.u1) annotation (Line(points={{122,150},{160,
          150},{160,148},{178,148}},    color={0,0,127}));
  connect(TDryBul, dryCooInAir.u3) annotation (Line(points={{-260,-190},{-212,-190},
          {-212,132},{178,132}},   color={0,0,127}));
  connect(dryCooInAir.y, TAirDryCooIn)
    annotation (Line(points={{202,140},{260,140}},   color={0,0,127}));
  connect(enaDryCoo1.u2, u1Eco) annotation (Line(points={{-82,42},{-182,42},{-182,
          180},{-260,180}}, color={255,0,255}));
  connect(TDyrCooIn, rejHea.u1)
    annotation (Line(points={{-260,-80},{-162,-80}}, color={0,0,127}));
  connect(TDryBul, rejHea.u2) annotation (Line(points={{-260,-190},{-212,-190},{
          -212,-88},{-162,-88}}, color={0,0,127}));
  connect(rejHea.y, cooWat.u1)
    annotation (Line(points={{-138,-80},{-86,-80},{-86,-50},{-32,-50}},
                                                    color={255,0,255}));
  connect(mTot.u1, mDryCooLoa_flow[1]) annotation (Line(points={{-162,-34},{-204,
          -34},{-204,-45},{-260,-45}}, color={0,0,127}));
  connect(mTot.u2, mDryCooLoa_flow[2]) annotation (Line(points={{-162,-46},{-206,
          -46},{-206,-35},{-260,-35}}, color={0,0,127}));
  connect(mTot.y, gaiM_flow.u)
    annotation (Line(points={{-138,-40},{-122,-40}}, color={0,0,127}));
  connect(gaiM_flow.y, dryCooPum.u1) annotation (Line(points={{-98,-40},{-70,
          -40},{-70,-20},{20,-20},{20,58},{198,58}}, color={0,0,127}));
annotation (defaultComponentName="dryCooCon",
  Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
                         graphics={Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
       Text(extent={{-104,144},{96,104}},
          textString="%name",
          textColor={0,0,255})}),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-240,-200},{240,200}})));
end DryCooler;
