within ThermalGridJBA.Hubs.Controls;
block TwoTankCoordination
  extends Modelica.Blocks.Icons.Block;
  extends ThermalGridJBA.Hubs.Controls.BaseClasses.ConnectorDeclarationHHW;

  parameter Boolean have_hotWat(fixed=true) "True if there is integrated DHW";

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uHot if have_hotWat
    "Charge request from the domestic hot water tank" annotation (Placement(
        transformation(extent={{-140,80},{-100,120}}), iconTransformation(
          extent={{-140,80},{-100,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TTopHot(final unit="K",
      displayUnit="degC") if have_hotWat
                          "Tank top temperature of the domestic hot water tank"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSetHot(final unit="K",
      displayUnit="degC") if have_hotWat
    "Tank top set point temperature of the domestic hot water tank" annotation
    (Placement(transformation(extent={{-140,0},{-100,40}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yMix(final unit="1")
    if have_hotWat "Mixing valve control signal" annotation (Placement(
        transformation(extent={{100,60},{140,100}}), iconTransformation(extent={{100,60},
            {140,100}})));

block WithDHW
  extends Modelica.Blocks.Icons.Block;
  extends ThermalGridJBA.Hubs.Controls.BaseClasses.ConnectorDeclarationHHW;

  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uHot
    "Charge request from the domestic hot water tank" annotation (Placement(
        transformation(extent={{-140,80},{-100,120}}), iconTransformation(
          extent={{-140,80},{-100,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TTopHot(final unit="K",
      displayUnit="degC") "Tank top temperature of the domestic hot water tank"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}}),
        iconTransformation(extent={{-140,40},{-100,80}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSetHot(final unit="K",
      displayUnit="degC")
    "Tank top set point temperature of the domestic hot water tank" annotation
    (Placement(transformation(extent={{-140,0},{-100,40}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yMix(final unit="1")
    "Mixing valve control signal" annotation (Placement(
        transformation(extent={{100,60},{140,100}}), iconTransformation(extent={{100,60},
            {140,100}})));

equation
  y = uHot or uHea;
  if uHot and uHea then
   yMix = 0.5;
   yDiv = 1;
   TTop = if TSetHot > TSetHea then TTopHot else TTopHea;
   TSet = max(TSetHot,TSetHea);
  elseif uHot and not uHea then
   yMix = 0;
   yDiv = 1;
   TTop = TTopHot;
   TSet = TSetHot;
  elseif uHea and not uHot then
   yMix = 1;
   yDiv = 1;
   TTop = TTopHea;
   TSet = TSetHea;
  else
   yMix = 1;
   yDiv = 0;
   TTop = TTopHea;
   TSet = TSetHea;
  end if;

end WithDHW;

block WithoutDHW
  extends Modelica.Blocks.Icons.Block;
  extends ThermalGridJBA.Hubs.Controls.BaseClasses.ConnectorDeclarationHHW;

  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea(realTrue=1,
      realFalse=0)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
equation
    connect(uHea, booToRea.u) annotation (Line(points={{-120,-20},{-20,-20},{-20,
            0},{-12,0}}, color={255,0,255}));
    connect(booToRea.y, yDiv) annotation (Line(points={{12,0},{20,0},{20,40},{120,
            40}}, color={0,0,127}));
    connect(TTopHea, TTop) annotation (Line(points={{-120,-60},{0,-60},{0,-40},{
            120,-40}}, color={0,0,127}));
    connect(TSetHea, TSet) annotation (Line(points={{-120,-100},{0,-100},{0,-80},
            {120,-80}}, color={0,0,127}));
  connect(uHea, y) annotation (Line(points={{-120,-20},{60,-20},{60,0},{120,0}},
        color={255,0,255}));
end WithoutDHW;

  WithDHW withDHW if have_hotWat
    annotation (Placement(transformation(extent={{-10,40},{10,60}})));
  WithoutDHW withoutDHW if not have_hotWat
    annotation (Placement(transformation(extent={{-10,-60},{10,-40}})));
equation
  connect(withoutDHW.uHea, uHea) annotation (Line(points={{-12,-52},{-40,-52},{-40,
          -20},{-120,-20}}, color={255,0,255}));
  connect(withoutDHW.yDiv, yDiv) annotation (Line(points={{12,-46},{40,-46},{40,
          40},{120,40}}, color={0,0,127}));
  connect(withoutDHW.TTop, TTop) annotation (Line(points={{11,-54},{60,-54},{60,
          -40},{120,-40}}, color={0,0,127}));
  connect(withoutDHW.TSet, TSet) annotation (Line(points={{11,-58},{20,-58},{20,
          -80},{120,-80}}, color={0,0,127}));
  connect(TTopHea, withoutDHW.TTopHea) annotation (Line(points={{-120,-60},{-30,
          -60},{-30,-56},{-12,-56}}, color={0,0,127}));
  connect(TSetHea, withoutDHW.TSetHea) annotation (Line(points={{-120,-100},{-20,
          -100},{-20,-60},{-12,-60}}, color={0,0,127}));
  connect(withDHW.uHot, uHot) annotation (Line(points={{-12,60},{-60,60},{-60,100},
          {-120,100}}, color={255,0,255}));
  connect(TTopHot, withDHW.TTopHot) annotation (Line(points={{-120,60},{-68,60},
          {-68,56},{-12,56}}, color={0,0,127}));
  connect(TSetHot, withDHW.TSetHot) annotation (Line(points={{-120,20},{-50,20},
          {-50,52},{-12,52}}, color={0,0,127}));
  connect(uHea, withDHW.uHea) annotation (Line(points={{-120,-20},{-40,-20},{-40,
          48},{-12,48}}, color={255,0,255}));
  connect(TTopHea, withDHW.TTopHea) annotation (Line(points={{-120,-60},{-30,-60},
          {-30,44},{-12,44}}, color={0,0,127}));
  connect(TSetHea, withDHW.TSetHea) annotation (Line(points={{-120,-100},{-20,-100},
          {-20,40},{-12,40}}, color={0,0,127}));
  connect(withDHW.yMix, yMix) annotation (Line(points={{12,58},{80,58},{80,80},{
          120,80}}, color={0,0,127}));
  connect(withDHW.yDiv, yDiv) annotation (Line(points={{12,54},{80,54},{80,40},{
          120,40}}, color={0,0,127}));
  connect(withDHW.TTop, TTop) annotation (Line(points={{11,46},{60,46},{60,-40},
          {120,-40}}, color={0,0,127}));
  connect(withDHW.TSet, TSet) annotation (Line(points={{11,42},{20,42},{20,-80},
          {120,-80}}, color={0,0,127}));
  connect(withDHW.y, y) annotation (Line(points={{12,50},{70,50},{70,0},{120,0}},
        color={255,0,255}));
  connect(withoutDHW.y, y) annotation (Line(points={{12,-50},{70,-50},{70,0},{120,
          0}}, color={255,0,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end TwoTankCoordination;
