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
  parameter Real mFan_flow_nominal(final unit="kg/s")
    "Design flow rate for dry cooler fan";
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
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput mSetPumDryCoo_flow(final
      quantity="MassFlowRate", final unit="kg/s")
    "Speed setpoint of the pump for the dry cooler" annotation (Placement(
        transformation(extent={{240,80},{280,120}}), iconTransformation(extent={{100,40},
            {140,80}})));

  Buildings.Controls.OBC.CDL.Reals.Switch dryCooPum
    "Dry cooler pump speed setpoint"
    annotation (Placement(transformation(extent={{200,90},{220,110}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(final k=0) "Zero"
    annotation (Placement(transformation(extent={{160,60},{180,80}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con2(final k=TAppSet)
    "Dry cooler approach temperature setpoint"
    annotation (Placement(transformation(extent={{102,-60},{122,-40}})));
  Buildings.Controls.OBC.CDL.Reals.PIDWithReset fanCon(
    final controllerType=fanConTyp,
    final k=kFan,
    final Ti=TiFan,
    final Td=TdFan,
    final reverseActing=false,
    final y_reset=minFanSpe)
    "Dry cooler fan speed controller"
    annotation (Placement(transformation(extent={{140,-60},{160,-40}})));
  Buildings.Controls.OBC.CDL.Reals.Switch dryCooFan
    "Dry cooler fan speed setpoint"
    annotation (Placement(transformation(extent={{200,-110},{220,-90}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zeo(final k=0)
    "Disable fan"
    annotation (Placement(transformation(extent={{140,-150},{160,-130}})));
  Buildings.Controls.OBC.CDL.Logical.Or enaDryCoo1 "Enable dry cooler"
    annotation (Placement(transformation(extent={{-80,40},{-60,60}})));
  Buildings.Controls.OBC.CDL.Reals.Switch swi1
    annotation (Placement(transformation(extent={{104,-102},{124,-82}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gai(final k=-1)
    "Reverse the subtract"
    annotation (Placement(transformation(extent={{40,-120},{60,-100}})));
  Buildings.Controls.OBC.CDL.Reals.Subtract sub
    "Check temperature difference"
    annotation (Placement(transformation(extent={{-180,-194},{-160,-174}})));

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u1Eco
    "Economizer commanded on" annotation (Placement(transformation(extent={{-280,
            160},{-240,200}}), iconTransformation(extent={{-140,70},{-100,110}})));
  Buildings.Controls.OBC.CDL.Reals.Greater rejHea(final h=0.25)
    "Output true if heat needs to be rejected"
    annotation (Placement(transformation(extent={{-160,-90},{-140,-70}})));

  Buildings.Controls.OBC.CDL.Reals.Add mTot "Total mass flow rate to be served"
    annotation (Placement(transformation(extent={{-160,-50},{-140,-30}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiMPum_flow(final k=1.05)
    "Gain for mass flow rate (in real systems to make sure loads are not starved)"
    annotation (Placement(transformation(extent={{-120,-50},{-100,-30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput mSetFanDryCoo_flow(final
      quantity="MassFlowRate", final unit="kg/s")
    "Speed setpoint of the fan of the dry cooler" annotation (Placement(
        transformation(extent={{240,-20},{280,20}}), iconTransformation(extent=
            {{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter gaiMFan_flow(k=
        mFan_flow_nominal)
    "Gain for fan mass flow rate to achieve equal capacity flow rate on glycol and air side"
    annotation (Placement(transformation(extent={{160,-10},{180,10}})));
equation
  connect(dryCooPum.y, mSetPumDryCoo_flow)
    annotation (Line(points={{222,100},{260,100}}, color={0,0,127}));
  connect(con.y, dryCooPum.u3) annotation (Line(points={{182,70},{190,70},{190,92},
          {198,92}},         color={0,0,127}));
  connect(u1HeaPum, enaDryCoo1.u1) annotation (Line(points={{-260,80},{-220,80},
          {-220,50},{-82,50}},     color={255,0,255}));
  connect(enaDryCoo1.y, dryCooPum.u2)
    annotation (Line(points={{-58,50},{70,50},{70,100},{198,100}},
                                                     color={255,0,255}));
  connect(con2.y, fanCon.u_s)
    annotation (Line(points={{124,-50},{138,-50}},   color={0,0,127}));
  connect(fanCon.y, dryCooFan.u1) annotation (Line(points={{162,-50},{180,-50},{
          180,-92},{198,-92}},    color={0,0,127}));
  connect(enaDryCoo1.y, dryCooFan.u2) annotation (Line(points={{-58,50},{70,50},
          {70,-70},{164,-70},{164,-100},{198,-100}},
                                  color={255,0,255}));
  connect(zeo.y, dryCooFan.u3) annotation (Line(points={{162,-140},{180,-140},{180,
          -108},{198,-108}}, color={0,0,127}));
  connect(enaDryCoo1.y, fanCon.trigger) annotation (Line(points={{-58,50},{70,50},
          {70,-70},{144,-70},{144,-62}},           color={255,0,255}));
  connect(TDryCooOut, sub.u1) annotation (Line(points={{-260,-140},{-200,-140},{
          -200,-178},{-182,-178}}, color={0,0,127}));
  connect(TDryBul, sub.u2) annotation (Line(points={{-260,-190},{-182,-190}},
                              color={0,0,127}));
  connect(sub.y, gai.u)
    annotation (Line(points={{-158,-184},{-60,-184},{-60,-110},{38,-110}},
                                                      color={0,0,127}));
  connect(sub.y, swi1.u1) annotation (Line(points={{-158,-184},{72,-184},{72,-84},
          {102,-84}},  color={0,0,127}));
  connect(gai.y, swi1.u3) annotation (Line(points={{62,-110},{80,-110},{80,-100},
          {102,-100}}, color={0,0,127}));
  connect(swi1.y, fanCon.u_m) annotation (Line(points={{126,-92},{150,-92},{150,
          -62}},  color={0,0,127}));
  connect(enaDryCoo1.u2, u1Eco) annotation (Line(points={{-82,42},{-182,42},{-182,
          180},{-260,180}}, color={255,0,255}));
  connect(TDyrCooIn, rejHea.u1)
    annotation (Line(points={{-260,-80},{-162,-80}}, color={0,0,127}));
  connect(TDryBul, rejHea.u2) annotation (Line(points={{-260,-190},{-212,-190},{
          -212,-88},{-162,-88}}, color={0,0,127}));
  connect(mTot.u1, mDryCooLoa_flow[1]) annotation (Line(points={{-162,-34},{-204,
          -34},{-204,-45},{-260,-45}}, color={0,0,127}));
  connect(mTot.u2, mDryCooLoa_flow[2]) annotation (Line(points={{-162,-46},{-206,
          -46},{-206,-35},{-260,-35}}, color={0,0,127}));
  connect(mTot.y, gaiMPum_flow.u)
    annotation (Line(points={{-138,-40},{-122,-40}}, color={0,0,127}));
  connect(gaiMPum_flow.y, dryCooPum.u1) annotation (Line(points={{-98,-40},{40,-40},
          {40,108},{198,108}}, color={0,0,127}));
  connect(swi1.u2, rejHea.y) annotation (Line(points={{102,-92},{-60,-92},{-60,-80},
          {-138,-80}}, color={255,0,255}));
  connect(gaiMFan_flow.y, mSetFanDryCoo_flow)
    annotation (Line(points={{182,0},{260,0}}, color={0,0,127}));
  connect(dryCooFan.y, gaiMFan_flow.u) annotation (Line(points={{222,-100},{230,
          -100},{230,-20},{140,-20},{140,0},{158,0}}, color={0,0,127}));
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
