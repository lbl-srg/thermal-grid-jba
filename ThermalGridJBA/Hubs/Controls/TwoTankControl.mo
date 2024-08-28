within ThermalGridJBA.Hubs.Controls;
model TwoTankControl "Control block for alternating two tank charging"
  extends Modelica.Blocks.Icons.Block;

  parameter Modelica.Units.SI.ThermodynamicTemperature T2Sup
    "Supply temperature for the two-status tank";
  parameter Modelica.Units.SI.ThermodynamicTemperature T3Sup
    "Supply temperature for the three-status tank";
  parameter Modelica.Units.SI.MassFlowRate m_flow_set
    "Set mass flow rate for fast charging";
  parameter Real rSlo
    "Ratio for slow charging mass flow rate";

  Buildings.Controls.OBC.CDL.Reals.LimitSlewRate ramLim(raisingSlewRate=
        m_flow_set/90)
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));
  RealListParameters reaLisPar_mPum_flow(n=4, x=m_flow_set*{0,rSlo,1,1})
    annotation (Placement(transformation(extent={{20,-10},{40,10}})));
  TwoTankCommand twoTanCom
    annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  RealListParameters reaLisPar_yVal(n=4, x={1,1,0,1})
    annotation (Placement(transformation(extent={{20,-70},{40,-50}})));
  RealListParameters reaLisPar_TConSup(n=4, x={15 + 273.15,T3Sup,T2Sup,T3Sup})
    annotation (Placement(transformation(extent={{20,50},{40,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TConSup
    "Condenser supply temperature" annotation (Placement(transformation(extent={
            {100,40},{140,80}}), iconTransformation(extent={{100,40},{140,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput mPum_flow
    "Set primary pump flow rate" annotation (Placement(transformation(extent={{100,
            -20},{140,20}}), iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yVal "Mixing valve position"
    annotation (Placement(transformation(extent={{100,-80},{140,-40}}),
        iconTransformation(extent={{100,-80},{140,-40}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput u2 annotation (Placement(
        transformation(rotation=0, extent={{-140,40},{-100,80}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput u3 annotation (Placement(
        transformation(rotation=0, extent={{-140,-60},{-100,-20}}),
        iconTransformation(extent={{-140,-80},{-100,-40}})));
equation
  connect(ramLim.y,mPum_flow)
    annotation (Line(points={{82,0},{120,0}}, color={0,0,127}));
  connect(reaLisPar_mPum_flow.y,ramLim. u)
    annotation (Line(points={{42,0},{58,0}}, color={0,0,127}));
  connect(twoTanCom.y,reaLisPar_mPum_flow. u)
    annotation (Line(points={{-18,0},{18,0}}, color={255,127,0}));
  connect(reaLisPar_yVal.y,yVal)
    annotation (Line(points={{42,-60},{120,-60}}, color={0,0,127}));
  connect(twoTanCom.y,reaLisPar_yVal. u) annotation (Line(points={{-18,0},{0,0},
          {0,-60},{18,-60}}, color={255,127,0}));
  connect(reaLisPar_TConSup.y,TConSup)
    annotation (Line(points={{42,60},{120,60}}, color={0,0,127}));
  connect(twoTanCom.y,reaLisPar_TConSup. u) annotation (Line(points={{-18,0},{0,
          0},{0,60},{18,60}}, color={255,127,0}));
  connect(u2, twoTanCom.u2) annotation (Line(points={{-120,60},{-60,60},{-60,6},
          {-42,6}},
               color={255,0,255}));
  connect(u3, twoTanCom.u3) annotation (Line(points={{-120,-40},{-60,-40},{-60,-6},
          {-42,-6}}, color={255,127,0}));
annotation(defaultComponentName="twoTanCon");
end TwoTankControl;
